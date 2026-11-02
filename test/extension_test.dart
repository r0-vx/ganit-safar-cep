import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ganit_safar/main.dart';
import 'package:ganit_safar/content.dart';
import 'package:ganit_safar/curriculum.dart';
import 'package:ganit_safar/generator.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await store.init();
    store.language = 0;
    store.largeText = false;
    store.contrast = false;
    store.reducedMotion = true;
    store.sidebarOpen = true;
    store.practiceDraft = {};
    store.grade = 1;
    store.completed = [];
    store.results = [];
    store.stars = 0;
  });
  test(
    'All curriculum rows have bilingual definitions, prerequisites and source status',
    () {
      expect(curriculum.length, 56);
      for (final o in curriculum) {
        expect(o.source, startsWith('https://books.ebalbharati.in/'));
        expect(o.review.toLowerCase(), contains('review'));
        expect(o.objective.mr, isNotEmpty);
        expect(o.hint.en, isNotEmpty);
        expect(o.commonMistake.mr, isNotEmpty);
      }
    },
  );
  test(
    'All class/topic/type templates validate across 30 numerical variants',
    () {
      for (var grade = 1; grade <= 4; grade++) {
        for (final t in topics) {
          for (final type in questionTypes.where(
            (x) => supportsType(t.id, x),
          )) {
            for (var i = 0; i < 30; i++) {
              final q = makeQuestion(t.id, grade, i, type);
              final v = validateQuestion(q);
              // Oversized object-count templates are rejected before serving, while other types stay valid.
              if (type != 'count')
                expect(
                  v.valid,
                  isTrue,
                  reason: '$grade ${t.id} $type $i ${v.errors}',
                );
              expect(q.metadata!.outcomeId, outcomeFor(grade, t.id).id);
            }
          }
        }
      }
    },
  );
  test(
    'Generated sessions have unique questions and repeatable fixed order',
    () {
      for (var g = 1; g <= 4; g++) {
        final q = generateQuestions(
          topicIds: ['add', 'subtract', 'money', 'time'],
          grade: g,
          count: 30,
          types: ['choice', 'fill', 'story', 'clock', 'coins'],
        );
        expect(q.map(questionFingerprint).toSet().length, 30);
        expect(q.every((x) => validateQuestion(x).valid), isTrue);
        final again = generateQuestions(
          topicIds: ['add', 'subtract', 'money', 'time'],
          grade: g,
          count: 30,
          types: ['choice', 'fill', 'story', 'clock', 'coins'],
        );
        expect(q.map(questionFingerprint), again.map(questionFingerprint));
      }
      final noOptions = generateQuestions(
        topicIds: ['add'],
        grade: 1,
        count: 5,
        types: ['choice'],
        showOptions: false,
      );
      expect(noOptions.every((q) => q.type == 'fill'), isTrue);
      expect(
        () => generateQuestions(
          topicIds: ['time'],
          grade: 1,
          count: 20,
          types: ['clock'],
        ),
        throwsStateError,
      );
    },
  );
  test(
    'Old v1 backups preserve progress while defaulting new preferences',
    () async {
      store.complete('add');
      await store.save();
      final old = store.encode()
        ..remove('extensionSchemaVersion')
        ..remove('sidebarOpen')
        ..remove('reducedMotion')
        ..remove('practiceDraft');
      store.decode(old);
      expect(store.completed, contains('1:add'));
      expect(store.stars, 3);
      expect(store.sidebarOpen, isTrue);
      expect(store.reducedMotion, isFalse);
      store.sidebarOpen = false;
      store.reducedMotion = true;
      await store.save();
      final restored = await Future.sync(() => store.encode());
      store.decode(restored);
      expect(store.sidebarOpen, isFalse);
      expect(store.reducedMotion, isTrue);
    },
  );
  for (final width in [375.0, 768.0, 1024.0, 1440.0]) {
    testWidgets(
      'Web layout $width supports bilingual larger text across setup and help',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        store.language = 2;
        store.largeText = true;
        store.contrast = true;
        for (final page in <Widget>[
          const Shell(),
          TopicsPage(mode: 'learn', onOpen: (_) {}),
          const PracticeSessionPage(),
          QuizSetup(topic: topics[2], onStart: (_) {}),
          StoryLessonPage(topic: topics[2], onDone: () {}, onQuiz: () {}),
          HelpCard(q: makeQuestion('add', 1, 0, 'choice'), topic: 'add'),
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
  testWidgets(
    'Practice help preserves typed answer, supports retry and saves stars',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1300);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      store.practiceDraft = {
        'topics': ['add'],
        'types': ['fill'],
        'count': 5,
        'difficulty': 1,
      };
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PracticeSessionPage())),
      );
      await tester.ensureVisible(find.text('Start practice'));
      await tester.tap(find.text('Start practice'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), '5');
      await tester.ensureVisible(find.byTooltip('Learning help'));
      await tester.tap(find.byTooltip('Learning help'));
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '5',
      );
      await tester.ensureVisible(find.byTooltip('Close help'));
      await tester.tap(find.byTooltip('Close help'));
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '5',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(store.stars, 1);
      expect(find.text('⭐ Wonderful work, explorer!'), findsOneWidget);
      // Re-submitting a solved input must not award the same practice star twice.
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(store.stars, 1);
    },
  );
  testWidgets('Sidebar opens as mobile overlay and closes with keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: Shell()));
    await tester.tap(find.byTooltip('Toggle sidebar (Ctrl+B)'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Settings'), findsOneWidget);
    expect(find.byTooltip('Close sidebar'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester.state<ScaffoldState>(find.byType(Scaffold)).isDrawerOpen,
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });
  for (final type in [
    'numberline',
    'model',
    'clock',
    'coins',
    'colour',
    'graph',
    'construct',
  ]) {
    testWidgets('$type interaction validates a meaningful student action', (
      tester,
    ) async {
      final topic = switch (type) {
        'clock' => 'time',
        'coins' => 'money',
        'colour' => 'fraction',
        'graph' => 'data',
        'construct' => 'shape',
        _ => 'add',
      };
      final q = makeQuestion(topic, 1, 0, type);
      int? answer;
      tester.view.physicalSize = const Size(1000, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(store.largeText ? 1.15 : 1),
            ),
            child: child!,
          ),
          home: Scaffold(
            body: RichInteraction(
              q: q,
              topic: topic,
              onAnswer: (n) => answer = n,
            ),
          ),
        ),
      );
      switch (type) {
        case 'numberline':
          await tester.tap(find.text('${q.answer}'));
          break;
        case 'model':
          await tester.tap(find.text(List.filled(q.answer, '●').join(' ')));
          break;
        case 'clock':
          await tester.tap(find.text('${q.a}'));
          await tester.tap(find.text('Check clock'));
          break;
        case 'coins':
          for (var i = 0; i < q.answer; i++) {
            await tester.tap(find.text('₹1'));
            await tester.pump();
          }
          await tester.tap(find.text('Check price'));
          break;
        case 'colour':
          for (var i = 0; i < q.a; i++) {
            await tester.tap(find.byType(OutlinedButton).at(i));
            await tester.pump();
          }
          await tester.tap(find.text('Check fraction'));
          break;
        case 'graph':
          await tester.tap(find.byType(OutlinedButton).first);
          break;
        case 'construct':
          for (var i = 0; i < q.answer; i++) {
            await tester.tap(find.text('Add side'));
            await tester.pump();
          }
          await tester.tap(find.text('Check shape'));
          break;
      }
      await tester.pump();
      expect(answer, q.answer);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'Central sign-in is explicit, localized and offers offline fallback',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: CentralLogin(onContinue: () {})),
      );
      expect(
        find.text('LOCAL DEVELOPMENT • No hosted central system'),
        findsOneWidget,
      );
      store.language = 1;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(store.largeText ? 1.15 : 1),
            ),
            child: child!,
          ),
          home: CentralLogin(key: UniqueKey(), onContinue: () {}),
        ),
      );
      expect(find.text('गणित अॅपमध्ये प्रवेश'), findsOneWidget);
    },
  );
}
