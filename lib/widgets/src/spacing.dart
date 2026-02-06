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
///
/// Using preset sizes:
/// ```dart
/// Column(
///   children: [
///     Text('First item'),
///     Spacing.sm, // Small vertical spacing
///     Text('Second item'),
///     Spacing.lg, // Large vertical spacing
///     Text('Third item'),
///   ],
/// )
/// ```
class Spacing extends StatelessWidget {
  /// Creates spacing with the specified [width] and [height].
  const Spacing({super.key, double? width, double? height})
    : _width = width,
      _height = height;

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

  /// Zero spacing - useful for conditional spacing.
  static const zero = Spacing.vertical(0);

  /// Extra small vertical spacing (4 logical pixels).
  static const xs = Spacing.vertical(4);

  /// Small vertical spacing (8 logical pixels).
  static const sm = Spacing.vertical(8);

  /// Medium vertical spacing (16 logical pixels).
  static const md = Spacing.vertical(16);

  /// Large vertical spacing (24 logical pixels).
  static const lg = Spacing.vertical(24);

  /// Extra large vertical spacing (32 logical pixels).
  static const xl = Spacing.vertical(32);

  /// Extra small horizontal spacing (4 logical pixels).
  static const xsHorizontal = Spacing.horizontal(4);

  /// Small horizontal spacing (8 logical pixels).
  static const smHorizontal = Spacing.horizontal(8);

  /// Medium horizontal spacing (16 logical pixels).
  static const mdHorizontal = Spacing.horizontal(16);

  /// Large horizontal spacing (24 logical pixels).
  static const lgHorizontal = Spacing.horizontal(24);

  /// Extra large horizontal spacing (32 logical pixels).
  static const xlHorizontal = Spacing.horizontal(32);

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: _width, height: _height);
  }

  /// Returns a [SliverToBoxAdapter] containing this spacing.
  /// Useful for adding spacing in [CustomScrollView] with slivers.
  Widget asSliver() {
    return SliverToBoxAdapter(child: this);
  }
}
