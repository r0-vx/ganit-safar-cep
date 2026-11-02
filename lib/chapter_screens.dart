part of 'main.dart';

PageRoute<void> _chapterPageRoute(Widget page) {
  final duration = Duration(
    milliseconds: store.reducedMotion ? 0 : (store.slow ? 700 : 260),
  );
  return PageRouteBuilder<void>(
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        store.reducedMotion
        ? child
        : FadeTransition(opacity: animation, child: child),
  );
}

Words _chapterStrandWords(String strand) => switch (strand.toLowerCase()) {
  'spatial' => const Words('Position', 'स्थिती'),
  'sequence' => const Words('Sequence', 'क्रम'),
  'shape' => const Words('Shapes', 'आकार'),
  'number' => const Words('Numbers', 'संख्या'),
  'addition' => const Words('Addition', 'बेरीज'),
  'subtraction' => const Words('Subtraction', 'वजाबाकी'),
  'data' => const Words('Data', 'माहिती'),
  'pattern' => const Words('Patterns', 'आकृतिबंध'),
  'measurement' => const Words('Measurement', 'मापन'),
  'time' => const Words('Time', 'वेळ'),
  'money' => const Words('Money', 'पैसे'),
  'multiplication' => const Words('Multiplication', 'गुणाकार'),
  'division' => const Words('Division', 'भागाकार'),
  'fraction' => const Words('Fractions', 'अपूर्णांक'),
  'operations' => const Words('Operations', 'क्रिया'),
  'place' => const Words('Place value', 'स्थानिक किंमत'),
  'application' => const Words('Applications', 'उपयोजन'),
  'area' => const Words('Area', 'क्षेत्रफळ'),
  'capacity' => const Words('Capacity', 'धारकता'),
  'map' => const Words('Maps', 'नकाशे'),
  'puzzle' => const Words('Puzzles', 'कोडी'),
  'symmetry' => const Words('Symmetry', 'सममिती'),
  _ => const Words('Mathematics', 'गणित'),
};

Words _chapterPageRange(SchoolChapter chapter) =>
    chapter.pageStart == chapter.pageEnd
    ? Words('Page ${chapter.pageStart}', 'पान ${chapter.pageStart}')
    : Words(
        'Pages ${chapter.pageStart}–${chapter.pageEnd}',
        'पाने ${chapter.pageStart}–${chapter.pageEnd}',
      );

/// A teacher-facing index of the approved textbook chapters.
class ChapterDirectoryPage extends StatelessWidget {
  final String mode;
  const ChapterDirectoryPage({super.key, this.mode = 'learn'});

