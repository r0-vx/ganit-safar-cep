part of 'main.dart';

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
  final List<int?> answers = [];
  final Set<int> submitted = {};
  final Map<String, GlobalKey> sceneKeys = {};
  ClassroomActivity? monitoring;
  int current = 0, helpLevel = 0;
  bool showHint = false, finished = false, showMistakeReview = false;

  bool get isQuiz => widget.mode == ChapterSessionMode.quiz;
  bool _answered(int index) =>
      answers[index] != null && (!isQuiz || submitted.contains(index));
  int get correctCount => List.generate(questions.length, (i) => i)
      .where((i) => _answered(i) && answers[i] == questions[i].correctIndex)
      .length;
  int get answeredCount =>
      List.generate(questions.length, (i) => i).where(_answered).length;
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

  void _select(int index) {
    if (submitted.contains(current) ||
        (!isQuiz && answers[current] == questions[current].correctIndex))
      return;
    setState(() => answers[current] = index);
  }

  void _submit() {
    if (answers[current] == null || submitted.contains(current)) return;
    setState(() => submitted.add(current));
  }

  void _advance() {
    if (isQuiz && answers[current] != null && !submitted.contains(current))
      return;
    if (!isQuiz && answers[current] != questions[current].correctIndex) return;
    if (current < questions.length - 1) {
      setState(() {
        current++;
        showHint = false;
        helpLevel = 0;
      });
    } else {
      setState(() {
        finished = true;
        showHint = false;
        showMistakeReview = false;
      });
      stopwatch.stop();
      central.completeActivity(monitoring);
    }
    _scrollToTop();
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
      submitted.clear();
      sceneKeys.clear();
      showHint = false;
      helpLevel = 0;
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
      backgroundColor: store.contrast ? Colors.white : LearningPalette.paper,
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
                padding: EdgeInsets.fromLTRB(
                  MediaQuery.sizeOf(context).width < 600 ? 16 : 28,
                  18,
                  MediaQuery.sizeOf(context).width < 600 ? 16 : 28,
                  30,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: finished ? _resultBody() : _questionBody(),
                  ),
                ),
              ),
            ),
            if (!finished && questions.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: store.contrast
                      ? Colors.white
                      : LearningPalette.surface,
                  border: Border(
                    top: BorderSide(
                      color: store.contrast
                          ? Colors.black
                          : LearningPalette.line,
                    ),
                  ),
                ),
                child: _questionActions(
                  questions[current],
                  answers[current],
                  isQuiz && submitted.contains(current),
                ),
              ),
          ],
        ),
      ),
    ),
  );

  Widget _questionBody() {
    if (questions.isEmpty)
      return LearningSurface(
        child: Column(
          children: [
            const Icon(Icons.menu_book_outlined, size: 48),
            Text(tr('No questions available yet', 'प्रश्न अजून उपलब्ध नाहीत')),
            Text(
              tr(
                'Return to the chapter lesson and try again later.',
                'धड्याकडे परत जा आणि नंतर पुन्हा प्रयत्न करा.',
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text(tr('Back', 'मागे')),
            ),
          ],
        ),
      );
    final question = questions[current];
    final selected = answers[current];
    final correct = selected == question.correctIndex;
    final locked = isQuiz && submitted.contains(current);
    final title = tr(
      'Chapter ${widget.chapter.number} • ${widget.chapter.title.en}',
      'धडा ${widget.chapter.number} • ${widget.chapter.title.mr}',
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LearningModeHeader(
          title: title,
          subtitle: tr(
            'Class ${widget.chapter.grade} • ${isQuiz ? 'Quiz' : 'Practice'} • Question ${current + 1} of ${questions.length}',
            'इयत्ता ${widget.chapter.grade} • ${isQuiz ? 'प्रश्नमंजुषा' : 'सराव'} • प्रश्न ${current + 1} / ${questions.length}',
          ),
          icon: isQuiz ? Icons.fact_check_outlined : Icons.edit_outlined,
        ),
        const SizedBox(height: 18),
        _SessionQuestionTrack(
          current: current,
          total: questions.length,
          answered: answers,
          submitted: submitted,
          quiz: isQuiz,
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, c) {
            final questionCard = LearningSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        isQuiz
                            ? Icons.help_outline_rounded
                            : Icons.touch_app_outlined,
                        color: LearningPalette.teal,
                        size: 23,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tr(
                            'Question ${current + 1}',
                            'प्रश्न ${current + 1}',
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: LearningPalette.teal,
                          ),
                        ),
                      ),
                      if (locked)
                        const Icon(Icons.lock_outline_rounded, size: 22),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    question.prompt.inLanguage(store.language),
                    style: TextStyle(
                      fontSize: c.maxWidth < 600 ? 22 : 26,
                      fontWeight: FontWeight.w800,
                      height: 1.5,
                      color: LearningPalette.ink,
                    ),
                  ),
                  const SizedBox(height: 18),
                  MathScene(
                    key: sceneKeys.putIfAbsent(question.id, () => GlobalKey()),
                    question: question,
                    interactive: !isQuiz,
                    revealAnswer: !isQuiz && correct,
                    replayKey: question.id,
                  ),
                  const SizedBox(height: 18),
                  _answerOptions(
                    question,
                    selected,
                    locked || (!isQuiz && correct),
                  ),
                  if (!isQuiz && selected != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      correct
                          ? tr(
                              'Well done. You found it!',
                              'छान! योग्य उत्तर सापडले.',
                            )
                          : tr(
                              'Good try. Take another look and choose again.',
                              'छान प्रयत्न. पुन्हा पाहा आणि उत्तर बदला.',
                            ),
                      style: TextStyle(
                        color: correct
                            ? LearningPalette.teal
                            : LearningPalette.clay,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    AnswerFeedback(
                      key: ValueKey('feedback:${question.id}:$correct'),
                      correct: correct,
                      explanation:
                          (correct ? question.explanation : question.hint)
                              .inLanguage(store.language),
                    ),
                  ],
                  if (isQuiz)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            locked ? Icons.lock_outline : Icons.info_outline,
                            size: 20,
                            color: LearningPalette.teal,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              locked
                                  ? tr(
                                      'Answer submitted. Your score appears at the end of this session.',
                                      'उत्तर निश्चित केले. या सत्राच्या शेवटी तुमचे गुण दिसतील.',
                                    )
                                  : tr(
                                      'Choose an answer, then submit it. Answers are explained after the quiz.',
                                      'उत्तर निवडा आणि निश्चित करा. प्रश्नमंजुषेनंतर उत्तरांचे स्पष्टीकरण दिसेल.',
                                    ),
                              style: const TextStyle(fontSize: 14, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
            final help = _learningHelp(question);
            final sideBySide =
                showHint &&
                !isQuiz &&
                c.maxWidth >= 1040 &&
                MediaQuery.textScalerOf(context).scale(1) <= 1.4;
            if (sideBySide)
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: questionCard),
                  const SizedBox(width: 18),
                  Expanded(flex: 4, child: help),
                ],
              );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                questionCard,
                if (showHint && !isQuiz) ...[const SizedBox(height: 16), help],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _answerOptions(ChapterQuestion question, int? selected, bool locked) =>
      LayoutBuilder(
        builder: (context, c) {
          final split =
              c.maxWidth >= 640 &&
              question.options.every(
                (o) => o.inLanguage(store.language).length < 90,
              );
          final width = split ? (c.maxWidth - 12) / 2 : c.maxWidth;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (int i = 0; i < question.options.length; i++)
                SizedBox(
                  key: ValueKey('session-answer-$i'),
                  width: width,
                  child: Semantics(
                    enabled: !locked,
                    child: AbsorbPointer(
                      absorbing: locked,
                      child: _ChapterChoiceOption(
                        index: i,
                        text: question.options[i].inLanguage(store.language),
                        selected: selected == i,
                        onTap: () => _select(i),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );

  Widget _learningHelp(ChapterQuestion question) => LearningSurface(
    color: store.contrast ? Colors.white : const Color(0xFFF4EAD6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: LearningPalette.clay),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                tr('Learning help', 'अभ्यास मदत'),
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              tooltip: tr('Close help', 'मदत बंद करा'),
              onPressed: () => setState(() => showHint = false),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _helpParagraph(
          tr('The idea', 'गणिती कल्पना'),
          lesson.concept.inLanguage(store.language),
        ),
        _helpParagraph(
          tr('A small clue', 'छोटा संकेत'),
          question.hint.inLanguage(store.language),
        ),
        if (helpLevel >= 1)
          _helpParagraph(
            tr('Worked example', 'सोडवलेले उदाहरण'),
            lesson.workedExample.inLanguage(store.language),
          ),
        if (helpLevel >= 2)
          _helpParagraph(
            tr('Check your answer', 'उत्तर तपासा'),
            question.explanation.inLanguage(store.language),
          ),
        if (helpLevel < 2)
          OutlinedButton.icon(
            onPressed: () => setState(() => helpLevel++),
            icon: const Icon(Icons.add_circle_outline),
            label: Text(tr('Show another step', 'पुढची पायरी दाखवा')),
          ),
        Text(
          tr(
            'Your question and answer stay in place.',
            'तुमचा प्रश्न आणि उत्तर तसेच राहतील.',
          ),
          style: const TextStyle(fontSize: 13, height: 1.5),
        ),
      ],
    ),
  );

  Widget _helpParagraph(String heading, String body) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: LearningPalette.teal,
          ),
        ),
        const SizedBox(height: 5),
        Text(body, style: const TextStyle(fontSize: 17, height: 1.55)),
      ],
    ),
  );

  Widget _questionActions(
    ChapterQuestion question,
    int? selected,
    bool locked,
  ) => Wrap(
    spacing: 12,
    runSpacing: 12,
    children: [
      if (!isQuiz && selected != null && selected != question.correctIndex)
        OutlinedButton.icon(
          onPressed: () => setState(() {
            answers[current] = null;
            showHint = false;
            helpLevel = 0;
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
              helpLevel = 0;
            });
            _scrollToTop();
          },
          icon: const Icon(Icons.arrow_back_rounded),
          label: Text(tr('Previous', 'मागे')),
        ),
      if (isQuiz && selected != null && !locked)
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.check_rounded),
          label: Text(tr('Submit answer', 'उत्तर निश्चित करा')),
        )
      else
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
  );

  Widget _resultBody() {
    final chapter = widget.chapter;
    final elapsed = stopwatch.elapsed;
    final timeText =
        '${elapsed.inMinutes.toString().padLeft(2, '0')}:${elapsed.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LearningModeHeader(
          title: isQuiz
              ? tr('Current Session Result', 'या सत्राचा निकाल')
              : tr('Practice session complete', 'सरावाचे सत्र पूर्ण'),
          subtitle: tr(
            'Class ${chapter.grade} • Chapter ${chapter.number}: ${chapter.title.en}',
            'इयत्ता ${chapter.grade} • धडा ${chapter.number}: ${chapter.title.mr}',
          ),
          icon: Icons.workspace_premium_outlined,
        ),
        const SizedBox(height: 20),
        LearningSurface(
          child: LayoutBuilder(
            builder: (context, c) {
              final summary = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isQuiz
                        ? tr(
                            'Your quiz is complete.',
                            'तुमची प्रश्नमंजुषा पूर्ण झाली.',
                          )
                        : tr(
                            'You worked through ${questions.length} questions.',
                            'तुम्ही ${questions.length} प्रश्न सोडवले.',
                          ),
                    style: const TextStyle(
                      fontSize: 25,
                      height: 1.45,
                      fontWeight: FontWeight.w800,
                      color: LearningPalette.ink,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (isQuiz)
                    Semantics(
                      label: tr('$stars of 3 stars', '३ पैकी $stars तारे'),
                      child: Row(
                        children: [
                          for (int i = 0; i < 3; i++)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                i < stars
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 35,
                                color: store.contrast
                                    ? Colors.black
                                    : LearningPalette.amber,
                              ),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    tr(
                      'Answered $answeredCount of ${questions.length} • Correct $correctCount • Incorrect $incorrectCount • Skipped $skippedCount',
                      'सोडवले $answeredCount / ${questions.length} • बरोबर $correctCount • चूक $incorrectCount • सोडले $skippedCount',
                    ),
                    style: const TextStyle(fontSize: 17, height: 1.6),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    isQuiz
                        ? tr(
                            'This result belongs to the current session. It is not saved to a student history.',
                            'हा निकाल फक्त या सत्रासाठी आहे. विद्यार्थ्यांच्या कायमच्या इतिहासात तो जतन होत नाही.',
                          )
                        : tr(
                            'Keep the idea with you. Try it with things around your classroom.',
                            'ही कल्पना लक्षात ठेवा. वर्गातील वस्तू वापरून पुन्हा पाहा.',
                          ),
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: LearningPalette.teal,
                    ),
                  ),
                ],
              );
              if (c.maxWidth >= 700)
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _SessionScoreRing(
                      value: accuracy,
                      correct: correctCount,
                      total: questions.length,
                    ),
                    const SizedBox(width: 32),
                    Expanded(child: summary),
                    if (c.maxWidth >= 980)
                      const LearningArtwork(
                        asset: 'assets/art/mascot.png',
                        width: 140,
                        height: 160,
                      ),
                  ],
                );
              return Column(
                children: [
                  _SessionScoreRing(
                    value: accuracy,
                    correct: correctCount,
                    total: questions.length,
                  ),
                  const SizedBox(height: 22),
                  summary,
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _ChapterResultTile(
              title: tr('Correct', 'बरोबर'),
              value: '$correctCount',
              icon: Icons.check_circle_outline,
            ),
            _ChapterResultTile(
              title: tr('Accuracy', 'अचूकता'),
              value: '${(accuracy * 100).round()}%',
              icon: Icons.track_changes_rounded,
            ),
            if (isQuiz)
              _ChapterResultTile(
                title: tr('Stars', 'तारे'),
                value: '$stars / 3',
                icon: Icons.star_outline_rounded,
              ),
            _ChapterResultTile(
              title: tr('Time', 'वेळ'),
              value: timeText,
              icon: Icons.timer_outlined,
            ),
          ],
        ),
        const SizedBox(height: 18),
        LearningSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                tr('This chapter', 'हा धडा'),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                chapter.title.inLanguage(store.language),
                style: const TextStyle(fontSize: 19, height: 1.4),
              ),
              const SizedBox(height: 13),
              LinearProgressIndicator(
                value: accuracy,
                minHeight: 10,
                borderRadius: BorderRadius.circular(10),
                color: LearningPalette.teal,
                backgroundColor: const Color(0xFFE0E6DE),
              ),
              const SizedBox(height: 10),
              Text(
                isQuiz && (incorrectCount > 0 || skippedCount > 0)
                    ? tr(
                        'A little more practice will help. Review the questions below.',
                        'आणखी थोडा सराव उपयोगी ठरेल. खाली प्रश्नांचा आढावा घ्या.',
                      )
                    : tr(
                        'You have worked through this chapter’s questions.',
                        'तुम्ही या धड्यातील प्रश्नांचा सराव केला.',
                      ),
                style: const TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
        if (isQuiz) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () =>
                setState(() => showMistakeReview = !showMistakeReview),
            icon: Icon(
              showMistakeReview
                  ? Icons.visibility_off_rounded
                  : Icons.fact_check_outlined,
            ),
            label: Text(
              showMistakeReview
                  ? tr('Hide mistake review', 'चुकांचा आढावा लपवा')
                  : tr('Review mistakes', 'चुका पाहा'),
            ),
          ),
          if (showMistakeReview) ...[
            const SizedBox(height: 16),
            for (int i = 0; i < questions.length; i++)
              if (answers[i] != questions[i].correctIndex)
                _ChapterMistakeReview(
                  number: i + 1,
                  question: questions[i],
                  answer: answers[i],
                ),
            if (incorrectCount == 0 && skippedCount == 0)
              AnswerFeedback(
                correct: true,
                explanation: tr(
                  'Every answer was correct. Great work!',
                  'सर्व उत्तरे बरोबर. छान काम!',
                ),
              ),
          ],
        ],
        const SizedBox(height: 20),
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
                icon: const Icon(Icons.edit_outlined),
                label: Text(tr('Go to Practice', 'सराव करा')),
              ),
            OutlinedButton.icon(
              onPressed: () => Navigator.maybePop(context),
              icon: Icon(
                isQuiz ? Icons.check_rounded : Icons.menu_book_outlined,
              ),
              label: Text(isQuiz ? tr('Finish', 'पूर्ण') : tr('Back', 'मागे')),
            ),
          ],
        ),
      ],
    );
  }
}

