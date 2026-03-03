import 'dart:convert';

import 'package:flutter/material.dart';
import '/widgets/src/form/validation.dart';

import '../typedefs.dart';
import '/themes/ny_themes.dart';
import '../state_action.dart';
import '../helper.dart';
import '../backpack.dart';
import '../ny_logger.dart';
import '/local_storage/ny_local_storage.dart';
import '/router/ny_router.dart';

/// Check if the device is in Dark Mode
extension DarkModeExt on BuildContext {
  /// Example
  /// if (context.isDeviceInDarkMode) {
  ///   do something here...
  /// }
  bool get isDeviceInDarkMode =>
      MediaQuery.of(this).platformBrightness == Brightness.dark;
}

extension NyContextExt on BuildContext {
  /// Get the TextTheme
  TextTheme textTheme() {
    return Theme.of(this).textTheme;
  }

  /// Get the MediaQueryData
  MediaQueryData mediaQuery() {
    return MediaQuery.of(this);
  }

  /// Pop the current page
  void pop<T extends Object?>({T? result, bool rootNavigator = false}) {
    Navigator.of(this, rootNavigator: rootNavigator).pop(result);
  }

  /// Get the width of the screen
  double widgetWidth() {
    return mediaQuery().size.width;
  }

  /// Get the height of the screen
  double widgetHeight() {
    return mediaQuery().size.height;
  }

  /// Check if the device is in dark mode
  bool get isThemeDark {
    if (isDeviceInDarkMode) return true;
    // Use Theme.of(this) to establish a dependency so the widget rebuilds on theme change
    Theme.of(this);
    return NyThemeManager.instance.isDark;
  }
}

extension RouteViewExt on RouteView {
  /// Get the path of the route.
  String get name {
    return this.$1;
  }

  /// Get the path of the route with arguments.
  String withParams(Map<String, dynamic> args) {
    String path = this.$1;
    args.forEach((key, value) {
      path = path.replaceAll("{$key}", value.toString());
    });
    return path;
  }

  /// Add query parameters to the path.
  String withQueryParams(Map<String, dynamic> args) {
    String path = this.$1;
    // build the query string
    String queryString = args.entries
        .map((entry) => "${entry.key}=${entry.value}")
        .join("&");
    // add the query string to the path
    if (path.contains("?")) {
      path = path.replaceAll("?", "?$queryString&");
    } else {
      path = "$path?$queryString";
    }
    return path;
  }

  /// Get the state name of the route.
  String stateName() {
    String fullPath = this.$2.toString();
    String pathName = fullPath.split(" => ").last;

    String template = "Closure: () => _{page_name}State";
    return template.replaceAll("{page_name}", pathName);
  }

  /// Get the ny page name.
  String nyPageName() {
    return "${this.$2.runtimeType.toString().replaceAll("BuildContext", "")}State"
        .replaceAll("() => ", "() => _");
  }

  /// Refresh the page
  dynamic stateRefresh() {
    return StateAction.refreshPage(this.$1);
  }

  /// Route to a new page.
  dynamic navigateTo({
    dynamic data,
    Map<String, dynamic>? queryParameters,
    NavigationType navigationType = NavigationType.push,
    dynamic result,
    bool Function(Route<dynamic> route)? removeUntilPredicate,
    TransitionType? transitionType,
    PageTransitionSettings? pageTransitionSettings,
    PageTransitionType? pageTransitionType,
    Function(dynamic value)? onPop,
  }) {
    return routeTo(
      name,
      data: data,
      queryParameters: queryParameters,
      navigationType: navigationType,
      result: result,
      removeUntilPredicate: removeUntilPredicate,
      transitionType: transitionType,
      // ignore: deprecated_member_use_from_same_package
      pageTransitionSettings: pageTransitionSettings,
      // ignore: deprecated_member_use_from_same_package
      pageTransitionType: pageTransitionType,
      onPop: onPop,
    );
  }
}

extension NyStorageKeyExt on StorageKey {
  /// Attempt to convert a [String] into a model by using your model decoders.
  T toModel<T>() => dataToModel<T>(data: jsonDecode(this));

  /// Read a value from the Backpack instance.
  T? fromBackpack<T>({dynamic defaultValue}) {
    return Backpack.instance.read<T>(this, defaultValue: defaultValue);
  }

