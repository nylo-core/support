import 'dart:math';

/// Static utility methods for working with lists.
///
/// ```dart
/// Arr.wrap('foo');                  // ['foo']
/// Arr.flatten([1, [2, [3]]]);       // [1, 2, 3]
/// Arr.chunk([1, 2, 3, 4, 5], 2);    // [[1, 2], [3, 4], [5]]
/// Arr.pluck(users, 'name');         // ['Anna', 'Brad']
/// Arr.keyBy(users, 'id');           // {1: {...}, 2: {...}}
/// ```
///
/// Available helpers:
///
/// Type checks:
///   - [accessible], [isList], [isAssoc]
///
/// Construction:
///   - [wrap], [flatten], [collapse], [crossJoin]
///
/// Filtering:
///   - [first], [last], [where], [reject], [whereNotNull]
///   - [unique], [exceptValues], [onlyValues]
///
/// Slicing / chunking:
///   - [take], [chunk], [prepend], [push], [interleave]
///
/// Ordering:
///   - [shuffle], [sort], [sortDesc], [sortRecursive]
///
/// Random:
///   - [random], [randomMany]
///
/// Iteration:
///   - [map], [mapWithKeys], [flatMap], [indexed], [partition], [groupBy]
///
/// Mutations (immutable):
///   - [replaceAt], [move], [swap]
///
/// Aggregates:
///   - [every], [some], [sole], [join]
///   - [sum], [average], [median], [min], [max], [countBy]
///
/// Map-list operations:
///   - [pluck], [keyBy], [select]
class Arr {
  Arr._();

  static final Random _random = Random.secure();

  // ---------------------------------------------------------------------------
  // Type checks
  // ---------------------------------------------------------------------------

  /// Returns true when [value] is a `List` or `Map` (i.e. index/key accessible).
  static bool accessible(Object? value) => value is List || value is Map;

  /// Returns true when [value] is a `List`.
  static bool isList(Object? value) => value is List;

  /// Returns true when [value] is a `Map` (associative).
  static bool isAssoc(Object? value) => value is Map;

  // ---------------------------------------------------------------------------
  // Construction
  // ---------------------------------------------------------------------------

  /// Wraps [value] in a `List` if it isn't already one.
  /// Returns an empty list when value is `null`.
  static List wrap(Object? value) {
    if (value == null) return [];
    if (value is List) return value;
    return [value];
  }

  /// Flattens a nested iterable into a single-level list.
  ///
  /// [depth] limits how deep to flatten; `-1` means unlimited.
  static List flatten(Iterable list, {int depth = -1}) {
    final result = [];
    for (final item in list) {
      if (item is Iterable && depth != 0) {
        result.addAll(flatten(item, depth: depth - 1));
      } else {
        result.add(item);
      }
    }
    return result;
  }

  /// Collapses a list of lists into a single list.
  static List<T> collapse<T>(Iterable<Iterable<T>> arrays) => [
    for (final a in arrays) ...a,
  ];

