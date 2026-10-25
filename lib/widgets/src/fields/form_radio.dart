import 'package:flutter/material.dart';
import '/helpers/ny_helpers.dart';
import '/localization/ny_localization.dart';
import '/widgets/ny_widgets.dart';
import 'field_card.dart';

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
    stateName = field.stateKey;
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
      final dynamic options = data["options"];
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
    final NyFieldColors colors = NyFieldColors.of(context);
    final FormFieldStyle formStyle = FormFieldStyle.of(context);
    FormCollection optionsValue = getOptions();
    List<FormOption> options = optionsValue.options;

    final List<Widget> tiles = [
      for (final FormOption formOption in options)
        RadioListTile<dynamic>(
          title: Text(
            formOption.label.tr(),
            style: formOption.description == null
                ? listTileStyle()
                : listTileStyle()?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: formOption.description == null
              ? null
              : Text(formOption.description!.tr(), style: subtitleStyle()),
          value: formOption.value,
          selected: formOption.value == currentValue,
          // A little tighter than a list row, so the card reads as a field.
          visualDensity: const VisualDensity(vertical: -2),
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
        ),
    ];

    // The options sit in one card like a text field, unless the style
    // colors or shapes the tiles itself.
    final bool card =
        style.tileColor == null &&
        style.selectedColor == null &&
        style.shape == null;

    final Widget optionList = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < tiles.length; i++) ...[
          if (i > 0) Divider(height: 1, thickness: 1, color: colors.divider),
          tiles[i],
        ],
      ],
    );
    final BoxDecoration? cardDecoration = formStyle.cardDecoration(colors);

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
          if (!card)
            ...tiles
          else if (cardDecoration == null)
            Material(type: MaterialType.transparency, child: optionList)
          else
            FieldCard(decoration: cardDecoration, child: optionList),
        ],
      ),
    );
  }

  /// Get the list of options from the field
  FormCollection getOptions() => _options ?? widget.options;

  /// Get the selected color
  Color? getSelectedTileColor() {
    return style.selectedColor?.toColor(context) ??
        NyFieldColors.of(context).selectedTint;
  }

  /// Get the tile color
  Color? getTileColor() {
    return style.tileColor?.toColor(context) ?? Colors.transparent;
  }

  /// Get the shape of the radio tile
  ShapeBorder? getShape() {
    return style.shape;
  }

  /// Get the content padding
  EdgeInsetsGeometry getContentPadding() {
    return style.contentPadding ?? const EdgeInsets.all(2.0);
  }

  /// Get active color
  Color? getActiveColor() {
    return style.activeColor?.toColor(context) ??
        NyFieldColors.of(context).accent;
  }

  /// Get the fill color
  WidgetStateColor? getFillColor() {
    final NyFieldColors colors = NyFieldColors.of(context);
    final Color? custom = style.fillColor?.toColor(context);
    return WidgetStateColor.resolveWith((Set<WidgetState> states) {
      if (custom != null) return custom;
      if (states.contains(WidgetState.disabled)) return colors.disabledText;
      return states.contains(WidgetState.selected)
          ? (getActiveColor() ?? colors.accent)
          : colors.controlOff;
    });
  }

  /// Get hover color
  Color? getHoverColor() {
    return style.hoverColor?.toColor(context) ??
        NyFieldColors.of(context).accent.withValues(alpha: 0.08);
  }

  /// Get overlay color
  WidgetStateColor? getOverlayColor() {
    final Color overlay =
        style.overlayColor?.toColor(context) ??
        NyFieldColors.of(context).accent.withValues(alpha: 0.12);
    return WidgetStateColor.resolveWith((_) => overlay);
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
    return style.titleStyle ?? NyFieldColors.of(context).labelStyle;
  }

  /// Get the list tile style
  TextStyle? listTileStyle() {
    return style.listTileStyle ??
        TextStyle(color: NyFieldColors.of(context).text, fontSize: 16);
  }

  /// Get the style of an option's description
  TextStyle subtitleStyle() {
    return TextStyle(
      fontSize: 13,
      color: NyFieldColors.of(context).placeholder,
    ).merge(style.subtitleStyle);
  }

  /// Get the hide title
  bool? hideTitle() {
    return style.hideTitle ?? false;
  }
}
