import 'package:flutter/material.dart';
import 'package:nylo_support/widgets/src/form/form.dart';
import '/helpers/ny_helpers.dart';
import '/localization/ny_localization.dart';
import '/widgets/ny_widgets.dart';

/// A customizable chip selection widget for forms that allows users to select multiple options.
///
/// The [NyFormChip] widget provides a Material Design chip interface where users can
/// toggle selections by tapping on chips. Each chip represents an option from the provided
/// [FormCollection] and displays with customizable styling.
///
/// Example usage:
/// ```dart
/// NyFormChip(
///   name: 'interests',
///   options: FormCollection.from(['Sports', 'Music', 'Art']),
///   onChanged: (selectedValues) => print('Selected: $selectedValues'),
/// )
/// ```
class NyFormChip extends NyFieldStatefulWidget {
  /// Creates a [NyFormChip] widget with the specified configuration.
  ///
  /// The [name] parameter identifies the field and [options] provides the available
  /// choices. Optionally set [selectedValue] for initial selection and customize
  /// appearance with [style].
  NyFormChip({
    super.key,
    required String name,
    String? selectedValue,
    FieldStyleChip? style,
    required this.options,
    this.onChanged,
  }) : field = Field.chips(
         name,
         options: options,
         value: selectedValue,
         style: style,
       );

  /// Creates a [NyFormChip] widget from an existing [Field] instance.
  ///
  /// This constructor is useful when the field configuration is already defined
  /// elsewhere in your form setup.
  NyFormChip.fromField(
    this.field, {
    super.key,
    required this.options,
    FieldStyleChip? style,
  }) : onChanged = field.onChanged;

  /// The field configuration that defines the chip behavior and properties.
  final Field field;

  @override
  Field? get formField => field;

  /// Collection of options that will be displayed as selectable chips.
  final FormCollection options;

  /// Callback function invoked when the user selects or deselects chips.
  ///
  /// The callback receives a list of selected values that corresponds to the
  /// value property of the selected [FormOption] items.
  final Function(dynamic value)? onChanged;

  /// Creates the state for this widget.
  ///
  /// Returns a [_NyFormChipState] instance that manages the chip selection state
  /// and handles user interactions.
  @override
  // ignore: no_logic_in_create_state
  createState() => _NyFormChipState(field);

  /// Provides access to state management actions for this chip widget.
  ///
  /// Use this method to get a [FormChipStateActions] instance that allows
  /// external components to interact with the chip widget's state.
  ///
  /// [stateName] should match the state identifier used when registering the widget.
  static FormChipStateActions stateActions(String stateName) =>
      FormChipStateActions(stateName);
}

/// Provides state management actions for [NyFormChip] widgets.
///
/// This class extends [FormStateActions] to provide chip-specific state operations
/// such as clearing selections or updating the widget state programmatically.
/// Use [NyFormChip.stateActions] to obtain an instance of this class.
class FormChipStateActions extends FormStateActions {
  /// Creates a [FormChipStateActions] instance for the specified state.
  ///
  /// [state] should be the state name identifier that corresponds to the
  /// chip widget you want to control.
  FormChipStateActions(super.state);

  /// Set the options for the chip group
  void setOptions(FormCollection options) {
    stateAction("setOptions", state: state, data: {"options": options});
  }
}

class _NyFormChipState extends FieldBaseState<NyFormChip> {
  List<dynamic> currentValues = [];
  FormCollection? _options;

  _NyFormChipState(super.field) {
    stateName = this.field.stateKey;
  }

  /// Get the style from the field
  @override
  FieldStyleChip get style {
    return widget.field.style as FieldStyleChip? ?? FieldStyleChip();
  }

  @override
  void initState() {
    super.initState();

    dynamic fieldValue = widget.field.value;
    if (fieldValue is String && fieldValue.isNotEmpty) {
      currentValues.add(fieldValue);
    }
    if (fieldValue is List && fieldValue.isNotEmpty) {
      currentValues = fieldValue;
    }
  }

  @override
  Map<String, Function> get stateActions => {
    "clear": () {
      currentValues = [];
      setState(() {});
    },
    "setValue": (data) {
      final value = data["value"];
      if (value is List) {
        currentValues = value;
      } else if (value != null) {
        currentValues = [value];
      } else {
        currentValues = [];
      }
      widget.field.setValue(currentValues);
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
  Widget view(BuildContext context) {
    FormCollection optionsValue = getOptions();
    List<FormOption> options = optionsValue.options;
    return LayoutBuilder(
      builder: (layoutContext, constraints) {
        Widget container = Wrap(
          runSpacing: getRunSpacing(),
          spacing: getSpacing(),
          children: options.map((FormOption option) {
            bool isSelected = currentValues.contains(option.value);
            return ChoiceChip(
              materialTapTargetSize: style.materialTapTargetSize,
              side: isSelected ? getSelectedSide() : getUnselectedSide(),
              shape: getShape(),
              label: Text(
                option.label.tr(),
                style: isSelected
                    ? getSelectedTextStyle()
                    : getUnselectedTextStyle(),
              ),
              labelStyle: getLabelStyle(),
              selected: isSelected,
              selectedColor: getSelectedColor(),
              padding: getPadding(),
              backgroundColor: Colors.transparent,
              shadowColor: style.shadowColor,
              surfaceTintColor: style.surfaceTintColor,
              checkmarkColor: getCheckmarkColor(),
              selectedShadowColor: Colors.transparent,
              color: WidgetStateColor.resolveWith((_) {
                return color(
                  light: isSelected ? getSelectedColor() : getBackgroundColor(),
                  dark: surfaceColorDark,
                );
              }),
              onSelected: (bool selected) {
                setState(() {
                  if (widget.onChanged == null) return;
                  if (selected) {
                    currentValues.add(option.value);
                  } else {
                    currentValues.remove(option.value);
                  }
                  widget.onChanged!(currentValues);
                });
              },
            );
          }).toList(),
        );

        return container;
      },
    );
  }

  /// Get the list of options from the field
  FormCollection getOptions() => _options ?? widget.options;

  /// Get the background color from the field
  Color getBackgroundColor() => style.backgroundColor ?? Colors.white;

  /// Get the selected color from the field
  Color? getSelectedColor() =>
      style.selectedColor ?? color(light: Colors.black, dark: Colors.white);

  /// Get the borderRadius from the field
  OutlinedBorder getShape() => style.shape;

  /// Get the unselected Side from the field
  BorderSide getUnselectedSide() => style.unselectedSide;

  /// Get the selected Side from the field
  BorderSide getSelectedSide() => style.selectedSide;

  /// Get the labelStyle from the field
  TextStyle getLabelStyle() => style.labelStyle;

  /// Get the unselectedTextStyle from the field
  TextStyle getUnselectedTextStyle() => style.unselectedTextStyle;

  /// Get the selectedTextStyle from the field
  TextStyle getSelectedTextStyle() => style.selectedTextStyle;

  /// Get the padding from the field
  EdgeInsets getPadding() => style.padding;

  /// Get the runSpacing from the field
  double getRunSpacing() => style.runSpacing;

  /// Get the spacing from the field
  double getSpacing() => style.spacing;

  /// Get the checkmarkColor from the field
  Color getCheckmarkColor() => style.checkmarkColor;
}
