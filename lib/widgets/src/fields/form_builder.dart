import 'package:flutter/material.dart';
import '/widgets/ny_widgets.dart';

/// Typedef for the builder function used by [Field.builder].
///
/// Receives the [BuildContext], an [onChanged] callback to report value changes
/// to the form, and the [currentValue] of the field.
typedef NyFieldBuilder =
    Widget Function(
      BuildContext context,
      Function(dynamic value) onChanged,
      dynamic currentValue,
    );

/// A builder widget for forms that lets developers create custom fields inline.
///
/// [NyFormBuilder] wraps a developer-provided builder function, allowing any
/// widget to participate in the form's value lifecycle without creating a
/// separate [NyFieldStatefulWidget] subclass.
///
/// Example usage:
/// ```dart
/// Field.builder(
///   'favorite_color',
///   builder: (context, onChanged, value) {
///     return ColorPicker(
///       selected: value,
///       onColorChanged: (color) => onChanged(color),
///     );
///   },
///   value: Colors.blue,
/// )
/// ```
class NyFormBuilder extends NyFieldStatefulWidget {
  NyFormBuilder.fromField(this.field, {super.key, required this.builder})
    : onChanged = field.onChanged;

  final Field field;
  final NyFieldBuilder builder;
  final Function(dynamic value)? onChanged;

  @override
  Field? get formField => field;

  @override
  // ignore: no_logic_in_create_state
  createState() => _NyFormBuilderState(field);

  static FormBuilderStateActions stateActions(String stateName) =>
      FormBuilderStateActions(stateName);
}

/// Provides state management actions for [NyFormBuilder] widgets.
class FormBuilderStateActions extends FormStateActions {
  FormBuilderStateActions(super.state);
}

class _NyFormBuilderState extends FieldBaseState<NyFormBuilder> {
  dynamic currentValue;

  _NyFormBuilderState(super.field) {
    stateName = this.field.stateKey;
  }

  @override
  void initState() {
    super.initState();
    currentValue = widget.field.value;
  }

  @override
  Map<String, Function> get stateActions => {
    "clear": () {
      currentValue = null;
      widget.field.restoreValue(null);
      setState(() {});
    },
    "setValue": (dynamic data) {
      currentValue = data["value"];
      widget.field.restoreValue(currentValue);
      setState(() {});
    },
  };

  @override
  Widget view(BuildContext context) {
    return widget.builder(context, (dynamic value) {
      currentValue = value;
      widget.field.restoreValue(value);
      if (widget.onChanged != null) {
        widget.onChanged!(value);
      }
      setState(() {});
    }, currentValue);
  }
}
