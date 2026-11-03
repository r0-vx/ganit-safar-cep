part of 'main.dart';

class AccountMenuButton extends StatelessWidget {
  final CentralClient? client;
  const AccountMenuButton({super.key, this.client});
  CentralClient get account => client ?? central;
  Future<void> _details(BuildContext context) => showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(tr('Account details', 'खात्याची माहिती')),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                account.session?.teacher.name ??
                    tr('Local learning', 'स्थानिक अभ्यास'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (account.session?.teacher.email.isNotEmpty == true)
                SelectableText(account.session!.teacher.email),
              Text(
                account.session == null
                    ? tr('Offline on this device', 'या साधनावर ऑफलाइन')
                    : roleLabel(account.session!.teacher.role),
              ),
              const SizedBox(height: 16),
              Text(
                account.schoolName.isEmpty
                    ? tr(
                        'No classroom linked. Learning content is available; link a classroom to report its activity.',
                        'वर्ग जोडलेला नाही. अभ्यास उपलब्ध आहे; कृतींची नोंद करण्यासाठी वर्ग जोडा.',
                      )
                    : '${account.schoolName} • ${account.classroomName}',
              ),
              const SizedBox(height: 12),
              Text(
                '${tr('Connection', 'जोडणी')}: ${account.connection == "connected" ? tr('Connected', 'जोडलेले') : tr('Offline', 'ऑफलाइन')}',
              ),
              if (account.offlineAuthorized)
                Text(
                  '${tr('Offline access until', 'ऑफलाइन प्रवेशाची अंतिम वेळ')}: ${monitorTime(account.lease!['expiresAt'])}',
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(tr('Close', 'बंद करा')),
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([account, store]),
    builder: (context, _) => PopupMenuButton<String>(
      tooltip: tr('Account', 'खाते'),
      position: PopupMenuPosition.under,
      icon: CircleAvatar(
        radius: 20,
        backgroundColor: green.withValues(alpha: .12),
        child: Text(
          (account.session?.teacher.name.trim().isNotEmpty == true
                  ? account.session!.teacher.name.trim().characters.first
                  : 'G')
              .toUpperCase(),
          style: const TextStyle(color: green, fontWeight: FontWeight.w900),
        ),
      ),
      itemBuilder: (_) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            account.session?.teacher.name ??
                tr('Local learning', 'स्थानिक अभ्यास'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        PopupMenuItem(
          value: 'details',
          height: 64,
          child: ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: Text(tr('Account details', 'खात्याची माहिती')),
          ),
        ),
        if (account.managed && account.session != null)
          PopupMenuItem(
            value: 'classroom',
            height: 64,
            child: ListTile(
              leading: const Icon(Icons.cast_connected_outlined),
              title: Text(tr('Connect classroom', 'वर्ग जोडा')),
            ),
          ),
        if (kIsWeb && account.isClassroomAdministrator)
          PopupMenuItem(
            value: 'dashboard',
            height: 64,
            child: ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: Text(tr('Open dashboard', 'निरीक्षण फलक उघडा')),
            ),
          ),
        if (account.session != null)
          PopupMenuItem(
            value: 'logout',
            height: 64,
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: Text(tr('Sign out', 'बाहेर पडा')),
            ),
          ),
      ],
      onSelected: (value) async {
        if (value == 'details') {
          await _details(context);
          return;
        }
        if (value == 'dashboard') {
          browserPortal(true, false);
          return;
        }
        if (value == 'classroom') {
          try {
            await account.reloadClassrooms();
          } catch (error) {
            if (context.mounted)
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(centralError(error))));
            return;
          }
          if (!context.mounted) return;
          await Navigator.push<void>(
            context,
            MaterialPageRoute(builder: (_) => const ClassroomEnrollmentPage()),
          );
          return;
        }
        if (value == 'logout') {
          await account.logout();
          appNavigator.currentState?.popUntil((r) => r.isFirst);
        }
      },
    ),
  );
}

class ClassroomTopBar extends StatelessWidget {
  final bool showBack, sidebarOpen, full;
  final FocusNode menuFocus;
  final VoidCallback onMenu, onBack, onFullscreen;
  const ClassroomTopBar({
    super.key,
    required this.showBack,
    required this.sidebarOpen,
    required this.full,
    required this.menuFocus,
    required this.onMenu,
    required this.onBack,
    required this.onFullscreen,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            button: true,
            expanded: sidebarOpen,
            child: IconButton(
              focusNode: menuFocus,
              tooltip: tr(
                'Toggle sidebar (Ctrl+B)',
                'बाजूपट्टी उघडा / बंद करा (Ctrl+B)',
              ),
              onPressed: onMenu,
              icon: const Icon(Icons.menu),
            ),
          ),
          if (showBack)
            IconButton(
              tooltip: tr('Back', 'मागे'),
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
            ),
          Expanded(
            child: Align(
              alignment: Alignment.topRight,
              child: Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                runSpacing: 4,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: DropdownButton<int>(
                      isExpanded: true,
                      itemHeight: store.smartboard ? 72 : 56,
                      value: store.language,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(
                          value: 0,
                          child: Text(
                            'English',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 1,
                          child: Text('मराठी', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text(
                            'English + मराठी',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          store.language = v;
                          store.save();
                        }
                      },
                    ),
                  ),
                  IconButton(
                    tooltip: tr('Toggle sound', 'आवाज चालू / बंद'),
                    onPressed: () {
                      store.sound = !store.sound;
                      store.save();
                    },
                    icon: Icon(
                      store.sound
                          ? Icons.volume_up_outlined
                          : Icons.volume_off_outlined,
                    ),
                  ),
                  IconButton(
                    tooltip: tr('Full screen (F11)', 'पूर्ण स्क्रीन (F11)'),
                    onPressed: onFullscreen,
                    icon: Icon(full ? Icons.fullscreen_exit : Icons.fullscreen),
                  ),
                  const AccountMenuButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
