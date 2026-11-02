part of 'main.dart';

class PortalSignInView extends StatelessWidget {
  final bool dashboard, busy;
  final TextEditingController email, password;
  final String error;
  final VoidCallback onSignIn, onContinueOffline;
  const PortalSignInView({
    super.key,
    required this.dashboard,
    required this.email,
    required this.password,
    required this.busy,
    required this.error,
    required this.onSignIn,
    required this.onContinueOffline,
  });

  Color get accent =>
      dashboard ? const Color(0xFF6D28D9) : LearningPalette.teal;
  String get title => dashboard
      ? tr('Monitoring dashboard sign in', 'निरीक्षण फलकावर प्रवेश')
      : tr('Classroom app sign in', 'गणित अॅपमध्ये प्रवेश');

  Widget _hero(bool wide) => Container(
    padding: EdgeInsets.all(wide ? 32 : 20),
    decoration: BoxDecoration(
      color: dashboard ? const Color(0xFFF1EBFF) : LearningPalette.paper,
      borderRadius: BorderRadius.circular(28),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const LogoMark(),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tr('Ganit Safar', 'गणित सफर'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (dashboard)
          Icon(
            Icons.monitor_heart_outlined,
            size: wide ? 76 : 44,
            color: accent,
          )
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LearningArtwork(
              asset: 'assets/art/classroom_story.png',
              height: wide ? 200 : 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(height: 20),
        Text(
          dashboard
              ? tr('Every classroom, at a glance.', 'एका नजरेत सर्व वर्ग.')
              : tr('Big adventures. Little numbers.', 'छोटे अंक. मोठी मजा.'),
          style: TextStyle(
            fontSize: wide ? 31 : 24,
            height: 1.3,
            fontWeight: FontWeight.w900,
            color: ink,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          dashboard
              ? tr(
                  'See classroom activity, connected boards and the next useful action.',
                  'वर्गातील कृती, जोडलेले फळे आणि पुढील आवश्यक कामे पाहा.',
                )
              : tr(
                  'Learn, practise and play with Mathematics on your classroom board.',
                  'वर्गाच्या फळ्यावर गणित शिका, सराव करा आणि खेळा.',
                ),
          style: const TextStyle(fontSize: 16, height: 1.6, color: _dashMuted),
        ),
        if (wide) ...[
          const SizedBox(height: 28),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final item
                  in dashboard
                      ? [
                          (Icons.school_outlined, tr('Schools', 'शाळा')),
                          (
                            Icons.cast_connected_rounded,
                            tr('Smartboards', 'स्मार्ट फळे'),
                          ),
                          (
                            Icons.insights_rounded,
                            tr('Live activity', 'थेट कृती'),
                          ),
                        ]
                      : [
                          (Icons.menu_book_rounded, tr('Learn', 'शिका')),
                          (Icons.edit_note_rounded, tr('Practice', 'सराव')),
                          (Icons.stars_rounded, tr('Quiz', 'प्रश्नमंजुषा')),
                        ])
                DashboardBadge(item.$2, color: accent, icon: item.$1),
            ],
          ),
        ],
      ],
    ),
  );

  Widget _form() => Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              dashboard
                  ? Icons.admin_panel_settings_outlined
                  : Icons.school_rounded,
              color: accent,
              size: 30,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          dashboard
              ? tr(
                  'Use your school ID and password to monitor your classrooms. Administrators can also sign in here.',
                  'तुमच्या वर्गांचे निरीक्षण पाहण्यासाठी शाळेचा आयडी व संकेतशब्द वापरा. प्रशासकही येथे प्रवेश करू शकतात.',
                )
              : tr(
                  'Use your school ID and password, then connect this smartboard to its classroom.',
                  'शाळेचा आयडी व संकेतशब्द वापरा, नंतर हा स्मार्ट फळा त्याच्या वर्गाला जोडा.',
                ),
          style: const TextStyle(fontSize: 15, height: 1.5, color: _dashMuted),
        ),
        if (!central.managed) ...[
          const SizedBox(height: 12),
          Text(
            tr(
              'LOCAL DEVELOPMENT • No hosted central system',
              'स्थानिक विकास • मध्यवर्ती प्रणाली प्रकाशित नाही',
            ),
          ),
        ],
        const SizedBox(height: 16),
        const SizedBox(height: 16),
        TextField(
          controller: email,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: tr('User ID or email', 'वापरकर्ता नाव किंवा ईमेल'),
            prefixIcon: const Icon(Icons.person_outline_rounded),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: password,
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
          onSubmitted: (_) {
            if (!busy) onSignIn();
          },
          decoration: InputDecoration(
            labelText: tr('Password', 'संकेतशब्द'),
            prefixIcon: const Icon(Icons.lock_outline_rounded),
          ),
        ),
        if (error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(error, style: const TextStyle(color: orange)),
          ),
        const SizedBox(height: 20),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            minimumSize: const Size(64, 64),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          onPressed: busy || central.apiBase.isEmpty ? null : onSignIn,
          icon: Icon(
            busy ? Icons.hourglass_top_rounded : Icons.arrow_forward_rounded,
          ),
          label: Text(
            busy
                ? tr('Connecting…', 'जोडत आहे…')
                : dashboard
                ? tr('Open monitoring dashboard', 'निरीक्षण फलक उघडा')
                : tr('Open classroom app', 'गणित अॅप उघडा'),
            textAlign: TextAlign.center,
          ),
        ),
        if (!central.managed) ...[
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onContinueOffline,
            child: Text(
              tr(
                'Continue offline • Development mode',
                'ऑफलाइन पुढे जा • विकास मोड',
              ),
            ),
          ),
        ],
        if (central.managed)
          TextButton(
            onPressed: () => Navigator.push<void>(
              // Existing reset-token workflow.
              appNavigator.currentContext!,
              MaterialPageRoute(builder: (_) => const CentralResetPage()),
            ),
            child: Text(
              tr(
                'Use a password-reset token',
                'संकेतशब्द बदलण्यासाठी टोकन वापरा',
              ),
            ),
          ),
        const SizedBox(height: 12),
        const CentralLanguageSelector(),
        if (kIsWeb) ...[
          const SizedBox(height: 16),
          const Divider(),
          TextButton.icon(
            onPressed: () => browserPortal(!dashboard, central.presentation),
            icon: Icon(
              dashboard ? Icons.school_outlined : Icons.dashboard_outlined,
            ),
            label: Text(
              dashboard
                  ? tr(
                      'Go to classroom sign in',
                      'गणित अॅपच्या प्रवेश पानावर जा',
                    )
                  : tr(
                      'Go to dashboard sign in',
                      'निरीक्षण फलकाच्या प्रवेश पानावर जा',
                    ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: store.contrast ? Colors.white : cream,
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, box) {
          final wide =
              box.maxWidth / MediaQuery.textScalerOf(context).scale(1) >= 1000;
          return SingleChildScrollView(
            padding: EdgeInsets.all(wide ? 32 : 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1160),
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: _hero(true)),
                          const SizedBox(width: 28),
                          Expanded(flex: 6, child: _form()),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _hero(false),
                          const SizedBox(height: 16),
                          _form(),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
