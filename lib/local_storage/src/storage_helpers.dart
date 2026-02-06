import 'ny_storage.dart';
import 'storage_utils.dart';

/// Read data from the storage class.
/// Returns the value cast to type [T], or null if not found.
Future<T?> storageRead<T>(
  String key, {
  Map<Type, dynamic>? modelDecoders,
}) async {
  return await NyStorage.read<T>(key, modelDecoders: modelDecoders);
}

/// Save data to the storage class.
Future<void> storageSave(
  String key,
  dynamic object, {
  bool inBackpack = false,
}) async {
  if (JsonHelper.tryEncode(object) != null) {
    await NyStorage.saveJson(key, object, inBackpack: inBackpack);
    return;
  }
  await NyStorage.save(key, object, inBackpack: inBackpack);
}

/// Save data to the storage class with an expiration time.
Future<void> storageSaveWithExpiry(
  String key,
  dynamic object, {
  required Duration ttl,
  bool inBackpack = false,
}) async {
  await NyStorage.saveWithExpiry(key, object, ttl: ttl, inBackpack: inBackpack);
}

/// Read data from the storage class, respecting TTL expiration.
Future<T?> storageReadWithExpiry<T>(
  String key, {
  T? defaultValue,
  Map<Type, dynamic>? modelDecoders,
  bool deleteIfExpired = true,
}) async {
  return await NyStorage.readWithExpiry<T>(
    key,
    defaultValue: defaultValue,
    modelDecoders: modelDecoders,
    deleteIfExpired: deleteIfExpired,
  );
}

/// Delete data from the storage class.
Future<void> storageDelete(String key) async {
  await NyStorage.delete(key);
}

/// Check if a key exists in storage.
Future<bool> storageHasKey(String key) async {
  return await NyStorage.hasKey(key);
}

/// Get the remaining time-to-live for a key with expiry.
Future<Duration?> storageGetTTL(String key) async {
  return await NyStorage.getTimeToLive(key);
}

/// Read a collection from the storage class.
Future<List<T>> storageCollectionRead<T>(
  String key, {
  Map<Type, dynamic>? modelDecoders,
}) async {
  return await NyStorage.readCollection<T>(key, modelDecoders: modelDecoders);
}

/// Save a collection to the storage class.
Future<void> storageCollectionSave<T>(String key, List<T> collection) async {
  await NyStorage.saveCollection<T>(key, collection);
}

/// Delete a value from a collection in the storage class.
Future<void> storageCollectionDeleteValue<T>(
  String key, {
  required T value,
}) async {
  await NyStorage.deleteValueFromCollection<T>(key, value: value);
}

/// Delete an item from a collection in the storage class.
Future<void> storageCollectionDeleteWhere<T>(
  String key,
  bool Function(T where) value,
) async {
  await NyStorage.deleteFromCollectionWhere<T>(value, key: key);
}

/// Delete an item from a collection in the storage class.
Future<void> storageCollectionDeleteIndex<T>(String key, int index) async {
  await NyStorage.deleteFromCollection<T>(index, key: key);
}

/// Save multiple key-value pairs to storage in batch.
Future<void> storageSaveAll(
  Map<String, dynamic> items, {
  bool inBackpack = false,
}) async {
  await NyStorage.saveAll(items, inBackpack: inBackpack);
}

/// Read multiple keys from storage in batch.
Future<Map<String, T?>> storageReadMultiple<T>(
  List<String> keys, {
  Map<Type, dynamic>? modelDecoders,
}) async {
  return await NyStorage.readMultiple<T>(keys, modelDecoders: modelDecoders);
}

/// Delete multiple keys from storage in batch.
Future<void> storageDeleteMultiple(
  List<String> keys, {
  bool andFromBackpack = false,
}) async {
  await NyStorage.deleteMultiple(keys, andFromBackpack: andFromBackpack);
}

/// Remove all expired keys from storage.
Future<int> storageRemoveExpired() async {
  return await NyStorage.removeExpired();
}
