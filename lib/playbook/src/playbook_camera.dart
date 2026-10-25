import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '/helpers/ny_helpers.dart';
import '/localization/ny_localization.dart';
import '/screenshot/ny_screenshot.dart';
import 'playbook_actor.dart';
import 'playbook_overlay.dart';
import 'playbook_step.dart';

/// Which screens a playbook run captures.
enum PlaybookScreenshots {
  /// Nothing.
  off,

  /// Only the screen at a failing step.
  failures,

  /// The `screenshot()` steps, and failing steps. What Metro asks for when
  /// no `--screenshots` is given.
  marked,

  /// The `screenshot()` steps of a playbook that has any, and every step of
  /// one that has none. Failing steps too.
  auto,

  /// Every step, the `screenshot()` steps, and failing steps.
  all;

  /// The mode called [name], or null.
  static PlaybookScreenshots? named(String name) {
    for (final PlaybookScreenshots mode in values) {
      if (mode.name == name) return mode;
    }
    return null;
  }
}

/// Why a [PlaybookShot] was taken.
enum PlaybookShotKind {
  /// A step finished, in a run capturing every step.
  step,

  /// A `screenshot()` step.
  marked,

  /// A step failed.
  failure,
}

/// One capture taken during a playbook run.
class PlaybookShot {
  /// Creates a shot.
  const PlaybookShot({
    required this.id,
    required this.kind,
    required this.screenshot,
    this.name,
    this.locale,
    this.theme,
    this.store,
    this.nativeFallback,
  });

  /// Creates a shot Metro took with the iOS Simulator or adb, for a
  /// `screenshot()` step. Metro saved the PNG itself.
  const PlaybookShot.native({
    required this.id,
    required this.name,
    this.locale,
    this.theme,
  }) : kind = PlaybookShotKind.marked,
       screenshot = null,
       store = null,
       nativeFallback = null;

  /// The id Metro collects it by, e.g. `s3`.
  final String id;

  /// Why it was taken.
  final PlaybookShotKind kind;

  /// The name given to `screenshot()`, for [PlaybookShotKind.marked].
  final String? name;

  /// The locale a `screenshot(locales: ...)` step took this shot in.
  final String? locale;

  /// The theme a `screenshot(themes: ...)` step took this shot in.
  final String? theme;

  /// The id of the store size it was converted to, e.g. `ios-6.9`.
  final String? store;

  /// Why Metro couldn't capture a `screenshot()` step it was asked for, so
  /// the app captured it instead, or null.
  final String? nativeFallback;

  /// The capture, or null for a [PlaybookShot.native] shot.
  final Screenshot? screenshot;

  /// Whether Metro took it with the iOS Simulator or adb.
  bool get isNative => screenshot == null;

  /// The PNG, or null for a [PlaybookShot.native] shot.
  Uint8List? get bytes => screenshot?.bytes;

  /// The shot as it's reported in a step event, without the PNG.
  Map<String, Object?> toJson() => {
    'id': id,
    'kind': kind.name,
    'name': ?name,
    'locale': ?locale,
    'theme': ?theme,
    'store': ?store,
    if (isNative) 'native': true,
    'nativeFallback': ?nativeFallback,
    'width': ?screenshot?.width,
    'height': ?screenshot?.height,
  };
}

/// A `screenshot()` step: the screen to capture, by [name], in each of
/// [locales] and [themes].
class PlaybookScreenshotStep extends PlaybookStep {
  /// Creates a step capturing the screen as [name].
  PlaybookScreenshotStep(
    this.name, {
    this.locales,
    this.themes,
    this.caption,
    this.native = true,
  }) : super('Screenshot $name', _settle);

  /// The name the capture is saved under.
  final String name;

  /// The language codes to capture the screen in, or null for the current
  /// one. [Screenshot.allLocales] is every bundled language.
  final List<String>? locales;

  /// The theme ids to capture the screen in, or null for the current one.
  /// [Screenshot.allThemes] is every registered theme.
  final List<String>? themes;