  void _selectGrade(int grade) {
    if (store.grade == grade) return;
    store.grade = grade;
    store.save();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final chapters = chaptersForGrade(store.grade);
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Heading(
              mode == 'practice'
                  ? tr('Choose a chapter to practise', 'सरावासाठी धडा निवडा')
                  : mode == 'quiz'
                  ? tr(
                      'Choose a chapter for a quiz',
                      'प्रश्नमंजुषेसाठी धडा निवडा',
                    )
                  : tr(
                      'Textbook chapter directory',
                      'पाठ्यपुस्तक धड्यांची सूची',
                    ),
              mode == 'practice'
                  ? tr(
                      'Browse the approved chapter list, then practise with questions from that chapter.',
                      'मंजूर धड्यांची सूची पाहा आणि निवडलेल्या धड्याच्या प्रश्नांचा सराव करा.',
                    )
                  : mode == 'quiz'
                  ? tr(
                      'Browse the approved chapter list, then start a quiz for that chapter.',
                      'मंजूर धड्यांची सूची पाहा आणि निवडलेल्या धड्याची प्रश्नमंजुषा सुरू करा.',
                    )
                  : tr(
                      'Choose a class to browse every approved chapter by number, title, strand, and page.',
                      'क्रमांक, शीर्षक, गणिती विभाग आणि पानानुसार मंजूर धडे पाहण्यासाठी इयत्ता निवडा.',
                    ),
            ),
            const SizedBox(height: 20),
            Text(
              tr('Choose a class', 'इयत्ता निवडा'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final buttonWidth = min(174.0, constraints.maxWidth);
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(4, (i) {
                    final grade = i + 1;
                    final selected = store.grade == grade;
                    final count = chaptersForGrade(grade).length;
                    return SizedBox(
                      width: buttonWidth,
                      height: 120,
                      child: selected
                          ? FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: gradeColors[i],
                                minimumSize: const Size(64, 72),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                              onPressed: () => _selectGrade(grade),
                              child: _gradeButtonLabel(grade, count),
                            )
                          : OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: gradeColors[i],
                                side: BorderSide(
                                  color: gradeColors[i],
                                  width: 2,
                                ),
                                minimumSize: const Size(64, 72),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                              onPressed: () => _selectGrade(grade),
                              child: _gradeButtonLabel(grade, count),
                            ),
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Heading(
                    tr(
                      'Class ${store.grade} chapters',
                      'इयत्ता ${store.grade} चे धडे',
                    ),
                    tr(
                      '${chapters.length} chapters • Tap a chapter to open its lesson.',
                      '${chapters.length} धडे • धडा उघडण्यासाठी त्यावर स्पर्श करा.',
                    ),
                  ),
                ),
                Text(
                  tr('APPROVED LIST', 'मंजूर सूची'),
                  style: TextStyle(
                    color: gradeColors[store.grade - 1],
                    fontSize: 12,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1320
                    ? 3
                    : constraints.maxWidth >= 760
                    ? 2
                    : 1;
                final gap = 14.0;
                final cardWidth =
                    (constraints.maxWidth - (columns - 1) * gap) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final chapter in chapters)
                      SizedBox(
                        width: cardWidth,
                        child: _ChapterDirectoryCard(
                          chapter: chapter,
                          actionLabel: mode == 'practice'
                              ? tr('Practise', 'सराव')
                              : mode == 'quiz'
                              ? tr('Start quiz', 'प्रश्नमंजुषा')
                              : tr('Open lesson', 'धडा उघडा'),
                          onTap: () {
                            if (mode == 'practice') {
                              Navigator.push<void>(
                                context,
                                _chapterPageRoute(
                                  ChapterSessionPage(
                                    chapter: chapter,
                                    mode: ChapterSessionMode.practice,
                                  ),
                                ),
                              );
                            } else if (mode == 'quiz') {
                              Navigator.push<void>(
                                context,
                                _chapterPageRoute(
                                  ChapterSessionPage(
                                    chapter: chapter,
                                    mode: ChapterSessionMode.quiz,
                                  ),
                                ),
                              );
                            } else {
                              Navigator.push<void>(
                                context,
                                _chapterPageRoute(
                                  ChapterLessonPage(chapter: chapter),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      );
    },
  );

  Widget _gradeButtonLabel(int grade, int count) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        tr('Class $grade', 'इयत्ता $grade'),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 15,
          height: 1.05,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        tr('$count chapters', '$count धडे'),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11, height: 1.05),
      ),
    ],
  );
}

class _ChapterDirectoryCard extends StatelessWidget {
  final SchoolChapter chapter;
  final String actionLabel;
  final VoidCallback onTap;
  const _ChapterDirectoryCard({
    required this.chapter,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final done = store.isChapterDone(chapter.id);
    final color = gradeColors[chapter.grade - 1];
    final numberBadge = Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: Text(
        '${chapter.number}',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 26,
        ),
      ),
    );
    final title = Text(
      chapter.title.inLanguage(store.language),
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        height: 1.4,
      ),
    );
    final metadata = Wrap(
      spacing: 8,
      runSpacing: 7,
      children: [
        _ChapterMetaChip(
          icon: Icons.menu_book_rounded,
          text: _chapterPageRange(chapter).inLanguage(store.language),
        ),
        _ChapterMetaChip(
          icon: Icons.category_rounded,
          text: _chapterStrandWords(chapter.strand).inLanguage(store.language),
        ),
        if (done)
          _ChapterMetaChip(
            icon: Icons.check_circle_rounded,
            text: tr('Lesson completed', 'धडा पूर्ण'),
            color: green,
          ),
      ],
    );
    final action = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.chevron_right_rounded, color: color, size: 30),
        Text(
          actionLabel,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
    return Panel(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 112),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 440) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          numberBadge,
                          const Spacer(),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: color,
                            size: 28,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      title,
                      const SizedBox(height: 9),
                      metadata,
                      const SizedBox(height: 5),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          actionLabel,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    numberBadge,
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [title, const SizedBox(height: 9), metadata],
                      ),
                    ),
                    const SizedBox(width: 8),
                    action,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ChapterMetaChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const _ChapterMetaChip({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final foreground = color ?? const Color(0xFF334155);
      final iconColor = color ?? const Color(0xFF475569);
      return Container(
        constraints: BoxConstraints(
          minHeight: 34,
          maxWidth: constraints.maxWidth,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: constraints.maxWidth < 100 ? 6 : 9,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(20),
        ),
        child: constraints.maxWidth < 100
            ? Tooltip(
                message: text,
                child: Semantics(
                  label: text,
                  child: Icon(icon, size: 18, color: iconColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 15, color: iconColor),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      text,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 12,
                        color: foreground,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
      );
    },
  );
}

/// A locally navigated chapter lesson; changing language never resets its step.
class ChapterLessonPage extends StatefulWidget {
  final SchoolChapter chapter;
  const ChapterLessonPage({super.key, required this.chapter});

  @override
  State<ChapterLessonPage> createState() => _ChapterLessonPageState();
}

class _ChapterLessonPageState extends State<ChapterLessonPage> {
  final ScrollController scrollController = ScrollController();
  int step = 0;
  int replay = 0;
  int? selectedAnswer;
  bool showHint = false;
  final Set<int> exploredObjects = {};
  late final List<ChapterQuestion> questions = widget.chapter.questions(
    count: 5,
  );
  late final ChapterQuestion checkQuestion = questions.first;

  ClassroomActivity? monitoring;
  @override
  void initState() {
    super.initState();
    monitoring = central.beginActivity(
      'learn',
      widget.chapter.grade,
      widget.chapter.id,
    );
  }

  @override
  void dispose() {
    central.leaveActivity(monitoring);
    scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) return;
      if (store.reducedMotion) {
        scrollController.jumpTo(0);
      } else {
        scrollController.animateTo(
          0,
          duration: Duration(milliseconds: store.slow ? 600 : 280),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _next() {
    if (step >= 5) return;
    if (step == 4 && selectedAnswer != checkQuestion.correctIndex) return;
    setState(() {
      step++;
      selectedAnswer = null;
      showHint = false;
    });
    _scrollToTop();
    if (step == 5) central.completeActivity(monitoring);
    if (step == 5 && !store.isChapterDone(widget.chapter.id)) {
      store.completeChapter(widget.chapter.id);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final chapter = widget.chapter;
      final lesson = chapter.lesson;
      final title = tr(
        'Chapter ${chapter.number} • ${chapter.title.en}',
        'धडा ${chapter.number} • ${chapter.title.mr}',
      );
      final pages = _chapterPageRange(chapter);
      return Scaffold(
        backgroundColor: store.contrast ? Colors.white : cream,
        body: SafeArea(
          child: Column(
            children: [
              _ChapterRouteBar(
                title: tr('Chapter lesson', 'धड्याचा अभ्यास'),
                onBack: () => Navigator.maybePop(context),
              ),
              const ClassroomConnectionStrip(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1280),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Heading(
                            title,
                            tr(
                              'Class ${chapter.grade} • ${pages.en} • ${_chapterStrandWords(chapter.strand).en}',
                              'इयत्ता ${chapter.grade} • ${pages.mr} • ${_chapterStrandWords(chapter.strand).mr}',
                            ),
                          ),
                          const SizedBox(height: 16),
                          _ChapterStepProgress(current: step, total: 6),
                          const SizedBox(height: 17),
                          Panel(
                            color: const Color(0xFFFFFEFA),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _lessonBody(lesson),
                                const SizedBox(height: 20),
                                if (step == 3) ...[
                                  _ChapterObjectBoard(
                                    objects: lesson.objects,
                                    visualKind: lesson.visualKind,
                                    revealKey: '$step:$replay',
                                    onTap: (i) => setState(() {
                                      if (!exploredObjects.add(i)) {
                                        exploredObjects.remove(i);
                                      }
                                    }),
                                    selected: exploredObjects,
                                    interactive: true,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    tr(
                                      'Touched: ${exploredObjects.length} of ${lesson.objects.length}',
                                      'स्पर्श केलेल्या वस्तू: ${exploredObjects.length} / ${lesson.objects.length}',
                                    ),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: green,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ] else if (step == 1 || step == 2) ...[
                                  _ChapterObjectBoard(
                                    objects: lesson.objects,
                                    visualKind: lesson.visualKind,
                                    revealKey: '$step:$replay',
                                  ),
                                ],
                                if (step == 4) ...[
                                  const SizedBox(height: 6),
                                  _ChapterQuestionCard(
                                    question: checkQuestion,
                                    selected: selectedAnswer,
                                    onSelect: (index) => setState(() {
                                      selectedAnswer = index;
                                      showHint = false;
                                    }),
                                  ),
                                  if (selectedAnswer != null &&
                                      selectedAnswer !=
                                          checkQuestion.correctIndex)
                                    _ChapterFeedback(
                                      correct: false,
                                      text: tr(
                                        'That’s a useful try. Choose another answer or open the hint.',
                                        'छान प्रयत्न. दुसरे उत्तर निवडा किंवा संकेत पाहा.',
                                      ),
                                    ),
                                  if (selectedAnswer ==
                                      checkQuestion.correctIndex)
                                    _ChapterFeedback(
                                      correct: true,
                                      text: tr(
                                        'That’s right. You are ready to recap.',
                                        'बरोबर. आता उजळणी करूया.',
                                      ),
                                    ),
                                  if (showHint)
                                    _ChapterHelpBox(
                                      text: checkQuestion.hint.inLanguage(
                                        store.language,
                                      ),
                                    ),
                                ],
                                if (step == 5) ...[
                                  _ChapterObjectBoard(
                                    objects: lesson.objects,
                                    visualKind: lesson.visualKind,
                                    revealKey: '$step:$replay',
                                  ),
                                  const SizedBox(height: 12),
                                  _ChapterCompletionMark(),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              OutlinedButton.icon(
                                onPressed: step > 0
                                    ? () {
                                        setState(() {
                                          step--;
                                          selectedAnswer = null;
                                          showHint = false;
                                        });
                                        _scrollToTop();
                                      }
                                    : () => Navigator.maybePop(context),
                                icon: const Icon(Icons.arrow_back_rounded),
                                label: Text(tr('Back', 'मागे')),
                              ),
                              OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    replay++;
                                    exploredObjects.clear();
                                    selectedAnswer = null;
                                    showHint = false;
                                  });
                                  _scrollToTop();
                                },
                                icon: const Icon(Icons.replay_rounded),
                                label: Text(
                                  tr(
                                    'Replay this step',
                                    'हा टप्पा पुन्हा पाहा',
                                  ),
                                ),
                              ),
                              if (step == 4)
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      setState(() => showHint = !showHint),
                                  icon: const Icon(
                                    Icons.lightbulb_outline_rounded,
                                  ),
                                  label: Text(
                                    showHint
                                        ? tr('Hide hint', 'संकेत लपवा')
                                        : tr('Hint', 'संकेत'),
                                  ),
                                ),
                              if (step == 5) ...[
                                FilledButton.icon(
                                  onPressed: () => Navigator.push<void>(
                                    context,
                                    _chapterPageRoute(
                                      ChapterSessionPage(
                                        chapter: chapter,
                                        mode: ChapterSessionMode.practice,
                                      ),
                                    ),
                                  ),
                                  icon: const Icon(Icons.edit_rounded),
                                  label: Text(tr('Practice', 'सराव')),
                                ),
                                FilledButton.icon(
                                  onPressed: () => Navigator.push<void>(
                                    context,
                                    _chapterPageRoute(
                                      ChapterSessionPage(
                                        chapter: chapter,
                                        mode: ChapterSessionMode.quiz,
                                      ),
                                    ),
                                  ),
                                  icon: const Icon(Icons.quiz_rounded),
                                  label: Text(
                                    tr('Start quiz', 'प्रश्नमंजुषा सुरू करा'),
                                  ),
                                ),
                              ] else
                                FilledButton.icon(
                                  onPressed:
                                      step == 4 &&
                                          selectedAnswer !=
                                              checkQuestion.correctIndex
                                      ? null
                                      : _next,
                                  icon: const Icon(Icons.arrow_forward_rounded),
                                  iconAlignment: IconAlignment.end,
                                  label: Text(
                                    step == 4
                                        ? tr(
                                            'Continue to recap',
                                            'उजळणीकडे चला',
                                          )
                                        : tr('Next step', 'पुढचा टप्पा'),
                                  ),
                                ),
                            ],
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
      );
    },
  );

  Widget _lessonBody(ChapterLesson lesson) {
    final Words copy = switch (step) {
      0 => lesson.story,
      1 => lesson.concept,
      2 => lesson.workedExample,
      3 => Words(
        'Touch the objects to explore the idea, then continue when you are ready.',
        'कल्पना समजून घेण्यासाठी वस्तूंना स्पर्श करा. तयार झाल्यावर पुढे चला.',
      ),
      4 => Words(
        'Try this check. You can choose again until it feels right.',
        'हा प्रश्न सोडवा. योग्य वाटेपर्यंत उत्तर बदलून पाहा.',
      ),
      _ => lesson.recap,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          copy.inLanguage(store.language),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            height: 1.65,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (step == 2 && lesson.hint.en.isNotEmpty && lesson.hint.mr.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _ChapterHelpBox(
              text: tr(
                'Keep this idea in mind: ${lesson.hint.en}',
                'ही गोष्ट लक्षात ठेवा: ${lesson.hint.mr}',
              ),
            ),
          ),
      ],
    );
  }
}

class _ChapterRouteBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  const _ChapterRouteBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: IconButton.filledTonal(
              tooltip: tr('Back', 'मागे'),
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, size: 27),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 64,
            child: DropdownButton<int>(
              value: store.language,
              itemHeight: 72,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 0, child: Text('English')),
                DropdownMenuItem(value: 1, child: Text('मराठी')),
                DropdownMenuItem(value: 2, child: Text('English + मराठी')),
              ],
              onChanged: (value) {
                if (value == null) return;
                store.language = value;
                store.save();
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class _ChapterStepProgress extends StatelessWidget {
  final int current, total;
  const _ChapterStepProgress({required this.current, required this.total});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        tr('Step ${current + 1} of $total', 'टप्पा ${current + 1} / $total'),
        textAlign: TextAlign.end,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
      ),
      const SizedBox(height: 7),
      LinearProgressIndicator(
        value: (current + 1) / total,
        minHeight: 7,
        borderRadius: BorderRadius.circular(8),
        color: green,
        backgroundColor: Colors.white,
      ),
    ],
  );
}

