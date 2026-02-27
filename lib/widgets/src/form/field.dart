import 'dart:async';
import 'dart:math';

import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '/helpers/ny_helpers.dart';
import '/widgets/ny_widgets.dart';
import '/localization/ny_localization.dart';
import 'package:recase/recase.dart';

/// Represents a form field with configuration, validation, and state management capabilities.
///
/// [Field] is the core class that defines form field behavior, appearance, and data handling.
/// It supports various field types including text, dropdowns, checkboxes, dates, and more.
/// Each field can have validation rules, styling, and custom widgets attached.
///
/// Example usage:
/// ```dart
/// final nameField = Field.text('name',
///   value: 'John Doe',
///   validator: FormValidator().notEmpty()
/// );
///
/// final countryField = Field.picker('country',
///   options: FormCollection.from({'US': 'United States'}),
///   value: 'US'
/// );
/// ```
class Field {
  /// The visual styling configuration for this field.
  ///
  /// Defines appearance properties like colors, fonts, spacing, and other
  /// visual characteristics specific to the field type.
  FieldStyle? style;

  /// Updates the styling configuration for this field.
  ///
  /// [style] can be null to reset to default styling, or a [FieldStyle]
  /// subclass appropriate for the field type.
  void setStyle(FieldStyle? style) {
    this.style = style;
  }

  /// The unique identifier for this field within a form.
  ///
  /// Used to distinguish this field from others and serves as the default
  /// label text if no custom label is provided.
  late String key;

  /// Optional custom display label for this field.
  ///
  /// If not provided, the [key] will be converted to title case and used
  /// as the display label. Supports localization through the `.tr()` extension.
  String? label;

  /// The current data value stored in this field.
  dynamic _value;

  /// Sets the field value and triggers the [onChanged] callback if defined.
  ///
  /// This setter automatically notifies listeners when the value changes,
  /// enabling reactive form behavior and validation triggers.
  set value(dynamic value) {
    _value = value;
    if (onChanged != null) {
      onChanged!(value);
    }
  }

  /// Gets the current field value.
  ///
  /// Returns the raw data value stored in this field, which may be
  /// of any type depending on the field configuration.
  dynamic get value => _value;

  /// Directly sets the field value and updates the UI widget.
  ///
  /// Use this method when you need to set the value programmatically.
  /// This will update both the internal value and the displayed widget.
  void setValue(dynamic value) {
    _value = value;
    _updateWidgetValue(value);
  }

  /// Sets the field value without triggering UI widget updates.
  /// Used during hot reload to preserve values before the widget tree rebuilds.
  void restoreValue(dynamic value) {
    _value = value;
  }

  /// Returns the unwrapped field widget (handles IgnorePointer wrapper).
  Widget? _getUnwrappedWidget() {
    if (widget == null) return null;
    if (widget is IgnorePointer) {
      return (widget as IgnorePointer).child;
    }
    return widget;
  }

  /// Returns the state actions for the field widget type.
  FormStateActions? _getFieldStateActions() {
    final fieldWidget = _getUnwrappedWidget();
    if (fieldWidget == null) return null;

    if (fieldWidget is NyFormTextField) {
      return InputField.stateActions(stateKey);
    } else if (fieldWidget is NyFormCheckbox) {
      return NyFormCheckbox.stateActions(stateKey);
    } else if (fieldWidget is NyFormSwitchBox) {
      return NyFormSwitchBox.stateActions(stateKey);
    } else if (fieldWidget is NyFormDateTimePicker) {
      return NyFormDateTimePicker.stateActions(stateKey);
    } else if (fieldWidget is NyFormChip) {
      return NyFormChip.stateActions(stateKey);
    } else if (fieldWidget is NyFormPicker) {
      return NyFormPicker.stateActions(stateKey);
    } else if (fieldWidget is NyFormRadio) {
      return NyFormRadio.stateActions(stateKey);
    } else if (fieldWidget is NyFormSlider) {
      return NyFormSlider.stateActions(stateKey);
    } else if (fieldWidget is NyFormRangeSlider) {
      return NyFormRangeSlider.stateActions(stateKey);
    } else if (fieldWidget is NyFormBuilder) {
      return NyFormBuilder.stateActions(stateKey);
    }
    return null;
  }

  /// Updates the widget's displayed value via state actions.
  void _updateWidgetValue(dynamic value) {
    _getFieldStateActions()?.setValue(value);
  }

  /// Validation rules applied to this field.
  ///
  /// Contains the validation logic that will be executed when the form
  /// is validated. Can include built-in rules like required, email format,
  /// length constraints, or custom validation functions.
  FormValidator? validator;

