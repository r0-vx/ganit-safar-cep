import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ganit_safar/content.dart';
import 'package:ganit_safar/curriculum.dart';
import 'package:ganit_safar/generator.dart';
import '../scripts/audit_class4_marathi.dart';
import '../scripts/freeze_class4_baseline.dart' as baseline;
import '../scripts/freeze_primary_marathi_baseline.dart' as primary;

void main() {
  test(
    'All 42 legacy topic families retain English, maths, identities and original drafts',
    () {
      final before = jsonDecode(
        File(
          'test/fixtures/classes123_marathi_baseline.json',
        ).readAsStringSync(),
      );
      final current = buildClass4AuditInventory();
      var families = 0;
      for (final record in (current['legacy'] as List).where(
        (c) => c['grade'] <= 3,
      )) {
        families++;
        expect(
          baseline.fingerprint(baseline.semantic(record)),
          before['legacySemantics'][record['id']],
          reason: record['id'],
        );
        expect(
          baseline.fingerprint(primary.originalDrafts(record)),
          before['originalDrafts']['legacy'][record['id']],
          reason: '${record['id']} original drafts',
        );
      }
      expect(families, 42);
    },
  );

  test(
    '90,720 numerical variants keep validation and localized classroom wording',
    () {
      var generated = 0;
      for (final grade in [1, 2, 3]) {
        for (final topic in topics) {
          for (final type in questionTypes.where(
            (t) => supportsType(topic.id, t),
          )) {
            for (final difficulty in [1, 2, 3]) {
              for (var seed = 0; seed < 80; seed++) {
                final q = makeQuestion(
                  topic.id,
                  grade,
                  seed,
                  type,
                  difficulty: difficulty,
                );
                generated++;
                for (final text in q.localizedTexts.values) {
                  expect(
                    text.translationProvider,
                    'class$grade-contextual-edit',
                  );
                  expect(text.translationStatus, 'draft');
                  expect(text.marathiDraft, isNotEmpty);
                  expect(
                    RegExp(r'[A-Za-z0-9]').hasMatch(text.mr),
                    false,
                    reason: '${q.id}: ${text.mr}',
                  );
                  expect(text.inLanguage(2), '${text.en}\n${text.mr}');
                  expect(text.audioReady['mr'], text.mr);
                  expect(text.accessibilityReady['mr'], text.mr);
                }
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
                  validateQuestion(q).errors,
                  countTooLarge
                      ? ['Use a grouped model instead of truncated counting']
                      : isEmpty,
                  reason: q.id,
                );
                expect(q.options.toSet().length, 4);
                expect(q.options, contains(q.answer));
              }
            }
          }
        }
      }
      expect(generated, 90720);
    },
  );

  test(
    'Every help field and story is contextual in all three primary grades',
    () {
      for (final grade in [1, 2, 3]) {
        for (final topic in topics) {
          final outcome = outcomeFor(grade, topic.id);
          for (final text in [
            outcome.objective,
            outcome.definition,
            outcome.hint,
            outcome.commonMistake,
            outcome.vocabularyText,
            lessonStory(topic.id, grade: grade),
          ]) {
            expect(text.translationProvider, 'class$grade-contextual-edit');
            expect(text.translationStatus, 'draft');
            expect(text.inLanguage(2), '${text.en}\n${text.mr}');
            expect(text.audioReady['mr'], text.mr);
            expect(text.accessibilityReady['mr'], text.mr);
          }
        }
      }
      expect(outcomeFor(1, 'place').commonMistake.mr, isNot(contains('१२५')));
      expect(
        makeQuestion('shape', 1, 2, 'choice').explanation.mr,
        contains('वर्तुळ'),
      );
    },
  );
}
