import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ganit_safar/central_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> get fixture =>
    jsonDecode(File('test/fixtures/offline_lease.json').readAsStringSync())
        as Map<String, dynamic>;
Map<String, dynamic> authResponse([String role = 'teacher']) => {
  'token': 'memory-only-access-token',
  'expiresAt': (fixture['serverTime'] as num) + 900,
  'user': {
    'id': 'teacher-test-id',
    'name': 'Test teacher',
    'role': role,
    'must_change_password': 0,
  },
  'classrooms': [
    {
      'id': 'classroom-test-id',
      'name': 'Test classroom',
      'school_name': 'Test school',
      'grade': 1,
    },
  ],
  'device': {
    'id': 'test-board-identity-123456',
    'name': 'Test board',
    'classroomId': 'classroom-test-id',
    'classroomName': 'Test classroom',
    'schoolName': 'Test school',
    'grade': 1,
  },
  if (role == 'teacher') 'offlineLease': fixture['offlineLease'],
  'leasePublicKey': fixture['publicKey'],
  'serverTime': fixture['serverTime'],
};
http.Response jsonResponse(Map<String, dynamic> value, [int status = 200]) =>
    http.Response(
      jsonEncode(value),
      status,
      headers: {'content-type': 'application/json'},
    );

class FakeEventClient extends http.BaseClient {
  final controller = StreamController<List<int>>();
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      http.StreamedResponse(
        controller.stream,
        200,
        headers: {'content-type': 'text/event-stream'},
      );
  void emit(Map<String, dynamic> value) => controller.add(
    utf8.encode('event: snapshot\ndata: ${jsonEncode(value)}\n\n'),
  );
  @override
  void close() {
    if (!controller.isClosed) unawaited(controller.close());
  }
}