class _ChapterObjectBoard extends StatelessWidget {
  final List<String> objects;
  final String visualKind;
  final Object? revealKey;
  final ValueChanged<int>? onTap;
  final Set<int> selected;
  final bool interactive;
  const _ChapterObjectBoard({
    required this.objects,
    required this.visualKind,
    this.revealKey,
    this.onTap,
    this.selected = const {},
    this.interactive = false,
  });

  @override
  Widget build(BuildContext context) {
    final duration = Duration(
      milliseconds: store.reducedMotion ? 0 : (store.slow ? 540 : 260),
    );
    final key = ValueKey<Object?>(revealKey ?? visualKind);
    final Widget content;
    if (objects.isEmpty) {
      content = Container(
        key: key,
        constraints: const BoxConstraints(minHeight: 96),
        alignment: Alignment.center,
        child: Icon(_iconForKind(visualKind), size: 54, color: green),
      );
    } else {
      content = Wrap(
        key: key,
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: [
          for (int i = 0; i < objects.length; i++)
            _ObjectTile(
              text: objects[i],
              semanticLabel: tr(
                'Object ${i + 1}: ${objects[i]}',
                'वस्तू ${i + 1}: ${objects[i]}',
              ),
              icon: _iconForKind(visualKind),
              active: selected.contains(i),
              interactive: interactive,
              onTap: onTap == null ? null : () => onTap!(i),
            ),
        ],
      );
    }
    return Semantics(
      label: tr('Math objects', 'गणिती वस्तू'),
      child: AnimatedSwitcher(
        duration: duration,
        transitionBuilder: (child, animation) => store.reducedMotion
            ? child
            : FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
        child: content,
      ),
    );
  }

