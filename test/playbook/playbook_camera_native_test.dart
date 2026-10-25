import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/live/ny_live.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/playbook/ny_playbook.dart';
import 'package:nylo_support/playbook/src/playbook_finder.dart'
    show PlaybookOverlayScope;
import 'package:nylo_support/screenshot/ny_screenshot.dart';
import 'package:nylo_support/testing/src/ny_playbook_testing.dart';

import 'playbook_test_app.dart';

class _Native extends Playbook {
  @override
  List<PlaybookStep> get steps => [see('Get started'), screenshot('welcome')];
}

class _AppOnly extends Playbook {
  @override
  List<PlaybookStep> get steps => [screenshot('welcome', native: false)];
}

class _NativeLocales extends Playbook {
  @override
  List<PlaybookStep> get steps => [
    screenshot('welcome', locales: ['en', 'es']),
  ];
}

/// One native request the camera made.
typedef _Request = ({String id, String name, String? locale, bool hidden});

Future<List<Map<String, Object?>>> _run(
  WidgetTester tester,
  Playbook playbook, {
  PlaybookNative? native,
  ScreenshotStore? store,
  List<String>? composed,
  List<int>? captures,
  void Function(PlaybookSession session)? after,
}) async {
  final List<Map<String, Object?>> events = [];
  final PlaybookSession session = await Playbook.open(
    clock: NyTesterClock(tester),
    camera: PlaybookCamera(
      mode: PlaybookScreenshots.marked,
      native: native,
      store: store,
      compose: (Screenshot shot, String? caption) async {
        composed?.add('$caption');
        return shot;
      },
      look: ({String? locale, String? theme}) async => () async {},
      capture: (double pixelRatio) async {
        captures?.add(1);
        return Screenshot(bytes: Uint8List(1), width: 100, height: 200);
      },
    ),
  );
  try {
    await playbook.runWith(
      session,
      speed: PlaybookSpeed.instant,
      emit: events.add,
    );
    after?.call(session);
  } finally {
    Playbook.close(session);
  }
  return events;
}

/// The shots reported in [events]' step events.
List<Map> _shots(List<Map<String, Object?>> events) => [
  for (final Map<String, Object?> event in events)
    if (event['event'] == 'step' && event['shots'] != null)
      for (final Object? shot in event['shots']! as List) shot! as Map,
];

