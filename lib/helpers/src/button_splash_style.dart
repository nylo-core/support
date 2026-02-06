import 'package:flutter/material.dart';

/// The type of splash effect for buttons
enum ButtonSplashType {
  /// Standard Material ripple effect
  ripple,

  /// Subtle highlight without ripple
  highlight,

  /// Soft glow effect that fades from center
  glow,

  /// Ink splash that spreads quickly
  ink,

  /// No splash effect
  none,
}

/// [ButtonSplashStyle] defines customizable splash effects for buttons.
/// Use factory constructors to create different splash styles.
class ButtonSplashStyle {
  final ButtonSplashType type;
  final Color? splashColor;
  final Color? highlightColor;
  final double? splashOpacity;
  final double? highlightOpacity;
  final BorderRadius? borderRadius;
  final bool bounded;
  final Duration? animationDuration;
  final InteractiveInkFeatureFactory? splashFactory;

  /// Optional overlay color for WidgetStateProperty-based control.
  /// When set, this takes precedence over splashColor/highlightColor.
  final WidgetStateProperty<Color?>? overlayColor;

  const ButtonSplashStyle._({
    required this.type,
    this.splashColor,
    this.highlightColor,
    this.splashOpacity,
    this.highlightOpacity,
    this.borderRadius,
    this.bounded = true,
    this.animationDuration,
    this.splashFactory,
    this.overlayColor,
  });

  /// Standard Material ripple effect (default)
  /// Circular ripple expands from touch point
  factory ButtonSplashStyle.ripple({
    Color? splashColor,
    Color? highlightColor,
    double splashOpacity = 0.12,
    double highlightOpacity = 0.06,
    BorderRadius? borderRadius,
    WidgetStateProperty<Color?>? overlayColor,
  }) {
    return ButtonSplashStyle._(
      type: ButtonSplashType.ripple,
      splashColor: splashColor,
      highlightColor: highlightColor,
      splashOpacity: splashOpacity,
      highlightOpacity: highlightOpacity,
      borderRadius: borderRadius,
      splashFactory: InkRipple.splashFactory,
      overlayColor: overlayColor,
    );
  }

  /// Subtle highlight effect without ripple animation
  /// Good for minimal/clean designs
  factory ButtonSplashStyle.highlight({
    Color? highlightColor,
    double highlightOpacity = 0.08,
    BorderRadius? borderRadius,
    WidgetStateProperty<Color?>? overlayColor,
  }) {
    return ButtonSplashStyle._(
      type: ButtonSplashType.highlight,
      highlightColor: highlightColor,
      highlightOpacity: highlightOpacity,
      borderRadius: borderRadius,
      splashFactory: NoSplash.splashFactory,
      overlayColor: overlayColor,
    );
  }

  /// Soft glow effect that radiates from touch point
  /// Creates a softer, more organic feel
  factory ButtonSplashStyle.glow({
    Color? glowColor,
    double glowOpacity = 0.15,
    BorderRadius? borderRadius,
    WidgetStateProperty<Color?>? overlayColor,
  }) {
    return ButtonSplashStyle._(
      type: ButtonSplashType.glow,
      splashColor: glowColor,
      splashOpacity: glowOpacity,
      borderRadius: borderRadius,
      splashFactory: InkSparkle.splashFactory,
      overlayColor: overlayColor,
    );
  }

  /// Quick ink splash effect
  /// Faster, more responsive feel
  factory ButtonSplashStyle.ink({
    Color? inkColor,
    double inkOpacity = 0.1,
    BorderRadius? borderRadius,
    WidgetStateProperty<Color?>? overlayColor,
  }) {
    return ButtonSplashStyle._(
      type: ButtonSplashType.ink,
      splashColor: inkColor,
      splashOpacity: inkOpacity,
      borderRadius: borderRadius,
      splashFactory: InkSplash.splashFactory,
      overlayColor: overlayColor,
    );
  }

  /// No splash effect
  /// Clean press without visual feedback (use with animations instead)
  const ButtonSplashStyle.none()
    : type = ButtonSplashType.none,
      splashColor = null,
      highlightColor = null,
      splashOpacity = 0,
      highlightOpacity = 0,
      borderRadius = null,
      bounded = true,
      animationDuration = null,
      splashFactory = NoSplash.splashFactory,
      overlayColor = null;

  /// Custom splash with full control
  factory ButtonSplashStyle.custom({
    required InteractiveInkFeatureFactory splashFactory,
    Color? splashColor,
    Color? highlightColor,
    double splashOpacity = 0.12,
    double highlightOpacity = 0.06,
    BorderRadius? borderRadius,
    bool bounded = true,
    WidgetStateProperty<Color?>? overlayColor,
  }) {
    return ButtonSplashStyle._(
      type: ButtonSplashType.ripple,
      splashColor: splashColor,
      highlightColor: highlightColor,
      splashOpacity: splashOpacity,
      highlightOpacity: highlightOpacity,
      borderRadius: borderRadius,
      bounded: bounded,
      splashFactory: splashFactory,
      overlayColor: overlayColor,
    );
  }

  /// Get the resolved splash color with opacity applied
  Color getSplashColor(BuildContext context, Color fallbackColor) {
    if (type == ButtonSplashType.none) return Colors.transparent;
    final baseColor = splashColor ?? fallbackColor;
    return baseColor.withValues(alpha: splashOpacity ?? 0.12);
  }

  /// Get the resolved highlight color with opacity applied
  Color getHighlightColor(BuildContext context, Color fallbackColor) {
    if (type == ButtonSplashType.none) return Colors.transparent;
    final baseColor = highlightColor ?? fallbackColor;
    return baseColor.withValues(alpha: highlightOpacity ?? 0.06);
  }

  /// Get the resolved overlay color for InkWell.
  /// Returns transparent for [ButtonSplashType.none] to fully disable feedback.
  WidgetStateProperty<Color?>? getOverlayColor() {
    if (type == ButtonSplashType.none) {
      return const WidgetStatePropertyAll<Color?>(Colors.transparent);
    }
    return overlayColor;
  }

  /// Create a copy with modified properties
  ButtonSplashStyle copyWith({
    ButtonSplashType? type,
    Color? splashColor,
    Color? highlightColor,
    double? splashOpacity,
    double? highlightOpacity,
    BorderRadius? borderRadius,
    bool? bounded,
    Duration? animationDuration,
    InteractiveInkFeatureFactory? splashFactory,
    WidgetStateProperty<Color?>? overlayColor,
  }) {
    return ButtonSplashStyle._(
      type: type ?? this.type,
      splashColor: splashColor ?? this.splashColor,
      highlightColor: highlightColor ?? this.highlightColor,
      splashOpacity: splashOpacity ?? this.splashOpacity,
      highlightOpacity: highlightOpacity ?? this.highlightOpacity,
      borderRadius: borderRadius ?? this.borderRadius,
      bounded: bounded ?? this.bounded,
      animationDuration: animationDuration ?? this.animationDuration,
      splashFactory: splashFactory ?? this.splashFactory,
      overlayColor: overlayColor ?? this.overlayColor,
    );
  }
}
