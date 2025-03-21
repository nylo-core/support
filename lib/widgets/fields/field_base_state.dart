import 'package:flutter/material.dart';
import '/helpers/extensions.dart';
import 'package:theme_provider/theme_provider.dart';
import '../../helpers/ny_color.dart';
import '/helpers/helper.dart';
import '/themes/base_theme_config.dart';
import '/widgets/ny_form.dart';

import '/widgets/spacing.dart';

abstract class FieldBaseState<T extends StatefulWidget> extends State<T> {
  FieldBaseState(this.field);
  late Field field;

  /// Default surface color for dark mode
  Color surfaceColorDark = "222831".toHexColor();

  /// Get metadata from a field
  // ignore: avoid_shadowing_type_parameters
  T getFieldMeta<T>(String name, T defaultValue) {
    if (field.cast.metaData == null || field.cast.metaData![name] == null) {
      return defaultValue;
    }
    return field.cast.metaData![name];
  }

  /// Get the widget state property for color
  WidgetStateProperty<Color>? getWidgetStatePropertyColor(String key,
      {Color? defaultValue}) {
    Color? colorMetaData = getFieldMeta(key, defaultValue);
    if (colorMetaData == null) {
      return null;
    }
    Color? thumbColorMetaData = color(light: colorMetaData, dark: Colors.black);
    if (thumbColorMetaData == null) {
      return null;
    }
    return WidgetStateProperty.all(thumbColorMetaData);
  }

  /// Get the widget state property for icon
  WidgetStateProperty<Icon>? getWidgetStatePropertyIcon(String key,
      {Icon? defaultValue}) {
    Icon? iconMetaData = getFieldMeta(key, defaultValue);
    if (iconMetaData == null) {
      return null;
    }
    return WidgetStateProperty.all(iconMetaData);
  }

  /// Get the headerSpacing from the field
  double getHeaderSpacing() => getFieldMeta("headerSpacing", 5);

  /// Get the footerSpacing from the field
  double getFooterSpacing() => getFieldMeta("footerSpacing", 5);

  /// The view of the widget
  Widget view(BuildContext context) {
    return const SizedBox.shrink();
  }

  /// Build the widget
  @override
  Widget build(BuildContext context) {
    Widget widget = view(context);

    if (field.header != null || field.footer != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (field.header != null) ...[
            field.header!,
            Spacing.vertical(getHeaderSpacing())
          ],
          widget,
          if (field.footer != null) ...[
            field.footer!,
            Spacing.vertical(getFooterSpacing())
          ],
        ],
      );
    }

    return widget;
  }

  /// Get the color based on the device mode
  Color? color({Color? light, Color? dark}) {
    return NyColor.resolveColor(context, light: light, dark: dark);
  }

  /// When the theme is in [light] mode, return [light] function, else return [dark] function
  // ignore: avoid_shadowing_type_parameters
  T whenTheme<T>({
    required T Function() light,
    T Function()? dark,
  }) {
    bool isDarkModeEnabled = false;
    ThemeController themeController = ThemeProvider.controllerOf(context);

    if (themeController.currentThemeId == getEnv('DARK_THEME_ID')) {
      isDarkModeEnabled = true;
    }

    if ((themeController.theme.options as NyThemeOptions).meta is Map &&
        (themeController.theme.options as NyThemeOptions).meta['type'] ==
            NyThemeType.dark) {
      isDarkModeEnabled = true;
    }

    if (context.isDeviceInDarkMode) {
      isDarkModeEnabled = true;
    }

    if (isDarkModeEnabled) {
      if (dark != null) {
        return dark();
      }
    }

    return light();
  }
}
