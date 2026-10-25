import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/live/ny_live.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/playbook/ny_playbook.dart';
import 'package:nylo_support/screenshot/ny_screenshot.dart';
import 'package:nylo_support/playbook/src/playbook_finder.dart'
    show PlaybookOverlayScope;
import 'package:nylo_support/testing/src/ny_playbook_testing.dart';

import 'playbook_test_app.dart';

class _StoreTour extends Playbook {
  @override
  List<PlaybookStep> get steps => [
    screenshot('welcome'),
    tap('Get started'),
    scene('Sign up', [waitForPage('/sign-up'), screenshot('sign_up')]),
  ];
}

class _Plain extends Playbook {
  @override
  List<PlaybookStep> get steps => [
    see('Get started'),
    tap('Get started'),
    waitForPage('/sign-up'),
  ];
}

class _Captioned extends Playbook {
  @override
  List<PlaybookStep> get steps => [
    see('Get started'),
    screenshot('welcome', caption: 'Pay in one tap'),
    tap('Does not exist'),
  ];
}

class _PlaysMissing extends Playbook {
  @override
  List<PlaybookStep> get steps => [play('missing')];
}

class _FailsInScene extends Playbook {
  @override
  List<PlaybookStep> get steps => [
    scene('Broken', [tap('Does not exist')]),
  ];
}

class _Parent extends Playbook {
  @override
  List<PlaybookStep> get steps => [play(_StoreTour()), see('Email')];
}

class _Press extends Playbook {
  @override
  bool get showFinger => true;

  @override
  List<PlaybookStep> get steps => [tap('Press')];
}

/// Captures a 1×1 "PNG" counting how often the screen was read.
class _FakeScreen {
  _FakeScreen({this.onCapture});

  final void Function()? onCapture;
  int captures = 0;

  Future<Screenshot> call(double pixelRatio) async {
    onCapture?.call();
    captures++;
    return Screenshot(
      bytes: Uint8List.fromList([captures]),
      width: (100 * pixelRatio).round(),
      height: (200 * pixelRatio).round(),
    );
  }
}

Future<List<Map<String, Object?>>> _run(
  WidgetTester tester,
  Playbook playbook,
  PlaybookScreenshots mode, {
  List<PlaybookShot>? received,
  _FakeScreen? screen,
  double pixelRatio = 1.0,
}) async {
  final List<Map<String, Object?>> events = [];
  final PlaybookSession session = await Playbook.open(
    clock: NyTesterClock(tester),
    overlay: false,
    camera: PlaybookCamera(
      mode: mode,
      pixelRatio: pixelRatio,
      onShot: received?.add,
      capture: (screen ?? _FakeScreen()).call,
    ),
  );
  try {
    await playbook.runWith(
      session,
      speed: PlaybookSpeed.instant,
      emit: events.add,
    );
  } finally {
    Playbook.close(session);
  }
  return events;
}

/// Each step event's title with the kinds and names of its shots.
List<String> _shots(List<Map<String, Object?>> events) => [
  for (final Map<String, Object?> event in events)
    if (event['event'] == 'step' && event['shots'] != null)
      '${event['title']}: ${[for (final Object? shot in event['shots']! as List) _label(shot! as Map)].join(', ')}',
];

String _label(Map shot) => shot['name'] == null
    ? '${shot['kind']}'
    : '${shot['kind']} ${shot['name']}';

