import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:recase/recase.dart';

import '/helpers/helper.dart';
import '/validation/ny_validator.dart';
import '/widgets/ny_form.dart';

/// NyFormData is a class that helps in managing form data
class NyFormData {
  NyFormData(String this.name) {
    dynamic formFields = fields();

    Map<String, dynamic> allData = {};
    for (dynamic formField in formFields) {
      if (formField is List) {
        for (Field field in formField) {
          allData.addAll(fieldData(field));
          _labels[field.key] = field.label;
          _cast[field.key] = field.cast;
          _validate[field.key] = field.validate;
          _dummyData[field.key] = field.dummyData;
          _header[field.key] = field.header;
          _footer[field.key] = field.footer;
          _style[field.key] = field.style;
          _metaData[field.key] = field.metaData;
          _hiddenData[field.key] = field.hidden;
          if (field.autofocus == true) {
            if (_getAutoFocusedField != null) {
              throw Exception(
                  "Only one field can be set to autofocus in a form");
            }
            _getAutoFocusedField = field.key;
          }
          _keys.add(field.key);
        }
        _groupedItems.add([for (Field field in formField) field.key]);
        continue;
      }

      if (formField is! Field) {
        continue;
      }

      allData.addAll(fieldData(formField));
      _groupedItems.add([formField.key]);

      Map<String, dynamic> formCast = _cast;
      Map<String, dynamic> formValidate = _validate;
      Map<String, dynamic> formDummyData = _dummyData;
      Map<String, dynamic> formStyle = _style;

      _cast[formField.key] = formField.cast;

      formCast.entries
          .where((test) => test.key == formField.key)
          .forEach((cast) {
        _cast[formField.key] = cast.value;
      });

      // Check if the field has a validate
      if (formField.validate != null) {
        _validate[formField.key] = formField.validate;
      }
      formValidate.entries
          .where((test) => test.key == formField.key)
          .forEach((validate) {
        _validate[formField.key] = validate.value;
      });

      if (!_validate.containsKey(formField.key)) {
        _validate[formField.key] = null;
      }

      if (formField.header != null) {
        _header[formField.key] = formField.header;
      }

      if (!_header.containsKey(formField.key)) {
        _header[formField.key] = null;
      }

      if (formField.footer != null) {
        _footer[formField.key] = formField.footer;
      }

      if (!_footer.containsKey(formField.key)) {
        _footer[formField.key] = null;
      }

      if (formField.hidden != null) {
        _hiddenData[formField.key] = formField.hidden;
      }

      if (!_hiddenData.containsKey(formField.key)) {
        _hiddenData[formField.key] = null;
      }

      if (formField.readOnly != null) {
        _readonlyData[formField.key] = formField.readOnly;
      }

      if (!_readonlyData.containsKey(formField.key)) {
        _readonlyData[formField.key] = null;
      }

      if (formField.metaData != null) {
        _metaData[formField.key] = formField.metaData;
      }

      if (!_metaData.containsKey(formField.key)) {
        _metaData[formField.key] = null;
      }

      // Check if the field has a dummy data
      if (formField.dummyData != null) {
        _dummyData[formField.key] = formField.dummyData;
      }
      formDummyData.entries
          .where((test) => test.key == formField.key)
          .forEach((dummyData) {
        _dummyData[formField.key] = dummyData.value;
      });

      if (!_dummyData.containsKey(formField.key)) {
        _dummyData[formField.key] = null;
      }

      // Check if the field has a style
      if (formField.style != null) {
        _style[formField.key] = formField.style;
      }
      formStyle.entries
          .where((test) => test.key == formField.key)
          .forEach((style) {
        _style[formField.key] = style.value;
      });

      if (!_style.containsKey(formField.key)) {
        _style[formField.key] = null;
      }

      if (formField.autofocus == true) {
        if (_getAutoFocusedField != null) {
          throw Exception("Only one field can be set to autofocus in a form");
        }
        _getAutoFocusedField = formField.key;
      }

      _keys.add(formField.key);
      _labels[formField.key] = formField.label;
    }

    if (init != null) {
      initialData(init!);
    }

    setData(allData, refreshState: false);
    if (getEnv('APP_ENV') != 'developing') {
      return;
    }
    Map<String, dynamic> allDummyData = getDummyData;
    for (var dummyData in allDummyData.entries) {
      if (dummyData.value != null) {
        setFieldValue(dummyData.key, dummyData.value, refreshState: false);
      }
    }
  }

  /// The name of the form
  String? name;

