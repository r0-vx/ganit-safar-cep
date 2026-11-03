import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ganit_safar/chapter_catalogue.dart';
import 'package:ganit_safar/content.dart';
import '../scripts/freeze_class4_baseline.dart' as baseline;
import '../scripts/freeze_primary_marathi_baseline.dart' as primary;

void main() {
  final source =
      jsonDecode(
            File(
              'test/fixtures/classes123_marathi_baseline.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  final before = <String, Map<String, dynamic>>{
    for (final item in (source['chaptersBefore'] as Map).entries)
      if (item.value['grade'] == 2)
        item.key.toString(): Map<String, dynamic>.from(item.value),
  };
  final chapters = chaptersForGrade(2);

  test(
    'All 22 Class 2 chapters preserve math, source order, IDs and original Marathi drafts',
    () {
      expect(chapters.length, 22);
      expect(before.keys, chapters.map((c) => c.id));
      for (final chapter in chapters) {
        final old = before[chapter.id]!;
        final oldTitle = old['title'] as Map;
        expect(chapter.title.en, oldTitle['english']);
        expect(chapter.title.mr, chapter.title.marathiDraft);
        final record = {
          'id': chapter.id,
          'grade': chapter.grade,
          'title': chapter.title.toJson(),
          'lesson': {
            for (final entry in chapter.lesson.localizedTexts.entries)
              entry.key: entry.value.toJson(),
          },
          'questions': [
            for (final q in chapter.questions(count: 10))
              {
                'id': q.id,
                'correctIndex': q.correctIndex,
                'visualKind': q.visualKind,
                'objects': q.objects,
                'text': {
                  for (final entry in q.localizedTexts.entries)
                    entry.key: entry.value.toJson(),
                },
              },
          ],
        };
        expect(
          baseline.fingerprint(primary.originalDrafts(record)),
          source['originalDrafts']['chapters'][chapter.id],
          reason: '${chapter.id}: all original drafts retained',
        );
        final questions = chapter.questions(count: 10);
        final oldQuestions = old['questions'] as List;
        expect(questions.length, 10);
        for (var index = 0; index < questions.length; index++) {
          final q = questions[index];
          final original = oldQuestions[index] as Map;
          final originalText = original['text'] as Map;
          expect(q.id, original['id']);
          expect(q.correctIndex, original['correctIndex']);
          expect(q.objects, original['objects']);
          expect(q.visualKind, original['visualKind']);
          for (final entry in q.localizedTexts.entries) {
            final field = originalText[entry.key] as Map;
            _word(entry.value, field, '${q.id}.${entry.key}');
            expect(
              entry.value.en,
              _allowedEnglish(
                chapter.number,
                index,
                entry.key,
                field['english'] as String,
              ),
              reason:
                  '${q.id}.${entry.key}: narrow approved English fixes only',
            );
          }
        }
        final lesson = chapter.lesson;
        expect(lesson.objects, questions.first.objects);
        expect(lesson.visualKind, questions.first.visualKind);
        final oldLesson = old['lesson'] as Map;
        for (final entry in lesson.localizedTexts.entries) {
          final original = oldLesson[entry.key] as Map;
          _word(entry.value, original, '${chapter.id}.lesson.${entry.key}');
          final expected = chapter.number == 6 && entry.key == 'workedExample'
              ? (original['english'] as String).replaceAll(
                  RegExp(r'\s*<\s*'),
                  ' → ',
                )
              : original['english'];
          expect(entry.value.en, expected);
        }
      }
    },
  );

  test(
    'All 220 questions, 880 options and 110 lesson fields have classroom Marathi',
    () {
      var questionCount = 0, optionCount = 0, lessonFields = 0;
      for (final chapter in chapters) {
        for (final question in chapter.questions(count: 10)) {
          questionCount++;
          optionCount += question.options.length;
          for (final field in question.localizedTexts.values) _classroom(field);
          expect(
            question.options.map((o) => o.mr).toSet().length,
            4,
            reason:
                '${question.id}: choices remain distinct after localisation',
          );
        }
        for (final field in chapter.lesson.localizedTexts.values) {
          lessonFields++;
          _classroom(field);
        }
      }
      expect(questionCount, 220);
      expect(optionCount, 880);
      expect(lessonFields, 110);
    },
  );

  test(
    'Geometry begins with familiar meaning and then names the solid precisely',
    () {
      final questions = chapters.first.questions(count: 10);
      expect(questions[0].prompt.mr, contains('फाशासारखा'));
      expect(questions[1].prompt.mr, contains('चेंडूसारखा'));
      expect(questions[1].explanation.mr, contains('एकही सपाट पृष्ठभाग नसतो'));
      expect(questions[2].prompt.mr, contains('डब्यासारखा'));
      expect(questions[3].prompt.mr, startsWith('पेटीसारखा आयताकृती ठोकळा'));
      expect(questions[3].prompt.mr, contains('(इष्टिकाचिती)'));
      expect(questions[4].prompt.mr, contains('टोपीसारखा'));
      expect(questions[5].prompt.mr, contains('दोन्ही टोकांना त्रिकोण'));
      expect(questions[7].prompt.mr, contains('सहा बाजूंचे आकार'));
      expect(questions[8].prompt.mr, contains('अर्ध्या चेंडूसारखा'));
    },
  );

  test(
    'Correct mathematical language is used for ordering, regrouping, units and rupees',
    () {
      final order = chapters
          .firstWhere((c) => c.number == 6)
          .questions(count: 10);
      for (var i = 0; i < order.length; i++) {
        expect(order[i].explanation.en, isNot(contains(' < ')));
        expect(order[i].explanation.mr, contains('→'));
        expect(
          order[i].prompt.mr,
          contains(i.isOdd ? 'मोठ्यापासून लहानाकडे' : 'लहानापासून मोठ्याकडे'),
        );
        for (final option in order[i].options) {
          if (option.en == 'None of these choices') {
            expect(option.mr, 'यांपैकी एकही नाही');
            continue;
          }
          if (option.en == 'All numbers are equal') {
            expect(option.mr, 'सर्व संख्या समान आहेत');
            continue;
          }
          expect(option.en, contains('→'));
          expect(option.mr, contains('→'));
        }
      }
      final regroup = chapters
          .firstWhere((c) => c.number == 14)
          .questions(count: 10);
      for (var i = 0; i < regroup.length; i++) {
        final a = 27 + i * 2, b = 16 + i * 2;
        if (a % 10 + b % 10 < 10) {
          expect(
            regroup[i].explanation.en,
            contains('No regrouping is needed'),
          );
          expect(
            regroup[i].explanation.mr,
            contains('नवीन दशक करायची गरज नाही'),
          );
        } else {
          expect(regroup[i].explanation.en, contains('Regroup ten ones'));
          expect(regroup[i].explanation.mr, contains('१० एककांचा १ दशक'));
        }
      }
      final fair = chapters
          .firstWhere((c) => c.number == 19)
          .questions(count: 10);
      expect(fair.first.prompt.mr, contains('फिरकीची किंमत ₹२'));
      expect(fair.first.explanation.mr, contains('₹२'));
      expect(fair[1].prompt.mr, contains('२ फिरक्यांसाठी'));
      final tens = chapters
          .firstWhere((c) => c.number == 3)
          .questions(count: 10);
      expect(tens.first.prompt.mr, contains('१ सुटी वस्तू आहे'));
      final measurement = chapters
          .firstWhere((c) => c.number == 12)
          .questions(count: 10);
      expect(measurement[2].prompt.mr, contains('पाण्याचे प्रमाण'));
      expect(measurement[8].prompt.mr, contains('कडधान्याच्या दाण्याचे वजन'));
    },
  );

  test(
    'Existing chapter-template coverage gaps are not hidden by fabricated topic content',
    () {
      for (final number in [4, 13]) {
        final chapter = chapters.firstWhere((c) => c.number == number);
        final q = chapter.questions(count: 1).first;
        expect(q.prompt.en, contains('What comes next?'));
        expect(q.prompt.mr, contains('पुढची संख्या'));
        expect(
          chapter.lesson.concept.mr,
          contains(number == 4 ? 'दर्शनी किंमत' : 'सपाट आकार'),
        );
      }
    },
  );
}

void _classroom(Words text) {
  expect(text.mr.trim(), isNotEmpty);
  expect(text.translationProvider, 'class2-contextual-edit');
  expect(text.translationStatus, 'draft');
  expect(text.isEditorReviewed, false);
  expect(text.bilingual, '${text.en}\n${text.mr}');
  expect(text.audioReady['mr'], text.mr);
  expect(text.accessibilityReady['mr'], text.mr);
  expect(
    RegExp(r'[A-Za-z0-9]').hasMatch(text.mr),
    false,
    reason: '${text.id}: ${text.mr}',
  );
}

void _word(Words text, Map original, String reason) {
  expect(text.id, original['id'], reason: '$reason identity');
  _classroom(text);
}

String _allowedEnglish(
  int chapter,
  int variant,
  String field,
  String original,
) {
  if (field.startsWith('option.')) {
    if (original == 'Option 1') return 'None of these choices';
    if (original == 'Option 2') return 'All numbers are equal';
    if (chapter == 6) return original.replaceAll(RegExp(r'\s*<\s*'), ' → ');
  }
  if (field == 'explanation' && chapter == 6)
    return original.replaceAll(RegExp(r'\s*<\s*'), ' → ');
  if (field == 'explanation' && chapter == 14) {
    final a = 27 + variant * 2, b = 16 + variant * 2, ones = a % 10 + b % 10;
    if (ones < 10)
      return 'Ones: ${a % 10} + ${b % 10} = $ones. No regrouping is needed because the ones total is less than ten: $a + $b = ${a + b}.';
  }
  return original;
}
