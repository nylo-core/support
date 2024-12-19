import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '/helpers/backpack.dart';
import '/helpers/extensions.dart';
import 'package:path_provider/path_provider.dart';

/// Cache helper
class NyCache {
  static const String _cacheDir = 'nycache';
  static NyCache? _instance;

  late Directory _cacheDirectory;

  NyCache._();

  static Future<NyCache> getInstance() async {
    if (_instance == null) {
      _instance = NyCache._();
      await _instance!._init();
    }
    return _instance!;
  }

  /// Initializes the cache directory.
  ///
  /// This method creates the cache directory if it doesn't exist.
  /// It's called automatically when getting an instance of the Cache.
  Future<void> _init() async {
    if (kIsWeb) {
      return;
    }
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    _cacheDirectory = Directory('${appDocDir.path}/$_cacheDir');
    if (!await _cacheDirectory.exists()) {
      await _cacheDirectory.create(recursive: true);
    }
  }

  /// Saves a value in the cache with an expiration time.
  ///
  /// [key] is the unique identifier for the cached item.
  /// [seconds] is the number of seconds until the item expires.
  /// [callback] is a function that returns the value to be cached.
  ///
  /// Returns the cached value, either from the cache if it exists and hasn't expired,
  /// or by calling the callback function and caching the result.
  Future saveRemember<T>(String key, int seconds, Function() callback) async {
    final File cacheFile = File('${_cacheDirectory.path}/$key');
    if (await cacheFile.exists()) {
      final content = await cacheFile.readAsString();
      final data = jsonDecode(content);
      if (DateTime.now().isBefore(DateTime.parse(data['expiration']))) {
        return data['value'];
      }
    }

    T value;
    if (callback is Future Function()) {
      value = await callback();
    } else {
      value = callback();
    }

    final expiration = DateTime.now().add(Duration(seconds: seconds));
    await cacheFile.writeAsString(jsonEncode({
      'value': value is Response ? value.toJson() : value,
      'expiration': expiration.toIso8601String(),
    }));
    return value;
  }

  /// Saves a value in the cache without an expiration time.
  ///
  /// [key] is the unique identifier for the cached item.
  /// [callback] is a function that returns the value to be cached.
  ///
  /// Returns the cached value, either from the cache if it exists,
  /// or by calling the callback function and caching the result.
  Future saveForever<T>(String key, Future<T> Function() callback) async {
    final File cacheFile = File('${_cacheDirectory.path}/$key');
    if (await cacheFile.exists()) {
      final content = await cacheFile.readAsString();
      final data = jsonDecode(content);
      return data['value'];
    }

    final T value = await callback();
    await cacheFile.writeAsString(jsonEncode({
      'value': value,
    }));
    return value;
  }

  /// Removes a specific item from the cache.
  ///
  /// [key] is the unique identifier of the item to be removed.
  Future<void> clear(String key) async {
    final File cacheFile = File('${_cacheDirectory.path}/$key');
    if (await cacheFile.exists()) {
      await cacheFile.delete();
    }
  }

  /// Removes all items from the cache.
  ///
  /// This method deletes the entire cache directory and recreates it.
  Future<void> flush() async {
    if (await _cacheDirectory.exists()) {
      await _cacheDirectory.delete(recursive: true);
    }
    await _cacheDirectory.create(recursive: true);
  }

  /// Retrieves a list of all cache keys.
  ///
  /// Returns a list of strings, where each string is a cache key.
  Future<List<String>> documents() async {
    final List<FileSystemEntity> entities =
        await _cacheDirectory.list().toList();
    return entities
        .whereType<File>()
        .map((file) => file.path.split('/').last)
        .toList();
  }

  /// Checks if a specific key exists in the cache.
  ///
  /// [key] is the unique identifier to check for.
  ///
  /// Returns true if the key exists, false otherwise.
  Future<bool> has(String key) async {
    final File cacheFile = File('${_cacheDirectory.path}/$key');
    return await cacheFile.exists();
  }

  /// Retrieves a value from the cache.
  ///
  /// [key] is the unique identifier of the item to retrieve.
  ///
  /// Returns the cached value if it exists and hasn't expired, null otherwise.
  /// If the item has expired, it is automatically removed from the cache.
  Future<T?> get<T>(String key) async {
    final File cacheFile = File('${_cacheDirectory.path}/$key');
    if (await cacheFile.exists()) {
      final content = await cacheFile.readAsString();
      final data = jsonDecode(content);
      if (data.containsKey('expiration')) {
        if (DateTime.now().isBefore(DateTime.parse(data['expiration']))) {
          return data['value'] as T?;
        } else {
          await cacheFile.delete();
          return null;
        }
      }
      return data['value'] as T?;
    }
    return null;
  }

  /// Stores a value in the cache.
  ///
  /// [key] is the unique identifier for the cached item.
  /// [value] is the value to be stored.
  /// [seconds] is an optional parameter for setting an expiration time.
  Future<void> put<T>(String key, T value, {int? seconds}) async {
    final File cacheFile = File('${_cacheDirectory.path}/$key');
    final Map<String, dynamic> data = {'value': value};
    if (seconds != null) {
      data['expiration'] =
          DateTime.now().add(Duration(seconds: seconds)).toIso8601String();
    }
    await cacheFile.writeAsString(jsonEncode(data));
  }

  /// Calculates the total size of the cache in bytes.
  ///
  /// Returns the sum of the sizes of all files in the cache directory.
  Future<int> size() async {
    int totalSize = 0;
    await for (var file
        in _cacheDirectory.list(recursive: true, followLinks: false)) {
      if (file is File) {
        totalSize += await file.length();
      }
    }
    return totalSize;
  }
}

/// Get the cache instance
NyCache cache() {
  if (backpackNylo().getCache == null) {
    throw Exception('Cache not initialized');
  }
  return backpackNylo().getCache!;
}
