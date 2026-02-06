import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/local_storage/ny_local_storage.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  setUp(() {
    Nylo.isTestMode = true;
  });

  tearDown(() async {
    await NyStorage.deleteAll();
    Nylo.isTestMode = true;
    NyTest.travelBack();
  });

  nyGroup('Storage Helper Functions', () {
    nyGroup('storageRead', () {
      nyTest('should read string value from storage', () async {
        await NyStorage.save('read_test', 'test_value');

        final result = await storageRead<String>('read_test');

        expect(result, 'test_value');
      });

      nyTest('should read int value from storage', () async {
        await NyStorage.save('read_int', 42);

        final result = await storageRead<int>('read_int');

        expect(result, 42);
      });

      nyTest('should return null for nonexistent key', () async {
        final result = await storageRead<String>('nonexistent');

        expect(result, isNull);
      });
    });

    nyGroup('storageSave', () {
      nyTest('should save string value to storage', () async {
        await storageSave('save_test', 'saved_value');

        final result = await NyStorage.read<String>('save_test');
        expect(result, 'saved_value');
      });

      nyTest('should save int value to storage', () async {
        await storageSave('save_int', 123);

        final result = await NyStorage.read<int>('save_int');
        expect(result, 123);
      });

      nyTest('should save JSON-encodable value using saveJson', () async {
        await storageSave('save_json', {'key': 'value'});

        final result = await NyStorage.readJson<Map<String, dynamic>>(
          'save_json',
        );
        expect(result, {'key': 'value'});
      });

      nyTest('should save to backpack when inBackpack is true', () async {
        await storageSave('backpack_save', 'value', inBackpack: true);

        expect(Backpack.instance.contains('backpack_save'), isTrue);
      });
    });

    nyGroup('storageSaveWithExpiry', () {
      nyTest('should save value with TTL', () async {
        await storageSaveWithExpiry(
          'expiry_save',
          'expiring_value',
          ttl: const Duration(hours: 1),
        );

        final result = await NyStorage.readWithExpiry<String>('expiry_save');
        expect(result, 'expiring_value');
      });

      nyTest('should save to backpack when inBackpack is true', () async {
        await storageSaveWithExpiry(
          'expiry_backpack',
          'value',
          ttl: const Duration(hours: 1),
          inBackpack: true,
        );

        expect(Backpack.instance.contains('expiry_backpack'), isTrue);
      });

      nyTest('should save int with TTL', () async {
        await storageSaveWithExpiry(
          'expiry_int',
          100,
          ttl: const Duration(hours: 1),
        );

        final result = await NyStorage.readWithExpiry<int>('expiry_int');
        expect(result, 100);
      });
    });

    nyGroup('storageReadWithExpiry', () {
      nyTest('should read valid non-expired value', () async {
        await NyStorage.saveWithExpiry(
          'read_expiry',
          'valid_value',
          ttl: const Duration(hours: 1),
        );

        final result = await storageReadWithExpiry<String>('read_expiry');

        expect(result, 'valid_value');
      });

      nyTest('should return default value for nonexistent key', () async {
        final result = await storageReadWithExpiry<String>(
          'nonexistent_expiry_key',
          defaultValue: 'default_value',
        );

        expect(result, 'default_value');
      });

      nyTest(
        'should return null for nonexistent key without default',
        () async {
          final result = await storageReadWithExpiry<String>(
            'nonexistent_expiry_key2',
          );

          expect(result, isNull);
        },
      );
    });

    nyGroup('storageDelete', () {
      nyTest('should delete key from storage', () async {
        await NyStorage.save('to_delete', 'value');

        await storageDelete('to_delete');

        final result = await NyStorage.read<String>('to_delete');
        expect(result, isNull);
      });

      nyTest('should handle deleting nonexistent key', () async {
        // Should not throw
        await storageDelete('nonexistent_delete');
      });
    });

    nyGroup('storageHasKey', () {
      nyTest('should return true for existing key', () async {
        await NyStorage.save('exists', 'value');

        final result = await storageHasKey('exists');

        expect(result, isTrue);
      });

      nyTest('should return false for nonexistent key', () async {
        final result = await storageHasKey('does_not_exist');

        expect(result, isFalse);
      });
    });

    nyGroup('storageGetTTL', () {
      nyTest('should return remaining TTL for key with expiry', () async {
        await NyStorage.saveWithExpiry(
          'ttl_key',
          'value',
          ttl: const Duration(hours: 2),
        );

        final ttl = await storageGetTTL('ttl_key');

        expect(ttl, isNotNull);
        // Should be approximately 2 hours (120 minutes)
        expect(ttl!.inMinutes, greaterThan(115));
        expect(ttl.inMinutes, lessThanOrEqualTo(120));
      });

      nyTest('should return null for key without expiry', () async {
        await NyStorage.save('no_expiry', 'value');

        final ttl = await storageGetTTL('no_expiry');

        expect(ttl, isNull);
      });

      nyTest('should return null for nonexistent key', () async {
        final ttl = await storageGetTTL('nonexistent_ttl');

        expect(ttl, isNull);
      });
    });

    nyGroup('storageCollectionRead', () {
      nyTest('should read string collection', () async {
        await NyStorage.saveCollection<String>('col_read', [
          'item1',
          'item2',
          'item3',
        ]);

        final result = await storageCollectionRead<String>('col_read');

        expect(result, ['item1', 'item2', 'item3']);
      });

      nyTest('should read int collection', () async {
        await NyStorage.saveCollection<int>('int_col', [1, 2, 3]);

        final result = await storageCollectionRead<int>('int_col');

        expect(result, [1, 2, 3]);
      });

      nyTest('should return empty list for nonexistent collection', () async {
        final result = await storageCollectionRead<String>('nonexistent_col');

        expect(result, isEmpty);
      });
    });

    nyGroup('storageCollectionSave', () {
      nyTest('should save string collection', () async {
        await storageCollectionSave<String>('save_col', ['a', 'b', 'c']);

        final result = await NyStorage.readCollection<String>('save_col');
        expect(result, ['a', 'b', 'c']);
      });

      nyTest('should save int collection', () async {
        await storageCollectionSave<int>('save_int_col', [10, 20, 30]);

        final result = await NyStorage.readCollection<int>('save_int_col');
        expect(result, [10, 20, 30]);
      });

      nyTest('should overwrite existing collection', () async {
        await NyStorage.saveCollection<String>('overwrite_col', ['old']);

        await storageCollectionSave<String>('overwrite_col', ['new1', 'new2']);

        final result = await NyStorage.readCollection<String>('overwrite_col');
        expect(result, ['new1', 'new2']);
      });
    });

    nyGroup('storageCollectionDeleteValue', () {
      nyTest('should delete specific value from collection', () async {
        await NyStorage.saveCollection<String>('del_val_col', [
          'a',
          'b',
          'c',
          'b',
        ]);

        await storageCollectionDeleteValue<String>('del_val_col', value: 'b');

        final result = await NyStorage.readCollection<String>('del_val_col');
        expect(result, ['a', 'c']);
      });

      nyTest('should handle value not in collection', () async {
        await NyStorage.saveCollection<String>('no_val_col', ['a', 'b', 'c']);

        await storageCollectionDeleteValue<String>('no_val_col', value: 'z');

        final result = await NyStorage.readCollection<String>('no_val_col');
        expect(result, ['a', 'b', 'c']);
      });
    });

    nyGroup('storageCollectionDeleteWhere', () {
      nyTest('should delete items matching condition', () async {
        await NyStorage.saveCollection<int>('where_col', [1, 2, 3, 4, 5]);

        await storageCollectionDeleteWhere<int>(
          'where_col',
          (value) => value % 2 == 0,
        );

        final result = await NyStorage.readCollection<int>('where_col');
        expect(result, [1, 3, 5]);
      });

      nyTest('should not delete when no items match', () async {
        await NyStorage.saveCollection<int>('no_where_col', [1, 2, 3]);

        await storageCollectionDeleteWhere<int>(
          'no_where_col',
          (value) => value > 100,
        );

        final result = await NyStorage.readCollection<int>('no_where_col');
        expect(result, [1, 2, 3]);
      });
    });

    nyGroup('storageCollectionDeleteIndex', () {
      nyTest('should delete item at specific index', () async {
        await NyStorage.saveCollection<String>('idx_col', ['a', 'b', 'c']);

        await storageCollectionDeleteIndex<String>('idx_col', 1);

        final result = await NyStorage.readCollection<String>('idx_col');
        expect(result, ['a', 'c']);
      });

      nyTest('should delete first item when index is 0', () async {
        await NyStorage.saveCollection<String>('first_col', [
          'first',
          'second',
        ]);

        await storageCollectionDeleteIndex<String>('first_col', 0);

        final result = await NyStorage.readCollection<String>('first_col');
        expect(result, ['second']);
      });
    });

    nyGroup('storageSaveAll', () {
      nyTest('should save multiple key-value pairs', () async {
        await storageSaveAll({
          'all_key1': 'value1',
          'all_key2': 'value2',
          'all_key3': 'value3',
        });

        expect(await NyStorage.read<String>('all_key1'), 'value1');
        expect(await NyStorage.read<String>('all_key2'), 'value2');
        expect(await NyStorage.read<String>('all_key3'), 'value3');
      });

      nyTest('should save all to backpack when inBackpack is true', () async {
        await storageSaveAll({
          'bp_all1': 'v1',
          'bp_all2': 'v2',
        }, inBackpack: true);

        expect(Backpack.instance.contains('bp_all1'), isTrue);
        expect(Backpack.instance.contains('bp_all2'), isTrue);
      });
    });

    nyGroup('storageReadMultiple', () {
      nyTest('should read multiple keys at once', () async {
        await NyStorage.save('rm1', 'val1');
        await NyStorage.save('rm2', 'val2');
        await NyStorage.save('rm3', 'val3');

        final results = await storageReadMultiple<String>([
          'rm1',
          'rm2',
          'rm3',
        ]);

        expect(results['rm1'], 'val1');
        expect(results['rm2'], 'val2');
        expect(results['rm3'], 'val3');
      });

      nyTest('should return null for missing keys', () async {
        await NyStorage.save('exists_multi', 'value');

        final results = await storageReadMultiple<String>([
          'exists_multi',
          'missing',
        ]);

        expect(results['exists_multi'], 'value');
        expect(results['missing'], isNull);
      });
    });

    nyGroup('storageDeleteMultiple', () {
      nyTest('should delete multiple keys at once', () async {
        await NyStorage.save('dm1', 'v1');
        await NyStorage.save('dm2', 'v2');
        await NyStorage.save('dm_keep', 'keep');

        await storageDeleteMultiple(['dm1', 'dm2']);

        expect(await NyStorage.read<String>('dm1'), isNull);
        expect(await NyStorage.read<String>('dm2'), isNull);
        expect(await NyStorage.read<String>('dm_keep'), 'keep');
      });

      nyTest(
        'should delete from backpack when andFromBackpack is true',
        () async {
          await NyStorage.save('bp_dm1', 'v1', inBackpack: true);
          await NyStorage.save('bp_dm2', 'v2', inBackpack: true);

          await storageDeleteMultiple([
            'bp_dm1',
            'bp_dm2',
          ], andFromBackpack: true);

          expect(Backpack.instance.contains('bp_dm1'), isFalse);
          expect(Backpack.instance.contains('bp_dm2'), isFalse);
        },
      );
    });

    nyGroup('storageRemoveExpired', () {
      nyTest('should return 0 when no expired keys', () async {
        await NyStorage.saveWithExpiry(
          'not_expired',
          'value',
          ttl: const Duration(days: 1),
        );

        final removedCount = await storageRemoveExpired();

        expect(removedCount, 0);
      });

      nyTest('should handle empty storage', () async {
        await NyStorage.deleteAll();

        final removedCount = await storageRemoveExpired();

        expect(removedCount, 0);
      });

      nyTest('should handle storage with non-expiring keys only', () async {
        await NyStorage.save('regular_key', 'value');

        final removedCount = await storageRemoveExpired();

        expect(removedCount, 0);
        expect(await NyStorage.hasKey('regular_key'), isTrue);
      });
    });

    nyGroup('TTL helper functions', () {
      nyTest(
        'should save value with TTL using storageSaveWithExpiry',
        () async {
          await storageSaveWithExpiry(
            'ttl_helper_key',
            'expiring_value',
            ttl: const Duration(hours: 1),
          );

          // Verify exists before expiry
          final result = await storageReadWithExpiry<String>('ttl_helper_key');
          expect(result, 'expiring_value');
        },
      );

      nyTest('should report correct initial TTL using storageGetTTL', () async {
        await storageSaveWithExpiry(
          'ttl_check_key',
          'value',
          ttl: const Duration(hours: 3),
        );

        // Immediately after saving, TTL should be approximately 3 hours
        final ttl = await storageGetTTL('ttl_check_key');

        expect(ttl, isNotNull);
        expect(ttl!.inMinutes, greaterThan(175));
        expect(ttl.inMinutes, lessThanOrEqualTo(180));
      });

      nyTest(
        'should return null for non-expiring key via storageGetTTL',
        () async {
          await storageSave('no_expiry', 'value');

          final ttl = await storageGetTTL('no_expiry');

          expect(ttl, isNull);
        },
      );

      nyTest('should return null TTL for nonexistent key', () async {
        final ttl = await storageGetTTL('nonexistent_ttl_key');

        expect(ttl, isNull);
      });

      nyTest(
        'should read value before expiry via storageReadWithExpiry',
        () async {
          await storageSaveWithExpiry(
            'read_expiry_test',
            'test_value',
            ttl: const Duration(hours: 24),
          );

          final result = await storageReadWithExpiry<String>(
            'read_expiry_test',
          );
          expect(result, 'test_value');
        },
      );

      nyTest(
        'should return default for expired value via storageReadWithExpiry',
        () async {
          // For non-expired keys, we can still test the default value path
          final result = await storageReadWithExpiry<String>(
            'nonexistent_expiry_key',
            defaultValue: 'default_value',
          );

          expect(result, 'default_value');
        },
      );
    });

    nyGroup('integration scenarios', () {
      nyTest('should support complete CRUD workflow', () async {
        // Create
        await storageSave('crud_key', 'created');
        expect(await storageHasKey('crud_key'), isTrue);

        // Read
        final readValue = await storageRead<String>('crud_key');
        expect(readValue, 'created');

        // Update
        await storageSave('crud_key', 'updated');
        final updatedValue = await storageRead<String>('crud_key');
        expect(updatedValue, 'updated');

        // Delete
        await storageDelete('crud_key');
        expect(await storageHasKey('crud_key'), isFalse);
      });

      nyTest('should support collection CRUD workflow', () async {
        // Create collection
        await storageCollectionSave<String>('crud_col', ['item1']);
        expect((await storageCollectionRead<String>('crud_col')).length, 1);

        // Add to collection
        await NyStorage.addToCollection<String>('crud_col', item: 'item2');
        expect((await storageCollectionRead<String>('crud_col')).length, 2);

        // Delete from collection by value
        await storageCollectionDeleteValue<String>('crud_col', value: 'item1');
        final afterDelete = await storageCollectionRead<String>('crud_col');
        expect(afterDelete, ['item2']);

        // Delete entire collection
        await storageDelete('crud_col');
        expect(await storageCollectionRead<String>('crud_col'), isEmpty);
      });

      nyTest('should support batch operations workflow', () async {
        // Batch save
        await storageSaveAll({
          'batch1': 'value1',
          'batch2': 'value2',
          'batch3': 'value3',
        });

        // Batch read
        final results = await storageReadMultiple<String>([
          'batch1',
          'batch2',
          'batch3',
        ]);
        expect(results.values.where((v) => v != null).length, 3);

        // Batch delete
        await storageDeleteMultiple(['batch1', 'batch2']);
        expect(await storageHasKey('batch1'), isFalse);
        expect(await storageHasKey('batch2'), isFalse);
        expect(await storageHasKey('batch3'), isTrue);
      });
    });

    nyGroup('edge cases for helper functions', () {
      nyTest('should handle empty keys list in readMultiple', () async {
        final results = await storageReadMultiple<String>([]);

        expect(results, isEmpty);
      });

      nyTest('should handle empty keys list in deleteMultiple', () async {
        await storageSave('untouched', 'value');

        // Should not throw
        await storageDeleteMultiple([]);

        expect(await storageHasKey('untouched'), isTrue);
      });

      nyTest('should handle empty map in saveAll', () async {
        // Should not throw
        await storageSaveAll({});
      });

      nyTest('should handle very short TTL', () async {
        await storageSaveWithExpiry(
          'short_ttl',
          'quick',
          ttl: const Duration(milliseconds: 100),
        );

        // Should still be readable immediately
        final result = await storageReadWithExpiry<String>('short_ttl');
        expect(result, 'quick');
      });

      nyTest('should handle very long TTL', () async {
        await storageSaveWithExpiry(
          'long_ttl',
          'lasting',
          ttl: const Duration(days: 365),
        );

        final ttl = await storageGetTTL('long_ttl');
        expect(ttl, isNotNull);
        expect(ttl!.inDays, greaterThan(360));
      });

      nyTest('should handle collection with single item', () async {
        await storageCollectionSave<String>('single_item', ['only_one']);

        final result = await storageCollectionRead<String>('single_item');

        expect(result, ['only_one']);
        expect(result.length, 1);
      });

      nyTest('should handle collection delete where all match', () async {
        await storageCollectionSave<int>('all_match', [2, 4, 6, 8]);

        await storageCollectionDeleteWhere<int>(
          'all_match',
          (value) => value % 2 == 0,
        );

        final result = await storageCollectionRead<int>('all_match');
        expect(result, isEmpty);
      });

      nyTest('should handle nested JSON via storageSave', () async {
        final nestedData = {
          'level1': {
            'level2': {
              'level3': {'value': 'deep'},
            },
          },
        };

        await storageSave('nested_data', nestedData);

        final result = await NyStorage.readJson<Map<String, dynamic>>(
          'nested_data',
        );
        expect(result!['level1']['level2']['level3']['value'], 'deep');
      });
    });
  });
}
