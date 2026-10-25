import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/widgets.dart';

import '/live/src/seed_recorder.dart';
import '/live/src/seeder.dart';
import '/nylo.dart';
import '/router/ny_router.dart' show RouteView;
import 'playbook_actor.dart';
import 'playbook_camera.dart';
import 'playbook_clock.dart';
import 'playbook_finder.dart';
import 'playbook_overlay.dart';
import 'playbook_registry.dart';
import 'playbook_report.dart';
import 'playbook_speed.dart';
import 'playbook_step.dart';

/// A user journey your app performs on itself: taps, typing, scrolling and
/// page changes, at a natural, fast or slow pace. Override [showFinger] and
/// [caption] to show a finger and a caption for each step.
///
/// Playbooks run in debug and profile builds only. In a release build
/// [run] throws and nothing can be registered, so a journey can't drive a
/// user's app.
///
/// List the [steps] with the verbs a playbook inherits:
///
/// ```dart
/// class SignUpPlaybook extends Playbook {
///   @override
///   String get description => 'New user signs up and lands on the dashboard';
///
///   @override
///   Map<String, dynamic> get defaults => {'email': 'demo@nylo.dev'};
///
///   @override
///   Future<void> setUp(PlaybookActor actor) async {
///     await Auth.logout();
///   }
///
///   @override
///   List<PlaybookStep> get steps => [
///     visit(SignUpPage.path),
///     type('Email', data['email']),
///     type('Password', 'secret123', secret: true),
///     tap('Create account'),
///     waitForPage(DashboardPage.path),
///     see('Welcome, ${data['email']}'),
///   ];
/// }
/// ```
///
/// Create one with `metro make:playbook sign_up`. Run it while the app is
/// running with `metro live:run playbook sign_up`, from Dart with [run], or
/// in a widget test with `run(clock: NyTesterClock(tester))`.
///
/// A plain string target is matched the way a person reads the screen:
/// visible text, then a field's hint or label, then a tooltip, a semantics
/// label, a `ValueKey`, and finally text that contains it. Use [Find] for
/// anything more precise.
abstract class Playbook {
  /// One line shown next to the playbook's name when Metro lists them.
  String? get description => null;

  /// The name this playbook runs by when it isn't registered with Nylo.
  ///
  /// Registered playbooks run under their key in the registry, and others
  /// under their class name in snake case (`SignUpPlaybook` is `sign_up`),
  /// so most playbooks leave this null.
  String? get name => null;

  /// The pace the playbook runs at when nothing else says.
  ///
  /// A speed passed to [run], `--speed` from Metro, or the speed of a
  /// playbook that plays this one wins.
  PlaybookSpeed get speed => PlaybookSpeed.natural;

  /// Where each step's caption is shown: nowhere by default.
  ///
  /// Override it with [PlaybookCaption.bottom] or [PlaybookCaption.top] to
  /// show what each step is doing, e.g. for a tutorial.
  PlaybookCaption get caption => PlaybookCaption.hidden;

  /// Whether a finger is drawn where this playbook's steps touch the
  /// screen. False by default.
  ///
  /// Taps and swipes happen either way. A playbook played by this one uses
  /// its own setting, and this one's comes back when it finishes.
  bool get showFinger => false;

  /// The data the steps start with. A run can override any of it.
  Map<String, dynamic> get defaults => const {};

  /// The data for this run: [defaults], overridden by what the run passed.
  ///
  /// Outside a run this is [defaults], so another playbook can spread this
  /// one's steps with `...SignUpPlaybook().steps`.
  Map<String, dynamic> get data => _data ?? defaults;
  Map<String, dynamic>? _data;

  /// Runs before the steps, e.g. to sign out or seed data.
  Future<void> setUp(PlaybookActor actor) async {}

