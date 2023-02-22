import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';

/// Base theme config is used for theme management
/// Set the required parameters to create new themes.
class BaseThemeConfig<T> {
  final String id;
  final String description;
  final ThemeData theme;
  final T colors;
  final dynamic meta;

  BaseThemeConfig(
      {required this.id,
      required this.description,
      required this.theme,
      required this.colors,
      this.meta = const {}});

  AppTheme toAppTheme({ThemeData? defaultTheme}) => AppTheme(
        id: id,
        data: defaultTheme ?? theme,
        description: description,
      );
}
