import 'dart:math' show max, min;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// A screenshot size an app store asks for.
///
/// ```dart
/// final Screenshot listing = await shot.forStore(
///   ScreenshotStore.ios69,
///   frame: true,
///   caption: 'Checkout in one tap',
/// );
/// ```
class ScreenshotStore {
  /// Creates a store size of [width] by [height] pixels, called [id].
  const ScreenshotStore(this.id, this.width, this.height, this.label);

  /// The id Metro takes, e.g. `ios-6.9`.
  final String id;

  /// The width in pixels.
  final int width;

  /// The height in pixels.
  final int height;

  /// What the size is for, e.g. `iPhone 6.9"`.
  final String label;

  /// App Store, 6.9" iPhone: 1320×2868.
  static const ScreenshotStore ios69 = ScreenshotStore(
    'ios-6.9',
    1320,
    2868,
    'iPhone 6.9"',
  );

  /// App Store, 6.5" iPhone: 1284×2778.
  static const ScreenshotStore ios65 = ScreenshotStore(
    'ios-6.5',
    1284,
    2778,
    'iPhone 6.5"',
  );

  /// App Store, 13" iPad: 2064×2752.
  static const ScreenshotStore ipad13 = ScreenshotStore(
    'ipad-13',
    2064,
    2752,
    'iPad 13"',
  );

  /// Google Play, phone: 1080×1920.
  static const ScreenshotStore playPhone = ScreenshotStore(
    'play-phone',
    1080,
    1920,
    'Google Play phone',
  );

  /// Google Play, 10" tablet: 1600×2560.
  static const ScreenshotStore playTablet = ScreenshotStore(
    'play-tablet',
    1600,
    2560,
    'Google Play tablet',
  );

  /// Every store size.
  static const List<ScreenshotStore> all = [
    ios69,
    ios65,
    ipad13,
    playPhone,
    playTablet,
  ];

  /// The store size with [id], or null.
  static ScreenshotStore? named(String id) {
    for (final ScreenshotStore store in all) {
      if (store.id == id) return store;
    }
    return null;
  }

  /// The size as Metro lists it.
  Map<String, Object?> toJson() => {
    'id': id,
    'width': width,
    'height': height,
    'label': label,
  };

  @override
  String toString() => '$id ($width×$height)';
}

/// Draws [source] onto a [width] by [height] canvas.
///
/// Without [frame], a screen of nearly the same shape fills the canvas and
/// any other is fitted inside it on [background]. With [frame], it's drawn
/// in a plain phone outline on [background], under [caption].
Future<ui.Image> composeScreenshot(
  ui.Image source, {
  required int width,
  required int height,
  bool frame = false,
  String? caption,
  Color? background,
  String? fontFamily,
}) async {
  final double w = width.toDouble();
  final double h = height.toDouble();
  final double sw = source.width.toDouble();
  final double sh = source.height.toDouble();
  final Color fill =
      background ?? (frame ? const Color(0xFFF2F4F6) : const Color(0xFFFFFFFF));
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = fill);
  final Paint image = Paint()..filterQuality = FilterQuality.high;
  final Rect whole = Rect.fromLTWH(0, 0, sw, sh);

  if (!frame) {
    // A screen within 3% of the store's shape fills it; others fit inside.
    final bool cover = ((sw / sh) - (w / h)).abs() / (w / h) < 0.03;
    final double scale = cover ? max(w / sw, h / sh) : min(w / sw, h / sh);
    canvas.drawImageRect(
      source,
      whole,
      Rect.fromCenter(
        center: Offset(w / 2, h / 2),
        width: sw * scale,
        height: sh * scale,
      ),
      image,
    );
  } else {
    double top = h * 0.05;
    if (caption != null && caption.trim().isNotEmpty) {
      final ui.ParagraphBuilder builder =
          ui.ParagraphBuilder(
              ui.ParagraphStyle(
                textAlign: TextAlign.center,
                maxLines: 3,
                fontFamily: fontFamily,
                fontSize: w * 0.06,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            )
            ..pushStyle(ui.TextStyle(color: _contrast(fill)))
            ..addText(caption.trim());
      final ui.Paragraph paragraph = builder.build()
        ..layout(ui.ParagraphConstraints(width: w * 0.84));
      canvas.drawParagraph(paragraph, Offset(w * 0.08, top));
      top += paragraph.height + h * 0.04;
    }

    // The outline is 3.5% of the phone's width on each side.
    final double screenAspect = sh / sw;
    final double available = h - top - h * 0.05;
    final double phoneWidth = min(
      w * 0.84,
      available / (0.93 * screenAspect + 0.07),
    );
    final double bezel = phoneWidth * 0.035;
    final double phoneHeight = phoneWidth * 0.93 * screenAspect + bezel * 2;
    final Rect phone = Rect.fromLTWH(
      (w - phoneWidth) / 2,
      top + (available - phoneHeight) / 2,
      phoneWidth,
      phoneHeight,
    );
    final double radius = phoneWidth * 0.13;
    final RRect outer = RRect.fromRectAndRadius(phone, Radius.circular(radius));
    final RRect inner = RRect.fromRectAndRadius(
      phone.deflate(bezel),
      Radius.circular(radius - bezel),
    );
    canvas.drawShadow(
      Path()..addRRect(outer),
      const Color(0xFF000000),
      phoneWidth * 0.03,
      false,
    );
    canvas.drawRRect(outer, Paint()..color = const Color(0xFF101214));
    canvas.save();
    canvas.clipRRect(inner);
    canvas.drawImageRect(source, whole, inner.outerRect, image);
    canvas.restore();
  }

  final ui.Picture picture = recorder.endRecording();
  try {
    return await picture.toImage(width, height);
  } finally {
    picture.dispose();
  }
}

/// Black or white, whichever reads better on [background].
Color _contrast(Color background) => background.computeLuminance() > 0.5
    ? const Color(0xFF161B22)
    : const Color(0xFFFFFFFF);
