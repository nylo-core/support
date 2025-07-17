import 'dart:convert';
import '/helpers/helper.dart';
import '/nylo.dart';

/// Backpack class for storing data
/// This class is not designed to store huge amounts of data.
class Backpack {
  final Map<String, dynamic> _values = {};

  Backpack._privateConstructor();

  static Backpack instance = Backpack._privateConstructor();

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

  /// Update the session with a [key] and [value].
  void sessionUpdate(String name, String key, dynamic value) {
    if (!_values.containsKey(name)) {
      _values[name] = {};
    }
    _values[name][key] = value;
  }

  /// Get a session value using a [key].
  T? sessionGet<T>(String name, String key) {
    if (!_values.containsKey(name)) {
      return null;
    }
    return _values[name][key];
  }

  /// Remove a session value using a [key].
  void sessionRemove(String name, String key) {
    if (_values.containsKey(name)) {
      _values[name].remove(key);
    }
  }

  /// Flush a session using a [name].
  void sessionFlush(String name) {
    if (_values.containsKey(name)) {
      _values.remove(name);
    }
  }

  /// Get all session values.
  Map<String, dynamic>? sessionData(String name) {
    if (_values.containsKey(name)) {
      return Map<String, dynamic>.from(_values[name]);
    }
    return null;
  }

  /// Checks if Backpack contains a key.
  bool contains(String key) {
    return _values.containsKey(key);
  }

  /// Set a value using a [key] and [value].
  void save(String key, dynamic value) => _values[key] = value;

  /// Delete a value using a [key].
  void delete(String key) {
    if (_values.containsKey(key)) {
      _values.remove(key);
    }
  }

  /// Delete all values from [Backpack].
  void deleteAll() {
    _values.removeWhere((key, value) {
      if (['nylo', 'event_bus'].contains(key)) {
        return false;
      }
      return true;
    });
  }

  /// Returns an instance of Nylo.
  Nylo nylo({String key = 'nylo'}) {
    if (!_values.containsKey(key)) {
      throw Exception('Nylo has not been initialized yet');
    }
    return _values[key];
  }

  /// Check if the Backpack class contains an instance of Nylo.
  bool isNyloInitialized({String? key = "nylo"}) =>
      _values.containsKey(key) && _values[key] is Nylo;
}

/// Read data from the Backpack with a [key].
T? backpackRead<T>(String key, {dynamic defaultValue}) =>
    Backpack.instance.read<T>(key, defaultValue: defaultValue);

/// Save a value using a [key] and [value].
void backpackSave(String key, dynamic value) =>
    Backpack.instance.save(key, value);

/// Delete a value using a [key].
void backpackDelete(String key) => Backpack.instance.delete(key);

/// Delete all values from [Backpack].
void backpackDeleteAll() => Backpack.instance.deleteAll();

/// Returns an instance of Nylo.
Nylo backpackNylo({String key = 'nylo'}) => Backpack.instance.nylo(key: key);

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
