import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/playbook/ny_playbook.dart';
import 'package:nylo_support/playbook/src/playbook_finder.dart'
    show PlaybookOverlayScope;
import 'package:nylo_support/testing/src/ny_playbook_testing.dart';

import 'playbook_test_app.dart';

Future<PlaybookReport> _run(
  WidgetTester tester,
  Playbook playbook, {
  PlaybookSpeed speed = PlaybookSpeed.instant,
  Map<String, dynamic>? data,
  List<Map<String, Object?>>? events,
}) => playbook.run(
  clock: NyTesterClock(tester),
  speed: speed,
  data: data,
  onEvent: events?.add,
);

class _SpeedProbe extends Playbook {
  static final List<String> seen = [];

  @override
  String? get name => 'speed_probe';

  @override
  Map<String, dynamic> get defaults => {'email': 'probe@nylo.dev'};

  @override
  List<PlaybookStep> get steps => [
    step('Record', (PlaybookActor actor) async {
      seen.add('${actor.speed.name} ${actor.data['email']}');
    }),
  ];
}

class _ProbeParent extends Playbook {
  @override
  Map<String, dynamic> get defaults => {'email': 'parent@nylo.dev'};

  @override
  List<PlaybookStep> get steps => [
    play(_SpeedProbe()),
    play(_SpeedProbe(), speed: PlaybookSpeed.slow),
    play(_SpeedProbe(), data: {'email': 'explicit@nylo.dev'}),
  ];
}

class _LoopA extends Playbook {
  @override
  List<PlaybookStep> get steps => [play(_LoopB())];
}

class _LoopB extends Playbook {
  @override
  List<PlaybookStep> get steps => [play(_LoopA())];
}

class _PlaysBroken extends Playbook {
  @override
  List<PlaybookStep> get steps => [
    see('Get started'),
    play(BrokenPlaybook()),
    see('Never reached'),
  ];
}

class _Spread extends Playbook {
  @override
  List<PlaybookStep> get steps => [
    ...SignUpToDashboardPlaybook().steps,
    ...LogOutPlaybook().steps,
  ];
}

class _Covered extends Playbook {
  @override
  List<PlaybookStep> get steps => [visit('/covered'), tap('Hidden action')];
}

class _TapHint extends Playbook {
  @override
  List<PlaybookStep> get steps => [
    tap('Get started'),
    tap('Email'),
    see('Email'),
  ];
}

class _Scenes extends Playbook {
  @override
  List<PlaybookStep> get steps => [
    scene('Sign up', [tap('Get started'), waitForPage('/sign-up')]),
    back(),
    see('Get started'),
  ];
}

class _Lifecycle extends Playbook {
  static final List<String> calls = [];

  @override
  Future<void> setUp(PlaybookActor actor) async => calls.add('setUp');

  @override
  Future<void> tearDown(PlaybookActor actor) async => calls.add('tearDown');

  @override
  List<PlaybookStep> get steps => [
    see('Get started'),
    step('Stop the run', (PlaybookActor actor) async {
      Playbook.stop();
      await actor.pause();
    }),
    tap('Get started'),
  ];
}

/// Whether the finger is drawn right now.
bool _fingerShown() => find
    .descendant(
      of: find.byType(PlaybookOverlayScope),
      matching: find.byType(AnimatedContainer),
    )
    .evaluate()
    .isNotEmpty;

PlaybookStep _recordFinger(String label) =>
    PlaybookStep('Record $label', (PlaybookActor actor) async {
      await actor.tap('Nylo');
      await actor.settle();
      _HiddenFinger.seen.add('$label ${_fingerShown()}');
    });

class _Inline extends Playbook {
  _Inline(this._steps);

  final List<PlaybookStep> _steps;

  @override
  List<PlaybookStep> get steps => _steps;
}

class _ShownFinger extends Playbook {
  @override
  bool get showFinger => true;

  @override
  List<PlaybookStep> get steps => [_recordFinger('child')];
}

// Hidden by default.
class _HiddenFinger extends Playbook {
  static final List<String> seen = [];

  @override
  List<PlaybookStep> get steps => [
    _recordFinger('parent'),
    play(_ShownFinger()),
    _recordFinger('parent again'),
  ];
}