  /// Whether this field should automatically receive focus when the form loads.
  ///
  /// Only one field per form should typically have autofocus enabled.
  bool autofocus;

  /// Sample data used for development/testing purposes.
  ///
  /// This value can be used to populate the field with realistic test data
  /// during development or demo scenarios.
  String? dummyData;

  /// Returns the display name for this field.
  ///
  /// Uses the [label] if provided, otherwise converts the [key] to title case.
  /// Automatically applies localization through the `.tr()` extension.
  String get name => label?.tr() ?? key.titleCase.tr();

  /// Optional widget to display above the field input.
  ///
  /// Can be used for additional context, instructions, or custom UI elements
  /// that should appear before the main field widget.
  Widget? header;

  /// Optional widget to display below the field input.
  ///
  /// Commonly used for help text, validation messages, or additional
  /// actions related to the field.
  Widget? footer;

  /// Custom text styling for the field title/label.
  ///
  /// If not provided, the default theme styling will be applied.
  TextStyle? titleStyle;

  /// Controls the visibility of this field in the form.
  ///
  /// When `true`, the field will not be rendered in the UI but may still
  /// participate in form validation and data collection.
  bool? hidden = false;

  /// Controls whether the field accepts user input.
  ///
  /// When `true`, the field displays its value but prevents user interaction.
  /// Useful for displaying calculated or locked values.
  bool? readOnly;

  /// Custom widget to render instead of the default field widget.
  ///
  /// When provided, this widget completely replaces the standard field
  /// rendering. Use this for completely custom field implementations.
  Widget? widget;

  /// Stream controller for field update notifications.
  ///
  /// Used internally by the form system to broadcast changes and
  /// coordinate field updates across the form.
  StreamController? updated;

  /// Configures the stream controller for field updates.
  ///
  /// [updated] is the stream controller that will receive notifications
  /// when this field's value or state changes.
  void setUpdated(StreamController? updated) {
    this.updated = updated;
  }

  /// Callback function invoked when the field value changes.
  ///
  /// This function is called whenever the user interacts with the field
  /// or when the value is programmatically changed through the [value] setter.
  Function(dynamic value)? onChanged;

  /// Generates a unique state key for this field.
  ///
  /// The state key is used by the widget system to track and manage
  /// the field's state across rebuilds. Based on the field's [key] in snake_case.
  String get stateKey => 'form_field_${key.snakeCase}';

  /// Makes this field invisible in the form UI.
  ///
  /// Hidden fields are not rendered but may still participate in
  /// form validation and data collection processes.
  void hide() {
    hidden = true;
    _cachedField = null;
  }

  /// Makes this field visible in the form UI.
  ///
  /// Shows a previously hidden field by setting [hidden] to false.
  void show() {
    hidden = false;
    _cachedField = null;
  }

  /// Generates a random key for internal use.
  ///
  /// Used internally when creating unique identifiers for field instances.
  String _randomKey() {
    return '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(1000000)}';
  }

  /// Validates the current field value against configured validation rules.
  ///
  /// Returns a [FormValidationResult] containing validation results,
  /// or `null` if no validator is configured or validation passes.
  FormValidationResult? validate() {
    validator?.setAttribute(name);
    if (validator != null) {
      return validator!.check(_value);
    }
    return null;
  }

  /// Set the onChanged callback for the field
  void setOnChanged(Function(dynamic value)? onChanged) {
    this.onChanged = (dynamic changedValue) {
      _value = changedValue;
      if (!(updated?.isClosed ?? true)) {
        updated?.add((this, changedValue));
      }
      if (onChanged != null) {
        onChanged(changedValue);
      }
    };
  }

  Widget? _cachedField;
  bool? _cachedReadOnly;
  bool? _cachedHidden;

  /// Get the cast of the field
  Widget? get field {
    if (widget == null) {
      throw Exception("Field widget is not set");
    }

    if (hidden ?? false) {
      return null;
    }

    final currentReadOnly = readOnly ?? false;
    if (_cachedField != null &&
        _cachedReadOnly == currentReadOnly &&
        _cachedHidden == hidden) {
      return _cachedField;
    }

    _cachedReadOnly = currentReadOnly;
    _cachedHidden = hidden;
    _cachedField = IgnorePointer(ignoring: currentReadOnly, child: widget!);
    return _cachedField;
  }

  /// Clear the value of the field
  void clear() {
    value = null;
    _getFieldStateActions()?.clear();
  }

