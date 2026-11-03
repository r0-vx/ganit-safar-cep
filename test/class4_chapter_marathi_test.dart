import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ganit_safar/chapter_catalogue.dart';
import 'package:ganit_safar/content.dart';

void main() {
  final chapters = chaptersForGrade(4);
  test(
    'All 14 Class 4 chapters preserve official titles, immutable math and original drafts',
    () {
      // Captured from the pre-edit catalogue. Only approved mathematical English
      // clarifications are excluded: 5 improper-fraction contexts and length units.
      const before = {
        'G4-C01':
            'cdb4d6882430b0bcf708fb68978734590007200d43bb4af01d0d02c565f11773',
        'G4-C02':
            'cd7378df6fa0f939167afa56c5cacf9c85e3d86d94b7391a52cb58b44af9755c',
        'G4-C03':
            '4ebd830cbe7d0a543a514211270067a24dfb2234b57fcd3375664b9c7a068d73',
        'G4-C04':
            '26fda4fc74551addf59f1dba049a1a150845c035fb28113e394ec06bfa8f46d1',
        'G4-C05':
            'cd48e86210c4533ca757b233c104f5c79ff6d6f8bc882628139d5cdb4a1d6ab2',
        'G4-C06':
            '17531027f856ef44a2191eac7c9d49639c2ffce2ff552f7f21b705ec009a8b2f',
        'G4-C07':
            '6a9c641a54b35e42967489d5e3a84631af9325a24e997f8677531f48dcfc7ce2',
        'G4-C08':
            '8509740af620fb3315a518e603e04831a8b87e4ea6cfad94c850f9a0aede1c68',
        'G4-C09':
            '694b4501499aa2d125d6e6fae29bb767188dd898ff14f4d610db98dbf60c74c5',
        'G4-C10':
            'bcc9b82233da7ae4c323b5e543de342aff656a3688d8f35adfeb297756efe065',
        'G4-C11':
            'dc207e9f074c897f965bc5def3883dad6198ecd508d287a2cb4904e4a8b9b46e',
        'G4-C12':
            '6187f14868c32aaa72e94e628dc2695bf5c519d5e6871023cb547ea6d83647fa',
        'G4-C13':
            'e90ab5cbabe5778cda9a9111bab83d1ba2f87636766d0874814e90dd9b34c671',
        'G4-C14':
            'b7736e0c3e6ce8e471b212dd5c07840b0cb3175d5157d73a7795dc7d2422fca1',
      };
      expect(chapters.length, 14);
      for (final chapter in chapters) {
        final questions = chapter.questions(count: 10);
        final projectedQuestions = <Object>[];
        for (var i = 0; i < questions.length; i++) {
          final q = questions[i];
          final allowed = chapter.number == 4 && i.isOdd
              ? {'prompt', 'explanation', 'hint'}
              : chapter.number == 11
              ? {'prompt'}
              : <String>{};
          projectedQuestions.add([
            q.id,
            q.correctIndex,
            q.visualKind,
            q.objects,
            [
              for (final entry in q.localizedTexts.entries)
                [
                  entry.key,
                  entry.value.id,
                  allowed.contains(entry.key) ? null : entry.value.en,
                  entry.value.marathiDraft,
                ],
            ],
          ]);
        }
        final lesson = chapter.lesson;
        final projectedLesson = [
          for (final entry in lesson.localizedTexts.entries)
            [
              entry.key,
              entry.value.id,
              chapter.number == 11 && entry.key == 'story'
                  ? null
                  : entry.value.en,
              entry.value.marathiDraft,
            ],
        ];
        final payload = [
          chapter.id,
          chapter.title.id,
          chapter.title.en,
          chapter.title.mr,
          projectedQuestions,
          projectedLesson,
        ];
        expect(
          sha256.convert(utf8.encode(jsonEncode(payload))).toString(),
          before[chapter.id],
          reason: chapter.id,
        );
      }
    },
  );

  test(
    'All 140 questions and 70 lesson fields have complete contextual Marathi and bilingual metadata',
    () {
      var questions = 0, lessonFields = 0;
      for (final chapter in chapters) {
        for (final q in chapter.questions(count: 10)) {
          questions++;
          for (final text in q.localizedTexts.values) _reviewed(text);
          // The quantities and times in every prompt/explanation are preserved.
          // Hints can additionally explain standard rules (e.g. even-number digits).
          expect(
            _numbers(q.prompt.mr),
            _numbers(q.prompt.en),
            reason: '${q.id}.prompt',
          );
          final sourceNumbers = {
            ..._numbers(q.prompt.en),
            ..._numbers(q.explanation.en),
          };
          final explainedNumbers = _numbers(q.explanation.mr);
          expect(
            sourceNumbers.containsAll(explainedNumbers),
            true,
            reason: '${q.id}.explanation: no invented quantities',
          );
          expect(
            explainedNumbers.containsAll(_numbers(q.explanation.en)),
            true,
            reason: '${q.id}.explanation: retain worked values',
          );
          for (final option in q.options) {
            if (RegExp(r'^\d+(?:[/\:]\d+)?$').hasMatch(option.en)) {
              expect(_western(option.mr), option.en, reason: option.id);
            }
          }
        }
        for (final text in chapter.lesson.localizedTexts.values) {
          lessonFields++;
          _reviewed(text);
        }
      }
      expect(questions, 140);
      expect(lessonFields, 70);
    },
  );

  test(
    'Fractions describe equal parts per whole and clarify only the five improper contexts',
    () {
      final fractions = chapters
          .firstWhere((c) => c.number == 4)
          .questions(count: 10);
      for (var i = 0; i < fractions.length; i++) {
        final q = fractions[i];
        final pieces = q.options[q.correctIndex].en
            .split('/')
            .map(int.parse)
            .toList();
        expect(q.explanation.mr, contains('अंश'));
        expect(q.explanation.mr, contains('छेद'));
        expect(q.hint.mr, contains('एका पूर्ण आकाराचे'));
        if (i.isOdd) {
          expect(pieces.first, greaterThan(pieces.last));
          expect(q.prompt.en, startsWith('Each identical'));
          expect(q.prompt.en, contains('parts are shaded across the shapes'));
          expect(q.prompt.mr, contains('प्रत्येक पूर्ण आकाराचे'));
          expect(q.explanation.en, contains('Each whole has'));
          expect(q.hint.en, contains('one whole'));
          expect(
            RegExp(
              r'cut into (\d+) equal parts\. (\d+) parts are shaded',
            ).hasMatch(q.prompt.en),
            true,
          );
        }
      }
    },
  );

  test(
    'Measurement and elapsed-time variants retain source quantities and natural units',
    () {
      final measurement = chapters
          .firstWhere((c) => c.number == 5)
          .questions(count: 10);
      expect(measurement[2].prompt.mr, '४ किलोग्रॅम म्हणजे किती ग्राम?');
      expect(measurement[2].explanation.mr, contains('४००० ग्राम'));
      expect(measurement[8].explanation.mr, contains('१०००० ग्राम'));
      final time = chapters
          .firstWhere((c) => c.number == 13)
          .questions(count: 10);
      expect(time.first.prompt.mr, contains('८:०० वाजता'));
      expect(time.first.explanation.mr, contains('८:१५ वाजता'));
      final area = chapters.firstWhere((c) => c.number == 11);
      for (final q in area.questions(count: 10)) {
        expect(q.prompt.en, contains('units long'));
        expect(q.prompt.en, isNot(contains('square units long')));
        expect(q.prompt.mr, contains('एकक आणि रुंदी'));
      }
      expect(area.lesson.story.en, isNot(contains('square units long')));
    },
  );
}

