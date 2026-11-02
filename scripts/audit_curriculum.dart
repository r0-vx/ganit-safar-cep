import 'dart:convert';
import 'dart:io';
import 'package:ganit_safar/content.dart';
import 'package:ganit_safar/curriculum.dart';
import 'package:ganit_safar/generator.dart';

void main() {
  final rows = <Map<String, dynamic>>[];
  var accepted = 0, rejected = 0;
  for (final o in curriculum) {
    final q = makeQuestion(o.topic, o.grade, 0, 'choice');
    final errors = <String>[];
    for (final type in questionTypes.where(
      (type) => supportsType(o.topic, type),
    )) {
      for (var difficulty = 1; difficulty <= 3; difficulty++) {
        for (var index = 0; index < 30; index++) {
          final question = makeQuestion(
            o.topic,
            o.grade,
            index,
            type,
            difficulty: difficulty,
          );
          final validation = validateQuestion(question);
          if (validation.valid) {
            accepted++;
          } else {
            rejected++;
            if (type != 'count')
              errors.add('$type/$difficulty/$index: ${validation.errors}');
          }
          if (question.metadata!.outcomeId != o.id) errors.add('Wrong outcome');
        }
      }
    }
    rows.add({
      'class': o.grade,
      'topic': o.topic,
      'outcomeId': o.id,
      'objectiveEn': o.objective.en,
      'objectiveMr': o.objective.mr,
      'prerequisite': o.prerequisite,
      'keyVocabulary': o.vocabulary,
      'conceptEn': o.definition.en,
      'conceptMr': o.definition.mr,
      'workedExampleEn': q.explanation.en,
      'workedExampleMr': q.explanation.mr,
      'practiceSkills': questionTypes
          .where((t) => supportsType(o.topic, t))
          .join('; '),
      'quizSkills': questionTypes
          .where((t) => supportsType(o.topic, t))
          .join('; '),
      'englishWording': q.prompt.en,
      'marathiWording': q.prompt.mr,
      'bilingualRendering': q.prompt.inLanguage(2),
      'hintEn': o.hint.en,
      'hintMr': o.hint.mr,
      'source': o.source,
      'implementation':
          ['measure', 'time', 'place', 'data', 'shape'].contains(o.topic)
          ? 'Partially implemented: foundational sample range'
          : 'Implemented sample activity',
      'curriculumStatus': o.review,
      'validationErrors': errors.join('; '),
    });
  }
  final report = {
    'schemaVersion': 2,
    'scope': 'Local web only; no deployment or native compatibility testing',
    'rows': rows,
    'acceptedTemplateSamples': accepted,
    'rejectedBeforeServing': rejected,
    'humanCurriculumReviewRequired': true,
  };
  File(
    'docs/curriculum/coverage.json',
  ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(report));
  String csv(Object? v) => '"${v.toString().replaceAll('"', '""')}"';
  final headers = rows.first.keys.toList();
  File('docs/curriculum/alignment-matrix.csv').writeAsStringSync(
    '${headers.map(csv).join(',')}\n${rows.map((r) => headers.map((h) => csv(r[h])).join(',')).join('\n')}\n',
  );
  final errors = rows.where((r) => r['validationErrors'] != '').toList();
  stdout.writeln(
    '${rows.length} class/topic records; $accepted valid samples; $rejected oversized counting samples rejected before serving; ${errors.length} unexpected failures.',
  );
  if (errors.isNotEmpty) exitCode = 1;
}
