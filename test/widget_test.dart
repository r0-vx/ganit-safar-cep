import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ganit_safar/main.dart';
import 'package:ganit_safar/content.dart';

Future<void> openLearning(WidgetTester tester) async {
  await tester.pumpWidget(const GanitApp());
  await tester.pump(const Duration(milliseconds: 300));
  final offline = find.widgetWithText(
    OutlinedButton,
    store.language == 0
        ? 'Continue offline • Development mode'
        : store.language == 1
        ? 'इंटरनेटशिवाय पुढे जा • विकासासाठीचा पर्याय'
        : 'Continue offline • Development mode\nइंटरनेटशिवाय पुढे जा • विकासासाठीचा पर्याय',
  );
  await tester.ensureVisible(offline);
  await tester.tap(offline);
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await store.init();
    store.language = 0;
    store.grade = 1;
  });
  testWidgets('Home has working learning navigation and language switching', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await openLearning(tester);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Big adventures.\nLittle numbers.'), findsOneWidget);
    await tester.tap(find.text('Let’s explore'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Textbook chapter directory'), findsOneWidget);
    expect(find.text('My village'), findsOneWidget);
    store.language = 1;
    await store.save();
    await tester.pump();
    expect(find.text('पाठ्यपुस्तकातील धड्यांची यादी'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Drag activity also accepts a tap and gives gentle feedback', (
    tester,
  ) async {
    var passed = false;
    final q = makeQuestion('add', 1, 0, 'drag');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuestionActivity(
            q: q,
            topic: 'add',
            practice: true,
            onAnswer: (v) => passed = v,
          ),
        ),
      ),
    );
    await tester.tap(find.text('5'));
    await tester.pump();
    expect(passed, isTrue);
    expect(find.text('⭐ Wonderful work, explorer!'), findsOneWidget);
  });
  testWidgets('Short story lesson completes and updates saved progress', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    store.completed = [];
    store.stars = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StoryLessonPage(topic: topics[2], onDone: () {}, onQuiz: () {}),
        ),
      ),
    );
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Next'));
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.tap(find.text('5'));
    await tester.pump();
    final q = makeQuestion('add', 1, 1, 'choice');
    await tester.tap(find.text('${q.answer}'));
    await tester.pump();
    expect(find.text('Well done!'), findsOneWidget);
    expect(store.completed, contains('1:add'));
    expect(store.stars, 3);
  });
  testWidgets('Landscape whiteboard layout supports bilingual larger text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    store.language = 2;
    store.largeText = true;
    await openLearning(tester);
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    store.largeText = false;
  });
  testWidgets(
    'Quiz scores once and keeps reviewable mistakes in session only',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      store.results = [];
      store.stars = 0;
      store.language = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: QuizPage(
            topic: topics[2],
            config: {
              'count': 2,
              'random': false,
              'types': ['choice'],
              'seconds': 0,
            },
          ),
        ),
      );
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('Next question'));
      await tester.pump();
      final q = makeQuestion('add', 1, 1, 'choice');
      await tester.tap(
        find.text('${q.options.firstWhere((n) => n != q.answer)}'),
      );
      await tester.pump();
      await tester.tap(find.text('See my discoveries'));
      await tester.pump();
      expect(find.text('1 / 2'), findsOneWidget);
      expect(store.results, isEmpty);
      expect(store.stars, 0);
      expect(find.text('Current Session Result'), findsOneWidget);
      await tester.tap(find.text('Review mistakes'));
      await tester.pump();
      expect(find.text(q.explanation.en), findsOneWidget);
    },
  );
  testWidgets('Teacher access requires a valid local PIN', (tester) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    store.language = 0;
    await openLearning(tester);
    await tester.pump();
    await tester.tap(find.text('Teacher mode').first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byType(TextField), '0000');
    await tester.tap(find.text('Unlock'));
    await tester.pump();
    expect(find.text('Please check your PIN.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '1234');
    await tester.tap(find.text('Unlock'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Your custom quizzes'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
  testWidgets('Teacher creates a bilingual quiz and saves it locally', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    store.language = 0;
    store.custom = [];
    await tester.pumpWidget(
      MaterialApp(home: CustomQuizEditor(topic: topics[2])),
    );
    final values = {
      'Quiz name': 'Mango friends',
      'Question in English': '2 + 3 = ?',
      'Question in Marathi': '२ + ३ = ?',
      'Correct number': '5',
      'English explanation': 'Put 2 and 3 together.',
      'Marathi explanation': '२ आणि ३ एकत्र करा.',
    };
    for (final entry in values.entries) {
      final field = find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == entry.key,
      );
      await tester.ensureVisible(field);
      await tester.enterText(field, entry.value);
    }
    await tester.ensureVisible(find.text('Add question'));
    await tester.tap(find.text('Add question'));
    await tester.pump();
    await tester.ensureVisible(find.text('Save quiz offline'));
    await tester.tap(find.text('Save quiz offline'));
    await tester.pump();
    expect(store.custom.length, 1);
    expect(store.custom.first['questions'].first['mr'], '२ + ३ = ?');
  });
  testWidgets('Team turns award positive scores and move to the next team', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    store.language = 0;
    store.grade = 1;
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TeamPage())),
    );
    await tester.tap(find.text('Start team adventure'));
    await tester.pump();
    await tester.tap(find.text('5', skipOffstage: false).first);
    await tester.pump();
    expect(find.text('⭐ 3'), findsOneWidget);
    await tester.tap(find.text('Next team'));
    await tester.pump();
    expect(find.text('Your turn!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Compact web landscape has no layout overflows', (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    store.language = 2;
    store.largeText = true;
    await openLearning(tester);
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    store.largeText = false;
  });
}
