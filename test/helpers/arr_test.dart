import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  // ===========================================================================
  // Construction
  // ===========================================================================

  nyGroup('Arr.wrap', () {
    nyTest('wraps a single value', () async {
      expect(Arr.wrap('foo'), ['foo']);
    });
    nyTest('returns the list when already a list', () async {
      expect(Arr.wrap([1, 2, 3]), [1, 2, 3]);
    });
    nyTest('returns empty list for null', () async {
      expect(Arr.wrap(null), isEmpty);
    });
  });

  nyGroup('Arr.flatten', () {
    nyTest('flattens nested lists fully by default', () async {
      expect(
        Arr.flatten([
          1,
          [
            2,
            [
              3,
              [4],
            ],
          ],
        ]),
        [1, 2, 3, 4],
      );
    });
    nyTest('respects depth=1', () async {
      expect(
        Arr.flatten([
          1,
          [
            2,
            [3],
          ],
        ], depth: 1),
        [
          1,
          2,
          [3],
        ],
      );
    });
    nyTest('handles empty list', () async {
      expect(Arr.flatten([]), isEmpty);
    });
  });

  nyGroup('Arr.collapse', () {
    nyTest('merges a list of lists', () async {
      expect(
        Arr.collapse([
          [1, 2],
          [3, 4],
          [5],
        ]),
        [1, 2, 3, 4, 5],
      );
    });
    nyTest('handles empty', () async {
      expect(Arr.collapse(<List<int>>[]), isEmpty);
    });
  });

  // ===========================================================================
  // Filtering
  // ===========================================================================

  nyGroup('Arr.first', () {
    nyTest('returns first element', () async {
      expect(Arr.first([1, 2, 3]), 1);
    });
    nyTest('returns first matching predicate', () async {
      expect(Arr.first([1, 2, 3, 4], predicate: (n) => n > 2), 3);
    });
    nyTest('returns defaultValue when empty', () async {
      expect(Arr.first<int>([], defaultValue: 99), 99);
    });
    nyTest('returns null when no match and no default', () async {
      expect(Arr.first<int>([1, 2], predicate: (n) => n > 10), isNull);
    });
  });

  nyGroup('Arr.last', () {
    nyTest('returns last element', () async {
      expect(Arr.last([1, 2, 3]), 3);
    });
    nyTest('returns last matching predicate', () async {
      expect(Arr.last([1, 2, 3, 4], predicate: (n) => n < 3), 2);
    });
    nyTest('returns defaultValue when empty', () async {
      expect(Arr.last<int>([], defaultValue: 99), 99);
    });
  });

  nyGroup('Arr.where', () {
    nyTest('filters to matching elements', () async {
      expect(Arr.where([1, 2, 3, 4], (n) => n.isEven), [2, 4]);
    });
  });

  nyGroup('Arr.whereNotNull', () {
    nyTest('removes null values', () async {
      expect(Arr.whereNotNull([1, null, 2, null, 3]), [1, 2, 3]);
    });
  });

  nyGroup('Arr.unique', () {
    nyTest('returns distinct values', () async {
      expect(Arr.unique([1, 2, 2, 3, 3, 3]), [1, 2, 3]);
    });
  });

  // ===========================================================================
  // Slicing / chunking
  // ===========================================================================

  nyGroup('Arr.take', () {
    nyTest('takes first n elements', () async {
      expect(Arr.take([1, 2, 3, 4, 5], 3), [1, 2, 3]);
    });
    nyTest('takes last n elements when negative', () async {
      expect(Arr.take([1, 2, 3, 4, 5], -2), [4, 5]);
    });
    nyTest('returns full list when count exceeds length', () async {
      expect(Arr.take([1, 2], 5), [1, 2]);
    });
    nyTest('returns empty when negative count exceeds length', () async {
      expect(Arr.take([1, 2], -5), isEmpty);
    });
  });

  nyGroup('Arr.chunk', () {
    nyTest('splits into equal chunks', () async {
      expect(Arr.chunk([1, 2, 3, 4], 2), [
        [1, 2],
        [3, 4],
      ]);
    });
    nyTest('handles uneven last chunk', () async {
      expect(Arr.chunk([1, 2, 3, 4, 5], 2), [
        [1, 2],
        [3, 4],
        [5],
      ]);
    });
    nyTest('throws on non-positive size', () async {
      expect(() => Arr.chunk([1, 2], 0), throwsArgumentError);
    });
  });

  // ===========================================================================
  // Ordering
  // ===========================================================================

  nyGroup('Arr.shuffle', () {
    nyTest('returns same elements', () async {
      final result = Arr.shuffle([1, 2, 3, 4, 5]);
      expect(result.toSet(), {1, 2, 3, 4, 5});
    });
    nyTest('is deterministic with seed', () async {
      expect(
        Arr.shuffle([1, 2, 3, 4, 5], seed: 42),
        Arr.shuffle([1, 2, 3, 4, 5], seed: 42),
      );
    });
    nyTest('does not mutate input', () async {
      final input = [1, 2, 3];
      Arr.shuffle(input, seed: 1);
      expect(input, [1, 2, 3]);
    });
  });

  nyGroup('Arr.sort', () {
    nyTest('sorts ascending by default', () async {
      expect(Arr.sort([3, 1, 2]), [1, 2, 3]);
    });
    nyTest('respects custom compare', () async {
      expect(Arr.sort([3, 1, 2], compare: (a, b) => b.compareTo(a)), [3, 2, 1]);
    });
  });

  nyGroup('Arr.sortDesc', () {
    nyTest('sorts descending', () async {
      expect(Arr.sortDesc([1, 3, 2]), [3, 2, 1]);
    });
  });

  // ===========================================================================
  // Random
  // ===========================================================================

  nyGroup('Arr.random', () {
    nyTest('returns an element from the list', () async {
      final list = [1, 2, 3];
      expect(list.contains(Arr.random(list)), isTrue);
    });
    nyTest('throws when list is empty', () async {
      expect(() => Arr.random<int>([]), throwsArgumentError);
    });
  });

  nyGroup('Arr.randomMany', () {
    nyTest('returns up to count elements without replacement', () async {
      final list = [1, 2, 3, 4, 5];
      final picked = Arr.randomMany(list, 3);
      expect(picked.length, 3);
      expect(picked.toSet().length, 3); // unique
    });
    nyTest('caps at list length', () async {
      expect(Arr.randomMany([1, 2], 10).length, 2);
    });
    nyTest('returns empty for count <= 0', () async {
      expect(Arr.randomMany([1, 2], 0), isEmpty);
    });
  });

  // ===========================================================================
  // Map-list ops
  // ===========================================================================

  nyGroup('Arr.pluck', () {
    nyTest('extracts a field from list of maps', () async {
      expect(
        Arr.pluck([
          {'name': 'Anna', 'age': 30},
          {'name': 'Brad', 'age': 25},
        ], 'name'),
        ['Anna', 'Brad'],
      );
    });
    nyTest('returns null entries for missing keys', () async {
      expect(
        Arr.pluck([
          {'name': 'Anna'},
          {'age': 25},
        ], 'name'),
        ['Anna', null],
      );
    });
  });

  nyGroup('Arr.keyBy', () {
    nyTest('indexes maps by key value', () async {
      final result = Arr.keyBy([
        {'id': 1, 'name': 'Anna'},
        {'id': 2, 'name': 'Brad'},
      ], 'id');
      expect(result[1], {'id': 1, 'name': 'Anna'});
      expect(result[2], {'id': 2, 'name': 'Brad'});
    });
    nyTest('later entries overwrite earlier on duplicate keys', () async {
      final result = Arr.keyBy([
        {'id': 1, 'name': 'A'},
        {'id': 1, 'name': 'B'},
      ], 'id');
      expect(result[1], {'id': 1, 'name': 'B'});
      expect(result.length, 1);
    });
  });

  nyGroup('Arr.select', () {
    nyTest('reduces each map to the given keys', () async {
      expect(
        Arr.select(
          [
            {'name': 'Anna', 'role': 'admin', 'age': 30},
            {'name': 'Brad', 'role': 'user', 'age': 25},
          ],
          ['name', 'role'],
        ),
        [
          {'name': 'Anna', 'role': 'admin'},
          {'name': 'Brad', 'role': 'user'},
        ],
      );
    });
    nyTest('skips missing keys', () async {
      expect(
        Arr.select(
          [
            {'name': 'Anna'},
          ],
          ['name', 'age'],
        ),
        [
          {'name': 'Anna'},
        ],
      );
    });
  });

  nyGroup('Arr.mapWithKeys', () {
    nyTest('builds a map from list entries', () async {
      expect(
        Arr.mapWithKeys([
          {'id': 1, 'name': 'Anna'},
          {'id': 2, 'name': 'Brad'},
        ], (m) => MapEntry(m['id'] as int, m['name'] as String)),
        {1: 'Anna', 2: 'Brad'},
      );
    });
  });

  // ===========================================================================
  // Type checks
  // ===========================================================================

  nyGroup('Arr.accessible', () {
    nyTest('true for List', () async {
      expect(Arr.accessible([1, 2]), isTrue);
    });
    nyTest('true for Map', () async {
      expect(Arr.accessible({'a': 1}), isTrue);
    });
    nyTest('false for scalar', () async {
      expect(Arr.accessible('x'), isFalse);
      expect(Arr.accessible(1), isFalse);
      expect(Arr.accessible(null), isFalse);
    });
  });

  nyGroup('Arr.isList', () {
    nyTest('true for List', () async {
      expect(Arr.isList([1]), isTrue);
    });
    nyTest('false for Map', () async {
      expect(Arr.isList({'a': 1}), isFalse);
    });
  });

  nyGroup('Arr.isAssoc', () {
    nyTest('true for Map', () async {
      expect(Arr.isAssoc({'a': 1}), isTrue);
    });
    nyTest('false for List', () async {
      expect(Arr.isAssoc([1, 2]), isFalse);
    });
  });

  // ===========================================================================
  // Cross / partition / push / prepend
  // ===========================================================================

  nyGroup('Arr.crossJoin', () {
    nyTest('produces all combinations', () async {
      expect(
        Arr.crossJoin([
          [1, 2],
          ['a', 'b'],
        ]),
        [
          [1, 'a'],
          [1, 'b'],
          [2, 'a'],
          [2, 'b'],
        ],
      );
    });
    nyTest('handles three lists', () async {
      expect(
        Arr.crossJoin([
          [1],
          ['a', 'b'],
          ['x'],
        ]),
        [
          [1, 'a', 'x'],
          [1, 'b', 'x'],
        ],
      );
    });
    nyTest('returns single empty when no lists', () async {
      expect(Arr.crossJoin([]), [[]]);
    });
  });

  nyGroup('Arr.partition', () {
    nyTest('splits into matching and non-matching', () async {
      expect(Arr.partition([1, 2, 3, 4], (n) => n.isEven), [
        [2, 4],
        [1, 3],
      ]);
    });
  });

  nyGroup('Arr.prepend', () {
    nyTest('inserts at front', () async {
      expect(Arr.prepend([2, 3], 1), [1, 2, 3]);
    });
    nyTest('does not mutate input', () async {
      final input = [2, 3];
      Arr.prepend(input, 1);
      expect(input, [2, 3]);
    });
  });

  nyGroup('Arr.push', () {
    nyTest('appends at end', () async {
      expect(Arr.push([1, 2], 3), [1, 2, 3]);
    });
  });

  // ===========================================================================
  // Reject / value filters
  // ===========================================================================

  nyGroup('Arr.reject', () {
    nyTest('filters out matching elements', () async {
      expect(Arr.reject([1, 2, 3, 4], (n) => n.isEven), [1, 3]);
    });
  });

  nyGroup('Arr.exceptValues', () {
    nyTest('removes specified values', () async {
      expect(Arr.exceptValues([1, 2, 3, 4], [2, 4]), [1, 3]);
    });
  });

  nyGroup('Arr.onlyValues', () {
    nyTest('keeps only specified values', () async {
      expect(Arr.onlyValues([1, 2, 3, 4], [2, 4, 9]), [2, 4]);
    });
  });

  // ===========================================================================
  // Iteration
  // ===========================================================================

  nyGroup('Arr.map', () {
    nyTest('passes value and index', () async {
      expect(Arr.map(['a', 'b', 'c'], (v, i) => '$i:$v'), [
        '0:a',
        '1:b',
        '2:c',
      ]);
    });
  });

  // ===========================================================================
  // Aggregates
  // ===========================================================================

  nyGroup('Arr.every', () {
    nyTest('true when all match', () async {
      expect(Arr.every([2, 4, 6], (n) => n.isEven), isTrue);
    });
    nyTest('false when any fails', () async {
      expect(Arr.every([2, 3, 4], (n) => n.isEven), isFalse);
    });
    nyTest('vacuously true for empty', () async {
      expect(Arr.every<int>([], (_) => false), isTrue);
    });
  });

  nyGroup('Arr.some', () {
    nyTest('true when any matches', () async {
      expect(Arr.some([1, 2, 3], (n) => n.isEven), isTrue);
    });
    nyTest('false when none match', () async {
      expect(Arr.some([1, 3, 5], (n) => n.isEven), isFalse);
    });
  });

  nyGroup('Arr.sole', () {
    nyTest('returns the only matching element', () async {
      expect(Arr.sole([1, 2, 3], predicate: (n) => n == 2), 2);
    });
    nyTest('returns single element when no predicate', () async {
      expect(Arr.sole([42]), 42);
    });
    nyTest('throws when no match', () async {
      expect(
        () => Arr.sole<int>([1, 2], predicate: (n) => n > 10),
        throwsStateError,
      );
    });
    nyTest('throws when multiple match', () async {
      expect(
        () => Arr.sole([1, 2, 3], predicate: (n) => n.isOdd),
        throwsStateError,
      );
    });
  });

  nyGroup('Arr.join', () {
    nyTest('joins with separator', () async {
      expect(Arr.join(['a', 'b', 'c'], ', '), 'a, b, c');
    });
    nyTest('uses final separator before last item', () async {
      expect(
        Arr.join(['apples', 'oranges', 'pears'], ', ', ' and '),
        'apples, oranges and pears',
      );
    });
    nyTest('returns single item without separator', () async {
      expect(Arr.join(['only'], ', ', ' and '), 'only');
    });
    nyTest('returns empty string for empty list', () async {
      expect(Arr.join([]), '');
    });
  });

  nyGroup('Arr.sortRecursive', () {
    nyTest('sorts top-level list', () async {
      expect(Arr.sortRecursive([3, 1, 2]), [1, 2, 3]);
    });
    nyTest('sorts nested lists', () async {
      expect(
        Arr.sortRecursive([
          [3, 1, 2],
          [9, 7, 8],
        ]),
        [
          [1, 2, 3],
          [7, 8, 9],
        ],
      );
    });
  });

  // ===========================================================================
  // UI / iteration extras
  // ===========================================================================

  nyGroup('Arr.interleave', () {
    nyTest('inserts separator between items', () async {
      expect(Arr.interleave(['a', 'b', 'c'], '|'), ['a', '|', 'b', '|', 'c']);
    });
    nyTest('returns input unchanged when length <= 1', () async {
      expect(Arr.interleave(['a'], '|'), ['a']);
      expect(Arr.interleave(<String>[], '|'), <String>[]);
    });
  });

  nyGroup('Arr.flatMap', () {
    nyTest('maps and flattens one level', () async {
      expect(Arr.flatMap([1, 2, 3], (n) => [n, n * 10]), [1, 10, 2, 20, 3, 30]);
    });
    nyTest('handles empty inner iterables', () async {
      expect(Arr.flatMap([1, 2, 3], (n) => n.isEven ? [n] : <int>[]), [2]);
    });
  });

  nyGroup('Arr.indexed', () {
    nyTest('pairs each value with its index', () async {
      expect(Arr.indexed(['a', 'b', 'c']), [(0, 'a'), (1, 'b'), (2, 'c')]);
    });
    nyTest('handles empty', () async {
      expect(Arr.indexed(<String>[]), <(int, String)>[]);
    });
  });

  nyGroup('Arr.groupBy', () {
    nyTest('groups items by key', () async {
      expect(
        Arr.groupBy([
          {'type': 'a', 'v': 1},
          {'type': 'b', 'v': 2},
          {'type': 'a', 'v': 3},
        ], (m) => m['type']),
        {
          'a': [
            {'type': 'a', 'v': 1},
            {'type': 'a', 'v': 3},
          ],
          'b': [
            {'type': 'b', 'v': 2},
          ],
        },
      );
    });
  });

  // ===========================================================================
  // Mutations (immutable)
  // ===========================================================================

  nyGroup('Arr.replaceAt', () {
    nyTest('replaces element at index', () async {
      expect(Arr.replaceAt([1, 2, 3], 1, 99), [1, 99, 3]);
    });
    nyTest('does not mutate input', () async {
      final input = [1, 2, 3];
      Arr.replaceAt(input, 1, 99);
      expect(input, [1, 2, 3]);
    });
    nyTest('throws on out-of-range index', () async {
      expect(() => Arr.replaceAt([1, 2], 5, 0), throwsRangeError);
    });
  });

  nyGroup('Arr.move', () {
    nyTest('moves element forward', () async {
      expect(Arr.move(['a', 'b', 'c', 'd'], 0, 2), ['b', 'c', 'a', 'd']);
    });
    nyTest('moves element backward', () async {
      expect(Arr.move(['a', 'b', 'c', 'd'], 3, 0), ['d', 'a', 'b', 'c']);
    });
    nyTest('clamps target index', () async {
      expect(Arr.move(['a', 'b', 'c'], 0, 99), ['b', 'c', 'a']);
    });
    nyTest('throws on out-of-range from', () async {
      expect(() => Arr.move([1, 2], 5, 0), throwsRangeError);
    });
  });

  nyGroup('Arr.swap', () {
    nyTest('swaps two elements', () async {
      expect(Arr.swap(['a', 'b', 'c'], 0, 2), ['c', 'b', 'a']);
    });
    nyTest('does not mutate input', () async {
      final input = [1, 2, 3];
      Arr.swap(input, 0, 2);
      expect(input, [1, 2, 3]);
    });
    nyTest('throws on bad index', () async {
      expect(() => Arr.swap([1, 2], 0, 5), throwsRangeError);
    });
  });

  // ===========================================================================
  // Numeric aggregates
  // ===========================================================================

  nyGroup('Arr.sum', () {
    nyTest('sums numeric list', () async {
      expect(Arr.sum([1, 2, 3]), 6);
    });
    nyTest('returns int when whole', () async {
      expect(Arr.sum([1.0, 2.0, 3.0]), 6);
      expect(Arr.sum([1.0, 2.0, 3.0]), isA<int>());
    });
    nyTest('uses extractor for object lists', () async {
      expect(
        Arr.sum([
          {'price': 10},
          {'price': 20},
        ], by: (m) => m['price'] as num),
        30,
      );
    });
  });

  nyGroup('Arr.average', () {
    nyTest('averages numeric list', () async {
      expect(Arr.average([2, 4, 6]), 4);
    });
    nyTest('returns 0 for empty list', () async {
      expect(Arr.average(<num>[]), 0);
    });
    nyTest('uses extractor', () async {
      expect(
        Arr.average([
          {'n': 10},
          {'n': 20},
        ], by: (m) => m['n'] as num),
        15,
      );
    });
  });

  nyGroup('Arr.median', () {
    nyTest('returns middle of odd-length list', () async {
      expect(Arr.median([1, 5, 2]), 2);
    });
    nyTest('averages two middle values for even-length list', () async {
      expect(Arr.median([1, 2, 3, 4]), 2.5);
    });
    nyTest('returns 0 for empty list', () async {
      expect(Arr.median(<num>[]), 0);
    });
  });

  nyGroup('Arr.min', () {
    nyTest('returns smallest comparable element', () async {
      expect(Arr.min([3, 1, 2]), 1);
    });
    nyTest('uses extractor and returns the element', () async {
      final users = [
        {'name': 'Anna', 'age': 30},
        {'name': 'Brad', 'age': 25},
        {'name': 'Cara', 'age': 40},
      ];
      expect(Arr.min(users, by: (u) => u['age'] as int)['name'], 'Brad');
    });
    nyTest('throws on empty list', () async {
      expect(() => Arr.min<int>([]), throwsArgumentError);
    });
  });

  nyGroup('Arr.max', () {
    nyTest('returns largest comparable element', () async {
      expect(Arr.max([3, 1, 2]), 3);
    });
    nyTest('uses extractor and returns the element', () async {
      final users = [
        {'name': 'Anna', 'age': 30},
        {'name': 'Brad', 'age': 25},
        {'name': 'Cara', 'age': 40},
      ];
      expect(Arr.max(users, by: (u) => u['age'] as int)['name'], 'Cara');
    });
  });

  nyGroup('Arr.countBy', () {
    nyTest('counts each value', () async {
      expect(Arr.countBy(['a', 'b', 'a', 'c', 'a']), {'a': 3, 'b': 1, 'c': 1});
    });
    nyTest('counts by extractor', () async {
      expect(
        Arr.countBy([
          {'status': 'paid'},
          {'status': 'pending'},
          {'status': 'paid'},
        ], by: (m) => m['status']),
        {'paid': 2, 'pending': 1},
      );
    });
  });
}
