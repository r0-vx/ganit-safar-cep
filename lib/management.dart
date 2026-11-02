part of 'main.dart';

String get portalSurface {
  const configured = String.fromEnvironment('GANIT_SURFACE');
  if (configured == 'dashboard' || configured == 'classroom') return configured;
  if (kIsWeb && Uri.base.host == 'ganit-safar-dashboard.vercel.app')
    return 'dashboard';
  if (kIsWeb && Uri.base.host == 'ganit-safar-smartboard.vercel.app')
    return 'classroom';
  return 'auto';
}

final central = CentralClient(surface: portalSurface);

String centralError(Object error) {
  final code = error is CentralFailure ? error.code : central.error;
  return switch (code) {
    'service_not_configured' => tr(
      'Hosted database setup is pending. No sample data is shown in live mode.',
      'मध्यवर्ती डेटाबेसची जोडणी अद्याप पूर्ण नाही. प्रत्यक्ष मोडमध्ये नमुना माहिती दाखवली जात नाही.',
    ),
    'wrong_portal' => tr(
      'Use the other sign-in page for this account.',
      'या खात्यासाठी दुसरे प्रवेश पान वापरा.',
    ),
    'invalid_request' => tr(
      'Check the required names and selected class.',
      'आवश्यक नावे आणि निवडलेली इयत्ता तपासा.',
    ),
    'invalid_credentials' => tr(
      'Check the sign-in details or account status.',
      'प्रवेशाची माहिती किंवा खात्याची स्थिती तपासा.',
    ),
    'rate_limited' => tr(
      'Too many attempts. Wait five minutes.',
      'अनेक प्रयत्न झाले. पाच मिनिटे थांबा.',
    ),
    'password_change_required' => tr(
      'Change the initial password to continue.',
      'पुढे जाण्यासाठी सुरुवातीचा संकेतशब्द बदला.',
    ),
    'weak_password' => tr(
      'Use a different password with at least 12 characters.',
      'किमान १२ अक्षरांचा वेगळा संकेतशब्द वापरा.',
    ),
    'device_revoked' || 'device_disabled' || 'device_identity_rejected' => tr(
      'This board is locked. Contact your administrator.',
      'हा फळा बंद आहे. प्रशासकाशी संपर्क करा.',
    ),
    'unassigned_classroom' => tr(
      'No active classroom assignment is available. Contact your administrator.',
      'सक्रिय वर्गाची नेमणूक उपलब्ध नाही. प्रशासकाशी संपर्क करा.',
    ),
    'unsupported_version' => tr(
      'This app version is no longer supported. Contact your administrator.',
      'अॅपची ही आवृत्ती समर्थित नाही. प्रशासकाशी संपर्क करा.',
    ),
    'invalid_reset' => tr(
      'The reset token is expired or already used.',
      'पुनर्स्थापनेचा टोकन कालबाह्य झाला किंवा वापरला आहे.',
    ),
    'forbidden' => tr(
      'Your account does not have permission for this action.',
      'या कृतीसाठी तुमच्या खात्याला परवानगी नाही.',
    ),
    'conflict' || 'already_assigned' => tr(
      'This record already exists or is assigned elsewhere.',
      'ही नोंद आधीच आहे किंवा दुसरीकडे नेमली आहे.',
    ),
    'https_required' || 'identity_key_changed' || 'invalid_offline_lease' => tr(
      'The secure connection could not be verified. Contact your administrator.',
      'सुरक्षित जोडणीची पडताळणी झाली नाही. प्रशासकाशी संपर्क करा.',
    ),
    'signed_out' => tr(
      'Signed out. Sign in when you are ready.',
      'प्रवेश बंद केला. तयार झाल्यावर पुन्हा प्रवेश करा.',
    ),
    'session_expired' ||
    'reauth_required' ||
    'account_disabled' ||
    'refresh_reuse' ||
    'offline_lease_expired' => tr(
      'Sign in again. An administrator may have changed access.',
      'पुन्हा प्रवेश करा. प्रशासकाने प्रवेश बदलला असू शकतो.',
    ),
    'invalid_pin' => tr(
      'Choose a private teaching PIN with 6–12 digits.',
      '६ ते १२ अंकांचा खासगी शिक्षक पिन निवडा.',
    ),
    _ => tr(
      'The service is unavailable or the request could not be completed. Learning can continue with a valid offline authorization.',
      'सेवा उपलब्ध नाही किंवा कृती पूर्ण झाली नाही. वैध ऑफलाइन परवानगी असल्यास अभ्यास सुरू राहतो.',
    ),
  };
}

String roleLabel(String role) => switch (role) {
  'super_admin' || 'admin' => tr('Super administrator', 'मुख्य प्रशासक'),
  'school_admin' => tr('School administrator', 'शाळा प्रशासक'),
  'teacher' => tr('Teacher', 'शिक्षक'),
  _ => tr('Viewer', 'निरीक्षक'),
};
String deviceStatusLabel(String status) => switch (status) {
  'online' || 'active' => tr('Online', 'ऑनलाइन'),
  'offline' => tr('Offline', 'ऑफलाइन'),
  'never_connected' => tr('Never connected', 'अद्याप जोडले नाही'),
  'disabled' => tr('Disabled', 'बंद'),
  _ => tr('Needs attention', 'लक्ष देणे आवश्यक'),
};
String modeLabel(String mode) => switch (mode) {
  'learn' => tr('Learn', 'शिका'),
  'practice' => tr('Practice', 'सराव'),
  'quiz' => tr('Quiz', 'प्रश्नमंजुषा'),
  _ => tr('Idle', 'सध्या कृती नाही'),
};
String monitorCode(String code) => switch (code) {
  'classroom_offline' => tr(
    'Classroom offline beyond the alert threshold',
    'वर्गाची जोडणी ठरलेल्या वेळेपेक्षा जास्त बंद',
  ),
  'repeated_login_failures' => tr(
    'Repeated sign-in failures',
    'प्रवेशाचे वारंवार अयशस्वी प्रयत्न',
  ),
  'device_revoked' => tr('Device revoked', 'साधनाचा प्रवेश रद्द'),
  'outdated_version' || 'unsupported_version' => tr(
    'App version needs an update',
    'अॅपची आवृत्ती अद्ययावत करणे आवश्यक',
  ),
  'repeated_app_errors' => tr(
    'Repeated application errors',
    'अॅपमध्ये वारंवार त्रुटी',
  ),
  'unhealthy_heartbeat' => tr(
    'Unhealthy heartbeat',
    'साधनाच्या स्थितीत समस्या',
  ),
  'unassigned_device' => tr(
    'Device has no valid classroom assignment',
    'साधनाला वैध वर्ग नेमलेला नाही',
  ),
  'unknown_device' => tr(
    'Unknown device or invalid identity proof',
    'अनोळखी साधन किंवा ओळखीचा पुरावा अवैध',
  ),
  'teacher_disabled' => tr('Teacher account disabled', 'शिक्षक खाते बंद'),
  'suspicious_session' => tr(
    'Suspicious session activity',
    'सत्रात संशयास्पद कृती',
  ),
  'render_error' || 'unhandled_error' => tr(
    'Application display/runtime error',
    'अॅपच्या दृश्यात किंवा कार्यात त्रुटी',
  ),
  'sync_failed' => tr('Synchronization error', 'समक्रमणात त्रुटी'),
  'queue_overflow' => tr(
    'Local event queue reached its limit',
    'स्थानिक कृती रांग पूर्ण झाली',
  ),
  'storage_error' => tr('Local storage error', 'स्थानिक साठवणीत त्रुटी'),
  _ => tr('Recorded system activity', 'नोंदवलेली प्रणाली कृती'),
};
String monitorTime(dynamic value) => value is num
    ? DateTime.fromMillisecondsSinceEpoch(
        (value * 1000).round(),
      ).toLocal().toString().split('.').first
    : tr('Never', 'अद्याप नाही');
String chapterLabel(String id) {
  final match = schoolChapters.where((chapter) => chapter.id == id).firstOrNull;
  if (match != null)
    return '${tr('Class', 'इयत्ता')} ${match.grade} • ${match.number}. ${match.title.inLanguage(store.language)}';
  final topic = topics.where((topic) => topic.id == id).firstOrNull;
  return topic?.name.inLanguage(store.language) ?? (id.isEmpty ? '—' : id);
}

class ConnectionGate extends StatefulWidget {
  const ConnectionGate({super.key});
  @override
  State<ConnectionGate> createState() => _ConnectionGateState();
}

class _ConnectionGateState extends State<ConnectionGate> {
  bool local = false, ready = false;
  @override
  void initState() {
    super.initState();
    central.init().then((_) {
      if (mounted) setState(() => ready = true);
    });
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([central, store]),
    builder: (context, _) {
      if (!ready)
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      if (!central.managed)
        return local
            ? const Shell()
            : CentralLogin(onContinue: () => setState(() => local = true));
      if (central.mustChangePassword && central.session != null)
        return CentralPasswordPage(firstLogin: true);
      if (central.canMonitor) return ManagementPage();
      if (central.offlineAuthorized &&
          !central.hasOfflinePin &&
          !central.isClassroomAdministrator &&
          central.connection == 'connected')
        return ClassroomConnectionPage();
      if (central.canLearn) return const Shell();
      if (central.canUseClassroom && !central.locked)
        return ClassroomEnrollmentPage();
      return CentralLogin(onContinue: () => setState(() {}));
    },
  );
}

class CentralLogin extends StatefulWidget {
  final VoidCallback onContinue;
  final bool? dashboard;
  const CentralLogin({super.key, required this.onContinue, this.dashboard});
  @override
  State<CentralLogin> createState() => _CentralLoginState();
}

