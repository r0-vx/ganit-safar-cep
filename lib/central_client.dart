import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'platform/central_network_stub.dart'
    if (dart.library.js_interop) 'platform/central_network_web.dart';
import 'platform/central_http_stub.dart'
    if (dart.library.js_interop) 'platform/central_http_web.dart';

Uri presentationModeUri(Uri uri, bool enabled) {
  final query = Map<String, String>.from(uri.queryParameters)
    ..remove('presentation');
  if (enabled) query['presentation'] = '1';
  // An explicit empty map clears the old query; null would keep it.
  return uri.replace(queryParameters: query);
}

class CentralFailure implements Exception {
  final String code;
  final int status;
  const CentralFailure(this.code, this.status);
  @override
  String toString() => 'CentralFailure($code)';
}

class ClassroomActivity {
  final String id, mode, chapter, classroomId, userId;
  final int grade;
  final DateTime started;
  bool ended = false;
  ClassroomActivity(
    this.id,
    this.mode,
    this.grade,
    this.chapter,
    this.classroomId,
    this.userId,
    this.started,
  );
}

/// No passwords, refresh tokens, device proof cookies, child names or answers
/// are stored in learning state. The browser owns the HttpOnly auth cookies.
class CentralClient extends ChangeNotifier {
  static const api = String.fromEnvironment('GANIT_API_URL');
  static const appVersion = String.fromEnvironment(
    'GANIT_APP_VERSION',
    defaultValue: '1.2.0',
  );
  static const _requireManaged = bool.fromEnvironment('GANIT_MANAGED');
  static const _pinnedKey = String.fromEnvironment('GANIT_LEASE_PUBLIC_KEY');
  final String apiBase;
  bool _demoPreview = false;
  bool get canPreviewDemo =>
      surface == 'dashboard' && isSuperAdmin && session != null;
  bool get presentation => canPreviewDemo && _demoPreview;
  final String surface;
  int loginRevision = 0;
  static const _defaultPollSeconds = int.fromEnvironment(
    'GANIT_MONITOR_POLL_SECONDS',
  );
  final int pollSeconds;
  String get _storagePrefix => '';
  final http.Client client;
  final DateTime Function() now;
  final http.Client Function() streamTransport;
  SharedPreferences? prefs;
  CentralSession? session;
  Map<String, dynamic>? device, lease;
  List<Map<String, dynamic>> classrooms = [], schools = [];
  String installation = '',
      connection = 'disconnected',
      error = '',
      classroom = '',
      lastSync = '',
      _leaseToken = '',
      _publicKey = '';
  bool initialized = false, mustChangePassword = false, locked = false;
  bool _starting = true,
      _syncing = false,
      _flushing = false,
      _closing = false,
      _networkAvailable = true;
  StreamSubscription<bool>? _networkSubscription;
  DateTime? expiresAt, lastInteraction, lastDashboardAt;
  Timer? heartbeat, _reconnect;
  http.Client? _streamClient;
  Timer? _pollTimer;
  bool _polling = false;
  StreamSubscription<String>? _streamSubscription;
  final _snapshots = StreamController<Map<String, dynamic>>.broadcast();
  final List<Map<String, dynamic>> _queue = [];
  final List<ClassroomActivity> _activities = [];
  Future<void>? _refreshing;
  int errorCount = 0, droppedEvents = 0;

  CentralClient({
    String? endpoint,
    this.surface = 'auto',
    this.pollSeconds = _defaultPollSeconds,
    http.Client? transport,
    DateTime Function()? clock,
    http.Client Function()? streamFactory,
  }) : apiBase = _resolveEndpoint(endpoint ?? api),
       client = transport ?? centralHttpClient(),
       now = clock ?? DateTime.now,
       streamTransport = streamFactory ?? centralHttpClient;

  static String _resolveEndpoint(String value) =>
      kIsWeb && value.startsWith('/')
      ? Uri.base.resolve(value).toString()
      : value;

