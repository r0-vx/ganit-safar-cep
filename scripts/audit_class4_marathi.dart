import 'dart:convert';
import 'dart:io';
import 'package:ganit_safar/chapter_catalogue.dart';
import 'package:ganit_safar/content.dart';
import 'package:ganit_safar/curriculum.dart';
import 'package:ganit_safar/generator.dart';

Map<String, dynamic> buildClass4AuditInventory() => <String, dynamic>{
  'chapters': [
    for (final c in schoolChapters)
      {
        'id': c.id,
        'grade': c.grade,
        'title': c.title.toJson(),
        'lesson': c.lesson.localizedTexts.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
        'questions': [
          for (final q in c.questions(count: 10))
            {
              'id': q.id,
              'correctIndex': q.correctIndex,
              'visualKind': q.visualKind,
              'objects': q.objects,
              'text': q.localizedTexts.map(
                (key, value) => MapEntry(key, value.toJson()),
              ),
            },
        ],
      },
  ],
  'legacy': [
    for (final o in curriculum)
      {
        'id': o.id,
        'grade': o.grade,
        'topic': o.topic,
        'help': {
          'objective': o.objective.toJson(),
          'definition': o.definition.toJson(),
          'hint': o.hint.toJson(),
          'mistake': o.commonMistake.toJson(),
          'vocabulary': o.vocabularyText.toJson(),
        },
        'questions': [
          for (final t in questionTypes.where((t) => supportsType(o.topic, t)))
            for (final d in [1, 2, 3])
              for (final i in [0, 1, 2, 9, 29])
                () {
                  final q = makeQuestion(o.topic, o.grade, i, t, difficulty: d);
                  return {
                    'id': q.id,
                    'type': t,
                    'a': q.a,
                    'b': q.b,
                    'answer': q.answer,
                    'options': q.options,
                    'metadata': {
                      'grade': q.metadata?.grade,
                      'topic': q.metadata?.topic,
                    },
                    'text': q.localizedTexts.map(
                      (key, value) => MapEntry(key, value.toJson()),
                    ),
                  };
                }(),
        ],
      },
  ],
};

void main(List<String> args) {
  final data = buildClass4AuditInventory();
  final path = args.isEmpty ? 'build/class4-marathi-audit.json' : args.first;
  File(path)
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
  stdout.writeln('Wrote $path');
}