  /// Runs after the steps, even when one failed.
  ///
  /// It also runs when this playbook is played by another one, so keep it
  /// to cleanup that's safe in the middle of a journey.
  Future<void> tearDown(PlaybookActor actor) async {}

  /// The steps, in order. Read after [setUp], so they can use [data].
  List<PlaybookStep> get steps;

  /// How deeply `play()` can nest playbooks.
  static const int maxDepth = 8;

  static PlaybookSession? _active;

  /// Makes this build act like a release build, for tests.
  @visibleForTesting
  static bool debugReleaseModeOverride = false;

  /// Whether playbooks can run in this build: false in release builds.
  static bool get isAvailable => !(kReleaseMode || debugReleaseModeOverride);

  /// Whether a playbook is running in this app.
  static bool get isRunning => _active != null;

  /// Asks the running playbook to stop at its next wait.
  ///
  /// The remaining steps are reported as skipped and [tearDown] still runs.
  /// Returns false when nothing is running.
  static bool stop() {
    final PlaybookSession? session = _active;
    if (session == null) return false;
    session.stopRequested = true;
    return true;
  }

  /// Runs the playbook and returns its report.
  ///
  /// [speed] overrides [Playbook.speed] and [data] overrides [defaults].
  /// Pass `NyTesterClock(tester)` as [clock] in a widget test. Without
  /// [overlay], no finger or caption is drawn.
  ///
  /// [onScreenshot] receives the run's screenshots, chosen by [screenshots]
  /// ([PlaybookScreenshots.auto] when it's null). [pixelRatio] sizes them
  /// relative to the device.
  ///
  /// A failing step doesn't throw: check [PlaybookReport.passed].
  Future<PlaybookReport> run({
    PlaybookSpeed? speed,
    Map<String, dynamic>? data,
    PlaybookClock? clock,
    bool overlay = true,
    void Function(Map<String, Object?> event)? onEvent,
    void Function(PlaybookShot shot)? onScreenshot,
    PlaybookScreenshots? screenshots,
    double pixelRatio = 1.0,
  }) async {
    final PlaybookSession session = await open(
      clock: clock,
      overlay: overlay,
      caption: caption,
      camera: onScreenshot == null
          ? null
          : PlaybookCamera(
              mode: screenshots ?? PlaybookScreenshots.auto,
              pixelRatio: pixelRatio,
              onShot: onScreenshot,
            ),
    );
    try {
      return await runWith(session, speed: speed, data: data, emit: onEvent);
    } finally {
      close(session);
    }
  }

  /// Starts a run: waits for the app's first frame and shows the overlay.
  ///
  /// [camera] takes the run's screenshots. Every [open] needs a [close].
  /// Use [run] unless you're running several playbooks back to back in one
  /// session.
  static Future<PlaybookSession> open({
    PlaybookClock? clock,
    bool overlay = true,
    PlaybookCaption caption = PlaybookCaption.hidden,
    PlaybookCamera? camera,
  }) async {
    if (!isAvailable) {
      throw UnsupportedError('Playbooks don\'t run in release builds.');
    }
    if (_active != null) {
      throw StateError(
        'A playbook is already running. Use play() to run one inside '
        'another.',
      );
    }
    final PlaybookClock time = clock ?? LivePlaybookClock();
    final PlaybookOverlay? layer = overlay
        ? PlaybookOverlay(caption: caption)
        : null;
    final PlaybookSession session = PlaybookSession(
      clock: time,
      overlay: layer,
      camera: camera,
    );
    _active = session;
    try {
      // Pointer events are locked until the warm-up frame is done.
      final Duration start = time.elapsed;
      while (WidgetsBinding.instance.rootElement == null &&
          time.elapsed - start < const Duration(seconds: 10)) {
        await time.wait(const Duration(milliseconds: 50));
      }
      await time.frame();
      if (layer != null && !layer.attach()) {
        layer.detach();
        return _active = PlaybookSession(clock: time, camera: camera);
      }
      await time.frame();
      return session;
    } catch (_) {
      _active = null;
      layer?.detach();
      rethrow;
    }
  }

