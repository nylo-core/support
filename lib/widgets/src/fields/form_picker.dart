import 'package:flutter/material.dart';
import '/helpers/ny_helpers.dart';

import '/localization/ny_localization.dart';
import '/widgets/ny_widgets.dart';

/// A dropdown/picker selection widget for forms that allows users to choose from a list of options.
///
/// [NyFormPicker] provides a Material Design dropdown interface where users can
/// select a single option from the provided [FormCollection]. The widget displays
/// the selected option and opens a dropdown menu when tapped.
///
/// Example usage:
/// ```dart
/// NyFormPicker(
///   name: 'country',
///   options: FormCollection.from({'US': 'United States', 'CA': 'Canada'}),
///   selectedValue: 'US',
///   onChanged: (value) => print('Selected: $value'),
/// )
/// ```
class NyFormPicker extends NyFieldStatefulWidget {
  /// Creates a [NyFormPicker] widget with the specified configuration.
  ///
  /// The [name] identifies the field and [options] provides the available choices.
  /// Optionally set [selectedValue] for initial selection and customize appearance with [style].
  NyFormPicker({
    super.key,
    required String name,
    required FormCollection options,
    String? selectedValue,
    this.onChanged,
    FieldStylePicker? style,
  }) : field = Field.picker(
         name,
         value: selectedValue,
         style: style,
         options: options,
       ),
       options = options;

  /// Creates a [NyFormPicker] widget from an existing [Field] instance.
  ///
  /// This constructor is useful when the field configuration is already defined
  /// elsewhere in your form setup. The [options] parameter can override the
  /// field's options if provided.
  NyFormPicker.fromField(this.field, {super.key, FormCollection? options})
    : onChanged = field.onChanged,
      options = options ?? FormCollection.from([]);

  /// The field configuration that defines the picker behavior and properties.
  final Field field;

  @override
  Field? get formField => field;

  /// Callback function invoked when the user selects an option from the dropdown.
  ///
  /// The callback receives the value of the selected [FormOption] when the user
  /// makes a selection from the dropdown menu.
  late final Function(dynamic value)? onChanged;

  /// Collection of options that will be displayed in the dropdown picker.
  ///
  /// Each option contains a value and label pair, where the value is returned
  /// in the [onChanged] callback and the label is displayed to the user.
  final FormCollection options;

  /// Creates the state for this widget.
  ///
  /// Returns a [_NyFormPickerState] instance that manages the dropdown selection
  /// state and handles user interactions with the picker.
  @override
  // ignore: no_logic_in_create_state
  createState() => _NyFormPickerState(field);

  /// Provides access to state management actions for this picker widget.
  ///
  /// Use this method to get a [FormPickerStateActions] instance that allows
  /// external components to interact with the picker's state, such as clearing
  /// the selection or programmatically setting a value.
  ///
  /// [stateName] should match the state identifier used when registering the widget.
  static FormPickerStateActions stateActions(String stateName) =>
      FormPickerStateActions(stateName);
}

/// Provides state management actions for [NyFormPicker] widgets.
///
/// This class extends [FormStateActions] to provide picker-specific state operations
/// such as clearing the selection, setting selected values, or triggering dropdown actions.
/// Use [NyFormPicker.stateActions] to obtain an instance of this class.
class FormPickerStateActions extends FormStateActions {
  /// Creates a [FormPickerStateActions] instance for the specified state.
  ///
  /// [state] should be the state name identifier that corresponds to the
  /// picker widget you want to control.
  FormPickerStateActions(super.state);

  /// Set the options for the picker
  void setOptions(FormCollection options) {
    stateAction("setOptions", state: state, data: {"options": options});
  }
}

class _NyFormPickerState extends FieldBaseState<NyFormPicker> {
  dynamic currentValue;
  FormCollection? _options;

  _NyFormPickerState(super.field) {
    stateName = this.field.stateKey;
  }

  @override
  void initState() {
    super.initState();

    dynamic fieldValue = widget.field.value;
    if (fieldValue is String && fieldValue.isNotEmpty) {
      currentValue = fieldValue;
    }
  }

  /// Get the style from the field
  @override
  FieldStylePicker get style {
    return widget.field.style as FieldStylePicker? ?? FieldStylePicker();
  }

