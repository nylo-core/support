# Field.builder Design

## Problem

`Field.custom` requires developers to create a full `NyFieldStatefulWidget` subclass to add custom fields to forms. This is heavy boilerplate for simple cases. Developers need an inline builder pattern that hooks into the form's value lifecycle without a separate widget class.

## Solution

Add `Field.builder` — a constructor that accepts a builder function. The builder receives `context`, an `onChanged` callback, and the `currentValue`, letting developers build any widget inline while staying fully integrated with the form's get/set/validate lifecycle.

## API

```dart
typedef NyFieldBuilder = Widget Function(
  BuildContext context,
  Function(dynamic value) onChanged,
  dynamic currentValue,
);

Field.builder(
  'favorite_color',
  builder: (context, onChanged, value) {
    return ColorPicker(
      selected: value,
      onColorChanged: (color) => onChanged(color),
    );
  },
  value: Colors.blue,
  validator: FormValidator().notEmpty(),
)
```

## Implementation

### New file: `lib/widgets/src/fields/form_builder.dart`

Contains three classes following the existing field widget pattern:

- **`NyFormBuilder`** extends `NyFieldStatefulWidget` — holds the `Field` reference and `NyFieldBuilder` function. Has a `fromField` constructor.
- **`FormBuilderStateActions`** extends `FormStateActions` — no extra methods needed beyond inherited `setValue`/`clear`.
- **`_NyFormBuilderState`** extends `FieldBaseState<NyFormBuilder>` — holds `currentValue`, exposes `stateActions` map with `"clear"` and `"setValue"`, calls the builder function in `view()`.

### Modified: `lib/widgets/src/form/field.dart`

- Add `Field.builder` constructor with standard params plus `required NyFieldBuilder builder`.
- Add `NyFormBuilder` branch in `_getFieldStateActions()`.

### Modified: `lib/widgets/ny_widgets.dart`

- Add `export 'src/fields/form_builder.dart';` to the Fields section.

## Files Changed

1. `lib/widgets/src/fields/form_builder.dart` (new)
2. `lib/widgets/src/form/field.dart` (modified)
3. `lib/widgets/ny_widgets.dart` (modified)
