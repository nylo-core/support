# Field.builder Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a `Field.builder` constructor that lets developers create custom form fields inline with a builder function, fully integrated with the form's value lifecycle.

**Architecture:** A new `NyFormBuilder` widget (following the same pattern as `NyFormCheckbox`, `NyFormSwitchBox`, etc.) wraps a developer-provided builder function. The builder receives `context`, `onChanged`, and `currentValue`. The `Field.builder` constructor wires it into the form system identically to all other field types.

**Tech Stack:** Flutter, Dart — Nylo form system (`Field`, `NyFieldStatefulWidget`, `FieldBaseState`, `FormStateActions`)

**Design doc:** `docs/plans/2026-02-27-field-builder-design.md`

---

### Task 1: Create `NyFormBuilder` widget

**Files:**
- Create: `lib/widgets/src/fields/form_builder.dart`

**Step 1: Create the file with all three classes**

```dart
import 'package:flutter/material.dart';
import '/widgets/ny_widgets.dart';

/// Typedef for the builder function used by [Field.builder].
///
/// Receives the [BuildContext], an [onChanged] callback to report value changes
/// to the form, and the [currentValue] of the field.
typedef NyFieldBuilder = Widget Function(
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
      setState(() {
        currentValue = null;
      });
    },
    "setValue": (dynamic data) {
      setState(() {
        currentValue = data["value"];
      });
    },
  };

  @override
  Widget view(BuildContext context) {
    return widget.builder(
      context,
      (dynamic value) {
        setState(() {
          currentValue = value;
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        });
      },
      currentValue,
    );
  }
}
```

**Step 2: Verify it analyzes cleanly**

Run: `dart analyze lib/widgets/src/fields/form_builder.dart`
Expected: `No issues found!`

**Step 3: Commit**

```
git add lib/widgets/src/fields/form_builder.dart
git commit -m "feat: add NyFormBuilder widget for Field.builder"
```

---

### Task 2: Add `Field.builder` constructor and wire up state actions

**Files:**
- Modify: `lib/widgets/src/form/field.dart`

**Step 1: Add `NyFormBuilder` branch in `_getFieldStateActions()`**

In `_getFieldStateActions()`, after the `NyFormRangeSlider` check (around line 126), add:

```dart
} else if (fieldWidget is NyFormBuilder) {
  return NyFormBuilder.stateActions(stateKey);
}
```

**Step 2: Add `Field.builder` constructor**

Add after `Field.rangeSlider` (after line 871), before the closing `}` of the class:

```dart
  /// Field.builder is a constructor that lets developers create custom form
  /// fields inline using a builder function.
  ///
  /// The [builder] receives the [BuildContext], an [onChanged] callback to
  /// report value changes to the form, and the [currentValue] of the field.
  ///
  /// Example:
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
  ///   validator: FormValidator().notEmpty(),
  /// )
  /// ```
  Field.builder(
    this.key, {
    required NyFieldBuilder builder,
    this.label,
    dynamic value,
    this.validator,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.hidden = false,
    this.readOnly,
    FieldStyle? style,
    Function(dynamic value)? onChanged,
  }) : _value = value,
       this.style = style {
    setOnChanged(onChanged);
    widget = NyFormBuilder.fromField(this, builder: builder);
  }
```

**Step 3: Verify it analyzes cleanly**

Run: `dart analyze lib/widgets/src/form/field.dart`
Expected: `No issues found!`

**Step 4: Commit**

```
git add lib/widgets/src/form/field.dart
git commit -m "feat: add Field.builder constructor with state action wiring"
```

---

### Task 3: Export from barrel and final verification

**Files:**
- Modify: `lib/widgets/ny_widgets.dart`

**Step 1: Add export**

In the `// Fields` section (after line 33, the `form_text_field.dart` export), add:

```dart
export 'src/fields/form_builder.dart';
```

**Step 2: Run full analysis**

Run: `dart analyze lib/`
Expected: No new issues introduced.

**Step 3: Commit**

```
git add lib/widgets/ny_widgets.dart
git commit -m "feat: export NyFormBuilder from ny_widgets barrel"
```