class _SessionQuestionTrack extends StatelessWidget {
  final int current, total;
  final List<int?> answered;
  final Set<int> submitted;
  final bool quiz;
  const _SessionQuestionTrack({
    required this.current,
    required this.total,
    required this.answered,
    required this.submitted,
    required this.quiz,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    label: tr(
      'Question ${current + 1} of $total',
      'प्रश्न ${current + 1} / $total',
    ),
    child: Row(
      children: [
        for (int i = 0; i < total; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == total - 1 ? 0 : 8),
              child: AnimatedContainer(
                duration: Duration(milliseconds: store.reducedMotion ? 0 : 180),
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: i == current
                      ? LearningPalette.clay
                      : (quiz ? submitted.contains(i) : answered[i] != null)
                      ? LearningPalette.teal
                      : const Color(0xFFD9DDD4),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _SessionScoreRing extends StatelessWidget {
  final double value;
  final int correct, total;
  const _SessionScoreRing({
    required this.value,
    required this.correct,
    required this.total,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    label: tr('Score: $correct of $total', 'गुण: $correct / $total'),
    child: SizedBox(
      width: 170,
      height: 170,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 11,
              backgroundColor: const Color(0xFFE3E7DC),
              color: store.contrast ? Colors.black : LearningPalette.teal,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$correct / $total',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: LearningPalette.ink,
                ),
              ),
              Text(
                tr('Score', 'गुण'),
                style: const TextStyle(
                  fontSize: 15,
                  color: LearningPalette.teal,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
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
    constraints: const BoxConstraints(minWidth: 132, minHeight: 102),
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
    decoration: BoxDecoration(
      color: store.contrast ? Colors.white : const Color(0xFFEEEDE4),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: store.contrast ? Colors.black : const Color(0xFFD9DDD1),
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 23, color: LearningPalette.teal),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 3),
        Text(title, style: const TextStyle(fontSize: 14, height: 1.4)),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: LearningSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '$number. ${question.prompt.inLanguage(store.language)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              tr('Your answer: $chosen', 'तुमचे उत्तर: $chosen'),
              style: const TextStyle(height: 1.5),
            ),
            const SizedBox(height: 5),
            Text(
              tr('Answer: $correct', 'योग्य उत्तर: $correct'),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: LearningPalette.teal,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            MathScene(
              question: question,
              revealAnswer: true,
              replayKey: 'review:${question.id}',
            ),
            const SizedBox(height: 12),
            Text(
              question.explanation.inLanguage(store.language),
              style: const TextStyle(fontSize: 17, height: 1.55),
            ),
          ],
        ),
      ),
    );
  }
}
