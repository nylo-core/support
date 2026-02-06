import 'package:flutter/material.dart';

/// Base color configuration for app themes.
///
/// Implement this abstract class to define your app's color scheme.
/// Add your implementations in light_theme_colors.dart and dark_theme_colors.dart.
///
/// Example:
/// ```dart
/// class LightThemeColors extends ThemeColor {
///   @override
///   GeneralColors get general => const GeneralColors(
///     background: Colors.white,
///     content: Colors.black,
///     primaryAccent: Colors.blue,
///     surface: Colors.grey,
///     surfaceContent: Colors.black87,
///   );
///   // ... other overrides
/// }
/// ```
abstract class ThemeColor {
  /// General app colors for backgrounds, content, and accents.
  GeneralColors get general;

  /// Colors for the app bar.
  AppBarColors get appBar;

  /// Colors for the bottom tab bar.
  BottomTabBarColors get bottomTabBar;
}

/// General color configuration for the app.
class GeneralColors {
  /// The primary background color.
  final Color background;

  /// The primary content/text color.
  final Color content;

  /// The primary accent color for highlights and interactive elements.
  final Color primaryAccent;

  /// The surface background color (cards, dialogs, etc.).
  final Color surface;

  /// The content color on surfaces.
  final Color surfaceContent;

  /// Creates a [GeneralColors] configuration.
  const GeneralColors({
    required this.background,
    required this.content,
    required this.primaryAccent,
    required this.surface,
    required this.surfaceContent,
  });

  /// Creates a copy with the specified fields replaced.
  GeneralColors copyWith({
    Color? background,
    Color? content,
    Color? primaryAccent,
    Color? surface,
    Color? surfaceContent,
  }) {
    return GeneralColors(
      background: background ?? this.background,
      content: content ?? this.content,
      primaryAccent: primaryAccent ?? this.primaryAccent,
      surface: surface ?? this.surface,
      surfaceContent: surfaceContent ?? this.surfaceContent,
    );
  }
}

/// Color configuration for the app bar.
class AppBarColors {
  /// The app bar background color.
  final Color background;

  /// The app bar content/text color.
  final Color content;

  /// Creates an [AppBarColors] configuration.
  const AppBarColors({required this.background, required this.content});

  /// Creates a copy with the specified fields replaced.
  AppBarColors copyWith({Color? background, Color? content}) {
    return AppBarColors(
      background: background ?? this.background,
      content: content ?? this.content,
    );
  }
}

/// Color configuration for the bottom tab bar.
class BottomTabBarColors {
  /// The bottom tab bar background color.
  final Color background;

  /// The color for selected tab icons.
  final Color iconSelected;

  /// The color for unselected tab icons.
  final Color iconUnselected;

  /// The color for selected tab labels.
  final Color labelSelected;

  /// The color for unselected tab labels.
  final Color labelUnselected;

  /// Creates a [BottomTabBarColors] configuration.
  const BottomTabBarColors({
    required this.background,
    required this.iconSelected,
    required this.iconUnselected,
    required this.labelSelected,
    required this.labelUnselected,
  });

  /// Creates a copy with the specified fields replaced.
  BottomTabBarColors copyWith({
    Color? background,
    Color? iconSelected,
    Color? iconUnselected,
    Color? labelSelected,
    Color? labelUnselected,
  }) {
    return BottomTabBarColors(
      background: background ?? this.background,
      iconSelected: iconSelected ?? this.iconSelected,
      iconUnselected: iconUnselected ?? this.iconUnselected,
      labelSelected: labelSelected ?? this.labelSelected,
      labelUnselected: labelUnselected ?? this.labelUnselected,
    );
  }
}
