import 'package:flutter/material.dart';
import 'field_slider_theme.dart';
import '/widgets/ny_widgets.dart';

/// A slider widget for forms that allows users to select a value from a range.
///
/// [NyFormSlider] provides a Material Design slider interface where users can
/// select a value by dragging a thumb along a track. The widget displays
/// the current value and allows customization of min/max values, divisions, and styling.
///
/// Example usage:
/// ```dart
/// NyFormSlider(
///   name: 'volume',
///   value: 50.0,
///   min: 0.0,
///   max: 100.0,
///   divisions: 10,
///   onChanged: (value) => print('Slider value: $value'),
/// )
/// ```
class NyFormSlider extends NyFieldStatefulWidget {
  /// Creates a [NyFormSlider] widget with the specified configuration.
  ///
  /// The [name] identifies the field and serves as the label text if no custom
  /// title is provided in the style. Set [value] for the initial slider position
  /// and customize appearance with [style].
  NyFormSlider({
    super.key,
    required String name,
    double? value,
    FieldStyleSlider? style,
    this.onChanged,
  }) : field = Field.slider(name, value: value, style: style);

  /// Creates a [NyFormSlider] widget from an existing [Field] instance.
  ///
  /// This constructor is useful when the field configuration is already defined
  /// elsewhere in your form setup.
  NyFormSlider.fromField(this.field, {super.key}) : onChanged = field.onChanged;

  /// The field configuration that defines the slider behavior and properties.
  final Field field;

  @override
  Field? get formField => field;

  /// Callback function invoked when the user changes the slider value.
  ///
  /// The callback receives a double value representing the current slider position
  /// whenever the user drags the slider thumb to a new position.
  final Function(dynamic value)? onChanged;

  /// Creates the state for this widget.
  ///
  /// Returns a [_NyFormSliderState] instance that manages the slider value
  /// and handles user interactions.
  @override
  // ignore: no_logic_in_create_state
  createState() => _NyFormSliderState(field);

  /// Provides access to state management actions for this slider widget.
  ///
  /// Use this method to get a [FormSliderStateActions] instance that allows
  /// external components to interact with the slider's state.
  ///
  /// [stateName] should match the state identifier used when registering the widget.
  static FormSliderStateActions stateActions(String stateName) =>
      FormSliderStateActions(stateName);
}

/// Provides state management actions for [NyFormSlider] widgets.
///
/// This class extends [FormStateActions] to provide slider-specific state operations
/// such as clearing the slider (resetting to minimum value), setting values programmatically,
/// or accessing the current slider position. Use [NyFormSlider.stateActions] to obtain an instance.
class FormSliderStateActions extends FormStateActions {
  /// Creates a [FormSliderStateActions] instance for the specified state.
  ///
  /// [state] should be the state name identifier that corresponds to the
  /// slider widget you want to control.
  FormSliderStateActions(super.state);
}

class _NyFormSliderState extends FieldBaseState<NyFormSlider> {
  double currentValue = 0.0;

  _NyFormSliderState(super.field) {
    stateName = field.stateKey;
  }

  /// Get the style from the field
  @override
  FieldStyleSlider get style {
    return widget.field.style as FieldStyleSlider;
  }

  @override
  Map<String, Function> get stateActions => {
    "clear": () {
      currentValue = style.min;
      setState(() {});
    },
  };

  @override
  void initState() {
    super.initState();
    dynamic fieldValue = widget.field.value;

    if (fieldValue is String) {
      currentValue = double.tryParse(fieldValue) ?? style.min;
    } else if (fieldValue is num) {
      currentValue = fieldValue.toDouble();
    } else {
      currentValue = style.min;
    }

    // Ensure the value is within bounds
    currentValue = currentValue.clamp(style.min, style.max);
  }

  @override
  Widget view(BuildContext context) {
    final NyFieldColors colors = NyFieldColors.of(context);
    Widget title =
        style.title ??
        Text(
          widget.field.name,
          style: widget.field.titleStyle ?? colors.labelStyle,
        );

    final Widget value = Text(
      style.valueFormatter(currentValue),
      style:
          style.valueTextStyle ??
          TextStyle(
            color: colors.accentText,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
    );
    // The value sits at the end of the title's row.
    final bool valueBesideTitle = style.showTitle && style.showValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (valueBesideTitle)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: title),
              value,
            ],
          )
        else if (style.showTitle)
          title,
        if (style.showTitle && style.titleSpacing > 0)
          SizedBox(height: style.titleSpacing),
        SliderTheme(
          data: fieldSliderTheme(
            context,
            colors,
            active: style.activeColor,
            inactive: style.inactiveColor,
            thumb: style.thumbColor,
          ),
          child: Slider(
            value: currentValue,
            min: style.min,
            max: style.max,
            divisions: style.divisions,
            label: style.showLabel ? style.labelFormatter(currentValue) : null,
            onChanged: style.enabled
                ? (value) {
                    setState(() {
                      currentValue = value;
                      if (widget.onChanged != null) {
                        widget.onChanged!(value);
                      }
                    });
                  }
                : null,
            focusNode: style.focusNode,
            autofocus: style.autofocus,
            mouseCursor: style.mouseCursor,
            overlayColor: getWidgetStatePropertyColor(style.overlayColor),
            semanticFormatterCallback: style.semanticFormatterCallback,
            allowedInteraction: style.allowedInteraction,
          ),
        ),
        if (style.showValue && !valueBesideTitle)
          Padding(
            padding: EdgeInsets.only(top: style.valueSpacing),
            child: value,
          ),
      ],
    );
  }
}
