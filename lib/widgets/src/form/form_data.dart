import 'dart:async';

import 'package:flutter/cupertino.dart';
import '/helpers/ny_helpers.dart';
import 'package:recase/recase.dart';

import '/widgets/ny_widgets.dart';

/// Base class for defining form structure, data, and behavior in Nylo applications.
///
/// [NyFormData] provides the internal form logic engine used by [NyFormWidget].
/// It manages field initialization, validation, data extraction, and state updates.
///
/// Users should extend [NyFormWidget] directly rather than subclassing this.
class NyFormData {
  /// Creates a new form data instance with the specified name.
  ///
  /// The [name] parameter serves as a unique identifier for the form and is used
  /// for state management. If an [init] function is defined, it will be called
  /// automatically to populate initial form data.
  NyFormData(String this.name) {
    if (init != null) {
      initialData(init!);
    }
  }

  /// The unique name identifier for this form.
  ///
  /// Used for state management and distinguishing between multiple form instances.
  String? name;

  /// Returns the state management key for this form.
  ///
  /// Generates a unique state key based on the form name, used internally
  /// by the Nylo state management system.
  String get stateName => 'form_$name';

  /// Stream controller for broadcasting form updates and changes.
  ///
  /// Used internally to coordinate updates between form fields and notify
  /// listeners of form state changes.
  StreamController<dynamic>? get updated {
    return _updatedStream;
  }

  StreamController<dynamic>? _updatedStream;

  /// Subscription for the onChanged stream listener.
  StreamSubscription? _onChangedSubscription;

  /// Callback function invoked when any field value changes.
  ///
  /// Receives the changed [Field] and its new value whenever a user
  /// interacts with form fields. Useful for real-time form processing.
  Function(Field field, dynamic value)? onChanged;

  /// Internal list of child widgets and form elements.
  List<dynamic> _children = [];

  /// Returns the list of form widgets and child elements.
  ///
  /// Contains the rendered form fields and any additional widgets
  /// that are part of the form structure.
  List<dynamic> get widgets => _children;

  /// Override this method to define the structure of your form.
  ///
  /// Should return a list of [Field] objects or lists of [Field] objects for rows.
  /// Each field defines an input type, validation rules, and display properties.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// fields() => [
  ///   Field.text("firstName"),
  ///   Field.text("lastName"),
  ///   [Field.text("city"), Field.text("state")], // Row of fields
  ///   Field.email("email"),
  /// ];
  /// ```
  List<dynamic> fields() => [];

  /// Processes and configures form fields for state management.
  ///
  /// Takes the fields defined in [fields()] and configures them with the
  /// provided stream controller for coordinated updates. Handles both
  /// individual fields and rows of fields.
  ///
  /// [stream] is the StreamController used for field synchronization.
  List<dynamic> getFields(StreamController stream) {
    List<dynamic> fieldList = [];
    for (var field in fields()) {
      if (field is Field) {
        field.setUpdated(stream);
        if (field.dummyData != null) {
          field.setValue(field.dummyData);
        }
        fieldList.add(field);
      }
      if (field is List) {
        List<Field> rowList = [];
        for (Field item in field) {
          item.setUpdated(stream);
          if (item.dummyData != null) {
            item.setValue(item.dummyData);
          }
          rowList.add(item);
        }
        fieldList.add(rowList);
      }
    }
    return fieldList;
  }

  /// Returns the data loading function for async form initialization.
  ///
  /// Used internally to retrieve the function that loads initial form data.
  /// This is typically called during form setup to populate field values.
  Function()? get getLoadData => _loadData;

  /// Internal reference to the data loading function.
  Function()? _loadData;

  /// Initial data passed from NyFormWidget constructor.
  /// Applied after fields are initialized.
  Map<String, dynamic>? _initialData;

  /// Override this method to provide initial form data.
  ///
  /// Can return either a synchronous Map or an async Future<Map> containing
  /// the initial field values. Keys should match field names and will be
  /// automatically converted to snake_case format.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Function()? get init => () async {
  ///   final userData = await UserService.getCurrentUser();
  ///   return {
  ///     'firstName': userData.firstName,
  ///     'email': userData.email,
  ///   };
  /// };
  /// ```
  Function()? get init => null;

  /// Loads and applies initial data from the [init] function to form fields.
  ///
  /// Executes the [init] function (if defined) and populates form fields with
  /// the returned data. Handles both synchronous and asynchronous init functions.
  /// Field names are automatically converted to snake_case to match field keys.
  setDataFromInit() async {
    if (init == null) return;
    Map<String, dynamic>? data;
    if (init is Future Function()) {
      data = await init!();
    } else {
      data = init!();
    }

    // map keys to snake case
    if (data == null) {
      return;
    }
    Map<String, dynamic> snakeCaseData = {};
    data.forEach((key, value) {
      snakeCaseData[key.snakeCase] = value;
    });

    setData(snakeCaseData);
  }

