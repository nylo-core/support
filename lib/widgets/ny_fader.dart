import 'package:flutter/material.dart';

/// This is a custom widget that fades the child widget
/// with a gradient from top to bottom.
class NyFader extends StatelessWidget {
  /// NyFader default constructor
  NyFader(
      {Key? key,
      required this.child,
      this.strength = 1,
      this.color = Colors.black,
      this.alignment = const [Alignment.topCenter, Alignment.bottomCenter]}) {
    assert(strength >= 1 && strength <= 5, 'strength must be between 1 and 5');
    assert(alignment.length == 2,
        'alignment must be a list of 2 AlignmentGeometry objects');
  }

  /// NyFader from bottom to top
  NyFader.bottom(
      {required this.child,
      this.color = Colors.black,
      this.strength = 1,
      this.alignment = const [Alignment.topCenter, Alignment.bottomCenter]}) {
    assert(strength >= 1 && strength <= 5, 'strength must be between 1 and 5');
    assert(alignment.length == 2,
        'alignment must be a list of 2 AlignmentGeometry objects');
  }

  /// NyFader from top to bottom
  NyFader.top(
      {required this.child,
      this.color = Colors.black,
      this.strength = 1,
      this.alignment = const [Alignment.bottomCenter, Alignment.topCenter]}) {
    assert(strength >= 1 && strength <= 5, 'strength must be between 1 and 5');
    assert(alignment.length == 2,
        'alignment must be a list of 2 AlignmentGeometry objects');
  }

  /// NyFader from left to right
  NyFader.left(
      {required this.child,
      this.color = Colors.black,
      this.strength = 1,
      this.alignment = const [Alignment.centerLeft, Alignment.centerRight]}) {
    assert(strength >= 1 && strength <= 5, 'strength must be between 1 and 5');
    assert(alignment.length == 2,
        'alignment must be a list of 2 AlignmentGeometry objects');
  }

  /// NyFader from right to left
  NyFader.right(
      {required this.child,
      this.color = Colors.black,
      this.strength = 1,
      this.alignment = const [Alignment.centerRight, Alignment.topLeft]}) {
    assert(strength >= 1 && strength <= 5, 'strength must be between 1 and 5');
    assert(alignment.length == 2,
        'alignment must be a list of 2 AlignmentGeometry objects');
  }

  final Widget child;
  final Color color;
  final int strength;
  final List<AlignmentGeometry> alignment;

  @override
  Widget build(BuildContext context) {
    List<Color> colors = [];
    List<double>? stops = [];

    switch (strength) {
      case 1:
        colors = [
          Colors.transparent,
          Colors.transparent,
          color.withOpacity(0.12),
          color
        ];
        stops = [0, 0, 0.9, 1];
        break;
      case 2:
        colors = [
          Colors.transparent,
          Colors.transparent,
          color.withOpacity(0.2),
          color
        ];
        stops = [0, 0, 0.8, 1];
        break;
      case 3:
        colors = [
          Colors.transparent,
          Colors.transparent,
          color.withOpacity(0.22),
          color
        ];
        stops = [0, 0, 0.7, 1];
        break;
      case 4:
        colors = [
          Colors.transparent,
          Colors.transparent,
          color.withOpacity(0.22),
          color
        ];
        stops = [0, 0, 0.6, 1];
        break;
      case 5:
        colors = [
          Colors.transparent,
          Colors.transparent,
          color.withOpacity(0.2),
          color
        ];
        stops = [0, 0, 0.5, 1];
        break;
    }
    return Container(
      child: Stack(
        children: [
          Positioned.fill(
            child: child,
          ),
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: alignment[0],
                  end: alignment[1],
                  stops: stops,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