  IconData _iconForKind(String kind) {
    final value = kind.toLowerCase();
    if (value.contains('clock') || value.contains('time'))
      return Icons.schedule_rounded;
    if (value.contains('shape') || value.contains('geometry'))
      return Icons.category_rounded;
    if (value.contains('coin') || value.contains('money'))
      return Icons.paid_rounded;
    if (value.contains('fraction') || value.contains('circle'))
      return Icons.pie_chart_rounded;
    if (value.contains('line') || value.contains('number'))
      return Icons.linear_scale_rounded;
    if (value.contains('group') || value.contains('array'))
      return Icons.grid_view_rounded;
    return Icons.circle_rounded;
  }
}

class _ObjectTile extends StatelessWidget {
  final String text, semanticLabel;
  final IconData icon;
  final bool active, interactive;
  final VoidCallback? onTap;
  const _ObjectTile({
    required this.text,
    required this.semanticLabel,
    required this.icon,
    required this.active,
    required this.interactive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(19),
      side: BorderSide(
        color: active ? green : const Color(0xFFCBD5E1),
        width: active ? 3 : 1,
      ),
    );
    return Semantics(
      button: interactive,
      label: semanticLabel,
      selected: active,
      onTap: interactive ? onTap : null,
      excludeSemantics: true,
      child: AnimatedScale(
        scale: active && !store.reducedMotion ? 1.05 : 1,
        duration: Duration(
          milliseconds: store.reducedMotion ? 0 : (store.slow ? 420 : 180),
        ),
        child: Material(
          color: active ? const Color(0xFFE0F2FE) : Colors.white,
          shape: shape,
          child: InkWell(
            onTap: onTap,
            customBorder: shape,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 72, minHeight: 72),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 114),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (text.runes.length <= 3)
                        Text(
                          text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 32),
                        )
                      else
                        Icon(icon, size: 27, color: green),
                      if (text.runes.length > 3) ...[
                        const SizedBox(height: 4),
                        Text(
                          text,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChapterQuestionCard extends StatelessWidget {
  final ChapterQuestion question;
  final int? selected;
  final ValueChanged<int> onSelect;
  const _ChapterQuestionCard({
    required this.question,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        question.prompt.inLanguage(store.language),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 20,
          height: 1.55,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 15),
      _ChapterObjectBoard(
        objects: question.objects,
        visualKind: question.visualKind,
        revealKey: question.id,
      ),
      const SizedBox(height: 12),
      for (int i = 0; i < question.options.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: _ChapterChoiceOption(
            index: i,
            text: question.options[i].inLanguage(store.language),
            selected: selected == i,
            onTap: () => onSelect(i),
          ),
        ),
    ],
  );
}

class _ChapterChoiceOption extends StatelessWidget {
  final int index;
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _ChapterChoiceOption({
    required this.index,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: BorderSide(
        color: selected ? green : const Color(0xFFCBD5E1),
        width: selected ? 3 : 1,
      ),
    );
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? const Color(0xFFDBEAFE) : Colors.white,
        shape: shape,
        child: InkWell(
          onTap: onTap,
          customBorder: shape,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 70),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: selected ? green : const Color(0xFFE2E8F0),
                    foregroundColor: selected ? Colors.white : ink,
                    child: Text(String.fromCharCode(65 + index)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.45,
                      ),
                    ),
                  ),
                  if (selected)
                    const Icon(Icons.check_circle_rounded, color: green),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChapterFeedback extends StatelessWidget {
  final bool correct;
  final String text;
  const _ChapterFeedback({required this.correct, required this.text});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 10),
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: correct ? const Color(0xFFDCFCE7) : const Color(0xFFEFF6FF),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: correct ? green : const Color(0xFF93C5FD)),
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.w800,
        color: correct ? const Color(0xFF166534) : const Color(0xFF1D4ED8),
        height: 1.5,
      ),
    ),
  );
}

