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
    dynamic fieldValue = widget.field.value;

    if (fieldValue is String && fieldValue.isNotEmpty) {
      try {
        currentValue = DateTime.parse(fieldValue);
      } on Exception catch (e) {
        dump(e);
      }
    }

    if (fieldValue is DateTime) {
      currentValue = fieldValue;
    }

    currentValue ??= style.firstDate ?? DateTime.now();
  }

  @override
  Map<String, Function> get stateActions => {
    "clear": () {
      currentValue = null;
      setState(() {});
    },
  };

  @override
  Widget view(BuildContext context) {
    return DateTimeFormField(
      decoration:
          style.decoration ??
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
      hideDefaultSuffixIcon: style.hideDefaultSuffixIcon,
      padding: style.padding ?? EdgeInsets.zero,
      style:
          style.style ??
          TextStyle(
            fontSize: 16,
            color: color(light: Colors.black, dark: Colors.white),
          ),
      onChanged: widget.onChanged,
    );
  }
}
