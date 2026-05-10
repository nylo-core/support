import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/event_bus/ny_event_bus.dart';
import 'package:nylo_support/helpers/src/backpack.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

/// Helper to initialize Nylo for widget tests that use NyState.
void _initNylo() {
  if (!Backpack.instance.isNyloInitialized()) {
    Backpack.instance.save("nylo", Nylo());
  }
  // Fresh EventBus per test so state-action events do not leak between tests.
  Backpack.instance.save("event_bus", EventBus(maxHistoryLength: 10));
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

    nyGroup('type coercion', () {
      // API responses (and JSON-decoded payloads) commonly arrive as
      // `List<dynamic>` even when each element is `Map<String, dynamic>`. The
      // widget must cast lazily so callers don't have to call `.cast<T>()`
      // themselves.
      testWidgets('casts List<dynamic> to List<T> for sync data', (
        tester,
      ) async {
        // Simulate an API response: return type is dynamic, runtime value is
        // List<dynamic> with Map<String, dynamic> elements.
        dynamic apiResponse() => <dynamic>[
          {'title': 'First'},
          {'title': 'Second'},
        ];

        await tester.pumpWidget(
          _app(
            CollectionView<Map<String, dynamic>>(
              data: () => apiResponse(),
              builder: (context, item) => Text(item.data['title']),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('First'), findsOneWidget);
        expect(find.text('Second'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('casts List<dynamic> to List<T> for async data', (
        tester,
      ) async {
        Future<dynamic> apiResponse() async => <dynamic>[
          {'title': 'AsyncOne'},
          {'title': 'AsyncTwo'},
        ];

        await tester.pumpWidget(
          _app(
            CollectionView<Map<String, dynamic>>(
              data: () => apiResponse(),
              builder: (context, item) => Text(item.data['title']),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('AsyncOne'), findsOneWidget);
        expect(find.text('AsyncTwo'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets(
        'casts List<dynamic> to List<T> for pullable paginated data',
        (tester) async {
          Future<dynamic> apiResponse(int page) async => <dynamic>[
            {'title': 'P${page}A'},
            {'title': 'P${page}B'},
          ];

          await tester.pumpWidget(
            _app(
              CollectionView<Map<String, dynamic>>.pullable(
                data: (page) => apiResponse(page),
                builder: (context, item) => Text(item.data['title']),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('P1A'), findsOneWidget);
          expect(find.text('P1B'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
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

    nyGroup('pullable - render', () {
      testWidgets('renders items from sync paginated data', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>.pullable(
              data: (page) => ['A', 'B', 'C'],
              builder: (context, item) => Text(item.data),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('A'), findsOneWidget);
        expect(find.text('B'), findsOneWidget);
        expect(find.text('C'), findsOneWidget);
        expect(find.byType(SmartRefresher), findsOneWidget);
      });

      testWidgets('renders items from async paginated data', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>.pullable(
              data: (page) async => ['X', 'Y'],
              builder: (context, item) => Text(item.data),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('X'), findsOneWidget);
        expect(find.text('Y'), findsOneWidget);
      });

      testWidgets('shows empty widget when paginated data is empty', (
        tester,
      ) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>.pullable(
              data: (page) => <String>[],
              builder: (context, item) => Text(item.data),
              empty: const Text('Nothing here'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Nothing here'), findsOneWidget);
      });

      testWidgets('renders header above items', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>.pullable(
              data: (page) => ['Item'],
              builder: (context, item) => Text(item.data),
              header: const Text('Header'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Header'), findsOneWidget);
        expect(find.text('Item'), findsOneWidget);
      });

      testWidgets('renders header above empty widget', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>.pullable(
              data: (page) => <String>[],
              builder: (context, item) => Text(item.data),
              empty: const Text('Empty'),
              header: const Text('Header'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Header'), findsOneWidget);
        expect(find.text('Empty'), findsOneWidget);
      });

      testWidgets('handles null returned from paginated data', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>.pullable(
              data: (page) => null,
              builder: (context, item) => Text(item.data),
              empty: const Text('Empty'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Empty'), findsOneWidget);
      });
    });

    nyGroup('pullableSeparated', () {
      testWidgets('renders items with separators', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>.pullableSeparated(
              data: (page) => ['One', 'Two'],
              builder: (context, item) => Text(item.data),
              separatorBuilder: (context, index) =>
                  const Divider(key: Key('sep')),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('One'), findsOneWidget);
        expect(find.text('Two'), findsOneWidget);
        expect(find.byKey(const Key('sep')), findsWidgets);
      });
    });

    nyGroup('pullableGrid', () {
      testWidgets('renders items in grid layout', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>.pullableGrid(
              data: (page) => ['A', 'B', 'C', 'D'],
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
    });

    nyGroup('pull-to-refresh (_onRefresh)', () {
      testWidgets(
        'refresh does not crash when list has many items (regression)',
        (tester) async {
          // Regression: previously _onRefresh set `_data = []` synchronously
          // before the await, leaving the live ListView pointing at an empty
          // list mid-frame. SliverList would relayout cached children at index
          // 13 and itemBuilder would throw RangeError. The fix only mutates
          // _data inside setState after the new data resolves.
          int call = 0;
          await tester.pumpWidget(
            _app(
              CollectionView<String>.pullable(
                data: (page) async {
                  call++;
                  return List.generate(20, (i) => 'Item$call-$i');
                },
                builder: (context, item) =>
                    SizedBox(height: 30, child: Text(item.data)),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('Item1-0'), findsOneWidget);

          final refresher = tester.widget<SmartRefresher>(
            find.byType(SmartRefresher),
          );
          refresher.controller.requestRefresh();
          await tester.pumpAndSettle(const Duration(seconds: 2));

          expect(tester.takeException(), isNull);
          expect(find.text('Item2-0'), findsOneWidget);
        },
      );

      testWidgets(
        'beforeRefresh, fetch, afterRefresh, onRefresh fire in order',
        (tester) async {
          final calls = <String>[];

          await tester.pumpWidget(
            _app(
              CollectionView<String>.pullable(
                data: (page) async {
                  calls.add('fetch');
                  return ['Item'];
                },
                beforeRefresh: () async {
                  calls.add('before');
                },
                afterRefresh: (data) {
                  calls.add('after');
                  return data;
                },
                onRefresh: () async {
                  calls.add('onRefresh');
                },
                builder: (context, item) => Text(item.data),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Initial load fires `fetch` only (not the refresh hooks).
          expect(calls, ['fetch']);
          calls.clear();

          final refresher = tester.widget<SmartRefresher>(
            find.byType(SmartRefresher),
          );
          refresher.controller.requestRefresh();
          await tester.pumpAndSettle(const Duration(seconds: 2));

          expect(calls, ['before', 'fetch', 'after', 'onRefresh']);
        },
      );

      testWidgets('afterRefresh can transform the list', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>.pullable(
              data: (page) async => ['raw'],
              afterRefresh: (data) => ['transformed'],
              builder: (context, item) => Text(item.data),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('raw'), findsOneWidget);

        final refresher = tester.widget<SmartRefresher>(
          find.byType(SmartRefresher),
        );
        refresher.controller.requestRefresh();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(find.text('transformed'), findsOneWidget);
        expect(find.text('raw'), findsNothing);
      });

      testWidgets(
        'null result from refresh preserves data and settles indicator',
        (tester) async {
          bool returnNull = false;
          await tester.pumpWidget(
            _app(
              CollectionView<String>.pullable(
                data: (page) async => returnNull ? null : ['Initial'],
                builder: (context, item) => Text(item.data),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('Initial'), findsOneWidget);

          returnNull = true;
          final refresher = tester.widget<SmartRefresher>(
            find.byType(SmartRefresher),
          );
          refresher.controller.requestRefresh();
          await tester.pumpAndSettle(const Duration(seconds: 2));

          expect(tester.takeException(), isNull);
          // Existing data preserved when refresh returns null.
          expect(find.text('Initial'), findsOneWidget);
        },
      );
    });

    nyGroup('pagination (_onLoading)', () {
      testWidgets('load more appends new data', (tester) async {
        int requestedPage = 0;
        await tester.pumpWidget(
          _app(
            CollectionView<String>.pullable(
              data: (page) async {
                requestedPage = page;
                if (page == 1) return ['P1A', 'P1B'];
                return ['P2A', 'P2B'];
              },
              builder: (context, item) =>
                  SizedBox(height: 30, child: Text(item.data)),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(requestedPage, 1);

        final refresher = tester.widget<SmartRefresher>(
          find.byType(SmartRefresher),
        );
        refresher.controller.requestLoading();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(requestedPage, 2);
        expect(find.text('P1A'), findsOneWidget);
        expect(find.text('P2A'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('empty result on load more does not crash', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>.pullable(
              data: (page) async => page == 1 ? ['First'] : <String>[],
              builder: (context, item) =>
                  SizedBox(height: 30, child: Text(item.data)),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final refresher = tester.widget<SmartRefresher>(
          find.byType(SmartRefresher),
        );
        refresher.controller.requestLoading();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(tester.takeException(), isNull);
        expect(find.text('First'), findsOneWidget);
      });

      testWidgets('null result on load more does not crash', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>.pullable(
              data: (page) async => page == 1 ? ['First'] : null,
              builder: (context, item) =>
                  SizedBox(height: 30, child: Text(item.data)),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final refresher = tester.widget<SmartRefresher>(
          find.byType(SmartRefresher),
        );
        refresher.controller.requestLoading();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(tester.takeException(), isNull);
        expect(find.text('First'), findsOneWidget);
      });
    });

    nyGroup('stateActions', () {
      testWidgets('addItem appends to the list', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>(
              stateName: 'list_add',
              data: () => ['A', 'B'],
              builder: (context, item) => Text(item.data),
            ),
          ),
        );
        await tester.pumpAndSettle();

        CollectionView.stateActions('list_add').addItem('C');
        await tester.pumpAndSettle();

        expect(find.text('A'), findsOneWidget);
        expect(find.text('B'), findsOneWidget);
        expect(find.text('C'), findsOneWidget);
      });

      testWidgets('insertItem inserts at the given index', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>(
              stateName: 'list_insert',
              data: () => ['A', 'C'],
              builder: (context, item) => Text('${item.index}:${item.data}'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        CollectionView.stateActions('list_insert').insertItem(1, 'B');
        await tester.pumpAndSettle();

        expect(find.text('0:A'), findsOneWidget);
        expect(find.text('1:B'), findsOneWidget);
        expect(find.text('2:C'), findsOneWidget);
      });

      testWidgets('insertItem clamps an out-of-range index', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>(
              stateName: 'list_insert_clamp',
              data: () => ['A'],
              builder: (context, item) => Text('${item.index}:${item.data}'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        CollectionView.stateActions('list_insert_clamp').insertItem(99, 'B');
        await tester.pumpAndSettle();

        expect(find.text('0:A'), findsOneWidget);
        expect(find.text('1:B'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('updateItemAtIndex replaces the item', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>(
              stateName: 'list_update',
              data: () => ['A', 'B', 'C'],
              builder: (context, item) => Text(item.data),
            ),
          ),
        );
        await tester.pumpAndSettle();

        CollectionView.stateActions('list_update').updateItemAtIndex(1, 'BB');
        await tester.pumpAndSettle();

        expect(find.text('A'), findsOneWidget);
        expect(find.text('B'), findsNothing);
        expect(find.text('BB'), findsOneWidget);
        expect(find.text('C'), findsOneWidget);
      });

      testWidgets('updateItemAtIndex out-of-range is a no-op', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>(
              stateName: 'list_update_oor',
              data: () => ['A'],
              builder: (context, item) => Text(item.data),
            ),
          ),
        );
        await tester.pumpAndSettle();

        CollectionView.stateActions(
          'list_update_oor',
        ).updateItemAtIndex(99, 'X');
        await tester.pumpAndSettle();

        expect(find.text('A'), findsOneWidget);
        expect(find.text('X'), findsNothing);
        expect(tester.takeException(), isNull);
      });

      testWidgets('removeFromIndex removes the item', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>(
              stateName: 'list_remove',
              data: () => ['A', 'B', 'C'],
              builder: (context, item) => Text(item.data),
            ),
          ),
        );
        await tester.pumpAndSettle();

        CollectionView.stateActions('list_remove').removeFromIndex(1);
        await tester.pumpAndSettle();

        expect(find.text('A'), findsOneWidget);
        expect(find.text('B'), findsNothing);
        expect(find.text('C'), findsOneWidget);
      });

      testWidgets('removeFromIndex out-of-range is a no-op', (tester) async {
        await tester.pumpWidget(
          _app(
            CollectionView<String>(
              stateName: 'list_remove_oor',
              data: () => ['A'],
              builder: (context, item) => Text(item.data),
            ),
          ),
        );
        await tester.pumpAndSettle();

        CollectionView.stateActions('list_remove_oor').removeFromIndex(99);
        await tester.pumpAndSettle();

        expect(find.text('A'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('refreshData re-invokes the data callback', (tester) async {
        int call = 0;
        await tester.pumpWidget(
          _app(
            CollectionView<String>(
              stateName: 'list_refresh',
              data: () {
                call++;
                return ['Call$call'];
              },
              builder: (context, item) => Text(item.data),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(call, 1);
        expect(find.text('Call1'), findsOneWidget);

        CollectionView.stateActions('list_refresh').refreshData();
        await tester.pumpAndSettle();

        expect(call, 2);
        expect(find.text('Call2'), findsOneWidget);
        expect(find.text('Call1'), findsNothing);
      });

      testWidgets('reset clears data and re-fetches', (tester) async {
        int call = 0;
        await tester.pumpWidget(
          _app(
            CollectionView<String>(
              stateName: 'list_reset',
              data: () {
                call++;
                return ['Call$call'];
              },
              builder: (context, item) => Text(item.data),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(call, 1);
        expect(find.text('Call1'), findsOneWidget);

        CollectionView.stateActions('list_reset').reset();
        await tester.pumpAndSettle();

        expect(call, 2);
        expect(find.text('Call2'), findsOneWidget);
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
