import 'dart:convert';
import '../ny_time.dart';

/// In-memory cache implementation for testing.
///
/// This class provides a memory-based cache that mimics the behavior
/// of [NyCache] without requiring file system access.
///
/// Example:
/// ```dart
/// final cache = NyTestCache();
/// await cache.put('key', 'value', seconds: 60);
/// final value = await cache.get<String>('key');
/// ```
class NyTestCache {
  static NyTestCache? _instance;
  final Map<String, _CacheEntry> _store = {};

  NyTestCache._();

  /// Get a singleton instance of the test cache.
  static NyTestCache getInstance() {
    _instance ??= NyTestCache._();
    return _instance!;
  }

  /// Reset the singleton instance (useful between tests).
  static void resetInstance() {
    _instance?._store.clear();
    _instance = null;
  }

  /// Saves a value in the cache with an expiration time.
  Future<T> saveRemember<T>(
    String key,
    int seconds,
    Function() callback,
  ) async {
    if (_store.containsKey(key)) {
      final entry = _store[key]!;
      if (entry.expiration == null ||
          NyTime.now().isBefore(entry.expiration!)) {
        return entry.value as T;
      }
    }

    T value;
    if (callback is Future Function()) {
      value = await callback() as T;
    } else {
      value = callback() as T;
    }

    final expiration = NyTime.now().add(Duration(seconds: seconds));
    _store[key] = _CacheEntry(value: value, expiration: expiration);
    return value;
  }

  /// Saves a value in the cache without an expiration time.
  Future<T> saveForever<T>(String key, Future<T> Function() callback) async {
    if (_store.containsKey(key)) {
      return _store[key]!.value as T;
    }

    final T value = await callback();
    _store[key] = _CacheEntry(value: value);
    return value;
  }

  /// Removes a specific item from the cache.
  Future<void> clear(String key) async {
    _store.remove(key);
  }

  /// Removes all items from the cache.
  Future<void> flush() async {
    _store.clear();
  }

  /// Retrieves a list of all cache keys.
  Future<List<String>> documents() async {
    return _store.keys.toList();
  }

  /// Checks if a specific key exists in the cache.
  Future<bool> has(String key) async {
    return _store.containsKey(key);
  }

  /// Retrieves a value from the cache.
  Future<T?> get<T>(String key) async {
    if (!_store.containsKey(key)) {
      return null;
    }

    final entry = _store[key]!;
    if (entry.expiration != null && NyTime.now().isAfter(entry.expiration!)) {
      _store.remove(key);
      return null;
    }

    return entry.value as T?;
  }

  /// Stores a value in the cache.
  Future<void> put<T>(String key, T value, {int? seconds}) async {
    DateTime? expiration;
    if (seconds != null) {
      expiration = NyTime.now().add(Duration(seconds: seconds));
    }
    _store[key] = _CacheEntry(value: value, expiration: expiration);
  }

  /// Calculates the total size of the cache in bytes (approximate).
  Future<int> size() async {
    int totalSize = 0;
    for (var entry in _store.values) {
      try {
        totalSize += jsonEncode(entry.value).length;
      } catch (_) {
        totalSize += entry.value.toString().length;
      }
    }
    return totalSize;
  }

  /// Get all entries (for debugging).
  Map<String, dynamic> get entries =>
      _store.map((key, value) => MapEntry(key, value.value));

  /// Get count of entries.
  int get count => _store.length;

  /// Check if cache is empty.
  bool get isEmpty => _store.isEmpty;

  /// Check if cache is not empty.
  bool get isNotEmpty => _store.isNotEmpty;
}

class _CacheEntry {
  final dynamic value;
  final DateTime? expiration;

  _CacheEntry({required this.value, this.expiration});
}
