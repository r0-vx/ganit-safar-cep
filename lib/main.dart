import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io' show Platform, exit;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_selector/file_selector.dart';
import 'package:window_manager/window_manager.dart';
import 'content.dart';
import 'store.dart';
import 'curriculum.dart';
import 'generator.dart';
import 'models.dart';
import 'chapter_catalogue.dart';
import 'central_client.dart';
import 'platform/fullscreen_stub.dart'
    if (dart.library.js_interop) 'platform/fullscreen_web.dart';
part 'learning_v2.dart';
part 'management.dart';
part 'dashboard_visuals.dart';
part 'presentation_ui.dart';
part 'portal_sign_in.dart';
part 'account_menu.dart';
part 'management_forms.dart';
part 'school_accounts.dart';
part 'chapter_screens.dart';
part 'chapter_lessons.dart';
part 'chapter_sessions.dart';
part 'learning_design.dart';
part 'math_scene.dart';
part 'board_ui.dart';
part 'class4_interface_marathi.dart';

final store = AppStore();
final appNavigator = GlobalKey<NavigatorState>();
const ink = Color(0xFF0F172A),
    green = Color(0xFF2563EB),
    cream = Color(0xFFEFF6FF),
    orange = Color(0xFFB45309);
const gradeColors = [
  Color(0xFF2563EB),
  Color(0xFF397BA8),
  Color(0xFF9866B5),
  Color(0xFFD0783D),
];
String tr(String en, String mr) => Words(
  en,
  store.grade == 4 && portalSurface != 'dashboard'
      ? class4UiMarathi(en, mr)
      : mr,
).inLanguage(store.language);

String classUiText(Words words, {int? grade}) => Words(
  words.en,
  (grade ?? store.grade) == 4 && portalSurface != 'dashboard'
      ? class4UiMarathi(words.en, words.mr)
      : words.mr,
).inLanguage(store.language);
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) browserCleanLegacyMode();
  await store.init();
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await windowManager.ensureInitialized();
    await windowManager.setMinimumSize(const Size(960, 640));
    await windowManager.setTitle('Ganit Safar / गणित सफर');
  }
  if (!kIsWeb && Platform.isAndroid) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
  HardwareKeyboard.instance.addHandler((event) {
    central.interact();
    return false;
  });
  final priorErrorHandler = FlutterError.onError;
  FlutterError.onError = (details) {
    priorErrorHandler?.call(details);
    scheduleMicrotask(() => central.reportError('render_error'));
  };
  final oldUnhandled = WidgetsBinding.instance.platformDispatcher.onError;
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    scheduleMicrotask(() => central.reportError('unhandled_error'));
    return oldUnhandled?.call(error, stack) ?? false;
  };
  runApp(const GanitApp());
}