  /// The text above the screen when a run frames its screenshots. A
  /// translation key is translated into each locale the step captures.
  final String? caption;

  /// Whether Metro captures the whole screen with the iOS Simulator or
  /// adb, status bar and keyboard included, when it can. False always uses
  /// the app's own capture.
  final bool native;

  static Future<void> _settle(PlaybookActor actor) => actor.settle();
}

/// Asks Metro to capture the whole screen for the shot [id], and completes
/// once it has. Throws with the reason when it can't.
typedef PlaybookNative =
    Future<void> Function({
      required String id,
      required String name,
      String? locale,
      String? theme,
    });

/// Shows the app in a locale and theme and returns a function that puts
/// back the ones before, like [ScreenshotLook.show].
typedef PlaybookLook =
    Future<Future<void> Function()> Function({String? locale, String? theme});

/// Takes a playbook run's screenshots once each step settles.
///
/// Every Metro run has one, saving the `screenshot()` steps and failing
/// steps unless `--screenshots` asks for more or less. A run from code gets
/// one with `run(onScreenshot: ...)`. Shots go to [onShot] when it's given,
/// and otherwise wait in the app until Metro collects them with
/// `screenshot.get`.
class PlaybookCamera {
  /// Creates a camera capturing per [mode].
  ///
  /// [pixelRatio] is relative to the device's: 0.5 is half size. [capture]
  /// replaces the screen capture, [look] replaces [ScreenshotLook.show],
  /// and [looks] lists the bundled locales and the themes, for tests.
  ///
  /// [matrix] is the locale and theme Metro switched the app to for this
  /// pass of `--locales` / `--themes`. A `screenshot()` step with its own
  /// lists then captures only that cell, when its lists include it.
  ///
  /// With [store] or [frame], step and marked shots are converted with
  /// [Screenshot.forStore] or [Screenshot.framed], on [background]. Failure
  /// shots stay as they are. [compose] replaces that conversion, for tests.
  ///
  /// [native] asks Metro to capture `screenshot()` steps. Without it, and in
  /// runs with [store] or [frame], which convert the app's own capture,
  /// the app captures them.
  PlaybookCamera({
    required this.mode,
    this.pixelRatio = 1.0,
    this.onShot,
    this.matrix,
    this.store,
    this.frame = false,
    this.background,
    this.native,
    Future<Screenshot> Function(Screenshot shot, String? caption)? compose,
    Future<Screenshot> Function(double pixelRatio)? capture,
    PlaybookLook? look,
    Future<({List<String> locales, List<String> themes})> Function()? looks,
  }) : _composeOverride = compose,
       _capture = capture ?? _captureScreen,
       _look = look ?? ScreenshotLook.show,
       _looks = looks ?? _bundledLooks;

  /// Which screens are captured.
  final PlaybookScreenshots mode;

  /// The locale and theme of this pass of a Metro matrix, or null.
  final ({String? locale, String? theme})? matrix;

  /// The store size step and marked shots are converted to, or null.
  final ScreenshotStore? store;

  /// Whether step and marked shots are drawn in a phone outline.
  final bool frame;

  /// The color behind a converted shot.
  final Color? background;

  /// Asks Metro for a native capture, or null when nothing can take one.
  final PlaybookNative? native;

  final Future<Screenshot> Function(Screenshot shot, String? caption)?
  _composeOverride;

  /// Converts [shot] per [store] and [frame], with [caption] above it.
  Future<Screenshot> _convert(Screenshot shot, String? caption) {
    final Future<Screenshot> Function(Screenshot shot, String? caption)?
    compose = _composeOverride;
    if (compose != null) return compose(shot, caption);
    final ScreenshotStore? size = store;
    if (size != null) {
      return shot.forStore(
        size,
        frame: frame,
        caption: caption,
        background: background,
      );
    }
    return shot.framed(caption: caption, background: background);
  }

