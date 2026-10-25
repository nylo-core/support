import 'package:flutter/material.dart';
import 'package:nylo_support/ny_core.dart';

/// A [Text] widget that automatically translates its content using Nylo's
/// localization system.
///
/// This widget extends Flutter's [Text] widget and applies the `.tr()` extension
/// method to automatically translate the provided string.
///
/// Example usage:
/// ```dart
/// TextTr('hello_world')
/// ```
///
/// With arguments for dynamic values:
/// ```dart
/// TextTr(
///   'welcome_message',
///   arguments: {'name': 'John'},
/// )
/// ```
///
/// With styling:
/// ```dart
/// TextTr(
///   'greeting',
///   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
///   textAlign: TextAlign.center,
/// )
/// ```
class TextTr extends Text {
  /// Creates a [TextTr] widget.
  ///
  /// The [data] parameter is the localization key that will be translated.
  ///
  /// The [arguments] parameter is an optional map of key-value pairs for
  /// string interpolation in the translated text.
  ///
  /// All standard [Text] parameters are supported.
  TextTr(
    String data, {
    super.key,
    super.style,
    super.textAlign,
    super.maxLines,
    super.overflow,
    super.softWrap,
    super.textDirection,
    super.locale,
    super.semanticsLabel,
    this.arguments,
  }) : _select = null,
       super(data.tr(arguments: arguments));

  /// Optional arguments for string interpolation in the translated text.
  ///
  /// For example, if your translation is `"Hello, {{name}}!"`, you can pass
  /// `arguments: {'name': 'John'}` to produce `"Hello, John!"`.
  final Map<String, String>? arguments;

  /// Picks the theme's text style for a named constructor such as
  /// [TextTr.titleLarge], or null.
  final TextStyle? Function(TextTheme theme)? _select;

  /// Looks the theme's style up as it builds, so the text follows the theme
  /// it's shown in, including a change of theme while its page is open.
  @override
  Widget build(BuildContext context) {
    final TextStyle? Function(TextTheme theme)? select = _select;
    if (select == null) return super.build(context);
    return Text(
      data!,
      style: select(Theme.of(context).textTheme),
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
    ).build(context);
  }

  /// Creates a [TextTr] with [displayLarge] text style.
  TextTr.displayLarge(String data, {super.key, super.textAlign, this.arguments})
    : _select = ((TextTheme theme) => theme.displayLarge),
      super(
        data.tr(arguments: arguments),
        style: NyThemeManager
            .instance
            .currentTheme
            ?.themeData
            .textTheme
            .displayLarge,
      );

  /// Creates a [TextTr] with [headlineLarge] text style.
  TextTr.headlineLarge(
    String data, {
    super.key,
    super.textAlign,
    this.arguments,
  }) : _select = ((TextTheme theme) => theme.headlineLarge),
       super(
         data.tr(arguments: arguments),
         style: NyThemeManager
             .instance
             .currentTheme
             ?.themeData
             .textTheme
             .headlineLarge,
       );

  /// Creates a [TextTr] with [bodyLarge] text style.
  TextTr.bodyLarge(String data, {super.key, super.textAlign, this.arguments})
    : _select = ((TextTheme theme) => theme.bodyLarge),
      super(
        data.tr(arguments: arguments),
        style:
            NyThemeManager.instance.currentTheme?.themeData.textTheme.bodyLarge,
      );

  /// Creates a [TextTr] with [labelLarge] text style.
  TextTr.labelLarge(String data, {super.key, super.textAlign, this.arguments})
    : _select = ((TextTheme theme) => theme.labelLarge),
      super(
        data.tr(arguments: arguments),
        style: NyThemeManager
            .instance
            .currentTheme
            ?.themeData
            .textTheme
            .labelLarge,
      );

  /// Creates a [TextTr] with [displayMedium] text style.
  TextTr.displayMedium(
    String data, {
    super.key,
    super.textAlign,
    this.arguments,
  }) : _select = ((TextTheme theme) => theme.displayMedium),
       super(
         data.tr(arguments: arguments),
         style: NyThemeManager
             .instance
             .currentTheme
             ?.themeData
             .textTheme
             .displayMedium,
       );

