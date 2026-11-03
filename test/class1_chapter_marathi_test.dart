import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ganit_safar/chapter_catalogue.dart';
import 'package:ganit_safar/content.dart';
import '../scripts/audit_class4_marathi.dart';
import '../scripts/freeze_class4_baseline.dart' as baseline;

void main() {
  final chapters = chaptersForGrade(1);

  test(
    'All 29 Class 1 chapter models retain English and mathematics except approved ordering clarifications',
    () {
      final fixture =
          jsonDecode(
                File(
                  'test/fixtures/classes123_marathi_baseline.json',
                ).readAsStringSync(),
              )
              as Map;
      final current = buildClass4AuditInventory();
      expect(chapters, hasLength(29));
      for (final record in (current['chapters'] as List).where(
        (c) => c['grade'] == 1,
      )) {
        final expected =
            jsonDecode(jsonEncode(fixture['chaptersBefore'][record['id']]))
                as Map;
        if (record['id'] == 'G1-C14' || record['id'] == 'G1-C15') {
          for (final question in expected['questions'] as List) {
            for (final field in (question['text'] as Map).entries) {
              final text = field.value as Map;
              if (field.key.toString().startsWith('option.')) {
                if (text['english'] == 'Option 1')
                  text['english'] = 'None of these choices';
                if (text['english'] == 'Option 2')
                  text['english'] = 'All numbers are equal';
              }
              if (record['id'] == 'G1-C15' &&
                  (field.key == 'explanation' ||
                      field.key.toString().startsWith('option.'))) {
                text['english'] = (text['english'] as String).replaceAll(
                  RegExp(r'\s*<\s*'),
                  ' → ',
                );
              }
            }
          }
        }
        if (record['id'] == 'G1-C15') {
          expected['lesson']['workedExample']['english'] =
              (expected['lesson']['workedExample']['english'] as String)
                  .replaceAll(RegExp(r'\s*<\s*'), ' → ');
        }
        expect(
          baseline.fingerprint(baseline.semantic(record)),
          baseline.fingerprint(expected),
          reason: record['id'],
        );
      }
    },
  );

  test(
    'All Class 1 original Marathi drafts and official chapter titles remain available',
    () {
      const hashes = {
        'G1-C01':
            '46e23aa4c2dc28e44a9891e0cf127261b29fa839b4ce1cf19583f1e1b1a759b3',
        'G1-C02':
            'a4cf874494ac67163e158778afc25d05e8d89549d127687f8a02bd2c026335bc',
        'G1-C03':
            '392cd845375d9171584598c6f96db72343cf04c4321c94d3a3229869ba2957d1',
        'G1-C04':
            'd413595c792b72eaf828247c90e714d400a9075be558cb8723c4c30d7d3a21d0',
        'G1-C05':
            'b033a9099ddda16f5491c8b5f73990887ebd423b28420908f32736a9e69fe480',
        'G1-C06':
            '1740e9bd6239534bcb4e63b433284ba1b012551e0a38042c2254a016a9cdc0b8',
        'G1-C07':
            '89e5089831a7d90ae97a60a14ce003e6039a97337a1aa4881be53a6c61398f10',
        'G1-C08':
            '678731cc55df1f1dd424776581bd590adfe5c67c2448f57608e489910961af79',
        'G1-C09':
            'c8ba843d6819e817ffad0aab7db6e2223bfe4ffd87b896166b265801a9749c71',
        'G1-C10':
            '670b1b93c80125fc7a0718e707754dab7605989c72578a710ace315df255b2eb',
        'G1-C11':
            '3aba5989a760670d29aed80b7fbb492a5273d014a2f6f2070b8728a9d1f2c04d',
        'G1-C12':
            'd6deee9e986085c24cccdba891eeb62d8cbd6dfbb5472321b7679b811ecfd816',
        'G1-C13':
            '3624ad7e2c0e894b3c437d1ea5c5961d98923ba40cb004a2a07ac3bdb1f6028a',
        'G1-C14':
            '04e065d10e8f51a22df6b60d49c2959c83d0a777c87da702eda02b96da0c24ab',
        'G1-C15':
            '5f92b73f20b1783c2f0c95e8e4207a30c4e4cb8d113ccef5b417495348976132',
        'G1-C16':
            'f3492739deaeba761efc7e9f37bc9a608a161d213aa75d8fbd7be488fdcb7786',
        'G1-C17':
            '627719f0005525045dd6a0087c147b90cd3bd17a024ab56b4897488ccd267605',
        'G1-C18':
            'c2cd0dc4a5c5e6f2527b275212c945736660720a82328924f6c04a72509e4cbc',
        'G1-C19':
            '6b63c93390cac30d0cf7d4c1f16fc2cc11f9a2489ed1b287cda5cc98897b53c4',
        'G1-C20':
            '5f76008b3052d1995f821504072b11a5080d6d77467c76a3e13fc65e4efdba50',
        'G1-C21':
            'ba727741c1fbc43354c8f7afcb51b1d32252705af906ea9c6b8bf38f976744b8',
        'G1-C22':
            '63e1b81bff8090d48db6f7eb5e3bc7933bafb440b8eaa268344ef6f4c07d6c89',
        'G1-C23':
            '23fb40eed1ec297d9553273889bb1454b401dab186efa0d8fab42597622a320b',
        'G1-C24':
            '9c7a2ae1c96d01ffdbb168a220b8438913df435def874bcb0afcf1e9e4837912',
        'G1-C25':
            '1eb50a6ab080dc34d061745f811c5f745bc7e2d17af1873bdddec4668158add8',
        'G1-C26':
            '1634ecc5866c7d43f4d103ea88e65a0ae5e38546943363fbd54853b516e11a69',
        'G1-C27':
            '09fba1322c3e22a8c5718a5bca54618fe21b9c687698fa8e5d93966bfa2be065',
        'G1-C28':
            '42c9dabc1ba45abe9f64f94dbec3bdbc7cd1cfff171aaa7ba366f7d43860b974',
        'G1-C29':
            'b492549a9939335522d5d81c10ee7d63259120b7c8739e38689398c0fb4fa925',
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
    'All 290 Class 1 questions and 145 lesson fields support all three language modes',
    () {
      var questions = 0, texts = 0, lessons = 0;
      for (final chapter in chapters) {
        for (final question in chapter.questions(count: 10)) {
          questions++;
          for (final text in question.localizedTexts.values) {
            texts++;
            _reviewed(text);
          }
          for (final option in question.options) {
            if (RegExp(r'^\d+$').hasMatch(option.en)) {
              expect(option.mr, _marathi(option.en), reason: option.id);
            }
          }
        }
        for (final text in chapter.lesson.localizedTexts.values) {
          lessons++;
          _reviewed(text);
        }
      }
      expect(questions, 290);
      expect(texts, 2030);
      expect(lessons, 145);
    },
  );

  test(
    'Class 1 answers and worked quantities match every numerical question variant',
    () {
      for (final chapter in chapters) {
        final questions = chapter.questions(count: 10);
        for (var i = 0; i < questions.length; i++) {
          final q = questions[i];
          int? answer;
          switch (chapter.number) {
            case 7:
              answer = 1 + i % 9;
            case 8:
              answer = 0;
            case 9:
              answer = 10 - (4 + i % 4);
            case 10:
            case 25:
              final a = chapter.number == 10 ? 1 + i % 4 : 6 + i % 8;
              final cap = chapter.number == 10 ? 9 : 18;
              final b = chapter.number == 10
                  ? 1 + (i * 3) % (cap - a)
                  : 1 + (i * 5) % (cap - a);
              answer = a + b;
              expect(q.prompt.mr, contains(_marathi('$a')));
              expect(q.prompt.mr, contains(_marathi('$b')));
            case 11:
              answer = 9 - (1 + i % 8);
            case 12:
              answer = 10 + 1 + (i * 2 % 9);
            case 13:
              answer =
                  5 +
                  i * 3 +
                  (i % 3 == 0
                      ? -1
                      : i % 3 == 1
                      ? 1
                      : 0);
            case 16:
              answer = 2 + i;
            case 17:
              answer = 4 + i % 5 + 1 + i % 4;
            case 18:
              final a = 9 - i % 3;
              answer = a - (1 + i % (a - 1));
            case 19:
              answer = 21 + i % 10;
            case 20:
              answer = 31 + (i * 13) % 69;
            case 21:
              answer = 4 + i + 3;
            case 22:
              answer = 2 + i * 2 + 3 * (1 + i % 4);
            case 23:
              answer = 2 + i;
            case 26:
              answer = (1 + i ~/ 3) * [1, 2, 5, 10][i % 4] + [1, 2, 5][i % 3];
            case 27:
              answer = (2 + i % 6) * (3 + i % 5);
            case 28:
              answer = 3 + i % 6;
            case 29:
              answer = 3 + i * 2 - (2 + i);
          }
          if (answer != null) {
            expect(q.options[q.correctIndex].en, '$answer', reason: q.id);
            expect(
              q.options[q.correctIndex].mr,
              _marathi('$answer'),
              reason: q.id,
            );
            expect(
              _numbers(q.explanation.mr),
              contains(answer),
              reason: '${q.id}.explanation',
            );
          }
        }
      }
    },
  );

  test(
    'Ordering uses directional lists with unchanged values and supports equal numbers',
    () {
      final chapter = chapters.firstWhere((c) => c.number == 15);
      final questions = chapter.questions(count: 10);
      for (var i = 0; i < questions.length; i++) {
        final q = questions[i];
        final sorted = [12 + i * 5, 4 + i * 3, 21 + i * 2]..sort();
        final values = i.isOdd ? sorted.reversed.toList() : sorted;
        expect(q.options[q.correctIndex].en, values.join(' → '), reason: q.id);
        expect(
          q.options[q.correctIndex].mr,
          _marathi(values.join(' → ')),
          reason: q.id,
        );
        expect(q.explanation.en, isNot(contains('<')));
        expect(q.explanation.mr, contains(_marathi(values.join(' → '))));
        for (final option in q.options) {
          expect(option.en, isNot(startsWith('Option ')));
          expect(option.mr, isNot(startsWith('पर्याय ')));
        }
      }
      expect(
        questions[3].options[questions[3].correctIndex].mr,
        '२७ → २७ → १३',
      );
    },
  );

  test(
    'Class 1 vocabulary uses familiar contexts and noun-appropriate Marathi',
    () {
      ChapterQuestion q(int chapter, int i) => chapters
          .firstWhere((c) => c.number == chapter)
          .questions(count: 10)[i];
      expect(q(7, 0).prompt.mr, contains('१ आंबा आहे'));
      expect(q(7, 1).prompt.mr, contains('२ गोट्या आहेत'));
      expect(q(7, 9).prompt.mr, contains('१ पान आहे'));
      expect(q(8, 0).explanation.mr, contains('एकही वस्तू नाही'));
      expect(q(10, 0).prompt.mr, contains('१ पान गोळा केले'));
      expect(q(10, 2).prompt.mr, contains('गोट्या गोळा केल्या'));
      expect(q(11, 0).explanation.mr, contains('शेंगा उरल्या'));
      expect(q(11, 1).explanation.mr, contains('आंबे उरले'));
      expect(q(11, 3).explanation.mr, contains('कार्डे उरली'));
      expect(q(12, 0).prompt.mr, contains('दहाचा १ गट आणि १ सुटी वस्तू'));
      expect(q(12, 1).prompt.mr, contains('३ सुट्या वस्तू'));
      expect(q(17, 0).prompt.mr, contains('१ पाऊल पुढे'));
      expect(q(17, 1).prompt.mr, contains('२ पावले पुढे'));
      expect(q(18, 0).prompt.mr, contains('१ पाऊल मागे'));
      expect(q(19, 0).prompt.mr, contains('१ सुटी वस्तू'));
      expect(q(19, 0).explanation.mr, contains('१ एकक म्हणजे'));
      expect(q(20, 0).explanation.mr, contains('१ एकक आहेत'));
      expect(q(16, 0).prompt.mr, contains('एक चिन्ह म्हणजे १ लाल पतंग'));
      expect(q(24, 0).prompt.mr, contains('सोमवारी'));
      expect(q(24, 0).options[q(24, 0).correctIndex].mr, 'मंगळवार');
      expect(q(24, 1).options[q(24, 1).correctIndex].mr, 'गुरुवार');
      expect(q(28, 0).prompt.mr, contains('मित्रांना समान वाट'));
      expect(q(29, 0).hint.mr, contains('सुरुवातीची संख्या'));
      for (final chapter in chapters) {
        final all = [
          ...chapter.lesson.localizedTexts.values,
          for (final q in chapter.questions(count: 10))
            ...q.localizedTexts.values,
        ];
        for (final text in all) {
          expect(text.mr, isNot(contains('किशोर')));
          expect(text.mr, isNot(contains('प्रमाणित')));
          expect(text.mr, isNot(contains('पर्याय १')));
        }
      }
    },
  );
}

String _marathi(String value) => value
    .split('')
    .map((c) => int.tryParse(c) == null ? c : '०१२३४५६७८९'[int.parse(c)])
    .join();
Set<int> _numbers(String value) {
  final western = value
      .split('')
      .map((c) => '०१२३४५६७८९'.contains(c) ? '${'०१२३४५६७८९'.indexOf(c)}' : c)
      .join();
  return RegExp(
    r'\d+',
  ).allMatches(western).map((m) => int.parse(m[0]!)).toSet();
}

void _reviewed(Words text) {
  expect(text.mr.trim(), isNotEmpty, reason: text.id);
  expect(text.translationProvider, 'class1-contextual-edit', reason: text.id);
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
  expect(RegExp(r'[A-Za-z0-9]').hasMatch(text.mr), false, reason: text.id);
}
