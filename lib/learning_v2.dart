part of 'main.dart';

class ResponsiveHome extends StatelessWidget {
  final ValueChanged<String> onGo;
  final VoidCallback onProgress, onTeacher;
  const ResponsiveHome({
    super.key,
    required this.onGo,
    required this.onProgress,
    required this.onTeacher,
  });
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      padding: EdgeInsets.all(constraints.maxWidth < 600 ? 16 : 30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LearningSurface(
                padding: EdgeInsets.zero,
                child: LayoutBuilder(
                  builder: (context, c) {
                    final wide = c.maxWidth >= 850;
                    final copy = Padding(
                      padding: EdgeInsets.all(wide ? 36 : 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 3,
                                color: LearningPalette.clay,
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  tr(
                                    'OUR MATHEMATICS CLASSROOM',
                                    'आपला गणित वर्ग',
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w800,
                                    color: LearningPalette.clay,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Text(
                            tr(
                              'Big adventures.\nLittle numbers.',
                              'मोठी सफर.\nछोट्या संख्या.',
                            ),
                            style: TextStyle(
                              fontSize: wide ? 43 : 30,
                              height: 1.2,
                              fontWeight: FontWeight.w900,
                              color: store.contrast
                                  ? Colors.black
                                  : LearningPalette.ink,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            tr(
                              'Meet Mira and Ravi. Count, play and learn together.',
                              'मीरा आणि रवीसोबत मोजा, खेळा आणि शिका.',
                            ),
                            style: const TextStyle(fontSize: 18, height: 1.6),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: () => onGo('learn'),
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: Text(tr('Let’s explore', 'चला शिकूया')),
                          ),
                        ],
                      ),
                    );
                    final artwork = ClipRRect(
                      borderRadius: BorderRadius.circular(19),
                      child: LearningArtwork(
                        asset: 'assets/art/classroom_story.png',
                        height: wide ? 365 : 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    );
                    return wide
                        ? Row(
                            children: [
                              Expanded(child: copy),
                              Expanded(child: artwork),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [copy, artwork],
                          );
                  },
                ),
              ),
              const SizedBox(height: 26),
              LearningModeHeader(
                title: tr('A little maths, every day.', 'दररोज थोडे गणित.'),
                subtitle: tr(
                  'Choose how you would like to begin.',
                  'आज कशी सुरुवात करायची ते निवडा.',
                ),
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, c) {
                  final columns = c.maxWidth >= 720 ? 3 : 1;
                  final width = (c.maxWidth - (columns - 1) * 16) / columns;
                  final paths = [
                    (
                      'learn',
                      Icons.auto_stories_outlined,
                      'Learn',
                      'शिका',
                      'See it. Move it. Understand it.',
                      'पाहा. हाताळा. समजून घ्या.',
                      LearningPalette.teal,
                    ),
                    (
                      'practice',
                      Icons.edit_outlined,
                      'Practice',
                      'सराव',
                      'A little help, then a fresh try.',
                      'थोडी मदत, मग नवा प्रयत्न.',
                      LearningPalette.blue,
                    ),
                    (
                      'quiz',
                      Icons.flag_outlined,
                      'Quiz',
                      'प्रश्नमंजुषा',
                      'Put your ideas to the test.',
                      'शिकलेले वापरून पाहा.',
                      LearningPalette.clay,
                    ),
                  ];
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (var i = 0; i < paths.length; i++)
                        SizedBox(
                          width: width,
                          child: LearningSurface(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      paths[i].$2,
                                      size: 30,
                                      color: paths[i].$7,
                                    ),
                                    const Spacer(),
                                    Text(
                                      '0${i + 1}',
                                      style: TextStyle(
                                        color: paths[i].$7,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  tr(paths[i].$5, paths[i].$6),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                  onPressed: () => onGo(paths[i].$1),
                                  icon: const Icon(
                                    Icons.arrow_forward,
                                    size: 20,
                                  ),
                                  label: Text(tr(paths[i].$3, paths[i].$4)),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              LearningSurface(
                color: const Color(0xFFE8EDDF),
                child: LayoutBuilder(
                  builder: (context, c) {
                    final text = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('Teach by chapter', 'पाठानुसार शिकवा'),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: LearningPalette.ink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tr(
                            'Choose your class and open a familiar textbook chapter. All 79 chapter names are ready to browse.',
                            'इयत्ता निवडा आणि पाठ्यपुस्तकातील परिचित पाठ उघडा. सर्व ७९ पाठांची नावे पाहा.',
                          ),
                          style: const TextStyle(height: 1.6, fontSize: 17),
                        ),
                      ],
                    );
                    final button = OutlinedButton.icon(
                      onPressed: () => onGo('chapters'),
                      icon: const Icon(Icons.library_books_outlined),
                      label: Text(
                        tr('Open chapter directory', 'पाठांची यादी उघडा'),
                      ),
                    );
                    return c.maxWidth > 850
                        ? Row(
                            children: [
                              Expanded(child: text),
                              const SizedBox(width: 24),
                              button,
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              text,
                              const SizedBox(height: 16),
                              button,
                            ],
                          );
                  },
                ),
              ),
              const SizedBox(height: 24),
              LearningSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.spa_outlined,
                          color: LearningPalette.teal,
                          size: 30,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr('Your learning garden', 'तुमची अभ्यासबाग'),
                                style: const TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                tr(
                                  '${store.stars} stars • ${store.completed.length + store.completedChapters.length} lessons',
                                  '${store.stars} तारे • ${store.completed.length + store.completedChapters.length} धडे',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        TextButton.icon(
                          onPressed: onProgress,
                          icon: const Icon(Icons.bar_chart),
                          label: Text(tr('My progress', 'माझी प्रगती')),
                        ),
                        TextButton.icon(
                          onPressed: onTeacher,
                          icon: const Icon(Icons.school_outlined),
                          label: Text(tr('Teacher mode', 'शिक्षक मोड')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                tr(
                  '79 textbook chapter titles • Original classroom activities',
                  'पाठ्यपुस्तकातील ७९ पाठांची नावे • मूळ वर्गकृती',
                ),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

String mathSentence(Question q, String topic) => switch (topic) {
  'add' || 'money' || 'data' || 'word' => '${q.a} + ${q.b} = ${q.answer}',
  'subtract' => '${q.a} − ${q.b} = ${q.answer}',
  'multiply' => '${q.a} × ${q.b} = ${q.answer}',
  'divide' => '${q.a} ÷ ${q.b} = ${q.answer}',
  'fraction' => '${q.a}/${q.b}',
  'place' => '${q.a} = ${q.a ~/ 10} × 10 + ${q.a % 10}',
  _ => '${q.answer}',
};

class StoryLessonPage extends StatefulWidget {
  final Topic topic;
  final VoidCallback onDone, onQuiz;
  final bool teacher;
  const StoryLessonPage({
    super.key,
    required this.topic,
    required this.onDone,
    required this.onQuiz,
    this.teacher = false,
  });
  @override
  State<StoryLessonPage> createState() => _StoryLessonState();
}

class _StoryLessonState extends State<StoryLessonPage> {
  int scene = 0, replay = 0;
  bool hint = false, steps = false, paused = false, showAnswer = false;
  late final int grade = store.grade;
  late final q = makeQuestion(widget.topic.id, grade, 0, 'choice');
  late final check = makeQuestion(
    widget.topic.id,
    grade,
    1,
    richType(widget.topic.id),
  );
  late final outcome = outcomeFor(grade, widget.topic.id);
  ClassroomActivity? monitoring;
  @override
  void initState() {
    super.initState();
    monitoring = central.beginActivity('learn', grade, widget.topic.id);
  }

  @override
  void dispose() {
    central.leaveActivity(monitoring);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 16 : 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Heading(
          '${tr('Class', 'इयत्ता')} $grade • ${widget.topic.name.inLanguage(store.language)}',
          lessonStory(widget.topic.id).inLanguage(store.language),
        ),
        const SizedBox(height: 16),
        Panel(
          child: Column(
            children: [
              if (scene == 0) ...[
                Text(
                  grade == 1
                      ? tr(
                          '🧒 Mira needs your help!',
                          '🧒 मीराला तुमची मदत हवी आहे!',
                        )
                      : grade == 2
                      ? tr(
                          '🧒 Ravi is getting the classroom ready.',
                          '🧒 रवी वर्गाची तयारी करत आहे.',
                        )
                      : grade == 3
                      ? tr(
                          '🧒 Friends are planning a village fair.',
                          '🧒 मित्र गावच्या जत्रेची तयारी करत आहेत.',
                        )
                      : tr(
                          '🧒 Our class is solving a market challenge.',
                          '🧒 आपला वर्ग बाजारातील गणित सोडवत आहे.',
                        ),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  q.prompt.inLanguage(store.language),
                  style: const TextStyle(fontSize: 22),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (grade == 1 && widget.topic.id == 'add')
                  Text(
                    reviewedMangoCounting.inLanguage(store.language),
                    semanticsLabel: reviewedMangoCounting.inLanguage(
                      store.language,
                    ),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                model(q, animated: false),
              ] else if (scene == 1) ...[
                Text(
                  outcome.definition.inLanguage(store.language),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                model(q, animated: true),
                const SizedBox(height: 16),
                Text(
                  mathSentence(q, widget.topic.id),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: green,
                  ),
                ),
                Text(
                  q.explanation.inLanguage(store.language),
                  textAlign: TextAlign.center,
                ),
                if (['add', 'subtract'].contains(widget.topic.id))
                  TickerMode(
                    enabled: !paused && !store.reducedMotion,
                    child: NumberLine(
                      q: q,
                      topic: widget.topic.id,
                      animate: true,
                    ),
                  ),
              ] else if (scene == 2) ...[
                Text(
                  tr('Let’s solve one together.', 'एक उदाहरण एकत्र सोडवूया.'),
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                QuestionActivity(
                  key: ValueKey('guided:$replay'),
                  q: makeQuestion(
                    widget.topic.id,
                    grade,
                    0,
                    richType(widget.topic.id),
                  ),
                  topic: widget.topic.id,
                  practice: true,
                  onAnswer: (ok) {
                    if (ok) setState(() => scene = 3);
                  },
                ),
              ] else if (scene == 3) ...[
                Text(
                  tr('One for you!', 'आता तुमची पाळी!'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                QuestionActivity(
                  key: ValueKey('check:$replay'),
                  q: check,
                  topic: widget.topic.id,
                  practice: true,
                  onAnswer: (ok) {
                    if (ok) {
                      central.completeActivity(monitoring);
                      store.complete(widget.topic.id);
                      setState(() => scene = 4);
                    }
                  },
                ),
              ] else ...[
                if (!store.reducedMotion) const Celebration(),
                const Text('🧒 ⭐ 🏅', style: TextStyle(fontSize: 52)),
                Text(
                  tr('Well done!', 'शाब्बास!'),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: green,
                  ),
                ),
                Text(
                  outcome.objective.inLanguage(store.language),
                  textAlign: TextAlign.center,
                ),
                Text(
                  mathSentence(check, widget.topic.id),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  tr(
                    'Your badge and 3 stars are saved.',
                    'तुमचे पदक आणि ३ तारे जतन झाले.',
                  ),
                ),
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
              ],
              if (hint && scene < 4)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    outcome.hint.inLanguage(store.language),
                    style: const TextStyle(fontSize: 20, color: orange),
                  ),
                ),
              if (steps || showAnswer)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '${tr('1. Look at the quantities. 2. Use the rule. 3. Check with the picture.', '१. राशी पाहा. २. नियम वापरा. ३. चित्राशी उत्तर तपासा.')}\n${q.explanation.inLanguage(store.language)}',
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                if (scene == 0) {
                  widget.onDone();
                } else {
                  setState(() => scene--);
                }
              },
              icon: const Icon(Icons.arrow_back),
              label: Text(tr('Back', 'मागे')),
            ),
            OutlinedButton.icon(
              onPressed: () => setState(() => replay++),
              icon: const Icon(Icons.replay),
              label: Text(tr('Replay', 'पुन्हा पाहा')),
            ),
            OutlinedButton.icon(
              onPressed: () => setState(() => hint = !hint),
              icon: const Icon(Icons.lightbulb_outline),
              label: Text(tr('Hint', 'संकेत')),
            ),
            TextButton(
              onPressed: () => setState(() => steps = !steps),
              child: Text(tr('Step-by-step', 'पायरीपायरीने')),
            ),
            if (scene < 2)
              FilledButton.icon(
                onPressed: () => setState(() {
                  scene++;
                  hint = false;
                }),
                icon: const Icon(Icons.arrow_forward),
                label: Text(tr('Next', 'पुढे')),
              ),
            if (scene >= 2)
              TextButton(
                onPressed: () => setState(() {
                  replay++;
                  if (scene == 4) scene = 2;
                }),
                child: Text(tr('Try again', 'पुन्हा प्रयत्न करा')),
              ),
            if (widget.teacher) ...[
              OutlinedButton(
                onPressed: () => setState(() => paused = !paused),
                child: Text(
                  paused ? tr('Play', 'चालू करा') : tr('Pause', 'थांबा'),
                ),
              ),
              OutlinedButton(
                onPressed: () => setState(() => showAnswer = !showAnswer),
                child: Text(tr('Show / hide answer', 'उत्तर दाखवा / लपवा')),
              ),
              if (scene < 3)
                OutlinedButton(
                  onPressed: () => setState(() => scene++),
                  child: Text(tr('Skip', 'वगळा')),
                ),
            ],
          ],
        ),
      ],
    ),
  );
  Widget model(Question question, {required bool animated}) => FittedBox(
    fit: BoxFit.scaleDown,
    child: SizedBox(
      width: 440,
      child: VisualBoard(
        key: ValueKey('$scene:$replay'),
        q: question,
        topic: widget.topic.id,
        animate: animated,
        paused: paused,
        interactive: scene == 0,
      ),
    ),
  );
}

String richType(String topic) => switch (topic) {
  'time' => 'clock',
  'fraction' => 'colour',
  'money' => 'coins',
  'shape' => 'construct',
  'data' => 'graph',
  'add' || 'subtract' => 'numberline',
  _ => 'choice',
};

class HelpCard extends StatelessWidget {
  final Question q;
  final String topic;
  const HelpCard({super.key, required this.q, required this.topic});
  @override
  Widget build(BuildContext context) {
    final o = outcomeFor(q.metadata?.grade ?? store.grade, topic);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          tr('Learning help', 'अभ्यास मदत'),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(o.definition.inLanguage(store.language)),
        const SizedBox(height: 12),
        Text(
          o.vocabularyText.inLanguage(store.language),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Text(
          mathSentence(q, topic),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: green,
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: 300,
            child: VisualBoard(q: q, topic: topic),
          ),
        ),
        const SizedBox(height: 12),
        Text(q.explanation.inLanguage(store.language)),
        const SizedBox(height: 12),
        Text(o.hint.inLanguage(store.language)),
        const SizedBox(height: 12),
        Text(
          '${tr('Watch out', 'लक्ष द्या')}: ${o.commonMistake.inLanguage(store.language)}',
        ),
        const SizedBox(height: 12),
        Text(
          tr(
            'Curriculum mapping needs review.',
            'अभ्यासक्रम जुळणीची पडताळणी आवश्यक.',
          ),
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

class PracticeSessionPage extends StatefulWidget {
  final String initialTopic;
  final bool focusTopic;
  const PracticeSessionPage({
    super.key,
    this.initialTopic = 'add',
    this.focusTopic = false,
  });
  @override
  State<PracticeSessionPage> createState() => _PracticeSessionPageState();
}

class _PracticeSessionPageState extends State<PracticeSessionPage> {
  late Set<String> selected = {widget.initialTopic};
  Set<String> types = {'choice', 'fill'};
  int difficulty = 1, count = 10, current = 0, correct = 0;
  bool started = false, help = false, solved = false, finished = false;
  String error = '';
  ClassroomActivity? monitoring;
  @override
  void dispose() {
    central.leaveActivity(monitoring);
    super.dispose();
  }

  List<Question> questions = [];
  @override
  void initState() {
    super.initState();
    final d = store.practiceDraft;
    if (d.isNotEmpty) {
      selected = List<String>.from(
        d['topics'] ?? [widget.initialTopic],
      ).where((x) => topics.any((t) => t.id == x)).toSet();
      if (selected.isEmpty || widget.focusTopic)
        selected = {widget.initialTopic};
      types = List<String>.from(
        d['types'] ?? ['choice'],
      ).where(questionTypes.contains).toSet();
      if (types.isEmpty) types = {'choice'};
      difficulty = (d['difficulty'] as int? ?? 1).clamp(1, 3);
      count = [5, 10, 15, 20].contains(d['count']) ? d['count'] : 10;
    }
  }

  void start() {
    try {
      questions = generateQuestions(
        topicIds: selected.toList(),
        grade: store.grade,
        count: count,
        types: types.toList(),
        difficulty: difficulty,
      );
      central.leaveActivity(monitoring);
      monitoring = central.beginActivity(
        'practice',
        store.grade,
        questions.first.metadata!.topic,
      );
      store.practiceDraft = {
        'topics': selected.toList(),
        'types': types.toList(),
        'difficulty': difficulty,
        'count': count,
      };
      store.save();
      setState(() {
        started = true;
        finished = false;
        current = 0;
        correct = 0;
        help = false;
        solved = false;
        error = '';
      });
    } catch (e) {
      setState(
        () => error = tr(
          'Choose fewer questions or add topics/types.',
          'प्रश्न कमी करा किंवा विषय / प्रकार वाढवा.',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 16 : 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Heading(
          tr('Practice together', 'एकत्र सराव करूया'),
          tr(
            'One question at a time. Help is always nearby.',
            'एकावेळी एक प्रश्न. मदत नेहमी जवळ आहे.',
          ),
        ),
        const SizedBox(height: 16),
        if (!started) ...[
          const GradePicker(),
          const SizedBox(height: 16),
          Text(classPlans[store.grade - 1].inLanguage(store.language)),
          const SizedBox(height: 16),
          Text(
            tr('Choose one or more topics', 'एक किंवा अधिक विषय निवडा'),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in topics)
                FilterChip(
                  label: Text(t.name.inLanguage(store.language)),
                  selected: selected.contains(t.id),
                  onSelected: (v) => setState(() {
                    v ? selected.add(t.id) : selected.remove(t.id);
                  }),
                ),
            ],
          ),
          Wrap(
            spacing: 20,
            children: [
              DropdownButton<int>(
                itemHeight: store.smartboard ? 72 : 56,
                value: difficulty,
                items: [
                  for (var i = 1; i <= 3; i++)
                    DropdownMenuItem(
                      value: i,
                      child: Text('${tr('Difficulty', 'काठिण्य')} $i'),
                    ),
                ],
                onChanged: (v) => setState(() => difficulty = v!),
              ),
              DropdownButton<int>(
                itemHeight: store.smartboard ? 72 : 56,
                value: count,
                items: [
                  for (final i in [5, 10, 15, 20])
                    DropdownMenuItem(
                      value: i,
                      child: Text('$i ${tr('questions', 'प्रश्न')}'),
                    ),
                ],
                onChanged: (v) => setState(() => count = v!),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in questionTypes)
                FilterChip(
                  label: Text(typeNames[type]!.inLanguage(store.language)),
                  selected: types.contains(type),
                  onSelected: (v) => setState(() {
                    v ? types.add(type) : types.remove(type);
                  }),
                ),
            ],
          ),
          if (error.isNotEmpty) Text(error),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: selected.isEmpty || types.isEmpty ? null : start,
            child: Text(tr('Start practice', 'सराव सुरू करा')),
          ),
        ] else if (finished) ...[
          Panel(
            child: Column(
              children: [
                if (!store.reducedMotion) const Celebration(),
                Text(
                  tr('Well done!', 'शाब्बास!'),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text('$correct / ${questions.length}'),
                FilledButton(
                  onPressed: () {
                    central.leaveActivity(monitoring);
                    setState(() => started = false);
                  },
                  child: Text(
                    tr('Choose another practice', 'दुसरा सराव निवडा'),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  '${current + 1} / ${questions.length} • ${topics.firstWhere((t) => t.id == questions[current].metadata!.topic).name.inLanguage(store.language)}',
                ),
              ),
              IconButton(
                tooltip: tr('Learning help', 'अभ्यास मदत'),
                isSelected: help,
                onPressed: () => setState(() => help = !help),
                icon: const Icon(Icons.help_outline),
              ),
            ],
          ),
          LayoutBuilder(
            builder: (context, c) {
              final question = Panel(
                child: QuestionActivity(
                  key: ValueKey('practice:$current'),
                  q: questions[current],
                  topic: questions[current].metadata!.topic,
                  practice: true,
                  onAnswer: (ok) {
                    if (ok && !solved) {
                      setState(() {
                        solved = true;
                        correct++;
                      });
                      store.stars++;
                      store.save();
                    }
                  },
                ),
              );
              final card = Panel(
                color: const Color(0xFFFFF7DB),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        tooltip: tr('Close help', 'मदत बंद करा'),
                        onPressed: () => setState(() => help = false),
                        icon: const Icon(Icons.close),
                      ),
                    ),
                    HelpCard(
                      q: questions[current],
                      topic: questions[current].metadata!.topic,
                    ),
                  ],
                ),
              );
              final sideBySide = c.maxWidth >= 850 && help;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: sideBySide ? (c.maxWidth - 16) * .6 : c.maxWidth,
                    child: question,
                  ),
                  if (help)
                    SizedBox(
                      width: sideBySide ? (c.maxWidth - 16) * .4 : c.maxWidth,
                      child: card,
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            children: [
              OutlinedButton(
                onPressed: () => setState(() => started = false),
                child: Text(tr('Change practice', 'सराव बदला')),
              ),
              FilledButton(
                onPressed: !solved
                    ? null
                    : () => setState(() {
                        if (current + 1 == questions.length) {
                          central.completeActivity(monitoring);
                          finished = true;
                        } else {
                          current++;
                          solved = false;
                          help = false;
                        }
                      }),
                child: Text(
                  current + 1 == questions.length
                      ? tr('Finish', 'पूर्ण करा')
                      : tr('Next question', 'पुढचा प्रश्न'),
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

class RichInteraction extends StatefulWidget {
  final Question q;
  final String topic;
  final ValueChanged<int> onAnswer;
  const RichInteraction({
    super.key,
    required this.q,
    required this.topic,
    required this.onAnswer,
  });
  @override
  State<RichInteraction> createState() => _RichInteractionState();
}

class _RichInteractionState extends State<RichInteraction> {
  int hour = 12, total = 0;
  Set<int> coloured = {}, sides = {};
  List<int> coins = [];
  @override
  Widget build(BuildContext context) {
    final q = widget.q;
    return Column(
      children: [
        if (q.type == 'numberline') ...[
          Text(tr('Tap the destination.', 'अंतिम संख्येवर टॅप करा.')),
          const SizedBox(height: 12),
          Wrap(
            spacing: 4,
            runSpacing: 8,
            children: [
              for (
                var n = max(0, min(q.a, q.answer) - 2);
                n <= max(q.a, q.answer) + 2;
                n++
              )
                OutlinedButton(
                  onPressed: () => widget.onAnswer(n),
                  child: Text('$n'),
                ),
            ],
          ),
        ] else if (q.type == 'clock') ...[
          Text(
            tr(
              'Set the short hand to ${q.a} o’clock.',
              'लहान काटा ${q.a} वाजतावर ठेवा.',
            ),
          ),
          SizedBox(
            width: 205,
            height: 205,
            child: Semantics(
              label: tr('Interactive hour clock', 'तास बदलणारे घड्याळ'),
              child: GestureDetector(
                onPanUpdate: (d) {
                  final angle = atan2(
                    d.localPosition.dx - 102.5,
                    -(d.localPosition.dy - 102.5),
                  );
                  setState(
                    () =>
                        hour = ((angle / (2 * pi) * 12).round() + 12) % 12 == 0
                        ? 12
                        : ((angle / (2 * pi) * 12).round() + 12) % 12,
                  );
                },
                child: CustomPaint(painter: ClockPainter(hour)),
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              for (var n = 1; n <= 12; n++)
                ChoiceChip(
                  label: Text('$n'),
                  selected: hour == n,
                  onSelected: (_) => setState(() => hour = n),
                ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => widget.onAnswer(hour),
            child: Text(tr('Check clock', 'घड्याळ तपासा')),
          ),
        ] else if (q.type == 'coins') ...[
          Text(
            tr(
              'Make ₹${q.answer} using these coins.',
              'या नाण्यांनी ₹${q.answer} तयार करा.',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              for (final n in [1, 2, 5, 10])
                OutlinedButton(
                  onPressed: () => setState(() => coins.add(n)),
                  child: Text('₹$n', style: const TextStyle(fontSize: 25)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${coins.map((n) => '₹$n').join(' + ')} = ₹${coins.fold<int>(0, (a, b) => a + b)}',
            style: const TextStyle(fontSize: 22),
          ),
          Wrap(
            spacing: 8,
            children: [
              TextButton(
                onPressed: () => setState(() => coins = []),
                child: Text(tr('Clear', 'पुसा')),
              ),
              FilledButton(
                onPressed: () =>
                    widget.onAnswer(coins.fold<int>(0, (a, b) => a + b)),
                child: Text(tr('Check price', 'किंमत तपासा')),
              ),
            ],
          ),
        ] else if (q.type == 'colour') ...[
          Text(
            tr(
              'Colour ${q.a} of ${q.b} equal parts.',
              '${q.b} समान भागांपैकी ${q.a} रंगवा.',
            ),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var i = 0; i < q.b; i++)
                Semantics(
                  label: tr('Part ${i + 1}', 'भाग ${i + 1}'),
                  selected: coloured.contains(i),
                  child: OutlinedButton(
                    onPressed: () => setState(
                      () => coloured.contains(i)
                          ? coloured.remove(i)
                          : coloured.add(i),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: coloured.contains(i)
                          ? const Color(0xFFFDE68A)
                          : Colors.white,
                    ),
                    child: Text(
                      coloured.contains(i) ? '✓' : '○',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
            ],
          ),
          Text('${coloured.length} / ${q.b}'),
          FilledButton(
            onPressed: () => widget.onAnswer(coloured.length),
            child: Text(tr('Check fraction', 'अपूर्णांक तपासा')),
          ),
        ] else if (q.type == 'construct') ...[
          Text(
            tr(
              'Build ${['a triangle', 'a square', 'a circle'][q.a]}. Add its straight sides.',
              '${['त्रिकोण', 'चौरस', 'वर्तुळ'][q.a]} तयार करा. त्याच्या सरळ बाजू जोडा.',
            ),
          ),
          SizedBox(
            width: 180,
            height: 180,
            child: CustomPaint(painter: ConstructPainter(sides.length, q.a)),
          ),
          Text(
            tr('${sides.length} straight sides', '${sides.length} सरळ बाजू'),
          ),
          DragTarget<int>(
            onAcceptWithDetails: (d) => setState(() {
              if (sides.length < 4) sides.add(sides.length);
            }),
            builder: (c, a, r) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: green),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tr(
                  'Drop a side here, or use Add side.',
                  'इथे बाजू सोडा किंवा बाजू जोडा वापरा.',
                ),
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              Draggable<int>(
                data: 1,
                feedback: const Material(
                  child: Text('━━━━', style: TextStyle(fontSize: 32)),
                ),
                child: OutlinedButton(
                  onPressed: sides.length >= 4
                      ? null
                      : () => setState(() => sides.add(sides.length)),
                  child: Text(tr('Add side', 'बाजू जोडा')),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => sides = {}),
                child: Text(tr('Clear', 'पुसा')),
              ),
              FilledButton(
                onPressed: () => widget.onAnswer(sides.length),
                child: Text(tr('Check shape', 'आकार तपासा')),
              ),
            ],
          ),
        ] else if (q.type == 'graph') ...[
          Text(
            tr(
              'Choose the graph for ${q.a} cows and ${q.b} goats.',
              '${q.a} गायी आणि ${q.b} शेळ्यांचा आलेख निवडा.',
            ),
          ),
          for (final pair in [
            (q.a, q.b, true),
            (q.a + 1, q.b, false),
            (q.a, q.b + 1, false),
          ])
            Padding(
              padding: const EdgeInsets.all(8),
              child: OutlinedButton(
                onPressed: () =>
                    widget.onAnswer(pair.$3 ? q.answer : q.answer + 1),
                child: Column(
                  children: [bar('🐄', pair.$1), bar('🐐', pair.$2)],
                ),
              ),
            ),
        ] else if (q.type == 'model') ...[
          Text(
            tr(
              'Choose the model that shows the answer.',
              'उत्तर दाखवणारे चित्र निवडा.',
            ),
          ),
          for (final n in [
            max(0, q.answer - 1),
            q.answer,
            q.answer + 1,
          ]..shuffle(Random(q.metadata?.seed ?? 0)))
            Padding(
              padding: const EdgeInsets.all(8),
              child: OutlinedButton(
                onPressed: () => widget.onAnswer(n),
                child: Text(
                  n <= 20 ? List.filled(n, '●').join(' ') : '$n ●',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget bar(String icon, int n) => Row(
    children: [
      Text('$icon $n'),
      const SizedBox(width: 8),
      Expanded(
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: n / 12,
            child: Container(height: 22, color: green),
          ),
        ),
      ),
    ],
  );
}

class ConstructPainter extends CustomPainter {
  final int sides, shape;
  ConstructPainter(this.sides, this.shape);
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..color = green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;
    if (shape == 2) {
      c.drawCircle(Offset(s.width / 2, s.height / 2), 60, p);
      for (var i = 0; i < sides; i++) {
        c.drawLine(
          Offset(8, s.height - 8 - i * 10),
          Offset(48, s.height - 8 - i * 10),
          p,
        );
      }
      return;
    }
    final pts = shape == 0
        ? [
            Offset(s.width / 2, 20),
            Offset(s.width - 20, s.height - 20),
            Offset(20, s.height - 20),
          ]
        : [
            const Offset(20, 20),
            Offset(s.width - 20, 20),
            Offset(s.width - 20, s.height - 20),
            Offset(20, s.height - 20),
          ];
    for (var i = 0; i < min(sides, pts.length); i++) {
      c.drawLine(pts[i], pts[(i + 1) % pts.length], p);
    }
    if (sides > pts.length)
      c.drawLine(
        Offset(15, s.height - 7),
        Offset(s.width - 15, s.height - 7),
        p,
      );
  }

  @override
  bool shouldRepaint(ConstructPainter old) =>
      sides != old.sides || shape != old.shape;
}