  /// Read a StorageKey value from NyStorage
  Future<T?> fromStorage<T>({dynamic defaultValue}) async {
    return await NyStorage.read<T>(this, defaultValue: defaultValue);
  }

  /// Read a StorageKey value from NyStorage
  Future<T?> read<T>({dynamic defaultValue}) async {
    return await fromStorage<T>(defaultValue: defaultValue);
  }

  /// Set a default value for a StorageKey
  Future Function(bool inBackpack)? defaultValue<T>(dynamic value) {
    return (inBackpack) async {
      dynamic localValue = await fromStorage();
      if (localValue == null) {
        await save(value, inBackpack: inBackpack);
        Backpack.instance.save(this, value);
        return;
      }
      if (inBackpack) {
        dynamic data = await storageRead<T>(this);
        Backpack.instance.save(this, data);
      }
    };
  }

  /// Read a JSON value from NyStorage
  Future<T?> readJson<T>({dynamic defaultValue}) async {
    T? response = await NyStorage.readJson<T>(this, defaultValue: defaultValue);
    if (response == null) return null;
    try {
      return response;
    } catch (e) {
      NyLogger.error(e);
      return null;
    }
  }

  /// Store a value in NyStorage
  /// You can also save a value in the backpack by setting [inBackpack] to true
  Future save(dynamic value, {bool inBackpack = false}) async {
    return await NyStorage.save(this, value, inBackpack: inBackpack);
  }

  /// Store a JSON value in NyStorage
  /// You can also save a value in the backpack by setting [inBackpack] to true
  Future saveJson(dynamic value, {bool inBackpack = false}) async {
    try {
      return await NyStorage.saveJson(this, value, inBackpack: inBackpack);
    } catch (e) {
      NyLogger.error(e);
    }
  }

  /// Add a value to a collection in NyStorage
  /// You can also set [allowDuplicates] to false to prevent duplicates
  Future addToCollection<T>(
    dynamic value, {
    bool allowDuplicates = true,
  }) async {
    return await NyStorage.addToCollection<T>(
      this,
      item: value,
      allowDuplicates: allowDuplicates,
    );
  }

  /// Read a collection from NyStorage
  Future<List<T>> readCollection<T>() async {
    return await NyStorage.readCollection(this);
  }

  /// Delete a StorageKey value from NyStorage
  Future deleteFromStorage({bool andFromBackpack = true}) async {
    return await NyStorage.delete(this, andFromBackpack: andFromBackpack);
  }

  /// Flush data from NyStorage
  Future flush({bool andFromBackpack = true}) async {
    return await deleteFromStorage(andFromBackpack: andFromBackpack);
  }
}

extension FormValidatorExtensionExt on List<FormValidator> {
  /// Validate a list of [FormValidator] objects.
  /// Returns a [List<FormValidationResponse>] indicating success or error for each validator.
  FormValidationResponseBag validateAll(dynamic data) {
    return map((validator) => validator.check(data)).toList();
  }

  /// Add a new [FormValidator] to the list.
  /// Returns the newly created [FormValidator].
  FormValidator that(dynamic data, {String? label}) {
    FormValidator? newValidator = FormValidator(data: data, attribute: label);
    this.add(newValidator);
    return newValidator;
  }
}

extension ListFormValidationResponseExtensionExt on FormValidationResponseBag {
  /// Check if all validations are successful.
  bool get isValid => every((response) => response.isValid);

  /// Get the first error message from the list of validation responses.
  String? get firstErrorMessage {
    return firstErrorFormValidationResult?.getFirstErrorMessage();
  }

  /// Get the first error [FormValidationResult] from the list.
  /// Returns null if all responses are valid.
  FormValidationResult? get firstErrorFormValidationResult {
    return validationErrors.isEmpty ? null : validationErrors.first;
  }

  /// Get a list of all validation errors.
  /// Returns a list of [FormValidationResult] objects that are not valid.
  List<FormValidationResult> get validationErrors {
    return this.where((value) => !value.isValid).toList();
  }

  /// Get a list of all successful validations.
  /// Returns a list of [FormValidationResult] objects that are valid.
  List<FormValidationResult> get validationSuccess {
    return this.where((value) => value.isValid).toList();
  }
}

typedef FormValidationResponseBag = List<FormValidationResult>;
