import 'package:flutter/material.dart';

import '/router/ny_router.dart';

/// Extensions for [Text]
extension NyTextExt on Text {
  /// This text in the theme's style that [select] picks, with [textStyle]
  /// over it. The style is looked up whenever the text builds, so it follows
  /// a change of theme.
  Text _themed(
    TextStyle? Function(TextTheme theme) select,
    TextStyle textStyle,
  ) {
    final Text text = this;
    return _ThemedText.like(
      text,
      select: select,
      overrides:
          (text is _ThemedText ? text.overrides : style)?.merge(textStyle) ??
          textStyle,
    );
  }

  /// A plain [Text], or [Text.rich] when this is rich text, with this text's
  /// settings and any given here over them. The copy's style is [style].
  Text _plainCopy({
    Key? key,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextAlign? textAlign,
    TextDirection? textDirection,
    Locale? locale,
    bool? softWrap,
    TextOverflow? overflow,
    TextScaler? textScaler,
    int? maxLines,
    String? semanticsLabel,
    TextWidthBasis? textWidthBasis,
  }) {
    final InlineSpan? span = textSpan;
    if (span != null) {
      return Text.rich(
        span,
        key: key ?? this.key,
        style: style,
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
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      );
    }
    return Text(
      data ?? "",
      key: key ?? this.key,
      style: style,
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
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
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
    return _themed((TextTheme theme) => theme.displayLarge, textStyle);
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
    return _themed((TextTheme theme) => theme.displayMedium, textStyle);
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
    return _themed((TextTheme theme) => theme.displaySmall, textStyle);
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
    return _themed((TextTheme theme) => theme.headlineLarge, textStyle);
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
    return _themed((TextTheme theme) => theme.headlineMedium, textStyle);
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
    return _themed((TextTheme theme) => theme.headlineSmall, textStyle);
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
    return _themed((TextTheme theme) => theme.titleLarge, textStyle);
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
    return _themed((TextTheme theme) => theme.titleMedium, textStyle);
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
    return _themed((TextTheme theme) => theme.titleSmall, textStyle);
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
    return _themed((TextTheme theme) => theme.bodyLarge, textStyle);
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
    return _themed((TextTheme theme) => theme.bodyMedium, textStyle);
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
    return _themed((TextTheme theme) => theme.bodySmall, textStyle);
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
    return _themed((TextTheme theme) => theme.labelLarge, textStyle);
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
    return _themed((TextTheme theme) => theme.labelMedium, textStyle);
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
    return _themed((TextTheme theme) => theme.labelSmall, textStyle);
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
    final Text text = this;
    final Text copy = _plainCopy(
      key: key,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      style: style != null ? this.style?.merge(style) ?? style : this.style,
    );
    if (text is _ThemedText) {
      return _ThemedText.like(
        copy,
        select: text.select,
        overrides: style != null
            ? text.overrides?.merge(style) ?? style
            : text.overrides,
      );
    }
    return copy;
  }
}

/// A [Text] in one of the theme's text styles, such as `titleLarge`, with
/// [overrides] over it.
///
/// [style] holds the style as it was when the text was made, for anyone who
/// reads it. Building looks the theme's style up again, so the text follows
/// the theme it's shown in, including a change of theme while its page is
/// open.
class _ThemedText extends Text {
  const _ThemedText(
    super.data, {
    required this.select,
    required this.overrides,
    super.key,
    super.style,
    super.strutStyle,
    super.textAlign,
    super.textDirection,
    super.locale,
    super.softWrap,
    super.overflow,
    super.textScaler,
    super.maxLines,
    super.semanticsLabel,
    super.textWidthBasis,
    super.textHeightBehavior,
    super.selectionColor,
  });

  const _ThemedText.rich(
    super.textSpan, {
    required this.select,
    required this.overrides,
    super.key,
    super.style,
    super.strutStyle,
    super.textAlign,
    super.textDirection,
    super.locale,
    super.softWrap,
    super.overflow,
    super.textScaler,
    super.maxLines,
    super.semanticsLabel,
    super.textWidthBasis,
    super.textHeightBehavior,
    super.selectionColor,
  }) : super.rich();

  /// [text], rich or plain, in the theme's style that [select] picks with
  /// [overrides] over it.
  factory _ThemedText.like(
    Text text, {
    required TextStyle? Function(TextTheme theme) select,
    required TextStyle? overrides,
  }) {
    final TextStyle? style = resolve(select, overrides, null);
    final InlineSpan? span = text.textSpan;
    if (span != null) {
      return _ThemedText.rich(
        span,
        select: select,
        overrides: overrides,
        style: style,
        key: text.key,
        strutStyle: text.strutStyle,
        textAlign: text.textAlign,
        textDirection: text.textDirection,
        locale: text.locale,
        softWrap: text.softWrap,
        overflow: text.overflow,
        textScaler: text.textScaler,
        maxLines: text.maxLines,
        semanticsLabel: text.semanticsLabel,
        textWidthBasis: text.textWidthBasis,
        textHeightBehavior: text.textHeightBehavior,
        selectionColor: text.selectionColor,
      );
    }
    return _ThemedText(
      text.data ?? "",
      select: select,
      overrides: overrides,
      style: style,
      key: text.key,
      strutStyle: text.strutStyle,
      textAlign: text.textAlign,
      textDirection: text.textDirection,
      locale: text.locale,
      softWrap: text.softWrap,
      overflow: text.overflow,
      textScaler: text.textScaler,
      maxLines: text.maxLines,
      semanticsLabel: text.semanticsLabel,
      textWidthBasis: text.textWidthBasis,
      textHeightBehavior: text.textHeightBehavior,
      selectionColor: text.selectionColor,
    );
  }

  /// Picks the theme's text style, e.g. `titleLarge`.
  final TextStyle? Function(TextTheme theme) select;

  /// What's set over the theme's style.
  final TextStyle? overrides;

  /// The theme's style that [select] picks, from [context] or else the app's
  /// navigator, with [overrides] over it.
  static TextStyle? resolve(
    TextStyle? Function(TextTheme theme) select,
    TextStyle? overrides,
    BuildContext? context,
  ) {
    BuildContext? themed = context;
    if (themed == null) {
      try {
        themed = NyNavigator.instance.router.navigatorKey?.currentContext;
      } catch (_) {
        // Nylo's router isn't set up, e.g. in a plain widget test.
      }
    }
    if (themed == null) return overrides;
    return select(Theme.of(themed).textTheme)?.merge(overrides) ?? overrides;
  }

  @override
  Widget build(BuildContext context) =>
      _plainCopy(style: resolve(select, overrides, context)).build(context);
}