  bool get managed => _requireManaged || apiBase.isNotEmpty;
  bool get isClassroomAdministrator =>
      surface == 'classroom' &&
      const {
        'super_admin',
        'admin',
        'school_admin',
      }.contains(session?.teacher.role);
  bool get canUseClassroom =>
      surface != 'dashboard' &&
      (session?.teacher.role == 'teacher' || isClassroomAdministrator);
  bool get canMonitor =>
      surface != 'classroom' &&
      session != null &&
      const {
        'super_admin',
        'school_admin',
        'viewer',
        'admin',
      }.contains(session!.teacher.role) &&
      !mustChangePassword;
  bool get canAdminister =>
      canMonitor && session!.teacher.role != 'viewer' && !presentation;
  bool get isSuperAdmin =>
      const {'super_admin', 'admin'}.contains(session?.teacher.role);
  bool get offlineAuthorized =>
      lease != null &&
      lease!['deviceId'] == installation &&
      lease!['role'] == 'teacher' &&
      (lease!['expiresAt'] as num) > _trustedSeconds;
  bool get onlineAdministratorAccess =>
      isClassroomAdministrator &&
      session?.teacher.role != 'school_admin' &&
      !locked &&
      !mustChangePassword &&
      connection == 'connected' &&
      expiresAt?.isAfter(now()) == true;
  Future<void> previewDemo(bool value) async {
    if (!canPreviewDemo) throw const CentralFailure('forbidden', 403);
    stopMonitoring();
    _demoPreview = value;
    lastDashboardAt = null;
    notifyListeners();
    startMonitoring();
  }

  bool get canLearn =>
      surface != 'dashboard' &&
      (!managed ||
          (!locked &&
              !mustChangePassword &&
              (offlineAuthorized || onlineAdministratorAccess)));
  bool get hasOfflinePin =>
      prefs?.getString(
        '${_storagePrefix}ganit_teacher_pin_${lease?['userId']}',
      ) !=
      null;
  int get pendingEvents => _queue.length;
  Stream<Map<String, dynamic>> get snapshots => _snapshots.stream;
  double get _trustedSeconds => max(
    now().millisecondsSinceEpoch / 1000,
    prefs?.getDouble('${_storagePrefix}ganit_last_trusted_time') ?? 0,
  );
  String get schoolName =>
      device?['schoolName']?.toString() ??
      lease?['schoolName']?.toString() ??
      '';
  String get classroomName =>
      device?['classroomName']?.toString() ??
      lease?['classroomName']?.toString() ??
      '';

  String _random() => base64UrlEncode(
    List<int>.generate(24, (_) => Random.secure().nextInt(256)),
  ).replaceAll('=', '');

