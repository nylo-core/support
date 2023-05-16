import 'dart:io';

import 'package:nylo_support/helpers/helper.dart';

/// Extensions for [String]
extension NyStr on String? {
  dump({String? tag}) {
    NyLogger.dump(this ?? "", tag);
  }

  dd({String? tag}) {
    NyLogger.dump(this ?? "", tag);
    exit(0);
  }
}

/// Extensions for [int]
extension NyInt on int? {
  dump({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
  }

  dd({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
    exit(0);
  }
}

/// Extensions for [Map]
extension NyMap on Map? {
  dump({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
  }

  dd({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
    exit(0);
  }
}

/// Extensions for [List]
extension NyList on List? {
  dump({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
  }

  dd({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
    exit(0);
  }
}
