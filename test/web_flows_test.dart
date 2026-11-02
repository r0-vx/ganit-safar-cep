import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ganit_safar/main.dart';
import 'package:ganit_safar/content.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await store.init();
    store.language = 2;
    store.largeText = true;
    store.reducedMotion = true;
    store.contrast = true;
    store.grade = 1;
    store.custom = [];
    store.results = [];
    store.completed = [];
    store.stars = 0;
    central.session = null;
  });
  for (final width in [375.0, 768.0, 1024.0, 1440.0]) {
    testWidgets(
      'Web $width settings, records, teams and teacher tools fit large bilingual text',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        for (final page in <Widget>[
          SettingsPage(onExit: () {}),
          const ProgressPage(),
          const TeamPage(),
          TeacherPage(
            onLesson: (_) {},
            onQuiz: (_) {},
            onTeam: () {},
            onLock: () {},
          ),
          QuizPage(
            topic: topics[2],
            config: {
              'count': 5,
              'types': ['choice'],
              'random': false,
            },
          ),
          const ManagementPage(),
          CentralLogin(onContinue: () {}),
        ]) {
          await tester.pumpWidget(MaterialApp(home: Scaffold(body: page)));
          await tester.pump(const Duration(milliseconds: 300));
          expect(
            tester.takeException(),
            isNull,
            reason: '$width ${page.runtimeType}',
          );
        }
      },
    );
  }
  testWidgets('Counting shows objects even with hidden answer options', (
    tester,
  ) async {
    store.language = 0;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(store.largeText ? 1.15 : 1)),
          child: child!,
        ),
        home: Scaffold(
          body: QuestionActivity(
            q: makeQuestion('count', 1, 2, 'fill'),
            topic: 'count',
            onAnswer: (_) {},
          ),
        ),
      ),
    );
    expect(find.byType(VisualBoard), findsOneWidget);
    expect(find.text('🍎'), findsNWidgets(3));
  });
  testWidgets('Teacher-created quiz passes validation and completes', (
    tester,
  ) async {
    store.language = 0;
    store.largeText = false;
    store.contrast = false;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(store.largeText ? 1.15 : 1)),
          child: child!,
        ),
        home: QuizPage(
          topic: topics[2],
          config: {
            'questions': [
              {
                'en': '2 + 3 = ?',
                'mr': '२ + ३ = ?',
                'hintEn': 'Combine two and three.',
                'hintMr': 'दोन आणि तीन एकत्र करा.',
                'answer': 5,
              },
            ],
            'seconds': 0,
          },
        ),
      ),
    );
    await tester.tap(find.text('5'));
    await tester.pump();
    await tester.ensureVisible(find.text('See my discoveries'));
    await tester.tap(find.text('See my discoveries'));
    await tester.pump();
    expect(find.text('1 / 1'), findsOneWidget);
    expect(store.results, isEmpty);
    expect(find.text('Current Session Result'), findsOneWidget);
  });
  testWidgets(
    'Quiz bank exhaustion shows localized error without starting a timer',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(store.largeText ? 1.15 : 1),
            ),
            child: child!,
          ),
          home: QuizPage(
            topic: topics.firstWhere((t) => t.id == 'time'),
            config: {
              'count': 20,
              'types': ['clock'],
              'seconds': 30,
            },
          ),
        ),
      );
      expect(
        find.textContaining(
          'This selection does not have enough distinct questions.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Practice empty selection disables start', (tester) async {
    store.language = 0;
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: PracticeSessionPage())),
    );
    await tester.tap(find.widgetWithText(FilterChip, 'Addition'));
    await tester.pump();
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Start practice'),
    );
    expect(button.onPressed, isNull);
  });
}