  /// Creates a [TextTr] with [displaySmall] text style.
  TextTr.displaySmall(String data, {super.key, super.textAlign, this.arguments})
    : _select = ((TextTheme theme) => theme.displaySmall),
      super(
        data.tr(arguments: arguments),
        style: NyThemeManager
            .instance
            .currentTheme
            ?.themeData
            .textTheme
            .displaySmall,
      );

  /// Creates a [TextTr] with [headlineMedium] text style.
  TextTr.headlineMedium(
    String data, {
    super.key,
    super.textAlign,
    this.arguments,
  }) : _select = ((TextTheme theme) => theme.headlineMedium),
       super(
         data.tr(arguments: arguments),
         style: NyThemeManager
             .instance
             .currentTheme
             ?.themeData
             .textTheme
             .headlineMedium,
       );

  /// Creates a [TextTr] with [headlineSmall] text style.
  TextTr.headlineSmall(
    String data, {
    super.key,
    super.textAlign,
    this.arguments,
  }) : _select = ((TextTheme theme) => theme.headlineSmall),
       super(
         data.tr(arguments: arguments),
         style: NyThemeManager
             .instance
             .currentTheme
             ?.themeData
             .textTheme
             .headlineSmall,
       );

  /// Creates a [TextTr] with [titleLarge] text style.
  TextTr.titleLarge(String data, {super.key, super.textAlign, this.arguments})
    : _select = ((TextTheme theme) => theme.titleLarge),
      super(
        data.tr(arguments: arguments),
        style: NyThemeManager
            .instance
            .currentTheme
            ?.themeData
            .textTheme
            .titleLarge,
      );

  /// Creates a [TextTr] with [titleMedium] text style.
  TextTr.titleMedium(String data, {super.key, super.textAlign, this.arguments})
    : _select = ((TextTheme theme) => theme.titleMedium),
      super(
        data.tr(arguments: arguments),
        style: NyThemeManager
            .instance
            .currentTheme
            ?.themeData
            .textTheme
            .titleMedium,
      );

  /// Creates a [TextTr] with [titleSmall] text style.
  TextTr.titleSmall(String data, {super.key, super.textAlign, this.arguments})
    : _select = ((TextTheme theme) => theme.titleSmall),
      super(
        data.tr(arguments: arguments),
        style: NyThemeManager
            .instance
            .currentTheme
            ?.themeData
            .textTheme
            .titleSmall,
      );

  /// Creates a [TextTr] with [bodyMedium] text style.
  TextTr.bodyMedium(String data, {super.key, super.textAlign, this.arguments})
    : _select = ((TextTheme theme) => theme.bodyMedium),
      super(
        data.tr(arguments: arguments),
        style: NyThemeManager
            .instance
            .currentTheme
            ?.themeData
            .textTheme
            .bodyMedium,
      );

  /// Creates a [TextTr] with [bodySmall] text style.
  TextTr.bodySmall(String data, {super.key, super.textAlign, this.arguments})
    : _select = ((TextTheme theme) => theme.bodySmall),
      super(
        data.tr(arguments: arguments),
        style:
            NyThemeManager.instance.currentTheme?.themeData.textTheme.bodySmall,
      );

  /// Creates a [TextTr] with [labelMedium] text style.
  TextTr.labelMedium(String data, {super.key, super.textAlign, this.arguments})
    : _select = ((TextTheme theme) => theme.labelMedium),
      super(
        data.tr(arguments: arguments),
        style: NyThemeManager
            .instance
            .currentTheme
            ?.themeData
            .textTheme
            .labelMedium,
      );

  /// Creates a [TextTr] with [labelSmall] text style.
  TextTr.labelSmall(String data, {super.key, super.textAlign, this.arguments})
    : _select = ((TextTheme theme) => theme.labelSmall),
      super(
        data.tr(arguments: arguments),
        style: NyThemeManager
            .instance
            .currentTheme
            ?.themeData
            .textTheme
            .labelSmall,
      );
}
