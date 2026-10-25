import 'dart:async';
import 'dart:math';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import '/nylo.dart';
import '/router/ny_router.dart';
import 'playbook_camera.dart';
import 'playbook_clock.dart';
import 'playbook_finder.dart';
import 'playbook_overlay.dart';
import 'playbook_speed.dart';

/// A step that couldn't do what it says, with what was on screen.
class PlaybookFailure implements Exception {
  /// Creates a [PlaybookFailure] with [message].
  const PlaybookFailure(this.message, {this.visibleText = const []});

  /// What went wrong, e.g. `Could not find "Log in" on screen after 10s.`
  final String message;

  /// The text on screen when it failed.
  final List<String> visibleText;

  @override
  String toString() => message;
}

/// Thrown inside a run that was asked to stop.
class PlaybookStopped implements Exception {
  /// Creates a [PlaybookStopped].
  const PlaybookStopped();

  @override
  String toString() => 'Stopped';
}

/// What one run shares across nested playbooks: the clock, the overlay,
/// the finger, and whether it's been asked to stop.
class PlaybookSession {
  /// Creates a session timed by [clock], drawing in [overlay] and capturing
  /// with [camera] when given.
  PlaybookSession({
    required this.clock,
    this.overlay,
    this.camera,
    Random? random,
  }) : random = random ?? Random();

  /// Where the run's time comes from.
  final PlaybookClock clock;

  /// The finger and caption, or null when the run doesn't show them.
  final PlaybookOverlay? overlay;

  /// Takes the run's screenshots, or null when the run doesn't capture.
  final PlaybookCamera? camera;

  /// The source of typing jitter.
  final Random random;

  /// Whether the run has been asked to stop.
  bool stopRequested = false;

  /// Where the finger is.
  Offset? cursor;

  int _nextPointer = 7000;

  /// A pointer id no real finger uses.
  int nextPointer() => _nextPointer++;
}

/// Performs a playbook's steps on the running app, like a person would.
///
/// Every verb a playbook's steps use is here too, as a method returning a
/// future, for [Playbook.setUp], [Playbook.tearDown] and `step()`:
///
/// ```dart
/// step('Dismiss the promo if it shows', (actor) async {
///   if (await actor.exists('Not now')) await actor.tap('Not now');
/// }),
/// ```
class PlaybookActor {
  /// Creates an actor for one playbook in [session].
  PlaybookActor({
    required this.session,
    required this.speed,
    required this.data,
    this.timeout = const Duration(seconds: 10),
  });

  /// What the whole run shares.
  final PlaybookSession session;

  /// The pace of this playbook's steps.
  final PlaybookSpeed speed;

  /// The playbook's data: its defaults, overridden by what the run passed.
  final Map<String, dynamic> data;

  /// How long a step waits for its target to show up.
  Duration timeout;

  /// While true, a stop request doesn't interrupt waits, so tearDown can
  /// finish.
  bool ignoreStop = false;

  static const Duration _poll = Duration(milliseconds: 50);
  static const Duration _frameTime = Duration(milliseconds: 16);
  static const int _device = 7;

  PlaybookClock get _clock => session.clock;

  // ---------------------------------------------------------------------------
  // Verbs
  // ---------------------------------------------------------------------------

  /// Taps [target].
  Future<void> tap(Object target) =>
      _press(Find.target(target), hold: speed.tapHold);

  /// Presses and holds [target] long enough to count as a long press.
  Future<void> longPress(Object target) => _press(
    Find.target(target),
    hold: kLongPressTimeout + const Duration(milliseconds: 150),
  );