class _CentralLoginState extends State<CentralLogin> {
  final email = TextEditingController(), password = TextEditingController();
  bool busy = false;
  String error = '';
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> login() async {
    setState(() {
      busy = true;
      error = '';
    });
    try {
      await central.login(email.text.trim(), password.text);
      if (mounted) {
        password.clear();
        appNavigator.currentState?.popUntil((route) => route.isFirst);
        widget.onContinue();
      }
    } catch (exception) {
      if (mounted) setState(() => error = centralError(exception));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  bool get dashboard => widget.dashboard ?? portalSurface == 'dashboard';

  @override
  Widget build(BuildContext context) => PortalSignInView(
    dashboard: dashboard,
    email: email,
    password: password,
    busy: busy,
    error: error.isNotEmpty
        ? error
        : central.locked &&
              !const {
                'reauth_required',
                'session_expired',
                'signed_out',
              }.contains(central.error)
        ? centralError(CentralFailure(central.error, 401))
        : '',
    onSignIn: login,
    onContinueOffline: widget.onContinue,
  );
}

class CentralLanguageSelector extends StatelessWidget {
  const CentralLanguageSelector({super.key});
  @override
  Widget build(BuildContext context) => DropdownButton<int>(
    isExpanded: true,
    itemHeight: store.smartboard ? 72 : 56,
    value: store.language,
    items: const [
      DropdownMenuItem(value: 0, child: Text('English')),
      DropdownMenuItem(value: 1, child: Text('मराठी')),
      DropdownMenuItem(value: 2, child: Text('English + मराठी')),
    ],
    onChanged: (value) {
      if (value != null) {
        store.language = value;
        store.save();
      }
    },
  );
}

class CentralPasswordPage extends StatefulWidget {
  final bool firstLogin;
  const CentralPasswordPage({super.key, this.firstLogin = false});
  @override
  State<CentralPasswordPage> createState() => _CentralPasswordState();
}

class _CentralPasswordState extends State<CentralPasswordPage> {
  final old = TextEditingController(),
      next = TextEditingController(),
      repeat = TextEditingController();
  String error = '';
  bool busy = false;
  @override
  void dispose() {
    old.dispose();
    next.dispose();
    repeat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(tr('Change account password', 'खात्याचा संकेतशब्द बदला')),
    ),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.firstLogin
                      ? tr(
                          'Choose your own password before using this account.',
                          'हे खाते वापरण्यापूर्वी स्वतःचा संकेतशब्द निवडा.',
                        )
                      : tr(
                          'Use a different password of at least 12 characters.',
                          'किमान १२ अक्षरांचा वेगळा संकेतशब्द वापरा.',
                        ),
                ),
                for (final field in [
                  (old, 'Current password', 'सध्याचा संकेतशब्द'),
                  (next, 'New password', 'नवीन संकेतशब्द'),
                  (repeat, 'Repeat new password', 'नवीन संकेतशब्द पुन्हा'),
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: TextField(
                      controller: field.$1,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: tr(field.$2, field.$3),
                      ),
                    ),
                  ),
                if (error.isNotEmpty) Text(error),
                FilledButton(
                  onPressed: busy
                      ? null
                      : () async {
                          if (next.text.length < 12 ||
                              next.text != repeat.text) {
                            setState(
                              () => error = tr(
                                'Use at least 12 characters and matching new passwords.',
                                'किमान १२ अक्षरे वापरा आणि दोन्ही नवीन संकेतशब्द जुळवा.',
                              ),
                            );
                            return;
                          }
                          setState(() {
                            busy = true;
                            error = '';
                          });
                          try {
                            await central.changePassword(old.text, next.text);
                            old.clear();
                            next.clear();
                            repeat.clear();
                            if (mounted && !widget.firstLogin)
                              Navigator.pop(context);
                          } catch (exception) {
                            if (mounted)
                              setState(() => error = centralError(exception));
                          } finally {
                            if (mounted) setState(() => busy = false);
                          }
                        },
                  child: Text(tr('Save password', 'संकेतशब्द जतन करा')),
                ),
                TextButton(
                  onPressed: central.logout,
                  child: Text(tr('Sign out', 'बाहेर पडा')),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class CentralResetPage extends StatefulWidget {
  const CentralResetPage({super.key});
  @override
  State<CentralResetPage> createState() => _CentralResetState();
}

class _CentralResetState extends State<CentralResetPage> {
  final token = TextEditingController(), password = TextEditingController();
  String feedback = '';
  bool busy = false;
  @override
  void dispose() {
    token.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(tr('Reset password', 'संकेतशब्द पुनर्स्थापित करा')),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  tr(
                    'Ask your administrator for a single-use reset token. It expires after 30 minutes.',
                    'प्रशासकाकडून एकदाच वापरता येणारा टोकन घ्या. तो ३० मिनिटांनी कालबाह्य होतो.',
                  ),
                ),
                TextField(
                  controller: token,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: tr('Reset token', 'पुनर्स्थापना टोकन'),
                  ),
                ),
                TextField(
                  controller: password,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: tr(
                      'New password (12+ characters)',
                      'नवीन संकेतशब्द (किमान १२ अक्षरे)',
                    ),
                  ),
                ),
                if (feedback.isNotEmpty) Text(feedback),
                FilledButton(
                  onPressed: busy
                      ? null
                      : () async {
                          setState(() => busy = true);
                          try {
                            await central
                                .request('POST', '/auth/reset-password', {
                                  'resetToken': token.text.trim(),
                                  'newPassword': password.text,
                                });
                            token.clear();
                            password.clear();
                            if (mounted)
                              setState(
                                () => feedback = tr(
                                  'Password changed. Return to sign in.',
                                  'संकेतशब्द बदलला. प्रवेशासाठी परत जा.',
                                ),
                              );
                          } catch (exception) {
                            if (mounted)
                              setState(
                                () => feedback = centralError(exception),
                              );
                          } finally {
                            if (mounted) setState(() => busy = false);
                          }
                        },
                  child: Text(
                    tr('Reset password', 'संकेतशब्द पुनर्स्थापित करा'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class ClassroomEnrollmentPage extends StatefulWidget {
  const ClassroomEnrollmentPage({super.key});
  @override
  State<ClassroomEnrollmentPage> createState() => _EnrollmentState();
}

class _EnrollmentState extends State<ClassroomEnrollmentPage> {
  String? classroomId;
  final name = TextEditingController();
  String error = '';
  bool busy = false;
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(tr('Assign this whiteboard', 'हा फळा वर्गाला जोडा')),
      actions: [
        TextButton(
          onPressed: central.logout,
          child: Text(tr('Sign out', 'बाहेर पडा')),
        ),
      ],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CentralLanguageSelector(),
                Text(
                  '${tr('Device ID', 'साधन क्रमांक')}: ${central.installation}',
                ),
                Text(
                  tr(
                    'Select only a classroom assigned by your administrator. No student accounts are needed.',
                    'प्रशासकाने नेमलेला वर्ग निवडा. विद्यार्थ्यांची खाती आवश्यक नाहीत.',
                  ),
                ),
                if (kIsWeb)
                  TextButton.icon(
                    onPressed: () => browserPortal(true, false),
                    icon: const Icon(Icons.dashboard_outlined),
                    label: Text(
                      tr('Open monitoring dashboard', 'निरीक्षण फलक उघडा'),
                    ),
                  ),
                if (central.classrooms.isEmpty)
                  Text(
                    tr(
                      central.isClassroomAdministrator
                          ? 'Create your school and classroom in the monitoring dashboard, then connect this board.'
                          : 'No active classroom is assigned. Contact your administrator.',
                      central.isClassroomAdministrator
                          ? 'निरीक्षण फलकावर शाळा व वर्ग तयार करा, नंतर हा फळा जोडा.'
                          : 'सक्रिय वर्ग नेमलेला नाही. प्रशासकाशी संपर्क करा.',
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    initialValue: classroomId,
                    isExpanded: true,
                    itemHeight: 88,
                    decoration: InputDecoration(
                      labelText: tr('Assigned classroom', 'नेमलेला वर्ग'),
                    ),
                    items: [
                      for (final room in central.classrooms)
                        DropdownMenuItem(
                          value: room['id'] as String,
                          child: Text(
                            '${room['school_name']} • ${room['name']}',
                            maxLines: 2,
                          ),
                        ),
                    ],
                    onChanged: (value) => setState(() => classroomId = value),
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: name,
                  decoration: InputDecoration(
                    labelText: tr('Whiteboard name', 'फळ्याचे नाव'),
                  ),
                ),
                if (error.isNotEmpty) Text(error),
                FilledButton(
                  onPressed:
                      busy || classroomId == null || central.classrooms.isEmpty
                      ? null
                      : () async {
                          setState(() {
                            busy = true;
                            error = '';
                          });
                          try {
                            await central.enroll(
                              classroomId!,
                              name.text.trim(),
                            );
                          } catch (exception) {
                            if (mounted)
                              setState(() => error = centralError(exception));
                          } finally {
                            if (mounted) setState(() => busy = false);
                          }
                        },
                  child: Text(
                    tr('Register and open learning', 'नोंदणी करून अभ्यास उघडा'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class ClassroomConnectionPage extends StatefulWidget {
  const ClassroomConnectionPage({super.key});
  @override
  State<ClassroomConnectionPage> createState() => _ClassroomConnectionState();
}

class _ClassroomConnectionState extends State<ClassroomConnectionPage> {
  final pin = TextEditingController(), repeat = TextEditingController();
  String feedback = '';
  bool busy = false;
  @override
  void dispose() {
    pin.dispose();
    repeat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr('Classroom connection', 'वर्ग जोडणी'))),
    body: ListenableBuilder(
      listenable: Listenable.merge([central, store]),
      builder: (context, _) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${central.schoolName} • ${central.classroomName}',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Text('${tr('Device ID', 'साधन क्रमांक')}: ${central.installation}'),
            Text(
              '${tr('Connection', 'जोडणी')}: ${central.connection == 'connected' ? tr('Connected', 'जोडलेले') : tr('Offline / disconnected', 'ऑफलाइन / जोडणी नाही')}',
            ),
            Text(
              '${tr('Queued anonymous events', 'रांगेतील अनामिक कृती')}: ${central.pendingEvents}',
            ),
            Text(
              '${tr('Last sync', 'शेवटची समक्रमण वेळ')}: ${central.lastSync.isEmpty ? '—' : central.lastSync}',
            ),
            if (central.droppedEvents > 0)
              Text(
                tr(
                  'Some old monitoring events exceeded the local queue limit. Learning results were not uploaded.',
                  'स्थानिक रांगेची मर्यादा भरल्याने काही जुन्या निरीक्षण कृती वगळल्या. विद्यार्थ्यांचे निकाल पाठवले नाहीत.',
                ),
              ),
            if (central.offlineAuthorized)
              Text(
                '${tr('Offline authorization until', 'ऑफलाइन परवानगीची अंतिम वेळ')}: ${monitorTime(central.lease!['expiresAt'])}',
              ),
            const SizedBox(height: 20),
            Text(
              tr('Private teaching PIN', 'खासगी शिक्षक पिन'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              tr(
                'Choose 6–12 digits for local Teacher Mode while disconnected. This does not grant administrator access.',
                'जोडणी नसताना शिक्षक मोडसाठी ६ ते १२ अंक निवडा. यामुळे प्रशासकीय प्रवेश मिळत नाही.',
              ),
            ),
            TextField(
              controller: pin,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: tr('New private PIN', 'नवीन खासगी पिन'),
              ),
            ),
            TextField(
              controller: repeat,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: tr('Repeat PIN', 'पिन पुन्हा'),
              ),
            ),
            if (feedback.isNotEmpty) Text(feedback),
            FilledButton(
              onPressed: busy || central.connection != 'connected'
                  ? null
                  : () async {
                      if (pin.text != repeat.text) {
                        setState(
                          () => feedback = tr(
                            'The PINs must match.',
                            'दोन्ही पिन जुळले पाहिजेत.',
                          ),
                        );
                        return;
                      }
                      setState(() => busy = true);
                      try {
                        await central.setOfflinePin(pin.text);
                        pin.clear();
                        repeat.clear();
                        if (mounted)
                          setState(
                            () => feedback = tr(
                              'Private teaching PIN saved.',
                              'खासगी शिक्षक पिन जतन केला.',
                            ),
                          );
                      } catch (exception) {
                        if (mounted)
                          setState(() => feedback = centralError(exception));
                      } finally {
                        if (mounted) setState(() => busy = false);
                      }
                    },
              child: Text(tr('Save private PIN', 'खासगी पिन जतन करा')),
            ),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton(
                  onPressed: central.sync,
                  child: Text(
                    tr('Reconnect and synchronize', 'पुन्हा जोडून समक्रमण करा'),
                  ),
                ),
                OutlinedButton(
                  onPressed: central.connection == 'connected'
                      ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CentralPasswordPage(),
                          ),
                        )
                      : null,
                  child: Text(
                    tr('Change account password', 'खात्याचा संकेतशब्द बदला'),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await central.logout();
                    if (mounted)
                      appNavigator.currentState?.popUntil(
                        (route) => route.isFirst,
                      );
                  },
                  child: Text(tr('Sign out', 'बाहेर पडा')),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class ClassroomConnectionStrip extends StatelessWidget {
  const ClassroomConnectionStrip({super.key});
  @override
  Widget build(BuildContext context) => !central.managed
      ? const SizedBox.shrink()
      : ListenableBuilder(
          listenable: Listenable.merge([central, store]),
          builder: (context, _) => Container(
            color: central.connection == 'connected'
                ? const Color(0xFFE0F2FE)
                : const Color(0xFFFEF3C7),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                Text(
                  central.classroomName.isEmpty
                      ? tr(
                          'No classroom linked • Learning available',
                          'वर्ग जोडलेला नाही • अभ्यास उपलब्ध',
                        )
                      : '${central.schoolName} • ${central.classroomName}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  central.connection == 'connected'
                      ? tr('Connected', 'जोडलेले')
                      : tr(
                          'Disconnected • learning continues',
                          'जोडणी नाही • अभ्यास सुरू आहे',
                        ),
                ),
              ],
            ),
          ),
        );
}

class ManagementPage extends StatefulWidget {
  final CentralClient? client;
  const ManagementPage({super.key, this.client});
  @override
  State<ManagementPage> createState() => _ManagementPageState();
}

class _ManagementPageState extends State<ManagementPage> {
  CentralClient get monitor => widget.client ?? central;
  Map<String, dynamic>? data;
  String page = 'overview', error = '';
  final _dashboardScroll = ScrollController();
  final _search = TextEditingController();
  final _detailAnchor = GlobalKey();
  String _query = '';
  String? _selectedEntity, _schoolFilter;
  bool? _tableChoice;
  bool _sortAscending = true, _navOpen = true;
  bool busy = false;
  Timer? _freshnessTicker;
  bool _lastLive = false;
  bool get _live =>
      monitor.connection == 'connected' &&
      monitor.lastDashboardAt != null &&
      monitor.now().difference(monitor.lastDashboardAt!).inSeconds <= 15;
  StreamSubscription<Map<String, dynamic>>? subscription;
  @override
  void initState() {
    super.initState();
    _freshnessTicker = Timer.periodic(const Duration(seconds: 5), (_) {
      final fresh = _live;
      if (mounted && fresh != _lastLive) setState(() => _lastLive = fresh);
    });
    subscription = monitor.snapshots.listen((value) {
      if (value['dataMode'] != null &&
          value['dataMode'] != (monitor.presentation ? 'presentation' : 'live'))
        return;
      if (mounted)
        setState(() {
          data = value;
          _lastLive = _live;
          error = '';
        });
    });
    if (monitor.canMonitor) {
      monitor.startMonitoring();
      load();
    }
  }

  @override
  void dispose() {
    subscription?.cancel();
    _freshnessTicker?.cancel();
    _dashboardScroll.dispose();
    _search.dispose();
    monitor.stopMonitoring();
    super.dispose();
  }

  Future<void> load() async {
    if (!monitor.canMonitor) return;
    final preview = monitor.presentation;
    try {
      final value = await monitor.request('GET', '/dashboard');
      if (mounted && preview == monitor.presentation)
        setState(() {
          data = value;
          error = '';
        });
    } catch (exception) {
      if (mounted) setState(() => error = centralError(exception));
    }
  }

  Future<Map<String, dynamic>?> action(
    String method,
    String path,
    Map<String, dynamic> body,
  ) async {
    setState(() {
      busy = true;
      error = '';
    });
    try {
      if (monitor.presentation) throw const CentralFailure('forbidden', 403);
      final result = await monitor.request(method, path, body);
      await load();
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('Saved successfully.', 'नोंद जतन केली.'))),
        );
      return result;
    } catch (exception) {
      if (mounted) setState(() => error = centralError(exception));
      return null;
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  List<Map<String, dynamic>> rows(String key) => (data?[key] as List? ?? [])
      .map((value) => Map<String, dynamic>.from(value))
      .toList();
  Map<String, dynamic> get analytics =>
      Map<String, dynamic>.from(data?['analytics'] ?? {});
  String nameOf(String type, dynamic id) =>
      rows(
        type,
      ).where((row) => row['id'] == id).firstOrNull?['name']?.toString() ??
      id?.toString() ??
      '—';

  Future<Map<String, String>?> form(
    String title,
    List<(String, String, String)> fields, {
    Map<String, String> values = const {},
    Set<String> secrets = const {},
  }) async {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (_) => ManagementRecordDialog(
        title: title,
        fields: fields,
        values: values,
        secrets: secrets,
      ),
    );
  }

  Future<List<String>?> choose(
    String title,
    List<Map<String, dynamic>> choices,
    List<String> initial, {
    bool single = false,
  }) async {
    var selected = Set<String>.from(initial);
    return showDialog<List<String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 620,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final item in choices)
                    CheckboxListTile(
                      value: selected.contains(item['id']),
                      title: Text(item['name'].toString()),
                      subtitle: item['school_name'] == null
                          ? null
                          : Text(item['school_name'].toString()),
                      onChanged: (value) => set(() {
                        if (single) selected = {};
                        if (value == true)
                          selected.add(item['id'].toString());
                        else
                          selected.remove(item['id']);
                      }),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr('Cancel', 'रद्द करा')),
            ),
            FilledButton(
              onPressed: single && selected.isEmpty
                  ? null
                  : () => Navigator.pop(ctx, selected.toList()),
              child: Text(tr('Confirm selection', 'निवड निश्चित करा')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> schoolForm([Map<String, dynamic>? school]) async {
    final value = await form(
      tr('School details', 'शाळेची माहिती'),
      [
        ('name', 'School name', 'शाळेचे नाव'),
        ('location', 'Location / district', 'ठिकाण / जिल्हा'),
        ('code', 'School code (optional)', 'शाळेचा संकेतांक (ऐच्छिक)'),
        ('admin_contact', 'Administrator contact', 'प्रशासकाचा संपर्क'),
      ],
      values: {
        for (final key in ['name', 'location', 'code', 'admin_contact'])
          key: school?[key]?.toString() ?? '',
      },
    );
    if (value == null) return;
    final result = await action(
      school == null ? 'POST' : 'PATCH',
      school == null ? '/schools' : '/schools/${school['id']}',
      value,
    );
    if (result != null && mounted) {
      _navigate('schools', entity: (result['id'] ?? school?['id']).toString());
      _revealEntity();
    }
  }

  Future<void> classroomForm({
    Map<String, dynamic>? room,
    String? schoolId,
  }) async {
    var selectedSchool =
        schoolId ?? room?['school_id']?.toString() ?? _schoolFilter;
    if (selectedSchool == null) {
      final schools = rows(
        'schools',
      ).where((s) => s['status'] == 'active').toList();
      if (schools.isEmpty) {
        _navigate('schools');
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                tr(
                  'Add an active school before creating a classroom.',
                  'वर्ग तयार करण्यापूर्वी सक्रिय शाळा जोडा.',
                ),
              ),
            ),
          );
        return;
      }
      final chosen = await choose(
        tr('Select school', 'शाळा निवडा'),
        schools,
        [],
        single: true,
      );
      if (chosen == null || chosen.isEmpty || !mounted) return;
      selectedSchool = chosen.single;
    }
    final value = await form(
      tr('Classroom details', 'वर्गाची माहिती'),
      [
        ('name', 'Classroom name', 'वर्गाचे नाव'),
        ('grade', 'Grade (1–4)', 'इयत्ता (१–४)'),
        ('section', 'Section', 'तुकडी'),
      ],
      values: {
        'name': room?['name']?.toString() ?? '',
        'grade': room?['grade']?.toString() ?? '1',
        'section': room?['section']?.toString() ?? '',
      },
    );
    if (value == null) return;
    final result = await action(
      room == null ? 'POST' : 'PATCH',
      room == null ? '/classrooms' : '/classrooms/${room['id']}',
      {
        ...value,
        'school_id': selectedSchool,
        'grade': int.parse(value['grade']!),
      },
    );
    if (result != null && mounted) {
      _openSchoolClassrooms(
        selectedSchool,
        entity: (result['id'] ?? room?['id']).toString(),
      );
    }
  }

  void _openSchoolClassrooms(String schoolId, {String? entity}) {
    _navigate('classrooms', entity: entity);
    setState(() => _schoolFilter = schoolId);
    if (entity != null) _revealEntity();
  }

  Future<void> userForm() async {
    final schoolIds = await choose(
      tr('Assigned schools', 'नेमलेल्या शाळा'),
      rows('schools'),
      [],
    );
    if (schoolIds == null || !mounted) return;
    final role = monitor.isSuperAdmin
        ? await choose(
            tr('Account role', 'खात्याची भूमिका'),
            [
              for (final id in [
                'teacher',
                'school_admin',
                'viewer',
                'super_admin',
              ])
                {'id': id, 'name': roleLabel(id)},
            ],
            ['teacher'],
            single: true,
          )
        : ['teacher'];
    if (role == null || role.length != 1 || !mounted) return;
    final value = await form(
      tr(
        'Create account • temporary password',
        'खाते तयार करा • तात्पुरता संकेतशब्द',
      ),
      [
        ('name', 'Teacher / account name', 'शिक्षकाचे / खात्याचे नाव'),
        ('email', 'Email', 'ईमेल'),
        (
          'password',
          'Temporary password (12+ characters)',
          'तात्पुरता संकेतशब्द (किमान १२ अक्षरे)',
        ),
      ],
      secrets: {'password'},
    );
    if (value != null)
      await action('POST', '/users', {
        ...value,
        'role': role.first,
        'school_ids': schoolIds,
      });
  }

  Future<void> resetUser(Map<String, dynamic> user) async {
    setState(() => busy = true);
    try {
      final value = await monitor.request(
        'POST',
        '/users/${user['id']}/password-reset',
        {},
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            tr('Single-use reset token', 'एकदाच वापरण्याचा पुनर्स्थापना टोकन'),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr(
                    'Share privately with the account holder. This token expires in 30 minutes and will not be shown again.',
                    'खातेदाराला खासगीपणे द्या. हा टोकन ३० मिनिटांत कालबाह्य होतो आणि पुन्हा दिसणार नाही.',
                  ),
                ),
                SelectableText(value['resetToken']),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Clipboard.setData(ClipboardData(text: value['resetToken'])),
              child: Text(tr('Copy token', 'टोकन प्रत करा')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr('Close', 'बंद करा')),
            ),
          ],
        ),
      );
    } catch (exception) {
      if (mounted) setState(() => error = centralError(exception));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> registerBoard() async {
    final selected = await choose(
      tr('Select classroom', 'वर्ग निवडा'),
      rows('classrooms'),
      [],
      single: true,
    );
    if (selected == null || selected.length != 1 || !mounted) return;
    final value = await form(
      tr('Register this browser / board', 'या ब्राउझरची / फळ्याची नोंदणी'),
      [('name', 'Device name', 'साधनाचे नाव')],
    );
    if (value == null) return;
    try {
      await monitor.enroll(selected.first, value['name'] ?? '');
      await load();
    } catch (exception) {
      if (mounted) setState(() => error = centralError(exception));
    }
  }

  List<(String, String, String, IconData)> get _pages => [
    ('overview', 'Overview', 'आढावा', Icons.space_dashboard_outlined),
    ('schools', 'Schools', 'शाळा', Icons.school_outlined),
    ('classrooms', 'Classrooms', 'वर्ग', Icons.meeting_room_outlined),
    if (monitor.canAdminister)
      (
        'users',
        'Teacher accounts',
        'शिक्षक खाती',
        Icons.people_outline_rounded,
      ),
    ('devices', 'Devices', 'साधने', Icons.cast_connected_outlined),
    ('analytics', 'Usage analytics', 'वापर विश्लेषण', Icons.insights_rounded),
    ('alerts', 'Alerts', 'सूचना', Icons.notifications_none_rounded),
    ('versions', 'App versions', 'अॅप आवृत्त्या', Icons.layers_outlined),
    if (monitor.canAdminister)
      ('audit', 'Audit log', 'कृती नोंद', Icons.history_rounded),
  ];

  void _navigate(String destination, {String? entity}) {
    setState(() {
      page = destination;
      if (destination == 'classrooms' && entity != null)
        _schoolFilter = rows(
          'classrooms',
        ).where((r) => r['id'] == entity).firstOrNull?['school_id']?.toString();
      _selectedEntity = entity;
      _search.clear();
      _query = '';
    });
    if (_dashboardScroll.hasClients) _dashboardScroll.jumpTo(0);
    if (entity != null) _revealEntity();
  }

  void _revealEntity() => WidgetsBinding.instance.addPostFrameCallback((_) {
    final target = _detailAnchor.currentContext;
    if (mounted && target != null)
      Scrollable.ensureVisible(
        target,
        duration: _dashDuration(context),
        alignment: .08,
      );
  });
  void _selectEntity(String id) {
    setState(() => _selectedEntity = _selectedEntity == id ? null : id);
    if (_selectedEntity != null) _revealEntity();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    return Theme(
      data: base.copyWith(
        scaffoldBackgroundColor: store.contrast ? Colors.white : cream,
        textTheme: base.textTheme.copyWith(
          bodyMedium: base.textTheme.bodyMedium?.copyWith(
            fontSize: 15,
            color: ink,
          ),
          bodyLarge: base.textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            color: ink,
          ),
        ),
        dividerColor: _dashLine,
      ),
      child: Scaffold(
        body: SafeArea(
          child: ListenableBuilder(
            listenable: Listenable.merge([monitor, store]),
            builder: (context, _) {
              if (!monitor.canMonitor)
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      monitor.session == null
                          ? tr(
                              'Signed out. Management data is locked.',
                              'प्रवेश बंद. व्यवस्थापन माहिती सुरक्षित आहे.',
                            )
                          : tr(
                              'Your role cannot access administration.',
                              'तुमच्या भूमिकेला प्रशासकीय प्रवेश नाही.',
                            ),
                    ),
                  ),
                );
              return LayoutBuilder(
                builder: (context, constraints) {
                  final wide =
                      constraints.maxWidth /
                          MediaQuery.textScalerOf(context).scale(1) >=
                      1180;
                  final content = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _quizToolbar(wide),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _dashboardScroll,
                          padding: EdgeInsets.all(
                            constraints.maxWidth < 600 ? 16 : 28,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1520),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _dashboardHeader(wide),
                                  const SizedBox(height: 24),
                                  if (monitor.presentation) ...[
                                    DashboardPanel(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        tr(
                                          'ADMIN DEMO PREVIEW • Read-only sample data, separate from your schools. Switch demo data off to create or edit records.',
                                          'प्रशासकासाठी नमुना पूर्वदृश्य • फक्त पाहण्यासाठी नमुना माहिती; तुमच्या शाळांपासून वेगळी. नोंदी तयार किंवा बदलण्यासाठी नमुना माहिती बंद करा.',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                  if (!_live && data != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 20,
                                      ),
                                      child: DashboardPanel(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              Icons.cloud_off_outlined,
                                              color: _dashAmber,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                tr(
                                                  'Live updates paused. These charts show the last received data, not the current classroom state.',
                                                  'थेट माहिती थांबली आहे. आलेख शेवटच्या मिळालेल्या माहितीनुसार आहेत; वर्गांची आत्ताची स्थिती नाही.',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (error.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      child: Text(
                                        error,
                                        style: const TextStyle(
                                          color: _dashAmber,
                                        ),
                                      ),
                                    ),
                                  if (data == null)
                                    DashboardPanel(
                                      child: Padding(
                                        padding: const EdgeInsets.all(28),
                                        child: Column(
                                          children: [
                                            const CircularProgressIndicator(),
                                            const SizedBox(height: 20),
                                            Text(
                                              tr(
                                                'Waiting for authenticated backend data…',
                                                'प्रमाणित सेवेकडील माहितीची वाट पाहत आहे…',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  else
                                    ..._pageBody(),
                                  const SizedBox(height: 28),
                                  Text(
                                    tr(
                                      'Classroom activity, not student tracking. Individual answers and quiz scores stay on the classroom device.',
                                      'वर्गातील कृतींची माहिती; विद्यार्थ्यांचे वैयक्तिक निरीक्षण नाही. वैयक्तिक उत्तरे व प्रश्नमंजुषेचे गुण वर्गाच्या साधनावरच राहतात.',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: _dashMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (wide && _navOpen) _dashboardSidebar(),
                      Expanded(child: content),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _dashboardMenu(bool wide) async {
    if (wide) {
      setState(() => _navOpen = !_navOpen);
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheet).height * .8,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const LogoMark(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tr('Ganit Safar', 'गणित सफर'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: tr('Close sidebar', 'बाजूपट्टी बंद करा'),
                      onPressed: () => Navigator.pop(sheet),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    for (final item in _pages)
                      ListTile(
                        minTileHeight: 72,
                        leading: Icon(item.$4, color: green),
                        title: Text(tr(item.$2, item.$3)),
                        selected: page == item.$1,
                        onTap: () {
                          Navigator.pop(sheet);
                          _navigate(item.$1);
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quizToolbar(bool wide) => Material(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 6,
        children: [
          IconButton(
            tooltip: tr('Toggle sidebar', 'बाजूपट्टी उघडा / बंद करा'),
            onPressed: () => _dashboardMenu(wide),
            icon: Icon(
              wide && _navOpen ? Icons.menu_open_rounded : Icons.menu_rounded,
            ),
          ),
          if (!wide || !_navOpen) const LogoMark(size: 36),
          SizedBox(
            width: 190,
            child: DropdownButtonHideUnderline(
              child: const CentralLanguageSelector(),
            ),
          ),
          if (monitor.canPreviewDemo)
            PresentationDataSwitch(
              presentation: monitor.presentation,
              compact: true,
              onChanged: _previewDemo,
            ),
          DashboardBadge(
            monitor.presentation
                ? tr('Demo activity', 'प्रात्यक्षिक कृती')
                : _live
                ? tr('Live updates', 'थेट माहिती')
                : tr('Waiting for live data', 'थेट माहितीची प्रतीक्षा'),
            color: _live ? _dashTeal : _dashAmber,
            icon: _live ? Icons.sensors_rounded : Icons.cloud_off_outlined,
          ),
          if (kIsWeb)
            IconButton(
              tooltip: tr(
                'Full screen (Esc to exit)',
                'पूर्ण स्क्रीन (बाहेर पडण्यासाठी Esc)',
              ),
              onPressed: () => browserFullscreen(true),
              icon: const Icon(Icons.fullscreen_rounded),
            ),
          if (!wide)
            IconButton(
              tooltip: tr('Sign out', 'बाहेर पडा'),
              onPressed: _signOut,
              icon: const Icon(Icons.logout_rounded),
            ),
        ],
      ),
    ),
  );

  Widget _dashboardHeader(bool wide) {
    final selected = _pages.firstWhere((item) => item.$1 == page);
    final title = page == 'overview'
        ? tr('Classroom overview', 'वर्गांचा आढावा')
        : tr(selected.$2, selected.$3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('Central classroom monitoring', 'मध्यवर्ती वर्ग निरीक्षण'),
          style: const TextStyle(fontSize: 12, color: _dashMuted),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w900,
            height: 1.35,
            color: ink,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${tr('Last live update', 'शेवटची थेट माहिती')}: ${monitor.lastDashboardAt == null ? '—' : monitor.lastDashboardAt!.toLocal().toString().split('.').first}',
          style: const TextStyle(fontSize: 11, color: _dashMuted),
        ),
      ],
    );
  }

  Future<void> _previewDemo(bool value) async {
    setState(() {
      data = null;
      error = '';
      _query = '';
      _search.clear();
      _selectedEntity = null;
      _schoolFilter = null;
      page = 'overview';
    });
    await monitor.previewDemo(value);
    await load();
  }

  Future<void> _signOut() async {
    await monitor.logout();
    if (mounted) appNavigator.currentState?.popUntil((route) => route.isFirst);
  }

  Widget _dashboardSidebar() => Container(
    width: 232,
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(right: BorderSide(color: _dashLine)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 28, 18, 22),
          child: Row(
            children: [
              const LogoMark(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('ganit safar', 'गणित सफर'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      tr('School workspace', 'शाळेचे कार्यक्षेत्र'),
                      style: const TextStyle(fontSize: 11, color: _dashMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                for (final item in _pages)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Material(
                      color: page == item.$1 ? cream : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => _navigate(item.$1),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 15,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item.$4,
                                size: 21,
                                color: page == item.$1 ? _dashBlue : _dashMuted,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  tr(item.$2, item.$3),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: page == item.$1
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                    color: page == item.$1
                                        ? _dashBlue
                                        : _dashMuted,
                                  ),
                                ),
                              ),
                              if (item.$1 == 'alerts' &&
                                  rows(
                                    'alerts',
                                  ).any((a) => a['status'] == 'open'))
                                const Icon(
                                  Icons.circle,
                                  size: 7,
                                  color: _dashAmber,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: _dashLine),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                monitor.session!.teacher.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                roleLabel(monitor.session!.teacher.role),
                style: const TextStyle(fontSize: 11, color: _dashMuted),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout_rounded, size: 17),
                label: Text(tr('Sign out', 'बाहेर पडा')),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  bool get _usesTable =>
      _tableChoice ??
      MediaQuery.sizeOf(context).width /
              MediaQuery.textScalerOf(context).scale(1) >=
          760;
  List<Map<String, dynamic>> _filteredRows(String key) {
    final value = rows(key)
        .where(
          (r) =>
              key != 'classrooms' ||
              _schoolFilter == null ||
              r['school_id'] == _schoolFilter,
        )
        .where(
          (r) =>
              _query.isEmpty ||
              [
                'name',
                'email',
                'location',
                'code',
                'school_name',
                'classroom_name',
                'teacher_name',
                'status',
              ].any(
                (k) => (r[k]?.toString().toLowerCase() ?? '').contains(_query),
              ),
        )
        .toList();
    value.sort(
      (a, b) =>
          (_sortAscending ? 1 : -1) *
          (a['name']?.toString() ?? '').compareTo(b['name']?.toString() ?? ''),
    );
    return value;
  }

  Widget _collectionControls(String key) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: DashboardPanel(
      padding: const EdgeInsets.all(18),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 14,
        children: [
          SizedBox(
            width: min(440, max(160, MediaQuery.sizeOf(context).width - 120)),
            child: TextField(
              key: const ValueKey('management-search'),
              controller: _search,
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: tr(
                  'Search by name, school or status',
                  'नाव, शाळा किंवा स्थितीनुसार शोधा',
                ),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: tr('Clear search', 'शोध पुसा'),
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _search.clear();
                          setState(() => _query = '');
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _dashLine),
                ),
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DashboardBadge(
                '${_filteredRows(key).length} / ${rows(key).length}',
                color: _dashBlue,
              ),
              ChoiceChip(
                avatar: const Icon(Icons.table_rows_outlined, size: 18),
                label: Text(tr('Table', 'तक्ता')),
                selected: _usesTable,
                onSelected: (_) => setState(() => _tableChoice = true),
              ),
              ChoiceChip(
                avatar: const Icon(Icons.grid_view_rounded, size: 18),
                label: Text(tr('Cards', 'कार्डे')),
                selected: !_usesTable,
                onSelected: (_) => setState(() => _tableChoice = false),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _collectionTable(
    String key,
    List<String> columns,
    List<List<Widget>> cells,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: DashboardPanel(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, c) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: max(820, c.maxWidth)),
            child: DataTable(
              showCheckboxColumn: false,
              sortColumnIndex: 0,
              sortAscending: _sortAscending,
              headingRowHeight: MediaQuery.textScalerOf(context).scale(58),
              dataRowMinHeight: MediaQuery.textScalerOf(context).scale(72),
              dataRowMaxHeight: MediaQuery.textScalerOf(context).scale(94),
              columnSpacing: 28,
              horizontalMargin: 22,
              headingRowColor: const WidgetStatePropertyAll(cream),
              headingTextStyle: const TextStyle(
                fontSize: 12,
                color: _dashMuted,
                fontWeight: FontWeight.w700,
              ),
              columns: [
                for (var i = 0; i < columns.length; i++)
                  DataColumn(
                    label: Text(columns[i]),
                    onSort: i == 0
                        ? (_, ascending) =>
                              setState(() => _sortAscending = ascending)
                        : null,
                  ),
              ],
              rows: [
                for (var i = 0; i < cells.length; i++)
                  DataRow(
                    selected: _selectedEntity == _filteredRows(key)[i]['id'],
                    onSelectChanged: (_) =>
                        _selectEntity(_filteredRows(key)[i]['id'].toString()),
                    cells: [for (final cell in cells[i]) DataCell(cell)],
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  Widget _tableText(String text, {bool strong = false}) => SizedBox(
    width: 180,
    child: Tooltip(
      excludeFromSemantics: true,
      message: text,
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          fontWeight: strong ? FontWeight.w700 : FontWeight.w400,
          color: strong ? ink : _dashMuted,
        ),
      ),
    ),
  );
  Widget _entityCard(String id, String title, List<Widget> children) {
    final expanded = _selectedEntity == id;
    return Padding(
      key: expanded ? _detailAnchor : null,
      padding: const EdgeInsets.only(bottom: 14),
      child: DashboardPanel(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => _selectEntity(id),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _dashBlue.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _pages.firstWhere((p) => p.$1 == page).$4,
                        color: _dashBlue,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: _dashMuted,
                    ),
                  ],
                ),
              ),
            ),
            if (expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider(color: _dashLine),
                    const SizedBox(height: 12),
                    ...children,
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _pageBody() => switch (page) {
    'schools' => _schools(),
    'classrooms' => _classrooms(),
    'users' => _users(),
    'devices' => _devices(),
    'analytics' => _analytics(),
    'alerts' => _alerts(),
    'versions' => _versions(),
    'audit' => _audit(),
    _ => _overview(),
  };
  Widget _card(String title, List<Widget> children) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: DashboardPanel(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    ),
  );
  Widget _button(String en, String mr, VoidCallback action) => OutlinedButton(
    onPressed: busy || monitor.connection != 'connected' ? null : action,
    child: Text(tr(en, mr)),
  );
  Widget _metrics(List<(String, String, dynamic)> values) => LayoutBuilder(
    builder: (context, constraints) => Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final value in values)
          SizedBox(
            width: constraints.maxWidth < 500
                ? constraints.maxWidth
                : (constraints.maxWidth - 12) / 2,
            child: Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${value.$3 ?? 0}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: green,
                    ),
                  ),
                  Text(tr(value.$1, value.$2)),
                ],
              ),
            ),
          ),
      ],
    ),
  );
  List<Widget> _overview() => [
    DashboardOverview(
      data: data!,
      live: _live,
      now: monitor.now(),
      onNavigate: _navigate,
      onClassroom: (id) => _navigate('classrooms', entity: id),
    ),
    const SizedBox(height: 22),
    ExpansionTile(
      title: Text(tr('More monitoring details', 'निरीक्षणाचे आणखी तपशील')),
      children: _overviewDetails(),
    ),
  ];
  List<Widget> _analytics() => [
    DashboardAnalytics(data: data!, now: monitor.now()),
    const SizedBox(height: 22),
    ExpansionTile(
      title: Text(
        tr('Detailed data & availability', 'सविस्तर माहिती व उपलब्धता'),
      ),
      children: _analyticsDetails(),
    ),
  ];
  List<Widget> _overviewDetails() {
    final o = data!['overview'] as Map;
    return [
      _metrics([
        ('Schools', 'शाळा', o['schools']),
        ('Classrooms', 'वर्ग', o['classrooms']),
        ('Registered devices', 'नोंदणीकृत साधने', o['devices']),
        ('Online classrooms', 'ऑनलाइन वर्ग', o['onlineClassrooms']),
        ('Offline classrooms', 'ऑफलाइन वर्ग', o['offlineClassrooms']),
        (
          'Recently active classrooms',
          'अलीकडे सक्रिय वर्ग',
          o['recentlyActiveClassrooms'],
        ),
        ('Active teachers', 'सक्रिय शिक्षक', o['activeTeachers']),
        ('Active lessons', 'सुरू धडे', o['activeLessons']),
        ('Active practice sessions', 'सुरू सराव सत्रे', o['activePractice']),
        ('Active quizzes', 'सुरू प्रश्नमंजुषा', o['activeQuizzes']),
        ('Today’s usage • UTC', 'आजचा वापर • UTC', analytics['todayUsage']),
        (
          'Weekly usage • UTC',
          'आठवड्याचा वापर • UTC',
          analytics['weeklyUsage'],
        ),
        ('Outdated devices', 'जुनी आवृत्ती असलेली साधने', o['outdatedDevices']),
        (
          'Devices needing attention',
          'लक्ष देण्याची गरज असलेली साधने',
          o['attention'],
        ),
      ]),
      _card(tr('Recent anonymous activity', 'अलीकडील अनामिक कृती'), [
        for (final event in rows('events').take(12))
          ListTile(
            title: Text(
              '${modeLabel(event['mode'])} • ${chapterLabel(event['chapter_id'])}',
            ),
            subtitle: Text(
              '${nameOf('classrooms', event['classroom_id'])} • ${monitorTime(event['occurred_at'])} • ${event['event_type'].endsWith('_completed')
                  ? tr('Completed', 'पूर्ण')
                  : event['event_type'].endsWith('_started')
                  ? tr('Started', 'सुरू')
                  : tr('Left', 'बाहेर पडले')}',
            ),
          ),
        if (rows('events').isEmpty)
          Text(
            tr(
              'No classroom activity received yet.',
              'वर्गातील कृती अद्याप मिळाली नाही.',
            ),
          ),
      ]),
      _card(tr('Connection and account events', 'जोडणी व खात्याच्या कृती'), [
        for (final event in rows('systemEvents').take(12))
          Text(
            '${auditLabel(event['action'])} • ${monitorTime(event['at'])} • ${event['target']}',
          ),
        if (rows('systemEvents').isEmpty)
          Text(
            tr(
              'No system events received.',
              'प्रणाली कृती अद्याप मिळाल्या नाहीत.',
            ),
          ),
      ]),
      _card(tr('Recent errors', 'अलीकडील त्रुटी'), [
        for (final event in rows('errors').take(8))
          Text(
            '${monitorCode(event['code'])} • ${nameOf('classrooms', event['classroom_id'])} • ${monitorTime(event['at'])}',
          ),
        if (rows('errors').isEmpty)
          Text(tr('No errors reported.', 'त्रुटी नोंदवलेल्या नाहीत.')),
      ]),
    ];
  }

  List<Widget> _schools() => [
    if (monitor.isSuperAdmin && !monitor.presentation)
      _button('Add school', 'शाळा जोडा', () => schoolForm()),
    _collectionControls('schools'),
    if (_usesTable)
      _collectionTable(
        'schools',
        [tr('School', 'शाळा'), tr('Location', 'ठिकाण'), tr('Status', 'स्थिती')],
        [
          for (final r in _filteredRows('schools'))
            [
              _tableText(r['name'].toString(), strong: true),
              _tableText(r['location']?.toString() ?? '—'),
              DashboardBadge(
                r['status'] == 'active'
                    ? tr('Active', 'सक्रिय')
                    : tr('Disabled', 'बंद'),
                color: r['status'] == 'active' ? _dashTeal : _dashAmber,
              ),
            ],
        ],
      ),
    if (_filteredRows('schools').isEmpty)
      _card(tr('No matching records', 'जुळणाऱ्या नोंदी नाहीत'), [
        Text(
          tr(
            'Try a different search or add a record.',
            'वेगळा शोध वापरा किंवा नोंद जोडा.',
          ),
        ),
      ]),
    for (final school in _filteredRows(
      'schools',
    ).where((r) => !_usesTable || _selectedEntity == r['id']))
      _entityCard(school['id'].toString(), '${school['name']} • ${school['code']}', [
        Text('${school['location']} • ${school['admin_contact']}'),
        Text(
          '${tr('Created', 'निर्मिती')}: ${monitorTime(school['created_at'])}',
        ),
        Text(
          '${tr('Classrooms', 'वर्ग')}: ${rows('classrooms').where((r) => r['school_id'] == school['id']).length} • ${tr('Devices', 'साधने')}: ${rows('devices').where((d) => d['school_id'] == school['id']).length}',
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (monitor.canAdminister && school['status'] == 'active')
              _button(
                'Add classroom',
                'वर्ग जोडा',
                () => classroomForm(schoolId: school['id'].toString()),
              ),
            _button(
              'View classrooms',
              'वर्ग पाहा',
              () => _openSchoolClassrooms(school['id'].toString()),
            ),
          ],
        ),
        for (final room in rows(
          'classrooms',
        ).where((r) => r['school_id'] == school['id']))
          ListTile(
            contentPadding: EdgeInsets.zero,
            minTileHeight: 64,
            leading: Icon(
              room['online'] == true
                  ? Icons.cast_connected
                  : Icons.meeting_room_outlined,
            ),
            title: Text(room['name'].toString()),
            subtitle: Text(
              room['online'] == true
                  ? tr('Online', 'ऑनलाइन')
                  : tr('Offline', 'ऑफलाइन'),
            ),
            onTap: () => _openSchoolClassrooms(
              school['id'].toString(),
              entity: room['id'].toString(),
            ),
          ),
        Text(
          '${tr('Weekly sessions', 'आठवड्यातील सत्रे')}: ${(analytics['usageDaily'] as List? ?? []).where((entry) => rows('classrooms').any((r) => r['school_id'] == school['id'] && r['id'] == entry['classroom_id'])).fold<int>(0, (sum, entry) => sum + (entry['started'] as num).toInt())}',
        ),
        if (monitor.isSuperAdmin && !monitor.presentation)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _button(
                'Edit school',
                'शाळेची माहिती बदला',
                () => schoolForm(school),
              ),
              _button(
                school['status'] == 'active'
                    ? 'Disable school'
                    : 'Enable school',
                school['status'] == 'active'
                    ? 'शाळा बंद करा'
                    : 'शाळा सक्रिय करा',
                () => action('PATCH', '/schools/${school['id']}', {
                  'status': school['status'] == 'active'
                      ? 'disabled'
                      : 'active',
                }),
              ),
            ],
          ),
      ]),
  ];
  List<Widget> _classrooms() => [
    if (_schoolFilter != null)
      _card(nameOf('schools', _schoolFilter), [
        Text(tr('Classrooms in this school', 'या शाळेतील वर्ग')),
        TextButton(
          onPressed: () => setState(() => _schoolFilter = null),
          child: Text(tr('Show all schools', 'सर्व शाळा दाखवा')),
        ),
      ]),
    if (monitor.canAdminister)
      _button('Add classroom', 'वर्ग जोडा', () => classroomForm()),
    _collectionControls('classrooms'),
    if (_usesTable)
      _collectionTable(
        'classrooms',
        [
          tr('Classroom', 'वर्ग'),
          tr('School', 'शाळा'),
          tr('Status', 'स्थिती'),
          tr('Current activity', 'चालू कृती'),
        ],
        [
          for (final r in _filteredRows('classrooms'))
            [
              _tableText(r['name'].toString(), strong: true),
              _tableText(r['school_name']?.toString() ?? '—'),
              DashboardBadge(
                r['online'] == true
                    ? tr('Online', 'ऑनलाइन')
                    : tr('Offline', 'ऑफलाइन'),
                color: r['online'] == true ? _dashTeal : _dashMuted,
              ),
              _tableText(
                (r['current_activities'] as List? ?? [])
                    .map((a) => modeLabel(a['mode']))
                    .join(', '),
              ),
            ],
        ],
      ),
    if (_filteredRows('classrooms').isEmpty)
      _card(tr('No matching records', 'जुळणाऱ्या नोंदी नाहीत'), [
        Text(
          tr(
            'Try a different search or add a record.',
            'वेगळा शोध वापरा किंवा नोंद जोडा.',
          ),
        ),
      ]),
    for (final room in _filteredRows(
      'classrooms',
    ).where((r) => !_usesTable || _selectedEntity == r['id']))
      _entityCard(room['id'].toString(), '${room['name']} • ${room['school_name']}', [
        Text(
          '${tr('Class', 'इयत्ता')} ${room['grade']} • ${room['section']} • ${room['status'] == 'active' ? tr('Active', 'सक्रिय') : tr('Disabled / archived', 'बंद / संग्रहित')}',
        ),
        Text(
          '${tr('Assigned teachers', 'नेमलेले शिक्षक')}: ${(room['teacher_ids'] as List).map((id) => nameOf('users', id)).join(', ')}',
        ),
        Text(
          '${tr('Current activity', 'चालू कृती')}: ${(room['current_activities'] as List).map((item) => '${modeLabel(item['mode'])} ${chapterLabel(item['chapter'])}').join(' • ')}',
        ),
        Text(
          '${tr('Registered devices', 'नोंदणीकृत साधने')}: ${rows('devices').where((d) => d['classroom_id'] == room['id']).map((d) => '${d['name']} (${deviceStatusLabel(d['status'])})').join(', ')}',
        ),
        if (monitor.canAdminister)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _button(
                'Edit classroom',
                'वर्गाची माहिती बदला',
                () => classroomForm(room: room),
              ),
              _button('Assign teachers', 'शिक्षक नेमा', () async {
                final selected = await choose(
                  tr('Assigned teachers', 'नेमलेले शिक्षक'),
                  rows('users')
                      .where(
                        (u) =>
                            u['role'] == 'teacher' && u['status'] == 'active',
                      )
                      .toList(),
                  List<String>.from(room['teacher_ids']),
                );
                if (selected != null)
                  await action('PATCH', '/classrooms/${room['id']}', {
                    'teacher_ids': selected,
                  });
              }),
              _button(
                room['status'] == 'active'
                    ? 'Disable classroom'
                    : 'Enable classroom',
                room['status'] == 'active' ? 'वर्ग बंद करा' : 'वर्ग सक्रिय करा',
                () => action('PATCH', '/classrooms/${room['id']}', {
                  'status': room['status'] == 'active' ? 'disabled' : 'active',
                }),
              ),
              _button(
                'Archive classroom',
                'वर्ग संग्रहित करा',
                () => action('PATCH', '/classrooms/${room['id']}', {
                  'status': 'archived',
                }),
              ),
            ],
          ),
      ]),
  ];
  List<Widget> _users() => [
    _button('Create teacher / account', 'शिक्षक / खाते तयार करा', userForm),
    Text(
      tr(
        'Initial passwords must be changed on first login. Passwords are never displayed after creation.',
        'पहिल्या प्रवेशावेळी सुरुवातीचा संकेतशब्द बदलावा लागतो. खाते तयार झाल्यानंतर संकेतशब्द दाखवले जात नाहीत.',
      ),
    ),
    _collectionControls('users'),
    if (_usesTable)
      _collectionTable(
        'users',
        [
          tr('Account', 'खाते'),
          tr('Role', 'भूमिका'),
          tr('Email', 'ईमेल'),
          tr('Status', 'स्थिती'),
        ],
        [
          for (final r in _filteredRows('users'))
            [
              _tableText(r['name'].toString(), strong: true),
              _tableText(roleLabel(r['role'])),
              _tableText(r['email'].toString()),
              DashboardBadge(
                r['status'] == 'active'
                    ? tr('Active', 'सक्रिय')
                    : tr('Disabled', 'बंद'),
                color: r['status'] == 'active' ? _dashTeal : _dashAmber,
              ),
            ],
        ],
      ),
    if (_filteredRows('users').isEmpty)
      _card(tr('No matching records', 'जुळणाऱ्या नोंदी नाहीत'), [
        Text(
          tr(
            'Try a different search or add a record.',
            'वेगळा शोध वापरा किंवा नोंद जोडा.',
          ),
        ),
      ]),
    for (final user in _filteredRows(
      'users',
    ).where((r) => !_usesTable || _selectedEntity == r['id']))
      _entityCard(
        user['id'].toString(),
        '${user['name']} • ${roleLabel(user['role'])}',
        [
          Text(user['email']),
          Text(
            '${tr('Last login', 'शेवटचा प्रवेश')}: ${monitorTime(user['last_login'])}',
          ),
          Text(
            '${tr('Schools', 'शाळा')}: ${(user['school_ids'] as List).map((id) => nameOf('schools', id)).join(', ')}',
          ),
          Text(
            '${tr('Classrooms', 'वर्ग')}: ${(user['classroom_ids'] as List).map((id) => nameOf('classrooms', id)).join(', ')}',
          ),
          Text(
            user['status'] == 'active'
                ? tr('Active', 'सक्रिय')
                : tr('Disabled', 'बंद'),
          ),
          if (user['manageable'] == true)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _button('Edit account name', 'खात्याचे नाव बदला', () async {
                  final value = await form(
                    tr('Edit account', 'खात्याची माहिती बदला'),
                    [('name', 'Account name', 'खात्याचे नाव')],
                    values: {'name': user['name']},
                  );
                  if (value != null)
                    await action('PATCH', '/users/${user['id']}', value);
                }),
                if (user['role'] == 'teacher')
                  _button('Assign classrooms', 'वर्ग नेमा', () async {
                    final chosen = await choose(
                      tr('Assigned classrooms', 'नेमलेले वर्ग'),
                      rows('classrooms')
                          .where(
                            (r) => (user['school_ids'] as List).contains(
                              r['school_id'],
                            ),
                          )
                          .toList(),
                      List<String>.from(user['classroom_ids']),
                    );
                    if (chosen != null)
                      await action('PATCH', '/users/${user['id']}', {
                        'classroom_ids': chosen,
                      });
                  }),
                _button(
                  'Reset password',
                  'संकेतशब्द पुनर्स्थापित करा',
                  () => resetUser(user),
                ),
                _button(
                  'Revoke sessions',
                  'सत्रांचा प्रवेश रद्द करा',
                  () => action(
                    'POST',
                    '/users/${user['id']}/revoke-sessions',
                    {},
                  ),
                ),
                _button(
                  user['status'] == 'active'
                      ? 'Disable account'
                      : 'Enable account',
                  user['status'] == 'active'
                      ? 'खाते बंद करा'
                      : 'खाते सक्रिय करा',
                  () => action('PATCH', '/users/${user['id']}', {
                    'status': user['status'] == 'active'
                        ? 'disabled'
                        : 'active',
                  }),
                ),
              ],
            ),
        ],
      ),
  ];
  List<Widget> _devices() => [
    if (monitor.canAdminister)
      _button(
        'Register this browser / whiteboard',
        'या ब्राउझरची / फळ्याची नोंदणी',
        registerBoard,
      ),
    _collectionControls('devices'),
    if (_usesTable)
      _collectionTable(
        'devices',
        [
          tr('Device', 'साधन'),
          tr('Classroom', 'वर्ग'),
          tr('Status', 'स्थिती'),
          tr('Activity', 'कृती'),
        ],
        [
          for (final r in _filteredRows('devices'))
            [
              _tableText(r['name'].toString(), strong: true),
              _tableText(r['classroom_name']?.toString() ?? '—'),
              DashboardBadge(
                deviceStatusLabel(r['status']),
                color: r['status'] == 'online'
                    ? _dashTeal
                    : r['status'] == 'needs_attention'
                    ? _dashAmber
                    : _dashMuted,
              ),
              _tableText(modeLabel(r['current_mode'])),
            ],
        ],
      ),
    if (_filteredRows('devices').isEmpty)
      _card(tr('No matching records', 'जुळणाऱ्या नोंदी नाहीत'), [
        Text(
          tr(
            'Try a different search or add a record.',
            'वेगळा शोध वापरा किंवा नोंद जोडा.',
          ),
        ),
      ]),
    for (final device in _filteredRows(
      'devices',
    ).where((r) => !_usesTable || _selectedEntity == r['id']))
      _entityCard(
        device['id'].toString(),
        '${device['name']} • ${deviceStatusLabel(device['status'])}',
        [
          SelectableText('${tr('Device ID', 'साधन क्रमांक')}: ${device['id']}'),
          Text(
            '${device['school_name']} • ${device['classroom_name']} • ${device['teacher_name']}',
          ),
          Text(
            '${tr('Version', 'आवृत्ती')}: ${device['version']} • ${modeLabel(device['current_mode'])} • ${chapterLabel(device['chapter_id'])}',
          ),
          Text(
            '${tr('Version first observed', 'आवृत्ती प्रथम दिसली')}: ${monitorTime(device['version_updated_at'])}',
          ),
          Text(
            '${tr('Last seen / heartbeat', 'शेवटची जोडणी / स्थिती')}: ${monitorTime(device['last_seen'])}',
          ),
          Text(
            '${tr('Last login', 'शेवटचा प्रवेश')}: ${monitorTime(device['last_login'])} • ${tr('Registered', 'नोंदणी')}: ${monitorTime(device['created_at'])}',
          ),
          Text(
            '${tr('Last interaction', 'शेवटची कृती')}: ${monitorTime(device['last_interaction'])} • ${tr('Anonymous active sessions', 'अनामिक सक्रिय सत्रे')}: ${device['session_count']}',
          ),
          Text(
            '${tr('Health', 'स्थिती')}: ${device['health'] == 'ok' ? tr('Healthy', 'व्यवस्थित') : tr('Needs attention', 'लक्ष देणे आवश्यक')} • ${tr('Error count', 'त्रुटी संख्या')}: ${device['error_count']}',
          ),
          if (device['last_error'].toString().isNotEmpty)
            Text(
              '${tr('Last error', 'शेवटची त्रुटी')}: ${monitorCode(device['last_error'])}',
            ),
          if (monitor.canAdminister)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _button('Rename', 'नाव बदला', () async {
                  final value = await form(
                    tr('Rename device', 'साधनाचे नाव बदला'),
                    [('name', 'Device name', 'साधनाचे नाव')],
                    values: {'name': device['name']},
                  );
                  if (value != null)
                    await action('PATCH', '/devices/${device['id']}', value);
                }),
                _button('Reassign classroom', 'वर्ग बदला', () async {
                  final chosen = await choose(
                    tr('Select classroom', 'वर्ग निवडा'),
                    rows(
                      'classrooms',
                    ).where((r) => r['status'] == 'active').toList(),
                    [device['classroom_id']],
                    single: true,
                  );
                  if (chosen != null && chosen.length == 1)
                    await action('PATCH', '/devices/${device['id']}', {
                      'classroom_id': chosen.first,
                    });
                }),
                _button(
                  device['active'] == 1 ? 'Deactivate' : 'Activate',
                  device['active'] == 1 ? 'निष्क्रिय करा' : 'सक्रिय करा',
                  () => action('PATCH', '/devices/${device['id']}', {
                    'active': device['active'] != 1,
                  }),
                ),
                _button(
                  'Force logout',
                  'सत्र बंद करा',
                  () => action('PATCH', '/devices/${device['id']}', {
                    'force_logout': true,
                  }),
                ),
                _button(
                  'Require sign-in again',
                  'पुन्हा प्रवेश आवश्यक करा',
                  () => action('PATCH', '/devices/${device['id']}', {
                    'require_reauth': true,
                  }),
                ),
                _button(
                  'Revoke device',
                  'साधनाचा प्रवेश रद्द करा',
                  () => action('PATCH', '/devices/${device['id']}', {
                    'revoked': true,
                  }),
                ),
              ],
            ),
          ExpansionTile(
            title: Text(
              tr('Device activity and errors', 'साधनाच्या कृती आणि त्रुटी'),
            ),
            children: [
              for (final event in rows(
                'events',
              ).where((e) => e['device_id'] == device['id']).take(15))
                ListTile(
                  title: Text(
                    '${modeLabel(event['mode'])} • ${chapterLabel(event['chapter_id'])}',
                  ),
                  subtitle: Text(monitorTime(event['occurred_at'])),
                ),
              for (final error in rows(
                'errors',
              ).where((e) => e['device_id'] == device['id']).take(10))
                ListTile(
                  title: Text(monitorCode(error['code'])),
                  subtitle: Text(monitorTime(error['at'])),
                ),
            ],
          ),
        ],
      ),
  ];
  List<Widget> _analyticsDetails() {
    final chapterUsage = Map<String, dynamic>.from(
      analytics['chapterUsage'] ?? {},
    );
    final chapterRows = [
      for (final chapter in schoolChapters)
        {
          'id': chapter.id,
          'started': (chapterUsage[chapter.id] as Map?)?['started'] ?? 0,
          'completed': (chapterUsage[chapter.id] as Map?)?['completed'] ?? 0,
        },
    ]..sort((a, b) => (b['started'] as int).compareTo(a['started'] as int));
    return [
      Text(
        tr(
          'Anonymous aggregate usage • last 7 days • UTC. No individual answers or permanent child scores.',
          'अनामिक एकत्रित वापर • मागील ७ दिवस • UTC. वैयक्तिक उत्तरे किंवा कायमचे विद्यार्थी गुण नाहीत.',
        ),
      ),
      _metrics([
        (
          'Daily active classrooms',
          'दिवसातील सक्रिय वर्ग',
          analytics['dailyActiveClassrooms'],
        ),
        (
          'Weekly active classrooms',
          'आठवड्यातील सक्रिय वर्ग',
          analytics['weeklyActiveClassrooms'],
        ),
        ('Lessons started', 'सुरू केलेले धडे', analytics['lessonsStarted']),
        (
          'Lessons completed',
          'पूर्ण केलेले धडे',
          analytics['lessonsCompleted'],
        ),
        ('Practice sessions', 'सराव सत्रे', analytics['practiceSessions']),
        ('Quiz sessions', 'प्रश्नमंजुषा सत्रे', analytics['quizSessions']),
        (
          'Average completed session • seconds',
          'पूर्ण सत्रांचा सरासरी वेळ • सेकंद',
          analytics['averageSessionDuration'],
        ),
      ]),
      _card(tr('Daily sessions', 'दिवसानुसार सत्रे'), [
        for (final usage in analytics['usageDaily'] as List? ?? [])
          ListTile(
            title: Text(
              '${usage['day']} • ${nameOf('classrooms', usage['classroom_id'])} • ${modeLabel(usage['mode'])}',
            ),
            subtitle: Text(
              '${tr('Started', 'सुरू')} ${usage['started']} • ${tr('Completed', 'पूर्ण')} ${usage['completed']}',
            ),
          ),
      ]),
      _card(tr('Most-used chapters', 'सर्वाधिक वापरलेले धडे'), [
        for (final row
            in chapterRows.where((r) => (r['started'] as int) > 0).take(5))
          _chapterUsageRow(row),
      ]),
      _card(tr('Least-used chapters', 'कमी वापरलेले धडे'), [
        for (final row in chapterRows.reversed.take(5)) _chapterUsageRow(row),
      ]),
      for (final metric in [
        ('practiceByClass', 'Practice by class', 'इयत्तेनुसार सराव'),
        ('quizByClass', 'Quiz by class', 'इयत्तेनुसार प्रश्नमंजुषा'),
        ('teacherActivity', 'Teacher activity', 'शिक्षकांच्या कृती'),
        ('versionDistribution', 'Version distribution', 'आवृत्ती वितरण'),
        ('errorFrequency', 'Error frequency', 'त्रुटींची वारंवारता'),
      ])
        _card(tr(metric.$2, metric.$3), [
          for (final entry in Map<String, dynamic>.from(
            analytics[metric.$1] ?? {},
          ).entries)
            Text(
              '${metric.$1 == 'teacherActivity'
                  ? nameOf('users', entry.key)
                  : metric.$1 == 'errorFrequency'
                  ? monitorCode(entry.key)
                  : entry.key}: ${entry.value}',
            ),
        ]),
      _card(
        tr(
          'Observed device availability • estimates',
          'नोंदवलेली साधन उपलब्धता • अंदाज',
        ),
        [
          Text(
            tr(
              'Based on received heartbeats, not hardware power-on measurements.',
              'मिळालेल्या स्थिती नोंदींवर आधारित; हार्डवेअर सुरू असण्याचे थेट मोजमाप नाही.',
            ),
          ),
          for (final entry in Map<String, dynamic>.from(
            analytics['deviceAvailability'] ?? {},
          ).entries)
            Text(
              '${nameOf('devices', entry.key)} • ${tr('Connected seconds', 'जोडलेले सेकंद')}: ${entry.value['observedConnectedSeconds']} • ${tr('Estimated offline seconds', 'अंदाजे ऑफलाइन सेकंद')}: ${entry.value['estimatedOfflineSeconds']}',
            ),
        ],
      ),
    ];
  }

  Widget _chapterUsageRow(Map<String, dynamic> row) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(chapterLabel(row['id'])),
        Text(
          '${tr('Started', 'सुरू')}: ${row['started']} • ${tr('Completed', 'पूर्ण')}: ${row['completed']}',
        ),
        LinearProgressIndicator(
          minHeight: 12,
          value: (row['started'] as int) == 0
              ? 0
              : min(1.0, (row['completed'] as int) / (row['started'] as int)),
        ),
      ],
    ),
  );
  List<Widget> _alerts() => [
    if (monitor.canAdminister)
      _button(
        'Configure alert thresholds',
        'सूचनांच्या मर्यादा ठरवा',
        () async {
          final school = await choose(
            tr('Select school', 'शाळा निवडा'),
            rows('schools'),
            [],
            single: true,
          );
          if (school == null || school.length != 1 || !mounted) return;
          final rule = rows(
            'alertRules',
          ).where((r) => r['school_id'] == school.first).firstOrNull;
          final value = await form(
            tr('Alert thresholds', 'सूचनांच्या मर्यादा'),
            [
              (
                'offline_seconds',
                'Offline duration (seconds)',
                'ऑफलाइन कालावधी (सेकंद)',
              ),
              (
                'error_threshold',
                'Errors in 30 minutes',
                '३० मिनिटांतील त्रुटी',
              ),
              (
                'login_threshold',
                'Failed logins in five minutes',
                'पाच मिनिटांतील अयशस्वी प्रवेश',
              ),
            ],
            values: {
              'offline_seconds': '${rule?['offline_seconds'] ?? 600}',
              'error_threshold': '${rule?['error_threshold'] ?? 3}',
              'login_threshold': '${rule?['login_threshold'] ?? 5}',
            },
          );
          if (value != null)
            await action('PATCH', '/alert-rules/${school.first}', {
              for (final entry in value.entries)
                entry.key: int.tryParse(entry.value) ?? 0,
            });
        },
      ),
    for (final alert in rows('alerts'))
      _card(monitorCode(alert['code']), [
        Text(
          '${alert['severity'] == 'critical' ? tr('Critical', 'गंभीर') : tr('Warning', 'सूचना')} • ${alert['status'] == 'open' ? tr('Unresolved', 'प्रलंबित') : tr('Resolved', 'सोडवलेली')}',
        ),
        Text(
          '${nameOf('classrooms', alert['classroom_id'])} • ${nameOf('devices', alert['device_id'])} • ${monitorTime(alert['at'])}',
        ),
        if (monitor.canAdminister)
          _button(
            alert['status'] == 'open' ? 'Mark resolved' : 'Reopen',
            alert['status'] == 'open'
                ? 'सोडवलेली म्हणून नोंदवा'
                : 'पुन्हा उघडा',
            () => action('PATCH', '/alerts/${alert['id']}', {
              'status': alert['status'] == 'open' ? 'resolved' : 'open',
            }),
          ),
      ]),
    if (rows('alerts').isEmpty)
      Text(tr('No alerts received.', 'सूचना मिळालेल्या नाहीत.')),
  ];
  List<Widget> _versions() => [
    Text(
      '${tr('This app version', 'या अॅपची आवृत्ती')}: ${CentralClient.appVersion}',
    ),
    if (monitor.isSuperAdmin && !monitor.presentation)
      _button(
        'Add / update approved version',
        'मान्य आवृत्ती जोडा / बदला',
        () async {
          final value = await form(tr('App version', 'अॅप आवृत्ती'), [
            ('version', 'Version (for example 1.2.0)', 'आवृत्ती (उदा. 1.2.0)'),
          ]);
          if (value != null)
            await action('POST', '/versions', {
              ...value,
              'approved': true,
              'supported': true,
            });
        },
      ),
    _card(tr('Versions by classroom', 'वर्गानुसार आवृत्त्या'), [
      for (final room in rows('classrooms'))
        Text(
          '${room['name']}: ${rows('devices').where((d) => d['classroom_id'] == room['id']).map((d) => d['version'].toString().isEmpty ? tr('Not reported', 'अद्याप नोंद नाही') : d['version']).join(', ')}',
        ),
    ]),
    for (final version in rows('versions'))
      _card(version['version'], [
        Text(
          version['approved'] == 1
              ? tr('Approved', 'मान्य')
              : tr('Outdated / unapproved', 'जुनी / अमान्य'),
        ),
        Text(
          version['supported'] == 1
              ? tr('Supported', 'समर्थित')
              : tr(
                  'Unsupported • online sign-in blocked',
                  'समर्थित नाही • ऑनलाइन प्रवेश बंद',
                ),
        ),
        Text('${tr('Updated', 'बदल')}: ${monitorTime(version['updated_at'])}'),
        if (monitor.isSuperAdmin && !monitor.presentation)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _button(
                'Approve version',
                'आवृत्ती मान्य करा',
                () => action('POST', '/versions', {
                  'version': version['version'],
                  'approved': true,
                  'supported': true,
                }),
              ),
              _button(
                'Mark outdated',
                'जुनी म्हणून नोंदवा',
                () => action('POST', '/versions', {
                  'version': version['version'],
                  'approved': false,
                  'supported': version['supported'] == 1,
                }),
              ),
              _button(
                'Disable unsupported version',
                'असमर्थित आवृत्ती बंद करा',
                () => action('POST', '/versions', {
                  'version': version['version'],
                  'approved': false,
                  'supported': false,
                }),
              ),
            ],
          ),
      ]),
  ];
  List<Widget> _audit() => [
    for (final event in rows('audit'))
      _card(auditLabel(event['action']), [
        Text('${nameOf('users', event['actor'])} • ${event['target']}'),
        Text(monitorTime(event['at'])),
      ]),
  ];
}

