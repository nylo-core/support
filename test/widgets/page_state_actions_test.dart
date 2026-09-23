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

UpdateState _lastEvent() {
  final EventBus eventBus = Backpack.instance.read('event_bus')!;
  return eventBus.history.last.event as UpdateState;
}

/// The shape Metro scaffolds: one declared line gives `CounterPage.actions`.
class CounterPage extends NyStatefulWidget {
  static RouteView path = ("/counter", (_) => CounterPage());
  static final actions = path.actions;

  CounterPage({super.key}) : super(child: () => _CounterPageState());
}

/// No `stateManaged` override: a page listens by default.
class _CounterPageState extends NyPage<CounterPage> {
  int count = 0;
  int inits = 0;
  String? toastDescription;
  String? toastId;
  Duration? toastDuration;

  @override
  get init => () {
    inits++;
  };

  @override
  Map<Object, Function> get stateActions => {
    'bump': () => count++,
    'add': (int by) => count += by,
  };

  /// Captures the toast instead of rendering it, which needs an overlay.
  @override
  void showToastCustom({
    String? title,
    String? description,
    String? id,
    Map<String, dynamic>? data,
    Duration? duration,
  }) {
    toastDescription = description;
    toastId = id;
    toastDuration = duration;
  }

  @override
  Widget view(BuildContext context) => Text('count $count');
}

/// A page that opts out of state updates.
class OptedOutPage extends NyStatefulWidget {
  static RouteView path = ("/opted-out", (_) => OptedOutPage());
  static final actions = path.actions;

  OptedOutPage({super.key}) : super(child: () => _OptedOutPageState());
}

class _OptedOutPageState extends NyPage<OptedOutPage> {
  int count = 0;

  @override
  bool get stateManaged => false;

  @override
  Map<Object, Function> get stateActions => {'bump': () => count++};

  @override
  Widget view(BuildContext context) => Text('opted out $count');
}

/// Typed actions: the methods have no body, `PageStateActions.noSuchMethod`
/// sends each one under its own symbol.
class LogoActions extends PageStateActions {
  LogoActions(super.state);

  void shake({int times = 1, String axis = 'x'});
  void setStars(int stars);
  void notRegistered();

  /// A bodiless getter is not an action.
  int get broken;
}

class LogoPage extends NyStatefulWidget {
  static RouteView path = ("/logo", (_) => LogoPage());
  static final actions = LogoActions(path);

  LogoPage({super.key}) : super(child: () => _LogoPageState());
}

class _LogoPageState extends NyPage<LogoPage> {
  int shakes = 0;
  String axis = '';
  int stars = 0;
  int legacy = 0;

  @override
  Map<Object, Function> get stateActions => {
    #shake: shake,
    #setStars: setStars,
    'legacy': () => legacy++,
  };

  void shake({int times = 1, String axis = 'x'}) {
    shakes += times;
    this.axis = axis;
  }

  void setStars(int stars) => this.stars = stars;

  @override
  Widget view(BuildContext context) =>
      Text('shakes $shakes $axis stars $stars legacy $legacy');
}

/// A state managed widget with several instances, reached by id.
class CartActions extends PageStateActions {
  CartActions(super.state, {super.id});

  void add(int count);
}

class Cart extends NyStateManaged {
  Cart({super.key, super.id})
    : super(baseState: state, child: () => _CartState());

  static const String state = 'cart';

  static CartActions actions({String? id}) => CartActions(state, id: id);
}

class _CartState extends NyState<Cart> {
  int items = 0;

