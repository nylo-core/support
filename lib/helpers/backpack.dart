import 'package:nylo_support/nylo.dart';

/// Backpack class for storing data
/// This class is not designed to store huge amounts of data.
class Backpack {
  Map<String, dynamic> _values = {};

  Backpack._privateConstructor();

  static final Backpack instance = Backpack._privateConstructor();

  /// Read data from the Backpack with a [key].
  T? read<T>(String key) {
    if (!_values.containsKey(key)) {
      return null;
    }
    return _values[key];
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
  Nylo nylo({String key = 'nylo'}) => _values[key];
}