  @override
  Map<String, Function> get stateActions => {
    "clear": () {
      currentValue = null;
      widget.field.restoreValue(null);
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
  Widget view(BuildContext context) {
    final double widthBreakpoint = style.widthBreakpoint;

    final TextStyle selectedValueStyle =
        style.selectedValueTextStyle ??
        TextStyle(
          color: color(light: Colors.black87, dark: Colors.white),
          fontSize: 13,
          fontWeight: FontWeight.bold,
        );

    final TextStyle fieldNameStyle =
        style.fieldNameTextStyle ??
        TextStyle(
          fontSize: 10,
          color: color(light: Colors.black54, dark: Colors.white),
          fontWeight: FontWeight.bold,
        );

    final TextStyle placeholderStyle =
        style.placeholderTextStyle ??
        TextStyle(
          color: color(light: Colors.black54, dark: Colors.white),
          fontSize: 13,
          fontWeight: FontWeight.bold,
        );

    final Color containerColor =
        findColorFromMeta(
          style.containerColor,
          defaultColor: color(
            light: Colors.grey.shade100,
            dark: surfaceColorDark,
          ),
        ) ??
        Colors.grey.shade100;

    final Color iconColor =
        findColorFromMeta(
          style.dropdownIconColor,
          defaultColor: color(light: Colors.grey.shade800, dark: Colors.white),
        ) ??
        Colors.grey.shade800;

    final String placeholderPrefix =
        (style.placeholderPrefix ?? "nylo.form_picker.select").tr();

    return LayoutBuilder(
      builder: (layoutContext, constraints) {
        double width = constraints.maxWidth;
        Widget container = Container(
          height: style.containerHeight,
          alignment: Alignment.center,
          padding: style.containerPadding,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: style.containerBorderRadius,
          ),
          child: currentValue != null
              ? SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: style.selectedValueAlignment != null
                        ? style.selectedValueAlignment!.x < 0
                              ? CrossAxisAlignment.start
                              : style.selectedValueAlignment!.x > 0
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.field.name, style: fieldNameStyle),
                      SizedBox(height: 2),
                      Text(
                        getOptions().getLabelByValue(currentValue.toString()) ??
                            currentValue.toString(),
                        style: selectedValueStyle,
                      ),
                    ],
                  ),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment:
                      style.placeholderAlignment ?? MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        "$placeholderPrefix ${widget.field.name}",
                        textAlign: width < widthBreakpoint
                            ? TextAlign.left
                            : TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: placeholderStyle,
                      ),
                    ),
                    Icon(style.dropdownIcon, color: iconColor),
                  ],
                ).withGap(style.placeholderGap),
        ).onTap(() => _selectValue(context));

        return container;
      },
    );
  }

  /// Get the list of options from the field
  FormCollection getOptions() {
    return _options ?? widget.options;
  }

  // Get the color from the field meta
  Color? findColorFromMeta(NyColor? nyColor, {Color? defaultColor}) {
    if (nyColor != null) {
      return color(light: nyColor.light, dark: nyColor.dark);
    }
    return defaultColor;
  }

  /// Select a value from the list of options
  void _selectValue(BuildContext context) {
    // get the list of values
    FormCollection values = getOptions();

    // colors
    Color? backgroundColor = findColorFromMeta(
      style.bottomModalSheetStyle?.backgroundColor,
    );
    Color? barrierColor = findColorFromMeta(
      style.bottomModalSheetStyle?.barrierColor,
      defaultColor: null,
    );

    // text styles
    TextStyle? titleTextStyle =
        style.bottomModalSheetStyle?.titleStyle ??
        TextStyle(
          fontWeight: FontWeight.bold,
          color: color(light: Colors.black, dark: Colors.white),
        );
    TextStyle? itemStyle =
        style.bottomModalSheetStyle?.itemStyle ??
        TextStyle(
          color: color(light: Colors.black87, dark: Colors.white),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        );
    TextStyle? clearButtonStyle =
        style.bottomModalSheetStyle?.clearButtonStyle ??
        TextStyle(
          fontSize: 13,
          color: color(light: Colors.red, dark: Colors.red),
        );

    Color dividerColor =
        findColorFromMeta(
          style.bottomSheetDividerColor,
          defaultColor: color(
            light: Colors.grey.shade100,
            dark: Colors.black38,
          ),
        ) ??
        Colors.grey.shade100;

    // show modal bottom sheet
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: backgroundColor,
      barrierColor: barrierColor,
      useRootNavigator: style.bottomModalSheetStyle?.useRootNavigator ?? false,
      routeSettings: style.bottomModalSheetStyle?.routeSettings,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            height:
                MediaQuery.of(context).size.height *
                style.bottomSheetHeightFactor,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: style.bottomSheetBorderRadius,
              color: backgroundColor,
            ),
            padding: style.bottomSheetPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.field.name,
                      textAlign: TextAlign.center,
                      style: titleTextStyle,
                    ).paddingOnly(top: 10),
                    Text(
                      "nylo.form_picker.clear".tr(),
                      style: clearButtonStyle,
                    ).onTap(() {
                      setState(() {
                        currentValue = null;
                        widget.field.restoreValue(null);
                      });
                      Navigator.pop(context);
                    }),
                  ],
                ).paddingOnly(bottom: 15),
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: ListTile.divideTiles(
                      context: context,
                      color: dividerColor,
                      tiles: values.options.map((item) {
                        final listTileStyle = style.listTileStyle;
                        final bool isSelected =
                            currentValue != null &&
                            item.value == currentValue.toString();

                        void onTap() {
                          if (widget.onChanged != null) {
                            widget.onChanged!(item.value);
                          }
                          setState(() {
                            currentValue = item.value;
                            widget.field.restoreValue(item.value);
                          });
                          Navigator.pop(context);
                        }

                        if (listTileStyle?.builder != null) {
                          return listTileStyle!.builder!(
                            item,
                            isSelected,
                            onTap,
                          );
                        }

                        final TextStyle effectiveStyle = isSelected
                            ? (listTileStyle?.selectedTextStyle ??
                                  listTileStyle?.textStyle ??
                                  itemStyle)
                            : (listTileStyle?.textStyle ?? itemStyle);

                        Widget? leading;
                        Widget? trailing;

                        if (listTileStyle?.indicator ==
                            PickerListTileIndicator.radio) {
                          final Color radioColor =
                              listTileStyle?.activeColor ??
                              Theme.of(context).primaryColor;
                          leading = Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: isSelected ? radioColor : null,
                          );
                        } else if (listTileStyle?.indicator ==
                            PickerListTileIndicator.checkmark) {
                          if (isSelected) {
                            final Color checkColor =
                                listTileStyle?.activeColor ??
                                Theme.of(context).primaryColor;
                            trailing = Icon(Icons.check, color: checkColor);
                          }
                        }

                        return ListTile(
                          leading: leading,
                          trailing: trailing,
                          title: Text(item.label, style: effectiveStyle),
                          contentPadding:
                              listTileStyle?.contentPadding ?? EdgeInsets.zero,
                          tileColor: isSelected
                              ? listTileStyle?.selectedTileColor
                              : listTileStyle?.tileColor,
                          onTap: onTap,
                        );
                      }),
                    ).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
