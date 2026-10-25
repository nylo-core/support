import 'playbook_actor.dart';
import 'playbook_report.dart';

/// One step of a playbook: a title, and what the actor does.
///
/// Steps come from the verbs a [Playbook] inherits (`tap`, `type`, `see`,
/// ...). Write your own with `step()`:
///
/// ```dart
/// step('Accept cookies if asked', (actor) async {
///   if (await actor.exists('Accept')) await actor.tap('Accept');
/// }),
/// ```
class PlaybookStep {
  /// Creates a step called [title] that runs [action].
  const PlaybookStep(this.title, this.action);

  /// What the step does, shown in the caption and the report.
  final String title;

  /// Performs the step.
  final Future<void> Function(PlaybookActor actor) action;

  @override
  String toString() => title;
}

/// A step made of other steps, like `scene()` and `play()`, whose results
/// nest under it in the report.
class PlaybookGroupStep extends PlaybookStep {
  /// Creates a group step called [title] that runs [group]. [steps] lists
  /// the steps it runs when they're known up front, like a `scene()`'s.
  PlaybookGroupStep(String title, this.group, {this.steps})
    : super(title, _noAction);

  /// Runs the nested steps and returns their results.
  ///
  /// [context] carries the caption prefix and nesting depth.
  final Future<List<PlaybookStepResult>> Function(
    PlaybookActor actor,
    PlaybookStepContext context,
  )
  group;

  /// The steps [group] runs, or null when they're only known once it runs,
  /// like another playbook's.
  final List<PlaybookStep>? steps;

  static Future<void> _noAction(PlaybookActor actor) async {}
}

/// Where a step list runs: its caption prefix, its depth, and the chain of
/// playbooks around it.
class PlaybookStepContext {
  /// Creates a [PlaybookStepContext].
  const PlaybookStepContext({
    required this.playbook,
    required this.path,
    this.depth = 0,
    this.caption = '',
    this.emit,
    this.everyStep = true,
  });

  /// The name of the playbook the steps belong to.
  final String playbook;

  /// The names of the playbooks from the top of the run down to this one.
  final List<String> path;

  /// How deeply nested the steps are: 0 for a top-level playbook.
  final int depth;

  /// The caption of the steps around these, e.g. `2/3 · Play log_out › `.
  final String caption;

  /// Receives the run's events.
  final void Function(Map<String, Object?> event)? emit;

  /// Whether a run capturing screenshots in `auto` mode captures every step:
  /// false when the playbook has `screenshot()` steps.
  final bool everyStep;

  /// The context for steps nested in the step at [index] of [total] called
  /// [title], belonging to [playbook] with [path].
  PlaybookStepContext nested({
    required int index,
    required int total,
    required String title,
    String? playbook,
    List<String>? path,
  }) => PlaybookStepContext(
    playbook: playbook ?? this.playbook,
    path: path ?? this.path,
    depth: depth + 1,
    caption: '$caption$index/$total · $title › ',
    emit: emit,
    everyStep: everyStep,
  );
}
