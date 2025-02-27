import 'package:flutter/material.dart';

import '/widgets/fields/field_base_state.dart';
import '/widgets/ny_form.dart';

/// A [NyFormCheckbox] widget for Form Fields
class NyFormCheckbox extends StatefulWidget {
  /// Creates a [NyFormCheckbox] widget
  NyFormCheckbox(
      {super.key,
      required String name,
      bool? value,
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
      ListTileControlAffinity controlAffinity =
          ListTileControlAffinity.platform,
      EdgeInsetsGeometry? contentPadding,
      bool tristate = false,
      ShapeBorder? checkboxShape,
      Color? selectedTileColor,
      ValueChanged<bool?>? onFocusChange,
      bool? enableFeedback,
      String? checkboxSemanticLabel,
      this.onChanged})
      : field = Field(name, value: value)
          ..cast = FormCast.checkbox(
              mouseCursor: mouseCursor,
              activeColor: activeColor,
              fillColor: fillColor,
              checkColor: checkColor,
              hoverColor: hoverColor,
              overlayColor: overlayColor,
              splashRadius: splashRadius,
              materialTapTargetSize: materialTapTargetSize,
              visualDensity: visualDensity,
              focusNode: focusNode,
              autofocus: autofocus,
              shape: shape,
              side: side,
              isError: isError,
              enabled: enabled,
              tileColor: tileColor,
              subtitle: subtitle,
              isThreeLine: isThreeLine,
              dense: dense,
              secondary: secondary,
              selected: selected,
              controlAffinity: controlAffinity,
              contentPadding: contentPadding,
              tristate: tristate,
              checkboxShape: checkboxShape,
              selectedTileColor: selectedTileColor,
              onFocusChange: onFocusChange,
              enableFeedback: enableFeedback,
              checkboxSemanticLabel: checkboxSemanticLabel);

  /// Creates a [NyFormCheckbox] widget from a [Field]
  const NyFormCheckbox.fromField(this.field, this.onChanged, {super.key});

  /// The field to be rendered
  final Field field;

  /// The callback function to be called when the value changes
  final Function(dynamic value)? onChanged;

  @override
  // ignore: no_logic_in_create_state
  createState() => _NyFormCheckboxState(field);
}

class _NyFormCheckboxState extends FieldBaseState<NyFormCheckbox> {
  dynamic currentValue;

  _NyFormCheckboxState(super.field);

  @override
  void initState() {
    super.initState();
    dynamic fieldValue = widget.field.value;

    if (fieldValue is String) {
      if (fieldValue.toLowerCase() == "true") {
        currentValue = true;
      } else if (fieldValue.toLowerCase() == "false") {
        currentValue = false;
      }
    }

    if (fieldValue is bool) {
      currentValue = fieldValue;
    }

    currentValue ??= false;
  }

  @override
  Widget view(BuildContext context) {
    Widget? title = getFieldMeta('title', null);

    if (title == null ||
        (title is Text && (title.data == null || title.data!.isEmpty))) {
      title = Text(
        widget.field.name,
        style: TextStyle(
          color: color(light: Colors.black, dark: Colors.white),
        ),
      );
    }

    Color? fillColorMetaData = color(
        light: getFieldMeta('fillColor', null) ?? Colors.transparent,
        dark: Colors.black);
    WidgetStateProperty<Color?>? fillColor =
        WidgetStateProperty.all(fillColorMetaData);

    Color? overlayColorMetaData = getFieldMeta('overlayColor', null);
    WidgetStateProperty<Color?>? overlayColor;
    if (overlayColorMetaData != null) {
      overlayColor = WidgetStateProperty.all(overlayColorMetaData);
    }

    return CheckboxListTile(
      mouseCursor: getFieldMeta('mouseCursor', null),
      title: title,
      value: currentValue,
      onChanged: (value) {
        setState(() {
          currentValue = value;
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        });
      },
      controlAffinity:
          getFieldMeta("controlAffinity", ListTileControlAffinity.platform),
      activeColor: color(
          light: getFieldMeta('activeColor', null) ?? Colors.black,
          dark: Colors.black),
      fillColor: fillColor,
      checkColor: color(
          light: getFieldMeta('checkColor', null) ?? Colors.black,
          dark: Colors.white),
      hoverColor: getFieldMeta('hoverColor', null),
      overlayColor: overlayColor,
      splashRadius: getFieldMeta('splashRadius', null),
      materialTapTargetSize: getFieldMeta('materialTapTargetSize', null),
      visualDensity: getFieldMeta('visualDensity', null),
      focusNode: getFieldMeta('focusNode', null),
      autofocus: getFieldMeta('autofocus', false),
      shape: getFieldMeta('shape', null),
      side: whenTheme(
          light: () => getFieldMeta('side', null),
          dark: () => BorderSide(
              width: 2,
              color: color(light: Colors.black, dark: Colors.white) ??
                  const Color(0xFF000000))),
      isError: getFieldMeta('isError', false),
      enabled: getFieldMeta('enabled', null),
      tileColor: getFieldMeta('tileColor', null),
      subtitle: getFieldMeta('subtitle', null),
      isThreeLine: getFieldMeta('isThreeLine', false),
      dense: getFieldMeta('dense', null),
      secondary: getFieldMeta('secondary', null),
      selected: getFieldMeta('selected', false),
      contentPadding: getFieldMeta('contentPadding', null),
      tristate: getFieldMeta('tristate', false),
      checkboxShape: getFieldMeta('checkboxShape', null),
      selectedTileColor: getFieldMeta('selectedTileColor', null),
      onFocusChange: getFieldMeta('onFocusChange', null),
      enableFeedback: getFieldMeta('enableFeedback', null),
      checkboxSemanticLabel: getFieldMeta('checkboxSemanticLabel', null),
    );
  }
}
