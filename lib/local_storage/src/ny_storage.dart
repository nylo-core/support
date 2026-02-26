import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '/helpers/ny_helpers.dart';
import '/testing/src/ny_time.dart';
import 'storage_manager.dart';
import 'storage_utils.dart';

/// Storage envelope format version for inline type metadata.
const String _storageEnvelopeVersion = 'v1';

/// Base class to help manage local storage
class NyStorage {
  static FlutterSecureStorage manager() => StorageManager.storage();

  /// Writes to storage
  static Future<void> _write(String key, String value) async {
    await manager().write(key: key, value: value);
  }

  /// Reads from storage
  static Future<String?> _read(String key) async {
    return await manager().read(key: key);
  }

  /// Deletes from storage
  static Future<void> _delete(String key) async {
    await manager().delete(key: key);
  }

  /// Deletes all from storage
  static Future<void> _deleteAllStorage() async {
    await manager().deleteAll();
  }

  /// Reads all from storage
  static Future<Map<String, String>> _readAllStorage() async {
    return await manager().readAll();
  }

  /// Saves an [object] to local storage using an optimized envelope format.
  /// The envelope stores type metadata inline with the value, reducing I/O operations.
  static Future<void> save(
    String key,
    dynamic object, {
    bool inBackpack = false,
  }) async {
    if (inBackpack == true) {
      Backpack.instance.save(key, object);
    }

    if (object is! Model) {
      // Use envelope format: single write with inline type metadata
      final envelope = _createEnvelope(
        type: object.runtimeType.toString(),
        value: object.toString(),
      );
      await _write(key, jsonEncode(envelope));
      return;
    }

    try {
      Map<String, dynamic> json = object.toJson();
      // Store model as envelope with 'model' type
      final envelope = _createEnvelope(type: 'model', value: jsonEncode(json));
      await _write(key, jsonEncode(envelope));
    } on NoSuchMethodError catch (_) {
      NyLogger.error(
        '[NyStorage.save] ${object.runtimeType.toString()} model needs to implement the toJson() method.',
      );
    }
  }

  /// Saves a JSON [object] to local storage.
  static Future<void> saveJson(
    String key,
    dynamic object, {
    bool inBackpack = false,
  }) async {
    if (inBackpack == true) {
      Backpack.instance.save(key, object);
    }

    try {
      // Use envelope format for JSON
      final envelope = _createEnvelope(type: 'json', value: jsonEncode(object));
      await _write(key, jsonEncode(envelope));
    } on Exception catch (e) {
      NyLogger.error(e.toString());
      NyLogger.error(
        '[NyStorage.saveJson] Failed to save $object to local storage. Please ensure that the object is a valid JSON object.',
      );
    }
  }

  /// Creates a storage envelope with type metadata.
  static Map<String, dynamic> _createEnvelope({
    required String type,
    required String value,
  }) {
    return {'_v': _storageEnvelopeVersion, '_t': type, '_d': value};
  }

