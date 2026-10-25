import 'package:flutter/material.dart';

import '/helpers/src/backpack.dart';
import '/nylo.dart';
import '/widgets/src/input_field.dart' show FieldLabelPosition;
import 'field_card.dart';
import 'field_colors.dart';

/// The four looks a [FormFieldStyle] can give fields.
enum FormFieldLook {
  /// A soft grey box with a hairline border. The default.
  filled,

  /// A transparent box with a crisp border.
  outlined,

  /// No box, just a line under the field.
  underlined,

  /// Rows in one card, with the label beside the value, as in iOS settings.
  grouped,
}

/// How every form field in an app, a form or a part of the screen is drawn:
/// its box, border, label and spacing.
///
/// Colors still come from the theme's [NyFieldColors], so each style works
/// in light and dark. A field's own `style:` wins over its form's
/// [NyFormWidget.fieldStyle], which wins over the app's.
///
/// For the whole app, in `Nylo.configure`:
///
/// ```dart
/// formFieldStyle: FormFieldStyle.outlined(),
/// ```
///
/// For one form:
///
/// ```dart
/// class ProfileForm extends NyFormWidget {
///   @override
///   FormFieldStyle get fieldStyle => FormFieldStyle.grouped();
/// }
/// ```
@immutable
class FormFieldStyle {
  /// A soft grey box with a hairline border, the label above it. The
  /// default.
  const FormFieldStyle.filled({
    this.radius = 12,
    this.labelPosition = FieldLabelPosition.above,
    this.dense = false,
  }) : look = FormFieldLook.filled;

  /// A transparent box with a crisp border that turns into a 2 px accent
  /// border when focused. For business, admin and web-like apps.
  const FormFieldStyle.outlined({
    this.radius = 10,
    this.labelPosition = FieldLabelPosition.above,
    this.dense = false,
  }) : look = FormFieldLook.outlined;

  /// No box, just a line under the field that thickens to the accent when
  /// focused. For minimal apps and long forms of short fields.
  const FormFieldStyle.underlined({
    this.labelPosition = FieldLabelPosition.above,
    this.dense = false,
  }) : look = FormFieldLook.underlined,
       radius = 0;

  /// Fields as rows in one card, each label beside its value, as in iOS
  /// settings. A form puts its text, picker, date and switch fields that
  /// follow each other in one card; elsewhere, wrap them in a
  /// [FormFieldGroup].
  const FormFieldStyle.grouped({this.radius = 12, this.dense = false})
    : look = FormFieldLook.grouped,
      labelPosition = FieldLabelPosition.above;

  /// Which of the four looks this is.
  final FormFieldLook look;

  /// The corner radius of a field's box, or of a group's card.
  final double radius;

  /// Where a field's label sits. A grouped field's label is always beside
  /// its value.
  final FieldLabelPosition labelPosition;

  /// Whether fields are shorter, for forms with many fields.
  final bool dense;

  /// The style for [context]: the nearest [FormFieldStyleScope]'s, else
  /// the app's from `Nylo.configure`, else [FormFieldStyle.filled].
  static FormFieldStyle of(BuildContext context) =>
      FormFieldStyleScope.maybeOf(context) ??
      _appStyle ??
      const FormFieldStyle.filled();

  static FormFieldStyle? get _appStyle {
    if (!Backpack.instance.isNyloInitialized()) return null;
    return Nylo.instance.formFieldStyle;
  }

  /// Whether fields are rows in a card.
  bool get isGrouped => look == FormFieldLook.grouped;

  /// The space between a label and the field under it.
  double get labelGap => look == FormFieldLook.underlined ? 4 : 8;

  /// The padding inside a field's box.
  EdgeInsetsGeometry get contentPadding {
    final double vertical = dense ? 11 : 15;
    return switch (look) {
      FormFieldLook.underlined => EdgeInsetsDirectional.symmetric(
        vertical: vertical - 3,
        horizontal: 2,
      ),
      FormFieldLook.grouped => EdgeInsetsDirectional.symmetric(
        vertical: vertical,
      ),
      _ => EdgeInsetsDirectional.symmetric(vertical: vertical, horizontal: 14),
    };
  }

  /// A field's box: its fill and borders for each state, in [colors].
  ///
  /// [radius] replaces this style's own.
  InputDecoration decoration(
    NyFieldColors colors, {
    required bool hasError,
    required bool disabled,
    BorderRadius? radius,
  }) {
    final BorderRadius corners =
        radius ?? BorderRadius.all(Radius.circular(this.radius));
    InputBorder box(Color color, [double width = 1]) => switch (look) {
      FormFieldLook.underlined => UnderlineInputBorder(
        borderSide: BorderSide(color: color, width: width),
      ),
      FormFieldLook.grouped => InputBorder.none,
      _ => OutlineInputBorder(
        borderRadius: corners,
        borderSide: BorderSide(color: color, width: width),
      ),
    };

    final bool boxed = look == FormFieldLook.filled;
    final Color edge = boxed ? colors.border : colors.controlOff;
    return InputDecoration(
      filled: boxed,
      fillColor: !boxed
          ? Colors.transparent
          : disabled
          ? colors.disabledFill
          : hasError
          ? colors.errorFill
          : colors.fill,
      isDense: true,
      contentPadding: contentPadding,
      border: box(edge),
      enabledBorder: box(edge),
      disabledBorder: box(colors.disabledBorder),
      focusedBorder: box(colors.accent, look == FormFieldLook.filled ? 1.5 : 2),
      errorBorder: box(colors.error),
      focusedErrorBorder: box(
        colors.error,
        look == FormFieldLook.filled ? 1.5 : 2,
      ),
    );
  }