class _ChapterHelpBox extends StatelessWidget {
  final String text;
  const _ChapterHelpBox({required this.text});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF7D6),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFEAB308)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.lightbulb_rounded, color: Color(0xFFB45309)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(height: 1.55, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class _ChapterPracticeHelp extends StatelessWidget {
  final Words concept, example, hint;
  const _ChapterPracticeHelp({
    required this.concept,
    required this.example,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF7D6),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFEAB308)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _helpLine(
          tr('Concept', 'संकल्पना'),
          concept.inLanguage(store.language),
        ),
        _helpLine(
          tr('Worked example', 'सोडवलेले उदाहरण'),
          example.inLanguage(store.language),
        ),
        _helpLine(tr('Hint', 'संकेत'), hint.inLanguage(store.language)),
      ],
    ),
  );

  Widget _helpLine(String label, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(text, style: const TextStyle(height: 1.5)),
      ],
    ),
  );
}

class _ChapterCompletionMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFDCFCE7),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF166534),
          size: 30,
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            tr('Chapter lesson complete', 'धड्याचा अभ्यास पूर्ण'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF166534),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  );
}

enum ChapterSessionMode { practice, quiz }

class ChapterSessionPage extends StatefulWidget {
  final SchoolChapter chapter;
  final ChapterSessionMode mode;
  const ChapterSessionPage({
    super.key,
    required this.chapter,
    required this.mode,
  });