  /// Field.text is a constructor that helps in managing text fields
  Field.text(
    this.key, {
    this.label,
    String? value,
    this.validator,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.hidden = false,
    this.readOnly,
    FieldStyleTextField? style,
    Function(dynamic value)? onChanged,
  }) : _value = value,
       this.style = style ?? FieldStyleTextField() {
    setOnChanged(onChanged);
    widget = NyFormTextField.fromField(this);
  }

  /// Field.currency is a constructor that helps in managing currency fields
  Field.currency(
    this.key, {
    this.label,
    required String currency,
    String? value,
    this.validator,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.hidden = false,
    this.readOnly,
    Function(dynamic value)? onChanged,
    FieldStyleTextField? style,
  }) : _value = value,
       this.style = style ?? FieldStyleTextField() {
    CurrencyMeta currencyMeta = CurrencyInputMatcher.getCurrencyMeta(
      "currency:" + currency,
      value: value ?? dummyData ?? "0",
      onChanged: onChanged,
    );

    this.style = (this.style as FieldStyleTextField).copyWith(
      type: "currency",
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [currencyMeta.formatter],
    );

    _value = currencyMeta.initialValue;
    dummyData = null;

    setOnChanged(onChanged);
    widget = NyFormTextField.fromField(this);
  }

  /// Field.password is a constructor that helps in managing password fields
  Field.password(
    this.key, {
    this.label,
    String? value,
    this.validator,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.hidden = false,
    bool viewable = false,
    this.readOnly,
    Function(dynamic value)? onChanged,
    FieldStyleTextField? style,
  }) : _value = value,
       this.style = style ?? FieldStyleTextField.password() {
    this.style = (this.style as FieldStyleTextField).copyWith(
      passwordViewable: viewable,
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
      obscuringCharacter: '*',
      passwordVisible: viewable,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
    );

    setOnChanged(onChanged);
    widget = NyFormTextField.fromField(this);
  }

