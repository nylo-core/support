import 'package:flutter/material.dart';
import '/helpers/ny_helpers.dart';
import '/localization/ny_localization.dart';
import '/widgets/ny_widgets.dart';

/// A radio button group widget for forms that allows users to select a single option.
///
/// [NyFormRadio] provides a Material Design radio button interface where users can
/// select one option from the provided [FormCollection]. The widget displays all
/// options as radio buttons in a vertical list format.
///
/// Example usage:
/// ```dart
/// NyFormRadio(
///   name: 'gender',
///   options: FormCollection.from(['Male', 'Female', 'Other']),
///   selectedValue: 'Male',
///   onChanged: (value) => print('Selected: $value'),
/// )
/// ```
class NyFormRadio extends NyFieldStatefulWidget {
  /// Creates a [NyFormRadio] widget with the specified configuration.
  ///
  /// The [name] identifies the field and [options] provides the available choices.
  /// Optionally set [selectedValue] for initial selection and customize appearance with [style].
  NyFormRadio({
    super.key,
    required String name,
    required this.options,
    String? selectedValue,
    FieldStyleRadio? style,
    this.onChanged,
  }) : field = Field.radio(
         name,
         value: selectedValue,
         style: style,
         options: options,
       );

  /// Creates a [NyFormRadio] widget from an existing [Field] instance.
  ///
  /// This constructor is useful when the field configuration is already defined
  /// elsewhere in your form setup.
  NyFormRadio.fromField(this.field, {super.key, required this.options})
    : onChanged = field.onChanged;

  /// Collection of options that will be displayed as radio buttons.
  ///
  /// Each option in the collection will be rendered as a separate radio button
  /// with its label text. Only one option can be selected at a time.
  final FormCollection options;

  /// The field configuration that defines the radio button behavior and properties.
  final Field field;

  @override
  Field? get formField => field;

  /// Callback function invoked when the user selects a radio button option.
  ///
  /// The callback receives the value of the selected [FormOption] when the user
  /// taps on a radio button.
  final Function(dynamic value)? onChanged;

  /// Creates the state for this widget.
  ///
  /// Returns a [_NyFormRadioState] instance that manages the radio button selection
  /// state and handles user interactions.
  @override
  // ignore: no_logic_in_create_state
  createState() => _NyFormRadioState(field);

  /// Provides access to state management actions for this radio button widget.
  ///
  /// Use this method to get a [FormRadioStateActions] instance that allows
  /// external components to interact with the radio button group's state.
  ///
  /// [stateName] should match the state identifier used when registering the widget.
  static FormRadioStateActions stateActions(String stateName) =>
      FormRadioStateActions(stateName);
}

/// Provides state management actions for [NyFormRadio] widgets.
///
/// This class extends [FormStateActions] to provide radio button-specific state operations
/// such as clearing the selection, setting the selected option, or accessing current values.
/// Use [NyFormRadio.stateActions] to obtain an instance of this class.
class FormRadioStateActions extends FormStateActions {
  /// Creates a [FormRadioStateActions] instance for the specified state.
  ///
  /// [state] should be the state name identifier that corresponds to the
  /// radio button widget you want to control.
  FormRadioStateActions(super.state);

  /// Set the options for the radio group
  void setOptions(FormCollection options) {
    stateAction("setOptions", state: state, data: {"options": options});
  }
}

class _NyFormRadioState extends FieldBaseState<NyFormRadio> {
  dynamic currentValue;
  FormCollection? _options;

  _NyFormRadioState(super.field) {
    stateName = this.field.stateKey;
  }

  /// Get the style from the field
  @override
  FieldStyleRadio get style {
    return widget.field.style as FieldStyleRadio? ?? FieldStyleRadio();
  }

  @override
  Map<String, Function> get stateActions => {
    "clear": () {
      currentValue = null;
      setState(() {});
    },
    "setValue": (data) {
      currentValue = data["value"];
      widget.field.restoreValue(currentValue);
      setState(() {});
    },
    "setOptions": (data) {
      final options = data["options"];
      if (options is FormCollection) {
        _options = options;
        setState(() {});
      }
    },
  };

