import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ganit_safar/chapter_catalogue.dart';
import 'package:ganit_safar/content.dart';
import '../scripts/audit_class4_marathi.dart';
import '../scripts/freeze_class4_baseline.dart' as baseline;

void main() {
  final chapters = chaptersForGrade(3);

  test(
    'Class 3 preserves all chapter and question models with only the approved length hint correction',
    () {
      final before =
          jsonDecode(
                File(
                  'test/fixtures/classes123_marathi_baseline.json',
                ).readAsStringSync(),
              )
              as Map;
      final current = buildClass4AuditInventory();
      expect(chapters, hasLength(14));
      var corrections = 0;
      for (final record in (current['chapters'] as List).where(
        (c) => c['grade'] == 3,
      )) {
        final semantic = baseline.semantic(record);
        if (record['id'] == 'G3-C05') {
          for (final i in [0, 2, 4, 5, 7, 9]) {
            final hint = semantic['questions'][i]['text']['hint'] as Map;
            expect(
              hint['english'],
              'Choose the unit that measures length at this scale.',
            );
            hint['english'] =
                'Choose the unit that measures mass at this scale.';
            corrections++;
          }
          expect(
            semantic['lesson']['hint']['english'],
            'Choose the unit that measures length at this scale.',
          );
          semantic['lesson']['hint']['english'] =
              'Choose the unit that measures mass at this scale.';
          corrections++;
        }
        expect(
          baseline.fingerprint(semantic),
          before['chapterSemantics'][record['id']],
          reason: record['id'],
        );
      }
      expect(corrections, 7);
    },
  );

  test(
    'All original Class 3 Marathi drafts and official titles remain available',
    () {
      const hashes = {
        'G3-C01':
            '99231104058e50d2da8446672a1c74236761026f90997956d0e3ae44a76567cc',
        'G3-C02':
            '67cdf8ee60a90599c10bad0df52e2e4a89e4ae27ca066e4538ef9e9161e0be35',
        'G3-C03':
            '99b238e0092b5a6641adb652f7718becc68b130aa1589a1672e617083facc7e3',
        'G3-C04':
            '16bcba293ce7450e48449038e79a8c317602795ca252b3d756de9b86fbd1ffcb',
        'G3-C05':
            '07308fde8e1363d61039c57d5f40891a22280335123e0d12390a95a6dc25ee5a',
        'G3-C06':
            '9713fc965a41425a37fc622ef5ece6b89445c2f3668d5cce02ab3bd76f65aee9',
        'G3-C07':
            'cd7137bf27ee5b75b68f0e06d9bb78a65178e92732d6d841a9639020f89ee991',
        'G3-C08':
            '3e3fb155f5663c279aad543fea0ed71341b5666cde26b42b8c0c337ec0dc0f70',
        'G3-C09':
            '83c873f80b002343c9100113cd9d0b0bad02600b759f97f645c5e30d75f9d4c1',
        'G3-C10':
            'a1357cc37d216914ebfec65e45c41fd8556b58c1b1d7219d5a5a74f94f32669d',
        'G3-C11':
            '10eab960460906d6be16158c103cd29ac38138edde78222a4abd9f2fe14f476e',
        'G3-C12':
            'dbbb0d847f981c67386050af706253b628a42a03a74d2879fe11f0c567f21cbd',
        'G3-C13':
            '427740d859ed7291f9cfaedbf67caa717ebfb0d46aa9e498991258372493a4cd',
        'G3-C14':
            '38f01fd11c4dd33ed0c73ee3ff28122ae2fb5f02b8eeb9435f7213ae301275a7',
      };
      for (final chapter in chapters) {
        final payload = [
          chapter.title.mr,
          [
            for (final q in chapter.questions(count: 10))
              [
                for (final e in q.localizedTexts.entries)
                  [e.key, e.value.marathiDraft],
              ],
          ],
          [
            for (final e in chapter.lesson.localizedTexts.entries)
              [e.key, e.value.marathiDraft],
          ],
        ];
        expect(
          baseline.fingerprint(payload),
          hashes[chapter.id],
          reason: chapter.id,
        );
      }
    },
  );

  test(
    'All 140 Class 3 questions and 70 lesson fields have complete bilingual classroom wording',
    () {
      var questionCount = 0, textCount = 0, lessonCount = 0;
      for (final chapter in chapters) {
        for (final q in chapter.questions(count: 10)) {
          questionCount++;
          for (final text in q.localizedTexts.values) {
            textCount++;
            _reviewed(text, grid: chapter.number == 7);
          }
          expect(
            _numbers(q.prompt.mr),
            _numbers(q.prompt.en),
            reason: '${q.id}.prompt quantities',
          );
          final source = {
            ..._numbers(q.prompt.en),
            ..._numbers(q.explanation.en),
            ..._numbers(q.options[q.correctIndex].en),
          };
          // Capacity explanations make explicit the standard two halves = one
          // whole relation, written in words in the original English.
          if (chapter.number == 12) source.addAll([1, 2]);
          expect(
            source.containsAll(_numbers(q.explanation.mr)),
            true,
            reason: '${q.id}.explanation quantities',
          );
        }
        for (final text in chapter.lesson.localizedTexts.values) {
          lessonCount++;
          _reviewed(text, grid: chapter.number == 7);
        }
      }
      expect(questionCount, 140);
      expect(textCount, 980);
      expect(lessonCount, 70);
    },
  );

  test(
    'Class 3 numerical answers, fraction roles, map coordinates and clock readings are consistent for every variant',
    () {
      for (final chapter in chapters) {
        final questions = chapter.questions(count: 10);
        for (var i = 0; i < questions.length; i++) {
          final q = questions[i];
          final answer = q.options[q.correctIndex];
          String? expected;
          switch (chapter.number) {
            case 2:
              expected =
                  '${(2 + i % 8) * 100 + (i * 3 % 10) * 10 + i * 7 % 10}';
            case 3:
              expected = '${236 + i * 31 + 112 + i * 17}';
            case 4:
              expected = '${[1, 1, 3, 2, 1][i % 5]}/${[2, 4, 4, 3, 4][i % 5]}';
              expect(q.explanation.mr, contains('अंश'));
              expect(q.explanation.mr, contains('छेद'));
              expect(q.prompt.mr, contains('समान भाग'));
            case 6:
              expected = '${2 + i}';
            case 7:
              expected = '${['A', 'B', 'C'][i % 3]}${1 + i % 4}';
              expect(q.explanation.mr, contains(_marathi(expected)));
            case 8:
              expected = '${(12 + i * 4) * (2 + i % 5)}';
            case 9:
              expected = '${i.isOdd ? i % (2 + i % 4) : 3 + i % 6}';
              expect(
                q.prompt.mr,
                contains(i.isOdd ? 'किती जांभळे उरतील' : 'प्रत्येक मित्राला'),
              );
              if (i.isOdd) expect(q.explanation.mr, contains('बाकी'));
            case 12:
              expected = '${(1 + i) * 2}';
              expect(q.prompt.mr, contains('अर्धा लिटर'));
            case 13:
              expected =
                  '${1 + i % 12}:${[0, 15, 30, 45][i % 4].toString().padLeft(2, '0')}';
              expect(q.explanation.mr, contains(_marathi(expected)));
            case 14:
              expected = '${2 + i * 2 + 3 * (1 + i % 4)}';
          }
          if (expected != null) {
            expect(answer.en, expected, reason: q.id);
            expect(answer.mr, _marathi(expected), reason: q.id);
          }
        }
      }
    },
  );

  test(
    'Class 3 measurement hints distinguish length from weight and retain all unit answers',
    () {
      final chapter = chapters.firstWhere((c) => c.number == 5);
      const units = [
        'सेंटीमीटर',
        'ग्राम',
        'मीटर',
        'किलोग्रॅम',
        'किलोमीटर',
        'सेंटीमीटर',
        'किलोग्रॅम',
        'मीटर',
        'ग्राम',
        'किलोमीटर',
      ];
      final questions = chapter.questions(count: 10);
      for (var i = 0; i < questions.length; i++) {
        final q = questions[i];
        final mass = const [1, 3, 6, 8].contains(i);
        expect(q.options[q.correctIndex].mr, units[i]);
        expect(q.hint.mr, startsWith(mass ? 'इथे वजन' : 'इथे लांबी'));
        expect(q.hint.en, contains(mass ? 'mass' : 'length'));
      }
      expect(chapter.lesson.hint.en, contains('length'));
      expect(chapter.lesson.hint.mr, startsWith('इथे लांबी'));
    },
  );
}

