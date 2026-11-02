import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ganit_safar/central_client.dart';
import 'package:ganit_safar/main.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'central_client_test.dart'
    show FakeEventClient, authResponse, fixture, jsonResponse;

Map<String, dynamic> snapshot(int online) => {
  'overview': {
    'schools': 1,
    'classrooms': 15,
    'devices': 2,
    'onlineClassrooms': online,
    'offlineClassrooms': 15 - online,
  },
  'analytics': <String, dynamic>{},
  for (final key in [
    'schools',
    'classrooms',
    'devices',
    'users',
    'teachers',
    'events',
    'errors',
    'alerts',
    'audit',
    'versions',
    'alertRules',
  ])
    key: <dynamic>[],
};

void main() {
  for (final size in [
    const Size(375, 812),
    const Size(768, 1024),
    const Size(1920, 1080),
  ]) {
    testWidgets(
      'Live dashboard stays usable at ${size.width} with bilingual large text',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        SharedPreferences.setMockInitialValues({
          'ganit_installation_id': 'test-board-identity-123456',
        });
        await store.init();
        store.language = 2;
        var loads = 0;
        final stream = FakeEventClient();
        final client = CentralClient(
          endpoint: 'http://localhost:8787',
          clock: () => DateTime.utc(2026, 11, 1),
          transport: MockClient((request) async {
            if (request.url.path == '/auth/refresh')
              return jsonResponse(authResponse('viewer'));
            loads++;
            return jsonResponse(snapshot(2));
          }),
          streamFactory: () => stream,
        );
        await client.init();
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                size: size,
                textScaler: const TextScaler.linear(1.4),
              ),
              child: ManagementPage(client: client),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
        expect(
          find.text('Central classroom monitoring\nमध्यवर्ती वर्ग निरीक्षण'),
          findsOneWidget,
        );
        expect(loads, 1);
        stream.emit(snapshot(0));
        await tester.pump(const Duration(milliseconds: 200));
        expect(
          loads,
          1,
          reason: 'SSE must update the dashboard without another REST load',
        );
        expect(find.text('0 / 15'), findsOneWidget);
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('online-ring-count')))
              .data,
          '0',
        );
        expect(find.textContaining('Teacher accounts'), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        client.dispose();
        await tester.pump();
      },
    );
  }
  testWidgets('Teacher cannot render administration even if routed directly', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'ganit_installation_id': 'test-board-identity-123456',
    });
    await store.init();
    store.language = 0;
    final client = CentralClient(
      endpoint: 'http://localhost:8787',
      clock: () => DateTime.fromMillisecondsSinceEpoch(
        ((fixture['serverTime'] as num) * 1000).round(),
      ),
      transport: MockClient((_) async => jsonResponse(authResponse())),
    );
    await client.init();
    await tester.pumpWidget(MaterialApp(home: ManagementPage(client: client)));
    expect(
      find.text('Your role cannot access administration.'),
      findsOneWidget,
    );
    expect(find.text('Add school'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    client.dispose();
  });
}
