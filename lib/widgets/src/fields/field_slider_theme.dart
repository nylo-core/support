import 'package:flutter/material.dart';

import 'field_colors.dart';

/// The slider look form fields share: a 4 px track in [colors], no tick
/// marks, and an accent thumb in a ring of [background], so it stands off
/// the track.
SliderThemeData fieldSliderTheme(
  BuildContext context,
  NyFieldColors colors, {
  Color? active,
  Color? inactive,
  Color? thumb,
}) {
  final Color background = Theme.of(context).scaffoldBackgroundColor;
  final Color accent = thumb ?? active ?? colors.accent;
  return SliderTheme.of(context).copyWith(
    trackHeight: 4,
    activeTrackColor: active ?? colors.accent,
    inactiveTrackColor: inactive ?? colors.track,
    activeTickMarkColor: Colors.transparent,
    inactiveTickMarkColor: Colors.transparent,
    disabledActiveTickMarkColor: Colors.transparent,
    disabledInactiveTickMarkColor: Colors.transparent,
    thumbColor: accent,
    overlayColor: accent.withValues(alpha: 0.16),
    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
    // Both tracks run the field's full width, so they line up with each
    // other and with the label; a thumb at either end overhangs by half.
    trackShape: const _InsetTrack(),
    rangeTrackShape: const _InsetRangeTrack(),
    thumbShape: _RingThumb(background),
    rangeThumbShape: _RingRangeThumb(background),
  );
}

/// How far a track starts in from each edge.
const double _inset = 0;

Rect _insetTrack(RenderBox parentBox, Offset offset, double? trackHeight) {
  final double height = trackHeight ?? 4;
  return Rect.fromLTWH(
    offset.dx + _inset,
    offset.dy + (parentBox.size.height - height) / 2,
    parentBox.size.width - _inset * 2,
    height,
  );
}

class _InsetTrack extends RoundedRectSliderTrackShape {
  const _InsetTrack();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) => _insetTrack(parentBox, offset, sliderTheme.trackHeight);
}

class _InsetRangeTrack extends RoundedRectRangeSliderTrackShape {
  const _InsetRangeTrack();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) => _insetTrack(parentBox, offset, sliderTheme.trackHeight);
}

/// Paints an accent dot in a ring of [ring], with a soft shadow.
void _paintRingThumb(Canvas canvas, Offset center, Color ring, Color fill) {
  const double radius = 11;
  canvas.drawShadow(
    Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    Colors.black,
    2,
    true,
  );
  canvas.drawCircle(center, radius, Paint()..color = ring);
  canvas.drawCircle(center, radius - 3, Paint()..color = fill);
}

class _RingThumb extends SliderComponentShape {
  const _RingThumb(this.ring);

  final Color ring;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(11);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) => _paintRingThumb(
    context.canvas,
    center,
    ring,
    sliderTheme.thumbColor ?? sliderTheme.activeTrackColor!,
  );
}

class _RingRangeThumb extends RangeSliderThumbShape {
  const _RingRangeThumb(this.ring);

  final Color ring;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(11);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool isOnTop = false,
    TextDirection textDirection = TextDirection.ltr,
    required SliderThemeData sliderTheme,
    Thumb thumb = Thumb.start,
    bool isPressed = false,
  }) => _paintRingThumb(
    context.canvas,
    center,
    ring,
    sliderTheme.thumbColor ?? sliderTheme.activeTrackColor!,
  );
}