class GanitApp extends StatelessWidget {
  const GanitApp({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => MaterialApp(
      navigatorKey: appNavigator,
      title: 'Ganit Safar / गणित सफर',
      debugShowCheckedModeBanner: false,
      theme: ganitAppTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(store.largeText ? 1.15 : 1)),
        child: Listener(
          onPointerDown: (_) => central.interact(),
          child: ListenableBuilder(
            listenable: central,
            builder: (context, _) => Stack(
              children: [
                if (child != null)
                  Padding(
                    padding: EdgeInsets.only(
                      top: central.presentation ? 44 : 0,
                    ),
                    child: ExcludeSemantics(
                      excluding: central.managed && central.locked,
                      child: ExcludeFocus(
                        excluding: central.managed && central.locked,
                        child: IgnorePointer(
                          ignoring: central.managed && central.locked,
                          child: child,
                        ),
                      ),
                    ),
                  ),
                if (central.presentation)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Material(
                      color: const Color(0xFFFFF0C2),
                      child: SizedBox(
                        height: 44,
                        child: Center(
                          child: Text(
                            tr(
                              'ADMIN DEMO PREVIEW • Separate from live school data',
                              'सादरीकरणासाठी प्रात्यक्षिक • प्रत्यक्ष शालेय माहितीपासून वेगळे',
                            ),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: ink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (central.managed && central.locked)
                  Positioned.fill(
                    child: HeroControllerScope.none(
                      child: Navigator(
                        onGenerateRoute: (_) => MaterialPageRoute(
                          builder: (_) => ListenableBuilder(
                            listenable: store,
                            builder: (_, _) => CentralLogin(
                              onContinue: () => appNavigator.currentState
                                  ?.popUntil((route) => route.isFirst),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      onGenerateInitialRoutes: (name) => [
        MaterialPageRoute<void>(
          settings: RouteSettings(name: name),
          builder: (_) => const ConnectionGate(),
        ),
      ],
      onGenerateRoute: (settings) => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const ConnectionGate(),
      ),
    ),
  );
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  @override
  void initState() {
    super.initState();
    store.addListener(refresh);
    central.addListener(refresh);
  }

  void refresh() {
    if (mounted)
      setState(() {
        if (central.locked) teacher = false;
      });
  }

  @override
  void dispose() {
    store.removeListener(refresh);
    central.removeListener(refresh);
    menuFocus.dispose();
    super.dispose();
  }

  String page = 'home', mode = 'learn';
  Topic selected = topics[2];
  bool full = false, teacher = false;
  void go(String target) {
    setState(() => page = target);
  }

  Future<void> fullscreen([bool? value]) async {
    full = value ?? !full;
    if (kIsWeb) {
      await browserFullscreen(full);
      setState(() {});
      return;
    }
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      await windowManager.setFullScreen(full);
    } else {
      await SystemChrome.setEnabledSystemUIMode(
        full ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
      );
    }
    setState(() {});
  }

  Future<void> teacherGate({String target = 'teacher'}) async {
    if (teacher) {
      go(target);
      return;
    }
    final input = TextEditingController();
    String? error;
    bool checking = false;
    final unlocked = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) {
          Future<void> check() async {
            if (checking) return;
            set(() => checking = true);
            final valid = central.managed
                ? await central.unlockTeacher(input.text)
                : AppStore.digest(input.text) == store.pinHash;
            if (!ctx.mounted) return;
            if (valid) {
              Navigator.pop(ctx, true);
            } else {
              set(() {
                checking = false;
                error = central.managed
                    ? tr(
                        'Check your private teaching credentials. Too many attempts require a wait.',
                        'खासगी शिक्षक माहिती तपासा. अनेक प्रयत्नांनंतर थांबावे लागेल.',
                      )
                    : tr('Please check your PIN.', 'पिन पुन्हा तपासा.');
              });
            }
          }

          return AlertDialog(
            title: Text(tr('Teacher’s corner', 'शिक्षक कक्ष')),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    central.managed
                        ? central.hasOfflinePin
                              ? tr(
                                  'Enter your private teaching PIN.',
                                  'खासगी शिक्षक पिन टाका.',
                                )
                              : tr(
                                  'Enter your account password while connected. Set a private offline PIN in Classroom connection.',
                                  'जोडणी असताना खात्याचा संकेतशब्द टाका. वर्ग जोडणीमध्ये खासगी ऑफलाइन पिन ठरवा.',
                                )
                        : tr(
                            'Enter your local PIN. First use: 1234. Change it in Teacher Mode.',
                            'स्थानिक पिन टाका. पहिल्या वापरासाठी: 1234. शिक्षक मोडमध्ये बदला.',
                          ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: input,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: central.managed && !central.hasOfflinePin
                        ? TextInputType.text
                        : TextInputType.number,
                    decoration: InputDecoration(
                      labelText: central.managed && !central.hasOfflinePin
                          ? tr('Account password', 'खात्याचा संकेतशब्द')
                          : tr('Teacher PIN', 'शिक्षक पिन'),
                      errorText: error,
                    ),
                    onSubmitted: (_) => check(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(tr('Cancel', 'रद्द करा')),
              ),
              FilledButton(
                onPressed: checking ? null : check,
                child: Text(tr('Unlock', 'उघडा')),
              ),
            ],
          );
        },
      ),
    );
    input.clear();
    input.dispose();
    if (unlocked == true && mounted) {
      teacher = true;
      go(target);
    }
  }

  void openTopic(Topic t) {
    selected = t;
    go(
      mode == 'quiz'
          ? 'quizSetup'
          : mode == 'practice'
          ? 'practice'
          : 'lesson',
    );
  }

  final menuFocus = FocusNode();
  final shellKey = GlobalKey<ScaffoldState>();
  Widget navigation(bool drawer) => SafeArea(
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
                  'ganit safar',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
              ),
              if (drawer)
                IconButton(
                  tooltip: tr('Close sidebar', 'बाजूपट्टी बंद करा'),
                  onPressed: () {
                    shellKey.currentState?.closeDrawer();
                    menuFocus.requestFocus();
                  },
                  icon: const Icon(Icons.close),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              for (final item in [
                ('home', Icons.home_rounded, 'Home', 'मुख्यपृष्ठ'),
                (
                  'chapters',
                  Icons.menu_book_rounded,
                  'Chapters',
                  'पाठांची यादी',
                ),
                ('learn', Icons.auto_stories_rounded, 'Learn', 'शिका'),
                ('practice', Icons.gesture_rounded, 'Practice', 'सराव'),
                ('quiz', Icons.extension_rounded, 'Quiz', 'प्रश्नमंजुषा'),
                ('progress', Icons.bar_chart_rounded, 'Progress', 'प्रगती'),
                (
                  'teacher',
                  Icons.school_outlined,
                  'Teacher mode',
                  'शिक्षक मोड',
                ),
                ('settings', Icons.settings_outlined, 'Settings', 'सेटिंग्ज'),
              ])
                ListTile(
                  minVerticalPadding: 12,
                  minTileHeight: store.smartboard ? 76 : 56,
                  selected:
                      page == item.$1 || (page == 'topics' && mode == item.$1),
                  leading: Icon(item.$2),
                  title: Text(tr(item.$3, item.$4)),
                  onTap: () {
                    if (drawer) Navigator.pop(context);
                    menuFocus.requestFocus();
                    if (item.$1 == 'teacher') {
                      teacherGate();
                    } else if (item.$1 == 'settings' &&
                        central.managed &&
                        !teacher) {
                      teacherGate(target: 'settings');
                    } else if ([
                      'learn',
                      'practice',
                      'quiz',
                    ].contains(item.$1)) {
                      mode = item.$1;
                      go(item.$1 == 'practice' ? 'practiceSetup' : 'topics');
                    } else {
                      go(item.$1);
                    }
                  },
                ),
            ],
          ),
        ),
        if (teacher)
          ListTile(
            leading: const Icon(Icons.settings_input_component),
            title: Text(tr('Classroom connection', 'वर्ग जोडणी')),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => central.managed
                    ? const ClassroomConnectionPage()
                    : CentralLogin(onContinue: () => Navigator.pop(context)),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            tr('Learning stays on this device', 'अभ्यास या साधनावर जतन होतो'),
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 768;
    void toggleMenu() {
      if (mobile) {
        if (shellKey.currentState?.isDrawerOpen == true) {
          Navigator.pop(context);
        } else {
          shellKey.currentState?.openDrawer();
        }
      } else {
        store.sidebarOpen = !store.sidebarOpen;
        store.save();
      }
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (shellKey.currentState?.isDrawerOpen == true) {
            Navigator.pop(context);
            menuFocus.requestFocus();
          } else if (store.sidebarOpen) {
            store.sidebarOpen = false;
            store.save();
            menuFocus.requestFocus();
          } else {
            fullscreen(false);
          }
        },
        const SingleActivator(LogicalKeyboardKey.f11): () => fullscreen(),
        const SingleActivator(LogicalKeyboardKey.keyB, control: true):
            toggleMenu,
      },
      child: Focus(
        autofocus: true,
        child: PopScope(
          canPop: page == 'home',
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) go('home');
          },
          child: Scaffold(
            key: shellKey,
            drawer: mobile
                ? Drawer(
                    width: min(320, MediaQuery.sizeOf(context).width - 48),
                    child: Focus(
                      autofocus: true,
                      onKeyEvent: (node, event) {
                        if (event is KeyDownEvent &&
                            event.logicalKey == LogicalKeyboardKey.escape) {
                          shellKey.currentState?.closeDrawer();
                          menuFocus.requestFocus();
                          return KeyEventResult.handled;
                        }
                        return KeyEventResult.ignored;
                      },
                      child: navigation(true),
                    ),
                  )
                : null,
            onDrawerChanged: (open) {
              if (!open) menuFocus.requestFocus();
            },
            body: SafeArea(
              child: Row(
                children: [
                  if (!mobile && store.sidebarOpen)
                    SizedBox(
                      width: 232,
                      child: Material(
                        color: store.contrast
                            ? Colors.white
                            : LearningPalette.surface,
                        child: navigation(false),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      children: [
                        ClassroomTopBar(
                          showBack: page != 'home',
                          sidebarOpen: mobile
                              ? (shellKey.currentState?.isDrawerOpen ?? false)
                              : store.sidebarOpen,
                          full: full,
                          menuFocus: menuFocus,
                          onMenu: toggleMenu,
                          onBack: () => go('home'),
                          onFullscreen: () => fullscreen(),
                        ),
                        const ClassroomConnectionStrip(),
                        Expanded(
                          child: TickerMode(
                            enabled: !store.reducedMotion,
                            child: KeyedSubtree(
                              key: ValueKey(page),
                              child: buildPage(),
                            ),
                          ),
                        ),
                      ],
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

  Widget buildPage() => switch (page) {
    'home' => ResponsiveHome(
      onGo: (m) {
        if (m == 'chapters') {
          go('chapters');
          return;
        }
        mode = m;
        go(m == 'practice' ? 'practiceSetup' : 'topics');
      },
      onProgress: () => go('progress'),
      onTeacher: () => teacherGate(),
    ),
    'chapters' => const ChapterDirectoryPage(),
    'topics' => ChapterDirectoryPage(mode: mode),
    'lesson' => StoryLessonPage(
      topic: selected,
      onDone: () => go('topics'),
      onQuiz: () => go('quizSetup'),
      teacher: teacher,
    ),
    'practice' => PracticeSessionPage(initialTopic: selected.id),
    'practiceSetup' => const ChapterDirectoryPage(mode: 'practice'),
    'practiceLab' => const PracticeSessionPage(),
    'quizSetup' => QuizSetup(
      topic: selected,
      onStart: (config) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizPage(topic: selected, config: config),
        ),
      ),
    ),
    'progress' => const ProgressPage(),
    'settings' =>
      central.managed && !teacher
          ? const SizedBox.shrink()
          : SettingsPage(onExit: () => exit(0)),
    'teacher' => TeacherPage(
      onChapters: () => go('chapters'),
      onPractice: () => go('practiceLab'),
      onLesson: (t) {
        fullscreen(true);
        selected = t;
        go('lesson');
      },
      onQuiz: (t) {
        selected = t;
        go('quizSetup');
      },
      onTeam: () => go('teams'),
      onLock: () {
        teacher = false;
        go('home');
      },
    ),
    'teams' => const TeamPage(),
    _ => const SizedBox(),
  };
}

class LogoMark extends StatelessWidget {
  final double size;
  const LogoMark({super.key, this.size = 40});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: green,
      borderRadius: BorderRadius.circular(size * .3),
    ),
    child: Center(
      child: Text(
        'g',
        style: TextStyle(
          fontSize: size * .9,
          height: 1,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFFFD566),
        ),
      ),
    ),
  );
}

class IconText extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const IconText({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 20),
    label: Text(label, style: const TextStyle(fontSize: 12)),
  );
}

class Panel extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsets padding;
  const Panel({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(24),
  });
  @override
  Widget build(BuildContext context) => Material(
    color: color,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: BorderSide(
        color: store.contrast ? ink : const Color(0xFFCBD5E1),
        width: store.contrast ? 2 : 1,
      ),
    ),
    child: Padding(padding: padding, child: child),
  );
}

class Heading extends StatelessWidget {
  final String title, subtitle;
  const Heading(this.title, this.subtitle, {super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 29,
          fontWeight: FontWeight.w900,
          height: 1.35,
          color: ink,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        subtitle,
        style: TextStyle(
          color: const Color(0xFF475569),
          fontSize: store.smartboard ? 18 : 14,
          height: 1.6,
        ),
      ),
    ],
  );
}

class Floaty extends StatefulWidget {
  final Widget child;
  const Floaty({super.key, required this.child});
  @override
  State<Floaty> createState() => _FloatyState();
}

class _FloatyState extends State<Floaty> with SingleTickerProviderStateMixin {
  late final AnimationController a = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: store.slow ? 5000 : 3000),
  )..repeat(reverse: true);
  @override
  void dispose() {
    a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: a,
    child: widget.child,
    builder: (c, child) => Transform.translate(
      offset: Offset(0, sin(a.value * pi) * 7),
      child: child,
    ),
  );
}

class HomePage extends StatelessWidget {
  final ValueChanged<String> onGo;
  final VoidCallback onProgress, onTeacher;
  const HomePage({
    super.key,
    required this.onGo,
    required this.onProgress,
    required this.onTeacher,
  });
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(32, 26, 32, 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE7EEE2),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                tr(
                  '⭐  YOUR MATHS ADVENTURE STARTS HERE',
                  '⭐  तुमची गणित सफर इथून सुरू होते',
                ),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: green,
                ),
              ),
            ),
            const Spacer(),
            Text(
              tr('Made for curious little minds', 'जिज्ञासू छोट्यांसाठी'),
              style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFFE9F1DE),
            borderRadius: BorderRadius.circular(26),
          ),
          child: LayoutBuilder(
            builder: (context, c) => SizedBox(
              height: store.language == 2 ? 420 : 360,
              child: Stack(
                children: [
                  Positioned.fill(child: CustomPaint(painter: MeadowPainter())),
                  Positioned(
                    top: 30,
                    left: 32,
                    right: c.maxWidth * .43,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr(
                            'Hello, little explorer!',
                            'नमस्कार, छोट्या शोधकांनो!',
                          ),
                          style: const TextStyle(
                            color: green,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          store.language == 1
                              ? 'गणिताची\nमजेदार सफर!'
                              : 'Big adventures.\nLittle numbers.',
                          style: TextStyle(
                            fontSize: c.maxWidth > 1000 ? 43 : 35,
                            fontWeight: FontWeight.w900,
                            height: 1.14,
                            letterSpacing: -1.1,
                            color: ink,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          tr(
                            'Count, play and discover the magic of maths.',
                            'मोजा, खेळा आणि गणिताची जादू अनुभवा.',
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.65,
                            color: Color(0xFF668067),
                          ),
                        ),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: () => onGo('learn'),
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 19,
                          ),
                          iconAlignment: IconAlignment.end,
                          label: Text(
                            tr('Let’s explore', 'चला शिकूया'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    top: 0,
                    width: c.maxWidth * .45,
                    child: Floaty(child: CustomPaint(painter: SchoolPainter())),
                  ),
                  Positioned(
                    right: 24,
                    top: 17,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Ganit Safar / गणित सफर',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: green,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Heading(
                tr('Pick your learning path', 'तुमचा शिकण्याचा मार्ग निवडा'),
                tr(
                  'A little learning, a lot of fun. Where shall we go today?',
                  'थोडे शिकूया, खूप मजा करूया. आज कुठे जाऊया?',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E9DF)),
              ),
              child: Text(
                tr(
                  '⭐  ${store.stars} stars earned',
                  '⭐  ${store.stars} तारे मिळवले',
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: ink,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, c) {
            final cards = [
              (
                'learn',
                '📖',
                tr('Learn', 'शिका'),
                tr(
                  'Stories that make maths click.',
                  'गोष्टींमधून गणित समजून घ्या.',
                ),
                const Color(0xFFE9F1E8),
                green,
              ),
              (
                'practice',
                '✏️',
                tr('Practice', 'सराव'),
                tr('Try it, play it, master it.', 'खेळा, सराव करा, शिका.'),
                const Color(0xFFFFF2D9),
                const Color(0xFFAE7B25),
              ),
              (
                'quiz',
                '🧩',
                tr('Quiz time', 'प्रश्नमंजुषा'),
                tr(
                  'A fun little challenge for you.',
                  'तुमच्यासाठी एक मजेदार आव्हान.',
                ),
                const Color(0xFFEDEAF7),
                const Color(0xFF7F68AA),
              ),
            ];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: cards
                  .map(
                    (a) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: a.$1 == 'quiz' ? 0 : 16,
                        ),
                        child: InkWell(
                          onTap: () => onGo(a.$1),
                          borderRadius: BorderRadius.circular(22),
                          child: Panel(
                            color: a.$5,
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 51,
                                      height: 51,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: .7,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Center(
                                        child: Text(
                                          a.$2,
                                          style: const TextStyle(fontSize: 30),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.north_east_rounded,
                                      color: a.$6,
                                      size: 21,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  a.$3,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: ink,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  a.$4,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF748276),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 26),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.route_outlined,
                          color: green,
                          size: 20,
                        ),
                        const SizedBox(width: 9),
                        Flexible(
                          child: Text(
                            tr('Your next discovery', 'तुमचा पुढचा शोध'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          tr('CLASS ${store.grade}', 'इयत्ता ${store.grade}'),
                          style: const TextStyle(
                            fontSize: 10,
                            color: green,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF2D9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            '🥭',
                            style: TextStyle(fontSize: 38),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr(
                                  'Mira’s mango adventure',
                                  'मीराची आंब्यांची गोष्ट',
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                tr(
                                  'Addition • Story + activity • 5 min',
                                  'बेरीज • गोष्ट + कृती • ५ मिनिटे',
                                ),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF8A978C),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: tr('Start learning', 'शिकायला सुरुवात करा'),
                          onPressed: () => onGo('learn'),
                          icon: const Icon(
                            Icons.arrow_circle_right_rounded,
                            size: 36,
                            color: green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: InkWell(
                onTap: onProgress,
                borderRadius: BorderRadius.circular(24),
                child: Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              tr('Growing every day', 'दररोज प्रगती'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Text('🌱', style: TextStyle(fontSize: 25)),
                        ],
                      ),
                      const SizedBox(height: 19),
                      Text(
                        tr(
                          '${store.completed.length} discoveries made',
                          '${store.completed.length} धडे पूर्ण',
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          color: green,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 13),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: min(1, store.completed.length / 56),
                          minHeight: 8,
                          backgroundColor: const Color(0xFFEDF1E8),
                          color: green,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        tr(
                          'Every little step counts.',
                          'प्रत्येक छोटे पाऊल महत्त्वाचे आहे.',
                        ),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF88958A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite, size: 13, color: Color(0xFFB6C3AE)),
            const SizedBox(width: 6),
            Text(
              tr(
                'Learn at your pace. Explore in your language. Always offline.',
                'तुमच्या गतीने शिका. तुमच्या भाषेत शोधा. नेहमी ऑफलाइन.',
              ),
              style: const TextStyle(fontSize: 11, color: Color(0xFF8B9987)),
            ),
          ],
        ),
      ],
    ),
  );
}

class MeadowPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final p = Paint();
    p.color = const Color(0xFFDCE9CC);
    c.drawOval(
      Rect.fromLTWH(s.width * .45, s.height * .67, s.width * .8, s.height * .6),
      p,
    );
    p.color = const Color(0xFFD1E2BA);
    c.drawOval(
      Rect.fromLTWH(s.width * .76, s.height * .8, s.width * .6, s.height * .5),
      p,
    );
    p.color = Colors.white.withValues(alpha: .65);
    for (final o in [Offset(s.width * .56, 58), Offset(s.width * .92, 84)]) {
      c.drawCircle(o, 16, p);
      c.drawCircle(o + const Offset(19, -8), 22, p);
      c.drawCircle(o + const Offset(41, 1), 14, p);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class SchoolPainter extends CustomPainter {
  void txt(
    Canvas c,
    String t,
    Offset o,
    double size,
    Color color, {
    FontWeight weight = FontWeight.w800,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: TextStyle(
          fontSize: size,
          color: color,
          fontWeight: weight,
          fontFamily: 'NotoSans',
          fontFamilyFallback: const ['NotoEmoji', 'NotoDevanagari'],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, o);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = canvas;
    c.save();
    final scale = min(size.width / 400, size.height / 300);
    c.translate(
      (size.width - 400 * scale) / 2,
      (size.height - 300 * scale) / 2 + 8,
    );
    c.scale(scale);
    final p = Paint();
    // Little school, trees, and an owl built from lightweight vector shapes.
    p.color = const Color(0xFFEFD39B);
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(198, 119, 158, 132),
        const Radius.circular(8),
      ),
      p,
    );
    p.color = const Color(0xFFCB8664);
    final roof = Path()
      ..moveTo(180, 125)
      ..lineTo(276, 54)
      ..lineTo(372, 125)
      ..close();
    c.drawPath(roof, p);
    p.color = const Color(0xFF8EAC88);
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(257, 182, 36, 69),
        const Radius.circular(5),
      ),
      p,
    );
    p.color = const Color(0xFFFFF7DC);
    for (double x in [215, 312]) {
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 152, 25, 32),
          const Radius.circular(4),
        ),
        p,
      );
    }
    p.color = Colors.white;
    c.drawRect(const Rect.fromLTWH(242, 122, 72, 18), p);
    txt(c, 'SCHOOL', const Offset(249, 123), 12, green);
    p.color = const Color(0xFFB59669);
    c.drawRect(const Rect.fromLTWH(367, 192, 8, 58), p);
    p.color = const Color(0xFF91B777);
    c.drawOval(const Rect.fromLTWH(340, 135, 65, 80), p);
    // Owl mascot with satchel.
    p.color = const Color(0xFFD8964F);
    c.drawOval(const Rect.fromLTWH(56, 138, 132, 125), p);
    final ears = Path()
      ..moveTo(62, 174)
      ..lineTo(56, 108)
      ..lineTo(103, 142)
      ..lineTo(146, 140)
      ..lineTo(187, 110)
      ..lineTo(182, 180)
      ..close();
    c.drawPath(ears, p);
    p.color = const Color(0xFFF0B869);
    c.drawOval(const Rect.fromLTWH(66, 137, 114, 111), p);
    p.color = const Color(0xFFFFF0CB);
    c.drawOval(const Rect.fromLTWH(71, 149, 52, 65), p);
    c.drawOval(const Rect.fromLTWH(122, 149, 52, 65), p);
    p.color = ink;
    c.drawOval(const Rect.fromLTWH(95, 168, 13, 22), p);
    c.drawOval(const Rect.fromLTWH(136, 168, 13, 22), p);
    p.color = Colors.white;
    c.drawCircle(const Offset(104, 172), 3, p);
    c.drawCircle(const Offset(145, 172), 3, p);
    p.color = const Color(0xFFDB8140);
    c.drawPath(
      Path()
        ..moveTo(115, 195)
        ..lineTo(130, 195)
        ..lineTo(122, 208)
        ..close(),
      p,
    );
    p.color = const Color(0xFFB97A42);
    c.drawOval(const Rect.fromLTWH(47, 195, 28, 52), p);
    c.drawOval(const Rect.fromLTWH(173, 195, 28, 52), p);
    p.color = const Color(0xFFDAA555);
    c.drawOval(const Rect.fromLTWH(82, 252, 30, 12), p);
    c.drawOval(const Rect.fromLTWH(139, 252, 30, 12), p);
    p.color = green;
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(105, 219, 46, 35),
        const Radius.circular(5),
      ),
      p,
    );
    p.color = const Color(0xFFFFDE80);
    c.drawRect(const Rect.fromLTWH(125, 219, 5, 35), p);
    // Friendly floating maths blocks.
    p.color = const Color(0xFFFFE5A8);
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(24, 48, 49, 49),
        const Radius.circular(12),
      ),
      p,
    );
    txt(c, '2', const Offset(38, 50), 33, const Color(0xFFAE7B31));
    p.color = const Color(0xFFEFE8F6);
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(118, 33, 49, 49),
        const Radius.circular(12),
      ),
      p,
    );
    txt(c, '+', const Offset(130, 32), 35, const Color(0xFF9879B2));
    txt(c, '⭐', const Offset(196, 33), 26, const Color(0xFFD3AF52));
    txt(c, '⭐', const Offset(22, 175), 21, const Color(0xFFD3AF52));
    c.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class GradePicker extends StatelessWidget {
  const GradePicker({super.key});
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 12,
    runSpacing: 10,
    children: List.generate(
      4,
      (i) => ChoiceChip(
        showCheckmark: false,
        selected: store.grade == i + 1,
        selectedColor: gradeColors[i].withValues(alpha: .15),
        backgroundColor: Colors.white,
        labelPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        avatar: Text(
          ['🐢', '🐰', '🦊', '🦁'][i],
          style: const TextStyle(fontSize: 23),
        ),
        label: Text(
          tr('Class ${i + 1}', 'इयत्ता ${i + 1}'),
          maxLines: 2,
          style: TextStyle(fontWeight: FontWeight.w800, color: gradeColors[i]),
        ),
        onSelected: (_) {
          store.grade = i + 1;
          store.save();
        },
      ),
    ),
  );
}

