import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ganit_safar/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'Locked managed login has a text-selection overlay and blocks learning routes',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await store.init();
      store.language = 0;
      central.initialized = true;
      central.locked = true;
      await tester.pumpWidget(const GanitApp());
      await tester.pump();
      final fields = find.byType(EditableText);
      final email = fields.at(fields.evaluate().length - 2);
      await tester.enterText(email, 'local-teacher@example.invalid');
      final state = tester.state<EditableTextState>(email);
      state.showToolbar();
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Big adventures.\nLittle numbers.'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
    skip: !central.managed,
  );
}
