import 'package:flutter_test/flutter_test.dart';
import 'package:ganit_safar/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'chapter completion is awarded once and survives backup restore',
    () async {
      final original = AppStore();
      await original.init();
      original.completeChapter('G1-C10');
      original.completeChapter('G1-C10');
      await original.save();
      final copy = AppStore();
      await copy.init();
      copy.decode(original.encode());
      expect(copy.completedChapters, ['G1-C10']);
      expect(copy.stars, 3);
      expect(copy.results, isEmpty);
      expect(copy.smartboard, isTrue);
      copy.reset(archive: true);
      await copy.save();
      expect(copy.completedChapters, isEmpty);
      expect(copy.archives.single['completedChapters'], ['G1-C10']);
    },
  );

  test(
    'old backup defaults board controls and preserves original progress',
    () async {
      final original = AppStore();
      await original.init();
      original.complete('add');
      final old = original.encode()..remove('smartboard');
      (old['progress'] as Map).remove('completedChapters');
      final restored = AppStore()..decode(old);
      expect(restored.completed, ['1:add']);
      expect(restored.completedChapters, isEmpty);
      expect(restored.smartboard, isTrue);
      restored.smartboard = false;
      expect((AppStore()..decode(restored.encode())).smartboard, isFalse);
    },
  );

  test('invalid chapter progress is rejected before restore', () async {
    final store = AppStore();
    await store.init();
    final data = store.encode();
    (data['progress'] as Map)['completedChapters'] = ['G4-C99'];
    expect(() => AppStore().decode(data), throwsFormatException);
  });
}