void main() {
  late DateTime clock;
  setUp(() {
    clock = DateTime.utc(2026, 11, 1);
    SharedPreferences.setMockInitialValues({
      'ganit_installation_id': 'test-board-identity-123456',
    });
  });

  test(
    'Python Ed25519 offline authorization verifies in Dart; tampering/expiry fail',
    () async {
      final client = CentralClient(
        endpoint: 'http://localhost:8787',
        clock: () => clock,
        transport: MockClient(
          (request) async => throw http.ClientException('offline'),
        ),
      );
      SharedPreferences.setMockInitialValues({
        'ganit_installation_id': 'test-board-identity-123456',
        'ganit_offline_lease': fixture['offlineLease'],
        'ganit_lease_public_key': fixture['publicKey'],
      });
      await client.init();
      expect(client.canLearn, isTrue);
      expect(client.session, isNull);
      expect(client.connection, 'offline');
      final altered = (fixture['offlineLease'] as String).replaceFirst(
        'e',
        'f',
      );
      expect(await client.verifyLease(altered, fixture['publicKey']), isNull);
      clock = clock.add(const Duration(days: 8));
      expect(client.canLearn, isFalse);
      await client.sync();
      expect(client.locked, isTrue);
      client.dispose();
    },
  );

  test(
    'offline learning queues anonymous events and reconnect retries exactly the same IDs',
    () async {
      var online = false, loseFirstAck = true;
      final deliveries = <Map<String, dynamic>>[];
      final stored = <String>{};
      SharedPreferences.setMockInitialValues({
        'ganit_installation_id': 'test-board-identity-123456',
        'ganit_offline_lease': fixture['offlineLease'],
        'ganit_lease_public_key': fixture['publicKey'],
      });
      final client = CentralClient(
        endpoint: 'http://localhost:8787',
        clock: () => clock,
        transport: MockClient((request) async {
          if (!online) throw http.ClientException('offline');
          if (request.url.path == '/auth/refresh')
            return jsonResponse(authResponse());
          if (request.url.path.endsWith('/heartbeat'))
            return jsonResponse({'classroom': 'Test classroom'});
          if (request.url.path.endsWith('/events')) {
            final events = (jsonDecode(request.body)['events'] as List)
                .map((r) => Map<String, dynamic>.from(r))
                .toList();
            deliveries.addAll(events);
            stored.addAll(events.map((e) => e['id'] as String));
            if (loseFirstAck) {
              loseFirstAck = false;
              throw http.ClientException('reply lost');
            }
            return jsonResponse({
              'acknowledged': events.map((e) => e['id']).toList(),
            });
          }
          return jsonResponse({});
        }),
      );
      await client.init();
      final activity = client.beginActivity('quiz', 1, 'G1-C10');
      clock = clock.add(const Duration(seconds: 20));
      client.completeActivity(activity);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(client.pendingEvents, 2);
      final prefs = await SharedPreferences.getInstance();
      final queued = prefs.getString('ganit_monitor_queue')!;
      expect(queued, isNot(contains('answers')));
      expect(queued, isNot(contains('score')));
      expect(queued, isNot(contains('student')));
      online = true;
      await client.sync();
      expect(client.pendingEvents, 2);
      await client.sync();
      expect(client.pendingEvents, 0);
      expect(stored, hasLength(2));
      expect(deliveries, hasLength(4));
      expect(deliveries[0]['id'], deliveries[2]['id']);
      expect(deliveries[1]['durationSeconds'], 20);
      expect(deliveries.every((event) => !event.containsKey('_owner')), isTrue);
      client.dispose();
    },
  );

  test(
    'revocation locks learning and clears the offline authorization',
    () async {
      var revoked = false;
      final client = CentralClient(
        endpoint: 'http://localhost:8787',
        clock: () => clock,
        transport: MockClient((request) async {
          if (request.url.path == '/auth/refresh' ||
              request.url.path == '/login')
            return jsonResponse(authResponse());
          if (revoked) return jsonResponse({'code': 'device_revoked'}, 403);
          return jsonResponse({'classroom': 'Test classroom'});
        }),
      );
      await client.init();
      expect(client.canLearn, isTrue);
      revoked = true;
      await client.sync();
      expect(client.canLearn, isFalse);
      expect(client.locked, isTrue);
      expect(client.session, isNull);
      expect(
        (await SharedPreferences.getInstance()).getString(
          'ganit_offline_lease',
        ),
        isNull,
      );
      client.dispose();
    },
  );

  test(
    'access/password are memory-only and private offline PIN is salted, not universal',
    () async {
      final client = CentralClient(
        endpoint: 'http://localhost:8787',
        clock: () => clock,
        transport: MockClient(
          (request) async => request.url.path.endsWith('/heartbeat')
              ? jsonResponse({'classroom': 'Test classroom'})
              : jsonResponse(authResponse()),
        ),
      );
      await client.init();
      await client.setOfflinePin('765432');
      expect(await client.unlockTeacher('000000'), isFalse);
      client.connection = 'offline';
      expect(await client.unlockTeacher('765432'), isTrue);
      final prefs = await SharedPreferences.getInstance();
      final saved = jsonEncode({
        for (final key in prefs.getKeys()) key: prefs.get(key),
      });
      expect(saved, isNot(contains('memory-only-access-token')));
      expect(saved, isNot(contains('765432')));
      expect(saved, isNot(contains('password')));
      expect(saved, isNot(contains('refreshToken')));
      client.dispose();
    },
  );

  test(
    'viewer SSE snapshots update automatically and teacher cannot start a monitor',
    () async {
      final stream = FakeEventClient();
      final viewer = CentralClient(
        endpoint: 'http://localhost:8787',
        clock: () => clock,
        streamFactory: () => stream,
        transport: MockClient(
          (request) async => jsonResponse(authResponse('viewer')),
        ),
      );
      await viewer.init();
      expect(viewer.canMonitor, isTrue);
      expect(viewer.canAdminister, isFalse);
      expect(viewer.canLearn, isFalse);
      final values = <Map<String, dynamic>>[];
      final subscription = viewer.snapshots.listen(values.add);
      viewer.startMonitoring();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      stream.emit({
        'overview': {'onlineClassrooms': 1},
      });
      await Future<void>.delayed(const Duration(milliseconds: 10));
      stream.emit({
        'overview': {'onlineClassrooms': 0},
      });
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(values.map((v) => v['overview']['onlineClassrooms']), [1, 0]);
      expect(viewer.lastDashboardAt, isNotNull);
      await subscription.cancel();
      viewer.dispose();
    },
  );
  test(
    'offline sign-out cannot silently restore a cookie session on reload',
    () async {
      var online = true;
      var refreshCalls = 0;
      http.Client transport() => MockClient((request) async {
        if (!online) throw http.ClientException('offline');
        if (request.url.path == '/auth/refresh') {
          refreshCalls++;
          return jsonResponse(authResponse());
        }
        return jsonResponse({'ok': true});
      });
      final first = CentralClient(
        endpoint: 'http://localhost:8787',
        clock: () => clock,
        transport: transport(),
      );
      await first.init();
      online = false;
      await first.logout();
      expect(first.canLearn, isFalse);
      first.dispose();
      online = true;
      final second = CentralClient(
        endpoint: 'http://localhost:8787',
        clock: () => clock,
        transport: transport(),
      );
      await second.init();
      expect(refreshCalls, 1);
      expect(second.locked, isTrue);
      expect(second.canLearn, isFalse);
      expect(
        (await SharedPreferences.getInstance()).getBool('ganit_logout_pending'),
        isNull,
      );
      second.dispose();
    },
  );

  test(
    'central server error preserves a valid offline learning authorization',
    () async {
      var failed = false;
      final client = CentralClient(
        endpoint: 'http://localhost:8787',
        clock: () => clock,
        transport: MockClient((request) async {
          if (failed) return jsonResponse({'code': 'server_error'}, 500);
          return jsonResponse(authResponse());
        }),
      );
      await client.init();
      failed = true;
      await client.sync();
      expect(client.connection, 'offline');
      expect(client.canLearn, isTrue);
      expect(client.locked, isFalse);
      client.dispose();
    },
  );
}
