import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ganit_safar/chapter_catalogue.dart';
import 'package:ganit_safar/content.dart';
import 'package:ganit_safar/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await store.init();
    store.language = 1;
    store.sound = false;
    store.reducedMotion = true;
    store.smartboard = true;
    store.largeText = false;
    store.contrast = false;
    store.stars = 7;
    store.completedChapters = [];
    store.results = [];
    store.practiceDraft = {};
    await store.save();
  });

  for (final grade in [1, 2, 3]) {
    testWidgets(
      'Class $grade guided lesson retains its answer and stage through Marathi, bilingual and English',
      (tester) async {
        _viewport(tester, 1280, 1100);
        store.grade = grade;
        final chapter = _addition(grade);
        final question = chapter.questions().first;
        final wrong = (question.correctIndex + 1) % question.options.length;
        await tester.pumpWidget(_app(ChapterLessonPage(chapter: chapter)));
        await tester.pumpAndSettle();
        for (var stage = 0; stage < 3; stage++) {
          await _tap(tester, find.byKey(const ValueKey('lesson-next')));
        }
        expect(find.text('मदत घेऊन सोडव'), findsOneWidget);
        await _tap(
          tester,
          find.text(question.options[wrong].inLanguage(1)).last,
        );
        for (final selection in [
          ('English + मराठी', 2),
          ('English', 0),
          ('मराठी', 1),
        ]) {
          await _language(tester, selection.$1);
          expect(store.language, selection.$2);
          expect(
            find.text(
              classUiText(
                const Words('Guided Try', 'मदतीने सोडवूया'),
                grade: grade,
              ),
            ),
            findsOneWidget,
          );
          expect(
            find.text(question.options[wrong].inLanguage(selection.$2)),
            findsOneWidget,
          );
          expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
          expect(
            tester
                .widget<FilledButton>(find.byKey(const ValueKey('lesson-next')))
                .onPressed,
            isNull,
          );
        }
        expect(
          store.stars,
          7,
          reason:
              'Changing language cannot finish a lesson or award completion stars',
        );
        expect(tester.takeException(), isNull);
      },
      skip: portalSurface == 'dashboard',
    );

    testWidgets(
      'Class $grade chapter Practice Help retains the selected answer and active question',
      (tester) async {
        _viewport(tester, 1280, 1100);
        store.grade = grade;
        final chapter = _addition(grade);
        final question = chapter.questions().first;
        final wrong = (question.correctIndex + 1) % question.options.length;
        await tester.pumpWidget(
          _app(
            ChapterSessionPage(
              chapter: chapter,
              mode: ChapterSessionMode.practice,
            ),
          ),
        );
        await tester.pumpAndSettle();
        await _tap(tester, find.byKey(ValueKey('session-answer-$wrong')));
        await _tap(tester, find.text('मदत').last);
        expect(find.text(question.prompt.inLanguage(1)), findsOneWidget);
        expect(_selected(wrong), findsOneWidget);
        await _language(tester, 'English + मराठी');
        expect(
          find.text('Learning help\nसमजून घेण्यासाठी मदत'),
          findsOneWidget,
        );
        expect(find.text(question.prompt.inLanguage(2)), findsOneWidget);
        expect(_selected(wrong), findsOneWidget);
        await _tap(tester, find.byTooltip('Close help\nमदत बंद कर'));
        expect(find.text(question.prompt.inLanguage(2)), findsOneWidget);
        expect(_selected(wrong), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
      skip: portalSurface == 'dashboard',
    );

    testWidgets(
      'Class $grade typed Practice answer survives Help and language without duplicate rewards',
      (tester) async {
        _viewport(tester, 1440, 1300);
        store.grade = grade;
        store.practiceDraft = {
          'topics': ['add'],
          'types': ['fill'],
          'count': 5,
          'difficulty': 1,
        };
        await tester.pumpWidget(
          _app(
            ListenableBuilder(
              listenable: store,
              builder: (context, _) => Scaffold(body: PracticeSessionPage()),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await _tap(tester, find.text(tr('Start practice', 'सराव सुरू करा')));
        final activity = tester.widget<QuestionActivity>(
          find.byType(QuestionActivity),
        );
        final questionId = activity.q.id;
        final answer = '${activity.q.answer}';
        await tester.enterText(find.byType(TextField), answer);
        await _tap(tester, find.byTooltip(tr('Learning help', 'अभ्यास मदत')));
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          answer,
        );
        store.language = 2;
        await store.save();
        await tester.pumpAndSettle();
        expect(
          tester.widget<QuestionActivity>(find.byType(QuestionActivity)).q.id,
          questionId,
        );
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          answer,
        );
        await _tap(tester, find.byTooltip(tr('Close help', 'मदत बंद करा')));
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          answer,
        );
        await tester.tap(find.byType(TextField));
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        expect(store.stars, 8);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        expect(
          store.stars,
          8,
          reason: 'Repeated submission must not repeat the practice reward',
        );
        expect(tester.takeException(), isNull);
      },
      skip: portalSurface == 'dashboard',
    );

    testWidgets(
      'Class $grade quiz result retains scores across languages, reviews mistakes and resets only the session',
      (tester) async {
        _viewport(tester, 1280, 1100);
        store.grade = grade;
        final chapter = _addition(grade);
        final questions = chapter.questions();
        await store.save();
        final before = jsonEncode(store.progressData());
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
          await _tap(
            tester,
            find.text(tr('Submit answer', 'उत्तर निश्चित करा')),
          );
          await _tap(
            tester,
            find.text(
              i == questions.length - 1
                  ? tr('Finish quiz', 'प्रश्नमंजुषा पूर्ण करा')
                  : tr('Next question', 'पुढचा प्रश्न'),
            ),
          );
        }
        expect(find.text('या सत्राचा निकाल'), findsOneWidget);
        await _language(tester, 'English + मराठी');
        expect(
          find.text('Current Session Result\nया सत्राचा निकाल'),
          findsOneWidget,
        );
        expect(find.textContaining('Correct 4 • Incorrect 1'), findsOneWidget);
        await _tap(tester, find.text(tr('Review mistakes', 'चुका पाहा')));
        expect(find.textContaining('Your answer:'), findsOneWidget);
        expect(
          find.text(questions.first.prompt.inLanguage(2)),
          findsNothing,
          reason: 'Review prefixes the prompt with its question number',
        );
        expect(find.textContaining(questions.first.prompt.en), findsOneWidget);
        expect(jsonEncode(store.progressData()), before);
        final prefs = await SharedPreferences.getInstance();
        final persisted = jsonDecode(prefs.getString('ganit_safar_v1')!) as Map;
        final expected = jsonDecode(before) as Map;
        for (final key in expected.keys) {
          expect(
            persisted['progress'][key],
            expected[key],
            reason: 'Session result must not alter persistent $key',
          );
        }
        await _tap(tester, find.text(tr('Try again', 'पुन्हा प्रयत्न करा')));
        expect(find.textContaining('Current Session Result'), findsNothing);
        expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
        expect(find.text(tr('Skip question', 'प्रश्न सोडा')), findsOneWidget);
        expect(jsonEncode(store.progressData()), before);
        expect(tester.takeException(), isNull);
      },
      skip: portalSurface == 'dashboard',
    );

    testWidgets(
      'Class $grade Marathi and bilingual large text fits phone, board and desktop widths',
      (tester) async {
        store.grade = grade;
        store.largeText = true;
        store.contrast = true;
        for (final language in [1, 2]) {
          store.language = language;
          for (final width in [375.0, 1024.0, 1920.0]) {
            _viewport(tester, width, 1100);
            for (final page in <Widget>[
              ChapterLessonPage(chapter: chaptersForGrade(grade).first),
              ChapterSessionPage(
                chapter: _addition(grade),
                mode: ChapterSessionMode.practice,
              ),
              ChapterSessionPage(
                chapter: chaptersForGrade(grade).last,
                mode: ChapterSessionMode.quiz,
              ),
            ]) {
              await tester.pumpWidget(
                _app(KeyedSubtree(key: UniqueKey(), child: page)),
              );
              await tester.pumpAndSettle();
              expect(
                tester.takeException(),
                isNull,
                reason: '$grade $language $width ${page.runtimeType}',
              );
            }
          }
        }
      },
      skip: portalSurface == 'dashboard',
    );
  }
}

SchoolChapter _addition(int grade) => chaptersForGrade(
  grade,
).firstWhere((c) => c.title.en.startsWith('Addition') && c.id != 'G1-C10');

Finder _selected(int index) => find.descendant(
  of: find.byKey(ValueKey('session-answer-$index')),
  matching: find.byIcon(Icons.check_circle_rounded),
);

void _viewport(WidgetTester tester, double width, double height) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _app(Widget home) => MaterialApp(
  theme: boardTheme(
    contrast: store.contrast,
    largeText: store.largeText,
    smartboard: store.smartboard,
  ),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(store.largeText ? 1.4 : 1)),
    child: child!,
  ),
  home: home,
);

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _language(WidgetTester tester, String label) async {
  await _tap(tester, find.byType(DropdownButton<int>));
  await _tap(tester, find.text(label).last);
}
