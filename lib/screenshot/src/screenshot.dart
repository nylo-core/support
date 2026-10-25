import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart' show Theme, ThemeData;
import 'package:flutter/widgets.dart';

import '/file_storage/ny_file_storage.dart';
import '/themes/ny_themes.dart';
import 'screenshot_look.dart';
import 'screenshot_store.dart';

/// A PNG of the app's screen, or of one [ScreenshotArea].
///
/// ```dart
/// // The whole screen as the user sees it, dialogs and sheets included.
/// final Screenshot shot = await Screenshot.capture();
/// await shot.store('reports/checkout.png');
///
/// // One part of the screen, wrapped in a ScreenshotArea.
/// final Screenshot receipt = await Screenshot.area('receipt');
/// await receipt.store('order-1042.png', disk: 'public');
/// ```
///
/// Captures work in every build mode, so they can power app features like
/// sharing a receipt or attaching the screen to a bug report. Metro's
/// `screenshot` command uses the same code.
class Screenshot {
  /// Creates a screenshot from [bytes], a PNG of [width] by [height]
  /// physical pixels.
  const Screenshot({
    required this.bytes,
    required this.width,
    required this.height,
  });

  /// The PNG.
  final Uint8List bytes;

  /// The width in physical pixels.
  final int width;

  /// The height in physical pixels.
  final int height;

  /// The boundary around the app's screen, which `NyApp` places in its
  /// `MaterialApp.builder` through [ScreenshotRoot].
  static final GlobalKey rootKey = GlobalKey(debugLabel: 'Screenshot.root');

  /// The overlay above [rootKey], for things drawn over the app that stay
  /// out of captures, like a playbook's finger and captions.
  static final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>(
    debugLabel: 'Screenshot.overlay',
  );

  static final Map<String, _ScreenshotAreaState> _areas = {};

  /// The names of the [ScreenshotArea]s on screen.
  static List<String> get areas => _areas.keys.toList()..sort();

  /// Every language the app bundles a file for, for a playbook's
  /// `screenshot('cart', locales: Screenshot.allLocales)`.
  static const List<String> allLocales = ['*'];

  /// Every registered theme, for a playbook's
  /// `screenshot('cart', themes: Screenshot.allThemes)`.
  static const List<String> allThemes = ['*'];

  /// Captures the whole screen, dialogs and sheets included.
  ///
  /// [pixelRatio] defaults to the device's, so the PNG has the screen's
  /// native resolution. The capture waits for the next frame first, so
  /// anything just changed is drawn; pass `settle: false` when a frame has
  /// just been drawn.
  ///
  /// With [locale] (a language code) or [theme] (a theme id), the screen is
  /// shown that way for the capture and put back straight after, keeping
  /// the page and its state. See [ScreenshotLook].
  ///
  /// In an app built with `NyApp.materialApp`, or with a [ScreenshotRoot] in
  /// its `MaterialApp.builder`, the capture holds exactly the app's pages.
  /// Other apps get the whole Flutter view.
  static Future<Screenshot> capture({
    double? pixelRatio,
    bool settle = true,
    String? locale,
    String? theme,
  }) async {
    if (locale != null || theme != null) {
      return _inLook(
        locale,
        theme,
        () => capture(pixelRatio: pixelRatio, settle: false),
      );
    }
    return _hidingPrivate(settle, () {
      final RenderObject? boundary = rootKey.currentContext?.findRenderObject();
      if (boundary is RenderRepaintBoundary && boundary.attached) {
        return _fromBoundary(boundary, pixelRatio);
      }
      return _fromView(pixelRatio);
    });
  }

  /// Captures the [ScreenshotArea] called [name].
  ///
  /// [pixelRatio] defaults to the device's, and [locale] and [theme] work as
  /// they do for [capture]. Throws a [StateError] when no area with that
  /// name is on screen.
  static Future<Screenshot> area(
    String name, {
    double? pixelRatio,
    bool settle = true,
    String? locale,
    String? theme,
  }) async {
    if (locale != null || theme != null) {
      return _inLook(
        locale,
        theme,
        () => area(name, pixelRatio: pixelRatio, settle: false),
      );
    }
    return _hidingPrivate(settle, () {
      final RenderObject? boundary = _areas[name]?._boundaryKey.currentContext
          ?.findRenderObject();
      if (boundary is! RenderRepaintBoundary || !boundary.attached) {
        final List<String> names = areas;
        throw StateError(
          'There\'s no ScreenshotArea called "$name" on screen.'
          '${names.isEmpty ? '' : ' On screen: ${names.join(', ')}.'}',
        );
      }
      return _fromBoundary(boundary, pixelRatio);
    });
  }

