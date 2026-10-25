import 'dart:math' show max;

import 'package:flutter/widgets.dart';

import '/router/ny_router.dart';
import '/screenshot/ny_screenshot.dart';
import 'playbook_finder.dart';

/// Where a playbook's step caption is shown.
enum PlaybookCaption {
  /// Along the top of the screen, under the status bar.
  top,

  /// Along the bottom of the screen.
  bottom,

  /// No caption. The default.
  hidden,
}

/// The playbook's finger and step caption, drawn above the app.
///
/// The entry sits in an `IgnorePointer`, so it never takes a tap meant for
/// the app, and inside a [PlaybookOverlayScope], so finders skip it. In an
/// app with a [ScreenshotRoot], it's drawn above the screenshot boundary,
/// so screenshots leave it out while screen recordings show it.
class PlaybookOverlay {
  /// Creates an overlay showing captions at [caption].
  PlaybookOverlay({this.caption = PlaybookCaption.hidden});

  /// Where captions are shown.
  PlaybookCaption caption;

  /// Where the finger is, or null before it first moves.
  final ValueNotifier<Offset?> finger = ValueNotifier<Offset?>(null);

  /// Whether the finger is pressing.
  final ValueNotifier<bool> pressed = ValueNotifier<bool>(false);

  /// The caption text, or null for none.
  final ValueNotifier<String?> text = ValueNotifier<String?>(null);

  /// Whether the finger is drawn. It still moves while hidden.
  final ValueNotifier<bool> showFinger = ValueNotifier<bool>(false);

  /// The seconds left before the run starts, or null when it isn't counting
  /// down.
  final ValueNotifier<int?> countdown = ValueNotifier<int?>(null);

  /// Whether the whole overlay is hidden, e.g. while Metro captures the
  /// device's screen, which shows everything drawn above the app.
  final ValueNotifier<bool> hidden = ValueNotifier<bool>(false);

  OverlayEntry? _entry;
  OverlayState? _overlay;

  // OverlayEntry.mounted stays false until the entry is first built, so
  // insertion is tracked here.
  bool _inserted = false;

  /// Inserts the overlay above the screenshot boundary, or into the app's
  /// root overlay.
  ///
  /// Returns false when the app has no overlay to draw in.
  bool attach() {
    final OverlayState? overlay = _findOverlay();
    if (overlay == null) return false;
    _overlay = overlay;
    _entry ??= OverlayEntry(builder: _build);
    overlay.insert(_entry!);
    _inserted = true;
    return true;
  }

  /// Moves the overlay above anything inserted since, like a dialog.
  void bringToFront() {
    final OverlayEntry? entry = _entry;
    final OverlayState? overlay = _overlay;
    if (entry == null || overlay == null || !overlay.mounted) return;
    if (_inserted) {
      entry.remove();
      _inserted = false;
    }
    overlay.insert(entry);
    _inserted = true;
  }

  /// Removes the overlay and releases it.
  void detach() {
    final OverlayEntry? entry = _entry;
    if (entry != null) {
      if (_inserted) entry.remove();
      entry.dispose();
    }
    _inserted = false;
    _entry = null;
    _overlay = null;
    finger.dispose();
    pressed.dispose();
    text.dispose();
    showFinger.dispose();
    countdown.dispose();
    hidden.dispose();
  }

  static OverlayState? _findOverlay() {
    final OverlayState? top = Screenshot.overlayKey.currentState;
    if (top != null && top.mounted) return top;
    try {
      final OverlayState? overlay =
          NyNavigator.instance.router.navigatorKey?.currentState?.overlay;
      if (overlay != null && overlay.mounted) return overlay;
    } catch (_) {
      // Nylo's router isn't set up, e.g. in a plain widget test.
    }
    OverlayState? found;
    void visit(Element element) {
      if (found != null) return;
      if (element is StatefulElement && element.state is OverlayState) {
        found = element.state as OverlayState;
        return;
      }
      element.visitChildElements(visit);
    }

    WidgetsBinding.instance.rootElement?.visitChildElements(visit);
    return found;
  }

  Widget _build(BuildContext context) => PlaybookOverlayScope(
    child: IgnorePointer(
      child: ValueListenableBuilder<bool>(
        valueListenable: hidden,
        builder: (BuildContext context, bool isHidden, Widget? child) =>
            isHidden ? const SizedBox.shrink() : child!,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ListenableBuilder(
              listenable: Listenable.merge([finger, showFinger]),
              builder: (BuildContext context, Widget? child) {
                final Offset? position = finger.value;
                if (position == null || !showFinger.value) {
                  return const SizedBox.shrink();
                }
                return Positioned(
                  left: position.dx - 22,
                  top: position.dy - 22,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: pressed,
                    builder: (BuildContext context, bool down, Widget? child) =>
                        _Finger(pressed: down),
                  ),
                );
              },
            ),
            if (caption != PlaybookCaption.hidden)
              ValueListenableBuilder<String?>(
                valueListenable: text,
                builder: (BuildContext context, String? value, Widget? child) {
                  if (value == null || value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return _Caption(
                    text: value,
                    top: caption == PlaybookCaption.top,
                  );
                },
              ),
            ValueListenableBuilder<int?>(
              valueListenable: countdown,
              builder: (BuildContext context, int? left, Widget? child) =>
                  left == null
                  ? const SizedBox.shrink()
                  : _Countdown(left: left),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Finger extends StatelessWidget {
  const _Finger({required this.pressed});

  final bool pressed;

  static const Color _color = Color(0xFFFF8A00);

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 44,
    height: 44,
    child: Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: pressed ? 34 : 44,
        height: pressed ? 34 : 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _color.withValues(alpha: pressed ? 0.45 : 0.18),
          border: Border.all(color: _color, width: 3),
          boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 6)],
        ),
      ),
    ),
  );
}

class _Countdown extends StatelessWidget {
  const _Countdown({required this.left});

  final int left;

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 112,
      height: 112,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xE6202124),
      ),
      child: Text(
        '$left',
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 52,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.none,
        ),
      ),
    ),
  );
}

class _Caption extends StatelessWidget {
  const _Caption({required this.text, required this.top});

  final String text;
  final bool top;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding =
        MediaQuery.maybePaddingOf(context) ?? EdgeInsets.zero;
    // Sit above the keyboard while it's open, not behind it.
    final double keyboard = MediaQuery.maybeViewInsetsOf(context)?.bottom ?? 0;
    return Positioned(
      left: 16,
      right: 16,
      top: top ? padding.top + 8 : null,
      bottom: top ? null : max(keyboard, padding.bottom) + 16,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xE6202124),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}
