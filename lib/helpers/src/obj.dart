/// Static utility methods for working with maps using dot notation.
///
/// ```dart
/// final user = {'profile': {'name': 'Anna', 'age': 30}};
/// Obj.get(user, 'profile.name');     // 'Anna'
/// Obj.has(user, 'profile.email');    // false
/// Obj.set(user, 'profile.email', 'a@b'); // mutates user
/// Obj.dot(user);                     // {'profile.name': 'Anna', 'profile.age': 30}
/// ```
///
/// Available helpers:
///
/// Read:
///   - [get], [has], [hasAny], [hasAll], [exists]
///
/// Typed read:
///   - [getString], [getInt], [getDouble], [getBool], [getList], [getMap]
///
/// Write (mutating):
///   - [set], [add], [forget], [pull]
///
/// Subset:
///   - [only], [except], [prependKeysWith], [divide]
///
/// Filter:
///   - [whereNotNull], [whereNotEmpty]
///
/// Transform:
///   - [mapKeys], [mapValues], [flip]
///
/// Flatten / inflate:
///   - [dot], [undot]
///
/// Merge / compare / query:
///   - [merge], [deepEquals], [query]
class Obj {
  Obj._();

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  /// Returns the value at [key] in [map] using dot notation, or [defaultValue]
  /// when the path is missing.
  ///
  /// Top-level keys containing literal dots take precedence over traversal.
  /// List elements can be addressed by integer index, e.g. `'users.0.name'`.
  static dynamic get(Map map, String key, [dynamic defaultValue]) {
    if (key.isEmpty) return defaultValue;
    if (map.containsKey(key)) return map[key];
    dynamic current = map;
    for (final segment in key.split('.')) {
      if (current is Map) {
        if (!current.containsKey(segment)) return defaultValue;
        current = current[segment];
      } else if (current is List) {
        final idx = int.tryParse(segment);
        if (idx == null || idx < 0 || idx >= current.length) {
          return defaultValue;
        }
        current = current[idx];
      } else {
        return defaultValue;
      }
    }
    return current;
  }

  /// Returns true when [map] has a value at [key] (dot notation).
  static bool has(Map map, String key) {
    if (key.isEmpty) return false;
    if (map.containsKey(key)) return true;
    dynamic current = map;
    for (final segment in key.split('.')) {
      if (current is Map && current.containsKey(segment)) {
        current = current[segment];
      } else if (current is List) {
        final idx = int.tryParse(segment);
        if (idx == null || idx < 0 || idx >= current.length) return false;
        current = current[idx];
      } else {
        return false;
      }
    }
    return true;
  }

  /// Returns true when any of [keys] resolves in [map].
  static bool hasAny(Map map, Iterable<String> keys) {
    for (final k in keys) {
      if (has(map, k)) return true;
    }
    return false;
  }

  /// Returns true when every one of [keys] resolves in [map].
  static bool hasAll(Map map, Iterable<String> keys) {
    for (final k in keys) {
      if (!has(map, k)) return false;
    }
    return true;
  }

  /// Returns true when [map] has [key] at the top level (no traversal).
  static bool exists(Map map, Object key) => map.containsKey(key);

  // ---------------------------------------------------------------------------
  // Typed read
  // ---------------------------------------------------------------------------

  /// Returns the value at [key] coerced to `String`, or [defaultValue].
  ///
  /// Strings pass through; everything else is rendered with `toString()`.
  /// Returns [defaultValue] when the path is missing or the value is `null`.
  static String? getString(Map map, String key, [String? defaultValue]) {
    final v = get(map, key);
    if (v == null) return defaultValue;
    if (v is String) return v;
    return v.toString();
  }

