import 'package:flutter/material.dart';
import '/widgets/ny_widgets.dart';

/// A text input field widget designed for use within forms.
///
/// [NyFormTextField] provides a customizable text input interface that integrates
/// with the Nylo form system. It supports validation, styling, and automatic
/// state management for text-based user input.
///
/// Example usage:
/// ```dart
/// NyFormTextField(
///   name: 'username',
///   options: [], // Required but not used for text fields
///   onChanged: (value) => print('Text changed: $value'),
/// )
/// ```
class NyFormTextField extends NyFieldStatefulWidget {
  /// Creates a [NyFormTextField] widget with the specified configuration.
  ///
  /// The [name] identifies the field, [options] is required but unused for text fields,
  /// and [selectedValue] sets the initial text value. Customize appearance with [style].
  NyFormTextField({
    super.key,
    required String name,
    required List<String> options,
    String? selectedValue,
    FieldStyleTextField? style,
    this.onChanged,
  }) : field = Field.text(name, value: selectedValue, style: style);

  /// Creates a [NyFormTextField] widget from an existing [Field] instance.
  ///
  /// This constructor is useful when the field configuration is already defined
  /// elsewhere in your form setup.
  NyFormTextField.fromField(this.field, {super.key})
    : onChanged = field.onChanged;

  /// The field configuration that defines the text input behavior and properties.
  final Field field;

  @override
  Field? get formField => field;

  /// Callback function invoked when the user types or modifies the text input.
  ///
  /// The callback receives the current text value as a string whenever
  /// the user makes changes to the input field.
  final Function(dynamic value)? onChanged;

  /// Creates the state for this widget.
  ///
  /// Returns a [_NyFormTextFieldState] instance that manages the text input state
  /// and handles user typing interactions.
  @override
  // ignore: no_logic_in_create_state
  createState() => _NyFormTextFieldState(field);

  /// Provides access to state management actions for this text field widget.
  ///
  /// Use this method to get a [FormTextFieldStateActions] instance that allows
  /// external components to interact with the text field's state, such as
  /// clearing the text or programmatically updating the value.
  ///
  /// [stateName] should match the state identifier used when registering the widget.
  static FormTextFieldStateActions stateActions(String stateName) =>
      FormTextFieldStateActions(stateName);
}

/// Provides state management actions for [NyFormTextField] widgets.
///
/// This class extends [FormStateActions] to provide text field-specific state operations
/// such as clearing the input, setting text values, or triggering validation.
/// Use [NyFormTextField.stateActions] to obtain an instance of this class.
class FormTextFieldStateActions extends FormStateActions {
  /// Creates a [FormTextFieldStateActions] instance for the specified state.
  ///
  /// [state] should be the state name identifier that corresponds to the
  /// text field widget you want to control.
  FormTextFieldStateActions(super.state);
}

class _NyFormTextFieldState extends FieldBaseState<NyFormTextField> {
  _NyFormTextFieldState(super.field) {
    stateName = this.field.stateKey;
  }

  /// Get the style from the field
  @override
  FieldStyleTextField get style {
    return (widget.field.style as FieldStyleTextField?) ??
        FieldStyleTextField();
  }

  @override
  Widget view(BuildContext context) {
    return InputField.fromFieldStyleText(
      field: widget.field,
      formValidator: widget.field.validator,
      style: style,
      onChanged: (String value) {
        widget.field.value = value;
      },
    );
  }
}
