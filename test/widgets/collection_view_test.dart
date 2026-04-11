import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/src/backpack.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';

/// Helper to initialize Nylo for widget tests that use NyState.
void _initNylo() {
  if (!Backpack.instance.isNyloInitialized()) {
    Backpack.instance.save("nylo", Nylo());
  }
}

/// Helper to wrap a widget in MaterialApp with bounded height for ListView.
Widget _app(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SizedBox(height: 600, width: 400, child: child)),
  );
}

void main() {
  NyTest.init();

  setUp(() {
    _initNylo();
  });

  nyGroup('CollectionItem', () {
    nyTest('stores data, index, and totalItems', () async {
      final item = CollectionItem<String>(
        data: 'hello',
        index: 2,
        totalItems: 5,
      );

      expect(item.data, 'hello');
      expect(item.index, 2);
      expect(item.totalItems, 5);
    });

    nyTest('isFirst returns true only for index 0', () async {
      final first = CollectionItem<int>(data: 1, index: 0, totalItems: 3);
      final second = CollectionItem<int>(data: 2, index: 1, totalItems: 3);

      expect(first.isFirst, true);
      expect(second.isFirst, false);
    });

    nyTest('isLast returns true only for last index', () async {
      final last = CollectionItem<int>(data: 3, index: 2, totalItems: 3);
      final notLast = CollectionItem<int>(data: 2, index: 1, totalItems: 3);

      expect(last.isLast, true);
      expect(notLast.isLast, false);
    });

    nyTest('isOdd and isEven check index parity', () async {
      final even = CollectionItem<int>(data: 0, index: 0, totalItems: 4);
      final odd = CollectionItem<int>(data: 1, index: 1, totalItems: 4);

      expect(even.isEven, true);
      expect(even.isOdd, false);
      expect(odd.isOdd, true);
      expect(odd.isEven, false);
    });

    nyTest('isAt checks specific position', () async {
      final item = CollectionItem<int>(data: 1, index: 3, totalItems: 5);

      expect(item.isAt(3), true);
      expect(item.isAt(0), false);
    });

    nyTest('isInRange checks inclusive range', () async {
      final item = CollectionItem<int>(data: 1, index: 3, totalItems: 10);

      expect(item.isInRange(2, 5), true);
      expect(item.isInRange(3, 3), true);
      expect(item.isInRange(0, 2), false);
      expect(item.isInRange(4, 6), false);
    });

    nyTest('isMultipleOf checks divisibility', () async {
      final item0 = CollectionItem<int>(data: 0, index: 0, totalItems: 10);
      final item3 = CollectionItem<int>(data: 3, index: 3, totalItems: 10);
      final item6 = CollectionItem<int>(data: 6, index: 6, totalItems: 10);

      expect(item0.isMultipleOf(3), true);
      expect(item3.isMultipleOf(3), true);
      expect(item6.isMultipleOf(3), true);
      expect(item6.isMultipleOf(4), false);
    });

    nyTest('progress returns 0.0 to 1.0', () async {
      final first = CollectionItem<int>(data: 0, index: 0, totalItems: 5);
      final middle = CollectionItem<int>(data: 2, index: 2, totalItems: 5);
      final last = CollectionItem<int>(data: 4, index: 4, totalItems: 5);

      expect(first.progress, 0.0);
      expect(middle.progress, 0.5);
      expect(last.progress, 1.0);
    });

    nyTest('progress returns 0.0 for single item', () async {
      final single = CollectionItem<int>(data: 0, index: 0, totalItems: 1);

      expect(single.progress, 0.0);
    });
  });

  nyGroup('CollectionView', () {
    nyGroup('builder (sync data)', () {
      testWidgets('renders items from sync data callback', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>(
              data: () => ['Apple', 'Banana', 'Cherry'],
              builder: (context, item) => Text(item.data),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Apple'), findsOneWidget);
        expect(find.text('Banana'), findsOneWidget);
        expect(find.text('Cherry'), findsOneWidget);
      });

      testWidgets('shows empty widget when data is empty', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>(
              data: () => <String>[],
              builder: (context, item) => Text(item.data),
              empty: const Text('Nothing here'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Nothing here'), findsOneWidget);
      });

      testWidgets('shows default empty widget when no custom empty provided', (
        tester,
      ) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>(
              data: () => <String>[],
              builder: (context, item) => Text(item.data),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // .tr() returns the key when localization is not initialized
        expect(find.text('nylo.collection_view.no_results'), findsOneWidget);
      });

      testWidgets('renders header before items', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>(
              data: () => ['Item 1'],
              builder: (context, item) => Text(item.data),
              header: const Text('My Header'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('My Header'), findsOneWidget);
        expect(find.text('Item 1'), findsOneWidget);
      });

      testWidgets('applies spacing between items', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>(
              data: () => ['A', 'B', 'C'],
              builder: (context, item) => Text(item.data),
              spacing: 12,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // All items should render
        expect(find.text('A'), findsOneWidget);
        expect(find.text('B'), findsOneWidget);
        expect(find.text('C'), findsOneWidget);

        // Spacing creates Padding widgets between items (not after last)
        final paddings = tester.widgetList<Padding>(find.byType(Padding));
        final spacingPaddings = paddings.where(
          (p) => p.padding == const EdgeInsets.only(bottom: 12),
        );
        // A and B get bottom padding, C (last) does not
        expect(spacingPaddings.length, 2);
      });
    });

    nyGroup('builder (async data)', () {
      testWidgets('renders items after async data loads', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>(
              data: () async {
                await Future.delayed(const Duration(milliseconds: 50));
                return ['Async Item 1', 'Async Item 2'];
              },
              builder: (context, item) => Text(item.data),
            ),
          ),
        );

        // Initially loading
        await tester.pump();

        // Wait for async data
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        expect(find.text('Async Item 1'), findsOneWidget);
        expect(find.text('Async Item 2'), findsOneWidget);
      });

      testWidgets('shows empty widget when async data returns empty', (
        tester,
      ) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>(
              data: () async {
                return <String>[];
              },
              builder: (context, item) => Text(item.data),
              empty: const Text('No data'),
            ),
          ),
        );

        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.text('No data'), findsOneWidget);
      });
    });

    nyGroup('transform and sort', () {
      testWidgets('applies transform to data', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>(
              data: () => ['apple', 'banana', 'cherry'],
              transform: (items) =>
                  items.where((s) => s.startsWith('a')).toList(),
              builder: (context, item) => Text(item.data),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('apple'), findsOneWidget);
        expect(find.text('banana'), findsNothing);
        expect(find.text('cherry'), findsNothing);
      });

      testWidgets('applies sort to data', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>(
              data: () => ['cherry', 'apple', 'banana'],
              sort: (items) => items..sort(),
              builder: (context, item) => Text(item.data),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // All items rendered
        expect(find.text('apple'), findsOneWidget);
        expect(find.text('banana'), findsOneWidget);
        expect(find.text('cherry'), findsOneWidget);
      });
    });

    nyGroup('separated', () {
      testWidgets('renders items with separators', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>.separated(
              data: () => ['One', 'Two', 'Three'],
              builder: (context, item) => Text(item.data),
              separatorBuilder: (context, index) => const Divider(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('One'), findsOneWidget);
        expect(find.text('Two'), findsOneWidget);
        expect(find.text('Three'), findsOneWidget);
        expect(find.byType(Divider), findsWidgets);
      });
    });

    nyGroup('grid', () {
      testWidgets('renders items in a grid layout', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>.grid(
              data: () => ['A', 'B', 'C', 'D'],
              crossAxisCount: 2,
              builder: (context, item) => Text(item.data),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('A'), findsOneWidget);
        expect(find.text('B'), findsOneWidget);
        expect(find.text('C'), findsOneWidget);
        expect(find.text('D'), findsOneWidget);
      });

      testWidgets('renders header spanning full grid width', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>.grid(
              data: () => ['A', 'B'],
              crossAxisCount: 2,
              builder: (context, item) => Text(item.data),
              header: const Text('Grid Header'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Grid Header'), findsOneWidget);
        expect(find.text('A'), findsOneWidget);
        expect(find.text('B'), findsOneWidget);
      });
    });

    nyGroup('parent-driven data updates (didUpdateWidget)', () {
      testWidgets('re-reads sync data when parent rebuilds with new data', (
        tester,
      ) async {
        // This tests the fix for the filtering regression.
        // When the parent widget updates _filteredLanguages and calls setState,
        // CollectionView should re-read the data callback.

        final controller = TextEditingController();

        await tester.pumpWidget(_app(_FilterableList(controller: controller)));
        await tester.pumpAndSettle();

        // All items visible initially
        expect(find.text('Apple'), findsOneWidget);
        expect(find.text('Banana'), findsOneWidget);
        expect(find.text('Cherry'), findsOneWidget);

        // Type 'Ban' to filter
        await tester.enterText(find.byType(TextField), 'Ban');
        await tester.pumpAndSettle();

        // Only Banana should be visible
        expect(find.text('Apple'), findsNothing);
        expect(find.text('Banana'), findsOneWidget);
        expect(find.text('Cherry'), findsNothing);

        // Clear filter
        await tester.enterText(find.byType(TextField), '');
        await tester.pumpAndSettle();

        // All items visible again
        expect(find.text('Apple'), findsOneWidget);
        expect(find.text('Banana'), findsOneWidget);
        expect(find.text('Cherry'), findsOneWidget);
      });

      testWidgets('shows empty widget when filter matches nothing', (
        tester,
      ) async {
        final controller = TextEditingController();

        await tester.pumpWidget(_app(_FilterableList(controller: controller)));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'xyz');
        await tester.pumpAndSettle();

        expect(find.text('No matches'), findsOneWidget);
      });
    });

    nyGroup('CollectionViewStateActions', () {
      nyTest('creates with state name', () async {
        final actions = CollectionView.stateActions('my_list');
        expect(actions.state, 'my_list');
      });
    });

    nyGroup('shrinkWrap and physics', () {
      testWidgets('respects shrinkWrap parameter', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>(
              data: () => ['A', 'B'],
              builder: (context, item) => Text(item.data),
              shrinkWrap: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('A'), findsOneWidget);
        expect(find.text('B'), findsOneWidget);
      });

      testWidgets('respects custom physics', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>(
              data: () => ['A'],
              builder: (context, item) => Text(item.data),
              physics: const NeverScrollableScrollPhysics(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('A'), findsOneWidget);
      });
    });

    nyGroup('scrollDirection', () {
      testWidgets('supports horizontal scrolling', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>(
              data: () => ['A', 'B', 'C'],
              builder: (context, item) =>
                  SizedBox(width: 100, child: Text(item.data)),
              scrollDirection: Axis.horizontal,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('A'), findsOneWidget);
      });
    });

    nyGroup('null data handling', () {
      testWidgets('handles null returned from sync data callback', (
        tester,
      ) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>(
              data: () => null,
              builder: (context, item) => Text(item.data),
              empty: const Text('Empty'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Empty'), findsOneWidget);
      });
    });

    nyGroup('builder item metadata', () {
      testWidgets('provides correct index and position info to builder', (
        tester,
      ) async {
        final List<String> labels = [];

        await tester.pumpWidget(
          _app(
            CollectionView<String>(
              data: () => ['A', 'B', 'C'],
              builder: (context, item) {
                String label = '${item.data}:${item.index}';
                if (item.isFirst) label += ':first';
                if (item.isLast) label += ':last';
                labels.add(label);
                return Text(label);
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('A:0:first'), findsOneWidget);
        expect(find.text('B:1'), findsOneWidget);
        expect(find.text('C:2:last'), findsOneWidget);
      });
    });
  });
}

/// Test helper widget that simulates parent-driven filtering (like the
/// native_language_widget pattern that was broken by the _syncDataInitialized
/// regression).
class _FilterableList extends StatefulWidget {
  final TextEditingController controller;

  const _FilterableList({required this.controller});

  @override
  State<_FilterableList> createState() => _FilterableListState();
}

class _FilterableListState extends State<_FilterableList> {
  final List<String> _allItems = ['Apple', 'Banana', 'Cherry'];
  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = _allItems;
    widget.controller.addListener(_onSearch);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSearch);
    super.dispose();
  }

  void _onSearch() {
    final query = widget.controller.text.toLowerCase();
    setState(() {
      _filteredItems = _allItems
          .where((item) => item.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(controller: widget.controller),
        Expanded(
          child: CollectionView<String>(
            data: () => _filteredItems,
            builder: (context, item) => Text(item.data),
            empty: const Text('No matches'),
          ),
        ),
      ],
    );
  }
}
