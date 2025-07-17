import 'package:date_field/date_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/widgets/styles/bottom_modal_sheet_style.dart';
import '/widgets/styles/ny_radio_tile_style.dart';
import '/widgets/ny_form.dart';

/// FormCast is a class that helps in managing form casts
class FormCast {
  String? type;
  dynamic metaData;

  FormCast({this.type = "capitalize-sentences"});

  /// Get the metadata for the form cast
  dynamic getMetaData(String name) {
    if (metaData == null) {
      return null;
    }
    if (metaData[name] == null) {
      return null;
    }
    return metaData[name];
  }

  /// Add metadata to the form cast
  void addMetaData(Map<String, dynamic> data) {
    if (metaData is Map) {
      metaData.addAll(data);
      return;
    }
    metaData = data;
  }

  /// Cast to a custom form field
  FormCast.custom(String this.type, {this.metaData});

  /// Cast to text
  FormCast.text({
    Widget? prefixIcon,
    bool clearable = false,
    Widget? clearIcon,
  }) {
    type = "text";

    metaData = {};
    metaData['prefixIcon'] = prefixIcon;
    metaData['clearable'] = clearable;
    metaData['clearIcon'] = clearIcon;
  }

  /// Cast to text
  FormCast.mask({
    Widget? prefixIcon,
    bool clearable = false,
    Widget? clearIcon,
    required String? mask,
    String? match = r'[\w\d]',
    bool? maskReturnValue = false,
  }) {
    type = "mask";

    metaData = {};
    metaData['prefixIcon'] = prefixIcon;
    metaData['clearable'] = clearable;
    metaData['clearIcon'] = clearIcon;
    metaData['mask'] = mask;
    metaData['match'] = match;
    metaData['maskedReturnValue'] = maskReturnValue;
  }

  /// Cast to a currency
  FormCast.currency(String currency) {
    type = "currency:$currency";
  }

  /// Cast to a checkbox
  FormCast.checkbox({
    MouseCursor? mouseCursor,
    Color? activeColor,
    Color? fillColor,
    Color? checkColor,
    Color? hoverColor,
    Color? overlayColor,
    double? splashRadius,
    MaterialTapTargetSize? materialTapTargetSize,
    VisualDensity? visualDensity,
    FocusNode? focusNode,
    bool autofocus = false,
    ShapeBorder? shape,
    BorderSide? side,
    bool isError = false,
    bool? enabled,
    Color? tileColor,
    Widget? title,
    Widget? subtitle,
    bool isThreeLine = false,
    bool? dense,
    Widget? secondary,
    bool selected = false,
    ListTileControlAffinity controlAffinity = ListTileControlAffinity.platform,
    EdgeInsetsGeometry? contentPadding,
    bool tristate = false,
    ShapeBorder? checkboxShape,
    Color? selectedTileColor,
    ValueChanged<bool?>? onFocusChange,
    bool? enableFeedback,
    String? checkboxSemanticLabel,
  }) {
    type = "checkbox";
    metaData = {};
    metaData['mouseCursor'] = mouseCursor;
    metaData['activeColor'] = activeColor;
    metaData['fillColor'] = fillColor;
    metaData['checkColor'] = checkColor;
    metaData['hoverColor'] = hoverColor;
    metaData['overlayColor'] = overlayColor;
    metaData['splashRadius'] = splashRadius;
    metaData['materialTapTargetSize'] = materialTapTargetSize;
    metaData['visualDensity'] = visualDensity;
    metaData['focusNode'] = focusNode;
    metaData['autofocus'] = autofocus;
    metaData['shape'] = shape;
    metaData['side'] = side;
    metaData['isError'] = isError;
    metaData['enabled'] = enabled;
    metaData['tileColor'] = tileColor;
    metaData['title'] = title;
    metaData['subtitle'] = subtitle;
    metaData['isThreeLine'] = isThreeLine;
    metaData['dense'] = dense;
    metaData['secondary'] = secondary;
    metaData['selected'] = selected;
    metaData['controlAffinity'] = controlAffinity;
    metaData['contentPadding'] = contentPadding;
    metaData['tristate'] = tristate;
    metaData['checkboxShape'] = checkboxShape;
    metaData['selectedTileColor'] = selectedTileColor;
    metaData['onFocusChange'] = onFocusChange;
    metaData['enableFeedback'] = enableFeedback;
    metaData['checkboxSemanticLabel'] = checkboxSemanticLabel;
  }

  /// Cast to a widget
  FormCast.widget({
    required Widget child,
  }) {
    type = "widget";
    metaData = {};
    metaData['child'] = child;
  }