  /// Taps the text field [target], then types [text] one character at a
  /// time.
  ///
  /// The field is cleared first unless [clear] is false, in which case the
  /// text is added at the end. [submit] then presses the keyboard's action
  /// button (done, next, search...).
  Future<void> type(
    Object target,
    String text, {
    bool clear = true,
    bool submit = false,
  }) async {
    final PlaybookFinder finder = Find.target(target);
    final ({Element element, Rect rect}) found = await _reach(
      finder,
      fields: true,
    );
    final Element editable = found.element;
    await _tapAt(found.rect.center, _viewIdOf(editable), speed.tapHold);
    await _clock.frame();

    EditableTextState state = _editableState(editable, finder);
    if (state.widget.readOnly) {
      throw PlaybookFailure('${finder.description} is read only.');
    }
    final TextEditingValue start = state.textEditingValue;
    if (clear) {
      if (start.text.isNotEmpty) {
        state.userUpdateTextEditingValue(
          TextEditingValue.empty,
          SelectionChangedCause.keyboard,
        );
      }
    } else {
      state.userUpdateTextEditingValue(
        start.copyWith(
          selection: TextSelection.collapsed(offset: start.text.length),
        ),
        SelectionChangedCause.keyboard,
      );
    }
    // Typing closes the edit menu the tap may have opened, like "Paste" on
    // iOS, which the system draws over the app.
    if (text.isNotEmpty) state.hideToolbar();

    for (final String character in text.characters) {
      _checkStopped();
      state = _editableState(editable, finder);
      final TextEditingValue value = state.textEditingValue;
      final TextSelection selection = value.selection.isValid
          ? value.selection
          : TextSelection.collapsed(offset: value.text.length);
      state.userUpdateTextEditingValue(
        TextEditingValue(
          text: value.text.replaceRange(
            selection.start,
            selection.end,
            character,
          ),
          selection: TextSelection.collapsed(
            offset: selection.start + character.length,
          ),
        ),
        SelectionChangedCause.keyboard,
      );
      await _sleep(speed.nextCharacter(session.random));
      await _clock.frame();
    }

    if (submit) {
      state = _editableState(editable, finder);
      state.performAction(state.widget.textInputAction ?? TextInputAction.done);
      await _clock.frame();
    }
  }

  /// Scrolls until [target] is on screen, swiping the largest scrollable on
  /// screen, or the one [within] finds.
  Future<void> scrollTo(Object target, {Object? within}) async {
    final PlaybookFinder finder = Find.target(target);
    final PlaybookFinder? container = within == null
        ? null
        : Find.target(within);
    bool backwards = false;
    int reveals = 0;
    for (int swipes = 0; swipes < 200; swipes++) {
      _checkStopped();
      final PlaybookTree tree = _tree();
      final List<Element> matches = finder.find(tree);
      for (final Element element in matches) {
        if (_centerVisible(element)) return;
      }
      if (matches.isNotEmpty && reveals < 4) {
        reveals++;
        await _reveal(matches.first);
        continue;
      }

      final ScrollableState? scrollable = _scrollableIn(tree, container);
      if (scrollable == null) {
        throw PlaybookFailure(
          container == null
              ? 'There\'s nothing to scroll on screen to find '
                    '${finder.description}.'
              : 'Could not find ${container.description} to scroll.',
          visibleText: tree.visibleText(),
        );
      }
      final ScrollPosition position = scrollable.position;
      final bool atEdge = backwards
          ? position.pixels <= position.minScrollExtent + 0.5
          : position.pixels >= position.maxScrollExtent - 0.5;
      if (atEdge) {
        if (backwards) {
          throw PlaybookFailure(
            'Scrolled through the whole list and could not find '
            '${finder.description}.',
            visibleText: tree.visibleText(),
          );
        }
        backwards = true;
        continue;
      }
      final double extent = position.viewportDimension;
      await _scrollBy(scrollable, (backwards ? -0.6 : 0.6) * extent);
    }
    throw PlaybookFailure(
      'Gave up scrolling to ${finder.description} after 200 swipes.',
    );
  }

  /// Waits for [target] to be on screen.
  Future<void> see(Object target) => waitFor(target);

