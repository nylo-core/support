import '../ny_logger.dart';

/// Extensions for [int]
extension NyIntExt on int? {
  /// dump the value to the console. [tag] is optional.
  void dump({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
  }

  /// dump the value to the console and exit the app. [tag] is optional.
  /// On web the exit step is skipped (`dart:io`'s `exit()` is unavailable).
  void dd({String? tag}) {
    NyLogger.dd((this ?? "").toString(), tag);
  }
}

/// Extensions for [double]
extension NyDoubleExt on double? {
  /// dump the value to the console. [tag] is optional.
  void dump({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
  }

  /// dump the value to the console and exit the app. [tag] is optional.
  /// On web the exit step is skipped (`dart:io`'s `exit()` is unavailable).
  void dd({String? tag}) {
    NyLogger.dd((this ?? "").toString(), tag);
  }
}

/// Extensions for [bool]
extension NyBoolExt on bool? {
  /// dump the value to the console. [tag] is optional.
  void dump({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
  }

  /// dump the value to the console and exit the app. [tag] is optional.
  /// On web the exit step is skipped (`dart:io`'s `exit()` is unavailable).
  void dd({String? tag}) {
    NyLogger.dd((this ?? "").toString(), tag);
  }
}
