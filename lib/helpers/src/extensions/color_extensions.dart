import 'dart:ui';

extension ColorOpacityExt on Color {
  /// Returns a new color with the given [opacity] (0.0 to 1.0).
  /// Replacement for the deprecated `withOpacity` method.
  Color setOpacity(double opacity) {
    return withValues(alpha: opacity);
  }
}
