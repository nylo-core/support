import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';

/// Base theme config is used for theme management
/// Set the required parameters to create new themes.
class BaseThemeConfig<T> {
  final String id;
  final String description;
  ThemeData Function(T colorStyles) theme;
  final T colors;
  final dynamic meta;

  /// Create a new [BaseThemeConfig].
  BaseThemeConfig(
      {required this.id,
      required this.description,
      required this.theme,
      required this.colors,
      this.meta = const {}});

  /// Convert the theme to a [AppTheme] object.
  AppTheme toAppTheme({ThemeData? defaultTheme}) => AppTheme(
        id: id,
        data: defaultTheme ?? theme(colors),
        description: description,
        options: NyThemeOptions(colors: colors, meta: meta),
      );
}

/// Theme options are used to pass additional data to the theme.
class NyThemeOptions<T> extends AppThemeOptions {
  final T colors;
  final dynamic meta;

  NyThemeOptions({required this.colors, this.meta = const {}});
}