  /// Attempts to parse data as an envelope, returns null if not envelope format.
  static _StorageEnvelope? _parseEnvelope(String data) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic> &&
          decoded.containsKey('_v') &&
          decoded.containsKey('_t') &&
          decoded.containsKey('_d')) {
        return _StorageEnvelope(
          version: decoded['_v'] as String,
          type: decoded['_t'] as String,
          value: decoded['_d'] as String,
        );
      }
    } catch (_) {
      // Not an envelope format
    }
    return null;
  }

  /// Read a value from the local storage.
  /// Returns the value cast to type [T], or [defaultValue] if not found.
  /// Supports both legacy format (separate _runtime_type key) and new envelope format.
  static Future<T?> read<T>(
    String key, {
    T? defaultValue,
    Map<Type, dynamic>? modelDecoders,
  }) async {
    String? data = await _read(key);

    if (data == null) {
      return defaultValue;
    }

    // Try to parse as new envelope format first
    final envelope = _parseEnvelope(data);
    if (envelope != null) {
      return _readFromEnvelope<T>(envelope, modelDecoders: modelDecoders);
    }

    // Fall back to legacy format: check for separate _runtime_type key
    String? runtimeType = await _read("${key}_runtime_type");

    // Handle stored runtime type metadata (legacy format)
    if (runtimeType != null && modelDecoders == null) {
      switch (runtimeType.toLowerCase()) {
        case 'int':
          return int.parse(data) as T;
        case 'double':
          return double.parse(data) as T;
        case 'string':
          return data as T;
        case 'bool':
          return (data == 'true') as T;
        case 'json':
          try {
            return jsonDecode(data) as T;
          } on Exception catch (e) {
            NyLogger.error(e.toString());
            return null;
          }
      }
    }

    // Handle explicit type parameter
    if (_isType<T, String>()) {
      return data.toString() as T;
    }

    if (_isType<T, int>()) {
      return int.parse(data.toString()) as T;
    }

    if (_isType<T, double>()) {
      return double.parse(data) as T;
    }

    // Auto-detect type from data format
    if (isInteger(data)) {
      return int.parse(data) as T;
    }

    if (isDouble(data)) {
      return double.parse(data) as T;
    }

    // Handle model deserialization
    if (T != dynamic) {
      try {
        return dataToModel<T>(
          data: jsonDecode(data),
          modelDecoders: modelDecoders,
        );
      } on Exception catch (e) {
        NyLogger.error(e.toString());
        return null;
      }
    }

    return data as T;
  }

  /// Reads a value from an envelope format.
  static T? _readFromEnvelope<T>(
    _StorageEnvelope envelope, {
    Map<Type, dynamic>? modelDecoders,
  }) {
    final type = envelope.type.toLowerCase();
    final value = envelope.value;

    switch (type) {
      case 'int':
        return int.parse(value) as T;
      case 'double':
        return double.parse(value) as T;
      case 'string':
        return value as T;
      case 'bool':
        return (value == 'true') as T;
      case 'null':
        return null;
      case 'json':
        try {
          return jsonDecode(value) as T;
        } on Exception catch (e) {
          NyLogger.error(e.toString());
          return null;
        }
      case 'model':
        if (T != dynamic) {
          try {
            return dataToModel<T>(
              data: jsonDecode(value),
              modelDecoders: modelDecoders,
            );
          } on Exception catch (e) {
            NyLogger.error(e.toString());
            return null;
          }
        }
        // If T is dynamic, return the raw JSON
        try {
          return jsonDecode(value) as T;
        } catch (_) {
          return value as T;
        }
      default:
        // Unknown type, try to parse based on T or return as string
        if (_isType<T, int>()) {
          return int.parse(value) as T;
        }
        if (_isType<T, double>()) {
          return double.parse(value) as T;
        }
        return value as T;
    }
  }

  /// Read a JSON value from the local storage.
  /// Returns the decoded JSON object, or [defaultValue] if not found.
  static Future<T?> readJson<T>(String key, {T? defaultValue}) async {
    String? data = await _read(key);
    if (data == null) {
      return defaultValue;
    }

    // Try envelope format first
    final envelope = _parseEnvelope(data);
    if (envelope != null) {
      // Always use envelope.value (the actual data), never expose envelope structure
      try {
        return jsonDecode(envelope.value) as T;
      } on Exception catch (e) {
        NyLogger.error(e.toString());
        return defaultValue;
      }
    }

    // Fall back to direct JSON decode (legacy format only - no envelope detected)
    try {
      return jsonDecode(data) as T;
    } on Exception catch (e) {
      NyLogger.error(e.toString());
      return defaultValue;
    }
  }

  /// Helper method to check if type [T] matches type [S].
  static bool _isType<T, S>() => <T>[] is List<S>;

  /// Deletes all keys with associated values.
  static Future<void> deleteAll({
    bool andFromBackpack = false,
    List<String>? excludeKeys,
  }) async {
    if (excludeKeys != null && excludeKeys.isNotEmpty) {
      Map<String, String> allValues = await readAll();
      for (String key in excludeKeys) {
        allValues.remove(key);
      }
      for (var data in allValues.entries) {
        await delete(data.key, andFromBackpack: andFromBackpack);
      }
      return;
    }

    if (andFromBackpack == true) {
      Backpack.instance.deleteAll();
    }
    await _deleteAllStorage();
  }

  /// Update a value in the local storage by [index].
  static Future<bool> updateCollectionByIndex<T>(
    int index,
    T Function(T item) object, {
    required String key,
  }) async {
    List<T> collection = await readCollection<T>(key);

    // Check if the collection is empty or the index is out of bounds
    if (collection.isEmpty || index < 0 || index >= collection.length) {
      NyLogger.error(
        '[NyStorage.updateCollectionByIndex] The collection is empty or the index is out of bounds.',
      );
      return false;
    }

    // Update the item
    T newItem = object(collection[index]);

    collection[index] = newItem;

    await saveCollection<T>(key, collection);
    return true;
  }

  /// Decrypts and returns all keys with associated values.
  static Future<Map<String, String>> readAll() async => await _readAllStorage();

  /// Deletes associated value for the given [key].
  static Future<void> delete(String key, {bool andFromBackpack = false}) async {
    if (andFromBackpack == true) {
      Backpack.instance.delete(key);
    }
    await _delete(key);
  }

  /// Deletes a collection from the given [key].
  /// @deprecated Use [delete] instead for consistent behavior.
  @Deprecated('Use delete() instead for consistent behavior.')
  static Future<void> deleteCollection(
    String key, {
    bool andFromBackpack = false,
  }) async {
    await delete(key, andFromBackpack: andFromBackpack);
  }

  /// Add a newItem to the collection using a [key].
  static Future<void> addToCollection<T>(
    String key, {
    required T item,
    bool allowDuplicates = true,
    Map<Type, dynamic>? modelDecoders,
  }) async {
    List<T> collection = await readCollection<T>(
      key,
      modelDecoders: modelDecoders,
    );
    if (allowDuplicates == false) {
      if (collection.any((collect) => collect == item)) {
        return;
      }
    }
    collection.add(item);
    await saveCollection<T>(key, collection);
  }

  /// Update item(s) in a collection using a where query.
  static Future<void> updateCollectionWhere<T>(
    bool Function(T value) where, {
    required String key,
    required T Function(T value) update,
  }) async {
    List<T> collection = await readCollection<T>(key);
    if (collection.isEmpty) return;

    collection = collection.map((element) {
      if (where(element)) return update(element);
      return element;
    }).toList();

    await saveCollection<T>(key, collection);
  }

  /// Read the collection values using a [key].
  static Future<List<T>> readCollection<T>(
    String key, {
    Map<Type, dynamic>? modelDecoders,
  }) async {
    String? data = await read(key);
    if (data == null || data == "") return [];

    List<dynamic> listData = jsonDecode(data);

    // Check if T is a primitive type
    if (T == dynamic || T == String || T == double || T == int) {
      return List.from(listData).toList().cast();
    }

    return List.from(listData)
        .map((json) => dataToModel<T>(data: json, modelDecoders: modelDecoders))
        .toList();
  }

  /// Sets the [key] to null.
  /// @deprecated Use [delete] instead for consistent behavior.
  @Deprecated('Use delete() instead for consistent behavior.')
  static Future<void> clear(String key) async =>
      await NyStorage.save(key, null);

  /// Delete item(s) from a collection using a where query.
  static Future<void> deleteFromCollectionWhere<T>(
    bool Function(T value) where, {
    required String key,
  }) async {
    List<T> collection = await readCollection<T>(key);
    if (collection.isEmpty) return;

    collection.removeWhere((value) => where(value));

    await saveCollection<T>(key, collection);
  }

  /// Delete an item of a collection using a [index] and the collection [key].
  static Future<void> deleteFromCollection<T>(
    int index, {
    required String key,
  }) async {
    List<T> collection = await readCollection<T>(key);
    if (collection.isEmpty) return;
    if (index < 0 || index >= collection.length) return;
    collection.removeAt(index);
    await saveCollection<T>(key, collection);
  }

  /// Save a list of objects to a [collection] using a [key].
  static Future<void> saveCollection<T>(String key, List<T> collection) async {
    // Check if T is a primitive type
    if (T == dynamic || T == String || T == double || T == int) {
      await save(key, jsonEncode(collection));
      return;
    }

    String json = jsonEncode(
      collection.map((item) {
        Map<String, dynamic>? data = objectToJson(item);
        if (data != null) {
          return data;
        }
        return item;
      }).toList(),
    );
    await save(key, json);
  }

  /// Delete a value from a collection using a [key] and the [value] you want to remove.
  static Future<void> deleteValueFromCollection<T>(
    String key, {
    required T value,
  }) async {
    List<T> collection = await readCollection<T>(key);
    collection.removeWhere((item) => item == value);
    await saveCollection<T>(key, collection);
  }

  /// Checks if a collection is empty
  static Future<bool> isCollectionEmpty(String key) async =>
      (await readCollection(key)).isEmpty;

  /// Sync all the keys stored to the [Backpack] instance.
  static Future<void> syncToBackpack({bool overwrite = false}) async {
    Map<String, String> values = await readAll();
    Backpack backpack = Backpack.instance;
    for (var data in values.entries) {
      if (overwrite == false && backpack.contains(data.key)) {
        continue;
      }
      dynamic result = await NyStorage.read(data.key);
      Backpack.instance.save(data.key, result);
    }
  }

  /// Checks if a key exists in local storage.
  static Future<bool> hasKey(String key) async {
    final data = await _read(key);
    return data != null;
  }

  /// Saves an [object] to local storage with an expiration time (TTL).
  /// The value will be automatically removed when read after expiration.
  static Future<void> saveWithExpiry(
    String key,
    dynamic object, {
    required Duration ttl,
    bool inBackpack = false,
  }) async {
    if (inBackpack == true) {
      Backpack.instance.save(key, object);
    }

    final expiresAt = NyTime.now().add(ttl).millisecondsSinceEpoch;

    if (object is! Model) {
      final envelope = _createEnvelopeWithExpiry(
        type: object.runtimeType.toString(),
        value: object.toString(),
        expiresAt: expiresAt,
      );
      await _write(key, jsonEncode(envelope));
      return;
    }

    try {
      Map<String, dynamic> json = object.toJson();
      final envelope = _createEnvelopeWithExpiry(
        type: 'model',
        value: jsonEncode(json),
        expiresAt: expiresAt,
      );
      await _write(key, jsonEncode(envelope));
    } on NoSuchMethodError catch (_) {
      NyLogger.error(
        '[NyStorage.saveWithExpiry] ${object.runtimeType.toString()} model needs to implement the toJson() method.',
      );
    }
  }

  /// Creates a storage envelope with type metadata and expiration.
  static Map<String, dynamic> _createEnvelopeWithExpiry({
    required String type,
    required String value,
    required int expiresAt,
  }) {
    return {
      '_v': _storageEnvelopeVersion,
      '_t': type,
      '_d': value,
      '_e': expiresAt,
    };
  }

  /// Read a value from local storage, respecting TTL expiration.
  /// If the value has expired, it will be deleted and null returned.
  static Future<T?> readWithExpiry<T>(
    String key, {
    T? defaultValue,
    Map<Type, dynamic>? modelDecoders,
    bool deleteIfExpired = true,
  }) async {
    String? data = await _read(key);

    if (data == null) {
      return defaultValue;
    }

    final envelope = _parseEnvelopeWithExpiry(data);
    if (envelope != null) {
      // Check if expired
      if (envelope.expiresAt != null) {
        final now = NyTime.now().millisecondsSinceEpoch;
        if (now > envelope.expiresAt!) {
          if (deleteIfExpired) {
            await delete(key);
          }
          return defaultValue;
        }
      }
      return _readFromEnvelope<T>(
        _StorageEnvelope(
          version: envelope.version,
          type: envelope.type,
          value: envelope.value,
        ),
        modelDecoders: modelDecoders,
      );
    }

    // Fall back to regular read for non-expiry data
    return read<T>(
      key,
      defaultValue: defaultValue,
      modelDecoders: modelDecoders,
    );
  }

  /// Parses an envelope that may contain expiry information.
  static _StorageEnvelopeWithExpiry? _parseEnvelopeWithExpiry(String data) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic> &&
          decoded.containsKey('_v') &&
          decoded.containsKey('_t') &&
          decoded.containsKey('_d')) {
        return _StorageEnvelopeWithExpiry(
          version: decoded['_v'] as String,
          type: decoded['_t'] as String,
          value: decoded['_d'] as String,
          expiresAt: decoded['_e'] as int?,
        );
      }
    } catch (_) {
      // Not an envelope format
    }
    return null;
  }

  /// Gets the remaining time-to-live for a key with expiry.
  /// Returns null if the key doesn't exist or has no expiry set.
  static Future<Duration?> getTimeToLive(String key) async {
    String? data = await _read(key);
    if (data == null) return null;

    final envelope = _parseEnvelopeWithExpiry(data);
    if (envelope?.expiresAt == null) return null;

    final now = NyTime.now().millisecondsSinceEpoch;
    final remaining = envelope!.expiresAt! - now;

    if (remaining <= 0) return Duration.zero;
    return Duration(milliseconds: remaining);
  }

  /// Saves multiple key-value pairs to local storage in batch.
  /// More efficient than calling [save] multiple times.
  static Future<void> saveAll(
    Map<String, dynamic> items, {
    bool inBackpack = false,
  }) async {
    for (final entry in items.entries) {
      await save(entry.key, entry.value, inBackpack: inBackpack);
    }
  }

  /// Reads multiple keys from local storage in batch.
  /// Returns a map of key-value pairs. Missing keys will have null values.
  static Future<Map<String, T?>> readMultiple<T>(
    List<String> keys, {
    Map<Type, dynamic>? modelDecoders,
  }) async {
    final results = <String, T?>{};
    for (final key in keys) {
      results[key] = await read<T>(key, modelDecoders: modelDecoders);
    }
    return results;
  }

  /// Deletes multiple keys from local storage in batch.
  static Future<void> deleteMultiple(
    List<String> keys, {
    bool andFromBackpack = false,
  }) async {
    for (final key in keys) {
      await delete(key, andFromBackpack: andFromBackpack);
    }
  }

  /// Removes all expired keys from storage.
  /// Returns the number of keys removed.
  static Future<int> removeExpired() async {
    int removedCount = 0;
    final allData = await readAll();

    for (final entry in allData.entries) {
      final envelope = _parseEnvelopeWithExpiry(entry.value);
      if (envelope?.expiresAt != null) {
        final now = NyTime.now().millisecondsSinceEpoch;
        if (now > envelope!.expiresAt!) {
          await delete(entry.key);
          removedCount++;
        }
      }
    }

    return removedCount;
  }

  /// Migrates legacy storage format to new envelope format.
  /// Call this during app initialization to convert old data.
  /// Returns the number of keys migrated.
  static Future<int> migrateToEnvelopeFormat() async {
    int migratedCount = 0;
    final allData = await readAll();

    for (final entry in allData.entries) {
      final key = entry.key;

      // Skip runtime_type keys - they're part of legacy format
      if (key.endsWith('_runtime_type')) continue;

      // Check if already in envelope format
      final envelope = _parseEnvelope(entry.value);
      if (envelope != null) continue;

      // Check for legacy runtime_type key
      final runtimeTypeKey = '${key}_runtime_type';
      if (allData.containsKey(runtimeTypeKey)) {
        // Migrate to envelope format
        final runtimeType = allData[runtimeTypeKey]!;
        final newEnvelope = _createEnvelope(
          type: runtimeType,
          value: entry.value,
        );
        await _write(key, jsonEncode(newEnvelope));
        await _delete(runtimeTypeKey);
        migratedCount++;
      }
    }

    return migratedCount;
  }
}

/// Internal class representing a storage envelope.
class _StorageEnvelope {
  final String version;
  final String type;
  final String value;

  const _StorageEnvelope({
    required this.version,
    required this.type,
    required this.value,
  });
}

/// Internal class representing a storage envelope with optional expiry.
class _StorageEnvelopeWithExpiry {
  final String version;
  final String type;
  final String value;
  final int? expiresAt;

  const _StorageEnvelopeWithExpiry({
    required this.version,
    required this.type,
    required this.value,
    this.expiresAt,
  });
}
