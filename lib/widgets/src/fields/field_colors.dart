import 'package:flutter/material.dart';

/// The colors Nylo's form fields are drawn with.
///
/// Every field reads them with [NyFieldColors.of], so the fields follow the
/// app's theme: neutral greys for its brightness, and its
/// `colorScheme.primary` as the accent. Add one to a theme's `extensions` to
/// choose them yourself:
///
/// ```dart
/// ThemeData(
///   extensions: [
///     NyFieldColors.fromTheme(Brightness.dark, accent: Color(0xFF4D9FFF))
///         .copyWith(fill: Color(0xFF1B1F24)),
///   ],
/// )
/// ```
///
/// A color set on a field's own style always wins over these.
@immutable
class NyFieldColors extends ThemeExtension<NyFieldColors> {
  /// Creates a set of field colors.
  const NyFieldColors({
    required this.fill,
    required this.border,
    required this.label,
    required this.text,
    required this.placeholder,
    required this.icon,
    required this.accent,
    required this.accentText,
    required this.onAccent,
    required this.error,
    required this.errorFill,
    required this.disabledFill,
    required this.disabledBorder,
    required this.disabledText,
    required this.controlOff,
    required this.track,
    required this.selectedTint,
    required this.chipSelected,
    required this.sheet,
    required this.divider,
  });

  /// The colors for a theme of [brightness], with [accent] for focus,
  /// selections and controls that are on.
  factory NyFieldColors.fromTheme(
    Brightness brightness, {
    required Color accent,
  }) {
    if (brightness == Brightness.dark) {
      const Color background = Color(0xFF121212);
      return NyFieldColors(
        fill: const Color(0xFF1E1E1E),
        border: const Color(0xFF333333),
        label: const Color(0xFFD4D4D4),
        text: const Color(0xFFF2F2F2),
        placeholder: const Color(0xFF8C8C8C),
        icon: const Color(0xFFA3A3A3),
        accent: accent,
        accentText: Color.lerp(accent, Colors.white, 0.35)!,
        onAccent: _readableOn(accent),
        error: const Color(0xFFFF8A80),
        errorFill: const Color(0xFF2A1715),
        disabledFill: const Color(0xFF181818),
        disabledBorder: const Color(0xFF262626),
        disabledText: const Color(0xFF5C5C5C),
        controlOff: const Color(0xFF6B6B6B),
        track: const Color(0xFF3A3A3A),
        selectedTint: Color.alphaBlend(
          accent.withValues(alpha: 0.10),
          background,
        ),
        chipSelected: Color.alphaBlend(
          accent.withValues(alpha: 0.18),
          background,
        ),
        sheet: const Color(0xFF1E1E1E),
        divider: const Color(0xFF2C2C2C),
      );
    }
    return NyFieldColors(
      fill: const Color(0xFFF4F5F7),
      border: const Color(0xFFE2E5E9),
      label: const Color(0xFF2E333A),
      text: const Color(0xFF111418),
      placeholder: const Color(0xFF5F6672),
      icon: const Color(0xFF5F6672),
      accent: accent,
      accentText: accent,
      onAccent: _readableOn(accent),
      error: const Color(0xFFB42318),
      errorFill: const Color(0xFFFEF3F2),
      disabledFill: const Color(0xFFF7F8F9),
      disabledBorder: const Color(0xFFECEEF1),
      disabledText: const Color(0xFF9AA1AC),
      controlOff: const Color(0xFF8A919C),
      track: const Color(0xFFD5D9DF),
      selectedTint: Color.alphaBlend(
        accent.withValues(alpha: 0.08),
        Colors.white,
      ),
      chipSelected: Color.alphaBlend(
        accent.withValues(alpha: 0.10),
        Colors.white,
      ),
      sheet: Colors.white,
      divider: const Color(0xFFE2E5E9),
    );
  }

  /// The colors the theme of [context] gives, or ones made from its
  /// brightness and `colorScheme.primary`.
  static NyFieldColors of(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.extension<NyFieldColors>() ??
        NyFieldColors.fromTheme(
          theme.brightness,
          accent: theme.colorScheme.primary,
        );
  }

