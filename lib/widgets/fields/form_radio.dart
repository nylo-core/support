import 'package:flutter/material.dart';
import '/localization/app_localization.dart';
import '/widgets/ny_widgets.dart';
import '/widgets/fields/field_base_state.dart';

/// A [NyFormRadio] widget for Form Fields
class NyFormRadio extends StatefulWidget {
  /// Creates a [NyFormRadio] widget
  NyFormRadio(
      {super.key,
      required String name,
      required List<String> options,
      String? selectedValue,
      NyRadioTileStyle? nyRadioTileStyle,
      this.onChanged})
      : field = Field(name, value: selectedValue)
          ..cast = FormCast.radio(
              options: options, nyRadioTileStyle: nyRadioTileStyle);

  /// Creates a [NyFormRadio] widget from a [Field]
  const NyFormRadio.fromField(this.field, this.onChanged, {super.key});

  /// The field to be rendered
  final Field field;

  /// The callback function to be called when the value changes
  final Function(dynamic value)? onChanged;

  @override
  // ignore: no_logic_in_create_state
  createState() => _NyFormRadioState(field);
}

class _NyFormRadioState extends FieldBaseState<NyFormRadio> {
  dynamic currentValue;

  _NyFormRadioState(super.field);

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
    List optionsValue = getOptions();
    List<String> options = List<String>.from(optionsValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (hideTitle() != true)
          Text(widget.field.name.tr(), style: titleStyle()),
        Spacing.vertical(10),
        ...options.map((val) {
          return RadioListTile(
            title: Text(
              val,
              style: listTileStyle(),
            ),
            value: val,
            groupValue: currentValue,
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
            onChanged: (value) {
              setState(() {
                currentValue = value;
              });
              if (widget.onChanged == null) return;
              widget.onChanged!(currentValue);
            },
          );
        })
      ],
    );
  }

  /// Get the list of options from the field
  List getOptions() => getFieldMeta("options", []);

  /// Get the selected color
  Color? getSelectedTileColor() {
    return getFieldMeta("selectedColor",
            NyColor(light: Colors.grey.shade100, dark: surfaceColorDark))
        .toColor(context);
  }

  /// Get the tile color
  Color? getTileColor() {
    return getFieldMeta("tileColor",
            NyColor(light: Colors.transparent, dark: surfaceColorDark))
        .toColor(context);
  }

  /// Get the shape of the radio tile
  ShapeBorder? getShape() {
    return getFieldMeta("shape", null);
  }

  /// Get the content padding
  EdgeInsetsGeometry getContentPadding() {
    return getFieldMeta("contentPadding", const EdgeInsets.all(8.0));
  }

  /// Get active color
  Color? getActiveColor() {
    return getFieldMeta(
            "activeColor", NyColor(light: Colors.blue, dark: Colors.black))
        .toColor(context);
  }

  /// Get the fill color
  WidgetStateColor? getFillColor() {
    return WidgetStateColor.resolveWith((_) {
      return getFieldMeta(
                  "fillColor", NyColor(light: Colors.black, dark: Colors.white))
              .toColor(context) ??
          const Color(0xFF000000);
    });
  }

  /// Get hover color
  Color? getHoverColor() {
    return getFieldMeta("hoverColor",
            NyColor(light: Colors.grey.shade100, dark: Colors.grey.shade100))
        .toColor(context);
  }

  /// Get overlay color
  WidgetStateColor? getOverlayColor() {
    return WidgetStateColor.resolveWith((_) {
      return getFieldMeta(
                  "overlayColor",
                  NyColor(
                      light: Colors.grey.shade100, dark: Colors.grey.shade100))
              .toColor(context) ??
          const Color(0xFF000000);
    });
  }

  /// Get splash radius
  double getSplashRadius() {
    return getFieldMeta("splashRadius", 0.0);
  }

  /// Get mouse cursor
  MouseCursor getMouseCursor() {
    return getFieldMeta("mouseCursor", SystemMouseCursors.click);
  }

  /// Get the title style
  TextStyle? titleStyle() {
    NyTextStyle? titleStyle = getFieldMeta(
        "titleStyle",
        NyTextStyle(
          color: NyColor(light: Colors.black, dark: Colors.white),
        ));
    if (titleStyle != null) {
      return titleStyle.toTextStyle(context);
    }
    return null;
  }

  /// Get the list tile style
  TextStyle? listTileStyle() {
    NyTextStyle? titleStyle = getFieldMeta(
        "listTileStyle",
        NyTextStyle(
          color: NyColor(light: Colors.black, dark: Colors.white),
        ));
    if (titleStyle != null) {
      return titleStyle.toTextStyle(context);
    }
    return null;
  }

  /// Get the hide title
  bool? hideTitle() {
    return getFieldMeta("hideTitle", false);
  }
}
