import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/testing/src/mocks/ny_test_cache.dart';
import 'package:nylo_support/testing/src/ny_time.dart';

void main() {
  setUp(() {
    NyTestCache.resetInstance();
    NyTime.reset();
  });

  tearDown(() {
    NyTestCache.resetInstance();
    NyTime.reset();
  });

  group('NyTestCache', () {
    group('getInstance()', () {
      test('returns singleton instance', () {
        final cache1 = NyTestCache.getInstance();
        final cache2 = NyTestCache.getInstance();

        expect(identical(cache1, cache2), isTrue);
      });
    });

    group('resetInstance()', () {
      test('clears cache and creates new instance', () async {
        final cache1 = NyTestCache.getInstance();
        await cache1.put('key', 'value');

        NyTestCache.resetInstance();

        final cache2 = NyTestCache.getInstance();
        expect(await cache2.get('key'), isNull);
        expect(identical(cache1, cache2), isFalse);
      });
    });

    group('put() and get()', () {
      test('stores and retrieves value', () async {
        final cache = NyTestCache.getInstance();
        await cache.put('key', 'value');

        final result = await cache.get<String>('key');
        expect(result, equals('value'));
      });

      test('stores different types', () async {
        final cache = NyTestCache.getInstance();
        await cache.put('string', 'hello');
        await cache.put('int', 42);
        await cache.put('bool', true);
        await cache.put('list', [1, 2, 3]);
        await cache.put('map', {'a': 1});

        expect(await cache.get<String>('string'), equals('hello'));
        expect(await cache.get<int>('int'), equals(42));
        expect(await cache.get<bool>('bool'), equals(true));
        expect(await cache.get<List>('list'), equals([1, 2, 3]));
        expect(await cache.get<Map>('map'), equals({'a': 1}));
      });

      test('returns null for missing key', () async {
        final cache = NyTestCache.getInstance();
        final result = await cache.get('nonexistent');

        expect(result, isNull);
      });

      test('respects expiration', () async {
        final cache = NyTestCache.getInstance();
        NyTime.setTestNow(DateTime(2025, 1, 1, 10, 0, 0));

        await cache.put('key', 'value', seconds: 60);

        // Before expiration
        expect(await cache.get('key'), equals('value'));

        // After expiration
        NyTime.advanceBy(const Duration(seconds: 61));
        expect(await cache.get('key'), isNull);
      });

      test('value without expiration persists', () async {
        final cache = NyTestCache.getInstance();
        NyTime.setTestNow(DateTime(2025, 1, 1, 10, 0, 0));

        await cache.put('key', 'value');

        // Advance time significantly
        NyTime.advanceBy(const Duration(days: 365));
        expect(await cache.get('key'), equals('value'));
      });
    });

    group('saveRemember()', () {
      test('saves and returns value from callback', () async {
        final cache = NyTestCache.getInstance();

        final result = await cache.saveRemember<String>(
          'key',
          60,
          () => 'computed value',
        );

        expect(result, equals('computed value'));
        expect(await cache.get('key'), equals('computed value'));
      });

      test('returns cached value without calling callback again', () async {
        final cache = NyTestCache.getInstance();
        var callCount = 0;

        await cache.saveRemember<String>('key', 60, () {
          callCount++;
          return 'value';
        });

        await cache.saveRemember<String>('key', 60, () {
          callCount++;
          return 'new value';
        });

        expect(callCount, equals(1));
      });

      test('calls callback again after expiration', () async {
        final cache = NyTestCache.getInstance();
        NyTime.setTestNow(DateTime(2025, 1, 1, 10, 0, 0));
        var callCount = 0;

        await cache.saveRemember<String>('key', 60, () {
          callCount++;
          return 'value $callCount';
        });

        // Expire the cache
        NyTime.advanceBy(const Duration(seconds: 61));

        final result = await cache.saveRemember<String>('key', 60, () {
          callCount++;
          return 'value $callCount';
        });

        expect(callCount, equals(2));
        expect(result, equals('value 2'));
      });

      test('handles async callback', () async {
        final cache = NyTestCache.getInstance();

        final result = await cache.saveRemember<String>('key', 60, () async {
          await Future.delayed(const Duration(milliseconds: 10));
          return 'async value';
        });

        expect(result, equals('async value'));
      });
    });

    group('saveForever()', () {
      test('saves value without expiration', () async {
        final cache = NyTestCache.getInstance();
        NyTime.setTestNow(DateTime(2025, 1, 1, 10, 0, 0));

        await cache.saveForever<String>('key', () async => 'forever value');

        // Advance time significantly
        NyTime.advanceBy(const Duration(days: 3650));
        expect(await cache.get('key'), equals('forever value'));
      });

      test('returns cached value without calling callback again', () async {
        final cache = NyTestCache.getInstance();
        var callCount = 0;

        await cache.saveForever<String>('key', () async {
          callCount++;
          return 'value';
        });

        await cache.saveForever<String>('key', () async {
          callCount++;
          return 'new value';
        });

        expect(callCount, equals(1));
        expect(await cache.get('key'), equals('value'));
      });
    });

    group('clear()', () {
      test('removes specific key', () async {
        final cache = NyTestCache.getInstance();
        await cache.put('key1', 'value1');
        await cache.put('key2', 'value2');

        await cache.clear('key1');

        expect(await cache.get('key1'), isNull);
        expect(await cache.get('key2'), equals('value2'));
      });
    });

    group('flush()', () {
      test('removes all keys', () async {
        final cache = NyTestCache.getInstance();
        await cache.put('key1', 'value1');
        await cache.put('key2', 'value2');
        await cache.put('key3', 'value3');

        await cache.flush();

        expect(await cache.get('key1'), isNull);
        expect(await cache.get('key2'), isNull);
        expect(await cache.get('key3'), isNull);
        expect(cache.isEmpty, isTrue);
      });
    });

    group('documents()', () {
      test('returns list of all keys', () async {
        final cache = NyTestCache.getInstance();
        await cache.put('key1', 'value1');
        await cache.put('key2', 'value2');
        await cache.put('key3', 'value3');

        final keys = await cache.documents();

        expect(keys, containsAll(['key1', 'key2', 'key3']));
        expect(keys.length, equals(3));
      });

      test('returns empty list when cache is empty', () async {
        final cache = NyTestCache.getInstance();
        final keys = await cache.documents();

        expect(keys, isEmpty);
      });
    });

    group('has()', () {
      test('returns true when key exists', () async {
        final cache = NyTestCache.getInstance();
        await cache.put('key', 'value');

        expect(await cache.has('key'), isTrue);
      });

      test('returns false when key does not exist', () async {
        final cache = NyTestCache.getInstance();

        expect(await cache.has('nonexistent'), isFalse);
      });
    });

    group('size()', () {
      test('returns approximate size in bytes', () async {
        final cache = NyTestCache.getInstance();
        await cache.put('key1', 'short');
        await cache.put('key2', 'a much longer string value');

        final size = await cache.size();

        expect(size, greaterThan(0));
      });

      test('returns 0 for empty cache', () async {
        final cache = NyTestCache.getInstance();
        final size = await cache.size();

        expect(size, equals(0));
      });
    });

    group('entries', () {
      test('returns map of all entries', () async {
        final cache = NyTestCache.getInstance();
        await cache.put('key1', 'value1');
        await cache.put('key2', 'value2');

        final entries = cache.entries;

        expect(entries['key1'], equals('value1'));
        expect(entries['key2'], equals('value2'));
      });
    });

    group('count', () {
      test('returns number of entries', () async {
        final cache = NyTestCache.getInstance();
        await cache.put('key1', 'value1');
        await cache.put('key2', 'value2');
        await cache.put('key3', 'value3');

        expect(cache.count, equals(3));
      });

      test('returns 0 for empty cache', () {
        final cache = NyTestCache.getInstance();
        expect(cache.count, equals(0));
      });
    });

    group('isEmpty', () {
      test('returns true when empty', () {
        final cache = NyTestCache.getInstance();
        expect(cache.isEmpty, isTrue);
      });

      test('returns false when not empty', () async {
        final cache = NyTestCache.getInstance();
        await cache.put('key', 'value');

        expect(cache.isEmpty, isFalse);
      });
    });

    group('isNotEmpty', () {
      test('returns false when empty', () {
        final cache = NyTestCache.getInstance();
        expect(cache.isNotEmpty, isFalse);
      });

      test('returns true when not empty', () async {
        final cache = NyTestCache.getInstance();
        await cache.put('key', 'value');

        expect(cache.isNotEmpty, isTrue);
      });
    });
  });
}
