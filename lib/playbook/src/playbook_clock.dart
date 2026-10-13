import 'package:flutter/scheduler.dart';

/// Where a playbook's time comes from.
///
/// In a running app, [LivePlaybookClock] waits in real time. Under a widget
/// test, `NyTesterClock` from Nylo's testing module pumps the tester
/// instead, so a playbook at natural speed finishes in about a second of
/// wall clock.
abstract class PlaybookClock {
  /// Creates a [PlaybookClock].
  const PlaybookClock();

  /// How much time has passed on this clock since it was created.
  Duration get elapsed;

  /// Waits for [duration], letting frames render meanwhile.
  Future<void> wait(Duration duration);

  /// Waits until the next frame has been drawn.
  Future<void> frame();
}

/// A [PlaybookClock] that waits in real time, for running apps and
/// integration tests.
class LivePlaybookClock extends PlaybookClock {
  /// Creates a [LivePlaybookClock] starting at zero.
  LivePlaybookClock() : _stopwatch = Stopwatch()..start();

  final Stopwatch _stopwatch;

  @override
  Duration get elapsed => _stopwatch.elapsed;

  @override
  Future<void> wait(Duration duration) async {
    if (duration > Duration.zero) await Future<void>.delayed(duration);
  }

  @override
  Future<void> frame() async {
    final SchedulerBinding binding = SchedulerBinding.instance;
    binding.scheduleFrame();
    await binding.endOfFrame;
  }
}