  /// Ends a run started with [open] and removes its overlay.
  static void close(PlaybookSession session) {
    session.overlay?.detach();
    if (identical(_active, session)) _active = null;
  }

  /// Runs this playbook inside [session], which [open] started.
  ///
  /// `play()` and Metro's runner use this; most code calls [run]. [path]
  /// lists the playbooks this one runs inside, [caption] is the caption
  /// prefix of the step that plays it, and [emit] receives the run's events.
  Future<PlaybookReport> runWith(
    PlaybookSession session, {
    PlaybookSpeed? speed,
    Map<String, dynamic>? data,
    void Function(Map<String, Object?> event)? emit,
    List<String> path = const [],
    int depth = 0,
    String caption = '',
  }) async {
    final String name = PlaybookRegistry.nameOf(this);
    if (path.contains(name)) {
      throw PlaybookFailure('Playbook cycle: ${[...path, name].join(' → ')}');
    }
    if (path.length >= maxDepth) {
      throw PlaybookFailure(
        'Playbooks nest at most $maxDepth deep: ${[...path, name].join(' → ')}',
      );
    }

    final PlaybookSpeed pace = speed ?? this.speed;
    final Map<String, dynamic> merged = {...defaults, ...?data};
    final PlaybookActor actor = PlaybookActor(
      session: session,
      speed: pace,
      data: merged,
    );
    final List<String> chain = [...path, name];
    PlaybookStepContext context = PlaybookStepContext(
      playbook: name,
      path: chain,
      depth: depth,
      caption: caption,
      emit: emit,
    );
    final PlaybookClock clock = session.clock;
    final Duration start = clock.elapsed;
    final List<PlaybookStepResult> results = [];
    List<PlaybookStep> list = const [];
    PlaybookStepResult? setUpFailure;

    final ValueNotifier<bool>? finger = session.overlay?.showFinger;
    final bool? fingerBefore = finger?.value;
    finger?.value = showFinger;
    _data = merged;
    try {
      try {
        await setUp(actor);
        list = steps;
        if (PlaybookCamera.hasMarks(list)) {
          context = PlaybookStepContext(
            playbook: name,
            path: chain,
            depth: depth,
            caption: caption,
            emit: emit,
            everyStep: false,
          );
        }
      } on PlaybookStopped {
        // Reported below as a stopped run.
      } catch (e) {
        setUpFailure = PlaybookStepResult(
          title: 'Set up',
          status: PlaybookStepStatus.failed,
          elapsed: clock.elapsed - start,
          error: _describe(e),
        );
      }

      emit?.call({
        'event': 'start',
        'name': name,
        'speed': pace.name,
        'total': list.length,
        'depth': depth,
        'path': chain,
      });
      if (setUpFailure != null) {
        results.add(setUpFailure);
        _emitStep(emit, context, 0, list.length, setUpFailure, group: false);
      }

      results.addAll(
        await runSteps(
          actor,
          list,
          context,
          skipAll: setUpFailure != null || session.stopRequested,
        ),
      );

      final Duration tearDownStart = clock.elapsed;
      actor.ignoreStop = true;
      try {
        await tearDown(actor);
      } catch (e) {
        final PlaybookStepResult failure = PlaybookStepResult(
          title: 'Tear down',
          status: PlaybookStepStatus.failed,
          elapsed: clock.elapsed - tearDownStart,
          error: _describe(e),
        );
        results.add(failure);
        _emitStep(emit, context, 0, list.length, failure, group: false);
      } finally {
        actor.ignoreStop = false;
      }
    } finally {
      _data = null;
      if (fingerBefore != null) finger?.value = fingerBefore;
    }

    final PlaybookReport report = PlaybookReport(
      name: name,
      speed: pace.name,
      steps: results,
      elapsed: clock.elapsed - start,
      stopped: session.stopRequested,
    );
    emit?.call({
      'event': 'finish',
      'name': name,
      'speed': pace.name,
      'depth': depth,
      'path': chain,
      'passed': report.passed,
      'stopped': report.stopped,
      'ms': report.elapsed.inMilliseconds,
      if (depth == 0) 'report': report.toJson(),
    });
    return report;
  }