  /// Cast to a switchBox
  FormCast.switchBox({
    MouseCursor? mouseCursor,
    Color? activeColor,
    Color? fillColor,
    Color? checkColor,
    Color? hoverColor,
    Color? overlayColor,
    double? splashRadius,
    MaterialTapTargetSize? materialTapTargetSize,
    VisualDensity? visualDensity,
    FocusNode? focusNode,
    bool autofocus = false,
    ShapeBorder? shape,
    BorderSide? side,
    bool isError = false,
    bool? enabled,
    Color? tileColor,
    Widget? title,
    Widget? subtitle,
    bool isThreeLine = false,
    bool? dense,
    Widget? secondary,
    bool selected = false,
    ListTileControlAffinity controlAffinity = ListTileControlAffinity.platform,
    EdgeInsetsGeometry? contentPadding,
    bool tristate = false,
    ShapeBorder? checkboxShape,
    Color? selectedTileColor,
    ValueChanged<bool?>? onFocusChange,
    bool? enableFeedback,
    String? checkboxSemanticLabel,
    Color? activeTrackColor,
    Color? inactiveThumbColor,
    Color? inactiveTrackColor,
    ImageProvider? activeThumbImage,
    ImageErrorListener? onActiveThumbImageError,
    ImageProvider? inactiveThumbImage,
    ImageErrorListener? onInactiveThumbImageError,
    Color? thumbColor,
    Color? trackColor,
    Color? trackOutlineColor,
    Widget? thumbIcon,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
  }) {
    type = "switchBox";
    metaData = {};
    metaData['mouseCursor'] = mouseCursor;
    metaData['activeColor'] = activeColor;
    metaData['fillColor'] = fillColor;
    metaData['checkColor'] = checkColor;
    metaData['hoverColor'] = hoverColor;
    metaData['overlayColor'] = overlayColor;
    metaData['splashRadius'] = splashRadius;
    metaData['materialTapTargetSize'] = materialTapTargetSize;
    metaData['visualDensity'] = visualDensity;
    metaData['focusNode'] = focusNode;
    metaData['autofocus'] = autofocus;
    metaData['shape'] = shape;
    metaData['side'] = side;
    metaData['isError'] = isError;
    metaData['enabled'] = enabled;
    metaData['tileColor'] = tileColor;
    metaData['title'] = title;
    metaData['subtitle'] = subtitle;
    metaData['isThreeLine'] = isThreeLine;
    metaData['dense'] = dense;
    metaData['secondary'] = secondary;
    metaData['selected'] = selected;
    metaData['controlAffinity'] = controlAffinity;
    metaData['contentPadding'] = contentPadding;
    metaData['tristate'] = tristate;
    metaData['checkboxShape'] = checkboxShape;
    metaData['selectedTileColor'] = selectedTileColor;
    metaData['onFocusChange'] = onFocusChange;
    metaData['enableFeedback'] = enableFeedback;
    metaData['checkboxSemanticLabel'] = checkboxSemanticLabel;
    metaData['activeTrackColor'] = activeTrackColor;
    metaData['inactiveThumbColor'] = inactiveThumbColor;
    metaData['inactiveTrackColor'] = inactiveTrackColor;
    metaData['activeThumbImage'] = activeThumbImage;
    metaData['onActiveThumbImageError'] = onActiveThumbImageError;
    metaData['inactiveThumbImage'] = inactiveThumbImage;
    metaData['onInactiveThumbImageError'] = onInactiveThumbImageError;
    metaData['thumbColor'] = thumbColor;
    metaData['trackColor'] = trackColor;
    metaData['trackOutlineColor'] = trackOutlineColor;
    metaData['thumbIcon'] = thumbIcon;
    metaData['dragStartBehavior'] = dragStartBehavior;
  }

  /// Cast to capitalize words
  FormCast.capitalizeWords({
    Widget? prefixIcon,
    bool clearable = false,
    Widget? clearIcon,
  }) {
    type = "capitalize-words";

    metaData = {};
    metaData['prefixIcon'] = prefixIcon;
    metaData['clearable'] = clearable;
    metaData['clearIcon'] = clearIcon;
  }

  /// Cast to capitalize sentences
  FormCast.capitalizeSentences({
    Widget? prefixIcon,
    bool clearable = false,
    Widget? clearIcon,
  }) {
    type = "capitalize-sentences";

    metaData = {};
    metaData['prefixIcon'] = prefixIcon;
    metaData['clearable'] = clearable;
    metaData['clearIcon'] = clearIcon;
  }

  /// Cast to a number
  FormCast.number({bool decimal = false}) {
    type = "number";
    if (decimal) {
      type = "number:decimal";
    }
  }

