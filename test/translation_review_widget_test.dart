import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ganit_safar/content.dart';
import 'package:ganit_safar/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await store.init();
    store.language = 1;
    store.grade = 1;
    store.sound = false;
    store.reducedMotion = true;
    store.custom = [];
  });

  testWidgets('mango teaching uses the reviewed classroom wording', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      _app(
        () => StoryLessonPage(topic: topics[2], onDone: () {}, onQuiz: () {}),
      ),
    );
    expect(find.text('आंबे मोजून पाहा.'), findsOneWidget);
    expect(find.text('आंब्यांची गणना करा.'), findsNothing);
    store.language = 2;
    await store.save();
    await tester.pumpAndSettle();
    expect(find.text(reviewedMangoCounting.bilingual), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'custom quiz plays spoken wording and preserves it across language changes',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final question = normalizeCustomQuestion({
        'en': reviewedMangoCounting.en,
        'mr': reviewedMangoCounting.marathiDraft,
        'hintEn': 'Touch each mango once.',
        'hintMr': 'प्रत्येक आंब्याला एकदा स्पर्श करा.',
        'answer': 5,
        'prompt': reviewedMangoCounting.toJson(),
      });
      await tester.pumpWidget(
        _app(
          () => QuizPage(
            topic: topics[2],
            config: {
              'count': 1,
              'seconds': 0,
              'questions': [question],
            },
          ),
        ),
      );
      expect(find.text(reviewedMangoCounting.marathiSpoken), findsOneWidget);
      expect(find.text(reviewedMangoCounting.marathiDraft), findsNothing);
      store.language = 0;
      await store.save();
      await tester.pumpAndSettle();
      expect(find.text(reviewedMangoCounting.en), findsOneWidget);
      store.language = 2;
      await store.save();
      await tester.pumpAndSettle();
      expect(find.text(reviewedMangoCounting.bilingual), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'teacher can save separate draft, classroom wording and review notes',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      store.language = 0;
      await tester.pumpWidget(
        _app(
          () => Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CustomQuizEditor(topic: topics[2]),
                  ),
                ),
                child: const Text('Open editor'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open editor'));
      await tester.pumpAndSettle();
      for (final entry in {
        'Quiz name': 'Mango review',
        'Question in English': reviewedMangoCounting.en,
        'Question in Marathi': reviewedMangoCounting.marathiDraft,
        'Classroom Marathi (optional)': reviewedMangoCounting.marathiSpoken,
        'Correct number': '5',
        'English explanation': 'Touch each mango once.',
        'Marathi explanation': 'प्रत्येक आंब्याला एकदा स्पर्श करा.',
        'Classroom Marathi explanation (optional)': 'प्रत्येक आंबा एकदाच मोजा.',
        'Wording review notes (optional)': 'Checked classroom wording.',
      }.entries) {
        final field = find.byWidgetPredicate(
          (widget) =>
              widget is TextField && widget.decoration?.labelText == entry.key,
        );
        await tester.ensureVisible(field);
        await tester.enterText(field, entry.value);
        await tester.pumpAndSettle();
      }
      final review = find.byType(SwitchListTile);
      await tester.ensureVisible(review);
      await tester.tap(review);
      await tester.pumpAndSettle();
      final add = find.text('Add question');
      await tester.ensureVisible(add);
      await tester.tap(add);
      await tester.pumpAndSettle();
      final save = find.text('Save quiz offline');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(store.custom, hasLength(1));
      final question = store.custom[0]['questions'][0];
      expect(
        question['prompt']['marathiDraft'],
        reviewedMangoCounting.marathiDraft,
      );
      expect(
        question['prompt']['marathiSpoken'],
        reviewedMangoCounting.marathiSpoken,
      );
      expect(question['prompt']['translationStatus'], 'editor-reviewed');
      expect(question['prompt']['translationProvider'], 'teacher-local');
      expect(question['prompt']['reviewNotes'], 'Checked classroom wording.');
      expect(
        question['explanation']['marathiSpoken'],
        'प्रत्येक आंबा एकदाच मोजा.',
      );
      expect(tester.takeException(), isNull);
    },
  );
}

Widget _app(Widget Function() child) => ListenableBuilder(
  listenable: store,
  builder: (context, _) => MaterialApp(home: child()),
);