String auditLabel(String code) => switch (code) {
  'login' || 'teacher_login' => tr('Account signed in', 'खात्याचा प्रवेश'),
  'logout' ||
  'teacher_logout' => tr('Account signed out', 'खात्यातून बाहेर पडले'),
  'school_created' ||
  'school_updated' => tr('School changed', 'शाळेच्या माहितीत बदल'),
  'classroom_created' ||
  'classroom_updated' => tr('Classroom changed', 'वर्गाच्या माहितीत बदल'),
  'user_created' ||
  'user_updated' => tr('Account changed', 'खात्याच्या माहितीत बदल'),
  'device_registered' || 'device_authenticated' => tr(
    'Device registered / authenticated',
    'साधनाची नोंदणी / प्रवेश',
  ),
  'session_expired' => tr('Session expired', 'सत्राची मुदत संपली'),
  'version_mismatch' => tr('App version mismatch', 'अॅपची आवृत्ती जुळत नाही'),
  'login_failed' => tr('Sign-in attempt rejected', 'प्रवेशाचा प्रयत्न नाकारला'),
  'device_connected' => tr('Device connected', 'साधन जोडले'),
  'device_disconnected' => tr('Device disconnected', 'साधनाची जोडणी बंद'),
  'device_updated' => tr('Device changed', 'साधनाच्या माहितीत बदल'),
  'device_revoked' => tr('Device revoked', 'साधनाचा प्रवेश रद्द'),
  'password_changed' ||
  'password_reset_completed' => tr('Password changed', 'संकेतशब्द बदलला'),
  'password_reset_issued' => tr('Reset token issued', 'पुनर्स्थापना टोकन दिला'),
  'user_sessions_revoked' => tr(
    'Account sessions revoked',
    'खात्याची सत्रे रद्द',
  ),
  'refresh_reuse_detected' => tr(
    'Suspicious session revoked',
    'संशयास्पद सत्र रद्द',
  ),
  'version_updated' => tr('Version policy changed', 'आवृत्ती धोरण बदलले'),
  'alert_updated' || 'alert_rules_updated' => tr(
    'Alert / threshold changed',
    'सूचना / मर्यादा बदलली',
  ),
  _ => tr('System action recorded', 'प्रणाली कृती नोंदवली'),
};