  /// Check if the form is ready
  void formReady() {
    _ready.add(true);
  }

  /// Initialize the stream for the form
  StreamController? initializeStream() {
    _updatedStream = StreamController.broadcast();
    return _updatedStream;
  }

  valueChange(data, {Function()? onChanged}) {
    if (_updatedStream == null) {
      initializeStream();
    }

    if (!(_updatedStream?.isClosed ?? true)) {
      _updatedStream?.add(data);
    }
  }

  /// StreamController for the form to check if it is ready
  final StreamController<bool> _ready = StreamController<bool>.broadcast();

  /// Stream for the form
  Stream<bool> get isReady => _ready.stream;

  /// Dispose of the form resources
  void dispose() {
    _onChangedSubscription?.cancel();
    _updatedStream?.close();
    _ready.close();
  }

  /// Load data for the form
  void initialData(Function() loadData) {
    _loadData = loadData;
  }

  /// On change function for the form
  void onChange(String field, Map<String, dynamic> data) {}

  /// Find a field in the form by its key
  Field findField(String key) {
    for (var item in _children) {
      if (item is Field && item.key.snakeCase == key.snakeCase) {
        return item;
      } else if (item is List) {
        for (Field subItem in item) {
          if (subItem.key.snakeCase == key.snakeCase) {
            return subItem;
          }
        }
      }
    }
    throw Exception("Field with key '$key' not found");
  }

  /// Clear the form
  void clear() {
    /// all clear on the fields
    widgets.forEach((field) {
      if (field is Field) {
        field.clear();
      } else if (field is List) {
        for (Field item in field) {
          item.clear();
        }
      }
    });
  }

  /// Clear a field in the form
  void clearField(String key) {
    Field field = findField(key);
    field.clear();
  }

  /// Set the value for a field in the form
  /// If the field does not exist, it will throw an exception
  void setFieldValue(String key, dynamic value) {
    Field field = findField(key);
    field.setValue(value);
  }

  /// Set the options for a field in the form.
  ///
  /// Supports Picker, Chip, and Radio field types.
  /// [key] is the field name, [options] should be a [FormCollection].
  void setFieldOptions(String key, FormCollection options) {
    Field field = findField(key);

    // Get the actual field widget (may be wrapped in IgnorePointer)
    Widget? fieldWidget = field.widget;
    if (field.widget is IgnorePointer) {
      final ignorePointer = field.widget as IgnorePointer;
      if (ignorePointer.child == null) {
        throw Exception("Field '$key' has null child widget");
      }
      fieldWidget = ignorePointer.child;
    }

    if (fieldWidget is NyFormPicker) {
      NyFormPicker.stateActions(field.stateKey).setOptions(options);
    } else if (fieldWidget is NyFormChip) {
      NyFormChip.stateActions(field.stateKey).setOptions(options);
    } else if (fieldWidget is NyFormRadio) {
      NyFormRadio.stateActions(field.stateKey).setOptions(options);
    } else {
      throw Exception("Field '$key' does not support options");
    }
  }

  /// Set the data for the form.
  ///
  /// If fields haven't been initialized yet, the data is stored and
  /// applied automatically when [initFields] is called.
  void setData(Map<String, dynamic> data, {bool refreshState = true}) {
    if (data.isEmpty) {
      return;
    }

    // If fields aren't initialized yet, store data to apply later
    if (_children.isEmpty) {
      _initialData = data;
      return;
    }

    _applyDataToFields(data);
  }

  /// Internal method to apply data to form fields.
  ///
  /// Keys are normalized to snake_case for matching, so both
  /// "First Name" and "first_name" will match a field with key "First Name".
  void _applyDataToFields(Map<String, dynamic> data, {bool updateUI = true}) {
    // Normalize data keys to snake_case for matching
    final normalizedData = <String, dynamic>{};
    for (final entry in data.entries) {
      normalizedData[entry.key.snakeCase] = entry.value;
    }

    for (var field in _children) {
      if (field is Field) {
        final fieldKey = field.key.snakeCase;
        if (normalizedData.containsKey(fieldKey)) {
          if (updateUI) {
            field.setValue(normalizedData[fieldKey]);
          } else {
            field.restoreValue(normalizedData[fieldKey]);
          }
        }
      } else if (field is List) {
        for (Field item in field) {
          final itemKey = item.key.snakeCase;
          if (normalizedData.containsKey(itemKey)) {
            if (updateUI) {
              item.setValue(normalizedData[itemKey]);
            } else {
              item.restoreValue(normalizedData[itemKey]);
            }
          }
        }
      }
    }
  }

