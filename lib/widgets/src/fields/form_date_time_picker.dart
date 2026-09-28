import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/helpers/ny_helpers.dart';
import '/widgets/ny_widgets.dart';

/// A [NyFormDateTimePicker] widget for Form Fields
class NyFormDateTimePicker extends NyFieldStatefulWidget {
  /// Creates a [NyFormDateTimePicker] widget
  NyFormDateTimePicker({
    super.key,
    required String name,
    String? value,
    FieldStyleDateTimePicker? style,
    this.onChanged,
  }) : field = Field.datetime(name, value: value, style: style);

  /// Creates a [NyFormDateTimePicker] widget from a [Field]
  NyFormDateTimePicker.fromField(this.field, {super.key})
    : onChanged = field.onChanged;

  /// The field to be rendered
  final Field field;

  @override
  Field? get formField => field;

  /// The callback function to be called when the value changes
  final Function(dynamic value)? onChanged;

  @override
  // ignore: no_logic_in_create_state
  createState() => _NyFormDateTimePickerState(field);

  /// State actions for the [NyFormDateTimePicker] widget
  /// This is used to manage the state of the widget
  static FormDateTimePickerStateActions stateActions(String stateName) =>
      FormDateTimePickerStateActions(stateName);
}

/// State actions for the [NyFormDateTimePicker] widget
class FormDateTimePickerStateActions extends FormStateActions {
  FormDateTimePickerStateActions(super.state);
}

class _NyFormDateTimePickerState extends FieldBaseState<NyFormDateTimePicker> {
  dynamic currentValue;

  _NyFormDateTimePickerState(super.field) {
    stateName = this.field.stateKey;
  }

  /// Get the style from the field
  @override
  FieldStyleDateTimePicker get style {
    return widget.field.style as FieldStyleDateTimePicker? ??
        FieldStyleDateTimePicker();
  }

  @override
  void initState() {
    super.initState();
    // An empty field stays empty: it used to show today (or `firstDate`)
    // while its value stayed null, so the form submitted nothing for the
    // date on screen. The picker still opens on today when there's no value.
    currentValue = _toDate(widget.field.value);
  }

  /// A [DateTime], or a date string such as "2026-09-27"; anything else is
  /// no date.
  DateTime? _toDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      final DateTime? parsed = DateTime.tryParse(value);
      if (parsed == null)
        dump("Field ${widget.field.key}: '$value' is not a date");
      return parsed;
    }
    return null;
  }

  @override
  Map<String, Function> get stateActions => {
    "clear": () {
      currentValue = null;
      widget.field.restoreValue(null);
      setState(() {});
    },
    // Field.setValue / NyFormWidget's setValue: show the new date. The form
    // field below re-reads `initialValue` when it changes.
    "setValue": (data) {
      currentValue = _toDate(data["value"]);
      widget.field.restoreValue(currentValue);
      setState(() {});
    },
  };

  /// The style's own decoration keeps the field's label when it gives none
  /// (no label, no hint), as a text field's does.
  InputDecoration? _customDecoration() {
    final InputDecoration? decoration = style.decoration;
    if (decoration == null) return null;
    final bool hasLabelOrHint =
        decoration.labelText != null ||
        decoration.label != null ||
        decoration.hintText != null ||
        decoration.hint != null;
    return hasLabelOrHint
        ? decoration
        : decoration.copyWith(labelText: widget.field.name);
  }

  @override
  Widget view(BuildContext context) {
    return DateTimeFormField(
      decoration:
          _customDecoration() ??
          InputDecoration(
            fillColor: color(
              light: Colors.grey.shade100,
              dark: surfaceColorDark,
            ),
            border: InputBorder.none,
            filled: true,
            suffixIconColor: color(light: Colors.black, dark: Colors.white),
            labelText: widget.field.name,
            labelStyle: TextStyle(
              fontSize: 16,
              color: color(light: Colors.grey, dark: Colors.white),
            ),
            isDense: true,
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.transparent),
            ),
          ),
      dateFormat: style.dateFormat ?? DateFormat('yyyy-MM-dd'),
      mode: style.mode,
      firstDate: style.firstDate ?? DateTime(1951),
      lastDate: style.lastDate ?? DateTime(2100),
      initialValue: currentValue,
      initialPickerDateTime: style.initialPickerDateTime ?? currentValue,
      onTap: style.onTap,
      enableFeedback: style.enableFeedback ?? true,
      autofocus: style.autofocus,
      focusNode: style.focusNode,
      pickerPlatform: style.pickerPlatform,
      materialDatePickerOptions:
          style.materialDatePickerOptions ?? const MaterialDatePickerOptions(),
      materialTimePickerOptions:
          style.materialTimePickerOptions ?? const MaterialTimePickerOptions(),
      cupertinoDatePickerOptions:
          style.cupertinoDatePickerOptions ??
          CupertinoDatePickerOptions(
            style: CupertinoDatePickerOptionsStyle(
              modalTitle: TextStyle(
                color: color(light: Colors.black, dark: Colors.white),
              ),
            ),
          ),
      canClear: style.canClear,
      clearIconData: style.clearIconData,
      hideDefaultSuffixIcon: style.hideDefaultSuffixIcon,
      padding: style.padding ?? EdgeInsets.zero,
      style:
          style.style ??
          TextStyle(
            fontSize: 16,
            color: color(light: Colors.black, dark: Colors.white),
          ),
      onChanged: (DateTime? value) {
        // Track what's on screen, so a later setValue compares against it.
        currentValue = value;
        widget.onChanged?.call(value);
      },
    );
  }
}
