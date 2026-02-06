import 'dart:io';

import '../../dart_console/ny_dart_console.dart';

/// Print messages in the console
/// e.g. MetroConsole.writeInGreen('success');
class MetroConsole {
  // ANSI escape codes for text styles
  static const String _bold = '\x1B[1m';
  static const String _reset = '\x1B[0m';

  /// writes a [message] in green.
  static void writeInGreen(String message) {
    stdout.writeln('\x1B[92m$message$_reset');
  }

  /// writes a [message] in red.
  static void writeInRed(String message) {
    stdout.writeln('\x1B[91m$message$_reset');
  }

  /// writes a [message] in black.
  static void writeInBlack(String message) {
    stdout.writeln(message);
  }

  /// writes a [message] in yellow.
  /// Useful for warning messages.
  static void writeInYellow(String message) {
    stdout.writeln('\x1B[93m$message$_reset');
  }

  /// writes a [message] in cyan.
  /// Useful for informational messages.
  static void writeInCyan(String message) {
    stdout.writeln('\x1B[96m$message$_reset');
  }

  /// writes a [message] in bold.
  static void writeInBold(String message) {
    stdout.writeln('$_bold$message$_reset');
  }

  /// Flexible write method with optional color, style, and newline control.
  ///
  /// [message] - The text to write to the console.
  /// [color] - Optional ConsoleColor for the text.
  /// [bold] - Whether to make the text bold (default: false).
  /// [newLine] - Whether to append a newline (default: true).
  ///
  /// Example:
  /// ```dart
  /// MetroConsole.write('Processing...', color: ConsoleColor.cyan, bold: true, newLine: false);
  /// MetroConsole.write(' Done!', color: ConsoleColor.green);
  /// ```
  static void write(
    String message, {
    ConsoleColor? color,
    bool bold = false,
    bool newLine = true,
  }) {
    final buffer = StringBuffer();

    // Apply bold if requested
    if (bold) {
      buffer.write(_bold);
    }

    // Apply color if provided
    if (color != null) {
      buffer.write(color.ansiSetForegroundColorSequence);
    }

    // Write the message
    buffer.write(message);

    // Reset styling
    if (bold || color != null) {
      buffer.write(_reset);
    }

    // Output with or without newline
    if (newLine) {
      stdout.writeln(buffer.toString());
    } else {
      stdout.write(buffer.toString());
    }
  }

  /// Creates a terminal hyperlink using OSC 8 escape sequence.
  /// Supported by VS Code, Cursor, iTerm2, GNOME Terminal, Windows Terminal, etc.
  /// Falls back to plain text in terminals that don't support it.
  static String hyperlink(String text, String filePath) {
    final absolutePath = File(filePath).absolute.path;
    // Using BEL (\x07) instead of ST (\x1B\\) for broader terminal compatibility
    return '\x1B]8;;file://$absolutePath\x07$text\x1B]8;;\x07';
  }

  /// Creates a colored terminal hyperlink.
  ///
  /// Combines hyperlink functionality with color styling.
  /// [text] - The display text for the hyperlink.
  /// [filePath] - The file path the hyperlink points to.
  /// [color] - The color to apply to the hyperlink text.
  /// [bold] - Whether to make the hyperlink text bold (default: false).
  ///
  /// Example:
  /// ```dart
  /// final link = MetroConsole.coloredHyperlink('config.dart', 'lib/config.dart', ConsoleColor.brightGreen);
  /// MetroConsole.writeInBlack('Created $link');
  /// ```
  static String coloredHyperlink(
    String text,
    String filePath,
    ConsoleColor color, {
    bool bold = false,
  }) {
    final absolutePath = File(filePath).absolute.path;
    final buffer = StringBuffer();

    // Apply bold if requested
    if (bold) {
      buffer.write(_bold);
    }

    // Apply color
    buffer.write(color.ansiSetForegroundColorSequence);

    // Create the hyperlink
    buffer.write('\x1B]8;;file://$absolutePath\x07$text\x1B]8;;\x07');

    // Reset styling
    buffer.write(_reset);

    return buffer.toString();
  }

  /// Resets any active console styling.
  ///
  /// Useful for error recovery or ensuring clean output after styled text.
  static void reset() {
    stdout.write(_reset);
  }
}
