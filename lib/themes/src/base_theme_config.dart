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

  ThemeData? _themeData;

  /// Get the [ThemeData] for this theme.
  ThemeData get themeData => _themeData ??= theme(colors);

  /// Drop the memoised [ThemeData] so the next read rebuilds it from [colors].
  void invalidateThemeData() => _themeData = null;
}

/// Enum representing the type of theme.
enum NyThemeType {
  /// Light theme.
  light,

  /// Dark theme.
  dark,
}