  /// Waits for [target] to be off the screen.
  Future<void> dontSee(Object target, {Duration? timeout}) async {
    final PlaybookFinder finder = Find.target(target);
    final Duration limit = timeout ?? this.timeout;
    final Duration start = _clock.elapsed;
    while (true) {
      _checkStopped();
      final PlaybookTree tree = _tree();
      if (!_anyVisible(finder.find(tree))) return;
      if (_clock.elapsed - start >= limit) {
        throw PlaybookFailure(
          'Still see ${finder.description} after ${_seconds(limit)}.',
          visibleText: tree.visibleText(),
        );
      }
      await _sleep(_poll);
    }
  }

  /// Waits up to [timeout] (the actor's [timeout] by default) for [target]
  /// to be on screen.
  Future<void> waitFor(Object target, {Duration? timeout}) async {
    await _reach(Find.target(target), timeout: timeout, reveal: false);
  }

  /// Whether [target] is on screen right now. Doesn't wait.
  Future<bool> exists(Object target) async {
    await _clock.frame();
    return _anyVisible(Find.target(target).find(_tree()));
  }

  /// Waits for the current page to be [path].
  Future<void> waitForPage(String path, {Duration? timeout}) async {
    final Duration limit = timeout ?? this.timeout;
    final Duration start = _clock.elapsed;
    while (true) {
      _checkStopped();
      final String? current = currentRouteName();
      if (current == path) {
        await _settle();
        return;
      }
      if (_clock.elapsed - start >= limit) {
        throw PlaybookFailure(
          'Still on ${current ?? 'an unnamed page'} after ${_seconds(limit)}, '
          'not $path.',
          visibleText: _tree().visibleText(),
        );
      }
      await _sleep(_poll);
    }
  }

  /// Opens the page at [path], passing [data] to it.
  Future<void> visit(String path, {Object? data}) async {
    Object? error;
    if (_nyloRouter) {
      // A push only completes when the page is popped, so it isn't awaited.
      unawaited(
        routeTo(path, data: data).then(
          (_) {},
          onError: (Object e) {
            error = e;
          },
        ),
      );
    } else {
      final NavigatorState? navigator = _navigator();
      if (navigator == null) {
        throw const PlaybookFailure('The app has no navigator to visit with.');
      }
      unawaited(
        navigator
            .pushNamed(path, arguments: data)
            .then(
              (_) {},
              onError: (Object e) {
                error = e;
              },
            ),
      );
    }
    final Duration start = _clock.elapsed;
    while (currentRouteName() != path) {
      _checkStopped();
      if (error != null) {
        throw PlaybookFailure('Could not open $path: $error');
      }
      if (_clock.elapsed - start >= timeout) {
        throw PlaybookFailure(
          'Visited $path, but the app is on '
          '${currentRouteName() ?? 'an unnamed page'}.',
        );
      }
      await _sleep(_poll);
    }
    await _settle(navigated: true);
  }

  /// Goes back a page, tapping the back button when one is on screen.
  Future<void> back() async {
    await _clock.frame();
    final PlaybookTree tree = _tree();
    for (final Element element in tree.elements) {
      final Widget widget = element.widget;
      if (widget is! BackButton &&
          widget is! CloseButton &&
          widget is! CupertinoNavigationBarBackButton) {
        continue;
      }
      if (_centerVisible(element)) {
        await _press(
          Find.where((Widget w) => identical(w, widget)),
          hold: speed.tapHold,
        );
        return;
      }
    }
    final NavigatorState? navigator = _navigator();
    if (navigator == null || !await navigator.maybePop()) {
      throw const PlaybookFailure('There\'s no page to go back to.');
    }
    await _settle(navigated: true);
  }

  /// Holds still for [seconds].
  Future<void> pause({num seconds = 1}) =>
      _sleep(Duration(milliseconds: (seconds * 1000).round()));

  /// The name of the page on screen, from Nylo's router when the app uses
  /// it, otherwise from the root navigator.
  String? currentRouteName() {
    if (_nyloRouter) {
      try {
        final String? name = Nylo.getCurrentRouteName();
        if (name != null) return name;
      } catch (_) {
        // Fall through to the navigator.
      }
    }
    final NavigatorState? navigator = _navigator();
    if (navigator == null) return null;
    String? name;
    navigator.popUntil((Route<dynamic> route) {
      name = route.settings.name;
      return true;
    });
    return name;
  }

