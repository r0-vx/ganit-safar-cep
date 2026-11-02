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
    store.language = 0;
    store.grade = 1;
    store.sound = false;
    store.reducedMotion = true;
    store.slow = false;
    store.smartboard = true;
    store.largeText = false;
    store.contrast = false;
    store.completedChapters = [];
    store.completed = [];
    store.results = [];
    store.stars = 0;
  });

  test(
    'Every generated numerical scene is consistent with the original answer',
    () {
      var numerical = 0;
      for (final chapter in schoolChapters) {
        for (final question in chapter.questions(count: 10)) {
          final scene = MathSceneModel.fromQuestion(question);
          final answer = int.tryParse(
            question.options[question.correctIndex].en,
          );
          switch (scene.kind) {
            case 'addition':
              expect(scene.first + scene.second, answer);
              numerical++;
            case 'subtraction':
              expect(scene.first - scene.second, answer);
              numerical++;
            case 'equalGroups':
              expect(scene.first * scene.second, answer);
              numerical++;
            case 'sharing':
              expect(
                scene.second * scene.result + scene.remainder,
                scene.first,
              );
              expect(scene.remainder, lessThan(scene.second));
              expect([scene.result, scene.remainder], contains(answer));
              numerical++;
            case 'coins':
              expect(scene.first * scene.second + scene.remainder, answer);
              numerical++;
            case 'fraction':
              expect(
                '${scene.first}/${scene.second}',
                question.options[question.correctIndex].en,
              );
              expect(scene.second, greaterThan(0));
              numerical++;
            case 'numberLine':
              expect(scene.first + scene.second * 3, answer);
              numerical++;
            case 'barChart':
              expect(scene.first * scene.second, answer);
              numerical++;
            case 'clock' || 'elapsedClock':
              expect(scene.first, inInclusiveRange(1, 12));
              expect(scene.second, inInclusiveRange(0, 59));
              numerical++;
            case 'count' || 'baseTen':
              expect(scene.first, answer);
              numerical++;
          }
        }
      }
      expect(numerical, greaterThan(200));
    },
  );

  testWidgets(
    'All 79 chapter scenes render in bilingual large-text narrow layout without fabricated fallback answers',
    (tester) async {
      tester.view.physicalSize = const Size(375, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      store.language = 2;
      store.largeText = true;
      for (final chapter in schoolChapters) {
        final question = chapter.questions(count: 1).first;
        await tester.pumpWidget(
          _app(
            SingleChildScrollView(
              child: MathScene(key: ValueKey(chapter.id), question: question),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: chapter.id);
        expect(
          find.text(question.explanation.inLanguage(store.language)),
          findsNothing,
          reason:
              'Assessment model must not print the answer explanation: ${chapter.id}',
        );
      }
    },
  );

  testWidgets(
    'Interactive counters meet touch size and count each object only once across language changes',
    (tester) async {
      final chapter = schoolChapters.firstWhere((c) => c.id == 'G1-C10');
      final question = chapter.questions(count: 2)[1]; // 2 + 4 mangoes.
      var touched = 0;
      final key = GlobalKey();
      Widget body() => MathScene(
        key: key,
        question: question,
        interactive: true,
        replayKey: 'stable',
        onCountChanged: (value) => touched = value,
      );
      await tester.pumpWidget(_app(body()));
      await tester.pumpAndSettle();
      final first = find.byKey(const ValueKey('scene-object-0'));
      expect(tester.getSize(first).width, greaterThanOrEqualTo(64));
      expect(tester.getSize(first).height, greaterThanOrEqualTo(64));
      await tester.tap(first);
      await tester.pumpAndSettle();
      await tester.tap(first);
      await tester.pumpAndSettle();
      expect(touched, 1);
      store.language = 1;
      await tester.pumpWidget(_app(body()));
      await tester.pumpAndSettle();
      expect(touched, 1);
      expect(find.textContaining('१ वस्तू मोजल्या'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Six-stage mango lesson requires guided and independent answers, replays and completes only once',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final chapter = schoolChapters.firstWhere((c) => c.id == 'G1-C10');
      await tester.pumpWidget(_app(ChapterLessonPage(chapter: chapter)));
      await tester.pumpAndSettle();
      expect(find.text('Story & Predict'), findsOneWidget);
      expect(find.textContaining('Mira has 3 mangoes'), findsOneWidget);
      Future<void> next() async {
        await tester.tap(find.byKey(const ValueKey('lesson-next')));
        await tester.pumpAndSettle();
      }

      await next();
      expect(find.text('Explore'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('scene-object-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Replay this step'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Counted 0 objects'), findsOneWidget);
      await next();
      expect(find.text('See the Maths'), findsOneWidget);
      await next();
      expect(find.text('Guided Try'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const ValueKey('lesson-next')))
            .onPressed,
        isNull,
      );
      await tester.ensureVisible(find.text('5').last);
      await tester.tap(find.text('5').last);
      await tester.pumpAndSettle();
      await next();
      expect(find.text('Independent Challenge'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const ValueKey('lesson-next')))
            .onPressed,
        isNull,
      );
      await tester.ensureVisible(find.text('6').last);
      await tester.tap(find.text('6').last);
      await tester.pumpAndSettle();
      await next();
      expect(find.text('Recap & Celebrate'), findsOneWidget);
      expect(store.completedChapters, contains(chapter.id));
      expect(store.stars, 3);
      await tester.tap(find.text('Back').last);
      await tester.pumpAndSettle();
      await next();
      expect(store.stars, 3);
      expect(tester.takeException(), isNull);
    },
  );

  for (final chapterId in ['G2-C08', 'G3-C04', 'G4-C01']) {
    for (final language in [0, 1, 2]) {
      testWidgets(
        '$chapterId completes six stages in language $language with hint, replay and completion state preserved',
        (tester) async {
          tester.view.physicalSize = const Size(1280, 1000);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          store.language = language;
          final chapter = schoolChapters.firstWhere((c) => c.id == chapterId);
          final questions = chapter.questions(count: 2);
          await tester.pumpWidget(_app(ChapterLessonPage(chapter: chapter)));
          await tester.pumpAndSettle();
          Future<void> next() async {
            await tester.tap(find.byKey(const ValueKey('lesson-next')));
            await tester.pumpAndSettle();
          }

          Future<void> choose(ChapterQuestion question) async {
            final option = find
                .text(
                  question.options[question.correctIndex].inLanguage(
                    store.language,
                  ),
                )
                .last;
            await tester.ensureVisible(option);
            await tester.tap(option);
            await tester.pumpAndSettle();
          }

          await next();
          await next();
          await next(); // Guided stage, no inferred answer.
          expect(
            tester
                .widget<FilledButton>(find.byKey(const ValueKey('lesson-next')))
                .onPressed,
            isNull,
          );
          await choose(questions.first);
          await tester.tap(find.byIcon(Icons.lightbulb_outline_rounded).last);
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<FilledButton>(find.byKey(const ValueKey('lesson-next')))
                .onPressed,
            isNotNull,
          );
          store.language = (language + 1) % 3;
          await store.save();
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<FilledButton>(find.byKey(const ValueKey('lesson-next')))
                .onPressed,
            isNotNull,
          );
          store.language = language;
          await store.save();
          await tester.pumpAndSettle();
          final replay = find.text(
            const Words(
              'Replay this step',
              'हा टप्पा पुन्हा पाहा',
            ).inLanguage(language),
          );
          await tester.tap(replay);
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<FilledButton>(find.byKey(const ValueKey('lesson-next')))
                .onPressed,
            isNull,
          );
          await choose(questions.first);
          await next();
          expect(
            tester
                .widget<FilledButton>(find.byKey(const ValueKey('lesson-next')))
                .onPressed,
            isNull,
          );
          await choose(questions[1]);
          await next();
          expect(store.isChapterDone(chapterId), true);
          expect(store.stars, 3);
          final back = find
              .text(const Words('Back', 'मागे').inLanguage(language))
              .last;
          await tester.tap(back);
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<FilledButton>(find.byKey(const ValueKey('lesson-next')))
                .onPressed,
            isNotNull,
          );
          await next();
          expect(store.stars, 3);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

Widget _app(Widget child) => MaterialApp(
  theme: ganitAppTheme(),
  home: Scaffold(body: child),
);