  /// Runs [steps] in order with [actor], stopping at the first failure.
  ///
  /// Steps after a failure, or every step when [skipAll], are reported as
  /// skipped.
  static Future<List<PlaybookStepResult>> runSteps(
    PlaybookActor actor,
    List<PlaybookStep> steps,
    PlaybookStepContext context, {
    bool skipAll = false,
  }) async {
    final PlaybookSession session = actor.session;
    final PlaybookClock clock = session.clock;
    final List<PlaybookStepResult> results = [];
    final int total = steps.length;
    bool halted = skipAll;

    for (int i = 0; i < total; i++) {
      final PlaybookStep step = steps[i];
      final int index = i + 1;
      final bool group = step is PlaybookGroupStep;
      if (halted || session.stopRequested) {
        final PlaybookStepResult skipped = PlaybookStepResult(
          title: step.title,
          status: PlaybookStepStatus.skipped,
        );
        results.add(skipped);
        _emitStep(context.emit, context, index, total, skipped, group: group);
        continue;
      }

      context.emit?.call({
        'event': 'begin',
        'name': context.playbook,
        'index': index,
        'total': total,
        'title': step.title,
        'depth': context.depth,
        'group': group,
      });
      final PlaybookOverlay? overlay = session.overlay;
      if (overlay != null) {
        overlay.text.value = '${context.caption}$index/$total · ${step.title}';
        overlay.bringToFront();
      }

      final Duration start = clock.elapsed;
      final PlaybookCamera? camera = session.camera;
      final List<PlaybookShot> shots = [];
      PlaybookStepResult result;
      try {
        if (step is PlaybookGroupStep) {
          final List<PlaybookStepResult> children = await step.group(
            actor,
            context.nested(index: index, total: total, title: step.title),
          );
          result = _groupResult(step.title, children, clock.elapsed - start);
        } else {
          await step.action(actor);
          await actor.settle();
          shots.addAll(
            await camera?.afterStep(
                  step,
                  actor,
                  everyStep: context.everyStep,
                ) ??
                const [],
          );
          result = PlaybookStepResult(
            title: step.title,
            status: PlaybookStepStatus.passed,
            elapsed: clock.elapsed - start,
          );
        }
      } on PlaybookStopped {
        result = PlaybookStepResult(
          title: step.title,
          status: PlaybookStepStatus.skipped,
          elapsed: clock.elapsed - start,
          error: 'Stopped',
        );
      } on PlaybookFailure catch (e) {
        result = PlaybookStepResult(
          title: step.title,
          status: PlaybookStepStatus.failed,
          elapsed: clock.elapsed - start,
          error: e.message,
          visibleText: e.visibleText,
        );
      } catch (e) {
        result = PlaybookStepResult(
          title: step.title,
          status: PlaybookStepStatus.failed,
          elapsed: clock.elapsed - start,
          error: _describe(e),
          visibleText: PlaybookTree(
            WidgetsBinding.instance.rootElement,
          ).visibleText(),
        );
      }

      // A group whose own steps failed already captured the failure.
      final bool failedInside = result.steps.any(
        (PlaybookStepResult child) => child.status == PlaybookStepStatus.failed,
      );
      if (result.status == PlaybookStepStatus.failed && !failedInside) {
        final PlaybookShot? shot = await camera?.afterFailure();
        if (shot != null) shots.add(shot);
      }

      results.add(result);
      _emitStep(
        context.emit,
        context,
        index,
        total,
        result,
        group: group,
        shots: shots,
      );
      if (result.status == PlaybookStepStatus.failed) {
        halted = true;
      } else if (index < total) {
        try {
          await actor.wait(actor.speed.betweenSteps);
        } on PlaybookStopped {
          // The next step is reported as skipped.
        }
      }
    }
    return results;
  }

