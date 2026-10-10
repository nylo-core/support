import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/event_bus/ny_event_bus.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';

/// A tab page that records every `initState` in a static counter.
class _CountingPage extends StatefulWidget {
  const _CountingPage(this.label);

  final String label;

  static int initialised = 0;
  static final List<String> order = [];

  static void resetCounters() {
    initialised = 0;
    order.clear();
  }

  @override
  State<_CountingPage> createState() => _CountingPageState();
}

class _CountingPageState extends State<_CountingPage> {
  @override
  void initState() {
    super.initState();
    _CountingPage.initialised++;
    _CountingPage.order.add(widget.label);
  }

  @override
  Widget build(BuildContext context) => Text('${widget.label} page');
}

Map<int, NavigationTab> _threeTabs() => {
  0: NavigationTab.tab(
    title: "One",
    page: const _CountingPage('one'),
    icon: const Icon(Icons.looks_one),
  ),
  1: NavigationTab.tab(
    title: "Two",
    page: const _CountingPage('two'),
    icon: const Icon(Icons.looks_two),
  ),
  2: NavigationTab.tab(
    title: "Three",
    page: const _CountingPage('three'),
    icon: const Icon(Icons.looks_3),
  ),
};

/// Bottom-nav hub with lazy tab loading enabled.
class LazyBottomHub extends NyStatefulWidget {
  LazyBottomHub({super.key}) : super(child: () => _LazyBottomHubState());
}

class _LazyBottomHubState extends NavigationHub<LazyBottomHub> {
  _LazyBottomHubState() : super(_threeTabs);

  @override
  bool get lazyLoadTabs => true;

  @override
  NavigationHubLayout? layout(BuildContext context) =>
      NavigationHubLayout.bottomNav();
}

/// Bottom-nav hub with the default (eager) tab loading.
class EagerBottomHub extends NyStatefulWidget {
  EagerBottomHub({super.key}) : super(child: () => _EagerBottomHubState());
}

class _EagerBottomHubState extends NavigationHub<EagerBottomHub> {
  _EagerBottomHubState() : super(_threeTabs);

  @override
  NavigationHubLayout? layout(BuildContext context) =>
      NavigationHubLayout.bottomNav();
}

/// Top-nav hub with lazy tab loading enabled.
class LazyTopHub extends NyStatefulWidget {
  LazyTopHub({super.key}) : super(child: () => _LazyTopHubState());
}

class _LazyTopHubState extends NavigationHub<LazyTopHub> {
  _LazyTopHubState() : super(_threeTabs);

  @override
  bool get lazyLoadTabs => true;

  @override
  NavigationHubLayout? layout(BuildContext context) =>
      NavigationHubLayout.topNav();
}

/// Lazy hub that starts on the middle tab.
class LazyInitialIndexHub extends NyStatefulWidget {
  LazyInitialIndexHub({super.key})
    : super(child: () => _LazyInitialIndexHubState());
}

class _LazyInitialIndexHubState extends NavigationHub<LazyInitialIndexHub> {
  _LazyInitialIndexHubState() : super(_threeTabs);

  @override
  bool get lazyLoadTabs => true;

  @override
  int get initialIndex => 1;

  @override
  NavigationHubLayout? layout(BuildContext context) =>
      NavigationHubLayout.bottomNav();
}

void _initNylo() {
  NyEnvRegistry.register(
    getter: (String key, {dynamic defaultValue}) => defaultValue,
    containsKey: (String key) => false,
  );
  if (!Backpack.instance.isNyloInitialized()) {
    Backpack.instance.save("nylo", Nylo());
  }
  Backpack.instance.save("event_bus", EventBus(maxHistoryLength: 10));
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  NyTest.init();

  setUp(() {
    _initNylo();
    _CountingPage.resetCounters();
  });

  nyGroup('NavigationHub lazyLoadTabs', () {
    nyWidgetTest('mounts only the selected tab until others are visited', (
      tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: LazyBottomHub()));
      await _settle(tester);

      expect(_CountingPage.initialised, 1);
      expect(_CountingPage.order, ['one']);
      // Slot count stays stable: three IndexedStack children.
      final IndexedStack stack = tester.widget<IndexedStack>(
        find.byType(IndexedStack),
      );
      expect(stack.children.length, 3);

      await tester.tap(find.text('Two'));
      await _settle(tester);

      expect(_CountingPage.initialised, 2);
      expect(_CountingPage.order, ['one', 'two']);
      expect(find.text('two page'), findsOneWidget);

      // Going back to a visited tab must not re-create it.
      await tester.tap(find.text('One'));
      await _settle(tester);

      expect(_CountingPage.initialised, 2);
      expect(find.text('one page'), findsOneWidget);
      // The never-visited tab is still a placeholder.
      expect(find.text('three page'), findsNothing);
    });

    nyWidgetTest('visited tabs stay alive when returning to them', (
      tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: LazyBottomHub()));
      await _settle(tester);

      await tester.tap(find.text('Three'));
      await _settle(tester);
      await tester.tap(find.text('Two'));
      await _settle(tester);
      await tester.tap(find.text('Three'));
      await _settle(tester);
      await tester.tap(find.text('One'));
      await _settle(tester);

      expect(_CountingPage.initialised, 3);
      expect(_CountingPage.order, ['one', 'three', 'two']);
    });

    nyWidgetTest('respects initialIndex', (tester) async {
      await tester.pumpWidget(MaterialApp(home: LazyInitialIndexHub()));
      await _settle(tester);

      expect(_CountingPage.initialised, 1);
      expect(_CountingPage.order, ['two']);
      expect(find.text('two page'), findsOneWidget);
    });

    nyWidgetTest('applies to the topNav layout too', (tester) async {
      await tester.pumpWidget(MaterialApp(home: LazyTopHub()));
      await _settle(tester);

      expect(_CountingPage.initialised, 1);
      expect(_CountingPage.order, ['one']);

      await tester.tap(find.text('Three'));
      await _settle(tester);

      expect(_CountingPage.initialised, 2);
      expect(_CountingPage.order, ['one', 'three']);
    });
  });

  nyGroup('NavigationHub default (eager) tab loading', () {
    nyWidgetTest('initialises every tab on the first frame', (tester) async {
      await tester.pumpWidget(MaterialApp(home: EagerBottomHub()));
      await _settle(tester);

      expect(_CountingPage.initialised, 3);
      expect(_CountingPage.order, ['one', 'two', 'three']);

      await tester.tap(find.text('Two'));
      await _settle(tester);

      expect(_CountingPage.initialised, 3);
    });
  });
}
