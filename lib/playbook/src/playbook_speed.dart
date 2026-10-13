import 'dart:math';

/// How fast a playbook performs its steps.
///
/// Every wait the actor takes comes from one [PlaybookSpeed], so a playbook
/// is written once and replayed at any pace:
///
/// ```dart
/// await SignUpPlaybook().run(speed: PlaybookSpeed.fast);
/// await SignUpPlaybook().run(speed: PlaybookSpeed.natural.times(2));
/// ```
///
/// From Metro: `metro live:run playbook sign_up --speed fast`.
class PlaybookSpeed {
  /// Creates a custom speed.
  ///
  /// [typingJitter] is how much each character's delay varies, as a fraction
  /// of [perCharacter] (0.6 means ± 60%).
  const PlaybookSpeed({
    required this.name,
    required this.betweenSteps,
    required this.tapHold,
    required this.perCharacter,
    this.typingJitter = 0,
    required this.fingerTravel,
    required this.swipe,
    required this.afterNavigation,
  });

  /// No waits beyond what scrolling needs. Meant for tests.
  static const PlaybookSpeed instant = PlaybookSpeed(
    name: 'instant',
    betweenSteps: Duration.zero,
    tapHold: Duration.zero,
    perCharacter: Duration.zero,
    fingerTravel: Duration.zero,
    swipe: Duration(milliseconds: 120),
    afterNavigation: Duration.zero,
  );

  /// Quick, but still easy to follow.
  static const PlaybookSpeed fast = PlaybookSpeed(
    name: 'fast',
    betweenSteps: Duration(milliseconds: 150),
    tapHold: Duration(milliseconds: 40),
    perCharacter: Duration(milliseconds: 20),
    fingerTravel: Duration(milliseconds: 120),
    swipe: Duration(milliseconds: 250),
    afterNavigation: Duration(milliseconds: 200),
  );

  /// The pace of a person using the app. The default.
  static const PlaybookSpeed natural = PlaybookSpeed(
    name: 'natural',
    betweenSteps: Duration(milliseconds: 700),
    tapHold: Duration(milliseconds: 90),
    perCharacter: Duration(milliseconds: 85),
    typingJitter: 0.6,
    fingerTravel: Duration(milliseconds: 380),
    swipe: Duration(milliseconds: 500),
    afterNavigation: Duration(milliseconds: 500),
  );

  /// Slow enough to narrate over, for tutorials and screen recordings.
  static const PlaybookSpeed slow = PlaybookSpeed(
    name: 'slow',
    betweenSteps: Duration(milliseconds: 1500),
    tapHold: Duration(milliseconds: 140),
    perCharacter: Duration(milliseconds: 180),
    typingJitter: 0.5,
    fingerTravel: Duration(milliseconds: 700),
    swipe: Duration(milliseconds: 900),
    afterNavigation: Duration(milliseconds: 900),
  );

  /// The built-in speeds, by name.
  static const Map<String, PlaybookSpeed> presets = {
    'instant': instant,
    'fast': fast,
    'natural': natural,
    'slow': slow,
  };

  /// The built-in speed called [name], or null when there is none.
  static PlaybookSpeed? named(String name) =>
      presets[name.trim().toLowerCase()];

  /// The name shown in reports, e.g. `natural` or `natural×2`.
  final String name;

  /// The pause after each step.
  final Duration betweenSteps;

  /// How long the finger stays down for a tap.
  final Duration tapHold;

  /// The delay between typed characters.
  final Duration perCharacter;

  /// How much [perCharacter] varies, as a fraction of it.
  final double typingJitter;

  /// How long the finger takes to move to its target.
  final Duration fingerTravel;

  /// How long one swipe of a scroll takes.
  final Duration swipe;

  /// The pause after the page changes.
  final Duration afterNavigation;

  /// This speed with every duration multiplied by [factor].
  ///
  /// `PlaybookSpeed.natural.times(2)` is twice as slow as natural.
  PlaybookSpeed times(num factor) {
    if (factor <= 0) {
      throw ArgumentError.value(factor, 'factor', 'must be greater than 0');
    }
    Duration scale(Duration duration) =>
        Duration(microseconds: (duration.inMicroseconds * factor).round());
    final String label = factor == factor.roundToDouble()
        ? '${factor.round()}'
        : '$factor';
    return PlaybookSpeed(
      name: '$name×$label',
      betweenSteps: scale(betweenSteps),
      tapHold: scale(tapHold),
      perCharacter: scale(perCharacter),
      typingJitter: typingJitter,
      fingerTravel: scale(fingerTravel),
      swipe: scale(swipe),
      afterNavigation: scale(afterNavigation),
    );
  }

  /// The delay before the next typed character, with [typingJitter] applied.
  Duration nextCharacter(Random random) {
    if (perCharacter == Duration.zero || typingJitter == 0) {
      return perCharacter;
    }
    final double spread = (random.nextDouble() * 2 - 1) * typingJitter;
    final int micros = (perCharacter.inMicroseconds * (1 + spread)).round();
    return Duration(microseconds: max(0, micros));
  }

  @override
  String toString() => 'PlaybookSpeed.$name';
}