  static PlaybookStepResult _groupResult(
    String title,
    List<PlaybookStepResult> children,
    Duration elapsed,
  ) {
    PlaybookStepResult? deepestFailure(List<PlaybookStepResult> results) {
      for (final PlaybookStepResult result in results) {
        if (result.status != PlaybookStepStatus.failed) continue;
        return deepestFailure(result.steps) ?? result;
      }
      return null;
    }

    final PlaybookStepResult? failure = deepestFailure(children);
    final bool stopped = children.any(
      (PlaybookStepResult child) => child.error == 'Stopped',
    );
    return PlaybookStepResult(
      title: title,
      status: failure != null
          ? PlaybookStepStatus.failed
          : stopped
          ? PlaybookStepStatus.skipped
          : PlaybookStepStatus.passed,
      elapsed: elapsed,
      error: failure?.error ?? (stopped ? 'Stopped' : null),
      visibleText: failure?.visibleText ?? const [],
      steps: children,
    );
  }

  static void _emitStep(
    void Function(Map<String, Object?> event)? emit,
    PlaybookStepContext context,
    int index,
    int total,
    PlaybookStepResult result, {
    required bool group,
    List<PlaybookShot> shots = const [],
  }) {
    emit?.call({
      'event': 'step',
      'name': context.playbook,
      'index': index,
      'total': total,
      'title': result.title,
      'depth': context.depth,
      'group': group,
      'status': result.status.name,
      'ms': result.elapsed.inMilliseconds,
      if (result.error != null) 'error': result.error,
      if (result.visibleText.isNotEmpty) 'visible': result.visibleText,
      if (shots.isNotEmpty)
        'shots': [for (final PlaybookShot shot in shots) shot.toJson()],
    });
  }

  static String _describe(Object error) =>
      error is PlaybookFailure ? error.message : error.toString();

  // ---------------------------------------------------------------------------
  // Verbs
  // ---------------------------------------------------------------------------

  /// Taps [target].
  ///
  /// [target] is a [String], [Key], [Type], [IconData] or a [Find] finder.
  PlaybookStep tap(Object target) {
    final PlaybookFinder finder = Find.target(target);
    return PlaybookStep(
      'Tap ${finder.description}',
      (PlaybookActor actor) => actor.tap(finder),
    );
  }

  /// Presses and holds [target].
  PlaybookStep longPress(Object target) {
    final PlaybookFinder finder = Find.target(target);
    return PlaybookStep(
      'Long press ${finder.description}',
      (PlaybookActor actor) => actor.longPress(finder),
    );
  }

  /// Types [text] into the field [target], found by its hint or label.
  ///
  /// The field is cleared first unless [clear] is false. [submit] presses
  /// the keyboard's action button afterwards. With [secret], the text is
  /// hidden in the caption and the report.
  PlaybookStep type(
    Object target,
    Object? text, {
    bool clear = true,
    bool submit = false,
    bool secret = false,
  }) {
    final PlaybookFinder finder = Find.target(target);
    final String value = '${text ?? ''}';
    final String shown = secret ? '•' * value.length : value;
    return PlaybookStep(
      'Type "$shown" into ${finder.description}',
      (PlaybookActor actor) =>
          actor.type(finder, value, clear: clear, submit: submit),
    );
  }

  /// Scrolls until [target] is on screen.
  ///
  /// Swipes the largest scrollable on screen, or the one [within] finds.
  PlaybookStep scrollTo(Object target, {Object? within}) {
    final PlaybookFinder finder = Find.target(target);
    final PlaybookFinder? container = within == null
        ? null
        : Find.target(within);
    return PlaybookStep(
      'Scroll to ${finder.description}',
      (PlaybookActor actor) => actor.scrollTo(finder, within: container),
    );
  }

