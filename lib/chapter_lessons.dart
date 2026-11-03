part of 'main.dart';

/// Six connected teaching stages. Answers and progress live in this State, so
/// language changes and opening hints never replace a child's active work.
class ChapterLessonPage extends StatefulWidget {
  final SchoolChapter chapter;
  const ChapterLessonPage({super.key, required this.chapter});
  @override
  State<ChapterLessonPage> createState() => _ChapterLessonPageState();
}

class _ChapterLessonPageState extends State<ChapterLessonPage> {
  final ScrollController scrollController = ScrollController();
  int step = 0, replay = 0, hintLevel = 0, explored = 0;
  int? prediction, guidedAnswer, independentAnswer;
  bool usedHelp = false;
  ClassroomActivity? monitoring;
  late final List<ChapterQuestion> questions = _lessonQuestions(widget.chapter);
  ChapterQuestion get demonstration => questions.first;
  ChapterQuestion get checkQuestion => questions[1];
  ChapterQuestion get activeQuestion =>
      step == 4 ? checkQuestion : demonstration;
  int? get selected => step == 4 ? independentAnswer : guidedAnswer;
  bool get canAdvance => step == 3
      ? guidedAnswer == demonstration.correctIndex
      : step == 4
      ? independentAnswer == checkQuestion.correctIndex
      : true;

  static List<ChapterQuestion> _lessonQuestions(SchoolChapter chapter) {
    if (chapter.id != 'G1-C10') return chapter.questions(count: 5);
    ChapterQuestion example(
      String id,
      Words prompt,
      List<Words> options,
      int correct,
      Words explanation,
      Words hint,
    ) => ChapterQuestion(
      id: id,
      prompt: prompt.identified('$id.prompt'),
      explanation: explanation.identified('$id.explanation'),
      hint: hint.identified('$id.hint'),
      options: options,
      correctIndex: correct,
      objects: const ['🥭', '🧺'],
      visualKind: 'addition',
    );
    return [
      example(
        '${chapter.id}-lesson-mango',
        const Words(
          'Mira has 3 mangoes. Ravi brings 2 more. How many mangoes are together?',
          'मीराकडे ३ आंबे आहेत. रवी आणखी २ आंबे आणतो. दोघांचे मिळून किती आंबे झाले?',
        ),
        const [
          Words('4', '४'),
          Words('5', '५'),
          Words('6', '६'),
          Words('3', '३'),
        ],
        1,
        const Words(
          '3 + 2 = 5. The two groups together have five mangoes.',
          '३ + २ = ५. दोन्ही गट मिळून पाच आंबे झाले.',
        ),
        const Words(
          'Bring the groups together. Touch each mango once.',
          'दोन्ही गट एकत्र आणा. प्रत्येक आंब्याला एकदा स्पर्श करा.',
        ),
      ),
      example(
        '${chapter.id}-lesson-pencil',
        const Words(
          'There are 4 pencils on a desk. Mira adds 2 pencils. How many pencils now?',
          'बाकावर ४ पेन्सिली आहेत. मीरा आणखी २ पेन्सिली ठेवते. आता किती पेन्सिली झाल्या?',
        ),
        const [
          Words('5', '५'),
          Words('7', '७'),
          Words('6', '६'),
          Words('4', '४'),
        ],
        2,
        const Words(
          '4 + 2 = 6. Four pencils and two more make six pencils.',
          '४ + २ = ६. चार पेन्सिली आणि आणखी दोन मिळून सहा पेन्सिली होतात.',
        ),
        const Words(
          'Join the two pencil groups, then count every pencil once.',
          'पेन्सिलींचे दोन्ही गट एकत्र करा. प्रत्येक पेन्सिल एकदा मोजा.',
        ),
      ),
    ];
  }

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

