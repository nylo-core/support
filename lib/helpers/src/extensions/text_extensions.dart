import 'package:flutter/material.dart';

import '/router/ny_router.dart';

/// Extensions for [Text]
extension NyTextExt on Text {
  BuildContext get _context {
    BuildContext? context =
        NyNavigator.instance.router.navigatorKey?.currentContext;
    if (context == null) {
      throw Exception('');
    }
    return context;
  }

  /// Set the Style to use [displayLarge].
  Text displayLarge({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    String? package,
    TextOverflow? overflow,
    TextDecoration? overline,
    Color? overlineColor,
    TextDecorationStyle? overlineStyle,
    double? overlineThickness,
    TextDecoration? underline,
    Color? underlineColor,
    TextDecorationStyle? underlineStyle,
    double? underlineThickness,
    TextHeightBehavior? textHeightBehavior,
  }) {
    TextStyle textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      package: package,
      overflow: overflow,
    );
    if (style == null) {
      return copyWith(
        style: Theme.of(_context).textTheme.displayLarge?.merge(textStyle),
      );
    }
    return setStyle(
      Theme.of(_context).textTheme.displayLarge?.merge(textStyle),
    );
  }

  /// Set the Style to use [displayMedium].
  Text displayMedium({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    String? package,
    TextOverflow? overflow,
    TextDecoration? overline,
    Color? overlineColor,
    TextDecorationStyle? overlineStyle,
    double? overlineThickness,
    TextDecoration? underline,
    Color? underlineColor,
    TextDecorationStyle? underlineStyle,
    double? underlineThickness,
    TextHeightBehavior? textHeightBehavior,
  }) {
    TextStyle textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      package: package,
      overflow: overflow,
    );
    if (style == null) {
      return copyWith(
        style: Theme.of(_context).textTheme.displayMedium?.merge(textStyle),
      );
    }
    return setStyle(
      Theme.of(_context).textTheme.displayMedium?.merge(textStyle),
    );
  }

  /// Set the Style to use [displaySmall].
  Text displaySmall({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    String? package,
    TextOverflow? overflow,
    TextDecoration? overline,
    Color? overlineColor,
    TextDecorationStyle? overlineStyle,
    double? overlineThickness,
    TextDecoration? underline,
    Color? underlineColor,
    TextDecorationStyle? underlineStyle,
    double? underlineThickness,
    TextHeightBehavior? textHeightBehavior,
  }) {
    TextStyle textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      package: package,
      overflow: overflow,
    );
    if (style == null) {
      return copyWith(
        style: Theme.of(_context).textTheme.displaySmall?.merge(textStyle),
      );
    }
    return setStyle(
      Theme.of(_context).textTheme.displaySmall?.merge(textStyle),
    );
  }

  /// Set the Style to use [headlineLarge].
  Text headingLarge({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    String? package,
    TextOverflow? overflow,
    TextDecoration? overline,
    Color? overlineColor,
    TextDecorationStyle? overlineStyle,
    double? overlineThickness,
    TextDecoration? underline,
    Color? underlineColor,
    TextDecorationStyle? underlineStyle,
    double? underlineThickness,
    TextHeightBehavior? textHeightBehavior,
  }) {
    TextStyle textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      package: package,
      overflow: overflow,
    );
    if (style == null) {
      return copyWith(
        style: Theme.of(_context).textTheme.headlineLarge?.merge(textStyle),
      );
    }
    return setStyle(
      Theme.of(_context).textTheme.headlineLarge?.merge(textStyle),
    );
  }

  /// Set the Style to use [headlineMedium].
  Text headingMedium({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    String? package,
    TextOverflow? overflow,
    TextDecoration? overline,
    Color? overlineColor,
    TextDecorationStyle? overlineStyle,
    double? overlineThickness,
    TextDecoration? underline,
    Color? underlineColor,
    TextDecorationStyle? underlineStyle,
    double? underlineThickness,
    TextHeightBehavior? textHeightBehavior,
  }) {
    TextStyle textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      package: package,
      overflow: overflow,
    );
    if (style == null) {
      return copyWith(
        style: Theme.of(_context).textTheme.headlineMedium?.merge(textStyle),
      );
    }
    return setStyle(
      Theme.of(_context).textTheme.headlineMedium?.merge(textStyle),
    );
  }

  /// Set the Style to use [headlineSmall].
  Text headingSmall({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    String? package,
    TextOverflow? overflow,
    TextDecoration? overline,
    Color? overlineColor,
    TextDecorationStyle? overlineStyle,
    double? overlineThickness,
    TextDecoration? underline,
    Color? underlineColor,
    TextDecorationStyle? underlineStyle,
    double? underlineThickness,
    TextHeightBehavior? textHeightBehavior,
  }) {
    TextStyle textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      package: package,
      overflow: overflow,
    );
    if (style == null) {
      return copyWith(
        style: Theme.of(_context).textTheme.headlineSmall?.merge(textStyle),
      );
    }
    return setStyle(
      Theme.of(_context).textTheme.headlineSmall?.merge(textStyle),
    );
  }

  /// Set the Style to use [titleLarge].
  Text titleLarge({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    String? package,
    TextOverflow? overflow,
    TextDecoration? overline,
    Color? overlineColor,
    TextDecorationStyle? overlineStyle,
    double? overlineThickness,
    TextDecoration? underline,
    Color? underlineColor,
    TextDecorationStyle? underlineStyle,
    double? underlineThickness,
    TextHeightBehavior? textHeightBehavior,
  }) {
    TextStyle textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      package: package,
      overflow: overflow,
    );
    if (style == null) {
      return copyWith(
        style: Theme.of(_context).textTheme.titleLarge?.merge(textStyle),
      );
    }
    return setStyle(Theme.of(_context).textTheme.titleLarge?.merge(textStyle));
  }

  /// Set the Style to use [titleMedium].
  Text titleMedium({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    String? package,
    TextOverflow? overflow,
    TextDecoration? overline,
    Color? overlineColor,
    TextDecorationStyle? overlineStyle,
    double? overlineThickness,
    TextDecoration? underline,
    Color? underlineColor,
    TextDecorationStyle? underlineStyle,
    double? underlineThickness,
    TextHeightBehavior? textHeightBehavior,
  }) {
    TextStyle textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      package: package,
      overflow: overflow,
    );
    if (style == null) {
      return copyWith(
        style: Theme.of(_context).textTheme.titleMedium?.merge(textStyle),
      );
    }
    return setStyle(Theme.of(_context).textTheme.titleMedium?.merge(textStyle));
  }

  /// Set the Style to use [titleSmall].
  Text titleSmall({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    String? package,
    TextOverflow? overflow,
    TextDecoration? overline,
    Color? overlineColor,
    TextDecorationStyle? overlineStyle,
    double? overlineThickness,
    TextDecoration? underline,
    Color? underlineColor,
    TextDecorationStyle? underlineStyle,
    double? underlineThickness,
    TextHeightBehavior? textHeightBehavior,
  }) {
    TextStyle textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      package: package,
      overflow: overflow,
    );
    if (style == null) {
      return copyWith(
        style: Theme.of(_context).textTheme.titleSmall?.merge(textStyle),
      );
    }
    return setStyle(Theme.of(_context).textTheme.titleSmall?.merge(textStyle));
  }

  /// Set the Style to use [bodyLarge].
  Text bodyLarge({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    String? package,
    TextOverflow? overflow,
    TextDecoration? overline,
    Color? overlineColor,
    TextDecorationStyle? overlineStyle,
    double? overlineThickness,
    TextDecoration? underline,
    Color? underlineColor,
    TextDecorationStyle? underlineStyle,
    double? underlineThickness,
    TextHeightBehavior? textHeightBehavior,
  }) {
    TextStyle textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      package: package,
      overflow: overflow,
    );
    if (style == null) {
      return copyWith(
        style: Theme.of(_context).textTheme.bodyLarge?.merge(textStyle),
      );
    }
    return setStyle(Theme.of(_context).textTheme.bodyLarge?.merge(textStyle));
  }

  /// Set the Style to use [bodyMedium].
  Text bodyMedium({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    String? package,
    TextOverflow? overflow,
    TextDecoration? overline,
    Color? overlineColor,
    TextDecorationStyle? overlineStyle,
    double? overlineThickness,
    TextDecoration? underline,
    Color? underlineColor,
    TextDecorationStyle? underlineStyle,
    double? underlineThickness,
    TextHeightBehavior? textHeightBehavior,
  }) {
    TextStyle textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      package: package,
      overflow: overflow,
    );
    if (style == null) {
      return copyWith(
        style: Theme.of(_context).textTheme.bodyMedium?.merge(textStyle),
      );
    }
    return setStyle(Theme.of(_context).textTheme.bodyMedium?.merge(textStyle));
  }

  /// Set the Style to use [bodySmall].
  Text bodySmall({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    String? package,
    TextOverflow? overflow,
    TextDecoration? overline,
    Color? overlineColor,
    TextDecorationStyle? overlineStyle,
    double? overlineThickness,
    TextDecoration? underline,
    Color? underlineColor,
    TextDecorationStyle? underlineStyle,
    double? underlineThickness,
    TextHeightBehavior? textHeightBehavior,
  }) {
    TextStyle textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      package: package,
      overflow: overflow,
    );
    if (style == null) {
      return copyWith(
        style: Theme.of(_context).textTheme.bodySmall?.merge(textStyle),
      );
    }
    return setStyle(Theme.of(_context).textTheme.bodySmall?.merge(textStyle));
  }

  /// Set the Style to use [labelLarge].
  Text labelLarge({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    String? package,
    TextOverflow? overflow,
    TextDecoration? overline,
    Color? overlineColor,
    TextDecorationStyle? overlineStyle,
    double? overlineThickness,
    TextDecoration? underline,
    Color? underlineColor,
    TextDecorationStyle? underlineStyle,
    double? underlineThickness,
    TextHeightBehavior? textHeightBehavior,
  }) {
    TextStyle textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      package: package,
      overflow: overflow,
    );
    if (style == null) {
      return copyWith(
        style: Theme.of(_context).textTheme.labelLarge?.merge(textStyle),
      );
    }
    return setStyle(Theme.of(_context).textTheme.labelLarge?.merge(textStyle));
  }

  /// Set the Style to use [labelMedium].
  Text labelMedium({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    String? package,
    TextOverflow? overflow,
    TextDecoration? overline,
    Color? overlineColor,
    TextDecorationStyle? overlineStyle,
    double? overlineThickness,
    TextDecoration? underline,
    Color? underlineColor,
    TextDecorationStyle? underlineStyle,
    double? underlineThickness,
    TextHeightBehavior? textHeightBehavior,
  }) {
    TextStyle textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      package: package,
      overflow: overflow,
    );
    if (style == null) {
      return copyWith(
        style: Theme.of(_context).textTheme.labelMedium?.merge(textStyle),
      );
    }
    return setStyle(Theme.of(_context).textTheme.labelMedium?.merge(textStyle));
  }

  /// Set the Style to use [labelSmall].
  Text labelSmall({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    String? package,
    TextOverflow? overflow,
    TextDecoration? overline,
    Color? overlineColor,
    TextDecorationStyle? overlineStyle,
    double? overlineThickness,
    TextDecoration? underline,
    Color? underlineColor,
    TextDecorationStyle? underlineStyle,
    double? underlineThickness,
    TextHeightBehavior? textHeightBehavior,
  }) {
    TextStyle textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      package: package,
      overflow: overflow,
    );
    if (style == null) {
      return copyWith(
        style: Theme.of(_context).textTheme.labelSmall?.merge(textStyle),
      );
    }
    return setStyle(Theme.of(_context).textTheme.labelSmall?.merge(textStyle));
  }

  /// Make the font bold.
  Text fontWeightBold() {
    return copyWith(style: const TextStyle(fontWeight: FontWeight.bold));
  }

  /// Make the font light.
  Text fontWeightLight() {
    return copyWith(style: const TextStyle(fontWeight: FontWeight.w300));
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

  /// Add padding to the text.
  Padding paddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: top,
        left: left,
        right: right,
        bottom: bottom,
      ),
      child: this,
    );
  }

  /// Change the [fontFamily].
  Text setFontFamily(String fontFamily) =>
      copyWith(style: TextStyle(fontFamily: fontFamily));

  /// Change the [fontSize].
  Text setFontSize(double fontSize) {
    if (style == null) {
      return copyWith(style: TextStyle(fontSize: fontSize));
    }
    return setStyle(TextStyle(fontSize: fontSize));
  }

  /// Helper to apply changes.
  Text copyWith({
    Key? key,
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
    TextStyle? style,
  }) {
    return Text(
      data ?? "",
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
      style: style != null ? this.style?.merge(style) ?? style : this.style,
    );
  }
}