  /// Returns the state name for the form
  String get stateName => name!;

  /// The data for the form
  final Map<String, dynamic> _data = {};

  /// The keys for the form
  final List _keys = [];

  /// The grouped items for the form
  final List<List> _groupedItems = [];

  /// The labels for the form
  final Map<String, String?> _labels = {};

  /// The cast for the form
  final Map<String, FormCast?> _cast = {};

  /// The validator for the form
  final Map<String, FormValidator?> _validate = {};

  /// The dummy data for the form
  final Map<String, String?> _dummyData = {};

  /// The headers for the form
  final Map<String, Widget?> _header = {};

  /// The footers for the form
  final Map<String, Widget?> _footer = {};

  /// The style for the form
  final Map<String, dynamic> _style = {};

  /// The metadata for the form
  final Map<String, dynamic> _metaData = {};

  /// The hidden data for the form
  final Map<String, dynamic> _hiddenData = {};

  /// The readonly data for the form
  final Map<String, dynamic> _readonlyData = {};

  /// Get the grouped items for the form
  List<List> get groupedItems => _groupedItems;

  /// Get the labels for the form
  Map<String, String?> get getLabels => _labels;

  /// Get the cast data for the form
  Map<String, FormCast?> get getCast => _cast;

  /// Get the validate data for the form
  Map<String, FormValidator?> get getValidate => _validate;

  /// Get the dummy data for the form
  Map<String, String?> get getDummyData => _dummyData;

  /// Get the header data for the form
  Map<String, Widget?> get getHeaderData => _header;

  /// Get the footer data for the form
  Map<String, Widget?> get getFooterData => _footer;

  /// Get the footer data for the form
  Map<String, dynamic> get getMetaData => _metaData;

  /// Get the hidden data for the form
  Map<String, dynamic> get getHiddenData => _hiddenData;

  /// Get the readonly data for the form
  Map<String, dynamic> get getReadOnlyData => _readonlyData;

  /// Get the style data for the form
  Map<String, dynamic> get getStyle => _style;

  /// Get the autofocus field for the form
  String? get getAutoFocusedField => _getAutoFocusedField;
  String? _getAutoFocusedField;

  /// StreamController for the form
  StreamController<dynamic>? get updated {
    return _updatedStream;
  }

  StreamController<dynamic>? _updatedStream;

  /// Validate the form
  Map<String, dynamic> validate() => _validate;

  /// Returns the fields for the form
  dynamic fields() => {};

  /// Get the load data function for the form
  Function()? get getLoadData => _loadData;

  /// Returns the load data function for the form
  Function()? _loadData;

  /// Initialize the form
  Function()? get init => null;

  /// Check if the form is ready
  void formReady() {
    _ready.add(true);
  }

  /// Initialize the stream for the form
  StreamController? initializeStream() {
    _updatedStream = StreamController.broadcast();
    return _updatedStream;
  }

  /// StreamController for the form to check if it is ready
  final StreamController<bool> _ready = StreamController<bool>.broadcast();

  /// Stream for the form
  Stream<bool> get isReady => _ready.stream;

  /// Submit button widget
  Widget? get submitButton => null;

  /// Load data for the form
  void initialData(Function() loadData, {bool refreshState = false}) {
    _loadData = loadData;

    if (!refreshState) return;
    NyForm.stateRefresh(stateName);
  }

  /// On change function for the form
  void onChange(String field, Map<String, dynamic> data) {}

  /// Refresh the form
  void refreshForm() {
    NyForm.stateRefreshForm(stateName);
  }

  /// Create a new form
  /// [initialData] The initial data for the form
  /// [crossAxisSpacing] The cross axis spacing for the form
  /// [mainAxisSpacing] The main axis spacing for the form
  /// [onChanged] The onChanged function for the form
  /// [validateOnFocusChange] Validate on focus change
  /// [locked] Lock the form
  NyForm create(
      {Map<String, dynamic>? initialData,
      double? crossAxisSpacing,
      double? mainAxisSpacing,
      Function(String field, Map<String, dynamic> data)? onChanged,
      bool? validateOnFocusChange,
      bool? locked}) {
    return NyForm(
        form: this,
        crossAxisSpacing: crossAxisSpacing ?? 10,
        mainAxisSpacing: mainAxisSpacing ?? 10,
        initialData: initialData,
        onChanged: onChanged,
        validateOnFocusChange: validateOnFocusChange ?? false,
        locked: locked ?? false);
  }

