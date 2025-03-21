import 'package:flutter/material.dart';
import '/localization/app_localization.dart';
import '/helpers/extensions.dart';
import '/widgets/fields/field_base_state.dart';
import '/widgets/ny_form.dart';

/// A [NyFormChip] widget for Form Fields
class NyFormChip extends StatefulWidget {
  /// Creates a [NyFormChip] widget
  NyFormChip(
      {super.key,
      required String name,
      required List<String> options,
      String? selectedValue,
      this.onChanged})
      : field = Field(name, value: selectedValue)
          ..cast = FormCast.chips(options: options);

  /// Compact version of the [NyFormChip] widget
  NyFormChip.compact(Field field, this.onChanged, {super.key})
      : field = field
          ..cast.addMetaData({
            "backgroundColor": Colors.grey.shade100,
            "selectedColor": Colors.grey.shade100,
            "shape":
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            "selectedSide": BorderSide(color: Colors.grey.shade200),
            "unselectedSide": BorderSide(color: Colors.grey.shade100),
            "labelStyle": const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black),
            "unselectedTextStyle": const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black),
            "selectedTextStyle": const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black),
            "padding": const EdgeInsets.all(8.0),
            "runSpacing": 8.0,
            "spacing": 8.0,
            "checkmarkColor": Colors.black,
          });

  /// Creates a [NyFormChip] widget from a [Field]
  const NyFormChip.fromField(this.field, this.onChanged, {super.key});

  /// The field to be rendered
  final Field field;

  /// The callback function to be called when the value changes
  final Function(dynamic value)? onChanged;

  @override
  // ignore: no_logic_in_create_state
  createState() => _NyFormChipState(field);
}

class _NyFormChipState extends FieldBaseState<NyFormChip> {
  List<dynamic> currentValues = [];

  _NyFormChipState(super.field);

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
  Widget view(BuildContext context) {
    List optionsValue = getOptions();
    List<String> options = List<String>.from(optionsValue);
    return LayoutBuilder(builder: (layoutContext, constraints) {
      Widget container = Wrap(
          runSpacing: getRunSpacing(),
          spacing: getSpacing(),
          children: options.map((option) {
            bool isSelected = currentValues.contains(option);
            return ChoiceChip(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: whenTheme(
                  light: () =>
                      isSelected ? getSelectedSide() : getUnselectedSide(),
                  dark: () => BorderSide(color: Colors.transparent)),
              shape: getShape(),
              label: Text(option.tr(),
                  style: whenTheme(
                      light: () => isSelected
                          ? getSelectedTextStyle()
                          : getUnselectedTextStyle(),
                      dark: () => TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white))),
              labelStyle: getLabelStyle(),
              selected: isSelected,
              selectedColor: getSelectedColor(),
              padding: getPadding(),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              checkmarkColor: whenTheme(
                  light: () => getCheckmarkColor(), dark: () => Colors.white),
              selectedShadowColor: Colors.transparent,
              color: WidgetStateColor.resolveWith((_) {
                return color(
                        light: isSelected
                            ? getSelectedColor()
                            : getBackgroundColor(),
                        dark: surfaceColorDark) ??
                    const Color(0xFF000000);
              }),
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    currentValues.add(option);
                  } else {
                    currentValues.remove(option);
                  }
                  widget.onChanged!(currentValues);
                });
              },
            );
          }).toList());

      return container;
    });
  }

  /// Get the list of options from the field
  List getOptions() => getFieldMeta("options", []);

  /// Get the background color from the field
  Color getBackgroundColor() => getFieldMeta("backgroundColor", Colors.white);

  /// Get the selected color from the field
  Color? getSelectedColor() => getFieldMeta(
      "selectedColor", color(light: Colors.black, dark: Colors.white));

  /// Get the borderRadius from the field
  OutlinedBorder getShape() => getFieldMeta(
      "shape", RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)));

  /// Get the unselected Side from the field
  BorderSide getUnselectedSide() => getFieldMeta(
      "unselectedSide", BorderSide(color: "#bfbbc5".toHexColor(), width: 1));

  /// Get the selected Side from the field
  BorderSide getSelectedSide() => getFieldMeta(
      "selectedSide", BorderSide(color: "#bfbbc5".toHexColor(), width: 1));

  /// Get the labelStyle from the field
  TextStyle getLabelStyle() => getFieldMeta(
      "labelStyle",
      TextStyle(
          fontWeight: FontWeight.bold,
          color: color(light: Colors.black, dark: Colors.white)));

  /// Get the unselectedTextStyle from the field
  TextStyle getUnselectedTextStyle() => getFieldMeta(
      "unselectedTextStyle",
      TextStyle(
          fontWeight: FontWeight.bold,
          color: color(light: Colors.black, dark: Colors.white)));

  /// Get the selectedTextStyle from the field
  TextStyle getSelectedTextStyle() => getFieldMeta(
      "selectedTextStyle",
      TextStyle(
          fontWeight: FontWeight.bold,
          color: color(light: Colors.black, dark: Colors.white)));

  /// Get the padding from the field
  EdgeInsets getPadding() => getFieldMeta("padding", const EdgeInsets.all(8.0));

  /// Get the runSpacing from the field
  double getRunSpacing() => getFieldMeta("runSpacing", 8.0);

  /// Get the spacing from the field
  double getSpacing() => getFieldMeta("spacing", 8.0);

  /// Get the checkmarkColor from the field
  Color getCheckmarkColor() => getFieldMeta("checkmarkColor", Colors.white);
}
