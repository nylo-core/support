import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('NySession', () {
    nyGroup('constructor', () {
      nyTest('should create session with name', () async {
        final nySession = NySession(name: 'test_session');

        expect(nySession.name, 'test_session');
      });
    });

    nyGroup('add', () {
      nyTest('should add value to session', () async {
        final nySession = NySession(name: 'add_session');

        nySession.add('key1', 'value1');

        final result = nySession.get<String>('key1');
        expect(result, 'value1');
      });

      nyTest('should return self for method chaining', () async {
        final nySession = NySession(name: 'chain_session');

        final result = nySession.add('key', 'value');

        expect(result, same(nySession));
      });

      nyTest('should support method chaining', () async {
        final nySession = NySession(name: 'multi_chain_session');

        nySession
            .add('key1', 'value1')
            .add('key2', 'value2')
            .add('key3', 'value3');

        expect(nySession.get<String>('key1'), 'value1');
        expect(nySession.get<String>('key2'), 'value2');
        expect(nySession.get<String>('key3'), 'value3');
      });

      nyTest('should add various value types', () async {
        final nySession = NySession(name: 'types_session');

        nySession.add('string', 'text');
        nySession.add('int', 42);
        nySession.add('double', 3.14);
        nySession.add('bool', true);
        nySession.add('list', [1, 2, 3]);
        nySession.add('map', {'nested': 'value'});

        expect(nySession.get<String>('string'), 'text');
        expect(nySession.get<int>('int'), 42);
        expect(nySession.get<double>('double'), 3.14);
        expect(nySession.get<bool>('bool'), isTrue);
        expect(nySession.get<List>('list'), [1, 2, 3]);
        expect(nySession.get<Map>('map'), {'nested': 'value'});
      });
    });

    nyGroup('set', () {
      nyTest('should set value (alias for add)', () async {
        final nySession = NySession(name: 'set_session');

        nySession.set('key', 'value');

        expect(nySession.get<String>('key'), 'value');
      });

      nyTest('should return self for method chaining', () async {
        final nySession = NySession(name: 'set_chain_session');

        final result = nySession.set('key', 'value');

        expect(result, same(nySession));
      });
    });

    nyGroup('get', () {
      nyTest('should get existing value', () async {
        final nySession = NySession(name: 'get_session');
        nySession.add('existing', 'found');

        final result = nySession.get<String>('existing');

        expect(result, 'found');
      });

      nyTest('should return null for nonexistent key', () async {
        final nySession = NySession(name: 'get_null_session');

        final result = nySession.get<String>('nonexistent');

        expect(result, isNull);
      });

      nyTest('should return typed value', () async {
        final nySession = NySession(name: 'typed_get_session');
        nySession.add('number', 123);

        final result = nySession.get<int>('number');

        expect(result, 123);
        expect(result, isA<int>());
      });
    });

    nyGroup('delete', () {
      nyTest('should delete existing key', () async {
        final nySession = NySession(name: 'delete_session');
        nySession.add('to_delete', 'value');

        nySession.delete('to_delete');

        expect(nySession.get<String>('to_delete'), isNull);
      });

      nyTest('should return self for method chaining', () async {
        final nySession = NySession(name: 'delete_chain_session');
        nySession.add('key', 'value');

        final result = nySession.delete('key');

        expect(result, same(nySession));
      });

      nyTest('should handle deleting nonexistent key', () async {
        final nySession = NySession(name: 'delete_nonexistent_session');

        // Should not throw
        nySession.delete('nonexistent');
      });
    });

    nyGroup('flush', () {
      nyTest('should clear all session data', () async {
        final nySession = NySession(name: 'flush_session');
        nySession.add('key1', 'value1');
        nySession.add('key2', 'value2');

        nySession.flush();

        expect(nySession.get<String>('key1'), isNull);
        expect(nySession.get<String>('key2'), isNull);
      });

      nyTest('should return self for method chaining', () async {
        final nySession = NySession(name: 'flush_chain_session');

        final result = nySession.flush();

        expect(result, same(nySession));
      });
    });

    nyGroup('clear', () {
      nyTest('should clear all session data (alias for flush)', () async {
        final nySession = NySession(name: 'clear_session');
        nySession.add('key', 'value');

        nySession.clear();

        expect(nySession.get<String>('key'), isNull);
      });

      nyTest('should return self for method chaining', () async {
        final nySession = NySession(name: 'clear_chain_session');

        final result = nySession.clear();

        expect(result, same(nySession));
      });
    });

    nyGroup('data', () {
      nyTest('should return all session data', () async {
        final nySession = NySession(name: 'data_session');
        nySession.add('key1', 'value1');
        nySession.add('key2', 'value2');

        final result = nySession.data();

        expect(result, {'key1': 'value1', 'key2': 'value2'});
      });

      nyTest('should return null for empty session', () async {
        final nySession = NySession(name: 'empty_data_session');
        nySession.flush();

        final result = nySession.data();

        expect(result, isNull);
      });

      nyTest('should return specific key data when key provided', () async {
        final nySession = NySession(name: 'key_data_session');
        nySession.add('specific', 'value');
        nySession.add('other', 'other_value');

        final result = nySession.data('specific');

        expect(result, {'specific': 'value'});
      });
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // session() Helper Function Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('session() helper function', () {
    nyTest('should create NySession with name', () async {
      final nySession = session('helper_session');

      expect(nySession, isA<NySession>());
      expect(nySession.name, 'helper_session');
    });

    nyTest('should create session with initial items', () async {
      final nySession = session('init_session', {
        'key1': 'value1',
        'key2': 'value2',
      });

      expect(nySession.get<String>('key1'), 'value1');
      expect(nySession.get<String>('key2'), 'value2');
    });

    nyTest('should create empty session when no items provided', () async {
      final nySession = session('no_items_session');

      final data = nySession.data();
      expect(data, isNull);
    });

    nyTest('should support various value types in initial items', () async {
      final nySession = session('types_init_session', {
        'string': 'text',
        'int': 42,
        'bool': true,
      });

      expect(nySession.get<String>('string'), 'text');
      expect(nySession.get<int>('int'), 42);
      expect(nySession.get<bool>('bool'), isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Integration Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('NySession Integration', () {
    nyTest('should work with Backpack session methods', () async {
      final nySession = NySession(name: 'backpack_integration');
      nySession.add('test_key', 'test_value');

      // Verify data is in Backpack
      final backpackValue = Backpack.instance.sessionGet<String>(
        'backpack_integration',
        'test_key',
      );
      expect(backpackValue, 'test_value');
    });

    nyTest('multiple sessions should be independent', () async {
      final session1 = NySession(name: 'independent_session1');
      final session2 = NySession(name: 'independent_session2');

      session1.add('key', 'value1');
      session2.add('key', 'value2');

      expect(session1.get<String>('key'), 'value1');
      expect(session2.get<String>('key'), 'value2');
    });

    nyTest('should support complete CRUD workflow', () async {
      final nySession = NySession(name: 'crud_session');

      // Create
      nySession.add('item', 'created');
      expect(nySession.get<String>('item'), 'created');

      // Read
      final readValue = nySession.get<String>('item');
      expect(readValue, 'created');

      // Update
      nySession.add('item', 'updated');
      expect(nySession.get<String>('item'), 'updated');

      // Delete
      nySession.delete('item');
      expect(nySession.get<String>('item'), isNull);
    });

    nyTest('should handle complex nested data', () async {
      final nySession = NySession(name: 'nested_session');

      final complexData = {
        'user': {
          'name': 'John',
          'address': {'city': 'New York', 'zip': '10001'},
          'tags': ['admin', 'user'],
        },
      };

      nySession.add('complex', complexData);

      final result = nySession.get<Map<String, dynamic>>('complex');
      expect(result?['user']['name'], 'John');
      expect(result?['user']['address']['city'], 'New York');
      expect(result?['user']['tags'], ['admin', 'user']);
    });
  });
}
