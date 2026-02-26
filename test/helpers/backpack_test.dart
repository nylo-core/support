import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/testing/ny_testing.dart';

/// Test model for Backpack deserialization tests
class _BackpackTestModel extends Model {
  String? name;
  int? age;

  _BackpackTestModel.fromJson(Map<String, dynamic> data) {
    name = data['name'];
    age = data['age'];
  }

  @override
  Map<String, dynamic> toJson() => {'name': name, 'age': age};
}

void main() {
  NyTest.init();

  nyGroup('Backpack', () {
    nyGroup('singleton instance', () {
      nyTest('should return the same instance', () async {
        final instance1 = Backpack.instance;
        final instance2 = Backpack.instance;

        expect(identical(instance1, instance2), isTrue);
      });
    });

    nyGroup('save and read', () {
      nyTest('should save and read a string value', () async {
        Backpack.instance.save('test_key', 'test_value');

        final result = Backpack.instance.read<String>('test_key');

        expect(result, 'test_value');
      });

      nyTest('should save and read an int value', () async {
        Backpack.instance.save('int_key', 42);

        final result = Backpack.instance.read<int>('int_key');

        expect(result, 42);
      });

      nyTest('should save and read a double value', () async {
        Backpack.instance.save('double_key', 3.14);

        final result = Backpack.instance.read<double>('double_key');

        expect(result, 3.14);
      });

      nyTest('should save and read a bool value', () async {
        Backpack.instance.save('bool_key', true);

        final result = Backpack.instance.read<bool>('bool_key');

        expect(result, isTrue);
      });

      nyTest('should save and read a list', () async {
        Backpack.instance.save('list_key', [1, 2, 3]);

        final result = Backpack.instance.read<List<int>>('list_key');

        expect(result, [1, 2, 3]);
      });

      nyTest('should save and read a map', () async {
        Backpack.instance.save('map_key', {'name': 'test', 'value': 123});

        final result = Backpack.instance.read<Map<String, dynamic>>('map_key');

        expect(result, {'name': 'test', 'value': 123});
      });

      nyTest('should return null for nonexistent key', () async {
        final result = Backpack.instance.read<String>('nonexistent_key');

        expect(result, isNull);
      });

      nyTest(
        'should return defaultValue for nonexistent key when provided',
        () async {
          final result = Backpack.instance.read<String>(
            'nonexistent_with_default',
            defaultValue: 'default',
          );

          expect(result, 'default');
        },
      );

      nyTest('should overwrite existing value', () async {
        Backpack.instance.save('overwrite_key', 'original');
        Backpack.instance.save('overwrite_key', 'updated');

        final result = Backpack.instance.read<String>('overwrite_key');

        expect(result, 'updated');
      });
    });

    nyGroup('contains', () {
      nyTest('should return true for existing key', () async {
        Backpack.instance.save('exists_key', 'value');

        final result = Backpack.instance.contains('exists_key');

        expect(result, isTrue);
      });

      nyTest('should return false for nonexistent key', () async {
        final result = Backpack.instance.contains('does_not_exist_key');

        expect(result, isFalse);
      });
    });

    nyGroup('delete', () {
      nyTest('should delete an existing key', () async {
        Backpack.instance.save('to_delete', 'value');
        expect(Backpack.instance.contains('to_delete'), isTrue);

        Backpack.instance.delete('to_delete');

        expect(Backpack.instance.contains('to_delete'), isFalse);
      });

      nyTest('should handle deleting nonexistent key gracefully', () async {
        // Should not throw
        Backpack.instance.delete('nonexistent_delete');
      });
    });

    nyGroup('deleteAll', () {
      nyTest('should delete all user keys', () async {
        Backpack.instance.save('user_key1', 'value1');
        Backpack.instance.save('user_key2', 'value2');
        Backpack.instance.save('user_key3', 'value3');

        Backpack.instance.deleteAll();

        expect(Backpack.instance.contains('user_key1'), isFalse);
        expect(Backpack.instance.contains('user_key2'), isFalse);
        expect(Backpack.instance.contains('user_key3'), isFalse);
      });

      nyTest('should preserve nylo and event_bus keys', () async {
        // This test verifies the protected keys behavior
        Backpack.instance.save('nylo', 'nylo_instance');
        Backpack.instance.save('event_bus', 'event_bus_instance');
        Backpack.instance.save('user_data', 'to_delete');

        Backpack.instance.deleteAll();

        expect(Backpack.instance.contains('nylo'), isTrue);
        expect(Backpack.instance.contains('event_bus'), isTrue);
        expect(Backpack.instance.contains('user_data'), isFalse);
      });
    });

    nyGroup('append', () {
      nyTest(
        'should create list and add value when key does not exist',
        () async {
          Backpack.instance.delete('append_new');

          Backpack.instance.append('append_new', 'item1', append: true);

          final result = Backpack.instance.read<List>('append_new');
          expect(result, ['item1']);
        },
      );

      nyTest('should append to existing list', () async {
        Backpack.instance.save('append_existing', ['item1']);

        Backpack.instance.append('append_existing', 'item2', append: true);

        final result = Backpack.instance.read<List>('append_existing');
        expect(result, ['item1', 'item2']);
      });

      nyTest('should replace value when append is false', () async {
        Backpack.instance.save('append_replace', ['item1']);

        Backpack.instance.append('append_replace', 'replaced', append: false);

        final result = Backpack.instance.read<String>('append_replace');
        expect(result, 'replaced');
      });

      nyTest('should respect limit parameter', () async {
        Backpack.instance.delete('append_limit');

        Backpack.instance.append(
          'append_limit',
          'item1',
          append: true,
          limit: 3,
        );
        Backpack.instance.append(
          'append_limit',
          'item2',
          append: true,
          limit: 3,
        );
        Backpack.instance.append(
          'append_limit',
          'item3',
          append: true,
          limit: 3,
        );
        Backpack.instance.append(
          'append_limit',
          'item4',
          append: true,
          limit: 3,
        );

        final result = Backpack.instance.read<List>('append_limit');
        expect(result?.length, 3);
        expect(result, ['item2', 'item3', 'item4']);
      });
    });

    nyGroup('session methods', () {
      nyTest('should update session value', () async {
        Backpack.instance.sessionUpdate('test_session', 'key1', 'value1');

        final result = Backpack.instance.sessionGet<String>(
          'test_session',
          'key1',
        );

        expect(result, 'value1');
      });

      nyTest('should get session value', () async {
        Backpack.instance.sessionUpdate('get_session', 'mykey', 'myvalue');

        final result = Backpack.instance.sessionGet<String>(
          'get_session',
          'mykey',
        );

        expect(result, 'myvalue');
      });

      nyTest('should return null for nonexistent session', () async {
        final result = Backpack.instance.sessionGet<String>(
          'nonexistent_session',
          'key',
        );

        expect(result, isNull);
      });

      nyTest('should return null for nonexistent key in session', () async {
        Backpack.instance.sessionUpdate('partial_session', 'exists', 'value');

        final result = Backpack.instance.sessionGet<String>(
          'partial_session',
          'not_exists',
        );

        expect(result, isNull);
      });

      nyTest('should remove session value', () async {
        Backpack.instance.sessionUpdate('remove_session', 'to_remove', 'value');

        Backpack.instance.sessionRemove('remove_session', 'to_remove');

        final result = Backpack.instance.sessionGet<String>(
          'remove_session',
          'to_remove',
        );
        expect(result, isNull);
      });

      nyTest('should handle removing from nonexistent session', () async {
        // Should not throw
        Backpack.instance.sessionRemove('nonexistent_remove_session', 'key');
      });

      nyTest('should flush session', () async {
        Backpack.instance.sessionUpdate('flush_session', 'key1', 'value1');
        Backpack.instance.sessionUpdate('flush_session', 'key2', 'value2');

        Backpack.instance.sessionFlush('flush_session');

        final result = Backpack.instance.sessionGet<String>(
          'flush_session',
          'key1',
        );
        expect(result, isNull);
      });

      nyTest('should handle flushing nonexistent session', () async {
        // Should not throw
        Backpack.instance.sessionFlush('nonexistent_flush_session');
      });

      nyTest('should get all session data', () async {
        Backpack.instance.sessionUpdate('data_session', 'key1', 'value1');
        Backpack.instance.sessionUpdate('data_session', 'key2', 'value2');

        final data = Backpack.instance.sessionData('data_session');

        expect(data, {'key1': 'value1', 'key2': 'value2'});
      });

      nyTest('should return null for nonexistent session data', () async {
        final data = Backpack.instance.sessionData('nonexistent_data_session');

        expect(data, isNull);
      });
    });

    nyGroup('Map deserialization', () {
      nyTest(
        'should deserialize Map value to typed model when T is specified',
        () async {
          // Set up Nylo with model decoders so dataToModel works
          final nylo = Nylo();
          nylo.addModelDecoders({
            _BackpackTestModel: (data) => _BackpackTestModel.fromJson(data),
          });

          // Simulate what syncKeys does: store a raw Map in Backpack
          Backpack.instance.save('user_model', {'name': 'Alice', 'age': 30});

          final result = Backpack.instance.read<_BackpackTestModel>(
            'user_model',
          );

          expect(result, isA<_BackpackTestModel>());
          expect(result?.name, 'Alice');
          expect(result?.age, 30);
        },
      );

      nyTest(
        'should cache deserialized model in Backpack after first read',
        () async {
          final nylo = Nylo();
          nylo.addModelDecoders({
            _BackpackTestModel: (data) => _BackpackTestModel.fromJson(data),
          });

          Backpack.instance.save('cached_model', {'name': 'Bob', 'age': 25});

          // First read deserializes
          final first = Backpack.instance.read<_BackpackTestModel>(
            'cached_model',
          );
          // Second read should return cached model instance
          final second = Backpack.instance.read<_BackpackTestModel>(
            'cached_model',
          );

          expect(identical(first, second), isTrue);
        },
      );

      nyTest('should return raw Map when T is dynamic', () async {
        Backpack.instance.save('raw_map', {'key': 'value'});

        final result = Backpack.instance.read('raw_map');

        expect(result, isA<Map>());
        expect(result['key'], 'value');
      });

      nyTest(
        'should fall through gracefully for Map without matching decoder',
        () async {
          final nylo = Nylo();
          nylo.addModelDecoders({});

          Backpack.instance.save('no_decoder_map', {'name': 'test'});

          // Reading with a type that has no decoder should not throw
          final result = Backpack.instance.read('no_decoder_map');

          expect(result, isA<Map>());
        },
      );
    });

    nyGroup('isNyloInitialized', () {
      nyTest('should return false when nylo is not saved', () async {
        Backpack.instance.delete('check_nylo');

        final result = Backpack.instance.isNyloInitialized(key: 'check_nylo');

        expect(result, isFalse);
      });
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Helper Functions Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('Backpack Helper Functions', () {
    nyGroup('backpackRead', () {
      nyTest('should read value from backpack', () async {
        Backpack.instance.save('helper_read', 'helper_value');

        final result = backpackRead<String>('helper_read');

        expect(result, 'helper_value');
      });

      nyTest('should return defaultValue when key not found', () async {
        final result = backpackRead<String>(
          'helper_not_found',
          defaultValue: 'default_helper',
        );

        expect(result, 'default_helper');
      });
    });

    nyGroup('backpackSave', () {
      nyTest('should save value to backpack', () async {
        backpackSave('helper_save', 'saved_value');

        final result = Backpack.instance.read<String>('helper_save');
        expect(result, 'saved_value');
      });
    });

    nyGroup('backpackDelete', () {
      nyTest('should delete value from backpack', () async {
        Backpack.instance.save('helper_delete', 'to_delete');

        backpackDelete('helper_delete');

        expect(Backpack.instance.contains('helper_delete'), isFalse);
      });
    });

    nyGroup('backpackDeleteAll', () {
      nyTest('should delete all user values from backpack', () async {
        Backpack.instance.save('helper_all1', 'value1');
        Backpack.instance.save('helper_all2', 'value2');

        backpackDeleteAll();

        expect(Backpack.instance.contains('helper_all1'), isFalse);
        expect(Backpack.instance.contains('helper_all2'), isFalse);
      });
    });
  });
}
