import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '/helpers/model.dart';
import '/helpers/ny_logger.dart';
import '/helpers/backpack.dart';
import '/helpers/helper.dart';

/// Storage configuration for Nylo.
/// You can set the storage options for each platform.
/// E.g. AndroidOptions, IOSOptions, LinuxOptions, WindowsOptions, WebOptions, MacOsOptions
class StorageConfig {
  IOSOptions iosOptions = IOSOptions.defaultOptions;
  AndroidOptions androidOptions = AndroidOptions.defaultOptions;
  LinuxOptions linuxOptions = LinuxOptions.defaultOptions;
  WindowsOptions windowsOptions = WindowsOptions.defaultOptions;
  WebOptions webOptions = WebOptions.defaultOptions;
  MacOsOptions macOsOptions = MacOsOptions.defaultOptions;

  StorageConfig({
    this.iosOptions = IOSOptions.defaultOptions,
    this.androidOptions = AndroidOptions.defaultOptions,
    this.linuxOptions = LinuxOptions.defaultOptions,
    this.windowsOptions = WindowsOptions.defaultOptions,
    this.webOptions = WebOptions.defaultOptions,
    this.macOsOptions = MacOsOptions.defaultOptions,
  });

  StorageConfig._privateConstructor();

  /// Initialize the storage configuration.
  static void init({
    IOSOptions? iosOptions,
    AndroidOptions? androidOptions,
    LinuxOptions? linuxOptions,
    WindowsOptions? windowsOptions,
    WebOptions? webOptions,
    MacOsOptions? macOsOptions,
  }) {
    StorageConfig storageConfig = StorageConfig.instance;
    storageConfig.iosOptions = iosOptions ?? IOSOptions.defaultOptions;
    storageConfig.androidOptions =
        androidOptions ?? AndroidOptions.defaultOptions;
    storageConfig.linuxOptions = linuxOptions ?? LinuxOptions.defaultOptions;
    storageConfig.windowsOptions =
        windowsOptions ?? WindowsOptions.defaultOptions;
    storageConfig.webOptions = webOptions ?? WebOptions.defaultOptions;
    storageConfig.macOsOptions = macOsOptions ?? MacOsOptions.defaultOptions;
  }

  /// Returns the instance.
  static final StorageConfig instance = StorageConfig._privateConstructor();
}

/// Storage manager for Nylo.
class StorageManager {
  /// Returns the storage instance.
  static FlutterSecureStorage storage() {
    StorageConfig storageConfig = StorageConfig.instance;
    return FlutterSecureStorage(
      iOptions: storageConfig.iosOptions,
      aOptions: storageConfig.androidOptions,
      lOptions: storageConfig.linuxOptions,
      wOptions: storageConfig.windowsOptions,
      webOptions: storageConfig.webOptions,
      mOptions: storageConfig.macOsOptions,
    );
  }
}

/// Base class to help manage local storage
class NyStorage {
  static FlutterSecureStorage manager() => StorageManager.storage();

  /// Saves an [object] to local storage.
  static Future save(String key, object, {bool inBackpack = false}) async {
    if (inBackpack == true) {
      Backpack.instance.save(key, object);
    }

    if (object is! Model) {
      await manager().write(
          key: "${key}_runtime_type", value: object.runtimeType.toString());
      return await manager().write(key: key, value: object.toString());
    }

    try {
      Map<String, dynamic> json = object.toJson();
      return await manager().write(key: key, value: jsonEncode(json));
    } on NoSuchMethodError catch (_) {
      NyLogger.error(
          '[NyStorage.save] ${object.runtimeType.toString()} model needs to implement the toJson() method.');
    }
  }

  /// Saves a JSON [object] to local storage.
  static Future saveJson(String key, object, {bool inBackpack = false}) async {
    if (inBackpack == true) {
      Backpack.instance.save(key, object);
    }

    try {
      await manager().write(key: "${key}_runtime_type", value: "json");
      return await manager().write(
        key: key,
        value: jsonEncode(object),
      );
    } on Exception catch (e) {
      NyLogger.error(e.toString());
      NyLogger.error(
          '[NyStorage.saveJson] Failed to save $object to local storage. Please ensure that the object is a valid JSON object.');
    }
  }

