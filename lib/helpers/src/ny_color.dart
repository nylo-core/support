import 'package:flutter/material.dart';

import '/themes/ny_themes.dart';
import 'extensions.dart';

/// Helper to find correct color from the [context].
class NyColor {
  final Color? light;
  final Color? dark;

  NyColor({this.light, this.dark});

  NyColor.fromColor(Color? color) : light = color, dark = color;

  /// Get the color based on the device mode
  Color? toColor(BuildContext context) {
    return resolveColor(context, light: light, dark: dark);
  }

  /// Get the color based on the device mode
  static Color? resolveColor(
    BuildContext context, {
    Color? light,
    Color? dark,
  }) {
    bool isDarkModeEnabled = NyThemeManager.instance.isDark;

    // Also check device dark mode as fallback
    if (!isDarkModeEnabled && context.isDeviceInDarkMode) {
      isDarkModeEnabled = true;
    }

    if (isDarkModeEnabled) {
      return dark;
    }

    return light;
  }
}
