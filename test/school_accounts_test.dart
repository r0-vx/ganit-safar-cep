import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ganit_safar/central_client.dart';
import 'package:ganit_safar/main.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'central_client_test.dart' show authResponse, fixture, jsonResponse;

void main() {
  testWidgets(
    'School login adds its classroom and connects a board without teacher accounts',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({
        'ganit_installation_id': 'test-board-identity-123456',
      });
      await store.init();
      store.language = 0;
      final rooms = <Map<String, dynamic>>[];
      final schools = [
        {'id': 'school-solo', 'name': 'School One', 'status': 'active'},
      ];
      final writes = <Map<String, dynamic>>[];
      final client = CentralClient(
        endpoint: 'http://localhost:8789',
        surface: 'classroom',
        clock: () => DateTime.fromMillisecondsSinceEpoch(
          ((fixture['serverTime'] as num) * 1000).round(),
        ),
        transport: MockClient((r) async {
          if (r.url.path == '/auth/refresh')
            return jsonResponse({
              ...authResponse('school_admin'),
              'device': null,
              'classrooms': rooms,
              'schools': schools,
            });
          if (r.url.path == '/me/classrooms')
            return jsonResponse({'classrooms': rooms, 'schools': schools});
          if (r.method == 'POST') {
            final body = jsonDecode(r.body) as Map<String, dynamic>;
            writes.add({'path': r.url.path, ...body});
            if (r.url.path == '/classrooms') {
              rooms.add({
                'id': 'classroom-test-id',
                'school_name': 'School One',
                ...body,
              });
              return jsonResponse({'id': 'classroom-test-id'}, 201);
            }
            if (r.url.path == '/devices/register')
              return jsonResponse({
                ...authResponse('school_admin'),
                'offlineLease': fixture['offlineLease'],
                'schools': schools,
              });
          }
          return jsonResponse({'ok': true});
        }),
      );
      await client.init();
      expect(client.canLearn, false);
      await tester.pumpWidget(
        MaterialApp(home: ClassroomEnrollmentPage(client: client)),
      );
      await tester.tap(find.text('Add classroom'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'Class 1 A');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(writes.single['school_id'], 'school-solo');
      expect(writes.single['grade'], 1);
      expect(find.text('School One • Class 1 A'), findsOneWidget);
      await tester.tap(find.text('Register and open learning'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      final registered = writes.firstWhere(
        (r) => r['path'] == '/devices/register',
      );
      expect(registered['classroom_id'], 'classroom-test-id');
      expect(registered['name'], 'Class 1 A');
      expect(client.canLearn, true);
      expect(writes.any((r) => r['path'] == '/users'), false);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      client.dispose();
      await tester.pump();
    },
  );

  testWidgets(
    'Generated school credentials have bilingual instructions and explicit acknowledgement',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await store.init();
      store.language = 2;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showSchoolLogin(context, {
                  'schoolName': 'School One',
                  'username': 'school-test',
                  'password': 'test-only-generated-password',
                }),
                child: const Text('Create'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
      expect(
        find.text('School login is ready\nशाळेचा प्रवेश तयार आहे'),
        findsOneWidget,
      );
      expect(find.text('school-test'), findsOneWidget);
      expect(find.text('test-only-generated-password'), findsOneWidget);
      expect(
        find.textContaining('No separate teacher accounts'),
        findsOneWidget,
      );
      await tester.tap(find.text('I have saved it\nमी जतन केले आहे'));
      await tester.pumpAndSettle();
      expect(find.text('test-only-generated-password'), findsNothing);
      expect(tester.takeException(), isNull);
      store.language = 0;
    },
  );
}
