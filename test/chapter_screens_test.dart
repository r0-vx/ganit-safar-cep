import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ganit_safar/chapter_catalogue.dart';
import 'package:ganit_safar/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await store.init();
    store.language = 0;
    store.grade = 1;
    store.sound = false;
    store.contrast = false;
    store.largeText = false;
    store.smartboard = true;
    store.reducedMotion = true;
    store.slow = false;
    store.stars = 0;
    store.completed = [];
    store.completedChapters = [];
    store.results = [];
    await store.save();
  });

  testWidgets('directory exposes the approved chapter count for each class', (
    tester,
  ) async {
    store.grade = 4;
    await tester.pumpWidget(_boardApp(const ChapterDirectoryPage()));

    expect(
      [for (var grade = 1; grade <= 4; grade++) chaptersForGrade(grade).length],
      [29, 22, 14, 14],
    );
    expect(find.text('29 chapters'), findsOneWidget);
    expect(find.text('22 chapters'), findsOneWidget);
    expect(find.text('14 chapters'), findsNWidgets(2));
    expect(find.text('Class 4 chapters'), findsOneWidget);
    expect(
      find.text('14 chapters • Tap a chapter to open its lesson.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('touching a chapter opens the lesson and completes its stages', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final chapter = chaptersForGrade(1).first;
    await tester.pumpWidget(_boardApp(const ChapterDirectoryPage()));

    final chapterTitle = find.text(chapter.title.en);
    await tester.ensureVisible(chapterTitle);
    await tester.tap(chapterTitle);
    await tester.pumpAndSettle();
    expect(find.text('Chapter 1 • My village'), findsOneWidget);
    expect(find.text(chapter.lesson.story.en), findsOneWidget);

    for (var i = 0; i < 3; i++) {
      final next = find.text('Next step');
      await tester.ensureVisible(next);
      await tester.tap(next);
      await tester.pumpAndSettle();
    }
    expect(
      find.textContaining('Touch the objects to explore the idea'),
      findsOneWidget,
    );

    final checkQuestion = chapter.questions(count: 5).first;
    final nextToCheck = find.text('Next step');
    await tester.ensureVisible(nextToCheck);
    await tester.tap(nextToCheck);
    await tester.pumpAndSettle();
    final correctOption = find.text(
      checkQuestion.options[checkQuestion.correctIndex].en,
    );
    await tester.ensureVisible(correctOption);
    await tester.tap(correctOption);
    await tester.pumpAndSettle();
    expect(find.text('That’s right. You are ready to recap.'), findsOneWidget);

    final recap = find.text('Continue to recap');
    await tester.ensureVisible(recap);
    await tester.tap(recap);
    await tester.pumpAndSettle();
    expect(find.text('Chapter lesson complete'), findsOneWidget);
    expect(store.isChapterDone(chapter.id), isTrue);
    expect(store.stars, 3);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switching language keeps the current lesson stage', (
    tester,
  ) async {
    final chapter = chaptersForGrade(1).first;
    await tester.pumpWidget(_boardApp(ChapterLessonPage(chapter: chapter)));

    final next = find.text('Next step');
    await tester.ensureVisible(next);
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(find.text(chapter.lesson.concept.en), findsOneWidget);

    await _switchToMarathi(tester);

    expect(store.language, 1);
    expect(find.text(chapter.lesson.concept.mr), findsOneWidget);
    expect(find.textContaining('टप्पा 2 / 6'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switching language preserves the selected practice answer', (
    tester,
  ) async {
    final chapter = chaptersForGrade(1).first;
    final question = chapter.questions(count: 5).first;
    final wrongIndex = (question.correctIndex + 1) % question.options.length;
    final wrongOption = question.options[wrongIndex];
    await tester.pumpWidget(
      _boardApp(
        ChapterSessionPage(chapter: chapter, mode: ChapterSessionMode.practice),
      ),
    );

    final answer = find.text(wrongOption.en);
    await tester.ensureVisible(answer);
    await tester.tap(answer);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    await _switchToMarathi(tester);

    expect(store.language, 1);
    expect(find.text(wrongOption.mr), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(
      find.text('छान प्रयत्न. पुन्हा पाहा आणि उत्तर बदला.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'quiz result stays in the session and does not change saved history',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final chapter = chaptersForGrade(1).first;
      final questions = chapter.questions(count: 5);
      store.stars = 7;
      store.completed = ['1:add'];
      store.completedChapters = ['G1-C01'];
      store.results = [
        {
          'topic': 'add',
          'grade': 1,
          'correct': 1,
          'total': 2,
          'mistakes': <Object>[],
          'date': DateTime.utc(2026, 1, 1).toIso8601String(),
        },
      ];
      await store.save();
      final beforeStars = store.stars;
      final beforeCompleted = List<String>.of(store.completedChapters);
      final beforeResults = List<dynamic>.of(store.results);
      final prefs = await SharedPreferences.getInstance();
      final beforeSavedData = prefs.getString('ganit_safar_v1');

      await tester.pumpWidget(
        _boardApp(
          ChapterSessionPage(chapter: chapter, mode: ChapterSessionMode.quiz),
        ),
      );

      for (var i = 0; i < questions.length; i++) {
        final question = questions[i];
        final index = i == 0
            ? (question.correctIndex + 1) % question.options.length
            : question.correctIndex;
        final choice = find.text(question.options[index].en);
        await tester.ensureVisible(choice);
        await tester.tap(choice);
        await tester.pumpAndSettle();

        final advance = find.text(
          i == questions.length - 1 ? 'Finish quiz' : 'Next question',
        );
        await tester.ensureVisible(advance);
        await tester.tap(advance);
        await tester.pumpAndSettle();
      }

      expect(find.text('Current Session Result'), findsOneWidget);
      expect(find.textContaining('Correct 4 • Incorrect 1'), findsOneWidget);
      expect(store.stars, beforeStars);
      expect(store.completedChapters, beforeCompleted);
      expect(store.results, beforeResults);
      expect(prefs.getString('ganit_safar_v1'), beforeSavedData);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'directory fits phone, board, and wide layouts with bilingual large text',
    (tester) async {
      store.language = 2;
      store.largeText = true;
      store.grade = 4;

      for (final width in [375.0, 1024.0, 1920.0]) {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(_boardApp(const ChapterDirectoryPage()));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Textbook chapter directory'),
          findsOneWidget,
        );
        expect(find.textContaining('धड्यांची सूची'), findsOneWidget);
        expect(find.textContaining('इयत्ता 4 चे धडे'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'viewport width $width');
      }

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    },
  );
}

Widget _boardApp(Widget home) => MaterialApp(
  theme: boardTheme(
    contrast: store.contrast,
    largeText: store.largeText,
    smartboard: store.smartboard,
  ),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(store.largeText ? 1.15 : 1)),
    child: child!,
  ),
  home: home,
);

Future<void> _switchToMarathi(WidgetTester tester) async {
  final language = find.byType(DropdownButton<int>);
  expect(language, findsOneWidget);
  await tester.tap(language);
  await tester.pumpAndSettle();
  await tester.tap(find.text('मराठी').last);
  await tester.pumpAndSettle();
}