void main() {
  setUp(PlaybookCamera.reset);

  testWidgets('a native step asks Metro, with the finger and caption hidden', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());
    final List<_Request> requests = [];
    final List<int> captures = [];
    bool? hiddenAfter;

    final List<Map<String, Object?>> events = await _run(
      tester,
      _Native(),
      captures: captures,
      native:
          ({
            required String id,
            required String name,
            String? locale,
            String? theme,
          }) async {
            requests.add((
              id: id,
              name: name,
              locale: locale,
              hidden: find
                  .descendant(
                    of: find.byType(PlaybookOverlayScope),
                    matching: find.byType(Stack),
                  )
                  .evaluate()
                  .isEmpty,
            ));
          },
      after: (PlaybookSession session) =>
          hiddenAfter = session.overlay?.hidden.value,
    );

    expect(requests, hasLength(1));
    expect(requests.single.name, 'welcome');
    expect(requests.single.hidden, isTrue);
    expect(hiddenAfter, isFalse);
    expect(captures, isEmpty);
    expect(_shots(events), [
      {
        'id': requests.single.id,
        'kind': 'marked',
        'name': 'welcome',
        'native': true,
      },
    ]);
    expect(PlaybookCamera.collect(requests.single.id), isNull);
  });

  testWidgets('a native step falls back to the app when Metro can\'t', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());
    final List<int> captures = [];

    final List<Map<String, Object?>> events = await _run(
      tester,
      _Native(),
      captures: captures,
      native:
          ({
            required String id,
            required String name,
            String? locale,
            String? theme,
          }) async => throw StateError('The simulator shut down'),
    );

    expect(captures, hasLength(1));
    final Map shot = _shots(events).single;
    expect(shot['native'], isNull);
    expect(shot['nativeFallback'], 'The simulator shut down');
    expect(shot['width'], 100);
    expect(PlaybookCamera.collect('${shot['id']}'), isNotNull);
  });

  testWidgets('without Metro, a screenshot() step is the app\'s capture', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());
    final List<int> captures = [];

    final List<Map<String, Object?>> events = await _run(
      tester,
      _Native(),
      captures: captures,
    );

    final Map shot = _shots(events).single;
    expect(captures, hasLength(1));
    expect(shot['native'], isNull);
    expect(shot['nativeFallback'], isNull);
  });

  testWidgets('store runs convert the app\'s capture instead of asking Metro', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());
    final List<String> composed = [];
    int asked = 0;

    final List<Map<String, Object?>> events = await _run(
      tester,
      _Native(),
      store: ScreenshotStore.ios69,
      composed: composed,
      native:
          ({
            required String id,
            required String name,
            String? locale,
            String? theme,
          }) async => asked++,
    );

    final Map shot = _shots(events).single;
    expect(asked, 0);
    expect(composed, hasLength(1));
    expect(shot['store'], 'ios-6.9');
    expect(shot['nativeFallback'], isNull);
  });

  testWidgets('native: false never asks Metro', (WidgetTester tester) async {
    await tester.pumpWidget(const PlaybookTestApp());
    int asked = 0;

    final List<Map<String, Object?>> events = await _run(
      tester,
      _AppOnly(),
      native:
          ({
            required String id,
            required String name,
            String? locale,
            String? theme,
          }) async => asked++,
    );

    expect(asked, 0);
    expect(_shots(events).single['native'], isNull);
  });

  testWidgets('a native step asks once for each locale', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());
    final List<String?> locales = [];

    final List<Map<String, Object?>> events = await _run(
      tester,
      _NativeLocales(),
      native:
          ({
            required String id,
            required String name,
            String? locale,
            String? theme,
          }) async => locales.add(locale),
    );

    expect(locales, ['en', 'es']);
    expect(
      [for (final Map shot in _shots(events)) shot['locale']],
      ['en', 'es'],
    );
  });

  group('live', () {
    final List<Map<String, Object?>> emitted = [];

    setUp(() {
      emitted.clear();
      NyLive.debugBuildOverride = true;
      final Nylo nylo = Nylo();
      nylo.addPlaybooks({'native': _Native.new});
      Backpack.instance.save('nylo', nylo);
    });

    tearDown(() {
      NyLive.onEmit = null;
      NyLive.debugBuildOverride = null;
      Backpack.instance.delete('nylo');
    });

    testWidgets('Metro answers a native event with screenshot.taken', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const PlaybookTestApp());
      final List<Object?> answers = [];
      NyLive.onEmit = (String kind, Map<String, Object?> data) {
        if (kind != 'playbook') return;
        emitted.add(data);
        if (data['event'] == 'native') {
          NyLive.dispatch('screenshot.taken', {
            'runId': data['runId'],
            'id': data['id'],
            'ok': true,
          }).then(answers.add);
        }
      };

      PlaybookRunner.start(
        ['native'],
        speed: PlaybookSpeed.instant,
        screenshots: PlaybookScreenshots.marked,
        native: true,
        clock: NyTesterClock(tester),
      );
      await PlaybookRunner.done;

      final Map<String, Object?> asked = emitted.firstWhere(
        (Map<String, Object?> e) => e['event'] == 'native',
      );
      expect(asked['name'], 'welcome');
      expect(answers, [
        {'resumed': true},
      ]);
      expect(_shots(emitted).single['native'], isTrue);
    });

    testWidgets('screenshot.taken for a step that stopped waiting', (
      WidgetTester tester,
    ) async {
      expect(
        await NyLive.dispatch('screenshot.taken', {
          'runId': 'pb_0',
          'id': 's1',
          'ok': false,
          'error': 'adb failed',
        }),
        {'resumed': false},
      );
    });

    testWidgets('playbooks.run checks native', (WidgetTester tester) async {
      await expectLater(
        NyLive.dispatch('playbooks.run', {
          'names': ['native'],
          'native': 'yes',
        }),
        throwsA(
          isA<LiveException>().having(
            (LiveException e) => e.message,
            'message',
            '"overlay", "loop" and "native" must be true or false.',
          ),
        ),
      );
    });
  });
}