  @override
  void initState() {
    super.initState();

    dynamic fieldValue = widget.field.value;
    if (fieldValue is String && fieldValue.isNotEmpty) {
      currentValue = fieldValue;
    }
  }

  @override
  Widget view(BuildContext context) {
    FormCollection optionsValue = getOptions();
    List<FormOption> options = optionsValue.options;

    return RadioGroup<dynamic>(
      groupValue: currentValue,
      onChanged: (value) {
        setState(() {
          currentValue = value;
        });
        if (widget.onChanged == null) return;
        widget.onChanged!(currentValue);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (hideTitle() != true)
            Text(widget.field.name.tr(), style: titleStyle()),
          Spacing.vertical(style.titleSpacing),
          ...options.map((FormOption formOption) {
            return RadioListTile<dynamic>(
              title: Text(formOption.label.tr(), style: listTileStyle()),
              value: formOption.value,
              mouseCursor: getMouseCursor(),
              activeColor: getActiveColor(),
              fillColor: getFillColor(),
              hoverColor: getHoverColor(),
              overlayColor: getOverlayColor(),
              splashRadius: getSplashRadius(),
              contentPadding: getContentPadding(),
              shape: getShape(),
              tileColor: getTileColor(),
              selectedTileColor: getSelectedTileColor(),
            );
          }),
        ],
      ),
    );
  }

  /// Get the list of options from the field
  FormCollection getOptions() => _options ?? widget.options;

  /// Get the selected color
  Color? getSelectedTileColor() {
    return (style.selectedColor ??
            NyColor(light: Colors.grey.shade100, dark: surfaceColorDark))
        .toColor(context);
  }

  /// Get the tile color
  Color? getTileColor() {
    return (style.tileColor ??
            NyColor(light: Colors.transparent, dark: surfaceColorDark))
        .toColor(context);
  }

  /// Get the shape of the radio tile
  ShapeBorder? getShape() {
    return style.shape;
  }

  /// Get the content padding
  EdgeInsetsGeometry getContentPadding() {
    return style.contentPadding ?? const EdgeInsets.all(8.0);
  }

  /// Get active color
  Color? getActiveColor() {
    return (style.activeColor ??
            NyColor(light: Colors.blue, dark: Colors.black))
        .toColor(context);
  }

  /// Get the fill color
  WidgetStateColor? getFillColor() {
    return WidgetStateColor.resolveWith((_) {
      return ((style.fillColor ??
                  NyColor(light: Colors.black, dark: Colors.white))
              .toColor(context)) ??
          const Color(0xFF000000);
    });
  }

  /// Get hover color
  Color? getHoverColor() {
    return (style.hoverColor ??
            NyColor(light: Colors.grey.shade100, dark: Colors.grey.shade100))
        .toColor(context);
  }

  /// Get overlay color
  WidgetStateColor? getOverlayColor() {
    return WidgetStateColor.resolveWith((_) {
      return (style.overlayColor ??
                  NyColor(
                    light: Colors.grey.shade100,
                    dark: Colors.grey.shade100,
                  ))
              .toColor(context) ??
          const Color(0xFF000000);
    });
  }

  /// Get splash radius
  double getSplashRadius() {
    return style.splashRadius ?? 0.0;
  }

  /// Get mouse cursor
  MouseCursor getMouseCursor() {
    return style.mouseCursor ?? SystemMouseCursors.click;
  }

  /// Get the title style
  TextStyle? titleStyle() {
    return style.titleStyle ??
        TextStyle(
          color: color(light: Colors.black, dark: Colors.white),
        );
  }

  /// Get the list tile style
  TextStyle? listTileStyle() {
    return style.listTileStyle ??
        TextStyle(
          color: color(light: Colors.black, dark: Colors.white),
        );
  }

  /// Get the hide title
  bool? hideTitle() {
    return style.hideTitle ?? false;
  }
}