void main() {
  setUp(AppLog.reset);

  testWidgets('a journey taps, types, scrolls and long presses like a person', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());

    final PlaybookReport report = await _run(
      tester,
      SignUpToDashboardPlaybook(),
      speed: PlaybookSpeed.natural,
    );

    expectPlaybookPassed(report);
    expect(report.name, 'sign_up_to_dashboard');
    expect(report.speed, 'natural');
    expect(report.steps, hasLength(19));
    // onChanged fired once per character, after the formatter lower-cased it.
    expect(AppLog.changes, hasLength('Demo@Nylo.dev'.length));
    expect(AppLog.changes.last, 'demo@nylo.dev');
    expect(AppLog.agreed, isTrue);
    expect(find.text('Long pressed 45'), findsOneWidget);
    expect(find.text('Log out?'), findsNothing);
    expect(report.steps.map((PlaybookStepResult step) => step.title).take(5), [
      'See "Get started"',
      'Tap "Get started"',
      'Wait for page /sign-up',
      'Type "Demo@Nylo.dev" into "Email"',
      'Type "•••••••••" into "Password"',
    ]);
  });

  testWidgets('the overlay comes and goes, and finders never match it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());

    String? caption;
    final PlaybookReport report = await _run(tester, BrokenPlaybook());

    expect(report.passed, isFalse);
    final PlaybookStepResult failure = report.steps.first;
    expect(failure.status, PlaybookStepStatus.failed);
    expect(
      failure.error,
      'Could not find "Does not exist" on screen after 10s.',
    );
    expect(failure.visibleText, containsAll(['Nylo', 'Get started']));
    expect(
      failure.visibleText.any((String text) => text.contains('Does not exist')),
      isFalse,
      reason: 'the step caption is in the overlay and must be skipped',
    );
    expect(report.steps.last.status, PlaybookStepStatus.skipped);
    await tester.pump();
    caption = tester
        .widgetList<Text>(find.byType(Text))
        .map((Text text) => text.data)
        .firstWhere(
          (String? text) => text?.contains('·') ?? false,
          orElse: () => null,
        );
    expect(caption, isNull, reason: 'the overlay is removed after the run');
    expect(Playbook.isRunning, isFalse);
    expect(
      report.toString(),
      contains(
        '✗ 10000ms  Tap "Does not exist"\n'
        '        Could not find "Does not exist" on screen after 10s.\n'
        '        Visible text: "Nylo", "Get started"',
      ),
    );
    expect(report.toString(), contains('(skipped)'));
  });

  testWidgets('a playbook shows no finger or caption unless it asks', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());
    final List<bool> shown = [];

    final PlaybookReport report = await _run(
      tester,
      _Inline([
        PlaybookStep('Look', (PlaybookActor actor) async {
          await actor.tap('Nylo');
          await actor.settle();
          shown
            ..add(_fingerShown())
            ..add(find.textContaining('1/1 · Look').evaluate().isNotEmpty);
        }),
      ]),
    );

    expectPlaybookPassed(report);
    expect(shown, [false, false]);
  });

  testWidgets('showFinger shows the finger for that playbook only', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());
    _HiddenFinger.seen.clear();

    final PlaybookReport report = await _run(tester, _HiddenFinger());

    expectPlaybookPassed(report);
    expect(_HiddenFinger.seen, [
      'parent false',
      'child true',
      'parent again false',
    ]);
  });

  testWidgets('a button under a modal barrier is refused, not tapped', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());

    final PlaybookReport report = await _run(tester, _Covered());

    expect(report.passed, isFalse);
    expect(report.failure!.error, contains('something covers it'));
    expect(AppLog.changes, isNot(contains('covered tapped')));
  });

  testWidgets('tapping a field by its hint focuses the field', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());

    final PlaybookReport report = await _run(tester, _TapHint());

    expectPlaybookPassed(report);
    final EditableText field = tester.widget<EditableText>(
      find.byType(EditableText).first,
    );
    expect(field.focusNode.hasFocus, isTrue);
  });

  testWidgets('play() nests a playbook with its data, speed and report', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());

    final List<Map<String, Object?>> events = [];
    final PlaybookReport report = await _run(
      tester,
      JourneyPlaybook(),
      events: events,
    );

    expectPlaybookPassed(report);
    expect(report.steps.map((PlaybookStepResult step) => step.title), [
      'Play sign_up_to_dashboard',
      'Play log_out',
      'See "Get started"',
    ]);
    expect(report.steps.first.steps, hasLength(19));
    expect(report.steps[1].steps, hasLength(4));
    // The parent's email reached the child.
    expect(
      report.steps.first.steps[3].title,
      'Type "chain@nylo.dev" into "Email"',
    );
    final Map<String, Object?> childStart = events.firstWhere(
      (Map<String, Object?> event) =>
          event['event'] == 'start' && event['depth'] == 1,
    );
    expect(childStart['path'], ['journey', 'sign_up_to_dashboard']);
    expect(childStart['speed'], 'instant');
    expect(events.last['event'], 'finish');
    expect(events.last['depth'], 0);
    expect(events.last['report'], isA<Map<String, Object?>>());
  });

  testWidgets('data flows down and speed is inherited unless play() says', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());
    _SpeedProbe.seen.clear();

    final PlaybookReport report = await _run(
      tester,
      _ProbeParent(),
      speed: PlaybookSpeed.fast,
    );

    expectPlaybookPassed(report);
    expect(_SpeedProbe.seen, [
      'fast parent@nylo.dev',
      'slow parent@nylo.dev',
      'fast explicit@nylo.dev',
    ]);
  });

  testWidgets('a cycle is refused with the chain named', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());

    final PlaybookReport report = await _run(tester, _LoopA());

    expect(report.passed, isFalse);
    expect(report.failure!.error, 'Playbook cycle: loop_a → loop_b → loop_a');
  });

  testWidgets('a failing child fails the parent step and skips the rest', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());

    final PlaybookReport report = await _run(tester, _PlaysBroken());

    expect(report.steps.map((PlaybookStepResult step) => step.status), [
      PlaybookStepStatus.passed,
      PlaybookStepStatus.failed,
      PlaybookStepStatus.skipped,
    ]);
    expect(report.steps[1].steps.first.status, PlaybookStepStatus.failed);
    expect(report.failure!.title, 'Tap "Does not exist"');
  });

  testWidgets('...other.steps spreads raw steps with their defaults', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());

    final PlaybookReport report = await _run(tester, _Spread());

    expectPlaybookPassed(report);
    expect(report.steps, hasLength(23));
    expect(find.text('Get started'), findsOneWidget);
  });

  testWidgets('scenes nest their steps, and back() taps the back button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());

    final PlaybookReport report = await _run(tester, _Scenes());

    expectPlaybookPassed(report);
    expect(report.steps.first.title, 'Sign up');
    expect(report.steps.first.steps, hasLength(2));
  });

  testWidgets('stop() skips the remaining steps and still tears down', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());
    _Lifecycle.calls.clear();

    final PlaybookReport report = await _run(tester, _Lifecycle());

    expect(report.stopped, isTrue);
    expect(report.passed, isFalse);
    expect(report.steps.map((PlaybookStepResult step) => step.status), [
      PlaybookStepStatus.passed,
      PlaybookStepStatus.skipped,
      PlaybookStepStatus.skipped,
    ]);
    expect(_Lifecycle.calls, ['setUp', 'tearDown']);
    expect(find.text('Get started'), findsOneWidget);
  });

  testWidgets('one playbook runs at a time', (WidgetTester tester) async {
    await tester.pumpWidget(const PlaybookTestApp());

    final Future<PlaybookReport> first = _run(tester, LogOutPlaybook());
    Object? error;
    try {
      await _run(tester, LogOutPlaybook());
    } catch (e) {
      error = e;
    }
    await first;

    expect(error, isA<StateError>());
    expect(Playbook.isRunning, isFalse);
  });

  group('Find', () {
    testWidgets('precise finders narrow a match', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Text('Delete'),
                for (int i = 0; i < 3; i++)
                  Card(child: Text('Delete', key: ValueKey<String>('d$i'))),
                const Icon(Icons.add),
                const Tooltip(message: 'Share', child: Icon(Icons.share)),
                Semantics(label: 'Avatar', child: const SizedBox(width: 20)),
                const TextField(decoration: InputDecoration(labelText: 'Name')),
              ],
            ),
          ),
        ),
      );
      final PlaybookTree tree = PlaybookTree(
        WidgetsBinding.instance.rootElement,
      );

      expect(Find.text('Delete').find(tree), hasLength(4));
      expect(
        Find.text('Delete').inside(Find.type<Card>()).find(tree),
        hasLength(3),
      );
      final Element second = Find.text(
        'Delete',
      ).inside(Find.type<Card>()).at(1).find(tree).single;
      expect(second.widget.key, const ValueKey<String>('d1'));
      expect(Find.icon(Icons.add).find(tree), hasLength(1));
      expect(Find.target('Share').find(tree).single.widget, isA<Tooltip>());
      expect(Find.target('Avatar').find(tree).single.widget, isA<Semantics>());
      // The label is visible text, which a plain string matches first...
      expect(Find.target('Name').find(tree).single.widget, isA<Text>());
      // ...while type() looks for fields first, and Find.input only does.
      expect(
        Find.target('Name').findFields(tree).single.widget,
        isA<InputDecorator>(),
      );
      expect(
        Find.input('Name').find(tree).single.widget,
        isA<InputDecorator>(),
      );
      expect(Find.target('d2').find(tree).single.widget, isA<Text>());
      expect(Find.textContaining('Del').find(tree), hasLength(4));
      expect(
        Find.text('Delete').inside(Find.type<Card>()).at(1).description,
        '"Delete" inside Card (#2)',
      );
      expect(() => Find.target(42), throwsArgumentError);
    });

    test('Find.field targets a NyForm field by its key', () {
      expect(Find.field('emailAddress').description, 'field "emailAddress"');
    });
  });

  group('PlaybookSpeed', () {
    test('presets are found by name and can be scaled', () {
      expect(PlaybookSpeed.named('FAST'), same(PlaybookSpeed.fast));
      expect(PlaybookSpeed.named('warp'), isNull);
      final PlaybookSpeed doubled = PlaybookSpeed.natural.times(2);
      expect(doubled.name, 'natural×2');
      expect(doubled.betweenSteps, const Duration(milliseconds: 1400));
      expect(() => PlaybookSpeed.fast.times(0), throwsArgumentError);
    });
  });
}
