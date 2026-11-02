import 'package:flutter_test/flutter_test.dart';
import 'package:ganit_safar/content.dart';
import 'package:ganit_safar/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'portable learning backup excludes PIN verifiers and cannot replace local authentication',
    () async {
      SharedPreferences.setMockInitialValues({});
      final source = AppStore();
      await source.init();
      source.pinHash = AppStore.digest('private-local-pin');
      source.stars = 9;
      final backup = source.learningBackup();
      expect(backup.containsKey('pinHash'), isFalse);
      final target = AppStore();
      await target.init();
      target.pinHash = AppStore.digest('different-local-pin');
      final original = target.pinHash;
      target.restoreLearningBackup({...backup, 'pinHash': 'malicious-import'});
      expect(target.pinHash, original);
      expect(target.stars, 9);
    },
  );

  test('Every class/topic has ten valid bilingual sample questions', () {
    for (var grade = 1; grade <= 4; grade++) {
      for (final topic in topics) {
        for (var i = 0; i < 10; i++) {
          final q = makeQuestion(topic.id, grade, i, 'choice');
          expect(q.prompt.en, isNotEmpty);
          expect(q.prompt.mr, isNotEmpty);
          expect(q.explanation.en, isNotEmpty);
          expect(q.explanation.mr, isNotEmpty);
          expect(q.options.toSet().length, 4);
          expect(q.options, contains(q.answer));
          expect(q.answer, greaterThanOrEqualTo(0));
          expect(q.prompt.audioReady.keys, containsAll(['en', 'mr']));
        }
      }
    }
  });
  test('Mango introduction and arithmetic stay correct', () {
    final q = makeQuestion('add', 1, 0, 'choice');
    expect([q.a, q.b, q.answer], [3, 2, 5]);
    for (final t in ['add', 'subtract', 'multiply', 'divide', 'money']) {
      for (var grade = 1; grade <= 4; grade++) {
        for (var i = 0; i < 20; i++) {
          final q = makeQuestion(t, grade, i, 'choice');
          final expected = switch (t) {
            'subtract' => q.a - q.b,
            'multiply' => q.a * q.b,
            'divide' => q.a ~/ q.b,
            _ => q.a + q.b,
          };
          expect(q.answer, expected);
        }
      }
    }
  });
  test(
    'Progress persists, badges are idempotent, profiles isolated, backup restores',
    () async {
      SharedPreferences.setMockInitialValues({});
      final s = AppStore();
      await s.init();
      s.complete('add');
      s.complete('add');
      await s.save();
      expect(s.stars, 3);
      expect(s.completed.length, 1);
      s.record('add', 8, 10, []);
      await s.save();
      final loaded = AppStore();
      await loaded.init();
      expect(loaded.stars, 11);
      expect(loaded.results.length, 1);
      await loaded.switchProfile('Mira');
      expect(loaded.stars, 0);
      loaded.complete('count');
      await loaded.save();
      await loaded.switchProfile('Classroom');
      expect(loaded.stars, 11);
      final backup = loaded.encode();
      final restored = AppStore();
      await restored.init();
      restored.decode(backup);
      expect(restored.results.length, 1);
      restored.reset();
      expect(restored.results, isEmpty);
      expect(restored.archives.length, 1);
    },
  );
  test('Invalid backup is rejected', () {
    expect(() => AppStore().decode({'version': 2}), throwsFormatException);
  });
  test(
    'Each grade/topic bank provides at least ten distinct question variants',
    () {
      for (var grade = 1; grade <= 4; grade++) {
        for (final topic in topics) {
          final variants = <String>{};
          for (var i = 0; i < 100; i++) {
            final q = makeQuestion(topic.id, grade, i, 'choice');
            variants.add('${q.prompt.en}:${q.a}:${q.b}');
          }
          expect(
            variants.length,
            greaterThanOrEqualTo(10),
            reason: 'Class $grade / ${topic.id}',
          );
        }
      }
    },
  );
}