  @override
  State<ChapterSessionPage> createState() => _ChapterSessionPageState();
}

class _ChapterSessionPageState extends State<ChapterSessionPage> {
  late final List<ChapterQuestion> questions = widget.chapter.questions(
    count: 5,
  );
  late final ChapterLesson lesson = widget.chapter.lesson;
  final ScrollController scrollController = ScrollController();
  final Stopwatch stopwatch = Stopwatch();
  ClassroomActivity? monitoring;
  final List<int?> answers = [];
  int current = 0;
  bool showHint = false, finished = false, showMistakeReview = false;

  bool get isQuiz => widget.mode == ChapterSessionMode.quiz;
  int get correctCount => List.generate(
    questions.length,
    (i) => i,
  ).where((i) => answers[i] == questions[i].correctIndex).length;
  int get answeredCount => answers.where((answer) => answer != null).length;
  int get incorrectCount => answeredCount - correctCount;
  int get skippedCount => questions.length - answeredCount;
  double get accuracy =>
      questions.isEmpty ? 0 : correctCount / questions.length;
  int get stars => correctCount == questions.length
      ? (questions.isEmpty ? 0 : 3)
      : correctCount >= (questions.length * .8).ceil()
      ? 2
      : correctCount >= (questions.length * .5).ceil()
      ? 1
      : 0;

  @override
  void initState() {
    super.initState();
    answers.addAll(List<int?>.filled(questions.length, null));
    stopwatch.start();
    monitoring = central.beginActivity(
      isQuiz ? 'quiz' : 'practice',
      widget.chapter.grade,
      widget.chapter.id,
    );
  }