String _western(String value) {
  const mr = '०१२३४५६७८९';
  return value
      .split('')
      .map((c) => mr.contains(c) ? '${mr.indexOf(c)}' : c)
      .join();
}

Set<int> _numbers(String text) {
  final normalized = _western(text).replaceAllMapped(
    RegExp(r'\d{1,3}(?:,\d{3})+'),
    (match) => match[0]!.replaceAll(',', ''),
  );
  return RegExp(
    r'\d+',
  ).allMatches(normalized).map((m) => int.parse(m[0]!)).toSet();
}

void _reviewed(Words text) {
  expect(text.mr.trim(), isNotEmpty, reason: text.id);
  expect(text.translationProvider, 'class4-contextual-edit', reason: text.id);
  expect(
    text.translationStatus,
    'draft',
    reason: 'Do not imply native educator approval: ${text.id}',
  );
  expect(text.isEditorReviewed, false);
  expect(text.inLanguage(0), text.en);
  expect(text.inLanguage(1), text.mr);
  expect(text.inLanguage(2), '${text.en}\n${text.mr}');
  expect(text.audioReady['mr'], text.mr);
  expect(text.accessibilityReady['mr'], text.mr);
  expect(
    RegExp(r'[a-zA-Z0-9]').hasMatch(text.mr),
    false,
    reason: 'Untranslated text or Western digits: ${text.id}',
  );
  for (final phrase in [
    'मिश्र संख्येची भाषा',
    'प्रमाणित एकूण',
    'अनुरूप',
    'वर्गीकृत करा',
  ]) {
    expect(text.mr, isNot(contains(phrase)), reason: text.id);
  }
}
