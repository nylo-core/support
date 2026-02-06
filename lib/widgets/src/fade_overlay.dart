import 'package:flutter/material.dart';

/// A widget that applies a gradient fade effect over its child.
///
/// Example:
/// ```dart
/// FadeOverlay(
///   child: Image.asset('background.jpg'),
///   strength: 0.5,
///   color: Colors.black,
/// )
/// ```
class FadeOverlay extends StatelessWidget {
  const FadeOverlay({
    super.key,
    required this.child,
    this.strength = 0.2,
    this.color = Colors.black,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
  }) : assert(
         strength >= 0.0 && strength <= 1.0,
         'strength must be between 0.0 and 1.0',
       );

  const FadeOverlay.top({
    super.key,
    required this.child,
    this.color = Colors.black,
    this.strength = 0.2,
  }) : begin = Alignment.bottomCenter,
       end = Alignment.topCenter;

  const FadeOverlay.bottom({
    super.key,
    required this.child,
    this.color = Colors.black,
    this.strength = 0.2,
  }) : begin = Alignment.topCenter,
       end = Alignment.bottomCenter;

  const FadeOverlay.left({
    super.key,
    required this.child,
    this.color = Colors.black,
    this.strength = 0.2,
  }) : begin = Alignment.centerRight,
       end = Alignment.centerLeft;

  const FadeOverlay.right({
    super.key,
    required this.child,
    this.color = Colors.black,
    this.strength = 0.2,
  }) : begin = Alignment.centerLeft,
       end = Alignment.centerRight;

  final Widget child;
  final Color color;

  /// Fade strength from 0.0 (subtle) to 1.0 (strong).
  final double strength;

  /// The gradient start alignment.
  final AlignmentGeometry begin;

  /// The gradient end alignment.
  final AlignmentGeometry end;

  @override
  Widget build(BuildContext context) {
    // Calculate gradient parameters based on strength
    final fadeStart = 1.0 - (strength * 0.5); // 0.9 to 0.5
    final alpha = (0.12 + (strength * 0.1)).clamp(0.0, 1.0); // 0.12 to 0.22

    final colors = [
      Colors.transparent,
      Colors.transparent,
      color.withAlpha((255 * alpha).round()),
      color,
    ];
    final stops = [0.0, 0.0, fadeStart, 1.0];

    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: begin,
                end: end,
                stops: stops,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