  bool get _converts => store != null || frame;

  /// The size relative to the device: 1.0 is the screen's own resolution.
  final double pixelRatio;

  /// Receives each shot instead of the app holding it for Metro.
  final void Function(PlaybookShot shot)? onShot;

  final Future<Screenshot> Function(double pixelRatio) _capture;
  final PlaybookLook _look;
  final Future<({List<String> locales, List<String> themes})> Function() _looks;

  static Future<({List<String> locales, List<String> themes})>
  _bundledLooks() async => (
    locales: await ScreenshotLook.bundledLocales(),
    themes: ScreenshotLook.themeIds,
  );

  /// How many shots the app holds for Metro before dropping the oldest.
  static const int maxHeld = 32;

  static int _counter = 0;
  static final LinkedHashMap<String, PlaybookShot> _held = LinkedHashMap();

  /// Removes and returns the held shot [id], or null when there's none.
  static PlaybookShot? collect(String id) => _held.remove(id);

  /// Drops every held shot.
  @visibleForTesting
  static void reset() {
    _held.clear();
    _counter = 0;
  }

  /// Whether a step list contains `screenshot()` steps, including inside
  /// its scenes.
  static bool hasMarks(List<PlaybookStep> steps) => steps.any(
    (PlaybookStep step) =>
        step is PlaybookScreenshotStep ||
        (step is PlaybookGroupStep && hasMarks(step.steps ?? const [])),
  );

  /// Takes the shot for [step], which [actor] just performed, when this run
  /// captures it. [everyStep] is false for a playbook with `screenshot()`
  /// steps. The shot waits for running animations to finish, so a tap that
  /// opens a page shows the page.
  ///
  /// A `screenshot()` step takes one shot for each of its locales and
  /// themes, switching the app in place and back again. When one can't be
  /// captured the step fails. Other captures are best effort.
  Future<List<PlaybookShot>> afterStep(
    PlaybookStep step,
    PlaybookActor actor, {
    required bool everyStep,
  }) async {
    if (step is PlaybookScreenshotStep) {
      if (mode == PlaybookScreenshots.off ||
          mode == PlaybookScreenshots.failures) {
        return const [];
      }
      final List<String?> locales = await _cells(
        step.locales,
        matrix?.locale,
        () async => (await _looks()).locales,
      );
      final List<String?> themes = await _cells(
        step.themes,
        matrix?.theme,
        () async => (await _looks()).themes,
      );
      return [
        for (final String? locale in locales)
          for (final String? theme in themes)
            await _marked(step, actor, locale: locale, theme: theme),
      ];
    }
    final bool capture = switch (mode) {
      PlaybookScreenshots.all => true,
      PlaybookScreenshots.auto => everyStep,
      _ => false,
    };
    if (!capture) return const [];
    await actor.settleAnimations();
    final PlaybookShot? shot = await _bestEffort(PlaybookShotKind.step);
    return [?shot];
  }

  /// The locales or themes a step captures: [wanted] (`*` for [every]),
  /// narrowed to [pass] in a matrix pass, or the current one for null.
  static Future<List<String?>> _cells(
    List<String>? wanted,
    String? pass,
    Future<List<String>> Function() every,
  ) async {
    if (wanted == null) return const [null];
    final List<String> list = wanted.contains('*')
        ? await every()
        : wanted.toSet().toList();
    if (pass == null) return list;
    return list.contains(pass) ? [pass] : const [];
  }

