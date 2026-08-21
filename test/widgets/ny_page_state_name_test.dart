import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/event_bus/ny_event_bus.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/router/ny_router.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';

/// Helper to initialize Nylo for widget tests that use NyPage.
void _initNylo() {
  NyEnvRegistry.register(
    getter: (String key, {dynamic defaultValue}) => defaultValue,
    containsKey: (String key) => false,
  );
  if (!Backpack.instance.isNyloInitialized()) {
    Backpack.instance.save("nylo", Nylo());
  }
  // Fresh EventBus per test so state events do not leak between tests.
  Backpack.instance.save("event_bus", EventBus(maxHistoryLength: 10));
}

/// A page whose state class is deliberately not named `_${Widget}State`.
///
/// This is the shape `flutter build --obfuscate` produces: the widget class and
/// its state class carry unrelated names, so a page can only be reached if both
/// ends of the update read the same class.
class RenamedStatePage extends NyStatefulWidget {
  static RouteView path = ("/renamed-state", (_) => RenamedStatePage());

  RenamedStatePage({super.key}) : super(child: () => _AnUnrelatedName());
}

class _AnUnrelatedName extends NyPage<RenamedStatePage> {
  int bumped = 0;

  @override
  bool get stateManaged => true;

  @override
  Map<String, Function> get stateActions => {
    'bump': () {
      bumped++;
      setState(() {});
    },
  };

  @override
  Widget view(BuildContext context) => Text('bumped $bumped');
}

/// A page that declares the name it is addressed by.
class DeclaredNamePage extends NyStatefulWidget {
  static const String stateKey = 'declared-name-page';

  DeclaredNamePage({super.key})
    : super(child: () => _DeclaredNamePageState(), stateName: stateKey);
}

class _DeclaredNamePageState extends NyPage<DeclaredNamePage> {
  @override
  bool get stateManaged => true;

  @override
  Widget view(BuildContext context) => Text('data: $stateData');
}

/// A page that names itself through its state's `name` argument.
class StateNamedPage extends NyStatefulWidget {
  static const String stateKey = 'state-named-page';

  StateNamedPage({super.key})
    : super(child: () => _StateNamedPageState(), stateName: 'ignored-name');
}

class _StateNamedPageState extends NyPage<StateNamedPage> {
  _StateNamedPageState() : super(name: StateNamedPage.stateKey);

  @override
  bool get stateManaged => true;

  @override
  Widget view(BuildContext context) => const SizedBox.shrink();
}

/// A journey hub whose state class is renamed the way obfuscation renames it.
class JourneyHub extends NyStatefulWidget {
  static RouteView path = ("/journey-hub", (_) => JourneyHub());

  JourneyHub({super.key}) : super(child: () => _AnUnrelatedHubName());

  static NavigationHubStateActions stateActions = NavigationHubStateActions(
    path.stateName(),
  );
}

class _AnUnrelatedHubName extends NavigationHub<JourneyHub> {
  _AnUnrelatedHubName()
    : super(
        () => {
          0: NavigationTab(title: 'Step 1', page: const Text('step one')),
          1: NavigationTab(title: 'Step 2', page: const Text('step two')),
        },
      );

  @override
  NavigationHubLayout? layout(BuildContext context) =>
      NavigationHubLayout.journey();
}

/// A journey hub that declares the name it is addressed by.
class DeclaredNameHub extends NyStatefulWidget {
  static const String stateKey = 'declared-name-hub';

  DeclaredNameHub({super.key})
    : super(child: () => _DeclaredNameHubState(), stateName: stateKey);

  static NavigationHubStateActions stateActions = NavigationHubStateActions(
    stateKey,
  );
}

class _DeclaredNameHubState extends NavigationHub<DeclaredNameHub> {
  _DeclaredNameHubState()
    : super(
        () => {
          0: NavigationTab(title: 'One', page: const Text('declared one')),
          1: NavigationTab(title: 'Two', page: const Text('declared two')),
        },
      );

  @override
  NavigationHubLayout? layout(BuildContext context) =>
      NavigationHubLayout.journey();
}

/// A journey step pointed at a hub that is not on screen.
class OrphanStep extends StatefulWidget {
  const OrphanStep({super.key});

  @override
  State<OrphanStep> createState() => _OrphanStepState();
}

class _OrphanStepState extends JourneyState<OrphanStep> {
  _OrphanStepState() : super(navigationHubState: 'a-hub-that-is-not-here');

  @override
  Widget view(BuildContext context) => const Text('orphan step');
}

