import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  // ===========================================================================
  // Read
  // ===========================================================================

  nyGroup('Obj.get', () {
    nyTest('returns top-level value', () async {
      expect(Obj.get({'a': 1}, 'a'), 1);
    });
    nyTest('traverses nested maps via dot notation', () async {
      expect(
        Obj.get({
          'a': {
            'b': {'c': 5},
          },
        }, 'a.b.c'),
        5,
      );
    });
    nyTest('returns defaultValue when path missing', () async {
      expect(Obj.get({'a': 1}, 'b.c', 'fallback'), 'fallback');
    });
    nyTest('returns null when path missing and no default', () async {
      expect(Obj.get({'a': 1}, 'x'), isNull);
    });
    nyTest('respects literal-dot top-level keys', () async {
      expect(Obj.get({'a.b': 'literal'}, 'a.b'), 'literal');
    });
    nyTest('traverses lists by index', () async {
      expect(
        Obj.get({
          'users': [
            {'name': 'A'},
          ],
        }, 'users.0.name'),
        'A',
      );
    });
  });

  nyGroup('Obj.has', () {
    nyTest('returns true when path exists', () async {
      expect(
        Obj.has({
          'a': {'b': 1},
        }, 'a.b'),
        isTrue,
      );
    });
    nyTest('returns false when path missing', () async {
      expect(Obj.has({'a': 1}, 'b'), isFalse);
    });
    nyTest('returns true for null value at path', () async {
      expect(Obj.has({'a': null}, 'a'), isTrue);
    });
  });

  nyGroup('Obj.hasAny', () {
    nyTest('returns true when at least one key resolves', () async {
      expect(Obj.hasAny({'a': 1}, ['x', 'y', 'a']), isTrue);
    });
    nyTest('returns false when none resolve', () async {
      expect(Obj.hasAny({'a': 1}, ['x', 'y']), isFalse);
    });
  });

  nyGroup('Obj.hasAll', () {
    nyTest('returns true when every key resolves', () async {
      expect(
        Obj.hasAll(
          {
            'a': 1,
            'b': {'c': 2},
          },
          ['a', 'b.c'],
        ),
        isTrue,
      );
    });
    nyTest('returns false when any key is missing', () async {
      expect(Obj.hasAll({'a': 1}, ['a', 'x']), isFalse);
    });
    nyTest('vacuously true for empty key list', () async {
      expect(Obj.hasAll({'a': 1}, <String>[]), isTrue);
    });
  });

  nyGroup('Obj.exists', () {
    nyTest('returns true for top-level key', () async {
      expect(Obj.exists({'a.b': 1}, 'a.b'), isTrue);
    });
    nyTest('does not traverse', () async {
      expect(
        Obj.exists({
          'a': {'b': 1},
        }, 'a.b'),
        isFalse,
      );
    });
  });

  // ===========================================================================
  // Write
  // ===========================================================================

  nyGroup('Obj.set', () {
    nyTest('sets top-level value', () async {
      final m = <String, dynamic>{};
      Obj.set(m, 'a', 1);
      expect(m, {'a': 1});
    });
    nyTest('creates nested path', () async {
      final m = <String, dynamic>{};
      Obj.set(m, 'a.b.c', 5);
      expect(m, {
        'a': {
          'b': {'c': 5},
        },
      });
    });
    nyTest('overwrites existing leaf', () async {
      final m = <String, dynamic>{
        'a': {'b': 1},
      };
      Obj.set(m, 'a.b', 2);
      expect(m, {
        'a': {'b': 2},
      });
    });
    nyTest('returns the map for chaining', () async {
      final m = <String, dynamic>{};
      expect(identical(Obj.set(m, 'x', 1), m), isTrue);
    });
    nyTest('does not clobber non-collection intermediates', () async {
      final m = <String, dynamic>{'a': 'literal'};
      Obj.set(m, 'a.b', 99);
      expect(m, {'a': 'literal'});
    });
    nyTest('updates a list element via integer segment', () async {
      final m = <String, dynamic>{
        'users': [
          {'name': 'Anna'},
          {'name': 'Brad'},
        ],
      };
      Obj.set(m, 'users.1.name', 'Brent');
      expect(m['users'][1]['name'], 'Brent');
    });
  });

  nyGroup('Obj.add', () {
    nyTest('adds when key absent', () async {
      final m = <String, dynamic>{};
      Obj.add(m, 'a', 1);
      expect(m, {'a': 1});
    });
    nyTest('does not overwrite when present', () async {
      final m = <String, dynamic>{'a': 1};
      Obj.add(m, 'a', 99);
      expect(m, {'a': 1});
    });
  });

  nyGroup('Obj.forget', () {
    nyTest('removes top-level key', () async {
      final m = <String, dynamic>{'a': 1, 'b': 2};
      Obj.forget(m, 'a');
      expect(m, {'b': 2});
    });
    nyTest('removes nested key via dot notation', () async {
      final m = <String, dynamic>{
        'a': {'b': 1, 'c': 2},
      };
      Obj.forget(m, 'a.b');
      expect(m, {
        'a': {'c': 2},
      });
    });
    nyTest('is a no-op when path missing', () async {
      final m = <String, dynamic>{'a': 1};
      Obj.forget(m, 'x.y.z');
      expect(m, {'a': 1});
    });
    nyTest('removes an element from a list', () async {
      final m = <String, dynamic>{
        'users': ['Anna', 'Brad', 'Cara'],
      };
      Obj.forget(m, 'users.1');
      expect(m['users'], ['Anna', 'Cara']);
    });
  });

  nyGroup('Obj.pull', () {
    nyTest('returns and removes value', () async {
      final m = <String, dynamic>{'a': 1, 'b': 2};
      expect(Obj.pull(m, 'a'), 1);
      expect(m, {'b': 2});
    });
    nyTest('returns defaultValue for missing key', () async {
      expect(Obj.pull(<String, dynamic>{}, 'x', 99), 99);
    });
  });

  // ===========================================================================
  // Subset
  // ===========================================================================

  nyGroup('Obj.only', () {
    nyTest('returns only specified keys', () async {
      expect(Obj.only({'a': 1, 'b': 2, 'c': 3}, ['a', 'c']), {'a': 1, 'c': 3});
    });
    nyTest('skips missing keys', () async {
      expect(Obj.only({'a': 1}, ['a', 'b']), {'a': 1});
    });
  });

  nyGroup('Obj.except', () {
    nyTest('returns all except specified keys', () async {
      expect(Obj.except({'a': 1, 'b': 2, 'c': 3}, ['b']), {'a': 1, 'c': 3});
    });
  });

  nyGroup('Obj.prependKeysWith', () {
    nyTest('prefixes top-level keys', () async {
      expect(Obj.prependKeysWith({'name': 'A', 'age': 30}, 'user_'), {
        'user_name': 'A',
        'user_age': 30,
      });
    });
  });

  nyGroup('Obj.divide', () {
    nyTest('returns [keys, values]', () async {
      expect(Obj.divide({'name': 'Desk', 'price': 100}), [
        ['name', 'price'],
        ['Desk', 100],
      ]);
    });
    nyTest('returns two empty lists for empty map', () async {
      expect(Obj.divide({}), [[], []]);
    });
  });

  // ===========================================================================
  // Flatten / inflate
  // ===========================================================================

  nyGroup('Obj.dot', () {
    nyTest('flattens nested maps', () async {
      expect(
        Obj.dot({
          'a': {'b': 1, 'c': 2},
        }),
        {'a.b': 1, 'a.c': 2},
      );
    });
    nyTest('handles deeply nested', () async {
      expect(
        Obj.dot({
          'a': {
            'b': {
              'c': {'d': 'x'},
            },
          },
        }),
        {'a.b.c.d': 'x'},
      );
    });
    nyTest('preserves leaf values that are not maps', () async {
      expect(
        Obj.dot({
          'a': [1, 2],
          'b': 'x',
        }),
        {
          'a': [1, 2],
          'b': 'x',
        },
      );
    });
  });

  nyGroup('Obj.undot', () {
    nyTest('inflates dot-keyed map', () async {
      expect(Obj.undot({'a.b': 1, 'a.c': 2}), {
        'a': {'b': 1, 'c': 2},
      });
    });
    nyTest('round-trips with dot', () async {
      final original = {
        'user': {
          'name': 'Anna',
          'address': {'city': 'NYC'},
        },
      };
      expect(Obj.undot(Obj.dot(original)), original);
    });
  });

  // ===========================================================================
  // Merge / query
  // ===========================================================================

  nyGroup('Obj.merge', () {
    nyTest('merges flat maps with source winning', () async {
      expect(Obj.merge({'a': 1, 'b': 2}, {'b': 99, 'c': 3}), {
        'a': 1,
        'b': 99,
        'c': 3,
      });
    });
    nyTest('deeply merges nested maps', () async {
      expect(
        Obj.merge(
          {
            'user': {'name': 'A', 'age': 30},
          },
          {
            'user': {'age': 31, 'email': 'x'},
          },
        ),
        {
          'user': {'name': 'A', 'age': 31, 'email': 'x'},
        },
      );
    });
    nyTest('handles non-Map<String, dynamic> input', () async {
      final Map<String, Object> a = {
        'a': 1,
        'b': {'x': 1},
      };
      final Map<String, Object> b = {
        'b': {'y': 2},
      };
      expect(Obj.merge(a, b), {
        'a': 1,
        'b': {'x': 1, 'y': 2},
      });
    });
  });

  nyGroup('Obj.query', () {
    nyTest('encodes flat map', () async {
      expect(Obj.query({'name': 'Anna', 'age': 30}), 'name=Anna&age=30');
    });
    nyTest('encodes list values with bracketed indices', () async {
      expect(
        Obj.query({
          'tags': ['a', 'b'],
        }),
        'tags%5B0%5D=a&tags%5B1%5D=b',
      );
    });
    nyTest('encodes nested maps', () async {
      expect(
        Obj.query({
          'user': {'name': 'Anna'},
        }),
        'user%5Bname%5D=Anna',
      );
    });
    nyTest('url-encodes special characters', () async {
      expect(Obj.query({'q': 'hello world'}), 'q=hello+world');
    });
  });

  // ===========================================================================
  // Typed read
  // ===========================================================================

  nyGroup('Obj.getString', () {
    nyTest('returns String value as-is', () async {
      expect(Obj.getString({'name': 'Anna'}, 'name'), 'Anna');
    });
    nyTest('coerces non-string values via toString', () async {
      expect(Obj.getString({'age': 30}, 'age'), '30');
    });
    nyTest('returns defaultValue when missing', () async {
      expect(Obj.getString({}, 'name', 'unknown'), 'unknown');
    });
    nyTest('returns defaultValue when null', () async {
      expect(Obj.getString({'name': null}, 'name', 'fallback'), 'fallback');
    });
    nyTest('traverses dot notation', () async {
      expect(
        Obj.getString({
          'user': {'name': 'A'},
        }, 'user.name'),
        'A',
      );
    });
  });

  nyGroup('Obj.getInt', () {
    nyTest('returns int value as-is', () async {
      expect(Obj.getInt({'age': 30}, 'age'), 30);
    });
    nyTest('parses int from String', () async {
      expect(Obj.getInt({'age': '30'}, 'age'), 30);
    });
    nyTest('truncates double', () async {
      expect(Obj.getInt({'age': 30.7}, 'age'), 30);
    });
    nyTest('coerces bool to 1/0', () async {
      expect(Obj.getInt({'a': true, 'b': false}, 'a'), 1);
      expect(Obj.getInt({'a': true, 'b': false}, 'b'), 0);
    });
    nyTest('returns defaultValue on parse failure', () async {
      expect(Obj.getInt({'age': 'abc'}, 'age', -1), -1);
    });
    nyTest('returns defaultValue when missing', () async {
      expect(Obj.getInt({}, 'age', 99), 99);
    });
  });

  nyGroup('Obj.getDouble', () {
    nyTest('returns double value as-is', () async {
      expect(Obj.getDouble({'price': 9.99}, 'price'), 9.99);
    });
    nyTest('widens int to double', () async {
      expect(Obj.getDouble({'price': 10}, 'price'), 10.0);
    });
    nyTest('parses double from String', () async {
      expect(Obj.getDouble({'price': '9.99'}, 'price'), 9.99);
    });
    nyTest('returns defaultValue on parse failure', () async {
      expect(Obj.getDouble({'price': 'abc'}, 'price', 0.0), 0.0);
    });
  });

  nyGroup('Obj.getBool', () {
    nyTest('returns bool value as-is', () async {
      expect(Obj.getBool({'flag': true}, 'flag'), isTrue);
      expect(Obj.getBool({'flag': false}, 'flag'), isFalse);
    });
    nyTest('parses common truthy strings', () async {
      expect(Obj.getBool({'a': 'true'}, 'a'), isTrue);
      expect(Obj.getBool({'a': 'YES'}, 'a'), isTrue);
      expect(Obj.getBool({'a': '1'}, 'a'), isTrue);
      expect(Obj.getBool({'a': 'on'}, 'a'), isTrue);
    });
    nyTest('parses common falsy strings', () async {
      expect(Obj.getBool({'a': 'false'}, 'a'), isFalse);
      expect(Obj.getBool({'a': 'no'}, 'a'), isFalse);
      expect(Obj.getBool({'a': '0'}, 'a'), isFalse);
      expect(Obj.getBool({'a': 'off'}, 'a'), isFalse);
    });
    nyTest('treats numbers as truthy when non-zero', () async {
      expect(Obj.getBool({'a': 1}, 'a'), isTrue);
      expect(Obj.getBool({'a': 0}, 'a'), isFalse);
      expect(Obj.getBool({'a': 0.5}, 'a'), isTrue);
    });
    nyTest('returns defaultValue on unrecognized string', () async {
      expect(Obj.getBool({'a': 'maybe'}, 'a', false), isFalse);
    });
  });

  nyGroup('Obj.getList', () {
    nyTest('returns List value', () async {
      expect(
        Obj.getList({
          'tags': [1, 2, 3],
        }, 'tags'),
        [1, 2, 3],
      );
    });
    nyTest('returns defaultValue when not a List', () async {
      expect(Obj.getList({'tags': 'oops'}, 'tags', []), []);
    });
    nyTest('returns defaultValue when missing', () async {
      expect(Obj.getList({}, 'tags', []), []);
    });
  });

  nyGroup('Obj.getMap', () {
    nyTest('returns Map value', () async {
      expect(
        Obj.getMap({
          'profile': {'a': 1},
        }, 'profile'),
        {'a': 1},
      );
    });
    nyTest('returns defaultValue when not a Map', () async {
      expect(Obj.getMap({'profile': 'oops'}, 'profile', {}), {});
    });
  });

  // ===========================================================================
  // Filter
  // ===========================================================================

  nyGroup('Obj.whereNotNull', () {
    nyTest('removes null entries', () async {
      expect(Obj.whereNotNull({'name': 'Anna', 'email': null}), {
        'name': 'Anna',
      });
    });
    nyTest('keeps falsy non-null values', () async {
      expect(Obj.whereNotNull({'a': 0, 'b': '', 'c': false, 'd': null}), {
        'a': 0,
        'b': '',
        'c': false,
      });
    });
  });

  nyGroup('Obj.whereNotEmpty', () {
    nyTest('removes null, empty string, list, map values', () async {
      expect(
        Obj.whereNotEmpty({
          'name': 'Anna',
          'tags': [],
          'bio': '',
          'meta': <String, dynamic>{},
          'email': null,
        }),
        {'name': 'Anna'},
      );
    });
    nyTest('keeps zero and false', () async {
      expect(Obj.whereNotEmpty({'a': 0, 'b': false}), {'a': 0, 'b': false});
    });
  });

  // ===========================================================================
  // Transform
  // ===========================================================================

  nyGroup('Obj.mapKeys', () {
    nyTest('transforms keys', () async {
      expect(Obj.mapKeys({'firstName': 'Anna'}, (k) => k.toLowerCase()), {
        'firstname': 'Anna',
      });
    });
    nyTest('last duplicate key wins', () async {
      expect(Obj.mapKeys({'a': 1, 'b': 2}, (_) => 'k'), {'k': 2});
    });
  });

  nyGroup('Obj.mapValues', () {
    nyTest('transforms values', () async {
      expect(Obj.mapValues({'a': 1, 'b': 2}, (v) => v * 10), {
        'a': 10,
        'b': 20,
      });
    });
    nyTest('can change value type', () async {
      expect(
        Obj.mapValues<String, int, String>({'a': 1, 'b': 2}, (v) => 'v$v'),
        {'a': 'v1', 'b': 'v2'},
      );
    });
  });

  nyGroup('Obj.flip', () {
    nyTest('swaps keys and values', () async {
      expect(Obj.flip({'one': 1, 'two': 2}), {1: 'one', 2: 'two'});
    });
    nyTest('last duplicate value wins', () async {
      expect(Obj.flip({'a': 1, 'b': 1}), {1: 'b'});
    });
  });

  // ===========================================================================
  // Compare
  // ===========================================================================

  nyGroup('Obj.deepEquals', () {
    nyTest('returns true for identical primitives', () async {
      expect(Obj.deepEquals(1, 1), isTrue);
      expect(Obj.deepEquals('x', 'x'), isTrue);
      expect(Obj.deepEquals(null, null), isTrue);
    });
    nyTest('returns false for different primitives', () async {
      expect(Obj.deepEquals(1, 2), isFalse);
    });
    nyTest('returns true for structurally equal maps', () async {
      expect(Obj.deepEquals({'a': 1, 'b': 2}, {'a': 1, 'b': 2}), isTrue);
    });
    nyTest('returns true for deeply nested equal maps', () async {
      expect(
        Obj.deepEquals(
          {
            'user': {
              'name': 'A',
              'tags': [1, 2],
            },
          },
          {
            'user': {
              'name': 'A',
              'tags': [1, 2],
            },
          },
        ),
        isTrue,
      );
    });
    nyTest('returns false when nested values differ', () async {
      expect(
        Obj.deepEquals(
          {
            'user': {
              'tags': [1, 2],
            },
          },
          {
            'user': {
              'tags': [1, 3],
            },
          },
        ),
        isFalse,
      );
    });
    nyTest('returns false for different lengths', () async {
      expect(Obj.deepEquals([1, 2], [1, 2, 3]), isFalse);
      expect(Obj.deepEquals({'a': 1}, {'a': 1, 'b': 2}), isFalse);
    });
    nyTest('returns false when one side has missing key', () async {
      expect(Obj.deepEquals({'a': 1, 'b': 2}, {'a': 1, 'c': 2}), isFalse);
    });
  });
}
