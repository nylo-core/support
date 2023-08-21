import 'dart:convert';

import 'package:nylo_support/helpers/helper.dart';
import 'package:nylo_support/nylo.dart';

/// Backpack class for storing data
/// This class is not designed to store huge amounts of data.
class Backpack {
  Map<String, dynamic> _values = {};

  Backpack._privateConstructor();

  static final Backpack instance = Backpack._privateConstructor();

  /// Read data from the Backpack with a [key].
  T? read<T>(String key, {dynamic defaultValue}) {
    if (!_values.containsKey(key)) {
      if (defaultValue != null) return defaultValue;
      return null;
    }
    dynamic value = _values[key];
    if (T.toString() != 'dynamic' && (value is String)) {
      dynamic nyJson = _NyJson.tryDecode(value);
      if (nyJson != null) {
        T model = dataToModel<T>(data: nyJson);
        _values[key] = model;
        return model;
      }
    }

    return value;
  }

  /// Checks if Backpack contains a key.
  bool contains(String key) {
    return _values.containsKey(key);
  }

  /// Set a value using a [key] and [value].
  void set(String key, dynamic value) => _values[key] = value;

  /// Delete a value using a [key].
  void delete(String key) {
    if (_values.containsKey(key)) {
      _values.remove(key);
    }
  }

  /// Delete all values from [Backpack].
  void deleteAll() {
    _values = {};
  }

  /// Returns an instance of Nylo.
  Nylo nylo({String key = 'nylo'}) {
    if (!_values.containsKey(key)) {
      throw Exception('Nylo has not been initialized yet');
    }
    return _values[key];
  }

  /// Returns an instance of the auth user.
  T? auth<T>({String? key}) {
    String storageKey = getEnv('AUTH_USER_KEY', defaultValue: 'AUTH_USER');
    if (key != null) {
      storageKey = key;
    }
    if (!_values.containsKey(storageKey)) {
      return null;
    }
    return _values[storageKey];
  }

  /// Check if the Backpack class contains an instance of Nylo.
  bool isNyloInitialized({String? key = "nylo"}) =>
      _values.containsKey(key) && _values[key] is Nylo;
}

/// helper to encode and decode data
class _NyJson {
  static dynamic tryDecode(data) {
    try {
      return jsonDecode(data);
    } catch (e) {
      return null;
    }
  }
}
