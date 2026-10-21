import 'dart:async';

import 'package:flutter/widgets.dart';

import '/helpers/ny_helpers.dart';
import '/live/src/live_exception.dart';
import '/live/src/ny_live.dart';
import 'playbook.dart';
import 'playbook_actor.dart';
import 'playbook_clock.dart';
import 'playbook_registry.dart';
import 'playbook_report.dart';
import 'playbook_speed.dart';
import 'playbook_step.dart';

/// Runs registered playbooks by name, for Metro and `PLAYBOOK_ON_BOOT`.
///
/// A run returns its id straight away and reports each step as a
/// `nylo.playbook` event, so Metro can stream a playbook that takes longer
/// than a command is allowed to.
abstract final class PlaybookRunner {
  static int _counter = 0;
  static String? _runId;
  static Future<void>? _running;

  /// The id of the run in progress, or null.
  static String? get activeRunId => _runId;

  /// Completes when the run in progress ends, or straight away.
  static Future<void> get done => _running ?? Future<void>.value();

  /// Each registered playbook's name, description, speed and step titles.
  static List<Map<String, Object?>> list() => [
    for (final MapEntry<String, Playbook Function()> entry
        in PlaybookRegistry.playbooks.entries)
      _describe(entry.key, entry.value()),
  ];

  static Map<String, Object?> _describe(String name, Playbook playbook) {
    List<String>? steps;
    String? error;
    try {
      steps = [for (final PlaybookStep step in playbook.steps) step.title];
    } catch (e) {
      error = '$e';
    }
    return {
      'name': name,
      'description': playbook.description,
      'speed': playbook.speed.name,
      'steps': steps,
      'error': ?error,
    };
  }

  /// Starts the playbooks [names] back to back and returns the run's id.
  ///
  /// [speed] overrides each playbook's own, and [data] is shared by all of
  /// them. With [loop], the list repeats until [stop]. A [countdown] counts
  /// that many seconds down on screen first, so there's time to start a
  /// screen recording. Throws a [LiveException] when a name is unknown or a
  /// playbook is running.
  static String start(
    List<String> names, {
    PlaybookSpeed? speed,
    Map<String, dynamic>? data,
    bool overlay = true,
    bool loop = false,
    int countdown = 0,
    PlaybookClock? clock,
  }) {
    if (_runId != null || Playbook.isRunning) {
      throw LiveException(
        'A playbook is already running${_runId == null ? '' : ' ($_runId)'}. '
        'Stop it first.',
      );
    }
    if (names.isEmpty) {
      throw const LiveException.invalidParams('Name a playbook to run.');
    }
    for (final String name in names) {
      if (PlaybookRegistry.find(name) == null) {
        final List<String> registered = PlaybookRegistry.playbooks.keys
            .toList();
        throw LiveException.invalidParams(
          'There\'s no playbook called "$name".'
          '${registered.isEmpty ? ' Create one with metro make:playbook $name' : ' Registered: ${registered.join(', ')}.'}',
        );
      }
    }

    final String runId = 'pb_${++_counter}';
    _runId = runId;
    _running = _run(
      runId,
      names,
      speed: speed,
      data: data,
      overlay: overlay,
      loop: loop,
      countdown: countdown,
      clock: clock,
    );
    return runId;
  }

  /// Stops the run [runId], or whichever is running when it's null.
  ///
  /// Returns false when that run isn't running.
  static bool stop([String? runId]) {
    if (_runId == null || (runId != null && runId != _runId)) return false;
    return Playbook.stop();
  }

  static Future<void> _run(
    String runId,
    List<String> names, {
    PlaybookSpeed? speed,
    Map<String, dynamic>? data,
    required bool overlay,
    required bool loop,
    required int countdown,
    PlaybookClock? clock,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    int iteration = 0;
    void emit(Map<String, Object?> event) {
      final bool top = event['depth'] == 0 && event['event'] == 'start';
      NyLive.emit('playbook', {
        'runId': runId,
        ...event,
        if (top) 'loop': iteration,
      });
    }

    bool passed = true;
    bool stopped = false;
    int runs = 0;
    String? error;
    PlaybookSession? session;
    try {
      session = await Playbook.open(
        clock: clock,
        overlay: overlay,
        caption: PlaybookRegistry.find(names.first)!.caption,
      );
      for (int left = countdown; left > 0; left--) {
        if (session.stopRequested) break;
        session.overlay?.countdown.value = left;
        emit({'event': 'countdown', 'left': left});
        await session.clock.wait(const Duration(seconds: 1));
      }
      session.overlay?.countdown.value = null;
      do {
        iteration++;
        for (final String name in names) {
          if (session.stopRequested) break;
          final Playbook playbook = PlaybookRegistry.find(name)!;
          session.overlay?.caption = playbook.caption;
          final PlaybookReport report = await playbook.runWith(
            session,
            speed: speed,
            data: data,
            emit: emit,
          );
          runs++;
          if (!report.passed) {
            passed = false;
            break;
          }
        }
        // Give a looping run a moment between rounds.
        if (loop && passed && !session.stopRequested) {
          await session.clock.wait(const Duration(seconds: 1));
        }
      } while (loop && passed && !session.stopRequested);
      stopped = session.stopRequested;
    } catch (e) {
      passed = false;
      error = e is PlaybookFailure ? e.message : '$e';
      NyLogger.error('[Playbook] $error');
    } finally {
      if (session != null) Playbook.close(session);
      _runId = null;
      _running = null;
      NyLive.emit('playbook', {
        'runId': runId,
        'event': 'done',
        'passed': passed && !stopped,
        'stopped': stopped,
        'ms': stopwatch.elapsedMilliseconds,
        'runs': runs,
        'error': ?error,
      });
    }
  }

  /// Starts the playbooks named in `PLAYBOOK_ON_BOOT` (comma separated) at
  /// `PLAYBOOK_SPEED`, once the app's first frame is on screen.
  ///
  /// `Nylo.init` calls this in debug and profile builds.
  static void startOnBoot() {
    final String names = '${getEnv('PLAYBOOK_ON_BOOT', defaultValue: '') ?? ''}'
        .trim();
    if (names.isEmpty) return;
    final String speedName =
        '${getEnv('PLAYBOOK_SPEED', defaultValue: '') ?? ''}'.trim();
    final PlaybookSpeed? speed = speedName.isEmpty
        ? null
        : PlaybookSpeed.named(speedName);
    if (speedName.isNotEmpty && speed == null) {
      NyLogger.error(
        '[Playbook] PLAYBOOK_SPEED "$speedName" isn\'t a speed. Use '
        '${PlaybookSpeed.presets.keys.join(', ')}.',
      );
    }

    unawaited(() async {
      await WidgetsBinding.instance.waitUntilFirstFrameRasterized;
      await Future<void>.delayed(const Duration(milliseconds: 500));
      try {
        start([
          for (final String name in names.split(','))
            if (name.trim().isNotEmpty) name.trim(),
        ], speed: speed);
      } on LiveException catch (e) {
        NyLogger.error(
          '[Playbook] PLAYBOOK_ON_BOOT could not start',
          context: {'error': e.message},
        );
      }
    }());
  }
}
