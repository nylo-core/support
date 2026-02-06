import 'package:flutter/material.dart';
import '/helpers/ny_helpers.dart';
import '/widgets/ny_widgets.dart';
import '/themes/ny_themes.dart';

/// A stateful widget base class for creating form field widgets.
///
/// [NyFieldStatefulWidget] provides the foundation for form field widgets
/// by extending [StatefulWidget] with additional form-specific functionality.
/// It supports custom state management and child widget delegation.
///
/// This class is typically used as a base for field widgets like text inputs,
/// dropdowns, checkboxes, and other form controls that need to maintain state.
class NyFieldStatefulWidget extends StatefulWidget {
  /// Creates a [NyFieldStatefulWidget] with optional state name and child widget.
  ///
  /// [stateName] can be provided to override the default state identifier.
  /// [child] can be a State instance or a function that returns a State.
  NyFieldStatefulWidget({super.key, this.child, String? stateName})
    : state = stateName ?? child.toString() {}

  /// The state name identifier for this widget.
  ///
  /// Used for state management and widget identification within the form system.
  final String? state;

  /// The child widget or state instance.
  ///
  /// Can be a State object directly or a function that returns a State object.
  /// This provides flexibility in how field widgets define their state behavior.
  final dynamic child;

  /// Returns the [Field] associated with this widget, if any.
  ///
  /// Override in subclasses to provide the field reference so that
  /// [FieldBaseState.didUpdateWidget] can refresh stale field data on hot reload.
  Field? get formField => null;

  @override
  StatefulElement createElement() => StatefulElement(this);

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() {
    if (child == null) {
      throw UnimplementedError();
    }
    if (child is State) {
      return child!;
    }
    if (child is Function) {
      dynamic child = this.child();
      assert(child is State, "Child must be a State");
      if (child is State) {
        return child;
      }
    }
    throw UnimplementedError();
  }
}

/// Abstract base class for form field widget states.
///
/// [FieldBaseState] extends [NyState] to provide common functionality for
/// form field widgets including styling, validation, and layout management.
/// All form field widgets should extend this class to ensure consistent
/// behavior and integration with the form system.
///
/// Type parameter [T] should be the StatefulWidget class that this state manages.
abstract class FieldBaseState<T extends StatefulWidget> extends NyState<T> {
  /// Creates a [FieldBaseState] with the associated field configuration.
  ///
  /// [field] contains the field definition including validation rules,
  /// styling, and other configuration options.
  FieldBaseState(this.field);

  /// The field configuration and data container for this widget.
  ///
  /// Contains all field-specific settings including validation rules,
  /// current value, styling options, and metadata.
  late Field field;

  /// Default surface color used for dark theme field backgrounds.
  ///
  /// Provides a consistent dark background color (#222831) for field widgets
  /// when the app is in dark mode.
  Color surfaceColorDark = "222831".toHexColor();

  /// Returns the styling configuration for this field.
  ///
  /// Override this getter in subclasses to return the appropriate
  /// field-specific style object (e.g., FieldStyleTextField, FieldStyleChip).
  /// Defaults to base FieldStyle if not overridden.
  FieldStyle get style {
    return FieldStyle();
  }

  /// Creates a WidgetStateProperty for colors with theme-aware fallbacks.
  ///
  /// Converts a color to a WidgetStateProperty that adapts to the current theme.
  /// In light mode, uses the provided color; in dark mode, defaults to black.
  /// Returns null if no color is provided.
  ///
  /// [colorMetaData] is the base color to use for light theme.
  /// [defaultValue] is an optional fallback color (currently unused).
  WidgetStateProperty<Color>? getWidgetStatePropertyColor(
    Color? colorMetaData, {
    Color? defaultValue,
  }) {
    if (colorMetaData == null) {
      return null;
    }
    Color? thumbColorMetaData = color(light: colorMetaData, dark: Colors.black);
    return WidgetStateProperty.all(thumbColorMetaData);
  }

  /// Creates a WidgetStateProperty for generic widget properties.
  ///
  /// Wraps any widget in a WidgetStateProperty for use with Material widgets
  /// that require state-dependent properties. Useful for icons, decorations, etc.
  ///
  /// [widgetData] is the widget to wrap.
  /// [defaultValue] is an optional fallback widget.
  WidgetStateProperty<T>? getWidgetStateProperty<T>(
    Widget? widgetData, {
    Icon? defaultValue,
  }) {
    if (widgetData == null) {
      return null;
    }
    return WidgetStateProperty.all(widgetData) as WidgetStateProperty<T>?;
  }

  /// Returns the vertical spacing above the field header.
  ///
  /// Gets the header spacing from the field's style configuration,
  /// defaulting to 5 pixels if not specified.
  double getHeaderSpacing() => style.headerSpacing ?? 5;

  /// Returns the vertical spacing below the field footer.
  ///
  /// Gets the footer spacing from the field's style configuration,
  /// defaulting to 5 pixels if not specified.
  double getFooterSpacing() => style.footerSpacing ?? 5;

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget is NyFieldStatefulWidget) {
      final newField = (widget as NyFieldStatefulWidget).formField;
      if (newField != null) {
        field = newField;
      }
    }
  }

  /// Override this method to define the main field widget content.
  ///
  /// This method should return the primary UI widget for the field
  /// (e.g., TextField, DropdownButton, Checkbox). The default implementation
  /// returns an empty SizedBox.
  Widget view(BuildContext context) {
    return const SizedBox.shrink();
  }

  /// Build the widget
  @override
  Widget build(BuildContext context) {
    Widget widget = view(context);

    if (field.header != null || field.footer != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (field.header != null) ...[
            field.header!,
            Spacing.vertical(getHeaderSpacing()),
          ],
          widget,
          if (field.footer != null) ...[
            field.footer!,
            Spacing.vertical(getFooterSpacing()),
          ],
        ],
      );
    }

    return widget;
  }

  /// When the theme is in [light] mode, return [light] function, else return [dark] function
  // ignore: avoid_shadowing_type_parameters
  T whenTheme<T>({required T Function() light, T Function()? dark}) {
    bool isDarkModeEnabled = NyThemeManager.instance.isDark;

    // Also check device dark mode as fallback
    if (!isDarkModeEnabled && context.isDeviceInDarkMode) {
      isDarkModeEnabled = true;
    }

    if (isDarkModeEnabled) {
      if (dark != null) {
        return dark();
      }
    }

    return light();
  }
}

/// The base class for form state actions
/// This class is used to manage the state of the form fields
class FormStateActions extends StateActions {
  FormStateActions(super.state);

  /// Clear the field value
  void clear() {
    stateAction("clear", state: state);
  }

  /// Set the field value
  void setValue(dynamic value) {
    stateAction("setValue", state: state, data: {"value": value});
  }
}
