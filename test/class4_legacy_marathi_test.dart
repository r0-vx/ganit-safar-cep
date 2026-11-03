import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ganit_safar/content.dart';
import 'package:ganit_safar/curriculum.dart';
import 'package:ganit_safar/generator.dart';

void main() {
  test(
    'All 1,890 original Class 4 legacy English/math variants are unchanged',
    () {
      // Captured before the Marathi rewrite: 14 families, each supported type,
      // seeds 0, 1, 2, 9 and 29 at all three difficulties. No Marathi fields
      // enter this fingerprint.
      final records = <Map<String, dynamic>>[];
      for (final topic in topics) {
        for (final type in questionTypes.where(
          (t) => supportsType(topic.id, t),
        )) {
          for (var difficulty = 1; difficulty <= 3; difficulty++) {
            for (final seed in [0, 1, 2, 9, 29]) {
              final q = makeQuestion(
                topic.id,
                4,
                seed,
                type,
                difficulty: difficulty,
              );
              records.add({
                'topic': topic.id,
                'type': q.type,
                'id': q.id,
                'a': q.a,
                'b': q.b,
                'answer': q.answer,
                'options': q.options,
                'prompt': q.prompt.en,
                'explanation': q.explanation.en,
              });
            }
          }
        }
      }
      expect(records.length, 1890);
      expect(
        sha256.convert(utf8.encode(jsonEncode(records))).toString(),
        'dce77aaa4b9e0bd321606d759ea990728dfa4140ce56635caedaa176d79c12b6',
      );
    },
  );

  test(
    'Every legacy family/type/difficulty has contextual Marathi and the same valid mathematics',
    () {
      var generated = 0;
      for (final topic in topics) {
        for (final type in questionTypes.where(
          (t) => supportsType(topic.id, t),
        )) {
          for (var difficulty = 1; difficulty <= 3; difficulty++) {
            for (var seed = 0; seed < 80; seed++) {
              final q = makeQuestion(
                topic.id,
                4,
                seed,
                type,
                difficulty: difficulty,
              );
              generated++;
              expect(q.prompt.translationProvider, 'class4-contextual-edit');
              expect(
                q.explanation.translationProvider,
                'class4-contextual-edit',
              );
              expect(q.prompt.translationStatus, 'draft');
              expect(q.prompt.isEditorReviewed, false);
              expect(q.prompt.mr, isNot(q.prompt.marathiDraft));
              expect(q.explanation.mr, isNot(q.explanation.marathiDraft));
              expect(q.prompt.bilingual, '${q.prompt.en}\n${q.prompt.mr}');
              expect(q.prompt.audioReady['mr'], q.prompt.mr);
              expect(q.prompt.accessibilityReady['mr'], q.prompt.mr);
              expect(
                RegExp(r'[0-9A-Za-z]').hasMatch(q.prompt.mr),
                false,
                reason: '${q.id}: ${q.prompt.mr}',
              );
              expect(
                RegExp(r'[0-9A-Za-z]').hasMatch(q.explanation.mr),
                false,
                reason: '${q.id}: ${q.explanation.mr}',
              );
              final errors = validateQuestion(q).errors;
              // The old generator rejects counting pictures that would truncate
              // large arithmetic quantities. A language edit must not bypass it.
              final countTooLarge =
                  type == 'count' &&
                  ['add', 'word', 'multiply', 'divide'].contains(topic.id) &&
                  (topic.id == 'multiply'
                          ? q.a * q.b
                          : topic.id == 'divide'
                          ? q.a
                          : q.a + q.b) >
                      36;
              expect(
                errors,
                countTooLarge
                    ? ['Use a grouped model instead of truncated counting']
                    : isEmpty,
                reason: q.id,
              );
              expect(q.metadata!.grade, 4);
              expect(q.metadata!.difficulty, difficulty);
              expect(q.metadata!.seed, seed);
              expect(q.options.toSet().length, 4);
              expect(q.options, contains(q.answer));
            }
          }
        }
      }
      expect(generated, 30240);
    },
  );

  test(
    'Class 4 wording explains the actual task and handles singular forms',
    () {
      final addition = makeQuestion('add', 4, 0, 'choice');
      expect(addition.prompt.mr, contains('मीराकडे ३८ आंबे आहेत'));
      expect(addition.explanation.mr, contains('३८ + ६ = ४४'));
      expect(addition.prompt.marathiDraft, contains('38 आंबे'));
      final apple = makeQuestion('count', 4, 0, 'choice');
      expect(apple.explanation.mr, contains('१ सफरचंद आहे'));
      final train = makeQuestion('word', 4, 0, 'choice');
      expect(train.prompt.mr, contains('१ मूल चढते'));
      final farm = makeQuestion('data', 4, 0, 'choice');
      expect(farm.prompt.mr, contains('१ शेळी आहे'));
      final time = makeQuestion('time', 4, 0, 'choice');
      expect(time.explanation.mr, contains('१ वाजला आहे'));
      final circle = makeQuestion('shape', 4, 2, 'construct');
      expect(circle.prompt.mr, contains('वर्तुळाला किती सरळ बाजू'));
      expect(circle.explanation.mr, contains('सरळ बाजू किंवा कोपरे नसतात'));
      expect(circle.answer, 0);
      final place = makeQuestion('place', 4, 100, 'choice');
      expect(place.a, 421);
      expect(place.answer, 42);
      expect(place.prompt.mr, contains('दहा-दहाचे गट'));
      expect(place.explanation.mr, contains('४२ × १० + १'));
      expect(place.prompt.mr, isNot(contains('दशकाच्या स्थानी कोणता अंक')));
      final fraction = makeQuestion('fraction', 4, 0, 'colour');
      expect(fraction.prompt.mr, contains('समान भाग'));
      expect(fraction.explanation.mr, contains('१ भाग रंगवला आहे'));
    },
  );

  test(
    'All fourteen Class 4 help cards and stories preserve provenance and English',
    () {
      for (final topic in topics) {
        final outcome = outcomeFor(4, topic.id);
        for (final text in [
          outcome.objective,
          outcome.definition,
          outcome.hint,
          outcome.commonMistake,
          outcome.vocabularyText,
        ]) {
          expect(text.mr, isNotEmpty);
          expect(text.translationProvider, 'class4-contextual-edit');
          expect(text.translationStatus, 'draft');
          expect(text.marathiDraft, isNotEmpty);
          expect(text.en, isNotEmpty);
          expect(text.bilingual, '${text.en}\n${text.mr}');
        }
        final source = lessonStory(topic.id);
        final revised = lessonStory(topic.id, grade: 4);
        expect(revised.en, source.en);
        expect(revised.marathiDraft, source.marathiDraft);
        expect(revised.translationProvider, 'class4-contextual-edit');
        expect(revised.isEditorReviewed, false);
      }
      expect(outcomeFor(4, 'fraction').definition.mr, contains('समान भाग'));
      expect(
        outcomeFor(4, 'money').definition.mr,
        contains('प्रत्येक नाण्याची किंमत'),
      );
      expect(outcomeFor(4, 'shape').definition.mr, contains('कोपरे नसतात'));
    },
  );

  test('Classes 1–3 keep original legacy wording, metadata and help', () {
    for (var grade = 1; grade <= 3; grade++) {
      for (final topic in topics) {
        final q = makeQuestion(topic.id, grade, 0, 'choice');
        expect(q.prompt.translationProvider, 'local-authored');
        expect(q.prompt.translationStatus, 'needs-review');
        expect(q.prompt.mr, q.prompt.marathiDraft);
        expect(q.explanation.mr, q.explanation.marathiDraft);
        expect(
          outcomeFor(grade, topic.id).objective.translationProvider,
          'local-authored',
        );
        expect(
          lessonStory(topic.id, grade: grade).toJson(),
          lessonStory(topic.id).toJson(),
        );
      }
    }
    expect(
      makeQuestion('time', 1, 0, 'choice').prompt.mr,
      'मोठा काटा 12 वर आहे. किती वाजले आहेत?',
    );
  });
}