  // ---------------------------------------------------------------------------
  // Steps' plumbing
  // ---------------------------------------------------------------------------

  /// Waits for [duration], stopping early when the run is stopped.
  Future<void> wait(Duration duration) => _sleep(duration);

  /// Waits for the screen to settle after a step.
  Future<void> settle() => _settle();

  /// Waits for running animations, like a page transition or a tap's
  /// ripple, to finish, for at most [timeout] so a looping animation can't
  /// hold the run.
  Future<void> settleAnimations({
    Duration timeout = const Duration(seconds: 1),
  }) async {
    final Duration start = _clock.elapsed;
    await _clock.frame();
    while (SchedulerBinding.instance.transientCallbackCount > 0 &&
        _clock.elapsed - start < timeout) {
      await _sleep(_frameTime);
    }
    await _clock.frame();
  }

  /// Throws [PlaybookStopped] when the run has been asked to stop.
  void _checkStopped() {
    if (session.stopRequested && !ignoreStop) throw const PlaybookStopped();
  }

  Future<void> _sleep(Duration duration) async {
    _checkStopped();
    Duration left = duration;
    while (left > Duration.zero) {
      final Duration chunk = left > const Duration(milliseconds: 100)
          ? const Duration(milliseconds: 100)
          : left;
      await _clock.wait(chunk);
      left -= chunk;
      _checkStopped();
    }
  }

  /// Lets route transitions and other animations finish, up to a limit.
  Future<void> _settle({bool navigated = false}) async {
    await _clock.frame();
    if (!navigated) return;
    final Duration start = _clock.elapsed;
    while (SchedulerBinding.instance.transientCallbackCount > 0 &&
        _clock.elapsed - start < const Duration(seconds: 2)) {
      await _sleep(_frameTime);
    }
    await _sleep(speed.afterNavigation);
  }

  PlaybookTree _tree() => PlaybookTree(WidgetsBinding.instance.rootElement);

  bool get _nyloRouter {
    try {
      return NyNavigator.instance.router.navigatorKey?.currentState != null;
    } catch (_) {
      return false;
    }
  }

  NavigatorState? _navigator() {
    if (_nyloRouter) {
      return NyNavigator.instance.router.navigatorKey?.currentState;
    }
    NavigatorState? found;
    void visit(Element element) {
      if (found != null) return;
      if (element is StatefulElement && element.state is NavigatorState) {
        found = element.state as NavigatorState;
        return;
      }
      element.visitChildElements(visit);
    }

    WidgetsBinding.instance.rootElement?.visitChildElements(visit);
    return found;
  }

  /// Waits for [finder] to match something on screen that a tap there would
  /// reach, scrolling it into view when it's built but off screen.
  ///
  /// With [fields], the match is the text field it is or is part of.
  Future<({Element element, Rect rect})> _reach(
    PlaybookFinder finder, {
    bool fields = false,
    bool reveal = true,
    Duration? timeout,
  }) async {
    final Duration limit = timeout ?? this.timeout;
    final Duration start = _clock.elapsed;
    String? problem;
    int reveals = 0;
    while (true) {
      _checkStopped();
      final PlaybookTree tree = _tree();
      final List<Element> matches = fields
          ? [
              for (final Element element in finder.findFields(tree))
                ?_editableFor(element),
            ]
          : finder.find(tree);
      Element? hidden;
      for (final Element element in matches) {
        final Rect? rect = playbookVisibleRect(element);
        if (rect == null || !_centerVisible(element)) {
          hidden ??= element;
          continue;
        }
        if (!reveal) return (element: element, rect: rect);
        if (_reachable(element, rect.center)) {
          return (element: element, rect: rect);
        }
        problem =
            'Found ${finder.description}, but something covers it, like a '
            'dialog or the keyboard.';
      }
      if (matches.isEmpty && fields && finder.find(tree).isNotEmpty) {
        problem = '${finder.description} is not a text field.';
      }
      if (hidden != null && reveal && reveals < 4 && _hasScrollable(hidden)) {
        reveals++;
        await _reveal(hidden);
        continue;
      }
      if (_clock.elapsed - start >= limit) {
        throw PlaybookFailure(
          problem ??
              (hidden != null
                  ? '${finder.description} is on the page but not on screen '
                        'after ${_seconds(limit)}.'
                  : 'Could not find ${finder.description} on screen after '
                        '${_seconds(limit)}.'),
          visibleText: tree.visibleText(),
        );
      }
      await _sleep(_poll);
    }
  }

