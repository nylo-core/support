/// Represents a single option item for form components like dropdowns, radios, and chips.
///
/// [FormOption] encapsulates a key-value pair where [value] is the actual data
/// stored/returned and [label] is the human-readable text displayed to users.
///
/// Example usage:
/// ```dart
/// final option = FormOption(value: 'us', label: 'United States');
/// print(option.label); // United States
/// print(option.value); // us
/// ```
class FormOption {
  /// The underlying data value for this option.
  ///
  /// This is the value that will be returned in form callbacks and stored
  /// in form data when this option is selected.
  final String value;

  /// The display text shown to users for this option.
  ///
  /// This human-readable label is what users see in dropdown menus,
  /// radio button labels, chip text, etc.
  final String label;

  /// Creates a [FormOption] with the specified value and label.
  ///
  /// Both [value] and [label] are required and represent the data value
  /// and display text respectively.
  const FormOption({required this.value, required this.label});

  /// Creates a [FormOption] from a JSON map.
  ///
  /// Expects a map with 'value'/'id' and 'label'/'name' keys.
  /// Falls back to 'id' and 'name' keys if 'value' and 'label' are not present.
  factory FormOption.fromJson(Map<String, dynamic> json) {
    return FormOption(
      value: json['value'] as String? ?? json['id']?.toString() ?? '',
      label: json['label'] as String? ?? json['name']?.toString() ?? '',
    );
  }

  /// Converts this [FormOption] to a JSON map representation.
  ///
  /// Returns a map with 'value' and 'label' keys containing the
  /// respective string values.
  Map<String, dynamic> toJson() {
    return {'value': value, 'label': label};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FormOption && other.value == value && other.label == label;
  }

  @override
  int get hashCode => value.hashCode ^ label.hashCode;

  @override
  String toString() => 'FormOption(value: $value, label: $label)';
}

/// A collection of form options that can be used with various form field widgets.
///
/// [FormCollection] provides a unified interface for handling different types of
/// option data structures including flat arrays, key-value maps, and structured objects.
/// It automatically converts various input formats into a consistent [FormOption] list.
///
/// Supported input formats:
/// - `List<String>`: Simple string arrays
/// - `Map<String, String>`: Key-value pairs
/// - `List<Map<String, dynamic>>`: Structured option objects
///
/// Example usage:
/// ```dart
/// // From array
/// final options1 = FormCollection.from(['Option 1', 'Option 2']);
///
/// // From map
/// final options2 = FormCollection.from({'key1': 'Label 1', 'key2': 'Label 2'});
///
/// // From structured list
/// final options3 = FormCollection.fromKeyValue([
///   {'value': 'us', 'label': 'United States'},
///   {'value': 'ca', 'label': 'Canada'}
/// ]);
/// ```
class FormCollection {
  /// Internal list of normalized form options.
  final List<FormOption> _options;

  /// Whether this collection was created from key-value structured data.
  final bool _isKeyValue;

  /// Private constructor for internal use.
  FormCollection._(this._options, this._isKeyValue);

  /// Creates an empty [FormCollection] with no options.
  ///
  /// Useful as a default value for fields whose options will be loaded later
  /// (e.g. from an API via `define()` in `init`).
  const FormCollection.empty() : _options = const [], _isKeyValue = false;

  /// Creates a [FormCollection] from a list of structured option maps.
  ///
  /// Each map should contain 'value'/'id' and 'label'/'name' keys.
  /// This is useful when working with API responses or structured data.
  ///
  /// Example:
  /// ```dart
  /// final collection = FormCollection.fromKeyValue([
  ///   {'value': 'en', 'label': 'English'},
  ///   {'value': 'es', 'label': 'Spanish'}
  /// ]);
  /// ```
  factory FormCollection.fromKeyValue(List<Map<String, dynamic>> data) {
    final options = data.map((item) => FormOption.fromJson(item)).toList();
    return FormCollection._(options, true);
  }

  /// Creates a [FormCollection] from a map of key-value pairs.
  ///
  /// The map keys become option values and map values become option labels.
  /// This is convenient for simple key-label mappings.
  ///
  /// Example:
  /// ```dart
  /// final collection = FormCollection.fromMap({
  ///   'small': 'Small Size',
  ///   'large': 'Large Size'
  /// });
  /// ```
  factory FormCollection.fromMap(Map<String, String> data) {
    final options = data.entries
        .map((entry) => FormOption(value: entry.key, label: entry.value))
        .toList();
    return FormCollection._(options, true);
  }

  /// Creates a [FormCollection] from a flat array of strings.
  ///
  /// Each string serves as both the value and label for the option.
  /// This is the simplest format for basic option lists.
  ///
  /// Example:
  /// ```dart
  /// final collection = FormCollection.fromArray(['Red', 'Green', 'Blue']);
  /// ```
  factory FormCollection.fromArray(List<String> data) {
    final options = data
        .map((item) => FormOption(value: item, label: item))
        .toList();
    return FormCollection._(options, false);
  }

