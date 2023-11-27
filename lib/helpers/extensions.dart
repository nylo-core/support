import 'dart:io';
import 'package:flutter/material.dart'
    show
        Brightness,
        BuildContext,
        Color,
        FontWeight,
        Key,
        Locale,
        MediaQuery,
        MediaQueryData,
        Navigator,
        StrutStyle,
        Text,
        TextAlign,
        TextDirection,
        TextOverflow,
        TextScaler,
        TextStyle,
        TextTheme,
        TextWidthBasis,
        Theme;
import 'package:nylo_support/helpers/backpack.dart';
import 'package:nylo_support/helpers/helper.dart';

/// Extensions for [String]
extension NyStr on String? {
  Color toHexColor() => nyHexColor(this ?? "");

  /// dump the value to the console. [tag] is optional.
  dump({String? tag}) {
    NyLogger.dump(this ?? "", tag);
  }

  /// dump the value to the console and exit the app. [tag] is optional.
  dd({String? tag}) {
    NyLogger.dump(this ?? "", tag);
    exit(0);
  }
}

/// Extensions for [int]
extension NyInt on int? {
  /// dump the value to the console. [tag] is optional.
  dump({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
  }

  /// dump the value to the console and exit the app. [tag] is optional.
  dd({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
    exit(0);
  }
}

/// Extensions for [Map]
extension NyMap on Map? {
  /// dump the value to the console. [tag] is optional.
  dump({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
  }

  /// dump the value to the console and exit the app. [tag] is optional.
  dd({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
    exit(0);
  }
}

/// Extensions for [double]
extension NyDouble on double? {
  /// dump the value to the console. [tag] is optional.
  dump({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
  }

  /// dump the value to the console and exit the app. [tag] is optional.
  dd({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
    exit(0);
  }
}

/// Extensions for [bool]
extension NyBool on bool? {
  /// dump the value to the console. [tag] is optional.
  dump({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
  }

  /// dump the value to the console and exit the app. [tag] is optional.
  dd({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
    exit(0);
  }
}

/// Extensions for [List]
extension NyList on List? {
  /// dump the value to the console. [tag] is optional.
  dump({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
  }

  /// dump the value to the console and exit the app. [tag] is optional.
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

  /// Change the [fontSize].
  Text setFontSize(double fontSize) {
    if (style == null) {
      return copyWith(style: TextStyle(fontSize: fontSize));
    }
    return this.setStyle(TextStyle(fontSize: fontSize));
  }

  /// Helper to apply changes.
  Text copyWith(
      {Key? key,
      StrutStyle? strutStyle,
      TextAlign? textAlign,
      TextDirection? textDirection = TextDirection.ltr,
      Locale? locale,
      bool? softWrap,
      TextOverflow? overflow,
      TextScaler? textScaler,
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
        textScaler: textScaler ?? this.textScaler,
        maxLines: maxLines ?? this.maxLines,
        semanticsLabel: semanticsLabel ?? this.semanticsLabel,
        textWidthBasis: textWidthBasis ?? this.textWidthBasis,
        style: style != null ? this.style?.merge(style) ?? style : this.style);
  }
}

extension NyBackpack<T> on String {
  /// Read a value from the Backpack instance.
  T? fromBackpack<T>() {
    return Backpack.instance.read<T>(this);
  }

  /// Read a StorageKey value from NyStorage
  Future<T?> fromStorage<T>() async {
    return await NyStorage.read<T>(this);
  }

  /// Delete a StorageKey value from NyStorage
  deleteFromStorage({bool andFromBackpack = false}) async {
    return await NyStorage.delete(this, andFromBackpack: andFromBackpack);
  }
}

/// Extension on the `List<T>` class that adds a `paginate` method for easy
/// pagination of list elements.
extension Paginate<T> on List<T> {
  /// Paginates the elements of the list based on the given parameters.
  ///
  /// The `paginate` method allows you to split a list of elements into
  /// multiple pages, with each page containing a specified number of items.
  /// This can be useful for implementing paginated UIs, such as displaying
  /// a limited number of items per page in a list view.
  ///
  /// The [itemsPerPage] parameter specifies the maximum number of items
  /// to include on each page. The [page] parameter specifies the page
  /// number (1-based) for which you want to retrieve the items.
  ///
  /// The method returns an `Iterable<T>` that represents the elements on the
  /// specified page. Note that the iterable is lazily evaluated, meaning that
  /// elements are computed on-demand as you iterate over it.
  ///
  /// If the calculated start index for the page exceeds the length of the list,
  /// or if the list is empty, the returned iterable will be empty.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// final List<int> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  /// final int itemsPerPage = 3;
  ///
  /// final Iterable<int> firstPage = numbers.paginate(itemsPerPage: itemsPerPage, page: 1);
  /// print(firstPage.toList()); // Output: [1, 2, 3]
  ///
  /// final Iterable<int> secondPage = numbers.paginate(itemsPerPage: itemsPerPage, page: 2);
  /// print(secondPage.toList()); // Output: [4, 5, 6]
  /// ```
  Iterable<T> paginate({required int itemsPerPage, required int page}) sync* {
    final startIndex = (page - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;

    for (int i = startIndex; i < endIndex && i < length; i++) {
      yield this[i];
    }
  }
}

/// Check if the device is in Dark Mode
extension DarkMode on BuildContext {
  /// Example
  /// if (context.isDarkMode) {
  ///   do something here...
  /// }
  bool get isDarkMode {
    final brightness = MediaQuery.of(this).platformBrightness;
    return brightness == Brightness.dark;
  }
}

extension NyContext on BuildContext {
  /// Get the TextTheme
  TextTheme textTheme() {
    return Theme.of(this).textTheme;
  }

  /// Get the MediaQueryData
  MediaQueryData mediaQuery() {
    return MediaQuery.of(this);
  }

  /// Pop the current page
  pop<T extends Object?>({T? result}) {
    Navigator.of(this).pop(result);
  }

  /// Get the width of the screen
  double widgetWidth() {
    return mediaQuery().size.width;
  }

  /// Get the height of the screen
  double widgetHeight() {
    return mediaQuery().size.height;
  }
}

extension NyMapEntry on Iterable<MapEntry<String, dynamic>> {
  /// Convert an Iterable<MapEntry<String, dynamic>> to a Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return Map.fromEntries(this);
  }
}