  /// Get the error bag for the form
  List<FormValidationError> errorBag() {
    List<FormValidationError> errorBag = [];
    for (var field in widgets) {
      if (field is Field) {
        FormValidationResult? formValidationResult = field.validate();
        if (formValidationResult != null) {
          errorBag.addAll(formValidationResult.errorResponses);
        }
      } else if (field is List) {
        for (Field item in field) {
          FormValidationResult? formValidationResult = item.validate();
          if (formValidationResult != null) {
            errorBag.addAll(formValidationResult.errorResponses);
          }
        }
      }
    }
    return errorBag;
  }

  /// Check if the form passes validation
  bool validate({
    Function(Map<String, dynamic> formData)? onSuccess,
    Function(List<FormValidationError> errors)? onError,
  }) {
    List<FormValidationError> _errorBag = errorBag();
    if (_errorBag.isNotEmpty) {
      if (onError != null) {
        onError(_errorBag.cast<FormValidationError>());
      }
      return false;
    }
    if (onSuccess != null) {
      onSuccess(data());
    }
    return true;
  }

  /// Get the data for a field
  Map<String, dynamic> fieldData(Field field) {
    return {field.key.snakeCase: field.value};
  }

  /// Returns the data for the form
  /// If a [key] is provided, it will return the data for that key
  dynamic data({String? key}) {
    Map<String, dynamic> dataMap = {};
    for (var field in widgets) {
      if (field is Field) {
        dataMap.addAll(fieldData(field));
      } else if (field is List) {
        for (Field item in field) {
          dataMap.addAll(fieldData(item));
        }
      }
    }
    if (key != null) {
      return dataMap[key.snakeCase];
    }
    return dataMap;
  }

  /// Extracts current values from all fields for preservation during refresh.
  /// Returns a Map with snake_case keys and field values.
  Map<String, dynamic> extractCurrentValues() {
    Map<String, dynamic> values = {};
    for (var item in _children) {
      if (item is Field) {
        values[item.key.snakeCase] = item.value;
      } else if (item is List) {
        for (Field field in item) {
          values[field.key.snakeCase] = field.value;
        }
      }
    }
    return values;
  }

  /// Refreshes form fields by re-calling fields() while preserving existing values.
  /// Called during hot reload to pick up field definition changes.
  void refreshFields() {
    // Step 1: Extract current values before refresh
    final preservedValues = extractCurrentValues();

    // Step 2: Cancel old subscription and close old stream to prevent memory leaks
    _onChangedSubscription?.cancel();
    _updatedStream?.close();

    // Step 3: Reinitialize stream
    _updatedStream = initializeStream();

    // Step 4: Re-subscribe to stream for onChanged callbacks
    _onChangedSubscription = _updatedStream?.stream.listen((data) {
      if (onChanged != null) {
        onChanged!(data.$1, data.$2);
      }
    });

    // Step 5: Recreate fields by calling fields() again (picks up code changes)
    _children = getFields(updated!);

    // Step 6: Restore preserved values to matching fields
    if (preservedValues.isNotEmpty) {
      _applyDataToFields(preservedValues, updateUI: false);
    }
  }

  /// Submit the form
  /// If the form is valid, it will call the [onSuccess] function
  void submit({
    required Function(dynamic value) onSuccess,
    Function(List<FormValidationError> errors)? onFailure,
    bool showToastError = true,
  }) {
    validate(
      onSuccess: (data) {
        onSuccess(data);
      },
      onError: (List<FormValidationError> errors) {
        String firstError = errors.first.rule.getMessage() ?? "Invalid data";
        if (showToastError) {
          stateAction(
            'showToast',
            state: stateName,
            data: {"message": firstError},
          );
        }
        if (onFailure != null) {
          onFailure(errors);
        }
      },
    );
  }

  /// Initialize the form fields and apply any pending initial data.
  void initFields() {
    _onChangedSubscription?.cancel();
    _updatedStream?.close();

    _updatedStream = initializeStream();

    _onChangedSubscription = _updatedStream?.stream.listen((data) {
      if (onChanged != null) {
        onChanged!(data.$1, data.$2);
      }
    });

    _children = getFields(updated!);

    // Apply stored initial data now that fields are initialized
    if (_initialData != null && _initialData!.isNotEmpty) {
      _applyDataToFields(_initialData!);
      _initialData = null; // Clear after applying
    }
  }

  /// Update a field in the form
  void updateField(String key, Field Function(Field item) update) {
    final normalizedKey = key.snakeCase;

    for (int i = 0; i < _children.length; i++) {
      final item = _children[i];

      if (item is Field && item.key.snakeCase == normalizedKey) {
        _children[i] = update(item);
        return;
      }

      if (item is List) {
        for (int j = 0; j < item.length; j++) {
          if (item[j].key.snakeCase == normalizedKey) {
            item[j] = update(item[j]);
            return;
          }
        }
      }
    }
  }
}
