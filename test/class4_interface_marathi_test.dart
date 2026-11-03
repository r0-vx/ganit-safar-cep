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
    store.grade = 4;
    store.language = 1;
    store.sound = false;
    store.reducedMotion = true;
    store.smartboard = true;
    store.largeText = false;
    store.contrast = false;
    store.stars = 0;
    store.completedChapters = [];
    store.results = [];
    await store.save();
  });

  test(
    'Class 4 interface uses plain classroom wording and exact bounded templates',
    () {
      expect(
        class4UiMarathi('Independent Challenge', 'स्वतः सोडवूया'),
        'स्वतः सोडवून पाहा',
      );
      expect(
        class4UiMarathi('Try again', 'पुन्हा प्रयत्न करा'),
        'पुन्हा प्रयत्न कर',
      );
      expect(
        class4UiMarathi('Submit answer', 'उत्तर निश्चित करा'),
        'उत्तर नोंदव',
      );
      expect(
        class4UiMarathi('Short hand: hours. Long hand: minutes.', 'जुना मजकूर'),
        'लहान काटा तास दाखवतो. मोठा काटा मिनिटे दाखवतो.',
      );
      expect(
        class4UiMarathi(
          'Counted 1 objects. Tap each object once.',
          'जुना मजकूर',
        ),
        'मोजलेल्या वस्तू: १. प्रत्येक वस्तूला एकदाच स्पर्श कर.',
      );
      expect(
        class4UiMarathi('Colour 3 of 8 equal parts.', 'जुना मजकूर'),
        'दिलेल्या ८ समान भागांपैकी ३ भाग रंगव.',
      );
      expect(
        class4UiMarathi('7 in each group; 2 left over.', 'जुना मजकूर'),
        'प्रत्येक गटात ७ वस्तू आल्या. २ वस्तू बाकी राहिल्या.',
      );
      expect(
        class4UiMarathi('Make ₹125 using these coins.', 'जुना मजकूर'),
        'या नाण्यांचा वापर करून ₹१२५ एवढी रक्कम बनव.',
      );
      expect(
        class4UiMarathi('Key: one sun stands for 4 kites.', 'जुना मजकूर'),
        'चित्रालेखाची खूण: सूर्याचे एक चित्र म्हणजे ४ पतंग.',
      );
      expect(
        class4UiMarathi('Time used: 75s', 'जुना मजकूर'),
        'लागलेला वेळ: ७५ सेकंद',
      );
      expect(
        class4UiMarathi('Question 4 of 10', 'जुना मजकूर'),
        'प्रश्न ४ / १०',
      );
      expect(
        class4UiMarathi(
          'A teacher story: Make ₹125 using these coins.',
          'माझा प्रश्न जसाच्या तसा',
        ),
        'माझा प्रश्न जसाच्या तसा',
      );
      expect(
        class4UiMarathi('Unknown authored question', 'माझा स्वतंत्र प्रश्न'),
        'माझा स्वतंत्र प्रश्न',
      );
    },
  );

  test(
    'Known answer-label prefixes preserve the already-localized answer contents',
    () {
      const answer = '३/४ लिटर — शिक्षकांनी दिलेले उत्तर';
      expect(
        class4UiMarathi('Your answer: custom answer', 'तुमचे उत्तर: $answer'),
        'तुझे उत्तर: $answer',
      );
      expect(
        class4UiMarathi('Your answer: custom answer', 'विशेष नोंद: $answer'),
        'विशेष नोंद: $answer',
      );
      expect(
        class4UiMarathi('Revision topic: Time', 'पुनरावृत्ती: वेळ'),
        'पुन्हा सराव करायचा विषय: वेळ',
      );
    },
  );

  test(
    'Only Class 4 learner interface changes; English, other classes and authored Words stay intact',
    () {
      for (var grade = 1; grade <= 3; grade++) {
        store.grade = grade;
        store.language = 1;
        expect(tr('Try again', 'पुन्हा प्रयत्न करा'), 'पुन्हा प्रयत्न करा');
        store.language = 2;
        expect(
          tr('Try again', 'पुन्हा प्रयत्न करा'),
          'Try again\nपुन्हा प्रयत्न करा',
        );
      }
      store.grade = 4;
      store.language = 0;
      expect(tr('Try again', 'पुन्हा प्रयत्न करा'), 'Try again');
      store.language = 1;
      expect(
        tr('Try again', 'पुन्हा प्रयत्न करा'),
        portalSurface == 'dashboard'
            ? 'पुन्हा प्रयत्न करा'
            : 'पुन्हा प्रयत्न कर',
      );
      store.language = 2;
      expect(
        tr('Try again', 'पुन्हा प्रयत्न करा'),
        portalSurface == 'dashboard'
            ? 'Try again\nपुन्हा प्रयत्न करा'
            : 'Try again\nपुन्हा प्रयत्न कर',
      );
      const teacherText = Words('Try again', 'शिक्षकांनी स्वतः लिहिलेला मजकूर');
      expect(teacherText.inLanguage(1), 'शिक्षकांनी स्वतः लिहिलेला मजकूर');
      expect(
        teacherText.inLanguage(2),
        'Try again\nशिक्षकांनी स्वतः लिहिलेला मजकूर',
      );
      expect(
        classUiText(const Words('Try again', 'पुन्हा प्रयत्न करा'), grade: 3),
        'Try again\nपुन्हा प्रयत्न करा',
      );
    },
  );

  testWidgets('Account accessibility label follows live language changes', (
    tester,
  ) async {
    store.language = 0;
    await tester.pumpWidget(_app(const AccountMenuButton()));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Account'), findsOneWidget);
    store.language = 1;
    await store.save();
    await tester.pumpAndSettle();
    expect(find.byTooltip('खाते'), findsOneWidget);
    store.language = 2;
    await store.save();
    await tester.pumpAndSettle();
    expect(find.byTooltip('Account\nखाते'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Class 4 lesson keeps its guided answer and stage when changing Marathi modes',
    (tester) async {
      _viewport(tester, 1280, 1100);
      final chapter = chaptersForGrade(4)[2];
      final question = chapter.questions().first;
      await tester.pumpWidget(_app(ChapterLessonPage(chapter: chapter)));
      await tester.pumpAndSettle();
      for (var stage = 0; stage < 3; stage++) {
        await _tap(tester, find.byKey(const ValueKey('lesson-next')));
      }
      expect(find.text('मदत घेऊन सोडव'), findsOneWidget);
      final wrong = (question.correctIndex + 1) % question.options.length;
      await _tap(tester, find.text(question.options[wrong].inLanguage(1)).last);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const ValueKey('lesson-next')))
            .onPressed,
        isNull,
      );
      await _language(tester, 'English + मराठी');
      expect(store.language, 2);
      expect(find.text('Guided Try\nमदत घेऊन सोडव'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const ValueKey('lesson-next')))
            .onPressed,
        isNull,
      );
      expect(find.text(question.options[wrong].inLanguage(2)), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
    skip: portalSurface == 'dashboard',
  );

  testWidgets(
    'Class 4 practice Help keeps the selected answer in Marathi and bilingual modes',
    (tester) async {
      _viewport(tester, 1280, 1100);
      final chapter = chaptersForGrade(4)[3];
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
      expect(find.text('समजून घेण्यासाठी मदत'), findsOneWidget);
      expect(_selected(wrong), findsOneWidget);
      await _language(tester, 'English + मराठी');
      expect(find.text('Learning help\nसमजून घेण्यासाठी मदत'), findsOneWidget);
      expect(_selected(wrong), findsOneWidget);
      await _tap(tester, find.byTooltip('Close help\nमदत बंद कर'));
      expect(_selected(wrong), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
    skip: portalSurface == 'dashboard',
  );

  testWidgets(
    'Class 4 Marathi and bilingual lesson, Practice and Quiz fit narrow large-text screens',
    (tester) async {
      store.largeText = true;
      store.contrast = true;
      for (final language in [1, 2]) {
        store.language = language;
        for (final width in [375.0, 1024.0, 1920.0]) {
          _viewport(tester, width, 1100);
          for (final page in <Widget>[
            ChapterLessonPage(chapter: chaptersForGrade(4).first),
            ChapterSessionPage(
              chapter: chaptersForGrade(4)[3],
              mode: ChapterSessionMode.practice,
            ),
            ChapterSessionPage(
              chapter: chaptersForGrade(4)[12],
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
              reason: '$language, $width, ${page.runtimeType}',
            );
          }
        }
      }
    },
    skip: portalSurface == 'dashboard',
  );
}

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
