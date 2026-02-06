import 'package:flutter/material.dart';
import '/helpers/ny_helpers.dart';

/// BottomModalSheetStyle
///
/// This class is used to style the bottom modal sheet.
class BottomModalSheetStyle {
  // Background color of the bottom modal sheet
  final NyColor? backgroundColor;
  // Barrier color of the bottom modal sheet
  final NyColor? barrierColor;
  // Use root navigator
  final bool useRootNavigator;
  // Route settings
  final RouteSettings? routeSettings;
  // title style
  final TextStyle? titleStyle;
  // item style
  final TextStyle? itemStyle;
  // clear button style
  final TextStyle? clearButtonStyle;

  BottomModalSheetStyle({
    this.backgroundColor,
    this.barrierColor,
    this.useRootNavigator = false,
    this.routeSettings,
    this.titleStyle,
    this.itemStyle,
    this.clearButtonStyle,
  });
}
