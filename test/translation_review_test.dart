import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ganit_safar/content.dart';
import 'package:ganit_safar/store.dart';
import 'package:ganit_safar/translation_catalogue.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('legacy text keeps all display modes and honest review defaults', () {
    const words = Words('Count the books.', 'पुस्तके मोजा.');
    expect(words.inLanguage(0), 'Count the books.');
    expect(words.inLanguage(1), 'पुस्तके मोजा.');
    expect(words.inLanguage(2), 'Count the books.\nपुस्तके मोजा.');
    expect(words.marathiDraft, words.marathiSpoken);
    expect(words.translationStatus, 'needs-review');
    expect(words.translationProvider, 'local-authored');
    expect(words.id, const Words('Count the books.', 'पुस्तके मोजा.').id);
    expect(
      Words.fromJson({'en': words.en, 'mr': words.mr}).toJson(),
      words.toJson(),
    );
  });

  test(
    'supplied mango record round-trips without replacing draft or provenance',
    () {
      final record = {
        'id': 'class1_addition_mango_001',
        'english': 'Count the mangoes.',
        'marathiDraft': 'आंब्यांची गणना करा.',
        'marathiSpoken': 'आंबे मोजून पाहा.',
        'bilingual': 'Count the mangoes. आंबे मोजून पाहा.',
        'translationProvider': 'bhashini-indictrans2',
        'translationStatus': 'editor-reviewed',
        'mathGlossaryTerms': ['counting'],
        'reviewNotes':
            'Changed literal formal wording to child-friendly classroom Marathi',
      };
      final words = Words.fromJson(record);
      expect(words.toJson(), record);
      expect(reviewedMangoCounting.toJson(), record);
      expect(words.inLanguage(1), 'आंबे मोजून पाहा.');
      expect(words.audioReady['mr'], words.marathiSpoken);
      expect(words.accessibilityReady['mr'], words.marathiSpoken);
      expect(words.isEditorReviewed, isTrue);
      expect(
        () => words.mathGlossaryTerms.add('addition'),
        throwsUnsupportedError,
      );
      final contextual = words.identified(
        'another-context',
        glossaryTerms: ['addition'],
      );
      expect(contextual.id, words.id);
      expect(contextual.reviewNotes, words.reviewNotes);
      expect(words.mathGlossaryTerms, ['counting']);
    },
  );

  test('bad review records and incomplete bilingual display are rejected', () {
    for (final patch in [
      {'translationStatus': 'automatically-approved'},
      {'translationProvider': ''},
      {
        'mathGlossaryTerms': [1],
      },
      {'marathiDraft': 1},
      {'english': false},
      {'id': ''},
      {'bilingual': 'English only'},
      {'marathiSpoken': '', 'translationStatus': 'editor-reviewed'},
    ]) {
      expect(
        () => Words.fromJson({...reviewedMangoCounting.toJson(), ...patch}),
        throwsFormatException,
      );
    }
    final draft = Words.fromJson({
      'english': 'Count.',
      'marathiDraft': 'मोजा.',
      'marathiSpoken': '',
      'translationStatus': 'draft',
    });
    expect(draft.mr, 'मोजा.');
  });

  test('every chapter and supported sample type exports review-ready text', () {
    var total = 0, reviewed = 0;
    final byId = <String, Map<String, dynamic>>{};
    for (final record in learningTranslationRecords()) {
      final words = Words.fromJson(
        jsonDecode(jsonEncode(record)) as Map<String, dynamic>,
      );
      expect(words.en, isNotEmpty);
      expect(words.marathiDraft, isNotEmpty);
      expect(words.mr, isNotEmpty);
      expect(words.audioReady['mr'], words.mr);
      expect(
        words.toJson().keys,
        containsAll([
          'id',
          'english',
          'marathiDraft',
          'marathiSpoken',
          'bilingual',
          'translationProvider',
          'translationStatus',
          'mathGlossaryTerms',
          'reviewNotes',
        ]),
      );
      if (words.isEditorReviewed) {
        reviewed++;
        expect(words.id, reviewedMangoCounting.id);
      } else {
        expect(words.translationStatus, 'needs-review');
        expect(words.translationProvider, 'local-authored');
      }
      if (byId.containsKey(words.id)) expect(byId[words.id], words.toJson());
      byId[words.id] = words.toJson();
      total++;
    }
    expect(reviewed, 1);
    expect(total, greaterThan(6000));
    expect(
      byId.keys.where((id) => id.endsWith('.title') && id.startsWith('G')),
      hasLength(79),
    );
    expect(
      byId['G1-C10-q1.prompt']!['mathGlossaryTerms'],
      contains('addition'),
    );
  });

  test(
    'old custom backups migrate and reviewed wording survives save/restore',
    () async {
      SharedPreferences.setMockInitialValues({});
      final store = AppStore();
      await store.init();
      store.custom = [
        {
          'name': 'Counting',
          'grade': 1,
          'topic': 'add',
          'questions': [
            {
              'en': 'Count the mangoes.',
              'mr': 'आंब्यांची गणना करा.',
              'hintEn': 'Touch each mango once.',
              'hintMr': 'प्रत्येक आंब्याला एकदा स्पर्श करा.',
              'answer': 5,
            },
          ],
        },
      ];
      final old =
          jsonDecode(jsonEncode(store.encode())) as Map<String, dynamic>;
      final oldQuestion = old['custom'][0]['questions'][0] as Map;
      oldQuestion.remove('prompt');
      oldQuestion.remove('explanation');
      old.remove('extensionSchemaVersion');
      store.decode(old);
      expect(
        store.custom[0]['questions'][0]['prompt']['translationStatus'],
        'needs-review',
      );
      final question = Map<String, dynamic>.from(
        store.custom[0]['questions'][0],
      );
      question['prompt'] = reviewedMangoCounting.toJson();
      store.custom[0]['questions'][0] = normalizeCustomQuestion(question);
      await store.save();
      final restored = AppStore();
      await restored.init();
      final saved = restored.custom[0]['questions'][0];
      expect(saved['prompt'], reviewedMangoCounting.toJson());
      expect(saved['mr'], reviewedMangoCounting.marathiSpoken);
      expect(saved['audioMr'], reviewedMangoCounting.marathiSpoken);
      final before = restored.encode();
      final broken = jsonDecode(jsonEncode(before)) as Map<String, dynamic>;
      broken['custom'][0]['questions'][0]['prompt']['translationStatus'] =
          'false-approval';
      expect(() => restored.decode(broken), throwsFormatException);
      expect(restored.encode(), before);
    },
  );
}
