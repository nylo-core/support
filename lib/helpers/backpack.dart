/// Backpack class for storing data
/// This class is not designed to store huge amounts of data.
class Backpack {
  Map<String, dynamic> _values = {};

  Backpack._privateConstructor();

  static final Backpack instance = Backpack._privateConstructor();

  T? read<T>(String key) {
    if (!_values.containsKey(key)) {
      return null;
    }
    return _values[key];
  }

  set(String key, dynamic value) => _values[key] = value;

  /// Returns an instance of Nylo
  nylo({String key = 'nylo'}) => _values[key];
}