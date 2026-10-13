/// How a playbook step ended.
enum PlaybookStepStatus {
  /// The step did what it says.
  passed,

  /// The step failed, which fails the playbook.
  failed,

  /// The step never ran, because an earlier one failed or the run stopped.
  skipped,
}

/// What happened in one step of a playbook run.
class PlaybookStepResult {
  /// Creates a [PlaybookStepResult].
  const PlaybookStepResult({
    required this.title,
    required this.status,
    this.elapsed = Duration.zero,
    this.error,
    this.visibleText = const [],
    this.steps = const [],
  });

  /// The step's title, e.g. `Tap "Create account"`.
  final String title;

  /// How the step ended.
  final PlaybookStepStatus status;

  /// How long the step took.
  final Duration elapsed;

  /// Why the step failed.
  final String? error;

  /// The text on screen when the step failed, to help see why.
  final List<String> visibleText;

  /// The steps inside a `scene()` or `play()` step.
  final List<PlaybookStepResult> steps;

  /// Whether the step passed.
  bool get passed => status == PlaybookStepStatus.passed;

  /// The result as JSON, as sent to Metro.
  Map<String, Object?> toJson() => {
    'title': title,
    'status': status.name,
    'ms': elapsed.inMilliseconds,
    if (error != null) 'error': error,
    if (visibleText.isNotEmpty) 'visible': visibleText,
    if (steps.isNotEmpty)
      'steps': [for (final PlaybookStepResult step in steps) step.toJson()],
  };

  void _write(StringBuffer buffer, int depth) {
    final String indent = '  ' * (depth + 1);
    final String mark = switch (status) {
      PlaybookStepStatus.passed => '✓',
      PlaybookStepStatus.failed => '✗',
      PlaybookStepStatus.skipped => '·',
    };
    final String ms = '${elapsed.inMilliseconds}ms'.padLeft(7);
    buffer.write('\n$indent$mark $ms  $title');
    if (status == PlaybookStepStatus.skipped) buffer.write('  (skipped)');
    final bool childFailed = steps.any(
      (PlaybookStepResult step) => step.status == PlaybookStepStatus.failed,
    );
    if (error != null && !childFailed) {
      buffer.write('\n$indent      $error');
      if (visibleText.isNotEmpty) {
        buffer.write(
          '\n$indent      Visible text: '
          '${visibleText.map((String text) => '"$text"').join(', ')}',
        );
      }
    }
    for (final PlaybookStepResult step in steps) {
      step._write(buffer, depth + 2);
    }
  }
}

/// The result of running a playbook: whether it passed, and each step.
///
/// `toString()` reads like Metro's output:
///
/// ```text
/// Playbook "sign_up" (natural) — passed in 12.4s
///   ✓   239ms  Tap "Get started"
///   ✓   512ms  Wait for page /sign-up
/// ```
class PlaybookReport {
  /// Creates a [PlaybookReport].
  const PlaybookReport({
    required this.name,
    required this.speed,
    required this.steps,
    required this.elapsed,
    this.stopped = false,
  });

  /// The playbook's name.
  final String name;

  /// The name of the speed it ran at.
  final String speed;

  /// Each step's result, in order.
  final List<PlaybookStepResult> steps;

  /// How long the run took.
  final Duration elapsed;

  /// Whether the run was stopped before it finished.
  final bool stopped;

  /// Whether every step passed and the run wasn't stopped.
  bool get passed =>
      !stopped &&
      steps.every(
        (PlaybookStepResult step) => step.status != PlaybookStepStatus.failed,
      );

  /// The first failed step, looking inside nested steps, or null.
  PlaybookStepResult? get failure {
    PlaybookStepResult? search(List<PlaybookStepResult> results) {
      for (final PlaybookStepResult result in results) {
        if (result.status != PlaybookStepStatus.failed) continue;
        return search(result.steps) ?? result;
      }
      return null;
    }

    return search(steps);
  }

  /// The report as JSON, as sent to Metro.
  Map<String, Object?> toJson() => {
    'name': name,
    'speed': speed,
    'passed': passed,
    'stopped': stopped,
    'ms': elapsed.inMilliseconds,
    'steps': [for (final PlaybookStepResult step in steps) step.toJson()],
  };

  @override
  String toString() {
    final String outcome = stopped
        ? 'stopped'
        : passed
        ? 'passed'
        : 'FAILED';
    final String seconds = (elapsed.inMilliseconds / 1000).toStringAsFixed(1);
    final StringBuffer buffer = StringBuffer(
      'Playbook "$name" ($speed) — $outcome in ${seconds}s',
    );
    for (final PlaybookStepResult step in steps) {
      step._write(buffer, 0);
    }
    return buffer.toString();
  }
}
