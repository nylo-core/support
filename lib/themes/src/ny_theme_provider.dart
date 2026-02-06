import 'package:flutter/material.dart';
import 'ny_theme_manager.dart';
import 'base_theme_config.dart';

/// Widget that provides theme context to its descendants.
///
/// Wraps the child in [AnimatedTheme] for smooth theme transitions.
/// Uses [ValueListenableBuilder] to reactively rebuild when theme changes.
///
/// Example:
/// ```dart
/// NyThemeProvider(
///   child: MaterialApp(
///     theme: NyThemeManager.instance.themeData,
///     home: MyHomePage(),
///   ),
/// )
/// ```
///
/// Or with custom transition settings:
/// ```dart
/// NyThemeProvider(
///   duration: Duration(milliseconds: 300),
///   curve: Curves.easeOut,
///   child: MaterialApp(...),
/// )
/// ```
class NyThemeProvider extends StatelessWidget {
  /// The child widget to wrap.
  final Widget child;

  /// Duration of the theme transition animation.
  final Duration duration;

  /// Curve of the theme transition animation.
  final Curve curve;

  /// Create a new [NyThemeProvider].
  const NyThemeProvider({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
  });

  /// Get the [NyThemeManager] instance from context.
  ///
  /// This is a convenience method that returns the singleton instance.
  static NyThemeManager of(BuildContext context) {
    return NyThemeManager.instance;
  }

  /// Get typed color styles from the current theme.
  ///
  /// Example:
  /// ```dart
  /// final colors = NyThemeProvider.colorStyles<MyColorStyles>(context);
  /// ```
  static T colorStyles<T>(BuildContext context) {
    return NyThemeManager.instance.colorStyles<T>();
  }

  /// Check if the current theme is dark.
  static bool isDark(BuildContext context) {
    return NyThemeManager.instance.isDark;
  }

  /// Get the current theme ID.
  static String currentThemeId(BuildContext context) {
    return NyThemeManager.instance.currentThemeId;
  }

  /// Get the current [BaseThemeConfig].
  static BaseThemeConfig? currentTheme(BuildContext context) {
    return NyThemeManager.instance.currentTheme;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: NyThemeManager.instance.themeNotifier,
      builder: (context, themeId, _) {
        final themeData = NyThemeManager.instance.themeData;

        if (themeData == null) {
          // Return child without theme wrapper if no theme is set
          return child;
        }

        return AnimatedTheme(
          data: themeData,
          duration: duration,
          curve: curve,
          child: child,
        );
      },
    );
  }
}

/// A widget that rebuilds when the theme changes.
///
/// Use this to wrap individual widgets that need to respond to theme changes
/// without wrapping the entire app.
///
/// Example:
/// ```dart
/// NyThemeBuilder(
///   builder: (context, themeData) {
///     return Container(
///       color: themeData.primaryColor,
///       child: Text('Themed container'),
///     );
///   },
/// )
/// ```
class NyThemeBuilder extends StatelessWidget {
  /// Builder function that receives the current [ThemeData].
  final Widget Function(BuildContext context, ThemeData? themeData) builder;

  /// Create a new [NyThemeBuilder].
  const NyThemeBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: NyThemeManager.instance.themeNotifier,
      builder: (context, themeId, _) {
        return builder(context, NyThemeManager.instance.themeData);
      },
    );
  }
}

/// A widget that rebuilds with typed color styles when the theme changes.
///
/// Example:
/// ```dart
/// NyColorStyleBuilder<MyColorStyles>(
///   builder: (context, colors) {
///     return Container(
///       color: colors.background,
///       child: Text(
///         'Styled text',
///         style: TextStyle(color: colors.content),
///       ),
///     );
///   },
/// )
/// ```
class NyColorStyleBuilder<T> extends StatelessWidget {
  /// Builder function that receives the typed color styles.
  final Widget Function(BuildContext context, T colorStyles) builder;

  /// Create a new [NyColorStyleBuilder].
  const NyColorStyleBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: NyThemeManager.instance.themeNotifier,
      builder: (context, themeId, _) {
        return builder(context, NyThemeManager.instance.colorStyles<T>());
      },
    );
  }
}