  /// Captures [child] without showing it, e.g. a share card built just for
  /// the image.
  ///
  /// [child] is laid out within [size], or the screen's size, and the PNG
  /// is as big as [child] is: wrap it in a `SizedBox` for an exact size.
  /// [pixelRatio] defaults to the device's. With [context], [child] gets
  /// that context's theme, text direction, localizations and media query;
  /// otherwise it gets the app's current theme. [delay] gives images in
  /// [child] time to load before the capture. [ScreenshotHidden] widgets in
  /// [child] are hidden.
  static Future<Screenshot> widget(
    Widget child, {
    Size? size,
    double? pixelRatio,
    BuildContext? context,
    Duration delay = Duration.zero,
  }) async {
    final ui.FlutterView view =
        WidgetsBinding.instance.platformDispatcher.implicitView ??
        WidgetsBinding.instance.platformDispatcher.views.first;
    final double ratio = pixelRatio ?? view.devicePixelRatio;
    final Size bounds = size ?? view.physicalSize / view.devicePixelRatio;

    final Widget content = context == null
        ? MediaQuery(
            data: MediaQueryData(size: bounds, devicePixelRatio: ratio),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Theme(
                data: NyThemeManager.instance.themeData ?? ThemeData(),
                child: Builder(
                  builder: (BuildContext context) => DefaultTextStyle(
                    style:
                        Theme.of(context).textTheme.bodyMedium ??
                        const TextStyle(),
                    child: child,
                  ),
                ),
              ),
            ),
          )
        : InheritedTheme.captureAll(
            context,
            MediaQuery(
              data: MediaQuery.of(context).copyWith(size: bounds),
              child: Localizations.override(context: context, child: child),
            ),
          );

