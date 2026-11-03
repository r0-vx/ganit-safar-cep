import 'dart:convert';
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
    store.reducedMotion = true;
    store.largeText = false;
    store.contrast = false;
    store.smartboard = true;
    store.stars = 5;
    store.completedChapters = ['G1-C01'];
    store.results = [];
    await store.save();
  });

  testWidgets(
    'Practice help and language preserve answer and counted objects',
    (tester) async {
      _viewport(tester, 1280, 1100);
      final chapter = chaptersForGrade(1).firstWhere((c) => c.number == 10);
      final q = chapter.questions().first;
      final wrong = (q.correctIndex + 1) % q.options.length;
      await tester.pumpWidget(
        _app(
          ChapterSessionPage(
            chapter: chapter,
            mode: ChapterSessionMode.practice,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final item = find.byKey(const ValueKey('scene-object-0'));
      expect(item, findsOneWidget);
      await tester.ensureVisible(item);
      await tester.tap(item);
      await tester.pumpAndSettle();
      expect(find.textContaining('Counted 1 objects'), findsOneWidget);
      await _tap(tester, find.byKey(ValueKey('session-answer-$wrong')));
      await _tap(tester, find.text('Help'));
      expect(find.text('Learning help'), findsOneWidget);
      expect(find.textContaining('Counted 1 objects'), findsOneWidget);
      expect(_selected(wrong), findsOneWidget);
      await _tap(tester, find.byType(DropdownButton<int>));
      await _tap(tester, find.text('मराठी').last);
      expect(_selected(wrong), findsOneWidget);
      expect(find.textContaining('मोजलेल्या वस्तू: १'), findsOneWidget);
      await _tap(tester, find.byTooltip('मदत बंद कर'));
      expect(_selected(wrong), findsOneWidget);
      expect(find.textContaining('मोजलेल्या वस्तू: १'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Quiz locks submitted choices, defers feedback and keeps scores temporary',
    (tester) async {
      _viewport(tester, 1280, 1100);
      final chapter = chaptersForGrade(1).firstWhere((c) => c.number == 10);
      final questions = chapter.questions();
      final prefs = await SharedPreferences.getInstance();
      final before = prefs.getString('ganit_safar_v1');
      final original = jsonEncode({
        'stars': store.stars,
        'chapters': store.completedChapters,
        'results': store.results,
      });
      await tester.pumpWidget(
        _app(
          ChapterSessionPage(chapter: chapter, mode: ChapterSessionMode.quiz),
        ),
      );
      await tester.pumpAndSettle();
      for (var i = 0; i < questions.length; i++) {
        final q = questions[i];
        final index = i == 0
            ? (q.correctIndex + 1) % q.options.length
            : q.correctIndex;
        await _tap(tester, find.byKey(ValueKey('session-answer-$index')));
        expect(find.byType(AnswerFeedback), findsNothing);
        expect(find.text('Submit answer'), findsOneWidget);
        await _tap(tester, find.text('Submit answer'));
        expect(find.text('Submit answer'), findsNothing);
        expect(find.byType(AnswerFeedback), findsNothing);
        if (i == 0) {
          final beforeSelection = _selected(index);
          expect(beforeSelection, findsOneWidget);
          await tester.tap(
            find.byKey(ValueKey('session-answer-${q.correctIndex}')),
            warnIfMissed: false,
          );
          await tester.pumpAndSettle();
          expect(_selected(index), findsOneWidget);
        }
        await _tap(
          tester,
          find.text(
            i == questions.length - 1 ? 'Finish quiz' : 'Next question',
          ),
        );
      }
      expect(find.text('Current Session Result'), findsOneWidget);
      expect(find.textContaining('Correct 4 • Incorrect 1'), findsOneWidget);
      await _tap(tester, find.text('Review mistakes'));
      expect(find.textContaining('Your answer:'), findsOneWidget);
      expect(find.textContaining('Answer:'), findsOneWidget);
      expect(
        jsonEncode({
          'stars': store.stars,
          'chapters': store.completedChapters,
          'results': store.results,
        }),
        original,
      );
      expect(prefs.getString('ganit_safar_v1'), before);
      await _tap(tester, find.text('Try again'));
      expect(find.text('Current Session Result'), findsNothing);
      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
      expect(find.text('Skip question'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Bilingual sessions support large text and reduced motion on phone and board',
    (tester) async {
      store.language = 2;
      store.largeText = true;
      store.contrast = true;
      final chapter = chaptersForGrade(
        4,
      ).firstWhere((c) => c.strand == 'fraction');
      for (final width in [375.0, 1024.0, 1920.0]) {
        _viewport(tester, width, 1100);
        for (final mode in ChapterSessionMode.values) {
          await tester.pumpWidget(
            _app(
              ChapterSessionPage(
                key: UniqueKey(),
                chapter: chapter,
                mode: mode,
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byType(MathScene), findsOneWidget);
          expect(find.textContaining('इयत्ता 4'), findsOneWidget);
          expect(tester.takeException(), isNull, reason: '$width $mode');
        }
      }
    },
  );
}

Finder _selected(int index) => find.descendant(
  of: find.byKey(ValueKey('session-answer-$index')),
  matching: find.byIcon(Icons.check_circle_rounded),
);
Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void _viewport(WidgetTester tester, double width, double height) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _app(Widget home) => MaterialApp(
  theme: learningTheme(
    boardTheme(
      contrast: store.contrast,
      largeText: store.largeText,
      smartboard: store.smartboard,
    ),
  ),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(store.largeText ? 1.4 : 1)),
    child: child!,
  ),
  home: home,
);