  /// Returns the value at [key] coerced to `int`, or [defaultValue].
  ///
  /// `String`s are parsed via `int.tryParse`; `double`s are truncated;
  /// `bool`s map to `1`/`0`. Returns [defaultValue] on missing path or
  /// failed coercion.
  static int? getInt(Map map, String key, [int? defaultValue]) {
    final v = get(map, key);
    if (v == null) return defaultValue;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is bool) return v ? 1 : 0;
    if (v is String) return int.tryParse(v) ?? defaultValue;
    return defaultValue;
  }

  /// Returns the value at [key] coerced to `double`, or [defaultValue].
  ///
  /// `String`s are parsed via `double.tryParse`; `int`s are widened;
  /// `bool`s map to `1.0`/`0.0`. Returns [defaultValue] on missing path
  /// or failed coercion.
  static double? getDouble(Map map, String key, [double? defaultValue]) {
    final v = get(map, key);
    if (v == null) return defaultValue;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is bool) return v ? 1.0 : 0.0;
    if (v is String) return double.tryParse(v) ?? defaultValue;
    return defaultValue;
  }

  /// Returns the value at [key] coerced to `bool`, or [defaultValue].
  ///
  /// Numbers are truthy when non-zero. The strings `'true'/'false'/'1'/`
  /// `'0'/'yes'/'no'/'on'/'off'` are recognized (case-insensitive, trimmed).
  /// Returns [defaultValue] on missing path or unrecognized value.
  static bool? getBool(Map map, String key, [bool? defaultValue]) {
    final v = get(map, key);
    if (v == null) return defaultValue;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      switch (v.toLowerCase().trim()) {
        case 'true':
        case '1':
        case 'yes':
        case 'on':
          return true;
        case 'false':
        case '0':
        case 'no':
        case 'off':
          return false;
      }
    }
    return defaultValue;
  }

  /// Returns the value at [key] when it is a `List`, otherwise [defaultValue].
  static List? getList(Map map, String key, [List? defaultValue]) {
    final v = get(map, key);
    return v is List ? v : defaultValue;
  }

  /// Returns the value at [key] when it is a `Map`, otherwise [defaultValue].
  static Map? getMap(Map map, String key, [Map? defaultValue]) {
    final v = get(map, key);
    return v is Map ? v : defaultValue;
  }

  // ---------------------------------------------------------------------------
  // Write (mutating)
  // ---------------------------------------------------------------------------

  /// Sets [value] at [key] in [map], creating nested maps along the path.
  /// Mutates [map] in place and returns it for chaining.
  ///
  /// Existing Lists encountered along the path are traversed by integer
  /// segment (e.g. `'users.0.name'`); Lists are not auto-created. Existing
  /// non-collection intermediates (e.g. an int or String) are left in place
  /// and the call becomes a no-op so that data isn't silently destroyed.
  static Map set(Map map, String key, dynamic value) {
    if (key.isEmpty) return map;
    final segments = key.split('.');
    dynamic current = map;
    for (var i = 0; i < segments.length - 1; i++) {
      final s = segments[i];
      if (current is Map) {
        final next = current[s];
        if (next is Map || next is List) {
          current = next;
        } else if (next == null) {
          final fresh = <String, dynamic>{};
          current[s] = fresh;
          current = fresh;
        } else {
          return map;
        }
      } else if (current is List) {
        final idx = int.tryParse(s);
        if (idx == null || idx < 0 || idx >= current.length) return map;
        current = current[idx];
      } else {
        return map;
      }
    }
    final last = segments.last;
    if (current is Map) {
      current[last] = value;
    } else if (current is List) {
      final idx = int.tryParse(last);
      if (idx != null && idx >= 0 && idx < current.length) {
        current[idx] = value;
      }
    }
    return map;
  }

  /// Adds [value] at [key] only if no value currently exists there.
  static Map add(Map map, String key, dynamic value) {
    if (!has(map, key)) set(map, key, value);
    return map;
  }

  /// Removes [key] (dot notation) from [map]. Returns the map for chaining.
  ///
  /// When the leaf lives inside a List, the element is removed via
  /// `removeAt`, shifting subsequent indices.
  static Map forget(Map map, String key) {
    if (key.isEmpty) return map;
    if (map.containsKey(key)) {
      map.remove(key);
      return map;
    }
    final segments = key.split('.');
    dynamic current = map;
    for (var i = 0; i < segments.length - 1; i++) {
      final s = segments[i];
      if (current is Map) {
        final next = current[s];
        if (next is Map || next is List) {
          current = next;
        } else {
          return map;
        }
      } else if (current is List) {
        final idx = int.tryParse(s);
        if (idx == null || idx < 0 || idx >= current.length) return map;
        current = current[idx];
      } else {
        return map;
      }
    }
    final last = segments.last;
    if (current is Map) {
      current.remove(last);
    } else if (current is List) {
      final idx = int.tryParse(last);
      if (idx != null && idx >= 0 && idx < current.length) {
        current.removeAt(idx);
      }
    }
    return map;
  }

  /// Returns the value at [key] and removes it from [map].
  static dynamic pull(Map map, String key, [dynamic defaultValue]) {
    final value = get(map, key, defaultValue);
    forget(map, key);
    return value;
  }

  // ---------------------------------------------------------------------------
  // Subset
  // ---------------------------------------------------------------------------

  /// Returns a new map containing only the entries whose keys are in [keys].
  static Map<K, V> only<K, V>(Map<K, V> map, Iterable<K> keys) => {
    for (final k in keys)
      if (map.containsKey(k)) k: map[k] as V,
  };

  /// Returns a new map containing all entries except those whose keys are in [keys].
  static Map<K, V> except<K, V>(Map<K, V> map, Iterable<K> keys) {
    final exclude = keys.toSet();
    return {
      for (final e in map.entries)
        if (!exclude.contains(e.key)) e.key: e.value,
    };
  }

  /// Prefixes every top-level key in [map] with [prefix].
  static Map<String, V> prependKeysWith<V>(Map<String, V> map, String prefix) =>
      {for (final e in map.entries) '$prefix${e.key}': e.value};

  /// Splits [map] into a `[keys, values]` pair.
  ///
  /// ```dart
  /// Obj.divide({'name': 'Desk', 'price': 100});
  /// // [['name', 'price'], ['Desk', 100]]
  /// ```
  static List<List> divide<K, V>(Map<K, V> map) => [
    map.keys.toList(),
    map.values.toList(),
  ];

  // ---------------------------------------------------------------------------
  // Filter
  // ---------------------------------------------------------------------------

  /// Returns a new map with entries whose values are `null` removed.
  ///
  /// ```dart
  /// Obj.whereNotNull({'name': 'Anna', 'email': null}); // {'name': 'Anna'}
  /// ```
  static Map<K, V> whereNotNull<K, V>(Map<K, V?> map) => {
    for (final e in map.entries)
      if (e.value != null) e.key: e.value as V,
  };

  /// Returns a new map with entries whose values are `null` or empty
  /// (empty `String`, `Iterable`, or `Map`) removed.
  ///
  /// ```dart
  /// Obj.whereNotEmpty({'name': 'Anna', 'tags': [], 'bio': ''});
  /// // {'name': 'Anna'}
  /// ```
  static Map<K, V> whereNotEmpty<K, V>(Map<K, V> map) {
    bool empty(dynamic v) {
      if (v == null) return true;
      if (v is String) return v.isEmpty;
      if (v is Iterable) return v.isEmpty;
      if (v is Map) return v.isEmpty;
      return false;
    }

    return {
      for (final e in map.entries)
        if (!empty(e.value)) e.key: e.value,
    };
  }

  // ---------------------------------------------------------------------------
  // Transform
  // ---------------------------------------------------------------------------

  /// Returns a new map with each key transformed by [fn].
  ///
  /// When [fn] produces duplicate keys, the last entry wins.
  ///
  /// ```dart
  /// Obj.mapKeys({'firstName': 'Anna'}, (k) => k.toLowerCase());
  /// // {'firstname': 'Anna'}
  /// ```
  static Map<K2, V> mapKeys<K, V, K2>(Map<K, V> map, K2 Function(K) fn) => {
    for (final e in map.entries) fn(e.key): e.value,
  };

  /// Returns a new map with each value transformed by [fn].
  ///
  /// ```dart
  /// Obj.mapValues({'a': 1, 'b': 2}, (v) => v * 10); // {'a': 10, 'b': 20}
  /// ```
  static Map<K, V2> mapValues<K, V, V2>(Map<K, V> map, V2 Function(V) fn) => {
    for (final e in map.entries) e.key: fn(e.value),
  };

  /// Swaps keys ↔ values. When values collide, the last entry wins.
  ///
  /// ```dart
  /// Obj.flip({'one': 1, 'two': 2}); // {1: 'one', 2: 'two'}
  /// ```
  static Map<V, K> flip<K, V>(Map<K, V> map) => {
    for (final e in map.entries) e.value: e.key,
  };

  // ---------------------------------------------------------------------------
  // Flatten / inflate
  // ---------------------------------------------------------------------------

  /// Flattens a nested map into a single-level map keyed by dot-paths.
  ///
  /// Source keys that already contain dots are kept verbatim, which means a
  /// `dot` → `undot` round-trip is lossy when input keys contain `.`.
  ///
  /// ```dart
  /// Obj.dot({'a': {'b': 1, 'c': 2}}); // {'a.b': 1, 'a.c': 2}
  /// ```
  static Map<String, dynamic> dot(Map map, [String prefix = '']) {
    final result = <String, dynamic>{};
    map.forEach((k, v) {
      final key = prefix.isEmpty ? k.toString() : '$prefix.$k';
      if (v is Map && v.isNotEmpty) {
        result.addAll(dot(v, key));
      } else {
        result[key] = v;
      }
    });
    return result;
  }

  /// Inflates a dot-keyed map back into a nested structure.
  ///
  /// ```dart
  /// Obj.undot({'a.b': 1, 'a.c': 2}); // {'a': {'b': 1, 'c': 2}}
  /// ```
  static Map<String, dynamic> undot(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    map.forEach((k, v) => set(result, k, v));
    return result;
  }

  // ---------------------------------------------------------------------------
  // Merge / compare / query
  // ---------------------------------------------------------------------------

  /// Recursively merges [source] into [target] and returns a new map.
  /// On key collision, [source] wins; nested maps are merged.
  ///
  /// Accepts any `Map` types (e.g. `Map<String, Object>` from typed JSON);
  /// the result is normalized to `Map<String, dynamic>`.
  static Map<String, dynamic> merge(Map target, Map source) {
    final result = <String, dynamic>{};
    target.forEach((k, v) => result[k.toString()] = v);
    source.forEach((k, v) {
      final key = k.toString();
      final existing = result[key];
      if (existing is Map && v is Map) {
        result[key] = merge(existing, v);
      } else {
        result[key] = v;
      }
    });
    return result;
  }

  /// Returns true when [a] and [b] are structurally equal.
  ///
  /// Maps and Lists are compared element-by-element and recursively, so
  /// nested collections need not share identity. Useful for `shouldRebuild`
  /// checks and state comparisons where `==` only does reference equality.
  ///
  /// ```dart
  /// Obj.deepEquals({'a': [1, 2]}, {'a': [1, 2]}); // true
  /// ```
  static bool deepEquals(dynamic a, dynamic b) {
    if (identical(a, b)) return true;
    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final k in a.keys) {
        if (!b.containsKey(k)) return false;
        if (!deepEquals(a[k], b[k])) return false;
      }
      return true;
    }
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (!deepEquals(a[i], b[i])) return false;
      }
      return true;
    }
    return a == b;
  }

  /// Encodes [map] as a URL query string.
  ///
  /// ```dart
  /// Obj.query({'name': 'Anna', 'tags': ['a', 'b']});
  /// // 'name=Anna&tags%5B0%5D=a&tags%5B1%5D=b'
  /// ```
  static String query(Map<String, dynamic> map) {
    final parts = <String>[];
    void encode(String key, dynamic value) {
      if (value is Map) {
        value.forEach((k, v) => encode('$key[$k]', v));
      } else if (value is Iterable) {
        var i = 0;
        for (final v in value) {
          encode('$key[${i++}]', v);
        }
      } else {
        parts.add(
          '${Uri.encodeQueryComponent(key)}'
          '=${Uri.encodeQueryComponent(value?.toString() ?? '')}',
        );
      }
    }

    map.forEach(encode);
    return parts.join('&');
  }
}