    final RenderRepaintBoundary boundary = RenderRepaintBoundary();
    final RenderView renderView = RenderView(
      view: view,
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints.tight(bounds),
        physicalConstraints: BoxConstraints.tight(bounds * ratio),
        devicePixelRatio: ratio,
      ),
      child: RenderPositionedBox(alignment: Alignment.topLeft, child: boundary),
    );
    final PipelineOwner pipelineOwner = PipelineOwner()..rootNode = renderView;
    renderView.prepareInitialFrame();
    final FocusManager focusManager = FocusManager();
    final BuildOwner buildOwner = BuildOwner(focusManager: focusManager);
    final RenderObjectToWidgetElement<RenderBox> root =
        RenderObjectToWidgetAdapter<RenderBox>(
          container: boundary,
          child: _Offscreen(child: content),
        ).attachToRenderTree(buildOwner);

    void draw() {
      buildOwner.buildScope(root);
      buildOwner.finalizeTree();
      pipelineOwner.flushLayout();
      pipelineOwner.flushCompositingBits();
      pipelineOwner.flushPaint();
    }

    try {
      draw();
      if (delay > Duration.zero) {
        await Future<void>.delayed(delay);
        draw();
      }
      final ui.Image image = await boundary.toImage(pixelRatio: ratio);
      return await _encode(image);
    } finally {
      // Unmount the tree so its states are disposed.
      RenderObjectToWidgetAdapter<RenderBox>(
        container: boundary,
      ).attachToRenderTree(buildOwner, root);
      buildOwner.buildScope(root);
      buildOwner.finalizeTree();
      focusManager.dispose();
    }
  }

  /// Saves the PNG to [path] on [disk], or on the default disk, and returns
  /// [path].
  Future<String> store(String path, {String? disk}) async {
    await FileStorage.disk(disk).put(path, bytes);
    return path;
  }

  /// This screenshot at the exact size [store] asks for.
  ///
  /// A screen of nearly the same shape fills the size, and any other is
  /// fitted inside it on [background]. With [frame], the screen is drawn in
  /// a plain phone outline on [background], under [caption].
  Future<Screenshot> forStore(
    ScreenshotStore store, {
    bool frame = false,
    String? caption,
    Color? background,
  }) => _compose(
    store.width,
    store.height,
    frame: frame,
    caption: caption,
    background: background,
  );

  /// This screenshot drawn in a plain phone outline on [background], under
  /// [caption], at its own size.
  Future<Screenshot> framed({String? caption, Color? background}) => _compose(
    width,
    height,
    frame: true,
    caption: caption,
    background: background,
  );

  Future<Screenshot> _compose(
    int width,
    int height, {
    required bool frame,
    String? caption,
    Color? background,
  }) async {
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.Image source = (await codec.getNextFrame()).image;
    codec.dispose();
    try {
      return await _encode(
        await composeScreenshot(
          source,
          width: width,
          height: height,
          frame: frame,
          caption: caption,
          background: background,
          fontFamily: NyThemeManager
              .instance
              .themeData
              ?.textTheme
              .titleLarge
              ?.fontFamily,
        ),
      );
    } finally {
      source.dispose();
    }
  }

  static Future<Screenshot> _inLook(
    String? locale,
    String? theme,
    Future<Screenshot> Function() take,
  ) async {
    final Future<void> Function() restore = await ScreenshotLook.show(
      locale: locale,
      theme: theme,
    );
    try {
      await settleAnimations();
      return await take();
    } finally {
      await restore();
    }
  }

  /// Waits for the next frame, then for running animations, like a theme
  /// fading in, to finish, for at most [timeout].
  static Future<void> settleAnimations({
    Duration timeout = const Duration(seconds: 1),
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    await _nextFrame();
    while (SchedulerBinding.instance.transientCallbackCount > 0 &&
        stopwatch.elapsed < timeout) {
      await _nextFrame();
    }
  }

  /// Above zero while a capture hides [ScreenshotHidden] widgets.
  static final ValueNotifier<int> _hiding = ValueNotifier<int>(0);
  static int _hidden = 0;

  /// Runs [take] with any [ScreenshotHidden] widgets showing their
  /// placeholder, which takes one frame to draw.
  static Future<Screenshot> _hidingPrivate(
    bool settle,
    Future<Screenshot> Function() take,
  ) async {
    if (_hidden == 0) {
      if (settle) await _nextFrame();
      return take();
    }
    _hiding.value++;
    try {
      await _nextFrame();
      return await take();
    } finally {
      _hiding.value--;
    }
  }

  static Future<void> _nextFrame() async {
    final SchedulerBinding binding = SchedulerBinding.instance;
    binding.scheduleFrame();
    await binding.endOfFrame;
  }

  static double _devicePixelRatio() {
    final ui.FlutterView? view =
        WidgetsBinding.instance.platformDispatcher.implicitView ??
        WidgetsBinding.instance.platformDispatcher.views.firstOrNull;
    return view?.devicePixelRatio ?? 1.0;
  }

  static Future<Screenshot> _fromBoundary(
    RenderRepaintBoundary boundary,
    double? pixelRatio,
  ) async {
    final ui.Image image = await boundary.toImage(
      pixelRatio: pixelRatio ?? _devicePixelRatio(),
    );
    return _encode(image);
  }

  static Future<Screenshot> _fromView(double? pixelRatio) async {
    final RenderView view = WidgetsBinding.instance.renderViews.first;
    // The root layer applies the device pixel ratio itself, so the bounds
    // are in physical pixels and the ratio is relative to the device.
    // ignore: invalid_use_of_protected_member
    final Layer? layer = view.layer;
    if (layer is! OffsetLayer) {
      throw StateError('The app hasn\'t drawn its first frame yet.');
    }
    final double device = view.flutterView.devicePixelRatio;
    final ui.Image image = await layer.toImage(
      Offset.zero & view.flutterView.physicalSize,
      pixelRatio: (pixelRatio ?? device) / device,
    );
    return _encode(image);
  }

  static Future<Screenshot> _encode(ui.Image image) async {
    try {
      final ByteData? data = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (data == null) {
        throw StateError('The screenshot couldn\'t be encoded.');
      }
      return Screenshot(
        bytes: data.buffer.asUint8List(),
        width: image.width,
        height: image.height,
      );
    } finally {
      image.dispose();
    }
  }
}

