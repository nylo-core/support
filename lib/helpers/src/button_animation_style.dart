import 'package:flutter/material.dart';

/// The type of button animation
enum ButtonAnimationType {
  none,
  clickable,
  bounce,
  pulse,
  squeeze,
  jelly,
  shine,
  ripple,
  morph,
  shake,
}

/// [ButtonAnimationStyle] defines composable animation styles for buttons.
/// Use factory constructors to create different animation effects.
class ButtonAnimationStyle {
  final ButtonAnimationType type;
  final Duration duration;
  final Curve curve;
  final bool enableHapticFeedback;

  // Animation-specific parameters
  final double? translateY;
  final double? shadowOffset;
  final double? scaleMin;
  final double? scaleMax;
  final double? pulseScale;
  final double? squeezeX;
  final double? squeezeY;
  final double? jellyStrength;
  final Color? shineColor;
  final double? shineWidth;
  final double? rippleScale;
  final double? morphRadius;
  final double? shakeOffset;
  final int? shakeCount;

  const ButtonAnimationStyle._({
    required this.type,
    required this.duration,
    required this.curve,
    this.enableHapticFeedback = false,
    this.translateY,
    this.shadowOffset,
    this.scaleMin,
    this.scaleMax,
    this.pulseScale,
    this.squeezeX,
    this.squeezeY,
    this.jellyStrength,
    this.shineColor,
    this.shineWidth,
    this.rippleScale,
    this.morphRadius,
    this.shakeOffset,
    this.shakeCount,
  });

  /// No animation (default behavior, backwards compatible)
  const ButtonAnimationStyle.none()
    : type = ButtonAnimationType.none,
      duration = Duration.zero,
      curve = Curves.linear,
      enableHapticFeedback = false,
      translateY = null,
      shadowOffset = null,
      scaleMin = null,
      scaleMax = null,
      pulseScale = null,
      squeezeX = null,
      squeezeY = null,
      jellyStrength = null,
      shineColor = null,
      shineWidth = null,
      rippleScale = null,
      morphRadius = null,
      shakeOffset = null,
      shakeCount = null;

  /// Duolingo-style 3D press effect with translateY and shadow
  /// Best for primary actions and game-like UX
  factory ButtonAnimationStyle.clickable({
    Duration duration = const Duration(milliseconds: 100),
    Curve curve = Curves.easeInOut,
    bool enableHapticFeedback = true,
    double translateY = 4.0,
    double shadowOffset = 4.0,
  }) {
    return ButtonAnimationStyle._(
      type: ButtonAnimationType.clickable,
      duration: duration,
      curve: curve,
      enableHapticFeedback: enableHapticFeedback,
      translateY: translateY,
      shadowOffset: shadowOffset,
    );
  }

  /// Scale down on press, spring back on release
  /// Best for add to cart, like buttons
  factory ButtonAnimationStyle.bounce({
    Duration duration = const Duration(milliseconds: 150),
    Curve curve = Curves.easeOutBack,
    bool enableHapticFeedback = true,
    double scaleMin = 0.92,
  }) {
    return ButtonAnimationStyle._(
      type: ButtonAnimationType.bounce,
      duration: duration,
      curve: curve,
      enableHapticFeedback: enableHapticFeedback,
      scaleMin: scaleMin,
    );
  }

  /// Subtle continuous scale pulse while pressed
  /// Best for long-press actions
  factory ButtonAnimationStyle.pulse({
    Duration duration = const Duration(milliseconds: 800),
    Curve curve = Curves.easeInOut,
    bool enableHapticFeedback = false,
    double pulseScale = 1.05,
  }) {
    return ButtonAnimationStyle._(
      type: ButtonAnimationType.pulse,
      duration: duration,
      curve: curve,
      enableHapticFeedback: enableHapticFeedback,
      pulseScale: pulseScale,
    );
  }

  /// Horizontal compress, vertical expand
  /// Best for playful interactions
  factory ButtonAnimationStyle.squeeze({
    Duration duration = const Duration(milliseconds: 120),
    Curve curve = Curves.easeInOut,
    bool enableHapticFeedback = true,
    double squeezeX = 0.95,
    double squeezeY = 1.05,
  }) {
    return ButtonAnimationStyle._(
      type: ButtonAnimationType.squeeze,
      duration: duration,
      curve: curve,
      enableHapticFeedback: enableHapticFeedback,
      squeezeX: squeezeX,
      squeezeY: squeezeY,
    );
  }