  void _top() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted || !scrollController.hasClients) return;
    if (store.reducedMotion) {
      scrollController.jumpTo(0);
    } else {
      scrollController.animateTo(
        0,
        duration: Duration(milliseconds: store.slow ? 500 : 240),
        curve: Curves.easeOut,
      );
    }
  });

  void _next() {
    if (step >= 5 || !canAdvance) return;
    setState(() {
      step++;
      hintLevel = 0;
      explored = 0;
    });
    if (step == 5) {
      central.completeActivity(monitoring);
      if (!store.isChapterDone(widget.chapter.id))
        store.completeChapter(widget.chapter.id);
    }
    _top();
  }

  void _replay() {
    setState(() {
      replay++;
      hintLevel = 0;
      explored = 0;
      if (step == 0) prediction = null;
      if (step == 3) guidedAnswer = null;
      if (step == 4) independentAnswer = null;
    });
    _top();
  }

  Words get stageTitle => const [
    Words('Story & Predict', 'गोष्ट आणि अंदाज'),
    Words('Explore', 'करून पाहूया'),
    Words('See the Maths', 'गणित समजून घेऊया'),
    Words('Guided Try', 'मदतीने सोडवूया'),
    Words('Independent Challenge', 'स्वतः सोडवूया'),
    Words('Recap & Celebrate', 'उजळणी आणि शाबासकी'),
  ][step];

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final chapter = widget.chapter, pages = _chapterPageRange(chapter);
      return Scaffold(
        backgroundColor: store.contrast ? Colors.white : LearningPalette.paper,
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
                  padding: EdgeInsets.all(
                    MediaQuery.sizeOf(context).width < 600 ? 16 : 24,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1220),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          LearningModeHeader(
                            title: tr(
                              'Chapter ${chapter.number} • ${chapter.title.en}',
                              'धडा ${chapter.number} • ${chapter.title.mr}',
                            ),
                            subtitle: tr(
                              'Class ${chapter.grade} • ${pages.en}',
                              'इयत्ता ${chapter.grade} • ${pages.mr}',
                            ),
                            icon: Icons.auto_stories_outlined,
                          ),
                          const SizedBox(height: 10),
                          _LessonStageRail(step: step),
                          const SizedBox(height: 10),
                          _ChapterStepProgress(current: step, total: 6),
                          const SizedBox(height: 16),
                          LearningSurface(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  classUiText(stageTitle, grade: chapter.grade),
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w900,
                                    color: LearningPalette.teal,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _stageBody(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _controls(),
            ],
          ),
        ),
      );
    },
  );

  Widget _stageBody() {
    final lesson = widget.chapter.lesson;
    if (step == 0) {
      final story = widget.chapter.id == 'G1-C10'
          ? demonstration.prompt
          : lesson.story;
      final text = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            story.inLanguage(store.language),
            style: const TextStyle(
              fontSize: 22,
              height: 1.65,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            tr(
              'What do you think? Make a prediction. We will explore it together.',
              'तुला काय वाटते? अंदाज सांग. मग आपण मिळून करून पाहूया.',
            ),
            style: const TextStyle(fontSize: 17, height: 1.5),
          ),
          const SizedBox(height: 16),
          _answers(
            demonstration,
            prediction,
            (value) => setState(() => prediction = value),
          ),
          if (prediction != null)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                tr(
                  'Prediction saved for this lesson. Let’s find out!',
                  'या धड्यासाठी अंदाज नोंदवला. आता शोधूया!',
                ),
                style: TextStyle(
                  color: LearningPalette.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      );
      return LayoutBuilder(
        builder: (context, c) => c.maxWidth > 850
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: text),
                  const SizedBox(width: 24),
                  const Expanded(
                    flex: 4,
                    child: LearningArtwork(
                      asset: 'assets/art/classroom_story.png',
                      height: 285,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              )
            : text,
      );
    }
    if (step == 1)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            demonstration.prompt.inLanguage(store.language),
            style: const TextStyle(
              fontSize: 21,
              height: 1.55,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          MathScene(
            question: demonstration,
            interactive: true,
            replayKey: '$step:$replay',
            onCountChanged: (count) => setState(() => explored = count),
          ),
          const SizedBox(height: 12),
          Text(
            demonstration.hint.inLanguage(store.language),
            style: const TextStyle(fontSize: 17, height: 1.55),
          ),
        ],
      );
    if (step == 2)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            lesson.concept.inLanguage(store.language),
            style: const TextStyle(
              fontSize: 21,
              height: 1.6,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          MathScene(
            question: demonstration,
            revealAnswer: true,
            replayKey: '$step:$replay',
          ),
          const SizedBox(height: 16),
          Text(
            demonstration.explanation.inLanguage(store.language),
            style: const TextStyle(
              fontSize: 21,
              height: 1.6,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    if (step == 3 || step == 4) {
      final question = activeQuestion;
      final correct = selected == question.correctIndex;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            step == 3
                ? tr(
                    'Try the idea with a little help.',
                    'थोड्या मदतीने ही कल्पना वापरून पाहा.',
                  )
                : tr(
                    'A fresh example. Use what you have learned.',
                    'नवे उदाहरण. शिकलेली कल्पना वापर.',
                  ),
            style: const TextStyle(fontSize: 17, height: 1.5),
          ),
          const SizedBox(height: 12),
          Text(
            question.prompt.inLanguage(store.language),
            style: const TextStyle(
              fontSize: 22,
              height: 1.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          MathScene(
            question: question,
            interactive: !correct,
            revealAnswer: correct || hintLevel == 3,
            replayKey: '$step:$replay',
          ),
          const SizedBox(height: 16),
          _answers(
            question,
            selected,
            (value) => setState(() {
              if (step == 3) {
                guidedAnswer = value;
              } else {
                independentAnswer = value;
              }
            }),
          ),
          if (selected != null)
            AnswerFeedback(
              key: ValueKey('$step:${correct ? 'correct' : 'try'}'),
              correct: correct,
              explanation: correct
                  ? question.explanation.inLanguage(store.language)
                  : tr(
                      'A useful try. Look at the model, or open a hint, then choose again.',
                      'छान प्रयत्न. चित्र पाहा किंवा संकेत उघडा आणि पुन्हा उत्तर निवडा.',
                    ),
            ),
          if (hintLevel > 0)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: _ChapterHelpBox(
                text: hintLevel == 1
                    ? question.hint.inLanguage(store.language)
                    : hintLevel == 2
                    ? tr(
                        'Follow one step at a time. ${question.hint.en}',
                        'एकेक पायरी करून पाहा. ${question.hint.mr}',
                      )
                    : question.explanation.inLanguage(store.language),
              ),
            ),
          if (selected != null && !correct)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() {
                  if (step == 3) {
                    guidedAnswer = null;
                  } else {
                    independentAnswer = null;
                  }
                }),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(tr('Try again', 'पुन्हा प्रयत्न करा')),
              ),
            ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ChapterCompletionMark(),
        const SizedBox(height: 16),
        MathScene(
          question: checkQuestion,
          revealAnswer: true,
          replayKey: '$step:$replay',
        ),
        const SizedBox(height: 16),
        Text(
          lesson.recap.inLanguage(store.language),
          style: const TextStyle(
            fontSize: 21,
            height: 1.6,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          usedHelp
              ? tr(
                  'You explored the idea and completed a fresh example with support. Replay whenever you like.',
                  'तू करून पाहिले आणि मदतीने नवे उदाहरण सोडवले. हवे तेव्हा पुन्हा पाहा.',
                )
              : tr(
                  'You explored the idea and solved a fresh example. Tell a friend how you did it.',
                  'तू करून पाहिले आणि नवे उदाहरण सोडवले. ते कसे सोडवले हे मित्राला सांग.',
                ),
          style: const TextStyle(fontSize: 17, height: 1.5),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () => Navigator.push<void>(
                context,
                _chapterPageRoute(
                  ChapterSessionPage(
                    chapter: widget.chapter,
                    mode: ChapterSessionMode.practice,
                  ),
                ),
              ),
              icon: const Icon(Icons.edit_outlined),
              label: Text(tr('Practice', 'सराव')),
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.push<void>(
                context,
                _chapterPageRoute(
                  ChapterSessionPage(
                    chapter: widget.chapter,
                    mode: ChapterSessionMode.quiz,
                  ),
                ),
              ),
              icon: const Icon(Icons.quiz_outlined),
              label: Text(tr('Start quiz', 'प्रश्नमंजुषा सुरू करा')),
            ),
          ],
        ),
      ],
    );
  }

  Widget _answers(
    ChapterQuestion question,
    int? value,
    ValueChanged<int> onSelect,
  ) => LayoutBuilder(
    builder: (context, c) {
      final width = c.maxWidth > 650 ? (c.maxWidth - 12) / 2 : c.maxWidth;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (var i = 0; i < question.options.length; i++)
            SizedBox(
              width: width,
              child: _ChapterChoiceOption(
                index: i,
                text: question.options[i].inLanguage(store.language),
                selected: value == i,
                onTap: () => onSelect(i),
              ),
            ),
        ],
      );
    },
  );

  Widget _controls() => Material(
    color: store.contrast ? Colors.white : LearningPalette.surface,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: LearningPalette.line)),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: step == 0
                ? () => Navigator.maybePop(context)
                : () {
                    setState(() {
                      step--;
                      hintLevel = 0;
                    });
                    _top();
                  },
            icon: const Icon(Icons.arrow_back_rounded),
            label: Text(tr('Back', 'मागे')),
          ),
          OutlinedButton.icon(
            onPressed: _replay,
            icon: const Icon(Icons.replay_rounded),
            label: Text(tr('Replay this step', 'हा टप्पा पुन्हा पाहा')),
          ),
          if (step == 3 || step == 4)
            OutlinedButton.icon(
              onPressed: () => setState(() {
                hintLevel = hintLevel == 3 ? 0 : hintLevel + 1;
                usedHelp = true;
              }),
              icon: const Icon(Icons.lightbulb_outline_rounded),
              label: Text(
                hintLevel == 3
                    ? tr('Hide hint', 'संकेत लपवा')
                    : hintLevel == 0
                    ? tr('Hint', 'संकेत')
                    : tr('More help', 'आणखी मदत'),
              ),
            ),
          if (step < 5)
            FilledButton.icon(
              key: const ValueKey('lesson-next'),
              onPressed: canAdvance ? _next : null,
              icon: const Icon(Icons.arrow_forward_rounded),
              iconAlignment: IconAlignment.end,
              label: Text(
                step == 4
                    ? tr('Continue to recap', 'उजळणीकडे चला')
                    : tr('Next step', 'पुढचा टप्पा'),
              ),
            ),
        ],
      ),
    ),
  );
}

class _LessonStageRail extends StatelessWidget {
  final int step;
  const _LessonStageRail({required this.step});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (var i = 0; i < 6; i++)
          Container(
            key: ValueKey('lesson-stage-$i'),
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: i == step
                  ? LearningPalette.teal
                  : i < step
                  ? const Color(0xFFE6EDDE)
                  : LearningPalette.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: i == step ? LearningPalette.teal : LearningPalette.line,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  i < step
                      ? Icons.check_rounded
                      : i == step
                      ? Icons.circle
                      : Icons.circle_outlined,
                  size: 16,
                  color: i == step ? Colors.white : LearningPalette.teal,
                ),
                const SizedBox(width: 7),
                Text(
                  '${i + 1}. ${[tr('Story', 'गोष्ट'), tr('Explore', 'कृती'), tr('Maths', 'गणित'), tr('Together', 'मदतीने'), tr('Your try', 'स्वतः'), tr('Recap', 'उजळणी')][i]}',
                  style: TextStyle(
                    color: i == step ? Colors.white : LearningPalette.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