  /// Clear the form
  void clear({bool refreshState = true}) {
    _data.forEach((key, value) {
      _data[key] = null;
    });
    _dummyData.forEach((key, value) {
      _dummyData[key] = null;
    });
    if (refreshState) {
      // update the state
      NyForm.stateClearData(stateName);
    }
  }

  /// Clear a field in the form
  void clearField(String key) {
    if (!_data.containsKey(key)) {
      throw Exception("Field $key does not exist in the form");
    }
    _data[key] = null;
    NyForm.stateRefresh(stateName);
  }

  /// Set the value for a field in the form
  /// If the field does not exist, it will throw an exception
  void setFieldValue(String key, dynamic value, {bool refreshState = true}) {
    if (!_data.containsKey(key)) {
      throw Exception("Field $key does not exist in the form");
    }
    _data[key] = value;
    if (!refreshState) return;
    NyForm.stateSetValue(stateName, key, value);
  }

  /// Set the options for a field in the form
  /// If the field does not exist, it will throw an exception
  void setFieldOptions(String key, dynamic value, {bool refreshState = true}) {
    if (!_data.containsKey(key)) {
      throw Exception("Field $key does not exist in the form");
    }
    _cast[key]?.metaData!["options"] = value;
    if (!refreshState) return;
    NyForm.stateSetOptions(stateName, key, value);
  }

  /// Set the data for the form
  void setData(Map<String, dynamic> data, {bool refreshState = true}) {
    if (data.isEmpty) {
      return;
    }
    data.forEach((key, value) {
      List<MapEntry<String, dynamic>> dataMapEntries = _data.entries
          .where((entry) => entry.key.snakeCase == key.snakeCase)
          .toList();
      if (dataMapEntries.isEmpty) {
        _data[key] = value;
      } else {
        _data[dataMapEntries.first.key] = value;
      }
    });
    if (!refreshState) return;
    NyForm.stateRefresh(stateName);
  }

  /// Check if the form passes validation
  bool isValid() {
    Map<String, dynamic> rules = getValidate;

    Map<String, dynamic> ruleMap = {};
    Map<String, dynamic> dataMap = {};

    for (MapEntry rule in rules.entries) {
      dynamic item = data(key: rule.key);
      if (rule.value is FormValidator) {
        if (rule.value.customRule != null) {
          if (!rule.value.customRule!(item)) {
            return false;
          }
        }

        rule.value.setData(item);
        dataMap[rule.key] = item is List ? item.join(", ") : item;
        ruleMap[rule.key] = rule.value.toValidationRule();
      } else {
        dataMap[rule.key] = data(key: rule.key);
        ruleMap[rule.key] = rule.value;
      }
    }

    return NyValidator.isSuccessful(rules: ruleMap, data: dataMap);
  }

  /// Get the data for a field
  Map<String, dynamic> fieldData(Field field) {
    Map<String, dynamic> json = field.toJson();

    return {json["key"]: json["value"]};
  }

  /// Returns the data for the form
  /// If a [key] is provided, it will return the data for that key
  dynamic data({String? key, bool lowerCaseKeys = false}) {
    if (key != null && _data.containsKey(key)) {
      return _data[key];
    }

    if (lowerCaseKeys == true) {
      Map<String, dynamic> newData = {};
      for (var entry in _data.entries) {
        // check if it's a widget
        if (_cast[entry.key]?.type == "widget") {
          continue;
        }

        newData[entry.key.toLowerCase().replaceAll(" ", "_")] = entry.value;
      }
      return newData;
    }
    return _data;
  }

  /// Submit the form
  /// If the form is valid, it will call the [onSuccess] function
  void submit(
      {required Function(dynamic value) onSuccess,
      Function(Exception exception)? onFailure,
      bool showToastError = true}) {
    Map<String, dynamic> rules = getValidate;
    if (rules.isEmpty) {
      Map<String, dynamic> currentData = data();
      // convert all keys to lowercase with underscores
      Map<String, dynamic> newData = {};
      for (var entry in currentData.entries) {
        if (_cast[entry.key]?.type == "widget") {
          continue;
        }

        newData[entry.key.toLowerCase().replaceAll(" ", "_")] = entry.value;
      }
      onSuccess(newData);
      return;
    }

    NyForm.submit(stateName,
        onSuccess: onSuccess,
        onFailure: onFailure,
        showToastError: showToastError);
  }

  /// Check if a field exists in the form
  bool hasField(String fieldKey) {
    return _data.containsKey(fieldKey);
  }
}