  /// Wobbly elastic deformation
  /// Best for fun/casual apps
  factory ButtonAnimationStyle.jelly({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.elasticOut,
    bool enableHapticFeedback = true,
    double jellyStrength = 0.15,
  }) {
    return ButtonAnimationStyle._(
      type: ButtonAnimationType.jelly,
      duration: duration,
      curve: curve,
      enableHapticFeedback: enableHapticFeedback,
      jellyStrength: jellyStrength,
    );
  }

  /// Glossy highlight sweep across button
  /// Best for premium features
  factory ButtonAnimationStyle.shine({
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.easeInOut,
    bool enableHapticFeedback = false,
    Color shineColor = Colors.white,
    double shineWidth = 0.3,
  }) {
    return ButtonAnimationStyle._(
      type: ButtonAnimationType.shine,
      duration: duration,
      curve: curve,
      enableHapticFeedback: enableHapticFeedback,
      shineColor: shineColor,
      shineWidth: shineWidth,
    );
  }

  /// Enhanced ripple from press point
  /// Best for material design emphasis
  factory ButtonAnimationStyle.ripple({
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOut,
    bool enableHapticFeedback = true,
    double rippleScale = 2.0,
  }) {
    return ButtonAnimationStyle._(
      type: ButtonAnimationType.ripple,
      duration: duration,
      curve: curve,
      enableHapticFeedback: enableHapticFeedback,
      rippleScale: rippleScale,
    );
  }

  /// Border radius increases on press
  /// Best for subtle feedback
  factory ButtonAnimationStyle.morph({
    Duration duration = const Duration(milliseconds: 150),
    Curve curve = Curves.easeInOut,
    bool enableHapticFeedback = false,
    double morphRadius = 24.0,
  }) {
    return ButtonAnimationStyle._(
      type: ButtonAnimationType.morph,
      duration: duration,
      curve: curve,
      enableHapticFeedback: enableHapticFeedback,
      morphRadius: morphRadius,
    );
  }

  /// Horizontal shake (programmatic trigger)
  /// Best for error states
  factory ButtonAnimationStyle.shake({
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeInOut,
    bool enableHapticFeedback = true,
    double shakeOffset = 8.0,
    int shakeCount = 3,
  }) {
    return ButtonAnimationStyle._(
      type: ButtonAnimationType.shake,
      duration: duration,
      curve: curve,
      enableHapticFeedback: enableHapticFeedback,
      shakeOffset: shakeOffset,
      shakeCount: shakeCount,
    );
  }

  /// Create a copy of this style with overridden properties
  ButtonAnimationStyle copyWith({
    ButtonAnimationType? type,
    Duration? duration,
    Curve? curve,
    bool? enableHapticFeedback,
    double? translateY,
    double? shadowOffset,
    double? scaleMin,
    double? scaleMax,
    double? pulseScale,
    double? squeezeX,
    double? squeezeY,
    double? jellyStrength,
    Color? shineColor,
    double? shineWidth,
    double? rippleScale,
    double? morphRadius,
    double? shakeOffset,
    int? shakeCount,
  }) {
    return ButtonAnimationStyle._(
      type: type ?? this.type,
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      translateY: translateY ?? this.translateY,
      shadowOffset: shadowOffset ?? this.shadowOffset,
      scaleMin: scaleMin ?? this.scaleMin,
      scaleMax: scaleMax ?? this.scaleMax,
      pulseScale: pulseScale ?? this.pulseScale,
      squeezeX: squeezeX ?? this.squeezeX,
      squeezeY: squeezeY ?? this.squeezeY,
      jellyStrength: jellyStrength ?? this.jellyStrength,
      shineColor: shineColor ?? this.shineColor,
      shineWidth: shineWidth ?? this.shineWidth,
      rippleScale: rippleScale ?? this.rippleScale,
      morphRadius: morphRadius ?? this.morphRadius,
      shakeOffset: shakeOffset ?? this.shakeOffset,
      shakeCount: shakeCount ?? this.shakeCount,
    );
  }
}