  Future<void> init() async {
    if (initialized) return;
    prefs = await SharedPreferences.getInstance();
    installation =
        prefs!.getString('${_storagePrefix}ganit_installation_id') ?? _random();
    await prefs!.setString(
      '${_storagePrefix}ganit_installation_id',
      installation,
    );
    // Older proof-in-local-preferences is retired in the managed web flow.
    await prefs!.remove('${_storagePrefix}ganit_installation_secret');
    _publicKey = _pinnedKey.isNotEmpty
        ? _pinnedKey
        : prefs!.getString('${_storagePrefix}ganit_lease_public_key') ?? '';
    _leaseToken =
        prefs!.getString('${_storagePrefix}ganit_offline_lease') ?? '';
    lease = await verifyLease(_leaseToken, _publicKey);
    try {
      final saved =
          jsonDecode(
                prefs!.getString('${_storagePrefix}ganit_monitor_queue') ??
                    '[]',
              )
              as List;
      _queue.addAll(
        saved
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .take(1000),
      );
    } catch (_) {
      await prefs!.remove('${_storagePrefix}ganit_monitor_queue');
    }
    lastInteraction = now();
    droppedEvents =
        prefs!.getInt('${_storagePrefix}ganit_monitor_dropped') ?? 0;
    initialized = true;
    if (!managed) return;
    _networkSubscription = centralNetworkChanges().listen((online) {
      _networkAvailable = online;
      if (!online) {
        connection = 'offline';
        notifyListeners();
      } else if (_starting) {
        return;
      } else if (canMonitor) {
        startMonitoring();
      } else {
        unawaited(sync());
      }
    });
    final uri = Uri.tryParse(apiBase);
    if (uri == null ||
        !(uri.scheme == 'https' ||
            (uri.scheme == 'http' &&
                const {'localhost', '127.0.0.1', '::1'}.contains(uri.host)))) {
      locked = true;
      error = 'https_required';
      notifyListeners();
      return;
    }
    if (prefs!.getBool('${_storagePrefix}ganit_logout_pending') == true) {
      try {
        await request('POST', '/auth/logout', {'installationId': installation});
        await prefs!.remove('${_storagePrefix}ganit_logout_pending');
      } catch (_) {}
      await _lock('signed_out');
      return;
    }
    try {
      await refresh();
    } catch (_) {
      /* offline grant remains usable on a network failure */
    }
    _starting = false;
    _startHeartbeat();
    notifyListeners();
  }

