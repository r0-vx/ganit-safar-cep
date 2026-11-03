import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ganit_safar/central_client.dart';
import 'package:ganit_safar/main.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'central_client_test.dart' show authResponse, fixture, jsonResponse;

void main() {
  for (final dashboard in [false, true]) {
    for (final width in [375.0, 1280.0]) {
      testWidgets(
        '${dashboard ? 'Dashboard' : 'Classroom'} has a distinct bilingual sign-in at $width',
        (tester) async {
          tester.view.physicalSize = Size(width, 1000);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          SharedPreferences.setMockInitialValues({});
          await store.init();
          store.language = 2;
          final email = TextEditingController(text: 'mock-user'),
              password = TextEditingController(text: 'mock-user');
          await tester.pumpWidget(
            MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(
                  size: Size(width, 1000),
                  textScaler: const TextScaler.linear(1.4),
                ),
                child: PortalSignInView(
                  dashboard: dashboard,
                  email: email,
                  password: password,
                  busy: false,
                  error: '',
                  onSignIn: () {},
                  onContinueOffline: () {},
                ),
              ),
            ),
          );
          expect(
            find.text(
              dashboard
                  ? 'Monitoring dashboard sign in\nनिरीक्षण फलकावर प्रवेश'
                  : 'Classroom app sign in\nगणित अॅपमध्ये प्रवेश',
            ),
            findsOneWidget,
          );
          expect(
            find.text(
              portalSurface == 'dashboard'
                  ? 'User ID or email\nवापरकर्ता नाव किंवा ईमेल'
                  : 'User ID or email\nशाळेचा आयडी, वापरकर्ता नाव किंवा ईमेल',
            ),
            findsOneWidget,
          );
          store.language = 0;
          await tester.pump();
          expect(email.text, 'mock-user');
          expect(password.text, 'mock-user');
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
          email.dispose();
          password.dispose();
        },
      );
    }
  }
  test(
    'Same administrator role routes to monitoring only on the dashboard surface',
    () async {
      for (final surface in ['classroom', 'dashboard']) {
        SharedPreferences.setMockInitialValues({});
        final client = CentralClient(
          endpoint: 'http://localhost:8789',
          surface: surface,
          clock: () => DateTime.fromMillisecondsSinceEpoch(
            ((fixture['serverTime'] as num) * 1000).round(),
          ),
          transport: MockClient(
            (_) async => jsonResponse(authResponse('super_admin')),
          ),
        );
        await client.init();
        expect(client.canMonitor, surface == 'dashboard');
        expect(client.canUseClassroom, surface == 'classroom');
        expect(client.canLearn, surface == 'classroom');
        expect(client.session, isNotNull);
        expect(client.loginRevision, 0); // Restored, without another login.
        client.dispose();
      }
    },
  );
  test(
    'App administrator can open shipped learning without seeding or enrolling demo data',
    () async {
      SharedPreferences.setMockInitialValues({
        'presentation_ganit_installation_id': 'test-board-identity-123456',
      });
      final paths = <String>[];
      final client = CentralClient(
        endpoint: 'http://localhost:8789',
        surface: 'classroom',
        clock: () => DateTime.fromMillisecondsSinceEpoch(
          ((fixture['serverTime'] as num) * 1000).round(),
        ),
        transport: MockClient((r) async {
          paths.add(r.url.path);
          if (r.url.path.endsWith('/auth/refresh'))
            return jsonResponse({'code': 'reauth_required'}, 401);
          if (r.url.path.endsWith('/devices/register'))
            return jsonResponse({
              ...authResponse('super_admin'),
              'offlineLease': fixture['offlineLease'],
            });
          if (r.url.path.endsWith('/heartbeat'))
            return jsonResponse({'classroom': 'Test classroom'});
          return jsonResponse({...authResponse('super_admin'), 'device': null});
        }),
      );
      await client.init();
      await client.login('mock-user', 'mock-password');
      expect(client.canMonitor, false);
      expect(client.canLearn, true);
      expect(client.offlineAuthorized, false);
      expect(client.isClassroomAdministrator, true);
      expect(client.loginRevision, 1);
      expect(paths.any((p) => p.endsWith('/devices/register')), false);
      expect(paths.any((p) => p.endsWith('/heartbeat')), false);
      client.dispose();
    },
  );
}