/// Marks part of the screen that [Screenshot.area] can capture by [name].
///
/// ```dart
/// ScreenshotArea(
///   name: 'receipt',
///   child: ReceiptCard(order: order),
/// );
///
/// final Screenshot receipt = await Screenshot.area('receipt');
/// ```
///
/// Metro captures it with `metro live:run screenshot --area receipt`.
class ScreenshotArea extends StatefulWidget {
  /// Creates an area called [name] around [child].
  const ScreenshotArea({super.key, required this.name, required this.child});

  /// The name [Screenshot.area] captures it by.
  final String name;

  /// What the area shows.
  final Widget child;

  @override
  State<ScreenshotArea> createState() => _ScreenshotAreaState();
}

class _ScreenshotAreaState extends State<ScreenshotArea> {
  final GlobalKey _boundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    Screenshot._areas[widget.name] = this;
  }

  @override
  void didUpdateWidget(ScreenshotArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.name == widget.name) return;
    _release(oldWidget.name);
    Screenshot._areas[widget.name] = this;
  }

  @override
  void dispose() {
    _release(widget.name);
    super.dispose();
  }

  void _release(String name) {
    if (identical(Screenshot._areas[name], this)) {
      Screenshot._areas.remove(name);
    }
  }

  @override
  Widget build(BuildContext context) =>
      RepaintBoundary(key: _boundaryKey, child: widget.child);
}

/// The boundary [Screenshot.capture] reads the app's screen from, with an
/// overlay above it for things that stay out of captures.
///
/// `NyApp.materialApp` adds one around its `builder`. An app that builds its
/// own `MaterialApp` adds it the same way:
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => ScreenshotRoot(child: child!),
/// )
/// ```
class ScreenshotRoot extends StatelessWidget {
  /// Creates the boundary around [child].
  const ScreenshotRoot({super.key, required this.child});

  /// The app's pages, usually the `child` of `MaterialApp.builder`.
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      RepaintBoundary(key: Screenshot.rootKey, child: child),
      Overlay(key: Screenshot.overlayKey),
    ],
  );
}

/// Hides [child] in every screenshot, e.g. an account number on a receipt
/// a user shares, or a card number in a store screenshot.
///
/// On screen [child] shows as usual. While a capture is taken, [replacement]
/// (a plain grey block by default) covers it at the same size. Showing the
/// placeholder takes one frame, so a screen recording can catch it.
class ScreenshotHidden extends StatefulWidget {
  /// Hides [child] in screenshots, showing [replacement] instead.
  const ScreenshotHidden({super.key, required this.child, this.replacement});

  /// What's hidden.
  final Widget child;

  /// What a screenshot shows in its place.
  final Widget? replacement;

  @override
  State<ScreenshotHidden> createState() => _ScreenshotHiddenState();
}

class _ScreenshotHiddenState extends State<ScreenshotHidden> {
  @override
  void initState() {
    super.initState();
    Screenshot._hidden++;
  }

  @override
  void dispose() {
    Screenshot._hidden--;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool offscreen =
        context.dependOnInheritedWidgetOfExactType<_Offscreen>() != null;
    return ValueListenableBuilder<int>(
      valueListenable: Screenshot._hiding,
      child: widget.child,
      builder: (BuildContext context, int hiding, Widget? child) => Stack(
        fit: StackFit.passthrough,
        children: [
          child!,
          if (offscreen || hiding > 0)
            Positioned.fill(
              child:
                  widget.replacement ??
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFF9AA4B1),
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                  ),
            ),
        ],
      ),
    );
  }
}

/// Marks a tree [Screenshot.widget] renders, where [ScreenshotHidden]
/// always shows its placeholder.
class _Offscreen extends InheritedWidget {
  const _Offscreen({required super.child});

  @override
  bool updateShouldNotify(_Offscreen oldWidget) => false;
}
