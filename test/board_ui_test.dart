import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ganit_safar/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('smartboard theme gives visible controls at least 64dp targets', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: boardTheme(contrast: false, largeText: false, smartboard: true),
        home: Scaffold(
          body: Wrap(
            children: [
              FilledButton(onPressed: () {}, child: const Text('Start')),
              OutlinedButton(onPressed: () {}, child: const Text('Back')),
              TextButton(onPressed: () {}, child: const Text('Help')),
              IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
            ],
          ),
        ),
      ),
    );

    for (final finder in [
      find.byType(FilledButton),
      find.byType(OutlinedButton),
      find.byType(TextButton),
      find.byType(IconButton),
    ]) {
      final size = tester.getSize(finder);
      expect(size.width, greaterThanOrEqualTo(64));
      expect(size.height, greaterThanOrEqualTo(64));
    }
  });

  testWidgets('smartboard button theme exposes a strong focused outline', (
    tester,
  ) async {
    late ButtonStyle style;
    await tester.pumpWidget(
      MaterialApp(
        theme: boardTheme(contrast: true, largeText: true, smartboard: true),
        home: Builder(
          builder: (context) {
            style = Theme.of(context).filledButtonTheme.style!;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final focusedOutline = style.side!.resolve({WidgetState.focused});
    expect(focusedOutline?.width, 3);
    expect(focusedOutline?.color, Colors.white);
  });

  testWidgets('board setting toggles and persists through the app store', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await store.init();
    store.language = 0;
    store.smartboard = false;

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BoardTouchSettings())),
    );
    await tester.tap(find.text('Smartboard / Android TV controls'));
    await tester.pumpAndSettle();

    expect(store.smartboard, isTrue);
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString('ganit_safar_v1');
    expect(encoded, contains('"smartboard":true'));
  });
}