  /// Cast to phone number
  FormCast.phoneNumber({
    Widget? prefixIcon,
    bool clearable = false,
    Widget? clearIcon,
  }) {
    type = "phone_number";

    metaData = {};
    metaData['prefixIcon'] = prefixIcon;
    metaData['clearable'] = clearable;
    metaData['clearIcon'] = clearIcon;
  }

  /// Cast to an email
  FormCast.email({
    Widget? prefixIcon,
    bool clearable = false,
    Widget? clearIcon,
  }) {
    type = "email";

    metaData = {};
    metaData['prefixIcon'] = prefixIcon;
    metaData['clearable'] = clearable;
    metaData['clearIcon'] = clearIcon;
  }

  /// Cast to a url
  FormCast.url({
    Widget? prefixIcon,
    bool clearable = false,
    Widget? clearIcon,
  }) {
    type = "url";

    metaData = {};
    metaData['prefixIcon'] = prefixIcon;
    metaData['clearable'] = clearable;
    metaData['clearIcon'] = clearIcon;
  }

  /// Cast to datetime
  FormCast.datetime({
    TextStyle? style,
    VoidCallback? onTap,
    FocusNode? focusNode,
    bool autofocus = false,
    bool? enableFeedback,
    EdgeInsetsGeometry? padding,
    bool hideDefaultSuffixIcon = false,
    DateTime? initialPickerDateTime,
    CupertinoDatePickerOptions? cupertinoDatePickerOptions,
    MaterialDatePickerOptions? materialDatePickerOptions,
    MaterialTimePickerOptions? materialTimePickerOptions,
    InputDecoration? decoration,
    DateFormat? dateFormat,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTimeFieldPickerMode mode = DateTimeFieldPickerMode.dateAndTime,
    DateTimeFieldPickerPlatform pickerPlatform =
        DateTimeFieldPickerPlatform.adaptive,
  }) {
    type = "datetime";
    metaData = {};
    metaData['style'] = style;
    metaData['onTap'] = onTap;
    metaData['focusNode'] = focusNode;
    metaData['autofocus'] = autofocus;
    metaData['enableFeedback'] = enableFeedback;
    metaData['padding'] = padding;
    metaData['hideDefaultSuffixIcon'] = hideDefaultSuffixIcon;
    metaData['initialPickerDateTime'] = initialPickerDateTime;
    metaData['cupertinoDatePickerOptions'] = cupertinoDatePickerOptions;
    metaData['materialDatePickerOptions'] = materialDatePickerOptions;
    metaData['materialTimePickerOptions'] = materialTimePickerOptions;
    metaData['decoration'] = decoration;
    metaData['dateFormat'] = dateFormat;
    metaData['firstDate'] = firstDate;
    metaData['lastDate'] = lastDate;
    metaData['mode'] = mode;
    metaData['pickerPlatform'] = pickerPlatform;
  }

  /// Cast to date
  FormCast.date({
    TextStyle? style,
    VoidCallback? onTap,
    FocusNode? focusNode,
    bool autofocus = false,
    bool? enableFeedback,
    EdgeInsetsGeometry? padding,
    bool hideDefaultSuffixIcon = false,
    DateTime? initialPickerDateTime,
    CupertinoDatePickerOptions? cupertinoDatePickerOptions,
    MaterialDatePickerOptions? materialDatePickerOptions,
    MaterialTimePickerOptions? materialTimePickerOptions,
    InputDecoration? decoration,
    DateFormat? dateFormat,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTimeFieldPickerMode mode = DateTimeFieldPickerMode.date,
    DateTimeFieldPickerPlatform pickerPlatform =
        DateTimeFieldPickerPlatform.adaptive,
  }) {
    type = "datetime";
    metaData = {};
    metaData['style'] = style;
    metaData['onTap'] = onTap;
    metaData['focusNode'] = focusNode;
    metaData['autofocus'] = autofocus;
    metaData['enableFeedback'] = enableFeedback;
    metaData['padding'] = padding;
    metaData['hideDefaultSuffixIcon'] = hideDefaultSuffixIcon;
    metaData['initialPickerDateTime'] = initialPickerDateTime;
    metaData['cupertinoDatePickerOptions'] = cupertinoDatePickerOptions;
    metaData['materialDatePickerOptions'] = materialDatePickerOptions;
    metaData['materialTimePickerOptions'] = materialTimePickerOptions;
    metaData['decoration'] = decoration;
    metaData['dateFormat'] = dateFormat;
    metaData['firstDate'] = firstDate;
    metaData['lastDate'] = lastDate;
    metaData['mode'] = mode;
    metaData['pickerPlatform'] = pickerPlatform;
  }