  /// Checks that [target] is on screen, waiting for it to show up.
  PlaybookStep see(Object target) {
    final PlaybookFinder finder = Find.target(target);
    return PlaybookStep(
      'See ${finder.description}',
      (PlaybookActor actor) => actor.see(finder),
    );
  }

  /// Checks that [target] isn't on screen, waiting for it to go.
  PlaybookStep dontSee(Object target) {
    final PlaybookFinder finder = Find.target(target);
    return PlaybookStep(
      'Don\'t see ${finder.description}',
      (PlaybookActor actor) => actor.dontSee(finder),
    );
  }

  /// Waits up to [timeout] (10 seconds by default) for [target].
  PlaybookStep waitFor(Object target, {Duration? timeout}) {
    final PlaybookFinder finder = Find.target(target);
    return PlaybookStep(
      'Wait for ${finder.description}',
      (PlaybookActor actor) => actor.waitFor(finder, timeout: timeout),
    );
  }

  /// Waits for the page at [path] to be on screen.
  ///
  /// [path] is a route path or a page's `RouteView`, e.g. `HomePage.path`.
  PlaybookStep waitForPage(Object path, {Duration? timeout}) {
    final String route = _path(path);
    return PlaybookStep(
      'Wait for page $route',
      (PlaybookActor actor) => actor.waitForPage(route, timeout: timeout),
    );
  }

  /// Opens the page at [path], passing it [data].
  ///
  /// [path] is a route path or a page's `RouteView`, e.g. `SignUpPage.path`.
  PlaybookStep visit(Object path, {Object? data}) {
    final String route = _path(path);
    return PlaybookStep(
      'Visit $route',
      (PlaybookActor actor) => actor.visit(route, data: data),
    );
  }

  /// Goes back a page.
  PlaybookStep back() =>
      PlaybookStep('Back', (PlaybookActor actor) => actor.back());

  /// Holds still for [seconds], e.g. to let a demo breathe.
  PlaybookStep pause({num seconds = 1}) => PlaybookStep(
    'Pause ${seconds}s',
    (PlaybookActor actor) => actor.pause(seconds: seconds),
  );

