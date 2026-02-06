import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

/// Helper function to create an EnvGetter from a Map for testing
EnvGetter mockEnv(Map<String, dynamic> values) =>
    (String key, {dynamic defaultValue}) => values[key] ?? defaultValue;

void main() {
  NyTest.init();

  nySetUp(() {
    NyEnvRegistry.register(getter: mockEnv({'APP_DEBUG': true}));
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // NyListWidgetExt Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('NyListWidgetExt', () {
    nyGroup('withGap', () {
      nyTest('should add SizedBox gaps between widgets', () async {
        final widgets = <Widget>[Container(), Container(), Container()];

        final result = widgets.withGap(10.0);

        expect(result.length, 5); // 3 widgets + 2 gaps
        expect(result[1], isA<SizedBox>());
        expect(result[3], isA<SizedBox>());
      });

      nyTest('should create SizedBox with correct height', () async {
        final widgets = <Widget>[Container(), Container()];

        final result = widgets.withGap(20.0);
        final gap = result[1] as SizedBox;

        expect(gap.height, 20.0);
      });

      nyTest('should return empty list for empty input', () async {
        final widgets = <Widget>[];

        final result = widgets.withGap(10.0);

        expect(result, isEmpty);
      });

      nyTest('should return single widget without gaps', () async {
        final widgets = <Widget>[Container()];

        final result = widgets.withGap(10.0);

        expect(result.length, 1);
        expect(result[0], isA<Container>());
      });

      nyTest('should preserve original widget order', () async {
        final widgets = <Widget>[Text('First'), Text('Second'), Text('Third')];

        final result = widgets.withGap(10.0);

        expect((result[0] as Text).data, 'First');
        expect((result[2] as Text).data, 'Second');
        expect((result[4] as Text).data, 'Third');
      });

      nyTest('should handle zero gap', () async {
        final widgets = <Widget>[Container(), Container()];

        final result = widgets.withGap(0);
        final gap = result[1] as SizedBox;

        expect(gap.height, 0);
      });
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // NyListExt (nullable List) Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('NyListExt (List? extensions)', () {
    nyGroup('row', () {
      nyTest('should convert list to Row widget', () async {
        final List<Widget>? widgets = [Container(), Container()];

        final result = widgets.row();

        expect(result, isA<Row>());
        expect(result.children.length, 2);
      });

      nyTest('should support mainAxisAlignment parameter', () async {
        final List<Widget>? widgets = [Container()];

        final result = widgets.row(mainAxisAlignment: MainAxisAlignment.center);

        expect(result.mainAxisAlignment, MainAxisAlignment.center);
      });

      nyTest('should support crossAxisAlignment parameter', () async {
        final List<Widget>? widgets = [Container()];

        final result = widgets.row(
          crossAxisAlignment: CrossAxisAlignment.start,
        );

        expect(result.crossAxisAlignment, CrossAxisAlignment.start);
      });

      nyTest('should support mainAxisSize parameter', () async {
        final List<Widget>? widgets = [Container()];

        final result = widgets.row(mainAxisSize: MainAxisSize.min);

        expect(result.mainAxisSize, MainAxisSize.min);
      });
    });

    nyGroup('randomItem', () {
      nyTest('should return a random item from list', () async {
        final List? items = [1, 2, 3, 4, 5];

        final result = items.randomItem();

        expect(items, contains(result));
      });

      nyTest('should return null for null list', () async {
        List? nullList;

        final result = nullList.randomItem();

        expect(result, isNull);
      });

      nyTest('should return single item from single-item list', () async {
        final List? items = ['only'];

        final result = items.randomItem();

        expect(result, 'only');
      });

      nyTest('should work with different types', () async {
        final List? intList = [1, 2, 3];
        final List? stringList = ['a', 'b', 'c'];

        expect(intList, contains(intList.randomItem()));
        expect(stringList, contains(stringList.randomItem()));
      });
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // ListUpdateExtensionExt Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('ListUpdateExtensionExt', () {
    nyGroup('update', () {
      nyTest('should update items matching condition', () async {
        final list = [1, 2, 3, 4, 5];

        final result = list.update(
          (item) => item % 2 == 0,
          (item) => item * 10,
        );

        expect(result, [1, 20, 3, 40, 5]);
      });

      nyTest('should not modify original list', () async {
        final list = [1, 2, 3];

        list.update((item) => item == 2, (item) => 20);

        expect(list, [1, 2, 3]);
      });

      nyTest('should return new list', () async {
        final list = [1, 2, 3];

        final result = list.update((item) => item == 2, (item) => 20);

        expect(identical(list, result), isFalse);
      });

      nyTest('should handle empty list', () async {
        final list = <int>[];

        final result = list.update((item) => true, (item) => item * 2);

        expect(result, isEmpty);
      });

      nyTest('should handle no matches', () async {
        final list = [1, 2, 3];

        final result = list.update((item) => item > 10, (item) => item * 2);

        expect(result, [1, 2, 3]);
      });

      nyTest('should handle all matches', () async {
        final list = [2, 4, 6];

        final result = list.update((item) => item % 2 == 0, (item) => item + 1);

        expect(result, [3, 5, 7]);
      });

      nyTest('should work with objects', () async {
        final list = [
          {'id': 1, 'active': false},
          {'id': 2, 'active': false},
        ];

        final result = list.update(
          (item) => item['id'] == 2,
          (item) => {...item, 'active': true},
        );

        expect(result[0]['active'], isFalse);
        expect(result[1]['active'], isTrue);
      });
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // NyListGenericExt Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('NyListGenericExt', () {
    nyGroup('toggleValue', () {
      nyTest('should add value if not present', () async {
        final list = [1, 2, 3];

        list.toggleValue(4);

        expect(list, [1, 2, 3, 4]);
      });

      nyTest('should remove value if present', () async {
        final list = [1, 2, 3];

        list.toggleValue(2);

        expect(list, [1, 3]);
      });

      nyTest('should work with strings', () async {
        final list = ['a', 'b', 'c'];

        list.toggleValue('b');
        expect(list, ['a', 'c']);

        list.toggleValue('d');
        expect(list, ['a', 'c', 'd']);
      });

      nyTest('should work with empty list', () async {
        final list = <int>[];

        list.toggleValue(1);

        expect(list, [1]);
      });

      nyTest('should work with objects by reference', () async {
        final obj1 = {'id': 1};
        final obj2 = {'id': 2};
        final list = [obj1];

        list.toggleValue(obj1);
        expect(list, isEmpty);

        list.toggleValue(obj2);
        expect(list, [obj2]);
      });
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // PaginateExt Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('PaginateExt', () {
    nyGroup('paginate', () {
      nyTest('should return first page correctly', () async {
        final list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

        final result = list.paginate(itemsPerPage: 3, page: 1).toList();

        expect(result, [1, 2, 3]);
      });

      nyTest('should return second page correctly', () async {
        final list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

        final result = list.paginate(itemsPerPage: 3, page: 2).toList();

        expect(result, [4, 5, 6]);
      });

      nyTest('should return partial last page', () async {
        final list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

        final result = list.paginate(itemsPerPage: 3, page: 4).toList();

        expect(result, [10]);
      });

      nyTest('should return empty for page beyond data', () async {
        final list = [1, 2, 3];

        final result = list.paginate(itemsPerPage: 3, page: 2).toList();

        expect(result, isEmpty);
      });

      nyTest('should handle empty list', () async {
        final list = <int>[];

        final result = list.paginate(itemsPerPage: 10, page: 1).toList();

        expect(result, isEmpty);
      });

      nyTest('should handle single item per page', () async {
        final list = [1, 2, 3];

        expect(list.paginate(itemsPerPage: 1, page: 1).toList(), [1]);
        expect(list.paginate(itemsPerPage: 1, page: 2).toList(), [2]);
        expect(list.paginate(itemsPerPage: 1, page: 3).toList(), [3]);
      });

      nyTest('should handle page size larger than list', () async {
        final list = [1, 2, 3];

        final result = list.paginate(itemsPerPage: 10, page: 1).toList();

        expect(result, [1, 2, 3]);
      });
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // NyMapEntryExt Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('NyMapEntryExt', () {
    nyGroup('toMap', () {
      nyTest('should convert entries to map', () async {
        final entries = [
          MapEntry('key1', 'value1'),
          MapEntry('key2', 'value2'),
        ];

        final result = entries.toMap();

        expect(result, {'key1': 'value1', 'key2': 'value2'});
      });

      nyTest('should handle empty entries', () async {
        final entries = <MapEntry<String, dynamic>>[];

        final result = entries.toMap();

        expect(result, isEmpty);
      });

      nyTest('should handle various value types', () async {
        final entries = [
          MapEntry('string', 'text'),
          MapEntry('int', 42),
          MapEntry('bool', true),
          MapEntry('list', [1, 2, 3]),
        ];

        final result = entries.toMap();

        expect(result['string'], 'text');
        expect(result['int'], 42);
        expect(result['bool'], isTrue);
        expect(result['list'], [1, 2, 3]);
      });

      nyTest('should handle duplicate keys (last wins)', () async {
        final entries = [MapEntry('key', 'first'), MapEntry('key', 'second')];

        final result = entries.toMap();

        expect(result['key'], 'second');
      });
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Integration Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('Collection Extensions Integration', () {
    nyTest('should chain list operations', () async {
      final list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

      // Update even numbers, then paginate
      final updated = list.update((item) => item % 2 == 0, (item) => item * 10);

      final page1 = updated.paginate(itemsPerPage: 3, page: 1).toList();

      expect(page1, [1, 20, 3]);
    });

    nyTest('should handle complex pagination workflow', () async {
      final items = List.generate(25, (i) => i + 1);

      // Simulate pagination UI
      final page1 = items.paginate(itemsPerPage: 10, page: 1).toList();
      final page2 = items.paginate(itemsPerPage: 10, page: 2).toList();
      final page3 = items.paginate(itemsPerPage: 10, page: 3).toList();

      expect(page1.length, 10);
      expect(page2.length, 10);
      expect(page3.length, 5);
      expect(page1.first, 1);
      expect(page2.first, 11);
      expect(page3.first, 21);
    });

    nyTest('should use toggle with pagination', () async {
      final selectedIds = <int>[];

      // Simulate selecting items
      selectedIds.toggleValue(1);
      selectedIds.toggleValue(3);
      selectedIds.toggleValue(5);

      expect(selectedIds, [1, 3, 5]);

      // Toggle off item 3
      selectedIds.toggleValue(3);

      expect(selectedIds, [1, 5]);
    });
  });
}
