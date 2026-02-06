import 'package:flutter/material.dart';
import '/widgets/ny_widgets.dart';

/// A checkbox widget for forms that allows users to toggle a boolean value.
///
/// [NyFormCheckbox] provides a Material Design checkbox interface where users can
/// toggle between checked (true) and unchecked (false) states. The widget displays
/// a checkbox with an associated label.
///
/// Example usage:
/// ```dart
/// NyFormCheckbox(
///   name: 'agree_terms',
///   value: false,
///   onChanged: (value) => print('Checkbox toggled: $value'),
/// )
/// ```
class NyFormCheckbox extends NyFieldStatefulWidget {
  /// Creates a [NyFormCheckbox] widget with the specified configuration.
  ///
  /// The [name] identifies the field and serves as the label text if no custom
  /// title is provided in the style. Set [value] for the initial checked state
  /// and customize appearance with [style].
  NyFormCheckbox({
    super.key,
    required String name,
    bool? value,
    FieldStyleCheckbox? style,
    this.onChanged,
  }) : field = Field.checkbox(name, value: value, style: style);

  /// Creates a [NyFormCheckbox] widget from an existing [Field] instance.
  ///
  /// This constructor is useful when the field configuration is already defined
  /// elsewhere in your form setup.
  NyFormCheckbox.fromField(this.field, {super.key})
    : onChanged = field.onChanged;

  /// The field configuration that defines the checkbox behavior and properties.
  final Field field;

  @override
  Field? get formField => field;

  /// Callback function invoked when the user toggles the checkbox.
  ///
  /// The callback receives a boolean value (true for checked, false for unchecked)
  /// whenever the user taps the checkbox to change its state.
  final Function(dynamic value)? onChanged;

  /// Creates the state for this widget.
  ///
  /// Returns a [_NyFormCheckboxState] instance that manages the checkbox toggle
  /// state and handles user interactions.
  @override
  // ignore: no_logic_in_create_state
  createState() => _NyFormCheckboxState(field);

  /// Provides access to state management actions for this checkbox widget.
  ///
  /// Use this method to get a [FormCheckboxStateActions] instance that allows
  /// external components to interact with the checkbox's state.
  ///
  /// [stateName] should match the state identifier used when registering the widget.
  static FormCheckboxStateActions stateActions(String stateName) =>
      FormCheckboxStateActions(stateName);
}

/// Provides state management actions for [NyFormCheckbox] widgets.
///
/// This class extends [FormStateActions] to provide checkbox-specific state operations
/// such as clearing the checkbox (unchecking it), setting values programmatically,
/// or accessing the current checked state. Use [NyFormCheckbox.stateActions] to obtain an instance.
class FormCheckboxStateActions extends FormStateActions {
  /// Creates a [FormCheckboxStateActions] instance for the specified state.
  ///
  /// [state] should be the state name identifier that corresponds to the
  /// checkbox widget you want to control.
  FormCheckboxStateActions(super.state);
}

class _NyFormCheckboxState extends FieldBaseState<NyFormCheckbox> {
  dynamic currentValue;

  _NyFormCheckboxState(super.field) {
    stateName = this.field.stateKey;
  }

  /// Get the style from the field
  FieldStyleCheckbox get style {
    return widget.field.style as FieldStyleCheckbox;
  }

  @override
  Map<String, Function> get stateActions => {
    "clear": () {
      currentValue = false;
      setState(() {});
    },
  };

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
    Widget? title = style.title;

    if (title == null ||
        (title is Text && (title.data == null || title.data!.isEmpty))) {
      title = Text(
        widget.field.name,
        style:
            style.titleTextStyle ??
            TextStyle(
              color: color(light: Colors.black, dark: Colors.white),
            ),
      );
    }

    Color? fillColorMetaData = color(
      light: style.fillColor ?? Colors.transparent,
      dark: Colors.black,
    );
    WidgetStateProperty<Color?>? fillColor = WidgetStateProperty.all(
      fillColorMetaData,
    );

    Color? overlayColorMetaData = style.overlayColor;
    WidgetStateProperty<Color?>? overlayColor;
    if (overlayColorMetaData != null) {
      overlayColor = WidgetStateProperty.all(overlayColorMetaData);
    }

    return CheckboxListTile(
      mouseCursor: style.mouseCursor,
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
      controlAffinity: style.controlAffinity,
      activeColor: color(
        light: style.activeColor ?? Colors.black,
        dark: Colors.black,
      ),
      fillColor: fillColor,
      checkColor: color(
        light: style.checkColor ?? Colors.black,
        dark: Colors.white,
      ),
      hoverColor: style.hoverColor,
      overlayColor: overlayColor,
      splashRadius: style.splashRadius,
      materialTapTargetSize: style.materialTapTargetSize,
      visualDensity: style.visualDensity,
      focusNode: style.focusNode,
      autofocus: style.autofocus,
      shape: style.shape,
      side:
          style.side ??
          whenTheme(
            light: () => null,
            dark: () => BorderSide(
              width: 2,
              color: color(light: Colors.black, dark: Colors.white),
            ),
          ),
      isError: style.isError,
      enabled: style.enabled,
      tileColor: style.tileColor,
      subtitle: style.subtitle,
      isThreeLine: style.isThreeLine,
      dense: style.dense,
      secondary: style.secondary,
      selected: style.selected,
      contentPadding: style.contentPadding,
      tristate: style.tristate,
      checkboxShape: style.checkboxShape,
      selectedTileColor: style.selectedTileColor,
      onFocusChange: style.onFocusChange,
      enableFeedback: style.enableFeedback,
      checkboxSemanticLabel: style.checkboxSemanticLabel,
    );
  }
}