  bool _anyVisible(List<Element> elements) =>
      elements.any((Element element) => playbookVisibleRect(element) != null);

  /// Whether the middle of [element]'s visible part is the middle of the
  /// element itself, give or take, so a tap there lands on it.
  bool _centerVisible(Element element) {
    final Rect? visible = playbookVisibleRect(element);
    if (visible == null) return false;
    final RenderObject? object = element.renderObject;
    if (object is! RenderBox) return false;
    final Offset center = object.localToGlobal(object.size.center(Offset.zero));
    return visible.inflate(1).contains(center) ||
        (visible.height >= 24 && visible.width >= 24);
  }

  /// Whether a pointer down at [point] reaches [element] rather than
  /// something on top of it.
  ///
  /// A tap also counts when it reaches the gesture detector [element] sits
  /// in, as when a text field's hint lies under its editable text, but not
  /// when something unrelated, like a modal barrier, takes it.
  bool _reachable(Element element, Offset point) {
    final RenderObject? target = element.renderObject;
    if (target == null) return false;
    final HitTestResult result = HitTestResult();
    GestureBinding.instance.hitTestInView(result, point, _viewIdOf(element));
    final Set<Object> hit = {
      for (final HitTestEntry entry in result.path) entry.target,
    };
    if (hit.contains(target)) return true;

    RenderObject? detector;
    int depth = 0;
    element.visitAncestorElements((Element ancestor) {
      final Widget widget = ancestor.widget;
      if (widget is RawGestureDetector || widget is Listener) {
        detector = ancestor.renderObject;
        return false;
      }
      return ++depth < 40;
    });
    return detector != null && hit.contains(detector);
  }

  int _viewIdOf(Element element) =>
      View.maybeOf(element)?.viewId ??
      PlatformDispatcher.instance.implicitView?.viewId ??
      0;

  Future<void> _press(PlaybookFinder finder, {required Duration hold}) async {
    final ({Element element, Rect rect}) found = await _reach(finder);
    await _tapAt(found.rect.center, _viewIdOf(found.element), hold);
    await _afterTouch();
  }

  /// Settles after a tap, waiting longer when it changed the page.
  Future<void> _afterTouch() async {
    final String? before = currentRouteName();
    await _clock.frame();
    await _clock.frame();
    await _settle(navigated: currentRouteName() != before);
  }

  Future<void> _tapAt(Offset point, int viewId, Duration hold) async {
    await _moveFinger(point);
    final int pointer = session.nextPointer();
    _dispatch(
      PointerDownEvent(
        timeStamp: _clock.elapsed,
        pointer: pointer,
        device: _device,
        position: point,
        viewId: viewId,
      ),
    );
    session.overlay?.pressed.value = true;
    await _sleep(hold);
    _dispatch(
      PointerUpEvent(
        timeStamp: _clock.elapsed,
        pointer: pointer,
        device: _device,
        position: point,
        viewId: viewId,
      ),
    );
    session.overlay?.pressed.value = false;
  }

  void _dispatch(PointerEvent event) =>
      GestureBinding.instance.handlePointerEvent(event);

  Future<void> _moveFinger(Offset to) async {
    final PlaybookOverlay? overlay = session.overlay;
    final Offset from = session.cursor ?? to;
    session.cursor = to;
    if (overlay == null) return;
    final int frames = speed.fingerTravel.inMilliseconds ~/ 16;
    if (frames <= 1 || from == to) {
      overlay.finger.value = to;
      await _clock.frame();
      return;
    }
    for (int i = 1; i <= frames; i++) {
      final double t = Curves.easeInOut.transform(i / frames);
      overlay.finger.value = Offset.lerp(from, to, t);
      await _sleep(_frameTime);
    }
  }

