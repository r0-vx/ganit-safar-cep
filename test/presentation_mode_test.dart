import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ganit_safar/central_client.dart';
import 'package:ganit_safar/main.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'central_client_test.dart' show authResponse, fixture, jsonResponse;

void main() {
  test(
    'Presentation switch round trips in both directions without retaining demo mode',
    () {
      for (final source in [
        'https://school.example/',
        'https://school.example/?theme=blue#lesson',
      ]) {
        final original = Uri.parse(source);
        final demo = presentationModeUri(original, true);
        expect(demo.queryParameters['presentation'], '1');
        final live = presentationModeUri(demo, false);
        expect(live.queryParameters.containsKey('presentation'), false);
        expect(
          live.queryParameters['theme'],
          original.queryParameters['theme'],
        );
        expect(live.fragment, original.fragment);
      }
    },
  );
  test(
    'Classroom rejects legacy demo identity and always uses live authentication',
    () async {
      SharedPreferences.setMockInitialValues({
        'ganit_installation_id': 'live-board-identity',
        'ganit_monitor_queue': '[]',
        'ganit_lease_public_key': 'live-key',
      });
      final paths = <String>[];
      final client = CentralClient(
        endpoint: 'http://localhost:8789/api',
        clock: () => DateTime.fromMillisecondsSinceEpoch(
          ((fixture['serverTime'] as num) * 1000).round(),
        ),
        transport: MockClient((r) async {
          paths.add(r.url.path);
          return jsonResponse(authResponse('viewer'));
        }),
      );
      await client.init();
      expect(client.apiBase, 'http://localhost:8789/api');
      expect(client.presentation, false);
      expect(client.installation, 'live-board-identity');
      expect(paths, ['/api/auth/refresh']);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('ganit_installation_id'), 'live-board-identity');
      expect(prefs.getString('ganit_lease_public_key'), fixture['publicKey']);
      expect(prefs.getString('presentation_ganit_installation_id'), isNull);
      expect(prefs.getString('presentation_ganit_lease_public_key'), isNull);
      client.dispose();
    },
  );

  test('Verified polling updates automatically and stops on dispose', () async {
    SharedPreferences.setMockInitialValues({});
    var loads = 0, fail = false;
    final client = CentralClient(
      endpoint: 'http://localhost:8789/api',
      pollSeconds: 1,
      clock: () => DateTime.fromMillisecondsSinceEpoch(
        ((fixture['serverTime'] as num) * 1000).round(),
      ),
      transport: MockClient((r) async {
        if (r.url.path.endsWith('/auth/refresh'))
          return jsonResponse(authResponse('viewer'));
        loads++;
        return fail
            ? jsonResponse({'code': 'server_error'}, 503)
            : jsonResponse({'dataMode': 'live', 'revision': loads});
      }),
    );
    await client.init();
    final received = <Map<String, dynamic>>[];
    final sub = client.snapshots.listen(received.add);
    client.startMonitoring();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(received.single['revision'], 1);
    await Future<void>.delayed(const Duration(milliseconds: 1050));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(received.last['revision'], 2);
    fail = true;
    await Future<void>.delayed(const Duration(milliseconds: 1050));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(
      received.length,
      2,
      reason: 'A network error must not invent replacement values',
    );
    expect(client.connection, 'offline');
    fail = false;
    await Future<void>.delayed(const Duration(milliseconds: 1050));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(client.connection, 'connected');
    expect(received.last['revision'], 4);
    client.stopMonitoring();
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    expect(loads, 4);
    await sub.cancel();
    client.dispose();
  });

  test(
    'Demo preview is available only to an authenticated dashboard super administrator',
    () async {
      for (final setting in [
        ('classroom', 'super_admin'),
        ('dashboard', 'viewer'),
        ('dashboard', 'school_admin'),
      ]) {
        SharedPreferences.setMockInitialValues({});
        final client = CentralClient(
          endpoint: 'http://localhost:8789',
          surface: setting.$1,
          clock: () => DateTime.fromMillisecondsSinceEpoch(
            ((fixture['serverTime'] as num) * 1000).round(),
          ),
          transport: MockClient(
            (_) async => jsonResponse(authResponse(setting.$2)),
          ),
        );
        await client.init();
        await expectLater(
          client.previewDemo(true),
          throwsA(isA<CentralFailure>()),
        );
        expect(client.presentation, false);
        client.dispose();
      }
      SharedPreferences.setMockInitialValues({});
      final paths = <String>[];
      final client = CentralClient(
        endpoint: 'http://localhost:8789',
        surface: 'dashboard',
        pollSeconds: 1,
        clock: () => DateTime.fromMillisecondsSinceEpoch(
          ((fixture['serverTime'] as num) * 1000).round(),
        ),
        transport: MockClient((r) async {
          paths.add(r.url.path);
          return jsonResponse(
            r.url.path == '/auth/refresh'
                ? authResponse('super_admin')
                : {
                    'dataMode': r.url.path.endsWith('/demo')
                        ? 'presentation'
                        : 'live',
                  },
          );
        }),
      );
      await client.init();
      await client.previewDemo(true);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(paths, contains('/dashboard/demo'));
      expect(client.canAdminister, false);
      await client.previewDemo(false);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(paths, contains('/dashboard'));
      expect(client.canAdminister, true);
      expect(paths.where((p) => p.contains('/login')), isEmpty);
      client.dispose();
    },
  );
  testWidgets(
    'Demo switch defaults off and remains bilingual with large touch text',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await store.init();
      store.language = 2;
      bool? changed;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 375,
              child: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(1.4)),
                child: PresentationDataSwitch(
                  presentation: false,
                  onChanged: (value) => changed = value,
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Demo data OFF\nनमुना माहिती बंद'), findsOneWidget);
      expect(tester.widget<Switch>(find.byType(Switch)).value, false);
      await tester.tap(find.byType(Switch));
      expect(changed, true);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      store.language = 0;
    },
  );
}
