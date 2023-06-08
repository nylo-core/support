import 'dart:io';

import 'package:flutter/material.dart'
    show
        Color,
        Text,
        BuildContext,
        Theme,
        TextDirection,
        TextStyle,
        TextAlign,
        FontWeight,
        Key,
        StrutStyle,
        TextOverflow,
        TextWidthBasis,
        Locale;
import 'package:nylo_support/helpers/helper.dart';

/// Extensions for [String]
extension NyStr on String? {
  Color toHexColor() => nyHexColor(this ?? "");

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

/// Extensions for [double]
extension NyDouble on double? {
  dump({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
  }

  dd({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
    exit(0);
  }
}

/// Extensions for [bool]
extension NyBool on bool? {
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

/// Extensions for [Text]
extension NyText on Text {
  /// Set the Style to use [displayLarge].
  Text displayLarge(BuildContext context) {
    if (style == null) {
      return copyWith(style: Theme.of(context).textTheme.displayLarge);
    }
    return this.setStyle(Theme.of(context).textTheme.displayLarge);
  }

  /// Set the Style to use [displayMedium].
  Text displayMedium(BuildContext context) {
    if (style == null) {
      return copyWith(style: Theme.of(context).textTheme.displayMedium);
    }
    return this.setStyle(Theme.of(context).textTheme.displayMedium);
  }

  /// Set the Style to use [displaySmall].
  Text displaySmall(BuildContext context) {
    if (style == null) {
      return copyWith(style: Theme.of(context).textTheme.displaySmall);
    }
    return this.setStyle(Theme.of(context).textTheme.displaySmall);
  }

  /// Set the Style to use [headlineLarge].
  Text headingLarge(BuildContext context) {
    if (style == null) {
      return copyWith(style: Theme.of(context).textTheme.headlineLarge);
    }
    return this.setStyle(Theme.of(context).textTheme.headlineLarge);
  }

  /// Set the Style to use [headlineMedium].
  Text headingMedium(BuildContext context) {
    if (style == null) {
      return copyWith(style: Theme.of(context).textTheme.headlineMedium);
    }
    return this.setStyle(Theme.of(context).textTheme.headlineMedium);
  }

  /// Set the Style to use [headlineSmall].
  Text headingSmall(BuildContext context) {
    if (style == null) {
      return copyWith(style: Theme.of(context).textTheme.headlineSmall);
    }
    return this.setStyle(Theme.of(context).textTheme.headlineSmall);
  }

  /// Set the Style to use [titleLarge].
  Text titleLarge(BuildContext context) {
    if (style == null) {
      return copyWith(style: Theme.of(context).textTheme.titleLarge);
    }
    return this.setStyle(Theme.of(context).textTheme.titleLarge);
  }

  /// Set the Style to use [titleMedium].
  Text titleMedium(BuildContext context) {
    if (style == null) {
      return copyWith(style: Theme.of(context).textTheme.titleMedium);
    }
    return this.setStyle(Theme.of(context).textTheme.titleMedium);
  }

  /// Set the Style to use [titleSmall].
  Text titleSmall(BuildContext context) {
    if (style == null) {
      return copyWith(style: Theme.of(context).textTheme.titleSmall);
    }
    return this.setStyle(Theme.of(context).textTheme.titleSmall);
  }

  /// Set the Style to use [bodyLarge].
  Text bodyLarge(BuildContext context) {
    if (style == null) {
      return copyWith(style: Theme.of(context).textTheme.bodyLarge);
    }
    return this.setStyle(Theme.of(context).textTheme.bodyLarge);
  }

  /// Set the Style to use [bodyMedium].
  Text bodyMedium(BuildContext context) {
    if (style == null) {
      return copyWith(style: Theme.of(context).textTheme.bodyMedium);
    }
    return this.setStyle(Theme.of(context).textTheme.bodyMedium);
  }

  /// Set the Style to use [bodySmall].
  Text bodySmall(BuildContext context) {
    if (style == null) {
      return copyWith(style: Theme.of(context).textTheme.bodySmall);
    }
    return this.setStyle(Theme.of(context).textTheme.bodySmall);
  }

  /// Make the font bold.
  Text fontWeightBold() {
    return copyWith(style: TextStyle(fontWeight: FontWeight.bold));
  }

  /// Make the font light.
  Text fontWeightLight() {
    return copyWith(style: TextStyle(fontWeight: FontWeight.w300));
  }

  /// Change the [style].
  Text setStyle(TextStyle? style) => copyWith(style: style);

  /// Aligns text to the left.
  Text alignLeft() {
    return copyWith(textAlign: TextAlign.left);
  }

  /// Aligns text to the right.
  Text alignRight() {
    return copyWith(textAlign: TextAlign.right);
  }

  /// Aligns text to the center.
  Text alignCenter() {
    return copyWith(textAlign: TextAlign.center);
  }

  /// Aligns text to the center.
  Text setMaxLines(int maxLines) {
    return copyWith(maxLines: maxLines);
  }

  /// Change the [fontFamily].
  Text setFontFamily(String fontFamily) =>
      copyWith(style: TextStyle(fontFamily: fontFamily));

  /// Helper to apply changes.
  Text copyWith(
      {Key? key,
      StrutStyle? strutStyle,
      TextAlign? textAlign,
      TextDirection? textDirection = TextDirection.ltr,
      Locale? locale,
      bool? softWrap,
      TextOverflow? overflow,
      double? textScaleFactor,
      int? maxLines,
      String? semanticsLabel,
      TextWidthBasis? textWidthBasis,
      TextStyle? style}) {
    return Text(this.data ?? "",
        key: key ?? this.key,
        strutStyle: strutStyle ?? this.strutStyle,
        textAlign: textAlign ?? this.textAlign,
        textDirection: textDirection ?? this.textDirection,
        locale: locale ?? this.locale,
        softWrap: softWrap ?? this.softWrap,
        overflow: overflow ?? this.overflow,
        textScaleFactor: textScaleFactor ?? this.textScaleFactor,
        maxLines: maxLines ?? this.maxLines,
        semanticsLabel: semanticsLabel ?? this.semanticsLabel,
        textWidthBasis: textWidthBasis ?? this.textWidthBasis,
        style: style != null ? this.style?.merge(style) ?? style : this.style);
  }
}
