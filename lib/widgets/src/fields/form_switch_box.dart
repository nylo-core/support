import 'package:flutter/material.dart';
import '/widgets/ny_widgets.dart';

/// A switch toggle widget for forms that allows users to toggle a boolean value.
///
/// [NyFormSwitchBox] provides a Material Design switch interface where users can
/// toggle between on (true) and off (false) states. The switch displays as a
/// sliding toggle control that users can tap or slide to change state.
///
/// Example usage:
/// ```dart
/// NyFormSwitchBox(
///   name: 'notifications_enabled',
///   value: true,
///   onChanged: (value) => print('Switch toggled: $value'),
/// )
/// ```
class NyFormSwitchBox extends NyFieldStatefulWidget {
  /// Creates a [NyFormSwitchBox] widget with the specified configuration.
  ///
  /// The [name] identifies the field. Set [value] for the initial switch state
  /// (true for on, false for off) and customize appearance with [style].
  NyFormSwitchBox({
    super.key,
    required String name,
    bool? value,
    FieldStyleSwitchBox? style,
    this.onChanged,
  }) : field = Field.switchBox(name, value: value, style: style);

  /// Creates a [NyFormSwitchBox] widget from an existing [Field] instance.
  ///
  /// This constructor is useful when the field configuration is already defined
  /// elsewhere in your form setup.
  NyFormSwitchBox.fromField(this.field, {super.key})
    : onChanged = field.onChanged;

  /// The field configuration that defines the switch behavior and properties.
  final Field field;

  @override
  Field? get formField => field;

  /// Callback function invoked when the user toggles the switch.
  ///
  /// The callback receives a boolean value (true for on, false for off)
  /// whenever the user interacts with the switch to change its state.
  final Function(dynamic value)? onChanged;

  /// Creates the state for this widget.
  ///
  /// Returns a [_NyFormSwitchBoxState] instance that manages the switch toggle
  /// state and handles user interactions.
  @override
  // ignore: no_logic_in_create_state
  createState() => _NyFormSwitchBoxState(field);

  /// Provides access to state management actions for this switch widget.
  ///
  /// Use this method to get a [FormSwitchBoxStateActions] instance that allows
  /// external components to interact with the switch's state.
  ///
  /// [stateName] should match the state identifier used when registering the widget.
  static FormSwitchBoxStateActions stateActions(String stateName) =>
      FormSwitchBoxStateActions(stateName);
}

/// Provides state management actions for [NyFormSwitchBox] widgets.
///
/// This class extends [FormStateActions] to provide switch-specific state operations
/// such as clearing the switch (turning it off), setting values programmatically,
/// or accessing the current on/off state. Use [NyFormSwitchBox.stateActions] to obtain an instance.
class FormSwitchBoxStateActions extends FormStateActions {
  /// Creates a [FormSwitchBoxStateActions] instance for the specified state.
  ///
  /// [state] should be the state name identifier that corresponds to the
  /// switch widget you want to control.
  FormSwitchBoxStateActions(super.state);
}

class _NyFormSwitchBoxState extends FieldBaseState<NyFormSwitchBox> {
  dynamic currentValue;

  _NyFormSwitchBoxState(super.field) {
    stateName = this.field.stateKey;
  }

  /// Get the style from the field
  @override
  FieldStyleSwitchBox get style {
    return widget.field.style as FieldStyleSwitchBox? ?? FieldStyleSwitchBox();
  }

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
  Map<String, Function> get stateActions => {
    "clear": () {
      setState(() {
        currentValue = false;
      });
    },
  };

  @override
  Widget view(BuildContext context) {
    Widget? title = style.title;

    title ??= Text(
      widget.field.name,
      style:
          style.titleTextStyle ??
          TextStyle(
            color: color(light: Colors.black, dark: Colors.white),
          ),
    );
    if (title is Text && (title.data == null || title.data!.isEmpty)) {
      title = Text(
        widget.field.name,
        style:
            style.titleTextStyle ??
            TextStyle(
              color: color(light: Colors.black, dark: Colors.white),
            ),
      );
    }

    Color? overlayColorMetaData = style.overlayColor;
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
      controlAffinity: style.controlAffinity,
      activeThumbColor: color(
        light: style.activeThumbColor ?? Theme.of(context).primaryColor,
        dark: Colors.black,
      ),
      hoverColor: style.hoverColor,
      overlayColor: overlayColor,
      splashRadius: style.splashRadius,
      materialTapTargetSize: style.materialTapTargetSize,
      visualDensity: style.visualDensity,
      focusNode: style.focusNode,
      autofocus: style.autofocus,
      shape: style.shape,
      tileColor: style.tileColor,
      subtitle: style.subtitle,
      isThreeLine: style.isThreeLine,
      dense: style.dense,
      secondary: style.secondary,
      selected: style.selected,
      contentPadding: style.contentPadding,
      selectedTileColor: style.selectedTileColor,
      onFocusChange: style.onFocusChange,
      enableFeedback: style.enableFeedback,
      activeThumbImage: style.activeThumbImage,
      onActiveThumbImageError: style.onActiveThumbImageError,
      inactiveThumbImage: style.inactiveThumbImage,
      onInactiveThumbImageError: style.onInactiveThumbImageError,
      thumbColor: getWidgetStatePropertyColor(style.thumbColor),
      trackColor: getWidgetStatePropertyColor(style.trackColor),
      trackOutlineColor: getWidgetStatePropertyColor(style.trackOutlineColor),
      thumbIcon: getWidgetStateProperty<Icon>(style.thumbIcon),
      activeTrackColor: style.activeTrackColor,
      inactiveThumbColor: style.inactiveThumbColor,
      inactiveTrackColor: style.inactiveTrackColor,
      dragStartBehavior: style.dragStartBehavior,
      mouseCursor: style.mouseCursor,
    );
  }
}