void main() {
  NyTest.init();

  setUp(() {
    _initNylo();
  });

  nyGroup('NyStatefulWidget state name', () {
    nyWidgetTest('defaults to the name its route addresses', (tester) async {
      expect(RenamedStatePage().state, RenamedStatePage.path.stateName());
    });

    nyWidgetTest('keeps a stateName given to the constructor', (tester) async {
      expect(DeclaredNamePage().state, DeclaredNamePage.stateKey);
    });
  });

  nyGroup('updateState', () {
    nyWidgetTest('fires a RouteView target at the route\'s state name', (
      tester,
    ) async {
      updateState(RenamedStatePage.path, data: 'route-view-data');

      final EventBus eventBus = Backpack.instance.read('event_bus')!;
      final UpdateState event = eventBus.history.last.event as UpdateState;

      expect(event.stateName, RenamedStatePage.path.stateName());
      expect(event.data, 'route-view-data');
    });
  });

  nyGroup('NyPage state name', () {
    nyWidgetTest('listens on the name its route addresses', (tester) async {
      await tester.pumpNyWidget(RenamedStatePage());

      final state = tester.state<_AnUnrelatedName>(
        find.byType(RenamedStatePage),
      );

      expect(state.stateName, RenamedStatePage.path.stateName());
    });

    nyWidgetTest('receives a state action sent to its route', (tester) async {
      await tester.pumpNyWidget(RenamedStatePage());
      expect(find.text('bumped 0'), findsOneWidget);

      stateAction('bump', state: RenamedStatePage.path);
      await tester.pumpAndSettle();

      expect(find.text('bumped 1'), findsOneWidget);
    });

    nyWidgetTest('keeps the stateName declared on the widget', (tester) async {
      await tester.pumpNyWidget(DeclaredNamePage());

      final state = tester.state<_DeclaredNamePageState>(
        find.byType(DeclaredNamePage),
      );

      expect(state.stateName, DeclaredNamePage.stateKey);
    });

    nyWidgetTest('keeps the name given to the state', (tester) async {
      await tester.pumpNyWidget(StateNamedPage());

      final state = tester.state<_StateNamedPageState>(
        find.byType(StateNamedPage),
      );

      expect(state.stateName, StateNamedPage.stateKey);
    });
  });

  nyGroup('NyPage state history', () {
    nyWidgetTest('restores the last payload sent to it', (tester) async {
      fireStateUpdate(DeclaredNamePage.stateKey, data: {'tab-index': 3});

      await tester.pumpNyWidget(DeclaredNamePage());

      final state = tester.state<_DeclaredNamePageState>(
        find.byType(DeclaredNamePage),
      );

      expect(state.stateData, {'tab-index': 3});
    });

    nyWidgetTest('leaves another state\'s payload alone', (tester) async {
      fireStateUpdate('a-different-state', data: {'tab-index': 3});

      await tester.pumpNyWidget(DeclaredNamePage());

      final state = tester.state<_DeclaredNamePageState>(
        find.byType(DeclaredNamePage),
      );

      expect(state.stateData, isNull);
    });
  });

  nyGroup('NavigationHub journeys', () {
    nyWidgetTest('advance when nextPage() is called', (tester) async {
      await tester.pumpNyWidget(JourneyHub());
      expect(find.text('step one'), findsOneWidget);

      expect(await JourneyHub.stateActions.nextPage(), isTrue);
      await tester.pumpAndSettle();

      expect(find.text('step two'), findsOneWidget);
      expect(find.text('step one'), findsNothing);
    });

    nyWidgetTest('advance when the hub declares its own name', (tester) async {
      await tester.pumpNyWidget(DeclaredNameHub());

      final state = tester.state<_DeclaredNameHubState>(
        find.byType(DeclaredNameHub),
      );
      expect(state.stateName, DeclaredNameHub.stateKey);
      expect(find.text('declared one'), findsOneWidget);

      expect(await DeclaredNameHub.stateActions.nextPage(), isTrue);
      await tester.pumpAndSettle();

      expect(find.text('declared two'), findsOneWidget);
    });

    nyWidgetTest('return to the previous step', (tester) async {
      await tester.pumpNyWidget(JourneyHub());

      await JourneyHub.stateActions.nextPage();
      await tester.pumpAndSettle();
      expect(await JourneyHub.stateActions.previousPage(), isTrue);
      await tester.pumpAndSettle();

      expect(find.text('step one'), findsOneWidget);
    });
  });

  nyGroup('JourneyState', () {
    nyWidgetTest('a step with no hub data is not treated as the last step', (
      tester,
    ) async {
      await tester.pumpNyWidget(const OrphanStep());

      final state = tester.state<_OrphanStepState>(find.byType(OrphanStep));

      expect(state.totalSteps, 0);
      expect(state.isFirstStep, isTrue);
      expect(state.isLastStep, isFalse);
    });
  });

  nyGroup('a name that reaches no hub', () {
    final List<NyLogEntry> logged = [];

    setUp(() {
      logged.clear();
      NyLogger.onLog = logged.add;
    });

    tearDown(() {
      NyLogger.onLog = null;
    });

    nyWidgetTest('is reported by nextPage()', (tester) async {
      final actions = NavigationHubStateActions('a-hub-that-nextpage-misses');

      await actions.nextPage();

      expect(logged, hasLength(1));
      expect(logged.single.type, 'error');
      expect(logged.single.message, contains('"a-hub-that-nextpage-misses"'));
    });

    nyWidgetTest('is reported by previousPage()', (tester) async {
      final actions = NavigationHubStateActions('a-hub-that-prevpage-misses');

      await actions.previousPage();

      expect(logged, hasLength(1));
      expect(logged.single.type, 'error');
    });

    nyWidgetTest('is reported once, across every step that addresses it', (
      tester,
    ) async {
      const String name = 'a-hub-addressed-on-every-step';

      /// A journey builds a fresh NavigationHubStateActions per step, so the
      /// guard has to hold across instances, not just across calls on one.
      await NavigationHubStateActions(name).nextPage();
      await NavigationHubStateActions(name).nextPage();
      await NavigationHubStateActions(name).previousPage();

      expect(logged, hasLength(1));
    });

    nyWidgetTest('leaves a hub that is listening unreported', (tester) async {
      await tester.pumpNyWidget(JourneyHub());

      await JourneyHub.stateActions.nextPage();

      expect(logged, isEmpty);
    });
  });
}
