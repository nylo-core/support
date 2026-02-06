import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'backpack.dart';

/// Cache helper
class NyCache {
  static const String _cacheDir = 'nycache';
  static NyCache? _instance;
  static Future<NyCache>? _initFuture;

  Directory? _cacheDirectory;

  /// Whether the cache is available (not on web platform).
  bool get isAvailable => _cacheDirectory != null;

  NyCache._();

  /// Gets the cache file for a given key.
  /// Sanitizes the key to prevent path traversal attacks.
  File _fileFor(String key) {
    final sanitized = key.replaceAll(RegExp(r'[/\\.]'), '_');
    return File('${_cacheDirectory!.path}/$sanitized');
  }

  /// Serializes a value for storage.
  dynamic _serialize(dynamic value) {
    if (value is Response) {
      return {
        'data': value.data,
        'statusCode': value.statusCode,
        'statusMessage': value.statusMessage,
      };
    }
    return value;
  }

  static Future<NyCache> getInstance() async {
    if (_instance != null) return _instance!;

    // Use a single future to prevent race conditions
    _initFuture ??= _createInstance();
    return _initFuture!;
  }

  static Future<NyCache> _createInstance() async {
    final instance = NyCache._();
    await instance._init();
    _instance = instance;
    return instance;
  }

  /// Initializes the cache directory.
  ///
  /// This method creates the cache directory if it doesn't exist.
  /// It's called automatically when getting an instance of the Cache.
  Future<void> _init() async {
    if (kIsWeb) {
      // Cache is not available on web - _cacheDirectory remains null
      return;
    }
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    _cacheDirectory = Directory('${appDocDir.path}/$_cacheDir');
    if (!await _cacheDirectory!.exists()) {
      await _cacheDirectory!.create(recursive: true);
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
  /// Returns null on web platform where caching is not available.
  Future<T?> saveRemember<T>(
    String key,
    int seconds,
    FutureOr<T> Function() callback,
  ) async {
    if (!isAvailable) return await callback();

    final cacheFile = _fileFor(key);
    if (await cacheFile.exists()) {
      try {
        final data = jsonDecode(await cacheFile.readAsString());
        final expiration = DateTime.tryParse(data['expiration'] ?? '');
        if (expiration != null && DateTime.now().isBefore(expiration)) {
          return data['value'] as T?;
        }
      } catch (_) {
        // Corrupted cache file, delete and continue to fetch fresh value
        await cacheFile.delete();
      }
    }

    final value = await callback();
    await cacheFile.writeAsString(
      jsonEncode({
        'value': _serialize(value),
        'expiration': DateTime.now()
            .add(Duration(seconds: seconds))
            .toIso8601String(),
      }),
    );
    return value;
  }

  /// Saves a value in the cache without an expiration time.
  ///
  /// [key] is the unique identifier for the cached item.
  /// [callback] is a function that returns the value to be cached.
  ///
  /// Returns the cached value, either from the cache if it exists,
  /// or by calling the callback function and caching the result.
  Future<T?> saveForever<T>(String key, FutureOr<T> Function() callback) async {
    if (!isAvailable) return await callback();

    final cacheFile = _fileFor(key);
    if (await cacheFile.exists()) {
      try {
        final data = jsonDecode(await cacheFile.readAsString());
        return data['value'] as T?;
      } catch (_) {
        // Corrupted cache file, delete and continue to fetch fresh value
        await cacheFile.delete();
      }
    }

    final value = await callback();
    await cacheFile.writeAsString(jsonEncode({'value': _serialize(value)}));
    return value;
  }

  /// Removes a specific item from the cache.
  ///
  /// [key] is the unique identifier of the item to be removed.
  Future<void> clear(String key) async {
    if (!isAvailable) return;

    final cacheFile = _fileFor(key);
    if (await cacheFile.exists()) {
      await cacheFile.delete();
    }
  }

  /// Removes all items from the cache.
  ///
  /// This method deletes the entire cache directory and recreates it.
  Future<void> flush() async {
    if (!isAvailable) return;

    if (await _cacheDirectory!.exists()) {
      await _cacheDirectory!.delete(recursive: true);
    }
    await _cacheDirectory!.create(recursive: true);
  }

  /// Retrieves a list of all cache keys.
  ///
  /// Returns a list of strings, where each string is a cache key.
  /// Returns an empty list on web platform.
  Future<List<String>> documents() async {
    if (!isAvailable) return [];

    if (!await _cacheDirectory!.exists()) return [];

    final List<FileSystemEntity> entities = await _cacheDirectory!
        .list()
        .toList();
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
  /// Returns false on web platform.
  Future<bool> has(String key) async {
    if (!isAvailable) return false;
    return _fileFor(key).exists();
  }

  /// Retrieves a value from the cache.
  ///
  /// [key] is the unique identifier of the item to retrieve.
  ///
  /// Returns the cached value if it exists and hasn't expired, null otherwise.
  /// If the item has expired, it is automatically removed from the cache.
  /// Returns null on web platform.
  Future<T?> get<T>(String key) async {
    if (!isAvailable) return null;

    final cacheFile = _fileFor(key);
    if (!await cacheFile.exists()) return null;

    try {
      final data = jsonDecode(await cacheFile.readAsString());
      final expirationStr = data['expiration'] as String?;
      if (expirationStr != null) {
        final expiration = DateTime.tryParse(expirationStr);
        if (expiration == null || DateTime.now().isAfter(expiration)) {
          await cacheFile.delete();
          return null;
        }
      }
      return data['value'] as T?;
    } catch (_) {
      // Corrupted cache file, delete it
      await cacheFile.delete();
      return null;
    }
  }

  /// Stores a value in the cache.
  ///
  /// [key] is the unique identifier for the cached item.
  /// [value] is the value to be stored.
  /// [seconds] is an optional parameter for setting an expiration time.
  Future<void> put<T>(String key, T value, {int? seconds}) async {
    if (!isAvailable) return;

    final data = <String, dynamic>{'value': _serialize(value)};
    if (seconds != null) {
      data['expiration'] = DateTime.now()
          .add(Duration(seconds: seconds))
          .toIso8601String();
    }
    await _fileFor(key).writeAsString(jsonEncode(data));
  }

  /// Calculates the total size of the cache in bytes.
  ///
  /// Returns the sum of the sizes of all files in the cache directory.
  /// Returns 0 on web platform.
  Future<int> size() async {
    if (!isAvailable) return 0;

    int totalSize = 0;
    await for (var file in _cacheDirectory!.list(
      recursive: true,
      followLinks: false,
    )) {
      if (file is File) {
        totalSize += await file.length();
      }
    }
    return totalSize;
  }
}

/// Get the cache instance.
/// Throws [StateError] if cache is not initialized.
NyCache cache() {
  final nyCache = backpackNylo().getCache;
  if (nyCache == null) {
    throw StateError('Cache not initialized');
  }
  return nyCache;
}
