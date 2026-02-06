import 'package:flutter/material.dart';

/// Base theme config is used for theme management.
/// Set the required parameters to create new themes.
///
/// Example:
/// ```dart
/// BaseThemeConfig<ColorStyles>(
///   id: 'light_theme',
///   description: 'Light theme',
///   theme: (colors) => ThemeData.light().copyWith(
///     primaryColor: colors.primaryAccent,
///     scaffoldBackgroundColor: colors.background,
///   ),
///   colors: LightThemeColors(),
///   type: NyThemeType.light,
/// )
/// ```
class BaseThemeConfig<T> {
  /// Unique identifier for the theme.
  final String id;

  /// Function that generates [ThemeData] from color styles.
  final ThemeData Function(T colorStyles) theme;

  /// Color styles instance for this theme.
  final T colors;

  /// Whether this is a light or dark theme.
  final NyThemeType type;

  /// Create a new [BaseThemeConfig].
  BaseThemeConfig({
    required this.id,
    required this.theme,
    required this.colors,
    this.type = NyThemeType.light,
  });

  /// Get the [ThemeData] for this theme.
  ThemeData get themeData => theme(colors);
}

/// Enum representing the type of theme.
enum NyThemeType {
  /// Light theme.
  light,

  /// Dark theme.
  dark,
}