  /// Captures the screen as [name].
  ///
  /// `metro live:run playbook <name>` saves it as
  /// `screenshots/<playbook>/<name>.png`, with no flag needed. A run from
  /// code captures it with `run(onScreenshot: ...)`, and any other run, such
  /// as `PLAYBOOK_ON_BOOT`, just waits for the screen to settle. [name] is
  /// used as a file name, so it's made of letters, digits, `-`, `_` and
  /// `.`.
  ///
  /// With [locales] or [themes], the same screen is captured once in each,
  /// saved as `es/cart.png` or `es-dark/cart.png`. The app switches in
  /// place, keeping the page and its state, and switches back before the
  /// next step:
  ///
  /// ```dart
  /// screenshot('cart', locales: ['en', 'es'], themes: ['light', 'dark']),
  /// screenshot('home', locales: Screenshot.allLocales),
  /// ```
  ///
  /// [caption] is the text above the screen when the run frames its
  /// screenshots, e.g. `--screenshots --store ios-6.9 --frame`. A
  /// translation key is translated into each locale.
  ///
  /// On the iOS Simulator and Android, Metro captures the device's whole
  /// screen, so the status bar and keyboard are in it, and the finger and
  /// caption are hidden while it does. Add `--clean-status-bar` to the run
  /// for 9:41 with full signal and battery. Elsewhere, in runs that aren't
  /// from Metro, and in `--store` and `--frame` runs, the app captures its
  /// own screen. [native] false always uses the app's capture:
  ///
  /// ```dart
  /// screenshot('checkout', native: false),
  /// ```
  PlaybookStep screenshot(
    String name, {
    List<String>? locales,
    List<String>? themes,
    String? caption,
    bool native = true,
  }) {
    if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9_.-]*$').hasMatch(name)) {
      throw ArgumentError.value(
        name,
        'name',
        'must start with a letter or digit and use only letters, digits, '
            '"-", "_" and "."',
      );
    }
    return PlaybookScreenshotStep(
      name,
      locales: locales,
      themes: themes,
      caption: caption,
      native: native,
    );
  }

  /// A step that runs any code, using the same verbs on [PlaybookActor].
  PlaybookStep step(
    String title,
    Future<void> Function(PlaybookActor actor) action,
  ) => PlaybookStep(title, action);

  /// Groups [steps] under [title], which leads their captions and nests
  /// their results in the report.
  PlaybookStep scene(String title, List<PlaybookStep> steps) =>
      PlaybookGroupStep(
        title,
        (PlaybookActor actor, PlaybookStepContext context) =>
            runSteps(actor, steps, context),
        steps: steps,
      );

  /// Runs another playbook here, in full: its setUp, steps and tearDown.
  ///
  /// [playbook] is a [Playbook] or the name it's registered under. It gets
  /// its own defaults, then this playbook's [data], then [data] passed
  /// here, and runs at this playbook's speed unless [speed] is given.
  PlaybookStep play(
    Object playbook, {
    Map<String, dynamic>? data,
    PlaybookSpeed? speed,
  }) {
    if (playbook is! Playbook && playbook is! String) {
      throw ArgumentError.value(
        playbook,
        'playbook',
        'must be a Playbook or the name of a registered one',
      );
    }
    final String title = playbook is Playbook
        ? PlaybookRegistry.nameOf(playbook)
        : playbook as String;
    return PlaybookGroupStep('Play $title', (
      PlaybookActor actor,
      PlaybookStepContext context,
    ) async {
      final Playbook? child = playbook is Playbook
          ? playbook
          : PlaybookRegistry.find(playbook as String);
      if (child == null) {
        final List<String> names = PlaybookRegistry.playbooks.keys.toList();
        throw PlaybookFailure(
          'There\'s no playbook called "$playbook".'
          '${names.isEmpty ? '' : ' Registered: ${names.join(', ')}.'}',
        );
      }
      final PlaybookReport report = await child.runWith(
        actor.session,
        speed: speed ?? actor.speed,
        data: {...actor.data, ...?data},
        emit: context.emit,
        path: context.path,
        depth: context.depth,
        caption: context.caption,
      );
      return report.steps;
    });
  }

  /// Runs [seeders] (seeders or the names they're registered under), for
  /// [setUp]. Throws when one fails.
  ///
  /// The runs are recorded like `seed` in `metro live`, so
  /// `seed:rollback <name>` undoes them.
  Future<void> seed(List<Object> seeders) async {
    final Map<String, Seeder Function()> registered = Nylo.isInitialized()
        ? Nylo.instance.getSeeders()
        : const {};
    final List<Seeder> resolved = [
      for (final Object seeder in seeders)
        switch (seeder) {
          final Seeder instance => instance,
          final String name when registered[name] != null =>
            registered[name]!(),
          _ => throw PlaybookFailure('There\'s no seeder called "$seeder".'),
        },
    ];
    for (final SeedRun run in await SeedRecorder.upAll(resolved)) {
      if (run.failed) {
        throw PlaybookFailure('Seeding ${run.name} failed: ${run.error}');
      }
    }
  }

  /// The route path of [path]: a [String] or a page's [RouteView]
  /// (`SignUpPage.path`).
  static String _path(Object path) => switch (path) {
    final String route => route,
    final RouteView view => view.$1,
    _ => throw ArgumentError.value(
      path,
      'path',
      'must be a route path or a page\'s RouteView',
    ),
  };
}
