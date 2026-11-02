import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ganit_safar/central_client.dart';
import 'package:ganit_safar/main.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'central_client_test.dart'
    show FakeEventClient, authResponse, fixture, jsonResponse;
import 'management_widget_test.dart' show snapshot;

void main() {
  testWidgets(
    'Create school, validate fields, then add and monitor its classroom without dialog disposal errors',
    (tester) async {
      tester.view.physicalSize = const Size(1920, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      await store.init();
      store.language = 0;
      final schools = <Map<String, dynamic>>[],
          rooms = <Map<String, dynamic>>[],
          writes = <Map<String, dynamic>>[];
      final events = FakeEventClient();
      final client = CentralClient(
        endpoint: 'http://localhost:8789',
        surface: 'dashboard',
        clock: () => DateTime.fromMillisecondsSinceEpoch(
          ((fixture['serverTime'] as num) * 1000).round(),
        ),
        streamFactory: () => events,
        transport: MockClient((r) async {
          if (r.url.path == '/auth/refresh')
            return jsonResponse(authResponse('super_admin'));
          if (r.method == 'GET')
            return jsonResponse({
              ...snapshot(0),
              'schools': schools,
              'classrooms': rooms,
            });
          final body = jsonDecode(r.body) as Map<String, dynamic>;
          writes.add({'path': r.url.path, ...body});
          if (r.url.path == '/schools')
            schools.add({
              'id': 'new-school',
              ...body,
              'code': 'SCH-NEW',
              'admin_contact': '',
              'status': 'active',
              'created_at': 1793577600,
            });
          if (r.url.path == '/classrooms')
            rooms.add({
              'id': 'new-room',
              ...body,
              'school_name': 'Workflow school',
              'status': 'active',
              'online': false,
              'teacher_ids': [],
              'current_activities': [],
              'created_at': 1793577600,
            });
          return jsonResponse({
            'id': r.url.path == '/schools' ? 'new-school' : 'new-room',
          }, 201);
        }),
      );
      await client.init();
      await tester.pumpWidget(
        MaterialApp(home: ManagementPage(client: client)),
      );
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('Schools').first);
      await tester.pump();
      await tester.tap(find.text('Add school'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(find.text('This field is required.'), findsOneWidget);
      expect(writes, isEmpty);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'School name'),
        'Workflow school',
      );
      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(writes.single['name'], 'Workflow school');
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Add classroom'));
      await tester.tap(find.text('Add classroom'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Classroom details'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Classroom name'),
        'Class 1 A',
      );
      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(writes.last['school_id'], 'new-school');
      expect(writes.last['grade'], 1);
      expect(find.text('Classrooms in this school'), findsOneWidget);
      expect(find.text('Class 1 A'), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      client.dispose();
      await tester.pump();
    },
  );
  testWidgets(
    'Account avatar shows details and signs out the authenticated user',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await store.init();
      store.language = 0;
      final client = CentralClient(
        endpoint: 'http://localhost:8789',
        surface: 'classroom',
        clock: () => DateTime.fromMillisecondsSinceEpoch(
          ((fixture['serverTime'] as num) * 1000).round(),
        ),
        transport: MockClient(
          (r) async => jsonResponse(
            r.url.path == '/auth/refresh'
                ? {...authResponse('super_admin'), 'device': null}
                : {'ok': true},
          ),
        ),
      );
      await client.init();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AccountMenuButton(client: client)),
        ),
      );
      await tester.tap(find.byTooltip('Account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Account details'));
      await tester.pumpAndSettle();
      expect(find.text('Super administrator'), findsOneWidget);
      expect(find.textContaining('No classroom linked'), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(client.session, isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      client.dispose();
      await tester.pump();
    },
  );
  testWidgets(
    'Classroom toolbar keeps account and controls aligned to the right',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      await store.init();
      store.language = 0;
      final focus = FocusNode();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topCenter,
              child: ClassroomTopBar(
                showBack: false,
                sidebarOpen: true,
                full: false,
                menuFocus: focus,
                onMenu: () {},
                onBack: () {},
                onFullscreen: () {},
              ),
            ),
          ),
        ),
      );
      expect(tester.getCenter(find.byTooltip('Account')).dx, greaterThan(1150));
      expect(
        tester.getCenter(find.byTooltip('Toggle sound')).dx,
        greaterThan(900),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      focus.dispose();
    },
  );
}