  /// Drags the finger from [from] to [to] over [duration], then holds still
  /// before lifting, so the scrollable doesn't fling.
  Future<void> _drag(
    Offset from,
    Offset to,
    int viewId,
    Duration duration,
  ) async {
    await _moveFinger(from);
    final int pointer = session.nextPointer();
    Offset last = from;
    _dispatch(
      PointerDownEvent(
        timeStamp: _clock.elapsed,
        pointer: pointer,
        device: _device,
        position: from,
        viewId: viewId,
      ),
    );
    session.overlay?.pressed.value = true;
    final int steps = max(6, duration.inMilliseconds ~/ 16);
    final Duration each = Duration(
      microseconds: max(
        _frameTime.inMicroseconds,
        duration.inMicroseconds ~/ steps,
      ),
    );
    for (int i = 1; i <= steps; i++) {
      final Offset position = Offset.lerp(
        from,
        to,
        Curves.easeInOut.transform(i / steps),
      )!;
      await _clock.wait(each);
      _dispatch(
        PointerMoveEvent(
          timeStamp: _clock.elapsed,
          pointer: pointer,
          device: _device,
          position: position,
          delta: position - last,
          viewId: viewId,
        ),
      );
      last = position;
      session.overlay?.finger.value = position;
      session.cursor = position;
    }
    // Hold still before lifting. The velocity tracker treats a gap of more
    // than 40ms between samples as a stop, so the lift lands where the finger
    // stopped instead of flinging (or, after a quick swipe, flinging back).
    for (int i = 0; i < 2; i++) {
      await _clock.wait(const Duration(milliseconds: 50));
      _dispatch(
        PointerMoveEvent(
          timeStamp: _clock.elapsed,
          pointer: pointer,
          device: _device,
          position: to,
          viewId: viewId,
        ),
      );
    }
    _dispatch(
      PointerUpEvent(
        timeStamp: _clock.elapsed,
        pointer: pointer,
        device: _device,
        position: to,
        viewId: viewId,
      ),
    );
    session.overlay?.pressed.value = false;
    _checkStopped();
  }

  /// Swipes [scrollable] so its offset changes by about [delta] pixels.
  Future<void> _scrollBy(ScrollableState scrollable, double delta) async {
    final Rect? viewport = playbookVisibleRect(scrollable.context as Element);
    if (viewport == null) return;
    final AxisDirection direction = scrollable.axisDirection;
    final bool vertical = axisDirectionToAxis(direction) == Axis.vertical;
    final double length = vertical ? viewport.height : viewport.width;
    final double distance = delta.clamp(-length * 0.8, length * 0.8);
    if (distance.abs() < 1) return;

    // Moving the finger against the axis direction scrolls forward.
    final double sign = axisDirectionIsReversed(direction) ? 1 : -1;
    final double finger = sign * (distance.abs() + kTouchSlop) * distance.sign;
    final Offset move = vertical ? Offset(0, finger) : Offset(finger, 0);
    final Offset start = viewport.center - move / 2;
    await _drag(
      start,
      start + move,
      _viewIdOf(scrollable.context as Element),
      speed.swipe,
    );
    await _settleScroll(scrollable);
  }

  Future<void> _settleScroll(ScrollableState scrollable) async {
    final Duration start = _clock.elapsed;
    await _clock.frame();
    while (scrollable.mounted &&
        scrollable.position.isScrollingNotifier.value &&
        _clock.elapsed - start < const Duration(seconds: 3)) {
      await _sleep(_frameTime);
    }
    await _clock.frame();
  }