void main() {
  setUp(PlaybookCamera.reset);

  testWidgets('auto captures every step of a playbook without marks', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());

    final List<Map<String, Object?>> events = await _run(
      tester,
      _Plain(),
      PlaybookScreenshots.auto,
    );

    expect(_shots(events), [
      'See "Get started": step',
      'Tap "Get started": step',
      'Wait for page /sign-up: step',
    ]);
  });

  testWidgets('auto captures only the screenshot() steps when there are any', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());

    final List<Map<String, Object?>> events = await _run(
      tester,
      _StoreTour(),
      PlaybookScreenshots.auto,
    );

    expect(_shots(events), [
      'Screenshot welcome: marked welcome',
      'Screenshot sign_up: marked sign_up',
    ]);
  });

  testWidgets('a played playbook keeps its own marks', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());

    final List<Map<String, Object?>> events = await _run(
      tester,
      _Parent(),
      PlaybookScreenshots.auto,
    );

    expect(_shots(events), [
      'Screenshot welcome: marked welcome',
      'Screenshot sign_up: marked sign_up',
      'See "Email": step',
    ]);
  });

  testWidgets('marked, Metro\'s default, captures the screenshot() steps', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());

    expect(
      _shots(await _run(tester, _StoreTour(), PlaybookScreenshots.marked)),
      [
        'Screenshot welcome: marked welcome',
        'Screenshot sign_up: marked sign_up',
      ],
    );
  });

  testWidgets('marked leaves the steps of a playbook without marks alone', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());

    expect(
      _shots(await _run(tester, _Plain(), PlaybookScreenshots.marked)),
      isEmpty,
    );
    PlaybookCamera.reset();
    expect(
      _shots(await _run(tester, BrokenPlaybook(), PlaybookScreenshots.marked)),
      ['Tap "Does not exist": failure'],
    );
  });

  testWidgets('failures skips the screenshot() steps', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());

    expect(
      _shots(await _run(tester, _StoreTour(), PlaybookScreenshots.failures)),
      isEmpty,
    );
  });

  testWidgets('all captures every step and the marks', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());

    final List<Map<String, Object?>> events = await _run(
      tester,
      _StoreTour(),
      PlaybookScreenshots.all,
    );

    expect(_shots(events), [
      'Screenshot welcome: marked welcome',
      'Tap "Get started": step',
      'Wait for page /sign-up: step',
      'Screenshot sign_up: marked sign_up',
    ]);
  });

  testWidgets('failures captures only the failing step', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());

    final List<Map<String, Object?>> events = await _run(
      tester,
      BrokenPlaybook(),
      PlaybookScreenshots.failures,
    );

    expect(_shots(events), ['Tap "Does not exist": failure']);
  });

  testWidgets('a group that fails before its steps run is captured', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());

    final List<Map<String, Object?>> events = await _run(
      tester,
      _PlaysMissing(),
      PlaybookScreenshots.failures,
    );

    expect(_shots(events), ['Play missing: failure']);
  });

  testWidgets('a failure inside a scene is captured once', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());

    final List<Map<String, Object?>> events = await _run(
      tester,
      _FailsInScene(),
      PlaybookScreenshots.failures,
    );

    expect(_shots(events), ['Tap "Does not exist": failure']);
  });

  testWidgets('every mode but off captures a failing step', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());

    final List<Map<String, Object?>> events = await _run(
      tester,
      BrokenPlaybook(),
      PlaybookScreenshots.auto,
    );

    expect(_shots(events), ['Tap "Does not exist": failure']);
  });

  testWidgets('off captures nothing, and screenshot() steps still pass', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());
    final _FakeScreen screen = _FakeScreen();

    final List<Map<String, Object?>> events = await _run(
      tester,
      _StoreTour(),
      PlaybookScreenshots.off,
      screen: screen,
    );

    expect(_shots(events), isEmpty);
    expect(screen.captures, 0);
    expect(events.last['passed'], isTrue);
  });

  testWidgets('a run without a camera passes its screenshot() steps', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());

    final PlaybookReport report = await _StoreTour().run(
      clock: NyTesterClock(tester),
      speed: PlaybookSpeed.instant,
    );

    expect(report.passed, isTrue);
  });

  testWidgets('shots go to onShot with their size', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());
    final List<PlaybookShot> received = [];

    final List<Map<String, Object?>> events = await _run(
      tester,
      _StoreTour(),
      PlaybookScreenshots.auto,
      received: received,
      pixelRatio: 0.5,
    );

    expect(
      [for (final PlaybookShot shot in received) shot.name],
      ['welcome', 'sign_up'],
    );
    expect(received.first.screenshot!.width, 50);
    expect(PlaybookCamera.collect(received.first.id), isNull);
    final Map shot =
        (events.firstWhere(
                      (Map<String, Object?> e) => e['shots'] != null,
                    )['shots']!
                    as List)
                .first
            as Map;
    expect(shot, {
      'id': received.first.id,
      'kind': 'marked',
      'name': 'welcome',
      'width': 50,
      'height': 100,
    });
  });

  testWidgets('the app holds shots until they are collected', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());

    final List<Map<String, Object?>> events = await _run(
      tester,
      _StoreTour(),
      PlaybookScreenshots.auto,
    );
    final List<String> ids = [
      for (final Map<String, Object?> event in events)
        for (final Object? shot in (event['shots'] as List?) ?? const [])
          '${(shot! as Map)['id']}',
    ];

    expect(ids, hasLength(2));
    expect(PlaybookCamera.collect(ids.first)?.name, 'welcome');
    expect(PlaybookCamera.collect(ids.first), isNull);
  });

  testWidgets('screenshot() names must work as file names', (
    WidgetTester tester,
  ) async {
    expect(() => _Plain().screenshot('store/home'), throwsArgumentError);
    expect(() => _Plain().screenshot(''), throwsArgumentError);
    expect(_Plain().screenshot('home-1.dark').title, 'Screenshot home-1.dark');
  });

  testWidgets('a step shot waits for the page transition to finish', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());
    final List<int> animating = [];

    await _run(
      tester,
      _Plain(),
      PlaybookScreenshots.auto,
      screen: _FakeScreen(
        onCapture: () =>
            animating.add(SchedulerBinding.instance.transientCallbackCount),
      ),
    );

    expect(animating, [0, 0, 0]);
  });

  testWidgets('the finger sits above the screenshot boundary', (
    WidgetTester tester,
  ) async {
    int taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        builder: (BuildContext context, Widget? child) =>
            ScreenshotRoot(child: child!),
        home: Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => taps++,
              child: const Text('Press'),
            ),
          ),
        ),
      ),
    );
    final PlaybookSession session = await Playbook.open(
      clock: NyTesterClock(tester),
    );
    try {
      final PlaybookReport report = await _Press().runWith(
        session,
        speed: PlaybookSpeed.instant,
      );
      expect(report.passed, isTrue);
      expect(
        find.descendant(
          of: find.byKey(Screenshot.overlayKey),
          matching: find.byType(PlaybookOverlayScope),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(Screenshot.rootKey),
          matching: find.byType(PlaybookOverlayScope),
        ),
        findsNothing,
      );
    } finally {
      Playbook.close(session);
    }
    expect(taps, 1);
  });

  testWidgets('store runs convert step and marked shots, not failures', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());
    final List<String?> captions = [];
    final List<Map<String, Object?>> events = [];
    final PlaybookSession session = await Playbook.open(
      clock: NyTesterClock(tester),
      overlay: false,
      camera: PlaybookCamera(
        mode: PlaybookScreenshots.all,
        store: ScreenshotStore.ios69,
        frame: true,
        capture: _FakeScreen().call,
        compose: (Screenshot shot, String? caption) async {
          captions.add(caption);
          return Screenshot(bytes: shot.bytes, width: 1320, height: 2868);
        },
      ),
    );
    try {
      await _Captioned().runWith(
        session,
        speed: PlaybookSpeed.instant,
        emit: events.add,
      );
    } finally {
      Playbook.close(session);
    }

    final List<Map> shots = [
      for (final Map<String, Object?> event in events)
        for (final Object? shot in (event['shots'] as List?) ?? const [])
          shot! as Map,
    ];
    expect(
      [for (final Map shot in shots) shot['kind']],
      ['step', 'marked', 'failure'],
    );
    expect(
      [for (final Map shot in shots) shot['store']],
      ['ios-6.9', 'ios-6.9', null],
    );
    expect(shots.last['width'], 100);
    expect(captions, [null, 'Pay in one tap']);
  });

  group('live', () {
    setUp(() {
      NyLive.debugBuildOverride = true;
      final Nylo nylo = Nylo();
      nylo.addPlaybooks({'plain': _Plain.new});
      Backpack.instance.save('nylo', nylo);
    });

    tearDown(() {
      NyLive.debugBuildOverride = null;
      Backpack.instance.delete('nylo');
    });

    testWidgets('playbooks.run checks the screenshots mode', (
      WidgetTester tester,
    ) async {
      await expectLater(
        NyLive.dispatch('playbooks.run', {
          'names': ['plain'],
          'screenshots': 'some',
        }),
        throwsA(
          isA<LiveException>().having(
            (LiveException e) => e.message,
            'message',
            '"screenshots" must be off, failures, marked, auto, all, not "some".',
          ),
        ),
      );
    });

    testWidgets('screenshot.get returns a held shot once', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const PlaybookTestApp());
      final List<Map<String, Object?>> events = await _run(
        tester,
        _StoreTour(),
        PlaybookScreenshots.auto,
      );
      final String id =
          '${((events.firstWhere((Map<String, Object?> e) => e['shots'] != null)['shots']! as List).first as Map)['id']}';

      final Object? result = await NyLive.dispatch('screenshot.get', {
        'id': id,
      });

      expect(result, {'png': 'AQ==', 'width': 100, 'height': 200});
      await expectLater(
        NyLive.dispatch('screenshot.get', {'id': id}),
        throwsA(isA<LiveException>()),
      );
    });
  });
}
