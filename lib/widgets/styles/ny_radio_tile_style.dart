import 'package:flutter/cupertino.dart';
import '/helpers/ny_text_style.dart';
import '/helpers/ny_color.dart';

/// NyRadioTileStyle
///
/// This class contains the style for the radio tile.
class NyRadioTileStyle {
  NyTextStyle? titleStyle;
  NyTextStyle? listTileStyle;
  bool? hideTitle;
  NyColor? selectedColor;
  NyColor? tileColor;
  ShapeBorder? shape;
  EdgeInsetsGeometry? contentPadding;
  NyColor? activeColor;
  NyColor? fillColor;
  NyColor? hoverColor;
  NyColor? overlayColor;
  double? splashRadius;
  MouseCursor? mouseCursor;

  NyRadioTileStyle({
    this.hideTitle,
    this.listTileStyle,
    this.titleStyle,
    this.selectedColor,
    this.tileColor,
    this.shape,
    this.contentPadding,
    this.activeColor,
    this.fillColor,
    this.hoverColor,
    this.overlayColor,
    this.splashRadius,
    this.mouseCursor,
  });
}