  /// Scrolls the scrollable that hides [element] until it's in view.
  Future<void> _reveal(Element element) async {
    final RenderObject? object = element.renderObject;
    if (object is! RenderBox || !object.attached || !object.hasSize) return;
    final Offset center = object.localToGlobal(object.size.center(Offset.zero));

    ScrollableState? scrollable = Scrollable.maybeOf(element);
    while (scrollable != null) {
      final Rect? viewport = playbookVisibleRect(scrollable.context as Element);
      if (viewport != null && !viewport.contains(center)) {
        final double pixelsBefore = scrollable.position.pixels;
        final AxisDirection direction = scrollable.axisDirection;
        final bool vertical = axisDirectionToAxis(direction) == Axis.vertical;
        final double offCenter = vertical
            ? center.dy - viewport.center.dy
            : center.dx - viewport.center.dx;
        await _scrollBy(
          scrollable,
          axisDirectionIsReversed(direction) ? -offCenter : offCenter,
        );
        if (scrollable.mounted &&
            (scrollable.position.pixels - pixelsBefore).abs() < 1 &&
            element.mounted) {
          // The swipe didn't move it, e.g. a scrollable that ignores drags.
          await Scrollable.ensureVisible(
            element,
            alignment: 0.5,
            duration: speed.swipe,
          );
          await _settleScroll(scrollable);
        }
        return;
      }
      scrollable = Scrollable.maybeOf(scrollable.context);
    }
  }

  bool _hasScrollable(Element element) => Scrollable.maybeOf(element) != null;

  /// The largest scrollable on screen, or the one [container] finds.
  ScrollableState? _scrollableIn(PlaybookTree tree, PlaybookFinder? container) {
    final Iterable<Element> candidates;
    if (container == null) {
      candidates = tree.elements;
    } else {
      final List<Element> roots = container.find(tree);
      if (roots.isEmpty) return null;
      final Element root = roots.first;
      if (root is StatefulElement && root.state is ScrollableState) {
        return root.state as ScrollableState;
      }
      final List<Element> inside = [];
      void visit(Element element) {
        inside.add(element);
        element.visitChildElements(visit);
      }

      root.visitChildElements(visit);
      candidates = inside;
    }

    ScrollableState? best;
    double bestArea = 0;
    for (final Element element in candidates) {
      if (element is! StatefulElement || element.state is! ScrollableState) {
        continue;
      }
      final ScrollableState state = element.state as ScrollableState;
      final Rect? rect = playbookVisibleRect(element);
      if (rect == null) continue;
      final ScrollPosition position = state.position;
      if (!position.hasContentDimensions ||
          position.maxScrollExtent <= position.minScrollExtent) {
        continue;
      }
      final double area = rect.width * rect.height;
      if (container != null) return state;
      if (area > bestArea) {
        best = state;
        bestArea = area;
      }
    }
    return best;
  }

  /// The `EditableText` [element] is, is inside, or labels.
  Element? _editableFor(Element element) {
    if (element.widget is EditableText) return element;
    final Element? below = _firstEditableUnder(element);
    if (below != null) return below;
    Element? found;
    int depth = 0;
    element.visitAncestorElements((Element ancestor) {
      found = _firstEditableUnder(ancestor);
      return found == null && ++depth < 6;
    });
    return found;
  }

  static Element? _firstEditableUnder(Element root) {
    Element? found;
    void visit(Element element) {
      if (found != null || element.widget is PlaybookOverlayScope) return;
      if (element.widget is EditableText) {
        found = element;
        return;
      }
      element.debugVisitOnstageChildren(visit);
    }

    root.debugVisitOnstageChildren(visit);
    return found;
  }

  EditableTextState _editableState(Element element, PlaybookFinder finder) {
    if (!element.mounted ||
        element is! StatefulElement ||
        element.state is! EditableTextState) {
      throw PlaybookFailure(
        '${finder.description} went away while typing into it.',
      );
    }
    return element.state as EditableTextState;
  }

  static String _seconds(Duration duration) {
    final double seconds = duration.inMilliseconds / 1000;
    return seconds == seconds.roundToDouble()
        ? '${seconds.round()}s'
        : '${seconds.toStringAsFixed(1)}s';
  }
}