  /// Creates a [FormCollection] from dynamic input data with automatic structure detection.
  ///
  /// This factory constructor analyzes the input and creates the appropriate
  /// collection type based on the data structure:
  /// - `Map<String, String>` → Uses [fromMap]
  /// - `List<Map<String, dynamic>>` → Uses [fromKeyValue]
  /// - `List<String>` → Uses [fromArray]
  ///
  /// Throws [ArgumentError] if the data format is not supported.
  ///
  /// Example:
  /// ```dart
  /// // Auto-detects as array format
  /// final options1 = FormCollection.from(['A', 'B', 'C']);
  ///
  /// // Auto-detects as map format
  /// final options2 = FormCollection.from({'key': 'value'});
  /// ```
  factory FormCollection.from(dynamic data) {
    if (data is Map<String, String>) {
      // Map structure
      return FormCollection.fromMap(data);
    } else if (data is List) {
      if (data.isEmpty) {
        return FormCollection._([], true);
      }

      // Check all elements to determine structure (not just first)
      bool allMaps = data.every((e) => e is Map<String, dynamic>);
      bool allStrings = data.every((e) => e is String);

      if (allMaps) {
        // Key-value structure (List of Maps)
        return FormCollection.fromKeyValue(data.cast<Map<String, dynamic>>());
      } else if (allStrings) {
        // Flat array structure
        return FormCollection.fromArray(data.cast<String>());
      }
    }
    throw ArgumentError(
      'FormCollection requires List<String>, List<Map<String, dynamic>>, or Map<String, String>',
    );
  }

  /// Returns an immutable list of all options in this collection.
  List<FormOption> get options => List.unmodifiable(_options);

  /// Returns the total number of options in this collection.
  int get length => _options.length;

  /// Returns true if this collection contains no options.
  bool get isEmpty => _options.isEmpty;

  /// Returns true if this collection contains at least one option.
  bool get isNotEmpty => _options.isNotEmpty;

  /// Returns true if this collection was created from key-value structured data.
  bool get isKeyValueStructure => _isKeyValue;

  /// Returns true if this collection was created from a flat array structure.
  bool get isArrayStructure => !_isKeyValue;

  /// Accesses a [FormOption] at the specified index.
  ///
  /// Returns `null` if the index is out of bounds rather than throwing an exception.
  /// This provides safe access to collection items.
  ///
  /// Example:
  /// ```dart
  /// final collection = FormCollection.from(['A', 'B']);
  /// print(collection[0]?.label); // 'A'
  /// print(collection[5]?.label); // null
  /// ```
  FormOption? operator [](int index) {
    if (index < 0 || index >= _options.length) return null;
    return _options[index];
  }

  FormOption get first => _options.first;
  FormOption get last => _options.last;

  // Retrieval methods for form usage
  FormOption? getByValue(String value) {
    try {
      return _options.firstWhere((option) => option.value == value);
    } catch (e) {
      return null;
    }
  }

  FormOption? getByLabel(String label) {
    try {
      return _options.firstWhere((option) => option.label == label);
    } catch (e) {
      return null;
    }
  }

  String? getLabelByValue(String value) {
    return getByValue(value)?.label;
  }

  String? getValueByLabel(String label) {
    return getByLabel(label)?.value;
  }

  List<FormOption> searchByLabel(String query) {
    final lowerQuery = query.toLowerCase();
    return _options
        .where((option) => option.label.toLowerCase().contains(lowerQuery))
        .toList();
  }

  int indexOfValue(String value) {
    return _options.indexWhere((option) => option.value == value);
  }

  int indexOfLabel(String label) {
    return _options.indexWhere((option) => option.label == label);
  }

  bool containsValue(String value) {
    return _options.any((option) => option.value == value);
  }

  bool containsLabel(String label) {
    return _options.any((option) => option.label == label);
  }

  // Form-specific utility methods
  List<String> get values => _options.map((option) => option.value).toList();
  List<String> get labels => _options.map((option) => option.label).toList();

  // Validation helpers
  bool isValidValue(String? value) {
    if (value == null) return false;
    return containsValue(value);
  }

  String? validateValue(String? value, {String? errorMessage}) {
    if (value == null || value.isEmpty) {
      return errorMessage ?? 'Please select an option';
    }
    if (!isValidValue(value)) return errorMessage ?? 'Invalid selection';
    return null;
  }

  // Conversion methods for different form libraries
  List<Map<String, dynamic>> toKeyValueList() {
    return _options.map((option) => option.toJson()).toList();
  }

  Map<String, String> toMap() {
    return Map.fromEntries(
      _options.map((option) => MapEntry(option.value, option.label)),
    );
  }

  // Iterator support
  Iterator<FormOption> get iterator => _options.iterator;

  // Functional methods
  FormCollection filter(bool Function(FormOption) test) {
    final filtered = _options.where(test).toList();
    return FormCollection._(filtered, _isKeyValue);
  }

  FormCollection sort([int Function(FormOption, FormOption)? compare]) {
    final sorted = [..._options];
    if (compare != null) {
      sorted.sort(compare);
    } else {
      sorted.sort((a, b) => a.label.compareTo(b.label));
    }
    return FormCollection._(sorted, _isKeyValue);
  }

  @override
  String toString() {
    return 'FormCollection(${_options.length} options, keyValue: $_isKeyValue)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FormCollection &&
        other._isKeyValue == _isKeyValue &&
        _listEquals(other._options, _options);
  }

  @override
  int get hashCode => _options.hashCode ^ _isKeyValue.hashCode;

  static bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