  /// Read a value from the local storage
  static Future<dynamic> read<T>(String key,
      {dynamic defaultValue, Map<Type, dynamic>? modelDecoders}) async {
    String? data = await manager().read(key: key);
    String? runtimeType = await manager().read(key: "${key}_runtime_type");

    if (data == null) {
      return defaultValue;
    }
    if (runtimeType != null && modelDecoders == null) {
      switch (runtimeType.toLowerCase()) {
        case 'int':
          return int.parse(data);
        case 'double':
          return double.parse(data);
        case 'string':
          return data;
        case 'bool':
          return data == 'true';
        case 'json':
          try {
            return jsonDecode(data);
          } on Exception catch (e) {
            NyLogger.error(e.toString());
            return null;
          }
      }
    } else {
      if (T.toString() == "String") {
        return data.toString();
      }

      if (T.toString() == "int") {
        return int.parse(data.toString());
      }

      if (T.toString() == "double") {
        return double.parse(data);
      }

      if (_isInteger(data)) {
        return int.parse(data);
      }

      if (_isDouble(data)) {
        return double.parse(data);
      }
    }

    if (T.toString() != 'dynamic') {
      try {
        return dataToModel<T>(
            data: jsonDecode(data), modelDecoders: modelDecoders);
      } on Exception catch (e) {
        NyLogger.error(e.toString());
        return null;
      }
    }
    return data;
  }

  /// Read a JSON value from the local storage
  static Future<dynamic> readJson<T>(String key, {dynamic defaultValue}) async {
    String? data = await manager().read(key: key);
    if (data == null) {
      return defaultValue;
    }

    try {
      return jsonDecode(data);
    } on Exception catch (e) {
      NyLogger.error(e.toString());
      return null;
    }
  }

  /// Deletes all keys with associated values.
  static Future deleteAll(
      {bool andFromBackpack = false, List<String>? excludeKeys}) async {
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
    await manager().deleteAll();
  }

  /// Update a value in the local storage by [index].
  static Future<bool> updateCollectionByIndex<T>(
      int index, T Function(T item) object,
      {required String key}) async {
    List<T> collection = await readCollection<T>(key);

    // Check if the collection is empty or the index is out of bounds
    if (collection.isEmpty || index < 0 || index >= collection.length) {
      NyLogger.error(
          '[NyStorage.updateCollectionByIndex] The collection is empty or the index is out of bounds.');
      return false;
    }

    // Update the item
    T newItem = object(collection[index]);

    collection[index] = newItem;

    await saveCollection<T>(key, collection);
    return true;
  }

  /// Decrypts and returns all keys with associated values.
  static Future<Map<String, String>> readAll() async =>
      await manager().readAll();

  /// Deletes associated value for the given [key].
  static Future delete(String key, {bool andFromBackpack = false}) async {
    if (andFromBackpack == true) {
      Backpack.instance.delete(key);
    }
    return await manager().delete(key: key);
  }

  /// Deletes a collection from the given [key].
  static Future deleteCollection(String key,
      {bool andFromBackpack = false}) async {
    await delete(key, andFromBackpack: andFromBackpack);
  }

  /// Add a newItem to the collection using a [key].
  static Future addToCollection<T>(String key,
      {required dynamic item,
      bool allowDuplicates = true,
      Map<Type, dynamic>? modelDecoders}) async {
    List<T> collection =
        await readCollection<T>(key, modelDecoders: modelDecoders);
    if (allowDuplicates == false) {
      if (collection.any((collect) => collect == item)) {
        return;
      }
    }
    collection.add(item);
    await saveCollection<T>(key, collection);
  }

  /// Update item(s) in a collection using a where query.
  static Future updateCollectionWhere<T>(bool Function(dynamic value) where,
      {required String key, required T Function(dynamic value) update}) async {
    List<T> collection = await readCollection<T>(key);
    if (collection.isEmpty) return;

    collection.where((value) => where(value)).forEach((element) {
      update(element);
    });

    await saveCollection<T>(key, collection);
  }

  /// Read the collection values using a [key].
  static Future<List<T>> readCollection<T>(String key,
      {Map<Type, dynamic>? modelDecoders}) async {
    String? data = await read(key);
    if (data == null || data == "") return [];

    List<dynamic> listData = jsonDecode(data);

    if (!["dynamic", "string", "double", "int"]
        .contains(T.toString().toLowerCase())) {
      return List.from(listData)
          .map((json) =>
              dataToModel<T>(data: json, modelDecoders: modelDecoders))
          .toList();
    }
    return List.from(listData).toList().cast();
  }

  /// Sets the [key] to null.
  static Future clear(String key) async => await NyStorage.save(key, null);

