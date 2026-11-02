import 'dart:math';
import 'content.dart';
import 'models.dart';

bool supportsType(String topic, String type) => switch (type) {
  'clock' => topic == 'time',
  'coins' => topic == 'money',
  'colour' => topic == 'fraction',
  'graph' => topic == 'data',
  'construct' => topic == 'shape',
  'numberline' => ['add', 'subtract', 'count', 'pattern'].contains(topic),
  'model' => ['count', 'add', 'subtract', 'multiply', 'divide'].contains(topic),
  _ => true,
};
String questionFingerprint(Question q) {
  // Matching is intentionally a reusable foundation skill: don't repeat it in a quiz.
  if (q.type == 'match') return 'match-1-2-3';
  if (q.type == 'order')
    return 'order:${(List<int>.of(q.options)..sort()).join(',')}';
  return '${q.metadata?.topic}:${q.a}:${q.b}:${q.answer}:${q.metadata?.topic == 'shape' ? q.prompt.en : ''}';
}

QuestionValidationResult validateQuestion(Question q) {
  final errors = <String>[];
  final m = q.metadata;
  if (m == null || m.grade < 1 || m.grade > 4)
    errors.add('Missing class metadata');
  if (q.answer < 0 ||
      q.options.toSet().length != 4 ||
      !q.options.contains(q.answer))
    errors.add('Invalid answers');
  if (q.prompt.en.isEmpty ||
      q.prompt.mr.isEmpty ||
      q.explanation.en.isEmpty ||
      q.explanation.mr.isEmpty)
    errors.add('Missing translation');
  if (m != null && (m.difficulty < 1 || m.difficulty > 3))
    errors.add('Invalid difficulty');
  if (!questionTypes.contains(q.type) && q.type != 'custom')
    errors.add('Unknown type');
  if (m != null && q.type != 'custom') {
    if (!supportsType(m.topic, q.type)) errors.add('Type does not match topic');
    final expected = switch (m.topic) {
      'add' || 'word' || 'money' || 'data' => q.a + q.b,
      'subtract' => q.a - q.b,
      'multiply' => q.a * q.b,
      'divide' => q.b == 0 ? -1 : q.a ~/ q.b,
      'count' || 'measure' || 'time' || 'fraction' => q.a,
      'place' => q.a ~/ 10,
      'pattern' => q.a + 3 * q.b,
      'shape' => [3, 4, 0][q.a],
      _ => q.answer,
    };
    if (q.type == 'count' &&
        ['add', 'word', 'multiply', 'divide'].contains(m.topic) &&
        (m.topic == 'multiply'
                ? q.a * q.b
                : m.topic == 'divide'
                ? q.a
                : q.a + q.b) >
            36)
      errors.add('Use a grouped model instead of truncated counting');
    if (q.answer != expected) errors.add('Arithmetic disagrees with model');
    if (m.topic == 'divide' && (q.b <= 0 || q.a % q.b != 0))
      errors.add('Sharing must be exact');
    if (m.topic == 'fraction' && (q.a >= q.b || q.a <= 0))
      errors.add('Invalid fraction');
  }
  return QuestionValidationResult(errors);
}

List<Question> generateQuestions({
  required List<String> topicIds,
  required int grade,
  required int count,
  required List<String> types,
  int difficulty = 1,
  bool random = false,
  bool showOptions = true,
}) {
  if (topicIds.isEmpty ||
      types.isEmpty ||
      count < 1 ||
      count > 100 ||
      grade < 1 ||
      grade > 4)
    throw ArgumentError('Choose topics, types and 1–100 questions');
  final ids = topics.map((t) => t.id).toSet();
  if (topicIds.any((t) => !ids.contains(t)))
    throw ArgumentError('Unknown topic');
  final used = <String>{};
  final result = <Question>[];
  final seed = random ? Random().nextInt(10000) : 0;
  for (var attempt = 0; attempt < 12000 && result.length < count; attempt++) {
    final topic = topicIds[attempt % topicIds.length];
    final available = types.where((t) => supportsType(topic, t)).toList();
    if (available.isEmpty) continue;
    var type = available[(attempt ~/ topicIds.length) % available.length];
    if (!showOptions &&
        [
          'choice',
          'truefalse',
          'story',
          'count',
          'model',
          'graph',
        ].contains(type))
      type = 'fill';
    final index = seed + attempt ~/ topicIds.length;
    final base = makeQuestion(
      topic,
      grade,
      index,
      type,
      difficulty: difficulty,
    );
    // Alternate original short direct prompts with contextual stories.
    final direct =
        index % 3 == 1 &&
        ['add', 'subtract', 'multiply', 'divide'].contains(topic) &&
        type != 'story';
    final symbol = switch (topic) {
      'subtract' => '−',
      'multiply' => '×',
      'divide' => '÷',
      _ => '+',
    };
    final q = direct
        ? Question(
            Words(
              '${base.a} $symbol ${base.b} = ?',
              '${base.a} $symbol ${base.b} = ?',
              id: '${base.prompt.id}.direct',
              mathGlossaryTerms: glossaryTermsFor(topic),
            ),
            base.explanation,
            base.answer,
            base.a,
            base.b,
            base.options,
            type,
            base.icon,
            metadata: base.metadata,
          )
        : base;
    if (validateQuestion(q).valid && used.add(questionFingerprint(q)))
      result.add(q);
  }
  if (result.length < count)
    throw StateError(
      'This selection has ${result.length} distinct questions. Choose fewer questions or more topics/types.',
    );
  return result;
}