  /// The card behind a [FormFieldGroup], and behind a grouped field shown
  /// on its own.
  BoxDecoration groupDecoration(NyFieldColors colors) => BoxDecoration(
    color: colors.fill,
    borderRadius: BorderRadius.all(Radius.circular(radius)),
    border: Border.all(color: colors.border),
  );

  /// Where a radio group or switch row draws its card: a filled or
  /// outlined one, or none for [FormFieldLook.underlined].
  BoxDecoration? cardDecoration(NyFieldColors colors) => switch (look) {
    FormFieldLook.outlined => BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      border: Border.all(color: colors.controlOff),
    ),
    FormFieldLook.underlined => null,
    _ => groupDecoration(colors),
  };

  @override
  bool operator ==(Object other) =>
      other is FormFieldStyle &&
      other.look == look &&
      other.radius == radius &&
      other.labelPosition == labelPosition &&
      other.dense == dense;

  @override
  int get hashCode => Object.hash(look, radius, labelPosition, dense);
}

/// Gives the fields under it a [FormFieldStyle].
///
/// ```dart
/// FormFieldStyleScope(
///   style: FormFieldStyle.underlined(),
///   child: Column(children: [...]),
/// )
/// ```
class FormFieldStyleScope extends InheritedWidget {
  /// Gives [child]'s fields [style].
  const FormFieldStyleScope({
    super.key,
    required this.style,
    required super.child,
  });

  /// The style the fields under it use.
  final FormFieldStyle style;

  /// The style of the nearest scope above [context], or null.
  static FormFieldStyle? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FormFieldStyleScope>()?.style;

  @override
  bool updateShouldNotify(FormFieldStyleScope oldWidget) =>
      style != oldWidget.style;
}

/// One card holding grouped fields as rows, with a line between each, as
/// in iOS settings.
///
/// A form with [FormFieldStyle.grouped] makes these itself. Use one to
/// group fields anywhere else:
///
/// ```dart
/// FormFieldGroup(children: [name.widget!, email.widget!])
/// ```
class FormFieldGroup extends StatelessWidget {
  /// Puts [children] in one card.
  const FormFieldGroup({super.key, required this.children, this.header});

  /// The rows.
  final List<Widget> children;

  /// A small heading above the card, e.g. "Account".
  final String? header;

  /// Whether [context] is inside a group's card.
  static bool isIn(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_GroupMarker>() != null;

  @override
  Widget build(BuildContext context) {
    final NyFieldColors colors = NyFieldColors.of(context);
    FormFieldStyle style = FormFieldStyle.of(context);
    if (!style.isGrouped) style = const FormFieldStyle.grouped();
    final Widget card = FormFieldStyleScope(
      style: style,
      child: _GroupMarker(
        child: FieldCard(
          decoration: style.groupDecoration(colors),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    color: colors.divider,
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ),
    );
    final String? title = header;
    if (title == null) return card;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 16, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.7,
              color: colors.placeholder,
            ),
          ),
        ),
        card,
      ],
    );
  }
}

/// Marks the inside of a [FormFieldGroup]'s card.
class _GroupMarker extends InheritedWidget {
  const _GroupMarker({required super.child});

  @override
  bool updateShouldNotify(_GroupMarker oldWidget) => false;
}

/// A grouped field's row: [label] beside [child], in a card of its own when
/// it isn't in a [FormFieldGroup].
class FormFieldGroupRow extends StatelessWidget {
  /// Shows [label] beside [child].
  const FormFieldGroupRow({
    super.key,
    required this.label,
    required this.child,
    this.hasError = false,
    this.alignTop = false,
  });

  /// The field's name.
  final String label;

  /// The field itself, with no box of its own.
  final Widget child;

  /// Shows [label] in the theme's error color.
  final bool hasError;

  /// Lines [label] up with the first line of [child], for a field that
  /// can grow, like a text field with an error under it.
  final bool alignTop;

  /// The space between the label and the field.
  static const double _labelGap = 16;

  /// The most of the row a label takes before it wraps.
  static const double _maxLabelShare = 0.4;

  @override
  Widget build(BuildContext context) {
    final NyFieldColors colors = NyFieldColors.of(context);
    final FormFieldStyle style = FormFieldStyle.of(context);
    final double inset = style.dense ? 11 : 15;
    final Widget row = Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => Row(
          crossAxisAlignment: alignTop
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            // The label keeps the row's inset above and below it, so a
            // label that wraps still clears the line under the row.
            Padding(
              padding: EdgeInsets.symmetric(vertical: inset),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * _maxLabelShare,
                ),
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    color: hasError ? colors.error : colors.text,
                  ),
                ),
              ),
            ),
            const SizedBox(width: _labelGap),
            Expanded(child: child),
          ],
        ),
      ),
    );
    if (FormFieldGroup.isIn(context)) return row;
    return FieldCard(decoration: style.groupDecoration(colors), child: row);
  }
}