  Future<Map<String, dynamic>?> verifyLease(String token, String key) async {
    try {
      final parts = token.split('.');
      if (parts.length != 2 || key.isEmpty) return null;
      final valid = await Ed25519().verify(
        utf8.encode(parts[0]),
        signature: Signature(
          base64Url.decode(base64Url.normalize(parts[1])),
          publicKey: SimplePublicKey(
            base64Url.decode(base64Url.normalize(key)),
            type: KeyPairType.ed25519,
          ),
        ),
      );
      if (!valid) return null;
      final value =
          jsonDecode(
                utf8.decode(base64Url.decode(base64Url.normalize(parts[0]))),
              )
              as Map<String, dynamic>;
      if (value['deviceId'] != installation ||
          value['role'] != 'teacher' ||
          value['expiresAt'] is! num ||
          (value['expiresAt'] as num) <= _trustedSeconds ||
          value['issuedAt'] is! num ||
          (value['issuedAt'] as num) > _trustedSeconds + 300)
        return null;
      return value;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> request(
    String method,
    String path, [
    Map<String, dynamic>? data,
    bool retry = true,
  ]) async {
    if (apiBase.isEmpty) throw const CentralFailure('not_configured', 0);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Installation-ID': installation,
      if (session != null) 'Authorization': 'Bearer ${session!.token}',
    };
    http.Response response;
    try {
      final effectivePath = path == '/dashboard' && presentation
          ? '/dashboard/demo'
          : path;
      final url = Uri.parse('$apiBase$effectivePath');
      response =
          await (method == 'GET'
                  ? client.get(url, headers: headers)
                  : method == 'PATCH'
                  ? client.patch(
                      url,
                      headers: headers,
                      body: jsonEncode(data ?? {}),
                    )
                  : client.post(
                      url,
                      headers: headers,
                      body: jsonEncode(data ?? {}),
                    ))
              .timeout(const Duration(seconds: 10));
    } catch (_) {
      connection = 'offline';
      error = 'connection_failed';
      notifyListeners();
      throw const CentralFailure('connection_failed', 0);
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      final code = decoded['code']?.toString() ?? 'server_error';
      if (response.statusCode == 401 &&
          code == 'session_expired' &&
          retry &&
          path != '/auth/refresh') {
        await refresh();
        return request(method, path, data, false);
      }
      if (path != '/login' &&
          path != '/auth/reauthenticate' &&
          path != '/auth/reset-password' &&
          (const {
            'device_revoked',
            'device_disabled',
            'reauth_required',
            'account_disabled',
            'refresh_reuse',
            'unsupported_version',
            'device_identity_rejected',
            'unassigned_classroom',
          }.contains(code))) {
        await _lock(code);
      } else if (response.statusCode >= 500) {
        connection = 'offline';
        error = 'connection_failed';
        notifyListeners();
      }
      throw CentralFailure(code, response.statusCode);
    }
    return decoded;
  }

  Future<void> _accept(Map<String, dynamic> value) async {
    final user = value['user'] as Map;
    session = CentralSession(
      TeacherIdentity(
        user['id'],
        user['name'],
        user['role'],
        user['email']?.toString() ?? '',
      ),
      value['token'],
    );
    mustChangePassword = user['must_change_password'] == 1;
    classrooms = (value['classrooms'] as List? ?? [])
        .map((r) => Map<String, dynamic>.from(r))
        .toList();
    schools = (value['schools'] as List? ?? [])
        .map((r) => Map<String, dynamic>.from(r))
        .toList();
    expiresAt = DateTime.fromMillisecondsSinceEpoch(
      ((value['expiresAt'] as num) * 1000).round(),
    );
    device = value['device'] == null
        ? null
        : Map<String, dynamic>.from(value['device']);
    if (_pinnedKey.isNotEmpty && value['leasePublicKey'] != _pinnedKey) {
      await _lock('identity_key_changed');
      throw const CentralFailure('identity_key_changed', 403);
    }
    _publicKey = value['leasePublicKey']?.toString() ?? _publicKey;
    await prefs?.setString(
      '${_storagePrefix}ganit_lease_public_key',
      _publicKey,
    );
    final serverTime =
        (value['serverTime'] as num?)?.toDouble() ?? _trustedSeconds;
    await prefs?.setDouble(
      '${_storagePrefix}ganit_last_trusted_time',
      max(serverTime, _trustedSeconds),
    );
    if (value['offlineLease'] is String) {
      _leaseToken = value['offlineLease'];
      lease = await verifyLease(_leaseToken, _publicKey);
      if (lease == null) {
        await _lock('invalid_offline_lease');
        throw const CentralFailure('invalid_offline_lease', 403);
      }
      await prefs?.setString(
        '${_storagePrefix}ganit_offline_lease',
        _leaseToken,
      );
    } else {
      lease = null;
      _leaseToken = '';
      await prefs?.remove('${_storagePrefix}ganit_offline_lease');
    }
    classroom = classroomName;
    connection = 'connected';
    error = '';
    locked = false;
    _startHeartbeat();
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    if (!initialized) await init();
    final value = await request('POST', '/login', {
      'email': email,
      'password': password,
      'installationId': installation,
    });
    await _accept(value);
    await prefs?.remove('${_storagePrefix}ganit_logout_pending');
    _starting = false;
    if (device != null) await sync();
    loginRevision++;
    notifyListeners();
  }

  Future<void> refresh() =>
      _refreshing ??= _refresh().whenComplete(() => _refreshing = null);
  Future<void> _refresh() async {
    final value = await request('POST', '/auth/refresh', {
      'installationId': installation,
    }, false);
    await _accept(value);
  }

  Future<void> enroll(String classroomId, String name) async {
    final value = await request('POST', '/devices/register', {
      'installationId': installation,
      'id': installation,
      'classroom_id': classroomId,
      'name': name,
    });
    await _accept(value);
    await sync();
  }

  Future<void> reloadClassrooms() async {
    final value = await request('GET', '/me/classrooms');
    classrooms = (value['classrooms'] as List? ?? [])
        .map((r) => Map<String, dynamic>.from(r))
        .toList();
    schools = (value['schools'] as List? ?? [])
        .map((r) => Map<String, dynamic>.from(r))
        .toList();
    notifyListeners();
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _accept(
      await request('POST', '/auth/change-password', {
        'currentPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );
  }

  Future<void> setOfflinePin(String pin) async {
    if (!canUseClassroom ||
        connection != 'connected' ||
        !offlineAuthorized ||
        !RegExp(r'^\d{6,12}$').hasMatch(pin)) {
      throw const CentralFailure('invalid_pin', 400);
    }
    final salt = _random();
    final key = await Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 120000,
      bits: 256,
    ).deriveKeyFromPassword(password: pin, nonce: utf8.encode(salt));
    await prefs!.setString(
      '${_storagePrefix}ganit_teacher_pin_${lease!['userId']}',
      '$salt.${base64UrlEncode(await key.extractBytes())}',
    );
    notifyListeners();
  }

  int _pinFailures = 0;
  DateTime? _pinBlockedUntil;
  Future<bool> unlockTeacher(String value) async {
    if ((!offlineAuthorized && !onlineAdministratorAccess) || locked)
      return false;
    if (_pinBlockedUntil?.isAfter(now()) == true) return false;
    final stored = offlineAuthorized
        ? prefs?.getString(
            '${_storagePrefix}ganit_teacher_pin_${lease!["userId"]}',
          )
        : null;
    if (stored != null) {
      final parts = stored.split('.');
      final key = await Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: 120000,
        bits: 256,
      ).deriveKeyFromPassword(password: value, nonce: utf8.encode(parts[0]));
      final actual = await key.extractBytes();
      final expected = base64Url.decode(parts[1]);
      var mismatch = actual.length ^ expected.length;
      for (var i = 0; i < min(actual.length, expected.length); i++) {
        mismatch |= actual[i] ^ expected[i];
      }
      if (mismatch == 0) {
        _pinFailures = 0;
        return true;
      }
    } else if (connection == 'connected' && session != null) {
      try {
        await request('POST', '/auth/reauthenticate', {'password': value});
        return true;
      } catch (_) {}
    }
    if (++_pinFailures >= 5) {
      _pinBlockedUntil = now().add(const Duration(minutes: 5));
    }
    return false;
  }

  Future<void> _lock(String reason) async {
    _demoPreview = false;
    session = null;
    classrooms = [];
    schools = [];
    lease = null;
    device = null;
    locked = true;
    mustChangePassword = false;
    connection = 'locked';
    error = reason;
    await prefs?.remove('${_storagePrefix}ganit_offline_lease');
    stopMonitoring();
    notifyListeners();
  }

  Future<void> logout() async {
    heartbeat?.cancel();
    stopMonitoring();
    _activities.clear();
    await prefs?.setBool('${_storagePrefix}ganit_logout_pending', true);
    await _lock('signed_out');
    try {
      await request('POST', '/auth/logout', {'installationId': installation});
      await prefs?.remove('${_storagePrefix}ganit_logout_pending');
    } catch (_) {}
  }

  void _startHeartbeat() {
    heartbeat?.cancel();
    if (managed)
      heartbeat = Timer.periodic(const Duration(seconds: 45), (_) => sync());
  }

  void interact() {
    lastInteraction = now();
  }

  ClassroomActivity? beginActivity(String mode, int grade, String chapter) {
    if (!managed || !offlineAuthorized || locked) return null;
    final activity = ClassroomActivity(
      _random(),
      mode,
      grade,
      chapter,
      lease!['classroomId'],
      lease!['userId'],
      now(),
    );
    _activities.add(activity);
    _enqueue(activity, 'started');
    interact();
    if (connection == 'connected') unawaited(sync());
    return activity;
  }

  void completeActivity(ClassroomActivity? activity) {
    if (activity == null || activity.ended) return;
    activity.ended = true;
    _enqueue(activity, 'completed');
    _activities.remove(activity);
    if (connection == 'connected') unawaited(sync());
  }

  void leaveActivity(ClassroomActivity? activity) {
    if (activity == null || activity.ended) return;
    activity.ended = true;
    _enqueue(activity, 'left');
    _activities.remove(activity);
    if (connection == 'connected') unawaited(sync());
  }

  void _enqueue(
    ClassroomActivity activity,
    String action, {
    String? errorCode,
  }) {
    final prefix = activity.mode == 'learn' ? 'lesson' : activity.mode;
    _queue.add({
      'id': _random(),
      'type': errorCode == null ? '${prefix}_$action' : 'app_error',
      'sessionId': errorCode == null ? activity.id : _random(),
      'mode': activity.mode,
      'grade': activity.grade,
      'chapterId': activity.chapter,
      'occurredAt': now().millisecondsSinceEpoch / 1000,
      'durationSeconds': max(
        0,
        now().difference(activity.started).inMilliseconds / 1000,
      ),
      'classroomId': activity.classroomId,
      'errorCode': ?errorCode,
      '_owner': activity.userId,
    });
    if (_queue.length > 1000) {
      _queue.removeAt(0);
      droppedEvents++;
      errorCount++;
      unawaited(
        prefs?.setInt(
              '${_storagePrefix}ganit_monitor_dropped',
              droppedEvents,
            ) ??
            Future.value(),
      );
    }
    unawaited(_saveQueue().then((_) => flush()));
    notifyListeners();
  }

  void reportError(String code) {
    if (!const {
      'render_error',
      'unhandled_error',
      'sync_failed',
      'queue_overflow',
      'storage_error',
    }.contains(code))
      return;
    errorCount++;
    if (!offlineAuthorized || locked) return;
    final activity =
        _activities.lastOrNull ??
        ClassroomActivity(
          _random(),
          'idle',
          (lease!['grade'] as num).toInt(),
          '',
          lease!['classroomId'],
          lease!['userId'],
          now(),
        );
    _enqueue(activity, 'error', errorCode: code);
  }

  Future<void> _saveQueue() async {
    await prefs?.setString(
      '${_storagePrefix}ganit_monitor_queue',
      jsonEncode(_queue),
    );
  }

  Future<void> flush() async {
    if (_flushing ||
        !canUseClassroom ||
        !offlineAuthorized ||
        connection != 'connected' ||
        locked)
      return;
    _flushing = true;
    try {
      final batch = _queue
          .where(
            (event) =>
                event['_owner'] == lease!['userId'] &&
                event['classroomId'] == lease!['classroomId'],
          )
          .take(100)
          .toList();
      if (batch.isEmpty) return;
      final result = await request('POST', '/devices/$installation/events', {
        'events': [
          for (final item in batch) {...item}..remove('_owner'),
        ],
      });
      final acknowledged = Set<String>.from(result['acknowledged'] as List);
      _queue.removeWhere((event) => acknowledged.contains(event['id']));
      await _saveQueue();
    } catch (_) {
      /* keep the same IDs for idempotent reconnect */
    } finally {
      _flushing = false;
      notifyListeners();
    }
  }

  Future<void> sync() async {
    if (_syncing || !managed || locked) return;
    if (lease != null && !offlineAuthorized) {
      await _lock('offline_lease_expired');
      return;
    }
    if (!offlineAuthorized && !canUseClassroom) return;
    if (!_networkAvailable) {
      connection = 'offline';
      notifyListeners();
      return;
    }
    _syncing = true;
    try {
      if (session == null ||
          expiresAt?.isBefore(now().add(const Duration(seconds: 10))) == true)
        await refresh();
      if (!canUseClassroom || device == null) return;
      final activity = _activities.lastOrNull;
      final result = await request('POST', '/devices/$installation/heartbeat', {
        'classroomId': lease!['classroomId'],
        'version': appVersion,
        'mode': activity?.mode ?? 'idle',
        'grade': activity?.grade ?? lease!['grade'],
        'chapterId': activity?.chapter ?? '',
        'lastInteractionAt':
            (lastInteraction ?? now()).millisecondsSinceEpoch / 1000,
        'networkState': 'online',
        'health': errorCount > 0 ? 'degraded' : 'ok',
        'errorCount': errorCount,
        'activeSessions': min(10, _activities.length),
      });
      connection = 'connected';
      error = '';
      lastSync = now().toIso8601String();
      classroom = result['classroom'] ?? classroom;
      await prefs?.setDouble(
        '${_storagePrefix}ganit_last_trusted_time',
        _trustedSeconds,
      );
      await flush();
    } catch (exception) {
      if (exception is! CentralFailure || !locked) {
        connection = 'offline';
      }
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  void startMonitoring() {
    _closing = false;
    if (pollSeconds > 0 || presentation) {
      _pollTimer?.cancel();
      unawaited(_pollDashboard());
      _pollTimer = Timer.periodic(
        Duration(seconds: pollSeconds > 0 ? pollSeconds : 3),
        (_) => _pollDashboard(),
      );
    } else {
      unawaited(_openStream());
    }
  }

  Future<void> _pollDashboard() async {
    if (_closing || !canMonitor || !_networkAvailable || _polling) return;
    _polling = true;
    final preview = presentation;
    try {
      final snapshot = await request('GET', '/dashboard');
      if (_closing || preview != presentation) return;
      lastDashboardAt = now();
      connection = 'connected';
      error = '';
      _snapshots.add(snapshot);
      notifyListeners();
    } catch (_) {
      if (!_closing) {
        connection = 'offline';
        notifyListeners();
      }
    } finally {
      _polling = false;
    }
  }

  void stopMonitoring() {
    _closing = true;
    _pollTimer?.cancel();
    _reconnect?.cancel();
    unawaited(_streamSubscription?.cancel());
    _streamClient?.close();
    _streamClient = null;
  }

  Future<void> _openStream() async {
    if (_closing || !canMonitor || !_networkAvailable) return;
    _reconnect?.cancel();
    await _streamSubscription?.cancel();
    _streamClient?.close();
    _streamClient = streamTransport();
    try {
      final request = http.Request('GET', Uri.parse('$apiBase/events/stream'))
        ..headers.addAll({
          'Accept': 'text/event-stream',
          'Authorization': 'Bearer ${session!.token}',
          'X-Installation-ID': installation,
        });
      final response = await _streamClient!
          .send(request)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 401) {
        await refresh();
        _scheduleReconnect();
        return;
      }
      if (response.statusCode == 403) {
        await _lock('forbidden');
        return;
      }
      if (response.statusCode != 200)
        throw CentralFailure('stream_failed', response.statusCode);
      var event = '', data = '';
      _streamSubscription = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              if (line.startsWith('event: ')) event = line.substring(7);
              if (line.startsWith('data: ')) data += line.substring(6);
              if (line.isEmpty) {
                if (event == 'snapshot' && data.isNotEmpty) {
                  _snapshots.add(jsonDecode(data) as Map<String, dynamic>);
                  lastDashboardAt = now();
                  connection = 'connected';
                  error = '';
                  notifyListeners();
                } else if (event == 'auth_required') {
                  unawaited(
                    refresh()
                        .then((_) => _openStream())
                        .catchError((_) => _scheduleReconnect()),
                  );
                }
                event = '';
                data = '';
              }
            },
            onError: (_) => _scheduleReconnect(),
            onDone: _scheduleReconnect,
            cancelOnError: true,
          );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_closing || !canMonitor || !_networkAvailable) return;
    connection = 'offline';
    notifyListeners();
    _reconnect?.cancel();
    _reconnect = Timer(
      const Duration(seconds: 3),
      () => unawaited(_openStream()),
    );
  }

  @override
  void dispose() {
    heartbeat?.cancel();
    unawaited(_networkSubscription?.cancel());
    stopMonitoring();
    client.close();
    unawaited(_snapshots.close());
    super.dispose();
  }
}