  Future<PlaybookShot> _marked(
    PlaybookScreenshotStep step,
    PlaybookActor actor, {
    String? locale,
    String? theme,
  }) async {
    Future<void> Function()? restore;
    try {
      // A matrix pass is already showing its own locale and theme.
      restore = await _look(
        locale: locale == matrix?.locale ? null : locale,
        theme: theme == matrix?.theme ? null : theme,
      );
      await actor.settleAnimations();
      String? fallback;
      final PlaybookNative? ask = native;
      if (step.native && ask != null && !_converts) {
        final String id = _nextId();
        fallback = await _askNative(
          actor,
          ask,
          id: id,
          name: step.name,
          locale: locale,
          theme: theme,
        );
        if (fallback == null) {
          return _keepNative(
            PlaybookShot.native(
              id: id,
              name: step.name,
              locale: locale,
              theme: theme,
            ),
          );
        }
      }
      Screenshot screenshot = await _take();
      if (_converts) {
        screenshot = await _convert(screenshot, step.caption?.tr());
      }
      return _keep(
        PlaybookShotKind.marked,
        screenshot,
        name: step.name,
        locale: locale,
        theme: theme,
        nativeFallback: fallback,
      );
    } catch (e) {
      final String look = [?locale, ?theme].join(' · ');
      throw PlaybookFailure(
        'Couldn\'t capture "${step.name}"${look.isEmpty ? '' : ' in $look'}: '
        '${e is StateError ? e.message : e}',
      );
    } finally {
      if (restore != null) {
        await restore();
        await actor.settleAnimations();
      }
    }
  }

  /// Takes the shot of a failing step as it is, unless the run captures
  /// nothing.
  Future<PlaybookShot?> afterFailure() async {
    if (mode == PlaybookScreenshots.off) return null;
    return _bestEffort(PlaybookShotKind.failure);
  }

  Future<PlaybookShot?> _bestEffort(PlaybookShotKind kind) async {
    try {
      Screenshot screenshot = await _take();
      if (kind == PlaybookShotKind.step && _converts) {
        screenshot = await _convert(screenshot, null);
      }
      return _keep(kind, screenshot);
    } catch (e) {
      NyLogger.error('[Playbook] Couldn\'t take a screenshot: $e');
      return null;
    }
  }

  Future<Screenshot> _take() => _capture(pixelRatio);

  String _nextId() => 's${++_counter}';

  /// Hides the finger and caption, asks Metro for the shot [id], and shows
  /// them again. Returns null once Metro has it, or why it couldn't.
  Future<String?> _askNative(
    PlaybookActor actor,
    PlaybookNative ask, {
    required String id,
    required String name,
    String? locale,
    String? theme,
  }) async {
    final PlaybookOverlay? overlay = actor.session.overlay;
    overlay?.hidden.value = true;
    try {
      // The OS captures what's on screen, so the overlay must be gone from it.
      await actor.settleAnimations();
      await ask(id: id, name: name, locale: locale, theme: theme);
      return null;
    } catch (e) {
      // Metro notes the reason under the shot.
      return e is StateError ? e.message : '$e';
    } finally {
      overlay?.hidden.value = false;
    }
  }

  PlaybookShot _keepNative(PlaybookShot shot) {
    onShot?.call(shot);
    return shot;
  }

  PlaybookShot _keep(
    PlaybookShotKind kind,
    Screenshot screenshot, {
    String? name,
    String? locale,
    String? theme,
    String? nativeFallback,
  }) {
    final PlaybookShot shot = PlaybookShot(
      id: _nextId(),
      kind: kind,
      name: name,
      locale: locale,
      theme: theme,
      store: kind == PlaybookShotKind.failure ? null : store?.id,
      screenshot: screenshot,
      nativeFallback: nativeFallback,
    );
    final void Function(PlaybookShot shot)? receive = onShot;
    if (receive != null) {
      receive(shot);
      return shot;
    }
    _held[shot.id] = shot;
    while (_held.length > maxHeld) {
      _held.remove(_held.keys.first);
    }
    return shot;
  }

  // The step has settled, so the frame on screen is the one to capture.
  static Future<Screenshot> _captureScreen(double pixelRatio) {
    final ui.FlutterView? view =
        WidgetsBinding.instance.platformDispatcher.implicitView;
    return Screenshot.capture(
      pixelRatio: (view?.devicePixelRatio ?? 1.0) * pixelRatio,
      settle: false,
    );
  }
}