String _marathi(String value) => value
    .split('')
    .map((c) => int.tryParse(c) == null ? c : '०१२३४५६७८९'[int.parse(c)])
    .join();

Set<int> _numbers(String text) {
  final western = text
      .split('')
      .map((c) => '०१२३४५६७८९'.contains(c) ? '${'०१२३४५६७८९'.indexOf(c)}' : c)
      .join();
  return RegExp(
    r'\d+',
  ).allMatches(western).map((m) => int.parse(m[0]!)).toSet();
}

void _reviewed(Words text, {required bool grid}) {
  expect(text.mr.trim(), isNotEmpty, reason: text.id);
  expect(text.translationProvider, 'class3-contextual-edit', reason: text.id);
  expect(text.translationStatus, 'draft', reason: text.id);
  expect(
    text.isEditorReviewed,
    false,
    reason: 'External educator approval is not implied',
  );
  expect(text.inLanguage(0), text.en);
  expect(text.inLanguage(1), text.mr);
  expect(text.inLanguage(2), '${text.en}\n${text.mr}');
  expect(text.audioReady['mr'], text.mr);
  expect(text.accessibilityReady['mr'], text.mr);
  expect(
    RegExp(grid ? r'[D-Za-z0-9]' : r'[A-Za-z0-9]').hasMatch(text.mr),
    false,
    reason: text.id,
  );
}
