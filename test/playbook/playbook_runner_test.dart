import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/live/ny_live.dart';
import 'package:nylo_support/live/src/ny_live_builtins.dart'
    show simulatorIdFromPath;
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/playbook/ny_playbook.dart';
import 'package:nylo_support/testing/src/ny_playbook_testing.dart';

import 'playbook_test_app.dart';

class _JourneyByName extends Playbook {
  @override
  List<PlaybookStep> get steps => [
    play('sign_up_to_dashboard'),
    play('log_out'),
  ];
}

class _UnknownChild extends Playbook {
  @override
  List<PlaybookStep> get steps => [play('nope')];
}

void main() {
  final List<Map<String, Object?>> events = [];

  setUp(() {
    AppLog.reset();
    events.clear();
    NyLive.debugBuildOverride = true;
    NyLive.onEmit = (String kind, Map<String, Object?> data) {
      if (kind == 'playbook') events.add(data);
    };
    final Nylo nylo = Nylo();
    nylo.addPlaybooks({
      'sign_up_to_dashboard': SignUpToDashboardPlaybook.new,
      'log_out': LogOutPlaybook.new,
      'broken': BrokenPlaybook.new,
      'journey_by_name': _JourneyByName.new,
      'unknown_child': _UnknownChild.new,
    });
    Backpack.instance.save('nylo', nylo);
  });

  tearDown(() {
    Playbook.debugReleaseModeOverride = false;
    NyLive.onEmit = null;
    NyLive.debugBuildOverride = null;
    Backpack.instance.delete('nylo');
  });

  List<String> kinds() => [
    for (final Map<String, Object?> event in events) '${event['event']}',
  ];

  testWidgets('runs registered playbooks back to back, streaming events', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());

    final String runId = PlaybookRunner.start(
      ['sign_up_to_dashboard', 'log_out'],
      speed: PlaybookSpeed.instant,
      data: {'email': 'metro@nylo.dev'},
      clock: NyTesterClock(tester),
    );
    final String? active = PlaybookRunner.activeRunId;
    await PlaybookRunner.done;

    expect(active, runId);

    expect(PlaybookRunner.activeRunId, isNull);
    expect(
      events.every((Map<String, Object?> e) => e['runId'] == runId),
      isTrue,
    );
    expect(kinds().first, 'start');
    expect(kinds().last, 'done');
    expect(kinds().where((String kind) => kind == 'finish'), hasLength(2));
    expect(kinds().where((String kind) => kind == 'step'), hasLength(23));
    expect(events.first['loop'], 1);
    expect(events.last['passed'], isTrue);
    expect(events.last['runs'], 2);
    final Map<String, Object?> typed = events.firstWhere(
      (Map<String, Object?> e) =>
          e['event'] == 'step' && '${e['title']}'.startsWith('Type "metro'),
    );
    expect(typed['status'], 'passed');
    expect(typed['index'], 4);
    expect(typed['total'], 19);
  });

  testWidgets('a failure ends the run and the rest of the list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());

    PlaybookRunner.start(
      ['broken', 'log_out'],
      speed: PlaybookSpeed.instant,
      clock: NyTesterClock(tester),
    );
    await PlaybookRunner.done;

    final Map<String, Object?> failed = events.firstWhere(
      (Map<String, Object?> e) => e['status'] == 'failed',
    );
    expect(failed['error'], contains('Could not find "Does not exist"'));
    expect(failed['visible'], contains('Get started'));
    expect(kinds().where((String kind) => kind == 'finish'), hasLength(1));
    expect(events.last['passed'], isFalse);
    expect(events.last['runs'], 1);
  });

  testWidgets('play() takes registry names, and says when one is missing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());

    final PlaybookReport byName = await _JourneyByName().run(
      clock: NyTesterClock(tester),
      speed: PlaybookSpeed.instant,
    );
    expectPlaybookPassed(byName);
    expect(byName.name, 'journey_by_name');

    final PlaybookReport missing = await _UnknownChild().run(
      clock: NyTesterClock(tester),
    );
    expect(
      missing.failure!.error,
      startsWith('There\'s no playbook called "nope".'),
    );
  });

  testWidgets('a countdown is shown and reported before the first step', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());

    // Each event is emitted after the previous second was pumped, so the
    // screen still shows the number before it.
    final List<String?> shown = [];
    NyLive.onEmit = (String kind, Map<String, Object?> data) {
      if (kind != 'playbook') return;
      events.add(data);
      if (data['event'] == 'countdown' || data['event'] == 'start') {
        shown.add(
          [
            '1',
            '2',
          ].where((n) => find.text(n).evaluate().isNotEmpty).firstOrNull,
        );
      }
    };
    PlaybookRunner.start(
      ['sign_up_to_dashboard', 'log_out'],
      speed: PlaybookSpeed.instant,
      countdown: 2,
      clock: NyTesterClock(tester),
    );
    await PlaybookRunner.done;

    expect(kinds().take(3), ['countdown', 'countdown', 'start']);
    expect(events[0]['left'], 2);
    expect(events[1]['left'], 1);
    expect(shown.take(3), [null, '2', '1']);
    await tester.pump();
    expect(find.text('1'), findsNothing);
    expect(events.last['passed'], isTrue);
  });

  testWidgets('loop repeats until stopped', (WidgetTester tester) async {
    await tester.pumpWidget(const PlaybookTestApp());

    final String runId = PlaybookRunner.start(
      ['sign_up_to_dashboard', 'log_out'],
      speed: PlaybookSpeed.instant,
      loop: true,
      clock: NyTesterClock(tester),
    );
    final List<bool> stops = [];
    NyLive.onEmit = (String kind, Map<String, Object?> data) {
      if (kind != 'playbook') return;
      events.add(data);
      if (data['event'] == 'start' && data['loop'] == 2 && data['depth'] == 0) {
        stops.add(PlaybookRunner.stop('someone_else'));
        stops.add(PlaybookRunner.stop(runId));
      }
    };
    await PlaybookRunner.done;

    expect(stops, [false, true]);

    expect(events.last['event'], 'done');
    expect(events.last['stopped'], isTrue);
    expect(events.last['passed'], isFalse);
    expect(events.last['runs'], 3);
  });

  testWidgets('the live built-ins list, run and stop playbooks', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());

    final Object? status = await NyLive.dispatch('status');
    expect((status as Map)['playbooks'], contains('log_out'));
    expect(status['protocol'], 14);
    expect(status.containsKey('simulator'), isFalse);
    expect(
      simulatorIdFromPath(
        '/Users/a/Library/Developer/CoreSimulator/Devices/'
        '5C3B43A5-2149-445F-8D80-6F72B766D4D4/data/Containers/Data/'
        'Application/1A9/tmp',
      ),
      '5C3B43A5-2149-445F-8D80-6F72B766D4D4',
    );
    expect(
      simulatorIdFromPath('/private/var/mobile/Containers/Data/x/tmp'),
      isNull,
    );

    final Map list = (await NyLive.dispatch('playbooks.list')) as Map;
    final Map signUp = (list['playbooks'] as List).firstWhere(
      (dynamic p) => p['name'] == 'sign_up_to_dashboard',
    );
    expect(
      signUp['description'],
      'New user signs up and lands on the dashboard',
    );
    expect(signUp['speed'], 'natural');
    expect((signUp['steps'] as List).first, 'See "Get started"');
    expect(list['running'], isNull);

    await expectLater(
      NyLive.dispatch('playbooks.run', {
        'names': ['nope'],
      }),
      throwsA(
        isA<LiveException>().having(
          (LiveException e) => e.message,
          'message',
          contains('Registered: sign_up_to_dashboard, log_out'),
        ),
      ),
    );
    await expectLater(
      NyLive.dispatch('playbooks.run', {
        'names': ['log_out'],
        'speed': 'warp',
      }),
      throwsA(isA<LiveException>()),
    );
    await expectLater(
      NyLive.dispatch('playbooks.run', {
        'names': ['log_out'],
        'countdown': 11,
      }),
      throwsA(
        isA<LiveException>().having(
          (LiveException e) => e.message,
          'message',
          contains('"countdown" must be a whole number of seconds'),
        ),
      ),
    );
    expect(await NyLive.dispatch('playbooks.stop'), {
      'stopped': false,
      'runId': null,
    });
    expect(NyLive.readOnlyCommands, contains('playbooks.list'));
    expect(NyLive.readOnlyCommands, isNot(contains('playbooks.run')));
  });

  testWidgets('release builds refuse to run or register playbooks', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());
    Playbook.debugReleaseModeOverride = true;

    expect(Playbook.isAvailable, isFalse);
    Object? error;
    try {
      await LogOutPlaybook().run(clock: NyTesterClock(tester));
    } catch (e) {
      error = e;
    }
    expect(error, isA<UnsupportedError>());
    expect(Playbook.isRunning, isFalse);
    expect(AppLog.changes, isEmpty);

    final Nylo nylo = Nylo();
    nylo.addPlaybooks({'log_out': LogOutPlaybook.new});
    expect(nylo.getPlaybooks(), isEmpty);
  });
}
