import 'dart:async';

import 'console.dart';

/// A spinner animation for indicating indeterminate loading states.
///
/// The spinner is displayed at the current cursor position and animates
/// through a sequence of characters to indicate that work is in progress.
///
/// Example usage:
/// ```dart
/// final spinner = Spinner(message: 'Loading...');
/// spinner.start();
/// // ... do some work ...
/// spinner.stop();
/// ```
class Spinner {
  /// The message to display next to the spinner.
  final String message;

  /// The characters to use for the spinner animation.
  ///
  /// The spinner will cycle through these characters in order.
  final List<String> spinnerCharacters;

  /// The interval between spinner updates in milliseconds.
  final int intervalMs;

  /// The starting position from which the spinner should be drawn.
  Coordinate? _startCoordinate;

  Timer? _timer;
  int _frameIndex = 0;
  bool _isRunning = false;

  final _console = Console();

  /// Creates a new spinner.
  ///
  /// [message] is displayed next to the spinner animation.
  /// [spinnerCharacters] defines the animation frames (defaults to a rotating line).
  /// [intervalMs] controls the animation speed in milliseconds.
  Spinner({
    this.message = '',
    this.spinnerCharacters = const <String>['|', '/', '-', '\\'],
    this.intervalMs = 100,
    Coordinate? startCoordinate,
  }) : _startCoordinate = startCoordinate;

  /// Whether the spinner is currently running.
  bool get isRunning => _isRunning;

  /// Starts the spinner animation.
  ///
  /// If the spinner is already running, this method does nothing.
  void start() {
    if (_isRunning || !_console.hasTerminal) return;

    _isRunning = true;
    _startCoordinate ??= _console.cursorPosition;
    _console.hideCursor();

    _timer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      _render();
    });

    // Render immediately
    _render();
  }

  /// Stops the spinner animation.
  ///
  /// Optionally displays a [finalMessage] in place of the spinner.
  void stop({String? finalMessage}) {
    if (!_isRunning) return;

    _timer?.cancel();
    _timer = null;
    _isRunning = false;

    // Clear the spinner line
    if (_startCoordinate != null) {
      _console.cursorPosition = _startCoordinate;
    }
    _console.eraseCursorToEnd();

    // Show final message if provided
    if (finalMessage != null) {
      _console.write(finalMessage);
      _console.writeLine();
    }

    _console.showCursor();
  }

  /// Updates the message displayed next to the spinner.
  void updateMessage(String newMessage) {
    if (_isRunning) {
      // Clear current line and re-render with new message
      if (_startCoordinate != null) {
        _console.cursorPosition = _startCoordinate;
      }
      _console.eraseCursorToEnd();
      _console.write('${spinnerCharacters[_frameIndex]} $newMessage');
    }
  }

  void _render() {
    if (_startCoordinate != null) {
      _console.cursorPosition = _startCoordinate;
    }
    _console.eraseCursorToEnd();

    final spinnerChar = spinnerCharacters[_frameIndex];
    if (message.isNotEmpty) {
      _console.write('$spinnerChar $message');
    } else {
      _console.write(spinnerChar);
    }

    _frameIndex = (_frameIndex + 1) % spinnerCharacters.length;
  }
}

/// Predefined spinner styles.
class SpinnerStyle {
  SpinnerStyle._();

  /// Classic rotating line spinner: | / - \
  static const List<String> line = ['|', '/', '-', '\\'];

  /// Dot spinner: ⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏
  static const List<String> dots = [
    '⠋',
    '⠙',
    '⠹',
    '⠸',
    '⠼',
    '⠴',
    '⠦',
    '⠧',
    '⠇',
    '⠏',
  ];

  /// Bouncing bar spinner: [=   ] [ =  ] [  = ] [   =]
  static const List<String> bouncingBar = [
    '[=   ]',
    '[ =  ]',
    '[  = ]',
    '[   =]',
    '[  = ]',
    '[ =  ]',
  ];

  /// Arrow spinner: ← ↖ ↑ ↗ → ↘ ↓ ↙
  static const List<String> arrows = ['←', '↖', '↑', '↗', '→', '↘', '↓', '↙'];

  /// Circle spinner: ◐ ◓ ◑ ◒
  static const List<String> circle = ['◐', '◓', '◑', '◒'];

  /// Square spinner: ◰ ◳ ◲ ◱
  static const List<String> square = ['◰', '◳', '◲', '◱'];

  /// Clock spinner: 🕐 🕑 🕒 🕓 🕔 🕕 🕖 🕗 🕘 🕙 🕚 🕛
  static const List<String> clock = [
    '🕐',
    '🕑',
    '🕒',
    '🕓',
    '🕔',
    '🕕',
    '🕖',
    '🕗',
    '🕘',
    '🕙',
    '🕚',
    '🕛',
  ];

  /// Simple dots: .  .. ...
  static const List<String> simpleDots = ['.  ', '.. ', '...', ' ..', '  .'];
}