  /// Cross joins the given [lists], returning every possible combination.
  ///
  /// ```dart
  /// Arr.crossJoin([[1, 2], ['a', 'b']]);
  /// // [[1, 'a'], [1, 'b'], [2, 'a'], [2, 'b']]
  /// ```
  static List<List> crossJoin(Iterable<Iterable> lists) {
    var result = <List>[<dynamic>[]];
    for (final source in lists) {
      final next = <List>[];
      for (final accumulated in result) {
        for (final item in source) {
          next.add([...accumulated, item]);
        }
      }
      result = next;
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Filtering
  // ---------------------------------------------------------------------------

  /// Returns the first element matching [predicate], or [defaultValue].
  static T? first<T>(
    Iterable<T> list, {
    bool Function(T)? predicate,
    T? defaultValue,
  }) {
    for (final v in list) {
      if (predicate == null || predicate(v)) return v;
    }
    return defaultValue;
  }

  /// Returns the last element matching [predicate], or [defaultValue].
  static T? last<T>(
    Iterable<T> list, {
    bool Function(T)? predicate,
    T? defaultValue,
  }) {
    T? result = defaultValue;
    var found = predicate == null;
    for (final v in list) {
      if (predicate == null || predicate(v)) {
        result = v;
        found = true;
      }
    }
    return found ? result : defaultValue;
  }

  /// Filters [list] to elements matching [predicate].
  static List<T> where<T>(Iterable<T> list, bool Function(T) predicate) =>
      list.where(predicate).toList();

  /// Filters [list] to elements NOT matching [predicate]. Inverse of [where].
  static List<T> reject<T>(Iterable<T> list, bool Function(T) predicate) => [
    for (final v in list)
      if (!predicate(v)) v,
  ];

  /// Returns [list] with `null` values removed.
  static List<T> whereNotNull<T>(Iterable<T?> list) => [
    for (final v in list)
      if (v != null) v,
  ];

  /// Returns the unique values of [list].
  static List<T> unique<T>(Iterable<T> list) => list.toSet().toList();

  /// Returns [list] with each of [values] removed.
  ///
  /// ```dart
  /// Arr.exceptValues([1, 2, 3, 4], [2, 4]); // [1, 3]
  /// ```
  static List<T> exceptValues<T>(Iterable<T> list, Iterable<T> values) {
    final exclude = values.toSet();
    return [
      for (final v in list)
        if (!exclude.contains(v)) v,
    ];
  }

  /// Returns the elements of [list] that are also in [values].
  ///
  /// ```dart
  /// Arr.onlyValues([1, 2, 3, 4], [2, 4, 9]); // [2, 4]
  /// ```
  static List<T> onlyValues<T>(Iterable<T> list, Iterable<T> values) {
    final include = values.toSet();
    return [
      for (final v in list)
        if (include.contains(v)) v,
    ];
  }

  // ---------------------------------------------------------------------------
  // Slicing / chunking
  // ---------------------------------------------------------------------------

  /// Returns the first [count] elements of [list], or last [count] if negative.
  static List<T> take<T>(Iterable<T> list, int count) {
    if (count >= 0) return list.take(count).toList();
    final source = list.toList();
    final n = source.length + count;
    return n < 0 ? <T>[] : source.sublist(n);
  }

  /// Splits [list] into chunks of [size] elements.
  static List<List<T>> chunk<T>(Iterable<T> list, int size) {
    if (size <= 0) throw ArgumentError('size must be positive');
    final source = list.toList();
    final result = <List<T>>[];
    for (var i = 0; i < source.length; i += size) {
      final end = i + size > source.length ? source.length : i + size;
      result.add(source.sublist(i, end));
    }
    return result;
  }

  /// Returns a new list with [value] inserted at the front.
  static List<T> prepend<T>(Iterable<T> list, T value) => [value, ...list];

  /// Returns a new list with [value] appended at the end.
  static List<T> push<T>(Iterable<T> list, T value) => [...list, value];

  /// Returns [list] with [separator] inserted between every pair of elements.
  ///
  /// Useful for building widget children with separators:
  /// ```dart
  /// Column(children: Arr.interleave(tiles, const Divider()));
  /// ```
  static List<T> interleave<T>(Iterable<T> list, T separator) {
    final source = list.toList();
    if (source.length <= 1) return source;
    return [
      for (var i = 0; i < source.length; i++) ...[
        if (i > 0) separator,
        source[i],
      ],
    ];
  }

  // ---------------------------------------------------------------------------
  // Ordering
  // ---------------------------------------------------------------------------

  /// Returns a shuffled copy of [list]. Pass [seed] for determinism.
  static List<T> shuffle<T>(Iterable<T> list, {int? seed}) {
    final rng = seed == null ? _random : Random(seed);
    return list.toList()..shuffle(rng);
  }

  /// Returns a sorted copy of [list].
  static List<T> sort<T>(Iterable<T> list, {int Function(T, T)? compare}) =>
      list.toList()..sort(compare);

  /// Returns a sorted copy of [list] in descending order.
  static List<T> sortDesc<T extends Comparable>(Iterable<T> list) =>
      list.toList()..sort((a, b) => b.compareTo(a));

  /// Recursively sorts [list]. Nested lists are sorted at every depth; values
  /// of mixed types fall back to string comparison.
  ///
  /// ```dart
  /// Arr.sortRecursive([[3, 1, 2], [9, 7, 8]]); // [[1, 2, 3], [7, 8, 9]]
  /// ```
  static List sortRecursive(
    List list, {
    int Function(dynamic, dynamic)? compare,
  }) {
    final c =
        compare ??
        (a, b) {
          if (a == null) return b == null ? 0 : -1;
          if (b == null) return 1;
          if (a is Comparable &&
              b is Comparable &&
              a.runtimeType == b.runtimeType) {
            return a.compareTo(b);
          }
          return a.toString().compareTo(b.toString());
        };
    return list.map((v) {
      if (v is List) return sortRecursive(v, compare: compare);
      return v;
    }).toList()..sort(c);
  }

  // ---------------------------------------------------------------------------
  // Random
  // ---------------------------------------------------------------------------

  /// Returns a random element of [list]. Throws when [list] is empty.
  static T random<T>(List<T> list) {
    if (list.isEmpty) throw ArgumentError('list must not be empty');
    return list[_random.nextInt(list.length)];
  }

  /// Returns up to [count] random elements of [list] without replacement.
  static List<T> randomMany<T>(List<T> list, int count) {
    if (count <= 0 || list.isEmpty) return <T>[];
    final n = count > list.length ? list.length : count;
    return shuffle(list).take(n).toList();
  }

  // ---------------------------------------------------------------------------
  // Iteration
  // ---------------------------------------------------------------------------

  /// Maps each element of [list] through [callback], passing the index too.
  static List<R> map<T, R>(
    Iterable<T> list,
    R Function(T value, int index) callback,
  ) {
    var i = 0;
    return [for (final v in list) callback(v, i++)];
  }

  /// Maps each element of [list] to a `MapEntry`, returning the resulting map.
  ///
  /// ```dart
  /// Arr.mapWithKeys(
  ///   [{'id': 1, 'name': 'Anna'}, {'id': 2, 'name': 'Brad'}],
  ///   (m) => MapEntry(m['id'], m['name']),
  /// ); // {1: 'Anna', 2: 'Brad'}
  /// ```
  static Map<K, V> mapWithKeys<T, K, V>(
    Iterable<T> list,
    MapEntry<K, V> Function(T) callback,
  ) {
    final result = <K, V>{};
    for (final v in list) {
      final entry = callback(v);
      result[entry.key] = entry.value;
    }
    return result;
  }

  /// Splits [list] into a `[matching, nonMatching]` pair based on [predicate].
  ///
  /// ```dart
  /// final [evens, odds] = Arr.partition([1, 2, 3, 4], (n) => n.isEven);
  /// // evens: [2, 4], odds: [1, 3]
  /// ```
  static List<List<T>> partition<T>(
    Iterable<T> list,
    bool Function(T) predicate,
  ) {
    final yes = <T>[];
    final no = <T>[];
    for (final v in list) {
      (predicate(v) ? yes : no).add(v);
    }
    return [yes, no];
  }

  /// Maps each element of [list] through [fn], flattening the resulting
  /// iterables into a single list.
  ///
  /// ```dart
  /// Arr.flatMap(pages, (p) => p.items); // all items from all pages
  /// ```
  static List<R> flatMap<T, R>(Iterable<T> list, Iterable<R> Function(T) fn) =>
      [for (final v in list) ...fn(v)];

  /// Pairs each element of [list] with its index, returning a list of
  /// `(index, value)` records.
  ///
  /// ```dart
  /// for (final (i, v) in Arr.indexed(['a', 'b', 'c'])) {
  ///   print('$i: $v'); // '0: a', '1: b', '2: c'
  /// }
  /// ```
  static List<(int, T)> indexed<T>(Iterable<T> list) {
    var i = 0;
    return [for (final v in list) (i++, v)];
  }

  /// Groups [list] into a map keyed by the value returned by [by].
  ///
  /// ```dart
  /// Arr.groupBy(messages, (m) => m.date);
  /// // {2024-01-01: [...], 2024-01-02: [...]}
  /// ```
  static Map<K, List<T>> groupBy<T, K>(Iterable<T> list, K Function(T) by) {
    final result = <K, List<T>>{};
    for (final v in list) {
      result.putIfAbsent(by(v), () => <T>[]).add(v);
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Mutations (immutable)
  // ---------------------------------------------------------------------------

  /// Returns a new list with the element at [index] replaced by [value].
  /// Throws [RangeError] when [index] is out of range.
  static List<T> replaceAt<T>(Iterable<T> list, int index, T value) {
    final source = list.toList();
    if (index < 0 || index >= source.length) {
      throw RangeError.index(index, source);
    }
    source[index] = value;
    return source;
  }

  /// Returns a new list with the element at [from] moved to position [to].
  ///
  /// Useful for reorderable lists. [to] is clamped to the valid range.
  ///
  /// ```dart
  /// Arr.move(['a', 'b', 'c', 'd'], 0, 2); // ['b', 'c', 'a', 'd']
  /// ```
  static List<T> move<T>(Iterable<T> list, int from, int to) {
    final source = list.toList();
    if (from < 0 || from >= source.length) {
      throw RangeError.index(from, source, 'from');
    }
    final target = to.clamp(0, source.length - 1);
    final item = source.removeAt(from);
    source.insert(target, item);
    return source;
  }

  /// Returns a new list with the elements at [i] and [j] swapped.
  static List<T> swap<T>(Iterable<T> list, int i, int j) {
    final source = list.toList();
    if (i < 0 || i >= source.length) {
      throw RangeError.index(i, source, 'i');
    }
    if (j < 0 || j >= source.length) {
      throw RangeError.index(j, source, 'j');
    }
    final tmp = source[i];
    source[i] = source[j];
    source[j] = tmp;
    return source;
  }

  // ---------------------------------------------------------------------------
  // Aggregates
  // ---------------------------------------------------------------------------

  /// Returns true when every element of [list] passes [predicate].
  /// Vacuously true for empty lists.
  static bool every<T>(Iterable<T> list, bool Function(T) predicate) =>
      list.every(predicate);

  /// Returns true when at least one element of [list] passes [predicate].
  static bool some<T>(Iterable<T> list, bool Function(T) predicate) =>
      list.any(predicate);

  /// Returns the single element matching [predicate]. Throws if zero or more
  /// than one element matches.
  static T sole<T>(Iterable<T> list, {bool Function(T)? predicate}) {
    final filtered = predicate == null
        ? list.toList()
        : list.where(predicate).toList();
    if (filtered.isEmpty) {
      throw StateError('sole: no items found');
    }
    if (filtered.length > 1) {
      throw StateError('sole: expected 1 item, found ${filtered.length}');
    }
    return filtered.first;
  }

  /// Joins [list] into a string with [separator]; the final element is joined
  /// with [finalSeparator] when provided.
  ///
  /// ```dart
  /// Arr.join(['apples', 'oranges', 'pears'], ', ', ' and ');
  /// // 'apples, oranges and pears'
  /// ```
  static String join(
    Iterable list, [
    String separator = ', ',
    String finalSeparator = '',
  ]) {
    final items = list.toList();
    if (items.isEmpty) return '';
    if (items.length == 1) return items.first.toString();
    if (finalSeparator.isEmpty) return items.join(separator);
    final head = items.sublist(0, items.length - 1).join(separator);
    return '$head$finalSeparator${items.last}';
  }

  /// Returns the sum of [list]. Pass [by] to extract a number from each
  /// element; otherwise [list] must be `Iterable<num>`.
  ///
  /// ```dart
  /// Arr.sum([1, 2, 3]);                                  // 6
  /// Arr.sum(orders, by: (o) => o.total);                  // sum of totals
  /// ```
  static num sum<T>(Iterable<T> list, {num Function(T)? by}) {
    var total = 0.0;
    for (final v in list) {
      total += by != null ? by(v) : (v as num);
    }
    return total == total.toInt() ? total.toInt() : total;
  }

  /// Returns the arithmetic mean of [list], or `0` when empty.
  static double average<T>(Iterable<T> list, {num Function(T)? by}) {
    if (list.isEmpty) return 0;
    var total = 0.0;
    var count = 0;
    for (final v in list) {
      total += by != null ? by(v) : (v as num);
      count++;
    }
    return total / count;
  }

  /// Returns the median of [list], or `0` when empty.
  static double median<T>(Iterable<T> list, {num Function(T)? by}) {
    if (list.isEmpty) return 0;
    final values = (by != null ? list.map(by) : list.cast<num>()).toList()
      ..sort();
    final mid = values.length ~/ 2;
    if (values.length.isOdd) return values[mid].toDouble();
    return (values[mid - 1] + values[mid]) / 2;
  }

  /// Returns the element of [list] with the smallest value of [by] (or the
  /// smallest element itself when [by] is null and `T` is `Comparable`).
  ///
  /// ```dart
  /// Arr.min(users, by: (u) => u.age); // user with the youngest age
  /// ```
  static T min<T>(Iterable<T> list, {Comparable Function(T)? by}) {
    if (list.isEmpty) throw ArgumentError('list must not be empty');
    T? best;
    Comparable? bestKey;
    for (final v in list) {
      final k = by != null ? by(v) : (v as Comparable);
      if (bestKey == null || k.compareTo(bestKey) < 0) {
        bestKey = k;
        best = v;
      }
    }
    return best as T;
  }

  /// Returns the element of [list] with the largest value of [by] (or the
  /// largest element itself when [by] is null and `T` is `Comparable`).
  static T max<T>(Iterable<T> list, {Comparable Function(T)? by}) {
    if (list.isEmpty) throw ArgumentError('list must not be empty');
    T? best;
    Comparable? bestKey;
    for (final v in list) {
      final k = by != null ? by(v) : (v as Comparable);
      if (bestKey == null || k.compareTo(bestKey) > 0) {
        bestKey = k;
        best = v;
      }
    }
    return best as T;
  }

  /// Counts occurrences in [list], optionally grouping by the value of [by].
  ///
  /// ```dart
  /// Arr.countBy(['a', 'b', 'a', 'c']);              // {'a': 2, 'b': 1, 'c': 1}
  /// Arr.countBy(orders, by: (o) => o.status);        // {paid: 12, pending: 3}
  /// ```
  static Map<K, int> countBy<T, K>(Iterable<T> list, {K Function(T)? by}) {
    final result = <K, int>{};
    for (final v in list) {
      final key = (by != null ? by(v) : v) as K;
      result[key] = (result[key] ?? 0) + 1;
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Map-list operations
  // ---------------------------------------------------------------------------

  /// Plucks the value at [key] from each map in [list].
  ///
  /// ```dart
  /// Arr.pluck([
  ///   {'name': 'Anna'},
  ///   {'name': 'Brad'},
  /// ], 'name'); // ['Anna', 'Brad']
  /// ```
  static List<V?> pluck<K, V>(Iterable<Map<K, V>> list, K key) => [
    for (final m in list) m[key],
  ];

  /// Indexes [list] by the value at [key]. Entries with a `null` value
  /// at [key] are skipped.
  ///
  /// ```dart
  /// Arr.keyBy([{'id': 1}, {'id': 2}], 'id'); // {1: {id: 1}, 2: {id: 2}}
  /// ```
  static Map<V, Map<K, V>> keyBy<K, V>(Iterable<Map<K, V>> list, K key) {
    final result = <V, Map<K, V>>{};
    for (final m in list) {
      final k = m[key];
      if (k != null) result[k] = m;
    }
    return result;
  }

  /// Returns each map in [list] reduced to only the given [keys].
  ///
  /// ```dart
  /// Arr.select([
  ///   {'name': 'Anna', 'role': 'admin', 'age': 30},
  ///   {'name': 'Brad', 'role': 'user', 'age': 25},
  /// ], ['name', 'role']);
  /// // [{'name': 'Anna', 'role': 'admin'}, {'name': 'Brad', 'role': 'user'}]
  /// ```
  static List<Map<K, V>> select<K, V>(
    Iterable<Map<K, V>> list,
    Iterable<K> keys,
  ) {
    final keySet = keys.toSet();
    return [
      for (final m in list)
        {
          for (final e in m.entries)
            if (keySet.contains(e.key)) e.key: e.value,
        },
    ];
  }
}