  @override
  void dispose() {
    central.leaveActivity(monitoring);
    stopwatch.stop();
    scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) return;
      if (store.reducedMotion) {
        scrollController.jumpTo(0);
      } else {
        scrollController.animateTo(
          0,
          duration: Duration(milliseconds: store.slow ? 600 : 280),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _select(int index) => setState(() {
    answers[current] = index;
    showHint = false;
  });

  void _advance() {
    if (current < questions.length - 1) {
      setState(() {
        current++;
        showHint = false;
      });
      _scrollToTop();
    } else {
      setState(() {
        finished = true;
        showHint = false;
        showMistakeReview = false;
      });
      stopwatch.stop();
      central.completeActivity(monitoring);
      _scrollToTop();
    }
  }

  void _reset() {
    central.leaveActivity(monitoring);
    monitoring = central.beginActivity(
      isQuiz ? 'quiz' : 'practice',
      widget.chapter.grade,
      widget.chapter.id,
    );
    setState(() {
      current = 0;
      answers
        ..clear()
        ..addAll(List<int?>.filled(questions.length, null));
      showHint = false;
      finished = false;
      showMistakeReview = false;
      stopwatch
        ..reset()
        ..start();
    });
    _scrollToTop();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => Scaffold(
      backgroundColor: store.contrast ? Colors.white : cream,
      body: SafeArea(
        child: Column(
          children: [
            _ChapterRouteBar(
              title: isQuiz
                  ? tr('Chapter quiz', 'धडा प्रश्नमंजुषा')
                  : tr('Chapter practice', 'धड्याचा सराव'),
              onBack: () => Navigator.maybePop(context),
            ),
            const ClassroomConnectionStrip(),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: finished ? _resultBody() : _questionBody(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _questionBody() {
    if (questions.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Heading(
            tr('No questions available yet', 'प्रश्न अजून उपलब्ध नाहीत'),
            tr(
              'Return to the chapter lesson and try again later.',
              'धड्याकडे परत जा आणि नंतर पुन्हा प्रयत्न करा.',
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            label: Text(tr('Back', 'मागे')),
          ),
        ],
      );
    }
    final question = questions[current];
    final title = tr(
      'Chapter ${widget.chapter.number} • ${widget.chapter.title.en}',
      'धडा ${widget.chapter.number} • ${widget.chapter.title.mr}',
    );
    final selected = answers[current];
    final practiceIsCorrect = selected == question.correctIndex;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Heading(
          title,
          tr(
            'Class ${widget.chapter.grade} • ${isQuiz ? 'Quiz' : 'Practice'} • Question ${current + 1} of ${questions.length}',
            'इयत्ता ${widget.chapter.grade} • ${isQuiz ? 'प्रश्नमंजुषा' : 'सराव'} • प्रश्न ${current + 1} / ${questions.length}',
          ),
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: (current + 1) / questions.length,
          minHeight: 8,
          borderRadius: BorderRadius.circular(8),
          color: gradeColors[widget.chapter.grade - 1],
          backgroundColor: Colors.white,
        ),
        const SizedBox(height: 16),
        Panel(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ChapterQuestionCard(
                question: question,
                selected: selected,
                onSelect: _select,
              ),
              if (!isQuiz && selected != null && practiceIsCorrect)
                _ChapterFeedback(
                  correct: true,
                  text: tr(
                    'Well done. You found it!',
                    'छान! योग्य उत्तर सापडले.',
                  ),
                ),
              if (!isQuiz && selected != null && !practiceIsCorrect)
                _ChapterFeedback(
                  correct: false,
                  text: tr(
                    'Good try. Take another look and choose again.',
                    'छान प्रयत्न. पुन्हा पाहा आणि उत्तर बदला.',
                  ),
                ),
              if (!isQuiz && showHint)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _ChapterPracticeHelp(
                    concept: lesson.concept,
                    example: lesson.workedExample,
                    hint: question.hint,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (!isQuiz && selected != null && !practiceIsCorrect)
              OutlinedButton.icon(
                onPressed: () => setState(() {
                  answers[current] = null;
                  showHint = false;
                }),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(tr('Try again', 'पुन्हा प्रयत्न करा')),
              ),
            if (!isQuiz)
              OutlinedButton.icon(
                onPressed: () => setState(() => showHint = !showHint),
                icon: const Icon(Icons.lightbulb_outline_rounded),
                label: Text(
                  showHint ? tr('Hide hint', 'संकेत लपवा') : tr('Help', 'मदत'),
                ),
              ),
            if (current > 0)
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    current--;
                    showHint = false;
                  });
                  _scrollToTop();
                },
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(tr('Previous', 'मागे')),
              ),
            FilledButton.icon(
              onPressed: isQuiz || selected == question.correctIndex
                  ? _advance
                  : null,
              icon: Icon(
                current == questions.length - 1
                    ? Icons.flag_rounded
                    : Icons.arrow_forward_rounded,
              ),
              iconAlignment: IconAlignment.end,
              label: Text(
                isQuiz
                    ? current == questions.length - 1
                          ? tr('Finish quiz', 'प्रश्नमंजुषा पूर्ण करा')
                          : selected == null
                          ? tr('Skip question', 'प्रश्न सोडा')
                          : tr('Next question', 'पुढचा प्रश्न')
                    : current == questions.length - 1
                    ? tr('Finish practice', 'सराव पूर्ण करा')
                    : tr('Next question', 'पुढचा प्रश्न'),
              ),
            ),
          ],
        ),
        if (isQuiz)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              tr(
                'Your score appears at the end of this session.',
                'या सत्राच्या शेवटी तुमचे गुण दिसतील.',
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
            ),
          ),
      ],
    );
  }