  /// Delete item(s) from a collection using a where query.
  static Future deleteFromCollectionWhere<T>(bool Function(T value) where,
      {required String key}) async {
    List<T> collection = await readCollection<T>(key);
    if (collection.isEmpty) return;

    collection.removeWhere((value) => where(value));

    await saveCollection<T>(key, collection);
  }

  /// Delete an item of a collection using a [index] and the collection [key].
  static Future deleteFromCollection<T>(int index,
      {required String key}) async {
    List<T> collection = await readCollection<T>(key);
    if (collection.isEmpty) return;
    collection.removeAt(index);
    await saveCollection<T>(key, collection);
  }

  /// Save a list of objects to a [collection] using a [key].
  static Future saveCollection<T>(String key, List collection) async {
    if (["dynamic", "string", "double", "int"]
        .contains(T.toString().toLowerCase())) {
      await save(key, jsonEncode(collection));
      return;
    }

    String json = jsonEncode(collection.map((item) {
      Map<String, dynamic>? data = _objectToJson(item);
      if (data != null) {
        return data;
      }
      return item;
    }).toList());
    await save(key, json);
  }

  /// Delete a value from a collection using a [key] and the [value] you want to remove.
  static Future deleteValueFromCollection<T>(String key,
      {dynamic value}) async {
    List<T> collection = await readCollection<T>(key);
    collection.removeWhere((item) => item == value);
    await saveCollection<T>(key, collection);
  }

  /// Checks if a collection is empty
  static Future<bool> isCollectionEmpty(String key) async =>
      (await readCollection(key)).isEmpty;

  /// Sync all the keys stored to the [Backpack] instance.
  static Future syncToBackpack({bool overwrite = false}) async {
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
}

/// Attempts to call toJson() on an [object].
Map<String, dynamic>? _objectToJson(dynamic object) {
  try {
    Map<String, dynamic> json = object.toJson();
    return json;
  } on NoSuchMethodError catch (e) {
    NyLogger.debug(e.toString());
    NyLogger.error(
        '[NyStorage.store] ${object.runtimeType.toString()} model needs to implement the toJson() method.');
  }
  return null;
}

/// Checks if the value is an integer.
bool _isInteger(String? s) {
  if (s == null) {
    return false;
  }

  RegExp regExp = RegExp(
    r"^-?[0-9]+$",
    caseSensitive: false,
    multiLine: false,
  );

  return regExp.hasMatch(s);
}

/// Checks if the value is a double.
bool _isDouble(String? s) {
  if (s == null) {
    return false;
  }

  RegExp regExp = RegExp(
    r"^[0-9]{1,13}([.]?[0-9]*)?$",
    caseSensitive: false,
    multiLine: false,
  );

  return regExp.hasMatch(s);
}

/// Read data from the storage class.
Future<dynamic> storageRead<T>(String key,
    {Map<Type, dynamic>? modelDecoders}) async {
  return await NyStorage.read<T>(key, modelDecoders: modelDecoders);
}

/// Save data to the storage class.
Future storageSave(String key, object, {bool inBackpack = false}) async {
  if (_Json.tryEncode(object) != null) {
    return await NyStorage.saveJson(key, object, inBackpack: inBackpack);
  }
  return await NyStorage.save(key, object, inBackpack: inBackpack);
}

/// Delete data from the storage class.
Future storageDelete(String key) async {
  return await NyStorage.clear(key);
}

/// Read a collection from the storage class.
Future<List<T>> storageCollectionRead<T>(String key,
    {Map<Type, dynamic>? modelDecoders}) async {
  return await NyStorage.readCollection<T>(key, modelDecoders: modelDecoders);
}

/// Save a collection to the storage class.
Future storageCollectionSave<T>(String key, List collection) async {
  return await NyStorage.saveCollection<T>(key, collection);
}

/// Delete a value from a collection in the storage class.
Future storageCollectionDeleteValue<T>(String key, {dynamic value}) async {
  return await NyStorage.deleteValueFromCollection<T>(key, value: value);
}

/// Delete an item from a collection in the storage class.
Future storageCollectionDeleteWhere<T>(
    String key, bool Function(T where) value) async {
  return await NyStorage.deleteFromCollectionWhere<T>(value, key: key);
}

/// Delete an item from a collection in the storage class.
Future storageCollectionDeleteIndex<T>(String key, int index) async {
  return await NyStorage.deleteFromCollection<T>(index, key: key);
}

/// Json helper class
class _Json {
  static String? tryEncode(data) {
    try {
      return jsonEncode(data);
    } catch (e) {
      return null;
    }
  }
}