  /// Field.email is a constructor that helps in managing password fields
  Field.email(
    this.key, {
    this.label,
    String? value,
    this.validator,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.hidden = false,
    this.readOnly,
    Function(dynamic value)? onChanged,
    FieldStyleTextField? style,
  }) : _value = value,
       this.style = style ?? FieldStyleTextField.emailAddress() {
    this.style = (this.style as FieldStyleTextField).copyWith(
      keyboardType: TextInputType.emailAddress,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\s')),
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._+-]')),
      ],
    );

    setOnChanged(onChanged);
    widget = NyFormTextField.fromField(this);
  }

  /// Field.capitalizeWords is a constructor that helps in managing capitalizeWords fields
  Field.custom(
    this.key, {
    required NyFieldStatefulWidget child,
    this.label,
    dynamic value,
    this.validator,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.hidden = false,
    this.readOnly,
    FieldStyle? style,
    Function(dynamic value)? onChanged,
  }) : _value = value,
       this.style = style {
    setOnChanged(onChanged);
    widget = child;
  }

  /// Field.capitalizeWords is a constructor that helps in managing capitalizeWords fields
  Field.capitalizeWords(
    this.key, {
    this.label,
    String? value,
    this.validator,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.hidden = false,
    this.readOnly,
    Function(dynamic value)? onChanged,
    FieldStyleTextField? style,
  }) : _value = value,
       this.style = style ?? FieldStyleTextField() {
    this.style = (this.style as FieldStyleTextField).copyWith(
      type: "capitalizeWords",
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]")),
      ],
      textCapitalization: TextCapitalization.words,
    );
    setOnChanged(onChanged);
    widget = NyFormTextField.fromField(this);
  }

  /// Field.capitalizeSentences is a constructor that helps in managing capitalizeSentences fields
  Field.capitalizeSentences(
    this.key, {
    this.label,
    String? value,
    this.validator,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.hidden = false,
    this.readOnly,
    FieldStyleTextField? style,
    Function(dynamic value)? onChanged,
  }) : _value = value,
       this.style = style ?? FieldStyleTextField() {
    this.style = (this.style as FieldStyleTextField).copyWith(
      type: "capitalizeSentences",
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]")),
      ],
      textCapitalization: TextCapitalization.sentences,
    );

    setOnChanged(onChanged);
    widget = NyFormTextField.fromField(this);
  }

  /// Field.picker is a constructor that helps in managing picker fields
  Field.picker(
    this.key, {
    this.label,
    dynamic value,
    this.validator,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.hidden = false,
    this.readOnly,
    FormCollection options = const FormCollection.empty(),
    FieldStylePicker? style,
    Function(dynamic value)? onChanged,
  }) : this.style = style ?? FieldStylePicker(),
       _value = value {
    setOnChanged(onChanged);
    widget = NyFormPicker.fromField(this, options: options);
  }

  /// Field.widget is a constructor that helps in managing widget fields
  Field.widget({required Widget child}) : autofocus = false {
    widget = child;
    key = _randomKey();
  }

  /// Field.radio is a constructor that helps in managing radio fields
  Field.radio(
    this.key, {
    this.label,
    dynamic value,
    this.validator,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.hidden = false,
    this.readOnly,
    FormCollection options = const FormCollection.empty(),
    FieldStyleRadio? style,
    Function(dynamic value)? onChanged,
  }) : _value = value,
       this.style = style {
    setOnChanged(onChanged);
    widget = NyFormRadio.fromField(this, options: options);
  }

  /// Field.number is a constructor that helps in managing number fields
  Field.number(
    this.key, {
    this.label,
    int? value,
    this.validator,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.hidden = false,
    this.readOnly,
    bool decimal = false,
    Function(dynamic value)? onChanged,
    FieldStyleTextField? style,
  }) : _value = value,
       this.style = style ?? FieldStyleTextField() {
    this.style = (this.style as FieldStyleTextField).copyWith(
      type: "number",
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      inputFormatters: decimal
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
          : [FilteringTextInputFormatter.digitsOnly],
    );

    setOnChanged(onChanged);
    widget = NyFormTextField.fromField(this);
  }

  /// Field.mask is a constructor that helps in managing mask fields
  Field.mask(
    this.key, {
    this.label,
    dynamic value,
    this.validator,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.hidden = false,
    this.readOnly,
    Widget? prefixIcon,
    bool clearable = false,
    Widget? clearIcon,
    required String? mask,
    String match = r'[\w\d]',
    bool? maskReturnValue = false,
    FieldStyleTextField? style,
    Function(dynamic value)? onChanged,
  }) : _value = value,
       this.style = style ?? FieldStyleTextField() {
    setOnChanged(onChanged);

    this.style = (this.style as FieldStyleTextField).copyWith(
      maskedReturnValue: maskReturnValue,
      inputFormatters: [
        MaskTextInputFormatter(
          mask: mask,
          filter: {"#": RegExp(match)},
          type: MaskAutoCompletionType.lazy,
        ),
      ],
    );

    widget = NyFormTextField.fromField(this);
  }

  /// Field.url is a constructor that helps in managing url fields
  Field.url(
    this.key, {
    this.label,
    String? value,
    this.validator,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.hidden = false,
    this.readOnly,
    Function(dynamic value)? onChanged,
    FieldStyleTextField? style,
  }) : _value = value,
       this.style = style ?? FieldStyleTextField() {
    this.style = (this.style as FieldStyleTextField).copyWith(
      type: "url",
      keyboardType: TextInputType.url,
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(
            r'[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&//=]*)',
          ),
        ),
      ],
    );

    setOnChanged(onChanged);
    widget = NyFormTextField.fromField(this);
  }

  /// Field.textArea is a constructor that helps in managing textArea fields
  Field.textArea(
    this.key, {
    this.label,
    String? value,
    this.validator,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.hidden = false,
    this.readOnly,
    FieldStyleTextField? style,
    Function(dynamic value)? onChanged,
  }) : _value = value,
       this.style = style ?? FieldStyleTextField() {
    setOnChanged(onChanged);
    widget = NyFormTextField.fromField(this);
  }

  /// Field.phoneNumber is a constructor that helps in managing phoneNumber fields
  Field.phoneNumber(
    this.key, {
    this.label,
    String? value,
    this.validator,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.hidden = false,
    this.readOnly,
    FieldStyleTextField? style,
    Function(dynamic value)? onChanged,
  }) : _value = value,
       this.style = (style ?? FieldStyleTextField()) {
    this.style = (this.style as FieldStyleTextField).copyWith(
      keyboardType: TextInputType.phone,
      inputFormatters: [PhoneInputFormatter()],
      // onChanged: onChanged,
    );

    setOnChanged(onChanged);
    widget = NyFormTextField.fromField(this);
  }

  /// Field.checkbox is a constructor that helps in managing textArea fields
  Field.checkbox(
    this.key, {
    this.label,
    dynamic value,
    this.validator,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.hidden = false,
    this.readOnly,
    FieldStyleCheckbox? style,
    Function(dynamic value)? onChanged,
  }) : _value = value,
       this.style = style ?? FieldStyleCheckbox() {
    setOnChanged(onChanged);
    widget = NyFormCheckbox.fromField(this);
  }

  /// Field.switchBox is a constructor that helps in managing switch fields
  Field.switchBox(
    this.key, {
    this.label,
    dynamic value,
    this.validator,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.hidden = false,
    this.readOnly,
    FieldStyleSwitchBox? style,
    Function(dynamic value)? onChanged,
  }) : _value = value,
       this.style = style ?? FieldStyleSwitchBox() {
    setOnChanged(onChanged);
    widget = NyFormSwitchBox.fromField(this);
  }

  /// Field.datetime is a constructor that helps in managing datetime fields
  Field.datetime(
    this.key, {
    this.label,
    dynamic value,
    this.validator,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.hidden = false,
    this.readOnly,
    DateTime? firstDate,
    DateTime? lastDate,
    DateFormat? dateFormat,
    DateTime? initialPickerDateTime,
    FieldStyleDateTimePicker? style,
    Function(dynamic value)? onChanged,
  }) : _value = value,
       this.style =
           style ??
           FieldStyleDateTimePicker(mode: DateTimeFieldPickerMode.dateAndTime) {
    this.style = (this.style as FieldStyleDateTimePicker).copyWith(
      mode: DateTimeFieldPickerMode.dateAndTime,
      firstDate: firstDate,
      lastDate: lastDate,
      dateFormat: dateFormat,
      initialPickerDateTime: initialPickerDateTime,
    );
    setOnChanged(onChanged);
    widget = NyFormDateTimePicker.fromField(this);
  }

  /// Field.date is a constructor that helps in managing date fields
  Field.date(
    this.key, {
    this.label,
    dynamic value,
    this.validator,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.hidden = false,
    this.readOnly,
    DateTime? firstDate,
    DateTime? lastDate,
    DateFormat? dateFormat,
    DateTime? initialPickerDateTime,
    FieldStyleDateTimePicker? style,
    Function(dynamic value)? onChanged,
  }) : _value = value,
       this.style =
           style ??
           FieldStyleDateTimePicker(mode: DateTimeFieldPickerMode.date) {
    this.style = (this.style as FieldStyleDateTimePicker).copyWith(
      mode: DateTimeFieldPickerMode.date,
      firstDate: firstDate,
      lastDate: lastDate,
      dateFormat: dateFormat,
      initialPickerDateTime: initialPickerDateTime,
    );
    setOnChanged(onChanged);
    widget = NyFormDateTimePicker.fromField(this);
  }

  /// Field.chips is a constructor that helps in managing chips fields
  Field.chips(
    this.key, {
    this.label,
    dynamic value,
    this.validator,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.hidden = false,
    this.readOnly,
    FormCollection options = const FormCollection.empty(),
    Function(dynamic value)? onChanged,
    FieldStyleChip? style,
  }) : style = style ?? FieldStyleChip(),
       _value = value {
    setOnChanged(onChanged);
    widget = NyFormChip.fromField(this, options: options);
  }

  /// Field.slider is a constructor that helps in managing slider fields
  Field.slider(
    this.key, {
    this.label,
    double? value,
    this.validator,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.hidden = false,
    this.readOnly,
    Function(dynamic value)? onChanged,
    FieldStyleSlider? style,
  }) : _value = value,
       this.style = style ?? FieldStyleSlider() {
    setOnChanged(onChanged);
    widget = NyFormSlider.fromField(this);
  }

  /// Field.rangeSlider is a constructor that helps in managing range slider fields
  Field.rangeSlider(
    this.key, {
    this.label,
    RangeValues? value,
    this.validator,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.hidden = false,
    this.readOnly,
    Function(dynamic value)? onChanged,
    FieldStyleRangeSlider? style,
  }) : _value = value,
       this.style = style ?? FieldStyleRangeSlider() {
    setOnChanged(onChanged);
    widget = NyFormRangeSlider.fromField(this);
  }

  /// Field.builder is a constructor that lets developers create custom form
  /// fields inline using a builder function.
  ///
  /// The [builder] receives the [BuildContext], an [onChanged] callback to
  /// report value changes to the form, and the [currentValue] of the field.
  ///
  /// Example:
  /// ```dart
  /// Field.builder(
  ///   'favorite_color',
  ///   builder: (context, onChanged, value) {
  ///     return ColorPicker(
  ///       selected: value,
  ///       onColorChanged: (color) => onChanged(color),
  ///     );
  ///   },
  ///   value: Colors.blue,
  ///   validator: FormValidator().notEmpty(),
  /// )
  /// ```
  Field.builder(
    this.key, {
    required NyFieldBuilder builder,
    this.label,
    dynamic value,
    this.validator,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.hidden = false,
    this.readOnly,
    FieldStyle? style,
    Function(dynamic value)? onChanged,
  }) : _value = value,
       this.style = style {
    setOnChanged(onChanged);
    widget = NyFormBuilder.fromField(this, builder: builder);
  }
}