  Widget _resultBody() {
    final chapter = widget.chapter;
    final percent = (accuracy * 100).round();
    final elapsed = stopwatch.elapsed;
    final timeText =
        '${elapsed.inMinutes.remainder(60).toString().padLeft(2, '0')}:${elapsed.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Heading(
          isQuiz
              ? tr('Current Session Result', 'या सत्राचा निकाल')
              : tr('Practice session complete', 'सरावाचे सत्र पूर्ण'),
          tr(
            'Class ${chapter.grade} • Chapter ${chapter.number}: ${chapter.title.en}',
            'इयत्ता ${chapter.grade} • धडा ${chapter.number}: ${chapter.title.mr}',
          ),
        ),
        const SizedBox(height: 16),
        Panel(
          color: const Color(0xFFFFFEFA),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isQuiz)
                Text(
                  List<String>.filled(stars, '⭐').join(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 42),
                ),
              const SizedBox(height: 7),
              Text(
                tr(
                  'Answered $answeredCount of ${questions.length} • Correct $correctCount • Incorrect $incorrectCount • Skipped $skippedCount',
                  'सोडवले $answeredCount / ${questions.length} • बरोबर $correctCount • चूक $incorrectCount • सोडले $skippedCount',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 13),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _ChapterResultTile(
                    title: tr('Score', 'गुण'),
                    value:
                        '${(correctCount * 100 / (questions.isEmpty ? 1 : questions.length)).round()}%',
                    icon: Icons.assessment_rounded,
                  ),
                  _ChapterResultTile(
                    title: tr('Accuracy', 'अचूकता'),
                    value: '$percent%',
                    icon: Icons.track_changes_rounded,
                  ),
                  if (isQuiz)
                    _ChapterResultTile(
                      title: tr('Stars', 'तारे'),
                      value: '$stars / 3',
                      icon: Icons.star_rounded,
                    ),
                  _ChapterResultTile(
                    title: tr('Time', 'वेळ'),
                    value: timeText,
                    icon: Icons.timer_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (isQuiz) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () =>
                setState(() => showMistakeReview = !showMistakeReview),
            icon: Icon(
              showMistakeReview
                  ? Icons.visibility_off_rounded
                  : Icons.fact_check_rounded,
            ),
            label: Text(
              showMistakeReview
                  ? tr('Hide mistake review', 'चुकांचा आढावा लपवा')
                  : tr('Review mistakes', 'चुका पाहा'),
            ),
          ),
          if (showMistakeReview) ...[
            const SizedBox(height: 12),
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    tr('Review mistakes', 'चुका पाहा'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (int i = 0; i < questions.length; i++)
                    if (answers[i] != questions[i].correctIndex)
                      _ChapterMistakeReview(
                        number: i + 1,
                        question: questions[i],
                        answer: answers[i],
                      ),
                  if (incorrectCount == 0 && skippedCount == 0)
                    _ChapterFeedback(
                      correct: true,
                      text: tr(
                        'Every answer was correct. Great work!',
                        'सर्व उत्तरे बरोबर. छान काम!',
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
        const SizedBox(height: 15),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.replay_rounded),
              label: Text(tr('Try again', 'पुन्हा प्रयत्न करा')),
            ),
            if (isQuiz)
              OutlinedButton.icon(
                onPressed: () => Navigator.pushReplacement<void, void>(
                  context,
                  _chapterPageRoute(
                    ChapterSessionPage(
                      chapter: chapter,
                      mode: ChapterSessionMode.practice,
                    ),
                  ),
                ),
                icon: const Icon(Icons.edit_rounded),
                label: Text(tr('Go to Practice', 'सराव करा')),
              ),
            OutlinedButton.icon(
              onPressed: () => Navigator.maybePop(context),
              icon: Icon(
                isQuiz ? Icons.check_rounded : Icons.menu_book_rounded,
              ),
              label: Text(isQuiz ? tr('Finish', 'पूर्ण') : tr('Back', 'मागे')),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChapterResultTile extends StatelessWidget {
  final String title, value;
  final IconData icon;
  const _ChapterResultTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 126, minHeight: 94),
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFEFF6FF),
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: const Color(0xFFBFDBFE)),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 21, color: green),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _ChapterMistakeReview extends StatelessWidget {
  final int number;
  final ChapterQuestion question;
  final int? answer;
  const _ChapterMistakeReview({
    required this.number,
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    final correct = question.options[question.correctIndex].inLanguage(
      store.language,
    );
    final chosen = answer == null
        ? tr('Skipped', 'सोडला')
        : question.options[answer!].inLanguage(store.language);
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. ${question.prompt.inLanguage(store.language)}',
            style: const TextStyle(fontWeight: FontWeight.w900, height: 1.45),
          ),
          const SizedBox(height: 6),
          Text(tr('Your answer: $chosen', 'तुमचे उत्तर: $chosen')),
          Text(
            tr('Answer: $correct', 'योग्य उत्तर: $correct'),
            style: const TextStyle(
              color: Color(0xFF166534),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            question.explanation.inLanguage(store.language),
            style: const TextStyle(height: 1.5),
          ),
        ],
      ),
    );
  }
}
