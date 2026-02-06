import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart' show Color;
import '../helper.dart' show nyHexColor;
import '../ny_logger.dart';

/// Extensions for [String]
extension NyStrExt on String? {
  Color toHexColor() => nyHexColor(this ?? "");

  /// dump the value to the console. [tag] is optional.
  void dump({String? tag}) {
    NyLogger.dump(this ?? "", tag);
  }

  /// dump the value to the console and exit the app. [tag] is optional.
  void dd({String? tag}) {
    NyLogger.dump(this ?? "", tag);
    exit(0);
  }

  /// jsonDecode a [String].
  dynamic parseJson() => jsonDecode(this ?? "{}");

  /// Attempt to convert a [String] to a [DateTime].
  DateTime toDateTime() => DateTime.parse(this ?? "");
}

/// Extensions for [String]
extension NyStringExt on String {
  /// dump the value to the console.
  /// [tag] is optional.
  /// [alwaysPrint] is optional.
  void dump({String? tag, bool alwaysPrint = false}) {
    NyLogger.dump(toString(), tag, alwaysPrint: alwaysPrint);
  }

  /// dump the value to the console and exit the app.
  /// [tag] is optional.
  void dd({String? tag}) {
    NyLogger.dump(toString(), tag);
    exit(0);
  }

  /// Convert a string to boolean.
  bool toBool() {
    if (toLowerCase() == "true" || toLowerCase() == "1") {
      return true;
    }
    if (toLowerCase() == "false" || toLowerCase() == "0") {
      return false;
    }
    throw UnsupportedError("Cannot convert $this to a boolean");
  }

  /// Convert a string to boolean.
  bool? tryParseBool() {
    if (toLowerCase() == "true" || toLowerCase() == "1") {
      return true;
    }
    if (toLowerCase() == "false" || toLowerCase() == "0") {
      return false;
    }
    return null;
  }
}

/// Extensions for String
extension StringExtensionExt on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1)}";
}
