import 'dart:convert';

import '/helpers/ny_helpers.dart';

/// Attempts to call toJson() on an [object].
Map<String, dynamic>? objectToJson(dynamic object) {
  try {
    Map<String, dynamic> json = object.toJson();
    return json;
  } on NoSuchMethodError catch (e) {
    NyLogger.debug(e.toString());
    NyLogger.error(
      '[NyStorage.store] ${object.runtimeType.toString()} model needs to implement the toJson() method.',
    );
  }
  return null;
}

/// Checks if the value is an integer.
bool isInteger(String? s) {
  if (s == null) {
    return false;
  }

  RegExp regExp = RegExp(r"^-?[0-9]+$", caseSensitive: false, multiLine: false);

  return regExp.hasMatch(s);
}

/// Checks if the value is a double (must contain a decimal point).
/// Returns false for integers - use [isInteger] to check for integers first.
bool isDouble(String? s) {
  if (s == null) {
    return false;
  }

  // Must contain a decimal point to be considered a double
  RegExp regExp = RegExp(
    r"^-?[0-9]+\.[0-9]+$",
    caseSensitive: false,
    multiLine: false,
  );

  return regExp.hasMatch(s);
}

/// Json helper class
class JsonHelper {
  static String? tryEncode(dynamic data) {
    try {
      return jsonEncode(data);
    } catch (e) {
      return null;
    }
  }
}
