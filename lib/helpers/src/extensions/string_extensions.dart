import 'dart:convert';

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
  /// On web the exit step is skipped (`dart:io`'s `exit()` is unavailable).
  void dd({String? tag}) {
    NyLogger.dd(this ?? "", tag);
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
  /// On web the exit step is skipped (`dart:io`'s `exit()` is unavailable).
  void dd({String? tag}) {
    NyLogger.dd(toString(), tag);
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
