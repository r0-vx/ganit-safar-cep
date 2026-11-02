import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ganit_safar/central_client.dart';
import 'package:ganit_safar/main.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'central_client_test.dart'
    show FakeEventClient, authResponse, jsonResponse;

Map<String, dynamic> visualSnapshot({bool online = true}) => {
  'overview': {
    'schools': 1,
    'classrooms': 2,
    'devices': 1,
    'onlineClassrooms': online ? 1 : 0,
    'offlineClassrooms': online ? 1 : 2,
    'activeTeachers': online ? 1 : 0,
    'activeLessons': online ? 1 : 0,
    'attention': 0,
  },
  'analytics': {
    'todayUsage': 6,
    'weeklyUsage': 6,
    'usageDaily': [
      {
        'day': '2026-11-01',
        'classroom_id': 'room-a',
        'mode': 'learn',
        'started': 3,
        'completed': 2,
      },
      {
        'day': '2026-11-01',
        'classroom_id': 'room-a',
        'mode': 'practice',
        'started': 2,
        'completed': 1,
      },
      {
        'day': '2026-11-01',
        'classroom_id': 'room-a',
        'mode': 'quiz',
        'started': 1,
        'completed': 1,
      },
    ],
  },
  'classrooms': [
    {
      'id': 'room-a',
      'name': 'Mango classroom',
      'school_name': 'Sample school',
      'school_id': 'school-a',
      'grade': 1,
      'section': 'A',
      'status': 'active',
      'online': online,
      'teacher_ids': [],
      'current_activities': online
          ? [
              {'mode': 'learn', 'chapter': 'G1-C10'},
            ]
          : [],
    },
    {
      'id': 'room-b',
      'name': 'Banana classroom',
      'school_name': 'Sample school',
      'school_id': 'school-a',
      'grade': 2,
      'section': 'B',
      'status': 'active',
      'online': false,
      'teacher_ids': [],
      'current_activities': [],
    },
  ],
  'devices': [
    {
      'id': 'board-a',
      'name': 'Sample board',
      'classroom_id': 'room-a',
      'classroom_name': 'Mango classroom',
      'school_name': 'Sample school',
      'school_id': 'school-a',
      'status': online ? 'online' : 'offline',
      'online': online,
      'current_mode': 'learn',
      'chapter_id': 'G1-C10',
      'active': 1,
      'revoked': 0,
      'health': 'ok',
      'teacher_name': 'Sample teacher',
      'last_seen': 1793491200,
      'session_count': 1,
      'error_count': 0,
      'version': '1.2.0',
    },
  ],
  for (final key in [
    'schools',
    'users',
    'teachers',
    'events',
    'errors',
    'alerts',
    'audit',
    'versions',
    'alertRules',
    'systemEvents',
  ])
    key: <dynamic>[],
};

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'ganit_installation_id': 'test-board-identity-123456',
    });
    await store.init();
    store.language = 0;
    store.reducedMotion = false;
    store.contrast = false;
  });

  testWidgets(
    'Weekly chart aggregates real modes, fills zero days and switches completion data',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DashboardWeekChart(
                usage: visualSnapshot()['analytics']['usageDaily'],
                today: DateTime.utc(2026, 11, 1),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('6 sessions'), findsOneWidget);
      expect(
        find.text('01/11  ·  Learn 3  ·  Practice 2  ·  Quiz 1'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('usage-day-0')));
      await tester.pumpAndSettle();
      expect(
        find.text('26/10  ·  Learn 0  ·  Practice 0  ·  Quiz 0'),
        findsOneWidget,
      );
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('usage-day-6')));
      await tester.pumpAndSettle();
      expect(find.text('4 sessions'), findsOneWidget);
      expect(
        find.text('01/11  ·  Learn 2  ·  Practice 1  ·  Quiz 1'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Classroom map filters actual online state and opens the selected room',
    (tester) async {
      String? opened;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DashboardClassroomMap(
                data: visualSnapshot(),
                onOpen: (id) => opened = id,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('room-room-a')), findsOneWidget);
      expect(find.byKey(const ValueKey('room-room-b')), findsOneWidget);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Online'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('room-room-b')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('room-room-a')));
      expect(opened, 'room-a');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DashboardClassroomMap(
                data: visualSnapshot(online: false),
                onOpen: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No classrooms match this status.'), findsOneWidget);
    },
  );

  testWidgets(
    'Reduced-motion, high-contrast charts support bilingual large text and zero data',
    (tester) async {
      store.language = 2;
      store.reducedMotion = true;
      store.contrast = true;
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.4)),
            child: Scaffold(
              body: SingleChildScrollView(
                child: DashboardOverview(
                  data: {'overview': {}, 'analytics': {}},
                  now: DateTime.utc(2026, 11, 1),
                  onNavigate: (_) {},
                  onClassroom: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('0 / 0'), findsOneWidget);
      expect(
        find.text(
          'No sessions recorded in this period yet.\nया कालावधीत अद्याप सत्रांची नोंद नाही.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Live updates preserve chart choice, search and viewer read-only table details',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final stream = FakeEventClient();
      final requests = <String>[];
      final client = CentralClient(
        endpoint: 'http://localhost:8787',
        clock: () => DateTime.utc(2026, 11, 1),
        streamFactory: () => stream,
        transport: MockClient((request) async {
          requests.add(request.url.path);
          return jsonResponse(
            request.url.path == '/auth/refresh'
                ? authResponse('viewer')
                : visualSnapshot(),
          );
        }),
      );
      await client.init();
      await tester.pumpWidget(
        MaterialApp(home: ManagementPage(client: client)),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.ensureVisible(find.text('Completed'));
      await tester.tap(find.text('Completed'));
      stream.emit(visualSnapshot(online: false));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('4 sessions'), findsOneWidget);
      expect(find.text('0 / 2'), findsOneWidget);
      expect(requests.where((path) => path == '/dashboard'), hasLength(1));
      await tester.ensureVisible(find.text('Classrooms').first);
      await tester.tap(find.text('Classrooms').first);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(DataTable), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('management-search')),
        'Mango',
      );
      await tester.pump();
      expect(find.text('Banana classroom'), findsNothing);
      stream.emit(visualSnapshot());
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('management-search')))
            .controller!
            .text,
        'Mango',
      );
      await tester.tap(find.text('Mango classroom'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.textContaining('Current activity:'), findsOneWidget);
      expect(find.textContaining('Assigned teachers'), findsNothing);
      expect(find.text('Edit classroom'), findsNothing);
      expect(find.text('Assign teachers'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      client.dispose();
      await tester.pump();
    },
  );
  testWidgets(
    'Every management section keeps its controls inside the new navigation',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final stream = FakeEventClient();
      final client = CentralClient(
        endpoint: 'http://localhost:8787',
        clock: () => DateTime.utc(2026, 11, 1),
        streamFactory: () => stream,
        transport: MockClient(
          (request) async => jsonResponse(
            request.url.path == '/auth/refresh'
                ? authResponse('super_admin')
                : visualSnapshot(),
          ),
        ),
      );
      await client.init();
      await tester.pumpWidget(
        MaterialApp(home: ManagementPage(client: client)),
      );
      await tester.pump(const Duration(milliseconds: 600));
      for (final pair in [
        ('Schools', 'Add school'),
        ('Classrooms', 'Add classroom'),
        ('Teacher accounts', 'Create teacher / account'),
        ('Devices', 'Register this browser / whiteboard'),
        ('Usage analytics', 'Practice by class'),
        ('Alerts', 'Configure alert thresholds'),
        ('App versions', 'Add / update approved version'),
        ('Audit log', 'Audit log'),
      ]) {
        await tester.ensureVisible(find.text(pair.$1).first);
        await tester.tap(find.text(pair.$1).first);
        await tester.pump(const Duration(milliseconds: 600));
        expect(find.text(pair.$2), findsWidgets);
        expect(tester.takeException(), isNull, reason: pair.$1);
      }
      await tester.pumpWidget(const SizedBox.shrink());
      client.dispose();
      await tester.pump();
    },
  );
  testWidgets('Bilingual touch menu opens classroom cards on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    store.language = 2;
    final stream = FakeEventClient();
    final client = CentralClient(
      endpoint: 'http://localhost:8787',
      clock: () => DateTime.utc(2026, 11, 1),
      streamFactory: () => stream,
      transport: MockClient(
        (request) async => jsonResponse(
          request.url.path == '/auth/refresh'
              ? authResponse('viewer')
              : visualSnapshot(),
        ),
      ),
    );
    await client.init();
    await tester.pumpWidget(MaterialApp(home: ManagementPage(client: client)));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(
      find.byTooltip('Toggle sidebar\nबाजूपट्टी उघडा / बंद करा'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Classrooms\nवर्ग'));
    await tester.pumpAndSettle();
    expect(find.text('Mango classroom • Sample school'), findsOneWidget);
    expect(find.byType(DataTable), findsNothing);
    expect(
      find.text('Create teacher / account\nशिक्षक / खाते तयार करा'),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    client.dispose();
    await tester.pump();
  });
  testWidgets(
    'A silent live stream is marked stale without erasing the last received data',
    (tester) async {
      var clock = DateTime.utc(2026, 11, 1);
      final stream = FakeEventClient();
      final client = CentralClient(
        endpoint: 'http://localhost:8787',
        clock: () => clock,
        streamFactory: () => stream,
        transport: MockClient(
          (request) async => jsonResponse(
            request.url.path == '/auth/refresh'
                ? authResponse('viewer')
                : visualSnapshot(),
          ),
        ),
      );
      await client.init();
      await tester.pumpWidget(
        MaterialApp(home: ManagementPage(client: client)),
      );
      await tester.pump(const Duration(milliseconds: 600));
      stream.emit(visualSnapshot());
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Live updates'), findsOneWidget);
      clock = clock.add(const Duration(seconds: 20));
      await tester.pump(const Duration(seconds: 20));
      expect(find.text('Waiting for live data'), findsOneWidget);
      expect(find.textContaining('Live updates paused.'), findsOneWidget);
      expect(find.text('1 / 2'), findsOneWidget);
      stream.emit(visualSnapshot(online: false));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Live updates'), findsOneWidget);
      expect(find.text('0 / 2'), findsOneWidget);
      expect(find.textContaining('Live updates paused.'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      client.dispose();
      await tester.pump();
    },
  );
  testWidgets(
    'Completion bars use a true percentage scale rather than stretching the largest ratio',
    (tester) async {
      final data = visualSnapshot();
      data['analytics']['chapterUsage'] = {
        'G1-C10': {'started': 4, 'completed': 1},
      };
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DashboardAnalytics(
                data: data,
                now: DateTime.utc(2026, 11, 1),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final completion = find.ancestor(
        of: find.text('Completion by chapter'),
        matching: find.byType(DashboardPanel),
      );
      final bars = find.descendant(
        of: completion,
        matching: find.byType(LinearProgressIndicator),
      );
      expect(bars, findsOneWidget);
      expect(
        tester.widget<LinearProgressIndicator>(bars).value,
        closeTo(.25, .0001),
      );
      expect(find.text('1 / 4'), findsOneWidget);
    },
  );
}
