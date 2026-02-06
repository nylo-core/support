import 'package:flutter/material.dart';
import '/widgets/ny_widgets.dart';

/// A range slider widget for forms that allows users to select a range of values.
///
/// [NyFormRangeSlider] provides a Material Design range slider interface where users can
/// select a range by dragging two thumbs along a track. The widget displays
/// the current range values and allows customization of min/max values, divisions, and styling.
///
/// Example usage:
/// ```dart
/// NyFormRangeSlider(
///   name: 'price_range',
///   values: RangeValues(10.0, 90.0),
///   min: 0.0,
///   max: 100.0,
///   divisions: 10,
///   onChanged: (values) => print('Range: ${values.start} - ${values.end}'),
/// )
/// ```
class NyFormRangeSlider extends NyFieldStatefulWidget {
  /// Creates a [NyFormRangeSlider] widget with the specified configuration.
  ///
  /// The [name] identifies the field and serves as the label text if no custom
  /// title is provided in the style. Set [values] for the initial range position
  /// and customize appearance with [style].
  NyFormRangeSlider({
    super.key,
    required String name,
    RangeValues? values,
    FieldStyleRangeSlider? style,
    this.onChanged,
  }) : field = Field.rangeSlider(name, value: values, style: style);

  /// Creates a [NyFormRangeSlider] widget from an existing [Field] instance.
  ///
  /// This constructor is useful when the field configuration is already defined
  /// elsewhere in your form setup.
  NyFormRangeSlider.fromField(this.field, {super.key})
    : onChanged = field.onChanged;

  /// The field configuration that defines the range slider behavior and properties.
  final Field field;

  @override
  Field? get formField => field;

  /// Callback function invoked when the user changes the range slider values.
  ///
  /// The callback receives a [RangeValues] object representing the current range
  /// whenever the user drags either thumb to a new position.
  final Function(dynamic value)? onChanged;

  /// Creates the state for this widget.
  ///
  /// Returns a [_NyFormRangeSliderState] instance that manages the range values
  /// and handles user interactions.
  @override
  // ignore: no_logic_in_create_state
  createState() => _NyFormRangeSliderState(field);

  /// Provides access to state management actions for this range slider widget.
  ///
  /// Use this method to get a [FormRangeSliderStateActions] instance that allows
  /// external components to interact with the range slider's state.
  ///
  /// [stateName] should match the state identifier used when registering the widget.
  static FormRangeSliderStateActions stateActions(String stateName) =>
      FormRangeSliderStateActions(stateName);
}

/// Provides state management actions for [NyFormRangeSlider] widgets.
///
/// This class extends [FormStateActions] to provide range slider-specific state operations
/// such as clearing the range slider (resetting to minimum range), setting values programmatically,
/// or accessing the current range values. Use [NyFormRangeSlider.stateActions] to obtain an instance.
class FormRangeSliderStateActions extends FormStateActions {
  /// Creates a [FormRangeSliderStateActions] instance for the specified state.
  ///
  /// [state] should be the state name identifier that corresponds to the
  /// range slider widget you want to control.
  FormRangeSliderStateActions(super.state);
}

class _NyFormRangeSliderState extends FieldBaseState<NyFormRangeSlider> {
  RangeValues currentValues = const RangeValues(0.0, 100.0);

  _NyFormRangeSliderState(super.field) {
    stateName = this.field.stateKey;
  }

  /// Get the style from the field
  FieldStyleRangeSlider get style {
    return widget.field.style as FieldStyleRangeSlider;
  }

  @override
  Map<String, Function> get stateActions => {
    "clear": () {
      currentValues = RangeValues(
        style.min,
        style.min + (style.max - style.min) * 0.1,
      );
      setState(() {});
    },
  };

  @override
  void initState() {
    super.initState();
    dynamic fieldValue = widget.field.value;

    if (fieldValue is RangeValues) {
      currentValues = fieldValue;
    } else {
      // Default to a 10% range starting from minimum
      double range = style.max - style.min;
      currentValues = RangeValues(style.min, style.min + range * 0.1);
    }

    // Ensure the values are within bounds
    currentValues = RangeValues(
      currentValues.start.clamp(style.min, style.max),
      currentValues.end.clamp(style.min, style.max),
    );
  }

  @override
  Widget view(BuildContext context) {
    Widget title =
        style.title ??
        Text(
          widget.field.name,
          style:
              widget.field.titleStyle ??
              TextStyle(
                color: color(light: Colors.black, dark: Colors.white),
              ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (style.showTitle) title,
        if (style.showTitle && style.titleSpacing > 0)
          SizedBox(height: style.titleSpacing),
        _buildRangeSlider(context),
        if (style.showValues)
          Padding(
            padding: EdgeInsets.only(top: style.valueSpacing),
            child: Text(
              style.valueFormatter(currentValues.start, currentValues.end),
              style:
                  style.valueTextStyle ??
                  TextStyle(
                    color: color(light: Colors.black54, dark: Colors.white70),
                    fontSize: 12,
                  ),
            ),
          ),
      ],
    );
  }

  Widget _buildRangeSlider(BuildContext context) {
    Widget slider = RangeSlider(
      values: currentValues,
      min: style.min,
      max: style.max,
      divisions: style.divisions,
      labels: style.showLabels
          ? RangeLabels(
              style.labelFormatter(currentValues.start),
              style.labelFormatter(currentValues.end),
            )
          : null,
      onChanged: style.enabled
          ? (values) {
              setState(() {
                currentValues = values;
                if (widget.onChanged != null) {
                  widget.onChanged!(values);
                }
              });
            }
          : null,
      activeColor: color(
        light: style.activeColor ?? Theme.of(context).primaryColor,
        dark: style.activeColor ?? Theme.of(context).primaryColor,
      ),
      inactiveColor: color(
        light: style.inactiveColor ?? Colors.grey[300],
        dark: style.inactiveColor ?? Colors.grey[700],
      ),
      overlayColor: getWidgetStatePropertyColor(style.overlayColor),
      mouseCursor: style.mouseCursor != null
          ? WidgetStateProperty.all(style.mouseCursor)
          : null,
      semanticFormatterCallback: style.semanticFormatterCallback,
    );

    if (style.thumbColor != null) {
      return SliderTheme(
        data: SliderTheme.of(context).copyWith(
          rangeThumbShape: RoundRangeSliderThumbShape(enabledThumbRadius: 10.0),
          thumbColor: style.thumbColor,
        ),
        child: slider,
      );
    }

    return slider;
  }
}