  /// Black-ish or white, whichever reads on [color].
  static Color _readableOn(Color color) =>
      ThemeData.estimateBrightnessForColor(color) == Brightness.dark
      ? Colors.white
      : const Color(0xFF0B1A2E);

  /// Behind a field's text.
  final Color fill;

  /// Around a field.
  final Color border;

  /// A field's name, above it.
  final Color label;

  /// What's typed or chosen.
  final Color text;

  /// Hints and placeholders.
  final Color placeholder;

  /// Icons in a field.
  final Color icon;

  /// Focus, selections and controls that are on.
  final Color accent;

  /// Text in the accent's color, e.g. a slider's value.
  final Color accentText;

  /// Text and checkmarks on the accent.
  final Color onAccent;

  /// Errors.
  final Color error;

  /// Behind a field with an error.
  final Color errorFill;

  /// Behind a disabled field.
  final Color disabledFill;

  /// Around a disabled field.
  final Color disabledBorder;

  /// A disabled field's text and icons.
  final Color disabledText;

  /// Checkboxes, radios and switches that are off.
  final Color controlOff;

  /// A slider's track.
  final Color track;

  /// Behind a selected radio option.
  final Color selectedTint;

  /// Behind a selected chip.
  final Color chipSelected;

  /// Behind a picker's sheet.
  final Color sheet;

  /// Between rows, e.g. a picker's options.
  final Color divider;

  @override
  NyFieldColors copyWith({
    Color? fill,
    Color? border,
    Color? label,
    Color? text,
    Color? placeholder,
    Color? icon,
    Color? accent,
    Color? accentText,
    Color? onAccent,
    Color? error,
    Color? errorFill,
    Color? disabledFill,
    Color? disabledBorder,
    Color? disabledText,
    Color? controlOff,
    Color? track,
    Color? selectedTint,
    Color? chipSelected,
    Color? sheet,
    Color? divider,
  }) => NyFieldColors(
    fill: fill ?? this.fill,
    border: border ?? this.border,
    label: label ?? this.label,
    text: text ?? this.text,
    placeholder: placeholder ?? this.placeholder,
    icon: icon ?? this.icon,
    accent: accent ?? this.accent,
    accentText: accentText ?? this.accentText,
    onAccent: onAccent ?? this.onAccent,
    error: error ?? this.error,
    errorFill: errorFill ?? this.errorFill,
    disabledFill: disabledFill ?? this.disabledFill,
    disabledBorder: disabledBorder ?? this.disabledBorder,
    disabledText: disabledText ?? this.disabledText,
    controlOff: controlOff ?? this.controlOff,
    track: track ?? this.track,
    selectedTint: selectedTint ?? this.selectedTint,
    chipSelected: chipSelected ?? this.chipSelected,
    sheet: sheet ?? this.sheet,
    divider: divider ?? this.divider,
  );

  @override
  NyFieldColors lerp(covariant NyFieldColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return NyFieldColors(
      fill: mix(fill, other.fill),
      border: mix(border, other.border),
      label: mix(label, other.label),
      text: mix(text, other.text),
      placeholder: mix(placeholder, other.placeholder),
      icon: mix(icon, other.icon),
      accent: mix(accent, other.accent),
      accentText: mix(accentText, other.accentText),
      onAccent: mix(onAccent, other.onAccent),
      error: mix(error, other.error),
      errorFill: mix(errorFill, other.errorFill),
      disabledFill: mix(disabledFill, other.disabledFill),
      disabledBorder: mix(disabledBorder, other.disabledBorder),
      disabledText: mix(disabledText, other.disabledText),
      controlOff: mix(controlOff, other.controlOff),
      track: mix(track, other.track),
      selectedTint: mix(selectedTint, other.selectedTint),
      chipSelected: mix(chipSelected, other.chipSelected),
      sheet: mix(sheet, other.sheet),
      divider: mix(divider, other.divider),
    );
  }

  /// The label above a field, in [label] at 13 px.
  TextStyle get labelStyle =>
      TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: label);
}