class TopicsPage extends StatelessWidget {
  final String mode;
  final ValueChanged<Topic> onOpen;
  const TopicsPage({super.key, required this.mode, required this.onOpen});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Heading(
          tr('A world of little discoveries', 'छोट्या शोधांचे जग'),
          tr(
            'Choose your class, then pick something you’re curious about.',
            'तुमची इयत्ता निवडा. मग आवडीचा विषय निवडा.',
          ),
        ),
        const SizedBox(height: 22),
        const GradePicker(),
        const SizedBox(height: 16),
        Text(classPlans[store.grade - 1].inLanguage(store.language)),
        const SizedBox(height: 12),
        Text(
          tr(
            'Suggested order • Curriculum review pending',
            'सुचवलेला क्रम • अभ्यासक्रम पडताळणी बाकी',
          ),
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 26),
        LayoutBuilder(
          builder: (context, c) {
            final cols = c.maxWidth < 500
                ? 1
                : c.maxWidth > 1050
                ? 4
                : c.maxWidth > 700
                ? 3
                : 2;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children:
                  (List<Topic>.of(topics)..sort(
                        (a, b) => recommendedOrder
                            .indexOf(a.id)
                            .compareTo(recommendedOrder.indexOf(b.id)),
                      ))
                      .map((t) {
                        final done = store.isDone(t.id);
                        final outcome = outcomeFor(store.grade, t.id);
                        return SizedBox(
                          width: (c.maxWidth - (cols - 1) * 16) / cols,
                          child: Panel(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Floaty(
                                      child: Text(
                                        t.icon,
                                        style: const TextStyle(fontSize: 38),
                                      ),
                                    ),

                                    Icon(
                                      done
                                          ? Icons.verified_rounded
                                          : Icons.lock_open_rounded,
                                      size: 20,
                                      color: done
                                          ? green
                                          : const Color(0xFFABBAAC),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  t.name.inLanguage(store.language),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  outcome.objective.inLanguage(store.language),
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  tr(
                                    '1 lesson • 1 quiz • 10+ questions',
                                    '१ धडा • १ प्रश्नमंजुषा • १०+ प्रश्न',
                                  ),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                LinearProgressIndicator(
                                  value: done ? 1 : 0,
                                  color: gradeColors[store.grade - 1],
                                  backgroundColor: cream,
                                  borderRadius: BorderRadius.circular(6),
                                  minHeight: 6,
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${done ? 100 : 0}%',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: green,
                                      ),
                                    ),

                                    TextButton(
                                      onPressed: () => onOpen(t),
                                      child: Text(tr('Start →', 'सुरू करा →')),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      })
                      .toList(),
            );
          },
        ),
      ],
    ),
  );
}

class LessonPage extends StatefulWidget {
  final Topic topic;
  final VoidCallback onDone, onQuiz;
  final bool teacher;
  const LessonPage({
    super.key,
    required this.topic,
    required this.onDone,
    required this.onQuiz,
    this.teacher = false,
  });
  @override
  State<LessonPage> createState() => _LessonState();
}