  @override
  Map<Object, Function> get stateActions => {#add: add};

  void add(int count) => items += count;

  @override
  Widget view(BuildContext context) =>
      Text('cart ${widget.id} items $items', textDirection: TextDirection.ltr);
}

void main() {
  NyTest.init();

  setUp(() {
    _initNylo();
  });

  nyGroup('PageStateActions', () {
    nyTest('targets the state name a route resolves to', () async {
      expect(
        PageStateActions(CounterPage.path).state,
        CounterPage.path.stateName(),
      );
    });

    nyTest('keeps a state name given as a string', () async {
      expect(PageStateActions('declared-name').state, 'declared-name');
    });

    nyTest('appends an id the way stateAction does', () async {
      expect(PageStateActions('cart', id: 'a').state, 'cart_a');
    });

    nyTest('rejects anything but a route or a name', () async {
      expect(() => PageStateActions(42), throwsArgumentError);
    });

    nyTest('path.actions and the page\'s static reach the same name', () async {
      expect(CounterPage.path.actions.state, CounterPage.path.stateName());
      expect(CounterPage.actions.state, CounterPage.path.stateName());
    });
  });

  nyGroup('StateActions.call', () {
    nyTest('fires the named action with its data', () async {
      CounterPage.actions.call('add', 3);

      final event = _lastEvent();
      expect(event.stateName, CounterPage.path.stateName());
      expect(event.data, {'action': 'add', 'data': 3});
    });

    nyTest('makes the actions object callable', () async {
      CounterPage.actions('bump');

      expect(_lastEvent().data, {'action': 'bump', 'data': null});
    });
  });

  nyGroup('a page receiving actions', () {
    nyWidgetTest('listens without a stateManaged override', (tester) async {
      await tester.pumpNyWidget(CounterPage());
      expect(find.text('count 0'), findsOneWidget);

      CounterPage.actions.call('bump');
      await tester.pumpAndSettle();

      expect(find.text('count 1'), findsOneWidget);
    });

    nyWidgetTest('passes the data to a handler that takes it', (tester) async {
      await tester.pumpNyWidget(CounterPage());

      CounterPage.actions.call('add', 5);
      await tester.pumpAndSettle();

      expect(find.text('count 5'), findsOneWidget);
    });

    nyWidgetTest('showToast carries the description, style and duration', (
      tester,
    ) async {
      await tester.pumpNyWidget(CounterPage());

      CounterPage.actions.showToast(
        'hello',
        id: 'info',
        duration: const Duration(seconds: 2),
      );
      await tester.pumpAndSettle();

      final state = tester.state<_CounterPageState>(find.byType(CounterPage));
      expect(state.toastDescription, 'hello');
      expect(state.toastId, 'info');
      expect(state.toastDuration, const Duration(seconds: 2));
    });

    nyWidgetTest('refreshPage re-runs init', (tester) async {
      await tester.pumpNyWidget(CounterPage());
      final state = tester.state<_CounterPageState>(find.byType(CounterPage));
      expect(state.inits, 1);

      CounterPage.actions.refreshPage();
      await tester.pumpAndSettle();

      expect(state.inits, 2);
    });

    nyWidgetTest('the deprecated path.stateRefresh() reaches the page', (
      tester,
    ) async {
      await tester.pumpNyWidget(CounterPage());
      final state = tester.state<_CounterPageState>(find.byType(CounterPage));

      // ignore: deprecated_member_use_from_same_package
      CounterPage.path.stateRefresh();
      await tester.pumpAndSettle();

      expect(state.inits, 2);
    });

    nyWidgetTest('a page that opts out receives nothing', (tester) async {
      await tester.pumpNyWidget(OptedOutPage());

      OptedOutPage.actions.call('bump');
      await tester.pumpAndSettle();

      expect(find.text('opted out 0'), findsOneWidget);
    });
  });

  nyGroup('typed actions', () {
    nyWidgetTest('a bodiless method reaches the handler under its symbol', (
      tester,
    ) async {
      await tester.pumpNyWidget(LogoPage());

      LogoPage.actions.shake(times: 3, axis: 'y');
      await tester.pumpAndSettle();

      expect(find.text('shakes 3 y stars 0 legacy 0'), findsOneWidget);
    });

    nyWidgetTest('sends the defaults when arguments are omitted', (
      tester,
    ) async {
      await tester.pumpNyWidget(LogoPage());

      LogoPage.actions.shake();
      await tester.pumpAndSettle();

      expect(find.text('shakes 1 x stars 0 legacy 0'), findsOneWidget);
    });

    nyWidgetTest('passes positional arguments', (tester) async {
      await tester.pumpNyWidget(LogoPage());

      LogoPage.actions.setStars(1204);
      await tester.pumpAndSettle();

      expect(find.text('shakes 0  stars 1204 legacy 0'), findsOneWidget);
    });

    nyWidgetTest('string and symbol keys share one map', (tester) async {
      await tester.pumpNyWidget(LogoPage());

      LogoPage.actions.call('legacy');
      LogoPage.actions.shake();
      await tester.pumpAndSettle();

      expect(find.text('shakes 1 x stars 0 legacy 1'), findsOneWidget);
    });

    nyWidgetTest('an unregistered method is reported and throws nothing', (
      tester,
    ) async {
      final List<NyLogEntry> logged = [];
      NyLogger.onLog = logged.add;
      addTearDown(() => NyLogger.onLog = null);

      await tester.pumpNyWidget(LogoPage());

      LogoPage.actions.notRegistered();
      await tester.pumpAndSettle();

      expect(logged, hasLength(1));
      expect(logged.single.type, 'error');
      expect(logged.single.message, contains('notRegistered'));
      expect(logged.single.message, contains('_LogoPageState'));
    });

    nyTest('a bodiless getter is not an action', () async {
      expect(() => LogoPage.actions.broken, throwsNoSuchMethodError);
    });

    nyWidgetTest('reaches one instance of a state managed widget by id', (
      tester,
    ) async {
      await tester.pumpWidget(
        Column(
          children: [
            Cart(id: 'a'),
            Cart(id: 'b'),
          ],
        ),
      );

      Cart.actions(id: 'b').add(3);
      await tester.pumpAndSettle();

      expect(find.text('cart a items 0'), findsOneWidget);
      expect(find.text('cart b items 3'), findsOneWidget);
    });
  });
}
