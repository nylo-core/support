import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '/widgets/fields/field_base_state.dart';
import '/widgets/ny_form.dart';

/// A [NyFormSwitchBox] widget for Form Fields
class NyFormSwitchBox extends StatefulWidget {
  /// Creates a [NyFormSwitchBox] widget
  NyFormSwitchBox(
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
      this.onChanged})
      : field = Field(name, value: value)
          ..cast = FormCast.switchBox(
            activeTrackColor: activeTrackColor,
            inactiveThumbColor: inactiveThumbColor,
            inactiveTrackColor: inactiveTrackColor,
            activeThumbImage: activeThumbImage,
            onActiveThumbImageError: onActiveThumbImageError,
            inactiveThumbImage: inactiveThumbImage,
            onInactiveThumbImageError: onInactiveThumbImageError,
            thumbColor: thumbColor,
            trackColor: trackColor,
            trackOutlineColor: trackOutlineColor,
            thumbIcon: thumbIcon,
            dragStartBehavior: dragStartBehavior,
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
            checkboxSemanticLabel: checkboxSemanticLabel,
          );

  /// Creates a [NyFormSwitchBox] widget from a [Field]
  const NyFormSwitchBox.fromField(this.field, this.onChanged, {super.key});

  /// The field to be rendered
  final Field field;

  /// The callback function to be called when the value changes
  final Function(dynamic value)? onChanged;

  @override
  // ignore: no_logic_in_create_state
  createState() => _NyFormSwitchBoxState(field);
}

class _NyFormSwitchBoxState extends FieldBaseState<NyFormSwitchBox> {
  dynamic currentValue;

  _NyFormSwitchBoxState(super.field);

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

    title ??= Text(
      widget.field.name,
      style: TextStyle(
        color: color(light: Colors.black, dark: Colors.white),
      ),
    );
    if (title is Text && (title.data == null || title.data!.isEmpty)) {
      title = Text(
        widget.field.name,
        style: TextStyle(
          color: color(light: Colors.black, dark: Colors.white),
        ),
      );
    }

    Color? overlayColorMetaData = getFieldMeta('overlayColor', null);
    WidgetStateProperty<Color?>? overlayColor;
    if (overlayColorMetaData != null) {
      overlayColor = WidgetStateProperty.all(overlayColorMetaData);
    }

    return SwitchListTile.adaptive(
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
          light: getFieldMeta('activeColor', null) ?? Color(0xFF0766ff),
          dark: Colors.black),
      hoverColor: getFieldMeta('hoverColor', null),
      overlayColor: overlayColor,
      splashRadius: getFieldMeta('splashRadius', null),
      materialTapTargetSize: getFieldMeta('materialTapTargetSize', null),
      visualDensity: getFieldMeta('visualDensity', null),
      focusNode: getFieldMeta('focusNode', null),
      autofocus: getFieldMeta('autofocus', false),
      shape: getFieldMeta('shape', null),
      tileColor: getFieldMeta('tileColor', null),
      subtitle: getFieldMeta('subtitle', null),
      isThreeLine: getFieldMeta('isThreeLine', false),
      dense: getFieldMeta('dense', null),
      secondary: getFieldMeta('secondary', null),
      selected: getFieldMeta('selected', false),
      contentPadding: getFieldMeta('contentPadding', null),
      selectedTileColor: getFieldMeta('selectedTileColor', null),
      onFocusChange: getFieldMeta('onFocusChange', null),
      enableFeedback: getFieldMeta('enableFeedback', null),
      activeThumbImage: getFieldMeta('activeThumbImage', null),
      onActiveThumbImageError: getFieldMeta('onActiveThumbImageError', null),
      inactiveThumbImage: getFieldMeta('inactiveThumbImage', null),
      onInactiveThumbImageError:
          getFieldMeta('onInactiveThumbImageError', null),
      thumbColor: getWidgetStatePropertyColor('thumbColor'),
      trackColor: getWidgetStatePropertyColor('trackColor'),
      trackOutlineColor: getWidgetStatePropertyColor('trackOutlineColor'),
      thumbIcon: getWidgetStatePropertyIcon('thumbIcon'),
      activeTrackColor: getFieldMeta('activeTrackColor', null),
      inactiveThumbColor: getFieldMeta('inactiveThumbColor', null),
      inactiveTrackColor: getFieldMeta('inactiveTrackColor', null),
      dragStartBehavior:
          getFieldMeta('dragStartBehavior', DragStartBehavior.start),
      mouseCursor: getFieldMeta('mouseCursor', null),
    );
  }
}
