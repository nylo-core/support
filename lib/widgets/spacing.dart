import 'package:flutter/material.dart';

/// A utility widget that creates consistent spacing between UI elements.
///
/// The [Spacing] class provides a clean way to add vertical or horizontal
/// spacing between widgets without manually creating [SizedBox] instances.
/// It supports two direction types and can be easily used within any widget tree.
///
/// Example usage:
/// ```dart
/// Column(
///   children: [
///     Text('First item'),
///     Spacing.vertical(16), // 16 logical pixels of vertical space
///     Text('Second item'),
///   ],
/// )
/// ```
class Spacing extends StatelessWidget {
  /// Creates vertical spacing with the specified [height].
  ///
  /// The [height] parameter defines the amount of vertical space in logical pixels.
  const Spacing.vertical(double height, {super.key})
      : _height = height,
        _width = null;

  /// Creates horizontal spacing with the specified [width].
  ///
  /// The [width] parameter defines the amount of horizontal space in logical pixels.
  const Spacing.horizontal(double width, {super.key})
      : _width = width,
        _height = null;

  /// The width of horizontal spacing (null for vertical spacing).
  final double? _width;

  /// The height of vertical spacing (null for horizontal spacing).
  final double? _height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      height: _height,
    );
  }
}