class _LessonState extends State<LessonPage> {
  int step = 0, replay = 0;
  bool hint = false, showAnswer = false, paused = false;
  final Set<int> counted = {};
  late Question q = makeQuestion(widget.topic.id, store.grade, 0, 'choice');
  Question get activeQuestion =>
      step == 5 ? makeQuestion(widget.topic.id, store.grade, 1, 'choice') : q;
  final stages = [
    const Words('Story', 'गोष्ट'),
    const Words('Discover', 'समजून घ्या'),
    const Words('Watch', 'पाहा'),
    const Words('Your turn', 'तुमची पाळी'),
    const Words('Practise', 'सराव'),
    const Words('Check', 'चाचणी'),
    const Words('Celebrate', 'आनंद साजरा करा'),
  ];
  void next() {
    if (step < 6)
      setState(() {
        step++;
        hint = false;
      });
    if (step == 6) store.complete(widget.topic.id);
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Heading(
                lessonStory(
                  widget.topic.id,
                  grade: store.grade,
                ).inLanguage(store.language),
                tr(
                  'Class ${store.grade} • ${widget.topic.name.en}',
                  'इयत्ता ${store.grade} • ${widget.topic.name.mr}',
                ),
              ),
            ),
            if (widget.teacher)
              Chip(
                avatar: const Icon(Icons.school, size: 16),
                label: Text(tr('Teacher controls', 'शिक्षक नियंत्रणे')),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 9,
          runSpacing: 8,
          children: List.generate(
            7,
            (i) => Chip(
              backgroundColor: i <= step
                  ? const Color(0xFFE3EFDE)
                  : Colors.white,
              label: Text(
                '${i + 1}. ${classUiText(stages[i])}',
                style: TextStyle(
                  fontSize: 11,
                  color: i == step ? green : const Color(0xFF8A978D),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Panel(
          color: const Color(0xFFFFFBF0),
          child: Column(
            children: [
              if (step == 6) ...[
                if (!store.reducedMotion) const Celebration(),
                const SizedBox(height: 20),
                Text(
                  tr('A new discovery!', 'नवा शोध लागला!'),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  tr(
                    'You earned the ${widget.topic.name.en} explorer badge and 3 stars.',
                    'तुम्ही ${widget.topic.name.mr} शोधक पदक आणि ३ तारे मिळवले.',
                  ),
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 12,
                  children: [
                    FilledButton(
                      onPressed: widget.onQuiz,
                      child: Text(tr('Try a quiz', 'प्रश्नमंजुषा सोडवा')),
                    ),
                    OutlinedButton(
                      onPressed: widget.onDone,
                      child: Text(tr('More topics', 'आणखी विषय')),
                    ),
                  ],
                ),
              ] else ...[
                Text(
                  step == 0
                      ? tr(
                          'Meet Mira and her friends. Let’s help them with maths!',
                          'मीरा आणि तिच्या मित्रांना भेटा. त्यांना गणितात मदत करूया!',
                        )
                      : step == 1
                      ? tr(
                          'Look closely. What changes when we work with these objects?',
                          'लक्षपूर्वक पाहा. या वस्तूंवर कृती केल्यावर काय बदलते?',
                        )
                      : step == 3
                      ? tr(
                          'Touch the objects. Explore, count, and try it yourself.',
                          'वस्तूंना स्पर्श करा. पाहा, मोजा आणि स्वतः करून पाहा.',
                        )
                      : step >= 4
                      ? stages[step].inLanguage(store.language)
                      : q.prompt.inLanguage(store.language),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.6,
                  ),
                ),
                if (step == 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      q.prompt.inLanguage(store.language),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, height: 1.6),
                    ),
                  ),
                const SizedBox(height: 22),
                if (step <= 3)
                  VisualBoard(
                    key: ValueKey('$replay:$step'),
                    q: q,
                    topic: widget.topic.id,
                    interactive: step == 3,
                    animate: step == 2 && !paused,
                    onCount: (n) => setState(() => counted.add(n)),
                    paused: paused,
                  ),
                if (step == 1 || hint || showAnswer)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      activeQuestion.explanation.inLanguage(store.language),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        color: green,
                        fontWeight: FontWeight.w700,
                        height: 1.6,
                      ),
                    ),
                  ),
                if (step == 4 || step == 5)
                  QuestionActivity(
                    q: makeQuestion(
                      widget.topic.id,
                      store.grade,
                      step == 4 ? 0 : 1,
                      step == 4 ? 'drag' : 'choice',
                    ),
                    topic: widget.topic.id,
                    onAnswer: (correct) {
                      if (correct) next();
                    },
                    practice: true,
                  ),
                const SizedBox(height: 18),
                if (step == 3)
                  Text(
                    tr(
                      'Objects touched: ${counted.length}',
                      'स्पर्श केलेल्या वस्तू: ${counted.length}',
                    ),
                    style: const TextStyle(
                      color: green,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                if (step == 2 || step == 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: TickerMode(
                      enabled: !paused,
                      child: NumberLine(
                        q: q,
                        topic: widget.topic.id,
                        animate: step == 2,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            OutlinedButton.icon(
              onPressed: step > 0
                  ? () => setState(() => step--)
                  : widget.onDone,
              icon: const Icon(Icons.arrow_back),
              label: Text(tr('Back', 'मागे')),
            ),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  replay++;
                  counted.clear();
                });
              },
              icon: const Icon(Icons.replay),
              label: Text(tr('Replay', 'पुन्हा पाहा')),
            ),
            OutlinedButton.icon(
              onPressed: () => setState(() => hint = !hint),
              icon: const Icon(Icons.lightbulb_outline),
              label: Text(tr('Hint', 'संकेत')),
            ),
            if (widget.teacher) ...[
              OutlinedButton.icon(
                onPressed: () => setState(() => paused = !paused),
                icon: Icon(paused ? Icons.play_arrow : Icons.pause),
                label: Text(
                  paused ? tr('Play', 'चालू करा') : tr('Pause', 'थांबा'),
                ),
              ),
              OutlinedButton(
                onPressed: () => setState(() => showAnswer = !showAnswer),
                child: Text(tr('Show / hide answer', 'उत्तर दाखवा / लपवा')),
              ),
              OutlinedButton(
                onPressed: next,
                child: Text(tr('Skip stage', 'टप्पा वगळा')),
              ),
            ],
            if (step < 4)
              FilledButton.icon(
                onPressed: next,
                icon: const Icon(Icons.arrow_forward),
                iconAlignment: IconAlignment.end,
                label: Text(tr('Next', 'पुढे')),
              ),
            if (step == 4 || step == 5)
              TextButton(
                onPressed: () => setState(() {
                  replay++;
                }),
                child: Text(
                  tr(
                    'Take your time. Try the activity above.',
                    'सावकाश करा. वरील कृती करून पाहा.',
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
  );
}

class VisualBoard extends StatefulWidget {
  final Question q;
  final String topic;
  final bool interactive, animate, paused;
  final ValueChanged<int>? onCount;
  const VisualBoard({
    super.key,
    required this.q,
    required this.topic,
    this.interactive = false,
    this.animate = false,
    this.paused = false,
    this.onCount,
  });
  @override
  State<VisualBoard> createState() => _VisualBoardState();
}

class _VisualBoardState extends State<VisualBoard>
    with SingleTickerProviderStateMixin {
  final Set<int> touched = {};
  int hand = 3;
  late List<int> baskets;
  late final AnimationController anim = AnimationController(
    vsync: this,
    duration: Duration(
      milliseconds: ((store.slow ? 5000 : 2400) / store.speed).round(),
    ),
  );
  @override
  void initState() {
    super.initState();
    hand = widget.q.a;
    baskets = List.filled(
      widget.topic == 'multiply' ? widget.q.a : max(1, widget.q.b),
      0,
    );
    if (widget.animate && !store.reducedMotion)
      anim.forward();
    else
      anim.value = 1;
  }

  @override
  void didUpdateWidget(VisualBoard old) {
    super.didUpdateWidget(old);
    if (widget.paused) {
      anim.stop();
    } else if (widget.animate && !store.reducedMotion && anim.value < 1) {
      anim.forward();
    }
  }

  @override
  void dispose() {
    anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.q;
    if (widget.topic == 'time')
      return Column(
        children: [
          SizedBox(
            width: 205,
            height: 205,
            child: GestureDetector(
              onPanUpdate: widget.interactive
                  ? (d) {
                      final local = d.localPosition;
                      final angle = atan2(local.dx - 102.5, -(local.dy - 102));
                      setState(
                        () => hand =
                            (((angle / (2 * pi) * 12).round() + 11) % 12) + 1,
                      );
                    }
                  : null,
              child: CustomPaint(painter: ClockPainter(hand)),
            ),
          ),
          if (widget.interactive)
            Wrap(
              spacing: 12,
              children: [
                IconButton(
                  tooltip: tr('Previous hour', 'मागचा तास'),
                  onPressed: () => setState(() => hand = (hand + 10) % 12 + 1),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$hand:00', style: const TextStyle(fontSize: 24)),
                IconButton(
                  tooltip: tr('Next hour', 'पुढचा तास'),
                  onPressed: () => setState(() => hand = hand % 12 + 1),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
        ],
      );
    if (widget.topic == 'fraction')
      return Column(
        children: [
          Wrap(
            spacing: 8,
            children: List.generate(
              q.b,
              (i) => GestureDetector(
                onTap: widget.interactive
                    ? () => setState(() {
                        touched.contains(i)
                            ? touched.remove(i)
                            : touched.add(i);
                      })
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 75,
                  height: 95,
                  decoration: BoxDecoration(
                    color: (widget.interactive ? touched.contains(i) : i < q.a)
                        ? const Color(0xFFF2B64D)
                        : const Color(0xFFFFF0CA),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    border: Border.all(color: orange, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      (widget.interactive ? touched.contains(i) : i < q.a)
                          ? '🍅'
                          : '',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            tr(
              '${widget.interactive ? touched.length : q.a} / ${q.b} slices coloured',
              '${widget.interactive ? touched.length : q.a} / ${q.b} भाग रंगवले',
            ),
            style: const TextStyle(fontSize: 21, color: green),
          ),
        ],
      );
    if (widget.topic == 'shape')
      return Column(
        children: [
          Text(q.icon, style: const TextStyle(fontSize: 110)),
          if (widget.interactive)
            Wrap(
              spacing: 10,
              children: List.generate(
                4,
                (i) => Draggable<int>(
                  data: i,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Container(width: 80, height: 12, color: green),
                  ),
                  child: Container(
                    width: 65,
                    height: 16,
                    color: gradeColors[i],
                  ),
                ),
              ),
            ),
          if (widget.interactive)
            DragTarget<int>(
              onAcceptWithDetails: (d) => setState(() => touched.add(d.data)),
              builder: (ctx, c, r) => Container(
                margin: const EdgeInsets.only(top: 12),
                height: 85,
                width: 220,
                decoration: BoxDecoration(
                  border: Border.all(color: green),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    tr(
                      'Build here: ${touched.length} sides',
                      'इथे बांधा: ${touched.length} बाजू',
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    if (widget.topic == 'measure')
      return Column(
        children: [
          SizedBox(
            width: 330,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: q.a * 30.0,
                height: 25,
                decoration: BoxDecoration(
                  color: orange,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text('✏️'),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 330,
            padding: const EdgeInsets.all(8),
            color: const Color(0xFFF1D49A),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                11,
                (i) => Text('|\n$i', textAlign: TextAlign.center),
              ),
            ),
          ),
          const Text('cm / सेमी'),
        ],
      );
    if (widget.topic == 'money')
      return Wrap(
        spacing: 24,
        children: [q.a, q.b]
            .map(
              (v) => Container(
                width: 95,
                height: 95,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFDA78),
                  border: Border.all(color: const Color(0xFFC6962D), width: 5),
                ),
                child: Center(
                  child: Text(
                    '₹$v',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      );
    if (widget.topic == 'data')
      return Column(
        children: [
          for (final row in [('🐄', q.a), ('🐐', q.b)])
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(row.$1, style: const TextStyle(fontSize: 35)),
                  const SizedBox(width: 10),
                  Container(height: 32, width: row.$2 * 28.0, color: green),
                  const SizedBox(width: 8),
                  Text('${row.$2}'),
                ],
              ),
            ),
        ],
      );
    if (widget.topic == 'place')
      return Column(
        children: [
          Text(
            '${q.a}',
            style: const TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.w900,
              color: green,
            ),
          ),
          Text(
            tr(
              '${q.a ~/ 10} bundles of ten + ${q.a % 10} single pencils',
              'दहाच्या ${q.a ~/ 10} जुड्या + ${q.a % 10} सुट्या पेन्सिली',
            ),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            children: List.generate(
              q.a ~/ 10,
              (i) => const Text('📦', style: TextStyle(fontSize: 40)),
            ),
          ),
        ],
      );
    if (widget.topic == 'pattern')
      return Wrap(
        spacing: 10,
        children: List.generate(
          4,
          (i) => Container(
            width: 76,
            height: 76,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: gradeColors[i].withValues(alpha: .15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              i == 3 ? '?' : '${q.a + i * q.b}',
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      );
    if ((widget.topic == 'multiply' || widget.topic == 'divide') &&
        !widget.interactive) {
      final groups = widget.topic == 'multiply' ? q.a : q.b;
      final perGroup = widget.topic == 'multiply' ? q.b : q.answer;
      return AnimatedBuilder(
        animation: anim,
        builder: (context, _) => Wrap(
          spacing: 14,
          runSpacing: 14,
          alignment: WrapAlignment.center,
          children: List.generate(
            groups,
            (g) => Opacity(
              opacity: widget.animate
                  ? (anim.value * groups - g).clamp(0.0, 1.0)
                  : 1,
              child: Container(
                width: 170,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0DE),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: green.withValues(alpha: .3)),
                ),
                child: Column(
                  children: [
                    Text(
                      tr('Group ${g + 1}', 'गट ${g + 1}'),
                      style: const TextStyle(
                        color: green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      children: List.generate(
                        perGroup,
                        (i) => Text(
                          widget.topic == 'divide' ? '📚' : '🌻',
                          style: const TextStyle(fontSize: 25),
                        ),
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
    final n = widget.topic == 'subtract'
        ? q.a
        : widget.topic == 'count'
        ? q.a
        : widget.topic == 'multiply'
        ? q.a * q.b
        : widget.topic == 'divide'
        ? q.a
        : widget.topic == 'shape'
        ? 1
        : q.a + q.b;
    final total = min(36, n);
    return Column(
      children: [
        if (n > 36)
          Text(
            tr(
              'Showing 36 of $n objects',
              'एकूण $n पैकी ३६ वस्तू दाखवल्या आहेत',
            ),
          ),
        AnimatedBuilder(
          animation: anim,
          builder: (ctx, _) => Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: List.generate(total, (i) {
              final removed = widget.topic == 'subtract' && i >= q.answer;
              return Transform.translate(
                offset: Offset(i >= q.a ? (1 - anim.value) * 70 : 0, 0),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: removed ? 1 - anim.value * .8 : 1,
                  child: GestureDetector(
                    onTap: () {
                      if (widget.interactive) {
                        setState(() => touched.add(i));
                        widget.onCount?.call(i);
                      }
                    },
                    child: Container(
                      width: store.smartboard ? 72 : 58,
                      height: store.smartboard ? 72 : 58,
                      decoration: BoxDecoration(
                        color: touched.contains(i)
                            ? const Color(0xFFD8EDCC)
                            : Colors.white.withValues(alpha: .65),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: touched.contains(i)
                              ? green
                              : const Color(0xFFE8E6D9),
                          width: touched.contains(i) ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          touched.contains(i)
                              ? '${touched.toList().indexOf(i) + 1}'
                              : widget.topic == 'word'
                              ? '🧒'
                              : q.icon,
                          style: const TextStyle(fontSize: 31),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        if (widget.interactive &&
            (widget.topic == 'divide' || widget.topic == 'multiply')) ...[
          const SizedBox(height: 16),
          Text(
            tr('Drag the book into an equal group.', 'पुस्तक समान गटात ओढा.'),
          ),
          Draggable<int>(
            data: 1,
            feedback: const Material(
              color: Colors.transparent,
              child: Text('📚', style: TextStyle(fontSize: 40)),
            ),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text('📚', style: TextStyle(fontSize: 36)),
            ),
          ),
          Wrap(
            spacing: 12,
            children: List.generate(
              baskets.length,
              (i) => DragTarget<int>(
                onAcceptWithDetails: (_) => setState(() => baskets[i]++),
                builder: (c, a, r) => Container(
                  width: 100,
                  height: 75,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3EFDE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '🧺 ${baskets[i]}',
                    style: const TextStyle(fontSize: 25),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class ClockPainter extends CustomPainter {
  final int hour;
  ClockPainter(this.hour);
  @override
  void paint(Canvas c, Size s) {
    final center = Offset(s.width / 2, s.height / 2);
    final p = Paint()..color = Colors.white;
    c.drawCircle(center, 98, p);
    p
      ..color = green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    c.drawCircle(center, 98, p);
    for (var i = 1; i <= 12; i++) {
      final angle = i * pi / 6 - pi / 2;
      final tp = TextPainter(
        text: TextSpan(
          text: '$i',
          style: const TextStyle(
            fontSize: 18,
            color: ink,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        c,
        center +
            Offset(
              cos(angle) * 76 - tp.width / 2,
              sin(angle) * 76 - tp.height / 2,
            ),
      );
    }
    p
      ..strokeCap = StrokeCap.round
      ..color = ink
      ..strokeWidth = 6;
    c.drawLine(center, center + const Offset(0, -56), p);
    p.color = orange;
    c.drawLine(
      center,
      center + Offset(sin(hour * pi / 6) * 43, -cos(hour * pi / 6) * 43),
      p,
    );
    p.style = PaintingStyle.fill;
    c.drawCircle(center, 6, p);
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) => oldDelegate.hour != hour;
}

class NumberLine extends StatelessWidget {
  final Question q;
  final String topic;
  final bool animate;
  const NumberLine({
    super.key,
    required this.q,
    required this.topic,
    this.animate = false,
  });
  @override
  Widget build(BuildContext context) {
    final maxN = max(q.answer, q.a);
    final stride = max(1, (maxN / 12).ceil());
    final ticks = {
      0,
      for (int n = 0; n <= maxN; n += stride) n,
      q.a,
      q.answer,
    }.toList()..sort();
    return TweenAnimationBuilder<double>(
      key: ValueKey(animate),
      tween: Tween(begin: animate && !store.reducedMotion ? 0 : 1, end: 1),
      duration: Duration(
        milliseconds: store.reducedMotion
            ? 0
            : ((store.slow ? 5000 : 2500) / store.speed).round(),
      ),
      builder: (ctx, v, _) => Column(
        children: [
          Text(
            tr('Follow the number line', 'संख्यारेषेवर पाहा'),
            style: const TextStyle(fontSize: 13, color: green),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 3,
            children: List.generate(ticks.length, (index) {
              final i = ticks[index];
              return Container(
                width: 30,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      i ==
                          ((topic == 'add' || topic == 'subtract')
                                  ? q.a + (q.answer - q.a) * v
                                  : q.answer * v)
                              .round()
                      ? orange
                      : Colors.white,
                  border: const Border(
                    bottom: BorderSide(color: green, width: 2),
                  ),
                ),
                child: Text(
                  '$i',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class QuestionActivity extends StatefulWidget {
  final Question q;
  final String topic;
  final ValueChanged<bool> onAnswer;
  final bool practice;
  const QuestionActivity({
    super.key,
    required this.q,
    required this.topic,
    required this.onAnswer,
    this.practice = false,
  });
  @override
  State<QuestionActivity> createState() => _QuestionActivityState();
}

class _QuestionActivityState extends State<QuestionActivity> {
  bool? correct;
  bool solution = false;
  int? chosen;
  final input = TextEditingController();
  List<int> arranged = [];
  int? pair;
  Set<int> matched = {};
  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(QuestionActivity old) {
    super.didUpdateWidget(old);
    if (old.q.prompt.en != widget.q.prompt.en || old.q.type != widget.q.type) {
      correct = null;
      solution = false;
      chosen = null;
      arranged = [];
      matched = {};
      pair = null;
      input.clear();
    }
  }

  void answer(int n) {
    if (correct == true) return;
    setState(() {
      chosen = n;
      correct = n == widget.q.answer;
    });
    if (correct == true && store.sound) SystemSound.play(SystemSoundType.click);
    if (!widget.practice || correct == true) widget.onAnswer(correct!);
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.q;
    if (q.metadata != null && !validateQuestion(q).valid)
      return Text(
        tr(
          'Choose another question type for this example.',
          'या उदाहरणासाठी दुसरा प्रश्न प्रकार निवडा.',
        ),
      );
    return Column(
      children: [
        Text(
          (q.type == 'order'
              ? tr(
                  'Arrange these numbers from smallest to largest.',
                  'या संख्या लहान ते मोठ्या क्रमाने लावा.',
                )
              : q.type == 'match'
              ? tr(
                  'Match each number to the same number of dots.',
                  'प्रत्येक संख्या तितक्याच ठिपक्यांशी जुळवा.',
                )
              : q.prompt.inLanguage(store.language)),
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 22),
        if (![
              'numberline',
              'model',
              'clock',
              'coins',
              'colour',
              'graph',
              'construct',
            ].contains(q.type) &&
            q.type != 'custom' &&
            (q.type == 'count' ||
                widget.topic == 'count' ||
                q.type == 'story' ||
                widget.topic == 'time' ||
                widget.topic == 'shape' ||
                widget.topic == 'data' ||
                widget.topic == 'fraction' ||
                widget.topic == 'measure' ||
                widget.topic == 'money')) ...[
          FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: 360,
              child: VisualBoard(
                q: q,
                topic: widget.topic,
                interactive: q.type == 'count' || widget.topic == 'fraction',
              ),
            ),
          ),
          const SizedBox(height: 22),
        ],
        if ([
          'numberline',
          'model',
          'clock',
          'coins',
          'colour',
          'graph',
          'construct',
        ].contains(q.type))
          RichInteraction(
            key: ValueKey('${q.metadata?.seed}:${q.type}'),
            q: q,
            topic: widget.topic,
            onAnswer: answer,
          )
        else if (q.type == 'fill')
          SizedBox(
            width: min(320, MediaQuery.sizeOf(context).width - 72),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: input,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: tr('Your number', 'तुमची संख्या'),
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (v) {
                      final n = int.tryParse(v);
                      if (n != null) answer(n);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () {
                    final n = int.tryParse(input.text);
                    if (n != null) answer(n);
                  },
                  child: Semantics(
                    label: tr('Check answer', 'उत्तर तपासा'),
                    child: const Icon(Icons.check),
                  ),
                ),
              ],
            ),
          )
        else if (q.type == 'truefalse') ...[
          Text(
            tr(
              'Is the answer ${q.answer + (q.a.isEven ? 1 : 0)}?',
              'उत्तर ${q.answer + (q.a.isEven ? 1 : 0)} आहे का?',
            ),
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 16,
            children: [
              FilledButton(
                onPressed: () => answer(q.a.isEven ? q.answer + 1 : q.answer),
                child: Text(tr('True', 'बरोबर')),
              ),
              OutlinedButton(
                onPressed: () => answer(q.a.isEven ? q.answer : q.answer + 1),
                child: Text(tr('False', 'चूक')),
              ),
            ],
          ),
        ] else if (q.type == 'order') ...[
          Text(
            tr(
              'Tap these numbers from smallest to largest.',
              'लहान ते मोठ्या क्रमाने या संख्यांवर टॅप करा.',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: q.options
                .map(
                  (n) => OutlinedButton(
                    onPressed: arranged.contains(n)
                        ? null
                        : () {
                            setState(() => arranged.add(n));
                            if (arranged.length == q.options.length) {
                              final sorted = List<int>.of(q.options)..sort();
                              answer(
                                listEquals(sorted, arranged)
                                    ? q.answer
                                    : q.answer + 1,
                              );
                            }
                          },
                    child: Text('$n', style: const TextStyle(fontSize: 25)),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Text(
            arranged.join(' → '),
            style: const TextStyle(fontSize: 24, color: green),
          ),
          TextButton(
            onPressed: () => setState(() => arranged = []),
            child: Text(tr('Rearrange', 'पुन्हा क्रम लावा')),
          ),
        ] else if (q.type == 'match') ...[
          Text(
            tr(
              'Select a number, then its matching dots.',
              'संख्या निवडा, मग तितक्याच ठिपक्यांशी जुळवा.',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: List.generate(
              3,
              (i) => OutlinedButton(
                onPressed: matched.contains(i + 1)
                    ? null
                    : () => setState(() => pair = i + 1),
                style: OutlinedButton.styleFrom(
                  backgroundColor: pair == i + 1
                      ? const Color(0xFFD8EDCC)
                      : null,
                ),
                child: Text('${i + 1}', style: const TextStyle(fontSize: 25)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [3, 1, 2]
                .map(
                  (n) => OutlinedButton(
                    onPressed: matched.contains(n)
                        ? null
                        : () {
                            if (pair == n) {
                              setState(() {
                                matched.add(n);
                                pair = null;
                              });
                              if (matched.length == 3) answer(q.answer);
                            } else {
                              setState(() => correct = false);
                            }
                          },
                    child: Text(
                      List.filled(n, '●').join(' '),
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                )
                .toList(),
          ),
        ] else if (q.type == 'drag') ...[
          DragTarget<int>(
            onAcceptWithDetails: (d) => answer(d.data),
            builder: (ctx, c, r) => Container(
              width: 230,
              height: 95,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.isNotEmpty ? const Color(0xFFD7EBCF) : cream,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: green, width: 2),
              ),
              child: Text(
                chosen == null
                    ? tr('Drop answer here', 'उत्तर इथे सोडा')
                    : '$chosen',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 14,
            runSpacing: 10,
            children: q.options
                .map(
                  (n) => Draggable<int>(
                    data: n,
                    feedback: Material(
                      borderRadius: BorderRadius.circular(15),
                      color: orange,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text('$n', style: const TextStyle(fontSize: 26)),
                      ),
                    ),
                    child: OutlinedButton(
                      onPressed: () => answer(n),
                      child: Text('$n', style: const TextStyle(fontSize: 26)),
                    ),
                  ),
                )
                .toList(),
          ),
          Text(
            tr('Drag, or tap an answer.', 'उत्तर ओढा किंवा टॅप करा.'),
            style: const TextStyle(fontSize: 12),
          ),
        ] else
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: q.options
                .map(
                  (n) => SizedBox(
                    width: 130,
                    child: OutlinedButton(
                      onPressed: correct == true ? null : () => answer(n),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: chosen == n
                            ? (correct == true
                                  ? const Color(0xFFDCEFD3)
                                  : const Color(0xFFFFECC8))
                            : Colors.white,
                        padding: const EdgeInsets.all(23),
                      ),
                      child: Text(
                        '$n',
                        style: const TextStyle(
                          fontSize: 29,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        if (correct != null)
          AnswerFeedback(
            correct: correct!,
            playSound: false,
            explanation: correct == true
                ? tr('⭐ Wonderful work, explorer!', '⭐ शाब्बास, छोट्या शोधका!')
                : '${tr('🌱 A good try! Let’s look together.', '🌱 छान प्रयत्न! आपण मिळून पाहूया.')}\n${q.explanation.inLanguage(store.language)}',
          ),
        if (widget.practice) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              TextButton.icon(
                onPressed: () => setState(() => solution = !solution),
                icon: const Icon(Icons.lightbulb_outline),
                label: Text(tr('Hint / step-by-step', 'संकेत / पायरीपायरीने')),
              ),
              if (correct == false)
                TextButton(
                  onPressed: () => setState(() {
                    correct = null;
                    chosen = null;
                    arranged = [];
                    matched = {};
                    input.clear();
                  }),
                  child: Text(tr('Try again', 'पुन्हा प्रयत्न करा')),
                ),
            ],
          ),
          if (solution)
            Panel(
              color: cream,
              child: Column(
                children: [
                  Text(
                    tr(
                      '1. Read the story.  2. Count or group the objects.  3. Check your number.',
                      '१. गोष्ट वाचा.  २. वस्तू मोजा किंवा गट करा.  ३. उत्तर तपासा.',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    q.explanation.inLanguage(store.language),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: green,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class PracticePage extends StatefulWidget {
  final Topic topic;
  const PracticePage({super.key, required this.topic});
  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  int index = 0, earned = 0;
  String type = 'count';
  bool solved = false;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Heading(
          tr('Play, practise, discover', 'खेळा, सराव करा, शोधा'),
          widget.topic.name.inLanguage(store.language),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: questionTypes
              .map(
                (t) => ChoiceChip(
                  label: Text(classUiText(typeNames[t]!)),
                  selected: type == t,
                  onSelected: (_) => setState(() {
                    type = t;
                    index++;
                    solved = false;
                  }),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
        Panel(
          child: QuestionActivity(
            key: ValueKey('$index:$type'),
            q: makeQuestion(widget.topic.id, store.grade, index, type),
            topic: widget.topic.id,
            practice: true,
            onAnswer: (correct) {
              if (correct && !solved) {
                solved = true;
                earned++;
                store.stars++;
                store.save();
                setState(() {});
              }
            },
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Text(
              tr(
                '⭐ $earned discoveries this session',
                '⭐ या सरावात $earned बरोबर उत्तरे',
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => setState(() {
                index++;
                solved = false;
              }),
              icon: const Icon(Icons.arrow_forward),
              label: Text(tr('Next activity', 'पुढची कृती')),
            ),
          ],
        ),
      ],
    ),
  );
}

class QuizSetup extends StatefulWidget {
  final Topic topic;
  final ValueChanged<Map<String, dynamic>> onStart;
  const QuizSetup({super.key, required this.topic, required this.onStart});
  @override
  State<QuizSetup> createState() => _QuizSetupState();
}

class _QuizSetupState extends State<QuizSetup> {
  int count = 10, difficulty = 1, seconds = 0;
  bool random = true, showOptions = true;
  Set<String> types = {'choice', 'count', 'fill'};
  @override
  void initState() {
    super.initState();
    final saved = store.quizSettings;
    count = [5, 10, 15, 20, 30, 50].contains(saved['count'])
        ? saved['count']
        : 10;
    difficulty = [1, 2, 3].contains(saved['difficulty'])
        ? saved['difficulty']
        : 1;
    seconds = [0, 30, 60, 120].contains(saved['seconds'])
        ? saved['seconds']
        : 0;
    random = saved['random'] != false;
    showOptions = saved['showOptions'] != false;
    final selected = List<String>.from(
      saved['types'] ?? types,
    ).where(questionTypes.contains).toSet();
    if (selected.isNotEmpty) types = selected;
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Heading(
          tr('A challenge of your own', 'तुमची स्वतःची प्रश्नमंजुषा'),
          widget.topic.name.inLanguage(store.language),
        ),
        const SizedBox(height: 20),
        const GradePicker(),
        const SizedBox(height: 20),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('Make it just right', 'तुमच्या आवडीनुसार निवडा'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 24,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 220,
                    child: DropdownButtonFormField<int>(
                      itemHeight: store.smartboard ? 72 : 56,
                      isExpanded: true,
                      initialValue: count,
                      decoration: InputDecoration(
                        labelText: tr('Questions', 'प्रश्न'),
                      ),
                      items: [5, 10, 15, 20, 30, 50]
                          .map(
                            (n) =>
                                DropdownMenuItem(value: n, child: Text('$n')),
                          )
                          .toList(),
                      onChanged: (n) => setState(() => count = n!),
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: DropdownButtonFormField<int>(
                      itemHeight: store.smartboard ? 72 : 56,
                      isExpanded: true,
                      initialValue: difficulty,
                      decoration: InputDecoration(
                        labelText: tr('Difficulty', 'कठीणपणा'),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 1,
                          child: Text(tr('Gentle', 'सोपे')),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text(tr('A little challenge', 'थोडे आव्हान')),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text(tr('Explorer', 'शोधक')),
                        ),
                      ],
                      onChanged: (n) => setState(() => difficulty = n!),
                    ),
                  ),
                  SizedBox(
                    width: 240,
                    child: DropdownButtonFormField<int>(
                      itemHeight: store.smartboard ? 72 : 56,
                      isExpanded: true,
                      initialValue: seconds,
                      decoration: InputDecoration(
                        labelText: tr(
                          'Time per question',
                          'प्रत्येक प्रश्नाची वेळ',
                        ),
                      ),
                      items: [0, 30, 60, 120]
                          .map(
                            (n) => DropdownMenuItem(
                              value: n,
                              child: Text(
                                n == 0
                                    ? tr('No timer', 'वेळेची मर्यादा नाही')
                                    : tr('$n seconds', '$n सेकंद'),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (n) => setState(() => seconds = n!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                tr('Question types', 'प्रश्नांचे प्रकार'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: questionTypes
                    .where((t) => supportsType(widget.topic.id, t))
                    .map(
                      (t) => FilterChip(
                        label: Text(classUiText(typeNames[t]!)),
                        selected: types.contains(t),
                        onSelected: (v) => setState(() {
                          if (v) {
                            types.add(t);
                          } else if (types.length > 1) {
                            types.remove(t);
                          }
                        }),
                      ),
                    )
                    .toList(),
              ),
              SwitchListTile(
                title: Text(tr('Show answer options', 'उत्तराचे पर्याय दाखवा')),
                value: showOptions,
                onChanged: (v) => setState(() => showOptions = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  tr('Random question order', 'प्रश्नांचा यादृच्छिक क्रम'),
                ),
                subtitle: Text(
                  tr(
                    'Turn off for a repeatable classroom quiz.',
                    'वर्गात तेच प्रश्न घेण्यासाठी बंद करा.',
                  ),
                ),
                value: random,
                onChanged: (v) => setState(() => random = v),
              ),
              const SizedBox(height: 15),
              FilledButton.icon(
                onPressed: () {
                  store.quizSettings = {
                    'count': count,
                    'difficulty': difficulty,
                    'seconds': seconds,
                    'random': random,
                    'showOptions': showOptions,
                    'types': types.toList(),
                  };
                  store.save();
                  widget.onStart({
                    'count': count,
                    'difficulty': difficulty,
                    'seconds': seconds,
                    'random': random,
                    'showOptions': showOptions,
                    'types': types.toList(),
                  });
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(tr('Start the adventure', 'प्रश्नमंजुषा सुरू करा')),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class QuizPage extends StatefulWidget {
  final Topic topic;
  final Map<String, dynamic> config;
  const QuizPage({super.key, required this.topic, required this.config});
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late List<Question> questions;
  int current = 0, score = 0, remaining = 0;
  bool answered = false, finished = false, review = false;
  Timer? timer;
  ClassroomActivity? monitoring;
  final Stopwatch sessionClock = Stopwatch();
  List<Map<String, dynamic>> mistakes = [];
  String generationError = '';
  @override
  void initState() {
    super.initState();
    buildQuestions();
  }

  void buildQuestions() {
    sessionClock
      ..reset()
      ..start();
    final types = List<String>.from(widget.config['types'] ?? ['choice']);
    final count = widget.config['count'] as int? ?? 10;
    final custom = widget.config['questions'] as List?;
    try {
      questions = custom != null
          ? custom.map((q) {
              final answer = (q['answer'] as num).toInt();
              final text = normalizeCustomQuestion(
                Map<String, dynamic>.from(q),
              );
              return Question(
                Words.fromJson(Map<String, dynamic>.from(text['prompt'])),
                Words.fromJson(Map<String, dynamic>.from(text['explanation'])),
                answer,
                3,
                2,
                [answer, answer + 1, answer + 2, answer + 3]..shuffle(),
                'custom',
                widget.topic.icon,
                metadata: GenerationMetadata(
                  templateId: 'teacher-custom-v2',
                  outcomeId: 'mh-g${store.grade}-${widget.topic.id}-v1',
                  topic: widget.topic.id,
                  skill: 'custom',
                  source: 'Teacher-authored local content',
                  grade: store.grade,
                  difficulty: 1,
                  seed: 0,
                  reviewStatus: 'Teacher review required',
                ),
              );
            }).toList()
          : generateQuestions(
              topicIds: [widget.topic.id],
              grade: store.grade,
              count: count,
              types: types,
              difficulty: widget.config['difficulty'] as int? ?? 1,
              random: widget.config['random'] == true,
              showOptions: widget.config['showOptions'] != false,
            );
      if (questions.any((q) => !validateQuestion(q).valid))
        throw StateError('Question validation failed');
    } catch (e) {
      questions = [];
      generationError = e.toString();
      return;
    }
    central.leaveActivity(monitoring);
    monitoring = central.beginActivity('quiz', store.grade, widget.topic.id);
    startTimer();
  }

  void startTimer() {
    timer?.cancel();
    remaining = widget.config['seconds'] as int? ?? 0;
    if (remaining > 0)
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || answered || finished) return;
        setState(() => remaining--);
        if (remaining <= 0) submit(false);
      });
  }

  void submit(bool correct) {
    if (answered) return;
    timer?.cancel();
    setState(() {
      answered = true;
      if (correct) {
        score++;
      } else {
        final q = questions[current];
        mistakes.add({
          'en': q.prompt.en,
          'mr': q.prompt.mr,
          'answer': q.answer,
          'hintEn': q.explanation.en,
          'hintMr': q.explanation.mr,
        });
      }
    });
  }

  void next() {
    if (current + 1 == questions.length) {
      sessionClock.stop();
      central.completeActivity(monitoring);
      setState(() => finished = true);
    } else {
      setState(() {
        current++;
        answered = false;
      });
      startTimer();
    }
  }

  @override
  void dispose() {
    central.leaveActivity(monitoring);
    timer?.cancel();
    sessionClock.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => generationError.isNotEmpty
        ? Scaffold(
            appBar: AppBar(
              title: Text(tr('Adjust your quiz', 'प्रश्नमंजुषा बदला')),
            ),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                tr(
                  'This selection does not have enough distinct questions. Choose fewer questions or add question types.',
                  'या निवडीत पुरेसे वेगळे प्रश्न नाहीत. प्रश्न कमी करा किंवा प्रश्नांचे प्रकार वाढवा.',
                ),
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(widget.topic.name.inLanguage(store.language)),
              actions: [
                DropdownButton<int>(
                  itemHeight: store.smartboard ? 72 : 56,
                  value: store.language,
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('English')),
                    DropdownMenuItem(value: 1, child: Text('मराठी')),
                    DropdownMenuItem(value: 2, child: Text('English + मराठी')),
                  ],
                  onChanged: (n) {
                    store.language = n!;
                    store.save();
                  },
                ),
                const SizedBox(width: 20),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: finished
                      ? result()
                      : Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  tr(
                                    'Question ${current + 1} of ${questions.length}',
                                    'प्रश्न ${current + 1} / ${questions.length}',
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const Spacer(),
                                Text('⭐ $score'),
                                const SizedBox(width: 20),
                                if ((widget.config['seconds'] ?? 0) > 0)
                                  Text(
                                    '⏱ $remaining s',
                                    style: const TextStyle(
                                      color: green,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: current / questions.length,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            const SizedBox(height: 24),
                            Panel(
                              child: AbsorbPointer(
                                absorbing: answered,
                                child: QuestionActivity(
                                  key: ValueKey(current),
                                  q: questions[current],
                                  topic: widget.topic.id,
                                  onAnswer: submit,
                                ),
                              ),
                            ),
                            if (answered) ...[
                              const SizedBox(height: 18),
                              if (remaining == 0 &&
                                  (widget.config['seconds'] ?? 0) > 0)
                                Text(
                                  tr(
                                    'Time to explore the answer.',
                                    'आता उत्तर समजून घेऊया.',
                                  ),
                                ),
                              FilledButton.icon(
                                onPressed: next,
                                icon: const Icon(Icons.arrow_forward),
                                label: Text(
                                  current + 1 == questions.length
                                      ? tr(
                                          'See my discoveries',
                                          'माझे गुण पाहा',
                                        )
                                      : tr('Next question', 'पुढचा प्रश्न'),
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
              ),
            ),
          ),
  );
  Widget result() => Panel(
    child: Column(
      children: [
        Text(
          tr('Current Session Result', 'सध्याच्या सत्राचा निकाल'),
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
        ),
        Text(
          '${tr('Class', 'इयत्ता')} ${store.grade} • ${widget.topic.name.inLanguage(store.language)}',
        ),
        Text(
          tr(
            'This result lasts until you leave this quiz.',
            'या प्रश्नमंजुषेतून बाहेर पडेपर्यंतच हा निकाल दिसेल.',
          ),
        ),
        if (!store.reducedMotion) const Celebration(),
        const SizedBox(height: 18),
        Text(
          tr('Every try helps you grow!', 'प्रत्येक प्रयत्नाने तुम्ही शिकता!'),
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 15),
        Text(
          '$score / ${questions.length}',
          style: const TextStyle(
            fontSize: 60,
            color: green,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          tr(
            '$score correct • ${mistakes.length} to explore again • $score stars earned',
            '$score बरोबर • ${mistakes.length} पुन्हा समजून घ्या • $score तारे मिळवले',
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          tr(
            '${questions.length} answered • ${(score / questions.length * 100).round()}% accuracy',
            '${questions.length} उत्तरे दिली • ${(score / questions.length * 100).round()}% अचूकता',
          ),
        ),
        if ((widget.config['seconds'] as int? ?? 0) > 0)
          Text(
            tr(
              'Time used: ${sessionClock.elapsed.inSeconds}s',
              'लागलेला वेळ: ${sessionClock.elapsed.inSeconds} सेकंद',
            ),
          ),
        const SizedBox(height: 20),
        if (mistakes.isNotEmpty)
          Text(
            tr(
              'Revision topic: ${widget.topic.name.en}',
              'पुनरावृत्ती: ${widget.topic.name.mr}',
            ),
            style: const TextStyle(fontWeight: FontWeight.bold, color: green),
          ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            FilledButton(
              onPressed: () => setState(() {
                current = 0;
                score = 0;
                mistakes = [];
                finished = false;
                answered = false;
                review = false;
                buildQuestions();
              }),
              child: Text(tr('Try again', 'पुन्हा प्रयत्न करा')),
            ),
            OutlinedButton(
              onPressed: () => setState(() => review = !review),
              child: Text(tr('Review mistakes', 'चुका समजून घ्या')),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(title: Text(tr('Practice', 'सराव'))),
                      body: PracticeSessionPage(
                        initialTopic: widget.topic.id,
                        focusTopic: true,
                      ),
                    ),
                  ),
                );
              },
              child: Text(tr('Go to practice', 'सराव करा')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr('Finish', 'पूर्ण करा')),
            ),
          ],
        ),
        if (review) ...[
          const SizedBox(height: 22),
          if (mistakes.isEmpty)
            Text(
              tr(
                'All correct! You’re ready for another adventure.',
                'सर्व उत्तरे बरोबर! पुढच्या सफरीसाठी तयार.',
              ),
            ),
          for (final m in mistakes)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Panel(
                color: cream,
                child: Column(
                  children: [
                    Text(
                      Words(m['en'], m['mr']).inLanguage(store.language),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      Words(
                        m['hintEn'],
                        m['hintMr'],
                      ).inLanguage(store.language),
                      style: const TextStyle(
                        color: green,
                        fontWeight: FontWeight.w700,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    ),
  );
}

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});
  @override
  Widget build(BuildContext context) {
    final results = store.results;
    final correct = results.fold<int>(0, (v, r) => v + (r['correct'] as int));
    final total = results.fold<int>(0, (v, r) => v + (r['total'] as int));
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Heading(
            tr('Look how far you’ve come', 'तुमची प्रगती पाहा'),
            tr(
              '${store.profile} • Every small discovery matters.',
              '${store.profile} • प्रत्येक छोटा शोध महत्त्वाचा.',
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              stat(
                '📖',
                '${store.completed.length + store.completedChapters.length}',
                tr('Lessons & topics completed', 'पूर्ण धडे आणि विषय'),
              ),
              stat(
                '🧩',
                '${results.length}',
                tr('Archived quiz records', 'जुने प्रश्नमंजुषा निकाल'),
              ),
              stat('⭐', '${store.stars}', tr('Stars earned', 'मिळवलेले तारे')),
              stat(
                '🌱',
                total == 0 ? '—' : '${(correct / total * 100).round()}%',
                tr('Correct answers', 'बरोबर उत्तरे'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(
                    'Textbook chapter progress',
                    'पाठ्यपुस्तकातील पाठांची प्रगती',
                  ),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                for (var grade = 1; grade <= 4; grade++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${tr('Class', 'इयत्ता')} $grade • ${store.completedChapters.where((id) => id.startsWith('G$grade-')).length}/${chaptersForGrade(grade).length}',
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          minHeight: 12,
                          value:
                              store.completedChapters
                                  .where((id) => id.startsWith('G$grade-'))
                                  .length /
                              chaptersForGrade(grade).length,
                        ),
                      ],
                    ),
                  ),
                Text(
                  tr(
                    'Quiz results stay in the current session.',
                    'प्रश्नमंजुषेचे निकाल फक्त चालू सत्रात राहतात.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('Your topic garden', 'तुमची विषयांची बाग'),
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                for (final t in topics)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        Text(t.icon, style: const TextStyle(fontSize: 25)),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: Text(
                            t.name.inLanguage(store.language),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Expanded(
                          child: LinearProgressIndicator(
                            value:
                                store.completed
                                    .where(
                                      (v) => v.toString().endsWith(':${t.id}'),
                                    )
                                    .length /
                                4,
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(6),
                            backgroundColor: cream,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${store.completed.where((v) => v.toString().endsWith(':${t.id}')).length}/4',
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('Explorer badges', 'शोधक पदके'),
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                if (store.completed.isEmpty)
                  Text(
                    tr(
                      'Your first badge is one lesson away!',
                      'पहिला धडा पूर्ण करा आणि पदक मिळवा!',
                    ),
                  ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: store.completed.map((id) {
                    final parts = id.toString().split(':');
                    final t = topics.firstWhere(
                      (t) => t.id == parts.last,
                      orElse: () => topics.first,
                    );
                    return Chip(
                      avatar: const Text('🏅'),
                      label: Text(
                        '${tr('Class', 'इयत्ता')} ${parts.first} • ${t.name.inLanguage(store.language)}',
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(
                    'Earlier saved quiz records',
                    'पूर्वी जतन केलेले प्रश्नमंजुषा निकाल',
                  ),
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (results.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text(
                      tr(
                        'New quiz results are shown only during their session.',
                        'नव्या प्रश्नमंजुषेचे निकाल फक्त त्या सत्रात दिसतात.',
                      ),
                    ),
                  ),
                for (final r in results.reversed.take(12))
                  ListTile(
                    leading: const Text('📝', style: TextStyle(fontSize: 28)),
                    title: Text(
                      '${tr('Class', 'इयत्ता')} ${r['grade']} • ${topics.firstWhere((t) => t.id == r['topic'], orElse: () => topics.first).name.inLanguage(store.language)}',
                    ),
                    subtitle: Text(
                      '${r['date'].toString().substring(0, 10)} • ${r['correct'] == r['total'] ? tr('Well explored!', 'छान शिकला!') : tr('A topic to revisit', 'पुन्हा सराव करा')}',
                    ),
                    trailing: Text(
                      '${r['correct']} / ${r['total']}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: green,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget stat(String icon, String number, String name) => SizedBox(
    width: 220,
    child: Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 30)),
          const SizedBox(height: 10),
          Text(
            number,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: green,
            ),
          ),
          Text(name, style: const TextStyle(fontSize: 13)),
        ],
      ),
    ),
  );
}

class SettingsPage extends StatefulWidget {
  final VoidCallback onExit;
  const SettingsPage({super.key, required this.onExit});
  @override
  State<SettingsPage> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  String notice = '';
  Future<void> backup() async {
    try {
      final bytes = utf8.encode(jsonEncode(store.learningBackup()));
      final file = XFile.fromData(
        Uint8List.fromList(bytes),
        mimeType: 'application/json',
        name: 'ganit-safar-backup.json',
      );
      if (!kIsWeb && Platform.isAndroid) {
        final saved = await const MethodChannel(
          'org.ganitsafar/backup',
        ).invokeMethod<bool>('saveBackup', {'json': utf8.decode(bytes)});
        if (saved != true) return;
      } else if (kIsWeb) {
        await file.saveTo('ganit-safar-backup.json');
      } else {
        final location = await getSaveLocation(
          suggestedName: 'ganit-safar-backup.json',
        );
        if (location == null) return;
        await file.saveTo(location.path);
      }
      setState(
        () => notice = tr(
          'Backup saved. Keep it somewhere safe.',
          'बॅकअप जतन झाला. सुरक्षित ठिकाणी ठेवा.',
        ),
      );
    } catch (e) {
      setState(
        () =>
            notice = tr('Could not save backup: $e', 'बॅकअप जतन झाला नाही: $e'),
      );
    }
  }

  Future<void> restore() async {
    try {
      final file = await openFile(
        acceptedTypeGroups: [
          const XTypeGroup(
            label: 'Ganit Safar backup',
            extensions: ['json'],
            mimeTypes: ['application/json'],
          ),
        ],
      );
      if (file == null) return;
      if (await file.length() > 5 * 1024 * 1024)
        throw const FormatException('Backup too large');
      final data = jsonDecode(await file.readAsString());
      if (data is! Map<String, dynamic>)
        throw const FormatException('Invalid backup');
      final candidate = AppStore();
      candidate.decode(data);
      if (!mounted) return;
      final ok = await confirm(
        context,
        tr(
          'Restore this backup? Current settings and progress will be replaced.',
          'हा बॅकअप पुनर्स्थापित करायचा? सध्याच्या सेटिंग्ज आणि प्रगती बदलल्या जातील.',
        ),
      );
      if (ok) {
        store.restoreLearningBackup(candidate.learningBackup());
        await store.save();
        setState(
          () => notice = tr(
            'Your backup is restored.',
            'तुमचा बॅकअप पुनर्स्थापित झाला.',
          ),
        );
      }
    } catch (e) {
      setState(
        () => notice = tr(
          'Could not restore this file. Choose a valid Ganit Safar backup.',
          'ही फाइल वाचता आली नाही. योग्य गणित सफर बॅकअप निवडा.',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Heading(
          tr('Make yourself at home', 'तुमच्या आवडीनुसार सेटिंग्ज'),
          tr(
            'Your classroom. Your pace. Your language.',
            'तुमचा वर्ग. तुमची गती. तुमची भाषा.',
          ),
        ),
        const SizedBox(height: 24),
        Panel(
          child: Column(
            children: [
              const BoardTouchSettings(),
              SwitchListTile(
                title: Text(tr('Sound effects', 'ध्वनी')),
                subtitle: Text(
                  tr(
                    'Gentle feedback when you make a discovery.',
                    'बरोबर उत्तरावर सौम्य ध्वनी.',
                  ),
                ),
                value: store.sound,
                onChanged: (v) {
                  store.sound = v;
                  store.save();
                },
              ),
              SwitchListTile(
                title: Text(tr('High contrast', 'उच्च रंगविरोध')),
                value: store.contrast,
                onChanged: (v) {
                  store.contrast = v;
                  store.save();
                },
              ),
              SwitchListTile(
                title: Text(tr('Larger text', 'मोठा मजकूर')),
                value: store.largeText,
                onChanged: (v) {
                  store.largeText = v;
                  store.save();
                },
              ),
              SwitchListTile(
                title: Text(tr('Reduced motion', 'कमी हालचाल')),
                value: store.reducedMotion,
                onChanged: (v) {
                  store.reducedMotion = v;
                  store.save();
                },
              ),
              SwitchListTile(
                title: Text(tr('Slow animations', 'संथ हालचाली')),
                value: store.slow,
                onChanged: (v) {
                  store.slow = v;
                  store.save();
                },
              ),
              ListTile(
                title: Text(tr('Animation speed', 'हालचालींची गती')),
                subtitle: Slider(
                  value: store.speed,
                  min: .5,
                  max: 2,
                  divisions: 3,
                  label: '${store.speed}×',
                  onChanged: (v) {
                    store.speed = v;
                    store.save();
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.record_voice_over_outlined),
                title: Text(
                  tr(
                    'Narration-ready learning content',
                    'कथनासाठी तयार अभ्यासक्रम',
                  ),
                ),
                subtitle: Text(
                  tr(
                    'English and Marathi scripts are bundled. Recorded voice packs are not included. Use replay and visual instructions.',
                    'इंग्रजी आणि मराठी कथन मजकूर उपलब्ध आहे. ध्वनिमुद्रित आवाज समाविष्ट नाही. पुन्हा पाहा आणि दृश्य सूचना वापरा.',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('Local backup & restore', 'स्थानिक बॅकअप आणि पुनर्स्थापना'),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 21,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                tr(
                  'Save lessons, profiles, quizzes, settings and progress in a JSON file. No cloud account needed.',
                  'धडे, प्रोफाइल, प्रश्नमंजुषा, सेटिंग्ज आणि प्रगती JSON फाइलमध्ये जतन करा. क्लाउड खाते आवश्यक नाही.',
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: backup,
                    icon: const Icon(Icons.download),
                    label: Text(tr('Save backup', 'बॅकअप जतन करा')),
                  ),
                  OutlinedButton.icon(
                    onPressed: restore,
                    icon: const Icon(Icons.upload_file),
                    label: Text(tr('Restore backup', 'बॅकअप पुनर्स्थापित करा')),
                  ),
                ],
              ),
              if (notice.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Text(notice, style: const TextStyle(color: green)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (!kIsWeb && Platform.isWindows)
          OutlinedButton.icon(
            onPressed: widget.onExit,
            icon: const Icon(Icons.exit_to_app),
            label: Text(tr('Exit Ganit Safar', 'गणित सफर बंद करा')),
          ),
      ],
    ),
  );
}

Future<bool> confirm(BuildContext context, String text) async =>
    await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(tr('Please confirm', 'कृपया खात्री करा')),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(tr('Cancel', 'रद्द करा')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(tr('Continue', 'पुढे जा')),
          ),
        ],
      ),
    ) ??
    false;

class TeacherPage extends StatefulWidget {
  final ValueChanged<Topic> onLesson, onQuiz;
  final VoidCallback onTeam, onLock;
  final VoidCallback? onChapters;
  final VoidCallback? onPractice;
  const TeacherPage({
    super.key,
    required this.onLesson,
    required this.onQuiz,
    required this.onTeam,
    required this.onLock,
    this.onChapters,
    this.onPractice,
  });
  @override
  State<TeacherPage> createState() => _TeacherState();
}

class _TeacherState extends State<TeacherPage> {
  Topic topic = topics[2];
  Future<void> changePin() async {
    if (central.managed) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ClassroomConnectionPage()),
      );
      return;
    }
    final c = TextEditingController();
    String? error;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: Text(tr('Change teacher PIN', 'शिक्षक पिन बदला')),
          content: TextField(
            controller: c,
            maxLength: 8,
            keyboardType: TextInputType.number,
            obscureText: true,
            decoration: InputDecoration(
              labelText: tr('New PIN (4–8 digits)', 'नवा पिन (४–८ अंक)'),
              errorText: error,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr('Cancel', 'रद्द करा')),
            ),
            FilledButton(
              onPressed: () {
                if (!RegExp(r'^\d{4,8}$').hasMatch(c.text)) {
                  set(() => error = tr('Use 4–8 digits.', '४ ते ८ अंक वापरा.'));
                  return;
                }
                store.pinHash = AppStore.digest(c.text);
                store.save();
                Navigator.pop(ctx);
              },
              child: Text(tr('Save PIN', 'पिन जतन करा')),
            ),
          ],
        ),
      ),
    );
    c.dispose();
  }

  Future<void> profileDialog() async {
    final c = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          tr('Local learner or classroom', 'स्थानिक विद्यार्थी किंवा वर्ग'),
        ),
        content: TextField(
          controller: c,
          maxLength: 40,
          decoration: InputDecoration(
            labelText: tr('Profile name', 'प्रोफाइलचे नाव'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('Cancel', 'रद्द करा')),
          ),
          FilledButton(
            onPressed: () {
              if (c.text.trim().isEmpty) return;
              store.switchProfile(c.text.trim());
              Navigator.pop(ctx);
            },
            child: Text(tr('Open profile', 'प्रोफाइल उघडा')),
          ),
        ],
      ),
    );
    c.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Heading(
                tr(
                  'A little help for big discoveries',
                  'मोठ्या शोधांसाठी थोडी मदत',
                ),
                tr(
                  'Teacher’s corner • All classroom data stays on this device.',
                  'शिक्षक कक्ष • सर्व माहिती या उपकरणावरच राहते.',
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: widget.onLock,
              icon: const Icon(Icons.lock_outline),
              label: Text(tr('Lock', 'कुलूप लावा')),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (widget.onChapters != null) ...[
          FilledButton.icon(
            onPressed: widget.onChapters,
            icon: const Icon(Icons.menu_book_rounded),
            label: Text(
              tr('Choose a textbook chapter', 'पाठ्यपुस्तकातील पाठ निवडा'),
            ),
          ),
          const SizedBox(height: 20),
        ],
        if (widget.onPractice != null) ...[
          OutlinedButton.icon(
            onPressed: widget.onPractice,
            icon: const Icon(Icons.gesture_rounded),
            label: Text(tr('Mixed activity practice', 'मिश्र कृतींचा सराव')),
          ),
          const SizedBox(height: 20),
        ],
        const GradePicker(),
        const SizedBox(height: 18),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<Topic>(
                itemHeight: store.smartboard ? 72 : 56,
                isExpanded: true,
                initialValue: topic,
                decoration: InputDecoration(
                  labelText: tr(
                    'More topic tools',
                    'अतिरिक्त नमुना विषय साधने',
                  ),
                ),
                items: topics
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(
                          '${t.icon} ${t.name.inLanguage(store.language)}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (t) => setState(() => topic = t!),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: () => widget.onLesson(topic),
                    icon: const Icon(Icons.auto_stories),
                    label: Text(tr('Start lesson', 'धडा सुरू करा')),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => widget.onQuiz(topic),
                    icon: const Icon(Icons.quiz_outlined),
                    label: Text(
                      tr('Whole-class quiz', 'संपूर्ण वर्गाची प्रश्नमंजुषा'),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: widget.onTeam,
                    icon: const Icon(Icons.groups_outlined),
                    label: Text(tr('Team adventure', 'संघांची सफर')),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('Your custom quizzes', 'तुमच्या प्रश्नमंजुषा'),
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CustomQuizEditor(topic: topic),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: Text(tr('Create quiz', 'प्रश्नमंजुषा तयार करा')),
              ),
              const SizedBox(height: 15),
              if (store.custom.isEmpty)
                Text(
                  tr(
                    'Add your own English and Marathi questions. They’ll be available offline.',
                    'स्वतःचे इंग्रजी आणि मराठी प्रश्न जोडा. ते ऑफलाइन उपलब्ध होतील.',
                  ),
                ),
              for (final quiz in store.custom)
                ListTile(
                  leading: const Icon(Icons.extension_outlined, color: green),
                  title: Text(quiz['name']),
                  subtitle: Text(
                    tr(
                      'Class ${quiz['grade']} • ${quiz['questions'].length} questions',
                      'इयत्ता ${quiz['grade']} • ${quiz['questions'].length} प्रश्न',
                    ),
                  ),
                  trailing: Wrap(
                    children: [
                      IconButton(
                        tooltip: tr('Start quiz', 'प्रश्नमंजुषा सुरू करा'),
                        icon: const Icon(Icons.play_circle_outline),
                        onPressed: () {
                          store.grade = quiz['grade'];
                          store.save();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizPage(
                                topic: topics.firstWhere(
                                  (t) => t.id == quiz['topic'],
                                ),
                                config: {
                                  'questions': quiz['questions'],
                                  'seconds': 0,
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        tooltip: tr('Delete quiz', 'प्रश्नमंजुषा काढा'),
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          if (await confirm(
                            context,
                            tr(
                              'Delete this saved quiz?',
                              'ही प्रश्नमंजुषा काढायची?',
                            ),
                          )) {
                            store.custom.remove(quiz);
                            store.save();
                          }
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr(
                  'Classroom profiles & records',
                  'वर्गाचे प्रोफाइल आणि नोंदी',
                ),
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                tr(
                  'Current: ${store.profile} • ${store.results.length} quizzes • ${store.stars} stars',
                  'सध्याचे: ${store.profile} • ${store.results.length} प्रश्नमंजुषा • ${store.stars} तारे',
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton(
                    onPressed: profileDialog,
                    child: Text(
                      tr('Open / create profile', 'प्रोफाइल उघडा / तयार करा'),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: changePin,
                    child: Text(tr('Change PIN', 'पिन बदला')),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      if (await confirm(
                        context,
                        tr(
                          'Archive this profile’s progress and start fresh? The archive is kept in your backup.',
                          'या प्रोफाइलची प्रगती संग्रहित करून नव्याने सुरुवात करायची? संग्रह बॅकअपमध्ये राहील.',
                        ),
                      )) {
                        store.reset();
                      }
                    },
                    child: Text(
                      tr('Archive & reset', 'संग्रहित करा आणि रीसेट करा'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              for (final name in store.profiles.keys.where(
                (n) => n != store.profile,
              ))
                TextButton(
                  onPressed: () => store.switchProfile(name),
                  child: Text(tr('Open $name', '$name उघडा')),
                ),
              Text(
                tr(
                  '${store.archives.length} progress archives saved locally.',
                  'प्रगतीचे ${store.archives.length} संग्रह स्थानिक जतन आहेत.',
                ),
                style: const TextStyle(fontSize: 12, color: green),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const ProgressPage(),
      ],
    ),
  );
}

class CustomQuizEditor extends StatefulWidget {
  final Topic topic;
  const CustomQuizEditor({super.key, required this.topic});
  @override
  State<CustomQuizEditor> createState() => _CustomEditorState();
}

class _CustomEditorState extends State<CustomQuizEditor> {
  final name = TextEditingController(),
      en = TextEditingController(),
      mr = TextEditingController(),
      spokenMr = TextEditingController(),
      answer = TextEditingController(),
      hintEn = TextEditingController(),
      hintMr = TextEditingController(),
      spokenHintMr = TextEditingController(),
      reviewNotes = TextEditingController();
  bool wordingReviewed = false;
  List<Map<String, dynamic>> questions = [];
  String error = '';
  @override
  void dispose() {
    for (final c in [
      name,
      en,
      mr,
      spokenMr,
      answer,
      hintEn,
      hintMr,
      spokenHintMr,
      reviewNotes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void add() {
    final n = int.tryParse(answer.text);
    if (en.text.trim().isEmpty ||
        mr.text.trim().isEmpty ||
        n == null ||
        n < 0 ||
        hintEn.text.trim().isEmpty ||
        hintMr.text.trim().isEmpty) {
      setState(
        () => error = tr(
          'Add both languages, both explanations, and a whole-number answer (0 or above).',
          'दोन्ही भाषांत प्रश्न, स्पष्टीकरण आणि शून्य किंवा मोठे पूर्णांक उत्तर लिहा.',
        ),
      );
      return;
    }
    setState(() {
      final status = wordingReviewed ? 'editor-reviewed' : 'needs-review';
      questions.add(
        normalizeCustomQuestion({
          'en': en.text.trim(),
          'mr': mr.text.trim(),
          'answer': n,
          'hintEn': hintEn.text.trim(),
          'hintMr': hintMr.text.trim(),
          'audioEn': en.text.trim(),
          'audioMr': mr.text.trim(),
          'prompt': Words(
            en.text.trim(),
            mr.text.trim(),
            marathiSpoken: spokenMr.text.trim().isEmpty
                ? mr.text.trim()
                : spokenMr.text.trim(),
            translationProvider: 'teacher-local',
            translationStatus: status,
            mathGlossaryTerms: glossaryTermsFor(widget.topic.id),
            reviewNotes: reviewNotes.text.trim(),
          ).toJson(),
          'explanation': Words(
            hintEn.text.trim(),
            hintMr.text.trim(),
            marathiSpoken: spokenHintMr.text.trim().isEmpty
                ? hintMr.text.trim()
                : spokenHintMr.text.trim(),
            translationProvider: 'teacher-local',
            translationStatus: status,
            mathGlossaryTerms: glossaryTermsFor(widget.topic.id),
            reviewNotes: reviewNotes.text.trim(),
          ).toJson(),
        }),
      );
      en.clear();
      mr.clear();
      spokenMr.clear();
      answer.clear();
      hintEn.clear();
      hintMr.clear();
      spokenHintMr.clear();
      reviewNotes.clear();
      wordingReviewed = false;
      error = '';
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        tr('Build a classroom quiz', 'वर्गासाठी प्रश्नमंजुषा तयार करा'),
      ),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: name,
                maxLength: 60,
                decoration: InputDecoration(
                  labelText: tr('Quiz name', 'प्रश्नमंजुषेचे नाव'),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                tr(
                  'Class ${store.grade} • ${widget.topic.name.en} • Numeric multiple-choice questions',
                  'इयत्ता ${store.grade} • ${widget.topic.name.mr} • संख्यात्मक बहुपर्यायी प्रश्न',
                ),
              ),
              const SizedBox(height: 20),
              Panel(
                child: Column(
                  children: [
                    for (final item in [
                      (en, 'Question in English', 'इंग्रजी प्रश्न'),
                      (mr, 'Question in Marathi', 'मराठी प्रश्न'),
                      (
                        spokenMr,
                        'Classroom Marathi (optional)',
                        'मुलांसाठी सोपी मराठी (ऐच्छिक)',
                      ),
                      (answer, 'Correct number', 'बरोबर संख्या'),
                      (hintEn, 'English explanation', 'इंग्रजी स्पष्टीकरण'),
                      (hintMr, 'Marathi explanation', 'मराठी स्पष्टीकरण'),
                      (
                        spokenHintMr,
                        'Classroom Marathi explanation (optional)',
                        'मुलांसाठी सोपे मराठी स्पष्टीकरण (ऐच्छिक)',
                      ),
                      (
                        reviewNotes,
                        'Wording review notes (optional)',
                        'भाषा पडताळणीच्या नोंदी (ऐच्छिक)',
                      ),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: TextField(
                          controller: item.$1,
                          keyboardType: item.$1 == answer
                              ? TextInputType.number
                              : TextInputType.multiline,
                          decoration: InputDecoration(
                            labelText: tr(item.$2, item.$3),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        tr(
                          'I reviewed the English and Marathi wording',
                          'मी इंग्रजी आणि मराठी मजकूर तपासला आहे',
                        ),
                      ),
                      subtitle: Text(
                        tr(
                          'Leave off until both versions and the classroom wording have been checked.',
                          'दोन्ही भाषांतील आणि मुलांसाठीचा मजकूर तपासल्यानंतरच हे चालू करा.',
                        ),
                      ),
                      value: wordingReviewed,
                      onChanged: (value) =>
                          setState(() => wordingReviewed = value),
                    ),
                    if (error.isNotEmpty)
                      Text(
                        error,
                        style: const TextStyle(color: Colors.deepOrange),
                      ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: add,
                      icon: const Icon(Icons.add),
                      label: Text(tr('Add question', 'प्रश्न जोडा')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              for (var i = 0; i < questions.length; i++)
                ListTile(
                  title: Text(
                    '${i + 1}. ${Words.fromJson(Map<String, dynamic>.from(questions[i]['prompt'])).inLanguage(store.language)}',
                  ),
                  subtitle: Text('= ${questions[i]['answer']}'),
                  trailing: IconButton(
                    tooltip: tr('Remove', 'काढा'),
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() => questions.removeAt(i));
                    },
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  if (name.text.trim().isEmpty || questions.isEmpty) {
                    setState(
                      () => error = tr(
                        'Name your quiz and add at least one question.',
                        'नाव लिहा आणि किमान एक प्रश्न जोडा.',
                      ),
                    );
                    return;
                  }
                  store.custom.add({
                    'name': name.text.trim(),
                    'grade': store.grade,
                    'topic': widget.topic.id,
                    'questions': questions,
                  });
                  store.save();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.save_outlined),
                label: Text(
                  tr('Save quiz offline', 'प्रश्नमंजुषा ऑफलाइन जतन करा'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});
  @override
  State<TeamPage> createState() => _TeamState();
}

class _TeamState extends State<TeamPage> {
  final names = [
    TextEditingController(text: 'Mango Stars'),
    TextEditingController(text: 'Clever Cubs'),
    TextEditingController(text: 'Number Ninjas'),
  ];
  Topic topic = topics[2];
  int teams = 2, turn = 0, index = 0;
  List<int> scores = [0, 0, 0], votes = [0, 0, 0, 0];
  bool started = false, answered = false, celebrate = false;
  late Question q;
  @override
  void initState() {
    super.initState();
    q = makeQuestion(topic.id, store.grade, index, 'choice');
  }

  @override
  void dispose() {
    for (final n in names) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Heading(
          tr('Better together!', 'एकत्र शिकूया!'),
          tr(
            'Take turns, cheer for everyone. Every effort earns a star.',
            'पाळीपाळीने उत्तरे द्या. सर्वांना प्रोत्साहन द्या. प्रत्येक प्रयत्नाला एक तारा.',
          ),
        ),
        const SizedBox(height: 22),
        if (!started)
          Panel(
            child: Column(
              children: [
                const GradePicker(),
                const SizedBox(height: 20),
                DropdownButtonFormField<Topic>(
                  itemHeight: store.smartboard ? 72 : 56,
                  isExpanded: true,
                  initialValue: topic,
                  decoration: InputDecoration(labelText: tr('Topic', 'विषय')),
                  items: topics
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.name.inLanguage(store.language)),
                        ),
                      )
                      .toList(),
                  onChanged: (t) => setState(() => topic = t!),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final n in [2, 3])
                      ChoiceChip(
                        label: Text(tr('$n teams', '$n संघ')),
                        selected: teams == n,
                        onSelected: (_) => setState(() => teams = n),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                for (var i = 0; i < teams; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: TextField(
                      controller: names[i],
                      maxLength: 30,
                      decoration: InputDecoration(
                        labelText: tr('Team ${i + 1} name', 'संघ ${i + 1} नाव'),
                      ),
                    ),
                  ),
                FilledButton(
                  onPressed: () => setState(() {
                    started = true;
                    scores = [0, 0, 0];
                    turn = 0;
                    answered = false;
                    celebrate = false;
                    votes = [0, 0, 0, 0];
                    q = makeQuestion(topic.id, store.grade, index++, 'choice');
                  }),
                  child: Text(
                    tr('Start team adventure', 'संघांची सफर सुरू करा'),
                  ),
                ),
              ],
            ),
          )
        else ...[
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: List.generate(
              teams,
              (i) => SizedBox(
                width: 240,
                child: Panel(
                  color: turn == i ? const Color(0xFFFFF0C8) : Colors.white,
                  child: Column(
                    children: [
                      Text(
                        ['🥭', '🦁', '🚀'][i],
                        style: const TextStyle(fontSize: 38),
                      ),
                      Text(
                        names[i].text,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '⭐ ${scores[i]}',
                        style: const TextStyle(
                          fontSize: 30,
                          color: green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (turn == i) Text(tr('Your turn!', 'तुमची पाळी!')),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Panel(
            child: Column(
              children: [
                if (celebrate)
                  const Floaty(
                    child: Text('🎉 ⭐ 🎉', style: TextStyle(fontSize: 45)),
                  ),
                AbsorbPointer(
                  absorbing: answered,
                  child: QuestionActivity(
                    key: ValueKey(index),
                    q: q,
                    topic: topic.id,
                    onAnswer: (correct) {
                      setState(() {
                        scores[turn] += correct ? 3 : 1;
                        answered = true;
                        celebrate = correct;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  tr(
                    'Whole-class voting • tap to add a vote',
                    'संपूर्ण वर्गाचे मतदान • मतासाठी टॅप करा',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: List.generate(
                    4,
                    (i) => OutlinedButton(
                      onPressed: () => setState(() => votes[i]++),
                      child: Text(
                        '${q.options[i]}  •  ${votes[i]} ${tr('votes', 'मते')}',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton(
                      onPressed: () => setState(() => scores[turn]++),
                      child: Text(
                        tr('⭐ Participation reward', '⭐ सहभाग पुरस्कार'),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () => setState(() => scores[turn] += 2),
                      child: Text(
                        tr('🌱 Improvement reward', '🌱 प्रगती पुरस्कार'),
                      ),
                    ),
                    if (answered)
                      FilledButton(
                        onPressed: () => setState(() {
                          turn = (turn + 1) % teams;
                          index++;
                          q = makeQuestion(
                            topic.id,
                            store.grade,
                            index,
                            'choice',
                          );
                          answered = false;
                          celebrate = false;
                          votes = [0, 0, 0, 0];
                        }),
                        child: Text(tr('Next team', 'पुढचा संघ')),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: () async {
              store.stars += scores.take(teams).fold(0, (a, b) => a + b);
              await store.save();
              if (mounted) setState(() => started = false);
            },
            child: Text(
              tr('Celebrate & save stars', 'आनंद साजरा करा आणि तारे जतन करा'),
            ),
          ),
        ],
      ],
    ),
  );
}

class ScrollableRail extends StatelessWidget {
  final Widget child;
  const ScrollableRail({super.key, required this.child});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) => SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: bounds.maxHeight),
        child: IntrinsicHeight(child: child),
      ),
    ),
  );
}

class Celebration extends StatefulWidget {
  const Celebration({super.key});
  @override
  State<Celebration> createState() => _CelebrationState();
}

class _CelebrationState extends State<Celebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController animation = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: store.slow ? 5000 : 2800),
  )..forward();
  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 125,
    width: 500,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, _) =>
                CustomPaint(painter: ConfettiPainter(animation.value)),
          ),
        ),
        const Floaty(child: Text('🌟 🏅 🌟', style: TextStyle(fontSize: 65))),
      ],
    ),
  );
}

class ConfettiPainter extends CustomPainter {
  final double progress;
  ConfettiPainter(this.progress);
  @override
  void paint(Canvas c, Size s) {
    final random = Random(17);
    final paint = Paint();
    for (var i = 0; i < 42; i++) {
      final x = random.nextDouble() * s.width;
      final start = random.nextDouble() * 180;
      final y = (progress * 270 - start);
      paint.color = [
        green,
        orange,
        Colors.purple,
        Colors.blue,
      ][i % 4].withValues(alpha: 1 - progress * .65);
      c.save();
      c.translate(x, y);
      c.rotate(progress * pi * (i % 3 + 1));
      c.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(0, 0, 6, 12),
          const Radius.circular(2),
        ),
        paint,
      );
      c.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter old) => old.progress != progress;
}