  /// Cast to a picker
  FormCast.picker({
    required List<dynamic> options,
    BottomModalSheetStyle? bottomModalSheetStyle,
  }) {
    type = "picker";
    metaData = {};
    metaData['options'] = options;

    // BottomModalSheetStyle
    metaData['bm_backgroundColor'] = bottomModalSheetStyle?.backgroundColor;
    metaData['bm_barrierColor'] = bottomModalSheetStyle?.barrierColor;
    metaData['bm_useRootNavigator'] = bottomModalSheetStyle?.useRootNavigator;
    metaData['bm_routeSettings'] = bottomModalSheetStyle?.routeSettings;

    metaData['bm_titleTextStyle'] = bottomModalSheetStyle?.titleStyle;
    metaData['bm_itemStyle'] = bottomModalSheetStyle?.itemStyle;
    metaData['bm_clearButtonStyle'] = bottomModalSheetStyle?.clearButtonStyle;
  }

  /// Cast to a radio
  FormCast.radio({
    required List<dynamic> options,
    NyRadioTileStyle? nyRadioTileStyle,
  }) {
    type = "radio";
    metaData = {};
    metaData['options'] = options;

    // NyRadioTileStyle
    metaData['titleStyle'] = nyRadioTileStyle?.titleStyle;
    metaData['listTileStyle'] = nyRadioTileStyle?.listTileStyle;
    metaData['hideTitle'] = nyRadioTileStyle?.hideTitle;
    metaData['tileColor'] = nyRadioTileStyle?.tileColor;
    metaData['selectedColor'] = nyRadioTileStyle?.selectedColor;
    metaData['shape'] = nyRadioTileStyle?.shape;
    metaData['contentPadding'] = nyRadioTileStyle?.contentPadding;
    metaData['activeColor'] = nyRadioTileStyle?.activeColor;
    metaData['fillColor'] = nyRadioTileStyle?.fillColor;
    metaData['hoverColor'] = nyRadioTileStyle?.hoverColor;
    metaData['overlayColor'] = nyRadioTileStyle?.overlayColor;
    metaData['splashRadius'] = nyRadioTileStyle?.splashRadius;
    metaData['mouseCursor'] = nyRadioTileStyle?.mouseCursor;
  }

  /// Cast to a chips
  FormCast.chips({
    required List<dynamic> options,
    Color? backgroundColor,
    Color? selectedColor,
    double headerSpacing = 5,
    double footerSpacing = 5,
    OutlinedBorder shape = const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8))),
    BorderSide unselectedSide = const BorderSide(color: Colors.grey, width: 1),
    BorderSide selectedSide = const BorderSide(color: Colors.grey, width: 1),
    TextStyle labelStyle =
        const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
    TextStyle unselectedTextStyle =
        const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
    TextStyle selectedTextStyle =
        const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
    EdgeInsets padding = const EdgeInsets.all(8.0),
    double runSpacing = 8.0,
    double spacing = 8.0,
    Color checkmarkColor = Colors.white,
  }) {
    type = "chip";
    metaData = {};
    metaData['options'] = options;
    metaData['backgroundColor'] = backgroundColor;
    metaData['selectedColor'] = selectedColor;
    metaData['headerSpacing'] = headerSpacing;
    metaData['footerSpacing'] = footerSpacing;
    metaData['shape'] = shape;
    metaData['unselectedSide'] = unselectedSide;
    metaData['selectedSide'] = selectedSide;
    metaData['labelStyle'] = labelStyle;
    metaData['unselectedTextStyle'] = unselectedTextStyle;
    metaData['selectedTextStyle'] = selectedTextStyle;
    metaData['padding'] = padding;
    metaData['runSpacing'] = runSpacing;
    metaData['spacing'] = spacing;
    metaData['checkmarkColor'] = checkmarkColor;
  }

  /// Cast to a textarea
  FormCast.textArea({TextAreaSize textAreaSize = TextAreaSize.sm}) {
    String size = "sm";
    if (textAreaSize == TextAreaSize.md) {
      size = "md";
    }
    if (textAreaSize == TextAreaSize.lg) {
      size = "lg";
    }

    type = "textarea:$size";
  }

  /// Cast to uppercase
  FormCast.uppercase() {
    type = "uppercase";
  }

  /// Cast to uppercase
  FormCast.lowercase() {
    type = "lowercase";
  }

  /// Cast to a password
  FormCast.password({bool viewable = false, Widget? prefixIcon}) {
    type = "password";
    if (viewable) {
      type = "password:viewable";
    }

    metaData = {};
    metaData['prefixIcon'] = prefixIcon;
  }
}
