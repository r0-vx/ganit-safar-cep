import 'chapter_catalogue.dart';
import 'content.dart';
import 'curriculum.dart';
import 'generator.dart';

/// Review inventory; generated numerical variants are samples, not a claim that
/// reviewing one variant approves an entire mathematical template.
Iterable<Map<String, dynamic>> learningTranslationRecords({
  int variants = 1,
}) sync* {
  if (variants < 1 || variants > 10)
    throw ArgumentError.value(variants, 'variants');
  Map<String, dynamic> record(Words words, String usage) => {
    ...words.toJson(),
    'usage': usage,
  };
  yield record(reviewedMangoCounting, 'lesson.instruction');
  for (final topic in topics) {
    yield record(topic.name, 'topic.title');
    yield record(
      lessonStory(topic.id).identified(
        'sample.${topic.id}.storyTitle',
        glossaryTerms: glossaryTermsFor(topic.id),
      ),
      'lesson.storyTitle',
    );
  }
  for (final entry in typeNames.entries) {
    yield record(
      entry.value.identified('questionType.${entry.key}'),
      'interface.questionType',
    );
  }
  for (final chapter in schoolChapters) {
    yield record(chapter.title, 'chapter.title');
    for (final entry in chapter.lesson.localizedTexts.entries) {
      yield record(entry.value, 'chapter.lesson.${entry.key}');
    }
    for (final q in chapter.questions(count: 10)) {
      for (final entry in q.localizedTexts.entries) {
        yield record(entry.value, 'chapter.question.${entry.key}');
      }
    }
  }
  for (final outcome in curriculum) {
    for (final entry in {
      'objective': outcome.objective,
      'definition': outcome.definition,
      'hint': outcome.hint,
      'commonMistake': outcome.commonMistake,
      'vocabulary': outcome.vocabularyText,
    }.entries) {
      yield record(entry.value, 'learningHelp.${entry.key}');
    }
    for (final type in questionTypes.where(
      (type) => supportsType(outcome.topic, type),
    )) {
      for (var index = 0; index < variants; index++) {
        final q = makeQuestion(outcome.topic, outcome.grade, index, type);
        if (!validateQuestion(q).valid) continue;
        for (final entry in q.localizedTexts.entries) {
          yield record(entry.value, 'sample.question.${entry.key}');
        }
      }
    }
  }
}
