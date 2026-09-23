import 'dart:async';

import 'package:flutter/foundation.dart';

/// The zone value that also receives every line written with [LiveOutput].
///
/// Seeders run inside a zone holding their run's log, so their messages show
/// up in Metro in order with the changes they make.
const Symbol liveOutputZoneKey = #nyloLiveOutput;

/// Writes lines to the terminal that ran a live command or seeder.
mixin LiveOutput {
  final List<Map<String, String>> _output = [];

  /// The lines written with [info], [success], [warning], [error] and [line].
  List<Map<String, String>> get output => List.unmodifiable(_output);

  /// Write an informational line to the terminal.
  void info(String message) =>
      writeOutput({'level': 'info', 'message': message});

  /// Write a success line to the terminal.
  void success(String message) =>
      writeOutput({'level': 'success', 'message': message});

  /// Write a warning line to the terminal.
  void warning(String message) =>
      writeOutput({'level': 'warning', 'message': message});

  /// Write an error line to the terminal.
  void error(String message) =>
      writeOutput({'level': 'error', 'message': message});

  /// Write a plain line to the terminal.
  void line(String message) =>
      writeOutput({'level': 'line', 'message': message});

  /// Adds [entry] (a `level` and `message`) to [output].
  @protected
  void writeOutput(Map<String, String> entry) {
    _output.add(entry);
    final Object? sink = Zone.current[liveOutputZoneKey];
    if (sink is void Function(Map<String, String>)) sink(entry);
  }
}
