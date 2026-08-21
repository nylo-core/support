import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/controllers/ny_controllers.dart';
import 'package:nylo_support/event_bus/ny_event_bus.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/router/ny_router.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';

/// A controller shared by every page that asks for it.
class SharedController extends NyController {
  @override
  bool get singleton => true;
}

/// A page whose state class is deliberately not named `_${Widget}State`.
///
/// This is the shape `flutter build --obfuscate` produces: the widget class and
/// its state class carry unrelated names, so a page can only be reached if both
/// ends of the update read the same class.
class RenamedNyStatePage extends NyStatefulWidget {
  static RouteView path = ("/renamed-nystate", (_) => RenamedNyStatePage());

  RenamedNyStatePage({super.key}) : super(child: () => _AnUnrelatedName());
}

class _AnUnrelatedName extends NyState<RenamedNyStatePage> {
  @override
  Widget view(BuildContext context) => const Text('renamed nystate');
}

/// A page that names itself through its state's `name` argument.
class StateNamedPage extends NyStatefulWidget {
  static const String stateKey = 'state-named-ny-state';

  StateNamedPage({super.key})
    : super(child: () => _StateNamedPageState(), stateName: 'ignored-name');
}

class _StateNamedPageState extends NyState<StateNamedPage> {
  _StateNamedPageState() : super(name: StateNamedPage.stateKey);

  @override
  Widget view(BuildContext context) => const Text('state named');
}

/// Two pages that share one [SharedController].
class SharedControllerPageA extends NyStatefulWidget<SharedController> {
  static RouteView path = ("/shared-a", (_) => SharedControllerPageA());

  SharedControllerPageA({super.key})
    : super(child: () => _SharedControllerPageAState());
}

class _SharedControllerPageAState extends NyState<SharedControllerPageA> {
  @override
  Widget view(BuildContext context) => const Text('shared a');
}

class SharedControllerPageB extends NyStatefulWidget<SharedController> {
  static RouteView path = ("/shared-b", (_) => SharedControllerPageB());

  SharedControllerPageB({super.key})
    : super(child: () => _SharedControllerPageBState());
}

class _SharedControllerPageBState extends NyState<SharedControllerPageB> {
  @override
  Widget view(BuildContext context) => const Text('shared b');
}

/// Helper to initialize Nylo for widget tests that use NyState.
void _initNylo() {
  NyEnvRegistry.register(
    getter: (String key, {dynamic defaultValue}) => defaultValue,
    containsKey: (String key) => false,
  );
  final nylo = Nylo();
  nylo.addControllers({SharedController: () => SharedController()});
  Backpack.instance.save("nylo", nylo);
  // Fresh EventBus per test so state events do not leak between tests.
  Backpack.instance.save("event_bus", EventBus(maxHistoryLength: 10));
}

void main() {
  NyTest.init();

  setUp(() {
    _initNylo();
  });

  nyGroup('NyState state name', () {
    nyWidgetTest('listens on the name its route addresses', (tester) async {
      await tester.pumpNyWidget(RenamedNyStatePage());

      final state = tester.state<_AnUnrelatedName>(
        find.byType(RenamedNyStatePage),
      );

      expect(state.stateName, RenamedNyStatePage.path.stateName());
    });

    nyWidgetTest('keeps the name given to the state', (tester) async {
      await tester.pumpNyWidget(StateNamedPage());

      final state = tester.state<_StateNamedPageState>(
        find.byType(StateNamedPage),
      );

      expect(state.stateName, StateNamedPage.stateKey);
    });
  });

  nyGroup('NyState with a singleton controller', () {
    nyWidgetTest('each page listens on its own name', (tester) async {
      await tester.pumpNyWidget(SharedControllerPageA());
      final pageA = tester.state<_SharedControllerPageAState>(
        find.byType(SharedControllerPageA),
      );
      expect(pageA.stateName, SharedControllerPageA.path.stateName());

      await tester.pumpNyWidget(SharedControllerPageB());
      final pageB = tester.state<_SharedControllerPageBState>(
        find.byType(SharedControllerPageB),
      );
      expect(pageB.stateName, SharedControllerPageB.path.stateName());
    });

    nyWidgetTest('the controller points at the page it is used from', (
      tester,
    ) async {
      await tester.pumpNyWidget(SharedControllerPageA());
      await tester.pumpNyWidget(SharedControllerPageB());

      final pageB = tester.state<_SharedControllerPageBState>(
        find.byType(SharedControllerPageB),
      );
      final controller = (pageB.widget as NyStatefulWidget).controller;

      /// The controller carries page A's name until page B replaces it, and a
      /// stale name here sends `controller.refreshPage()` to the wrong page.
      expect(controller.state, SharedControllerPageB.path.stateName());
    });
  });
}
