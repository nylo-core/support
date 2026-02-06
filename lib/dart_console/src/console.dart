import 'dart:io';
import 'dart:math';
import 'ansi.dart';
import 'consolecolor.dart';
import 'ffi/termlib.dart';
import 'ffi/win/termlib_win.dart';
import 'key.dart';
import 'scrollbackbuffer.dart';
import 'string_utils.dart';
import 'textalignment.dart';

/// A screen position, measured in rows and columns from the top-left origin
/// of the screen. Coordinates are zero-based, and converted as necessary
/// for the underlying system representation (e.g. one-based for VT-style
/// displays).
///
/// **Note on coordinate ordering:** This class uses row-first ordering, which
/// is conventional for terminal operations. The constructor takes `(row, col)`,
/// where:
/// - `row` is the vertical position (0 = top of screen)
/// - `col` is the horizontal position (0 = left of screen)
///
/// This differs from the parent [Point] class which uses `(x, y)` where `x` is
/// horizontal. Here, `row` maps to [Point.x] and `col` maps to [Point.y] for
/// internal storage, but you should use [row] and [col] getters for clarity.
///
/// Example:
/// ```dart
/// final pos = Coordinate(5, 10); // Row 5, Column 10
/// print(pos.row); // 5
/// print(pos.col); // 10
/// ```
class Coordinate extends Point<int> {
  /// Creates a coordinate with the given [row] and [col].
  ///
  /// Both values are zero-based, with (0, 0) representing the top-left corner.
  const Coordinate(super.row, super.col);

  /// The vertical position (row number), zero-based from the top.
  int get row => x;

  /// The horizontal position (column number), zero-based from the left.
  int get col => y;

  @override
  String toString() => '(row: $row, col: $col)';
}

/// A representation of the current console window.
///
/// Use the [Console] to get information about the current window and to read
/// and write to it.
///
/// A comprehensive set of demos of using the Console class can be found in the
/// `examples/` subdirectory.
class Console {
  bool _isRawMode = false;

  final _termlib = TermLib();

  // Declare the type explicitly: Initializing the _scrollbackBuffer
  // in the constructor means that we can no longer infer the type
  // here.
  final ScrollbackBuffer? _scrollbackBuffer;

  // Declaring the named constructor means that Dart no longer
  // supplies the default constructor. Besides, we need to set
  // _scrollbackBuffer to null for the regular console to work as
  // before.
  Console() : _scrollbackBuffer = null;

  // Create a named constructor specifically for scrolling consoles
  // Use `Console.scrolling(recordBlanks: false)` to omit blank lines
  // from console history
  Console.scrolling({bool recordBlanks = true})
    : _scrollbackBuffer = ScrollbackBuffer(recordBlanks: recordBlanks);

  /// Releases any resources allocated by the console.
  ///
  /// Call this method when you are done using the console to free any
  /// native resources that may have been allocated.
  void dispose() {
    _termlib.dispose();
  }

  /// Enables or disables raw mode.
  ///
  /// There are a series of flags applied to a UNIX-like terminal that together
  /// constitute 'raw mode'. These flags turn off echoing of character input,
  /// processing of input signals like Ctrl+C, and output processing, as well as
  /// buffering of input until a full line is entered.
  ///
  /// Raw mode is useful for console applications like text editors, which
  /// perform their own input and output processing, as well as for reading a
  /// single key from the input.
  ///
  /// In general, you should not need to enable or disable raw mode explicitly;
  /// you should call the [readKey] command, which takes care of handling raw
  /// mode for you.
  ///
  /// If you use raw mode, you should disable it before your program returns, to
  /// avoid the console being left in a state unsuitable for interactive input.
  ///
  /// When raw mode is enabled, the newline command (`\n`) does not also perform
  /// a carriage return (`\r`). You can use the [newLine] property or the
  /// [writeLine] function instead of explicitly using `\n` to ensure the
  /// correct results.
  ///
  set rawMode(bool value) {
    _isRawMode = value;
    if (value) {
      _termlib.enableRawMode();
    } else {
      _termlib.disableRawMode();
    }
  }

  /// Returns whether the terminal is in raw mode.
  ///
  /// There are a series of flags applied to a UNIX-like terminal that together
  /// constitute 'raw mode'. These flags turn off echoing of character input,
  /// processing of input signals like Ctrl+C, and output processing, as well as
  /// buffering of input until a full line is entered.
  bool get rawMode => _isRawMode;

  /// Returns whether the terminal supports Unicode emojis (👍)
  ///
  /// Assume Unicode emojis are supported when not on Windows.
  /// If we are on Windows, Unicode emojis are supported in Windows Terminal,
  /// which sets the WT_SESSION environment variable. See:
  /// https://github.com/microsoft/terminal/issues/1040
  bool get supportsEmoji =>
      !Platform.isWindows || Platform.environment.containsKey('WT_SESSION');

  /// Clears the entire screen
  void clearScreen() {
    if (Platform.isWindows) {
      final winTermlib = _termlib as TermLibWindows;
      winTermlib.clearScreen();
    } else {
      stdout.write(ansiEraseInDisplayAll + ansiResetCursorPosition);
    }
  }

  /// Erases all the characters in the current line.
  void eraseLine() => stdout.write(ansiEraseInLineAll);

  /// Erases the current line from the cursor to the end of the line.
  void eraseCursorToEnd() => stdout.write(ansiEraseCursorToEnd);

  /// Returns the width of the current console window in characters.
  int get windowWidth {
    if (hasTerminal) {
      return stdout.terminalColumns;
    } else {
      // Treat a window that has no terminal as if it is 80x25. This should be
      // more compatible with CI/CD environments.
      return 80;
    }
  }

  /// Returns the height of the current console window in characters.
  int get windowHeight {
    if (hasTerminal) {
      return stdout.terminalLines;
    } else {
      // Treat a window that has no terminal as if it is 80x25. This should be
      // more compatible with CI/CD environments.
      return 25;
    }
  }

  /// Whether there is a terminal attached to stdout.
  bool get hasTerminal => stdout.hasTerminal;

  /// Hides the cursor.
  ///
  /// If you hide the cursor, you should take care to return the cursor to
  /// a visible status at the end of the program, even if it throws an
  /// exception, by calling the [showCursor] method.
  void hideCursor() => stdout.write(ansiHideCursor);

  /// Shows the cursor.
  void showCursor() => stdout.write(ansiShowCursor);

  /// Moves the cursor one position to the left.
  void cursorLeft() => stdout.write(ansiCursorLeft);

  /// Moves the cursor one position to the right.
  void cursorRight() => stdout.write(ansiCursorRight);

  /// Moves the cursor one position up.
  void cursorUp() => stdout.write(ansiCursorUp);

  /// Moves the cursor one position down.
  void cursorDown() => stdout.write(ansiCursorDown);

  /// Moves the cursor to the top left corner of the screen.
  void resetCursorPosition() => stdout.write(ansiCursorPosition(1, 1));

  /// Returns the current cursor position as a coordinate.
  ///
  /// Warning: Linux and macOS terminals report their cursor position by
  /// posting an escape sequence to stdin in response to a request. However,
  /// if there is lots of other keyboard input at the same time, some
  /// terminals may interleave that input in the response. There is no
  /// easy way around this; the recommendation is therefore to use this call
  /// before reading keyboard input, to get an original offset, and then
  /// track the local cursor independently based on keyboard input.
  ///
  ///
  Coordinate? get cursorPosition {
    rawMode = true;
    stdout.write(ansiDeviceStatusReportCursorPosition);
    // returns a Cursor Position Report result in the form <ESC>[24;80R
    // which we have to parse apart, unfortunately
    var result = '';
    var i = 0;

    // avoid infinite loop if we're getting a bad result
    while (i < 16) {
      final readByte = stdin.readByteSync();

      if (readByte == -1) break; // headless console may not report back

      // ignore: use_string_buffers
      result += String.fromCharCode(readByte);
      if (result.endsWith('R')) break;
      i++;
    }
    rawMode = false;

    if (result.isEmpty || result[0] != '\x1b') {
      return null;
    }

    result = result.substring(2, result.length - 1);
    final coords = result.split(';');

    if (coords.length != 2) {
      return null;
    }
    if ((int.tryParse(coords[0]) != null) &&
        (int.tryParse(coords[1]) != null)) {
      return Coordinate(int.parse(coords[0]) - 1, int.parse(coords[1]) - 1);
    } else {
      return null;
    }
  }

  /// Sets the cursor to a specific coordinate.
  ///
  /// Coordinates are measured from the top left of the screen, and are
  /// zero-based.
  set cursorPosition(Coordinate? cursor) {
    if (cursor != null) {
      if (Platform.isWindows) {
        final winTermlib = _termlib as TermLibWindows;
        winTermlib.setCursorPosition(cursor.col, cursor.row);
      } else {
        stdout.write(ansiCursorPosition(cursor.row + 1, cursor.col + 1));
      }
    }
  }

  /// Sets the console foreground color to a named ANSI color.
  ///
  /// There are 16 named ANSI colors, as defined in the [ConsoleColor]
  /// enumeration. Depending on the console theme and background color,
  /// some colors may not offer a legible contrast against the background.
  void setForegroundColor(ConsoleColor foreground) {
    stdout.write(foreground.ansiSetForegroundColorSequence);
  }

  /// Sets the console background color to a named ANSI color.
  ///
  /// There are 16 named ANSI colors, as defined in the [ConsoleColor]
  /// enumeration. Depending on the console theme and background color,
  /// some colors may not offer a legible contrast against the background.
  void setBackgroundColor(ConsoleColor background) {
    stdout.write(background.ansiSetBackgroundColorSequence);
  }

  /// Sets the foreground to one of 256 extended ANSI colors.
  ///
  /// See https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit for
  /// the full set of colors. You may also run `examples/demo.dart` for this
  /// package, which provides a sample of each color in this list.
  void setForegroundExtendedColor(int colorValue) {
    assert(
      colorValue >= 0 && colorValue <= 0xFF,
      'Color must be a value between 0 and 255.',
    );

    stdout.write(ansiSetExtendedForegroundColor(colorValue));
  }

  /// Sets the background to one of 256 extended ANSI colors.
  ///
  /// See https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit for
  /// the full set of colors. You may also run `examples/demo.dart` for this
  /// package, which provides a sample of each color in this list.
  void setBackgroundExtendedColor(int colorValue) {
    assert(
      colorValue >= 0 && colorValue <= 0xFF,
      'Color must be a value between 0 and 255.',
    );

    stdout.write(ansiSetExtendedBackgroundColor(colorValue));
  }

  /// Sets the foreground color using 24-bit RGB values (TrueColor).
  ///
  /// Each color component ([r], [g], [b]) should be in the range 0-255.
  /// Not all terminals support TrueColor; most modern terminals do.
  void setForegroundRgbColor(int r, int g, int b) {
    assert(r >= 0 && r <= 255, 'Red component must be between 0 and 255.');
    assert(g >= 0 && g <= 255, 'Green component must be between 0 and 255.');
    assert(b >= 0 && b <= 255, 'Blue component must be between 0 and 255.');

    stdout.write(ansiSetRgbForegroundColor(r, g, b));
  }

  /// Sets the background color using 24-bit RGB values (TrueColor).
  ///
  /// Each color component ([r], [g], [b]) should be in the range 0-255.
  /// Not all terminals support TrueColor; most modern terminals do.
  void setBackgroundRgbColor(int r, int g, int b) {
    assert(r >= 0 && r <= 255, 'Red component must be between 0 and 255.');
    assert(g >= 0 && g <= 255, 'Green component must be between 0 and 255.');
    assert(b >= 0 && b <= 255, 'Blue component must be between 0 and 255.');

    stdout.write(ansiSetRgbBackgroundColor(r, g, b));
  }

  /// Sets the text style.
  ///
  /// Note that not all styles may be supported by all terminals.
  void setTextStyle({
    bool bold = false,
    bool faint = false,
    bool italic = false,
    bool underscore = false,
    bool blink = false,
    bool inverted = false,
    bool invisible = false,
    bool strikethru = false,
  }) {
    stdout.write(
      ansiSetTextStyles(
        bold: bold,
        faint: faint,
        italic: italic,
        underscore: underscore,
        blink: blink,
        inverted: inverted,
        invisible: invisible,
        strikethru: strikethru,
      ),
    );
  }

  /// Resets all color attributes and text styles to the default terminal
  /// setting.
  void resetColorAttributes() => stdout.write(ansiResetColor);

  /// Writes the text to the console.
  void write(Object text) => stdout.write(text);

  /// Returns the current newline string.
  String get newLine => _isRawMode ? '\r\n' : '\n';

  /// Writes an error message to the console, with newline automatically
  /// appended.
  void writeErrorLine(Object text) {
    stderr.write(text);

    // Even if we're in raw mode, we write '\n', since raw mode only applies
    // to stdout
    stderr.write('\n');
  }

  /// Writes a line to the console, optionally with alignment provided by the
  /// [TextAlignment] enumeration.
  ///
  /// If no parameters are supplied, the command simply writes a new line
  /// to the console. By default, text is left aligned.
  ///
  /// Text alignment operates based off the current window width, and pads
  /// the remaining characters with a space character.
  void writeLine([Object? text, TextAlignment alignment = TextAlignment.left]) {
    final int width = windowWidth;
    if (text != null) {
      writeAligned(text.toString(), width, alignment);
    }
    stdout.writeln();
  }

  /// Writes a quantity of text to the console with padding to the given width.
  void writeAligned(
    Object text, [
    int? width,
    TextAlignment alignment = TextAlignment.left,
  ]) {
    final textAsString = text.toString();
    stdout.write(
      textAsString.alignText(
        width: width ?? textAsString.length,
        alignment: alignment,
      ),
    );
  }

  /// Parses CSI (Control Sequence Introducer) escape sequences.
  ///
  /// CSI sequences start with ESC [ and are used for cursor movement,
  /// function keys, and other control sequences.
  ControlCharacter _parseCsiSequence(String char) {
    switch (char) {
      case 'A':
        return ControlCharacter.arrowUp;
      case 'B':
        return ControlCharacter.arrowDown;
      case 'C':
        return ControlCharacter.arrowRight;
      case 'D':
        return ControlCharacter.arrowLeft;
      case 'H':
        return ControlCharacter.home;
      case 'F':
        return ControlCharacter.end;
      default:
        return ControlCharacter.unknown;
    }
  }

  /// Parses numeric CSI escape sequences (e.g., ESC [ 3 ~ or ESC [ 15 ~).
  ///
  /// These sequences are used for keys like Delete, Page Up, Page Down,
  /// and function keys F5-F12.
  ControlCharacter _parseNumericCsiSequence(String numStr) {
    switch (numStr) {
      case '1':
        return ControlCharacter.home;
      case '3':
        return ControlCharacter.delete;
      case '4':
        return ControlCharacter.end;
      case '5':
        return ControlCharacter.pageUp;
      case '6':
        return ControlCharacter.pageDown;
      case '7':
        return ControlCharacter.home;
      case '8':
        return ControlCharacter.end;
      // F5-F12 use multi-digit sequences
      case '15':
        return ControlCharacter.F5;
      case '17':
        return ControlCharacter.F6;
      case '18':
        return ControlCharacter.F7;
      case '19':
        return ControlCharacter.F8;
      case '20':
        return ControlCharacter.F9;
      case '21':
        return ControlCharacter.F10;
      case '23':
        return ControlCharacter.F11;
      case '24':
        return ControlCharacter.F12;
      default:
        return ControlCharacter.unknown;
    }
  }

  /// Parses SS3 (Single Shift 3) escape sequences.
  ///
  /// SS3 sequences start with ESC O and are used for function keys F1-F4
  /// and some navigation keys.
  ControlCharacter _parseSs3Sequence(String char) {
    switch (char) {
      case 'H':
        return ControlCharacter.home;
      case 'F':
        return ControlCharacter.end;
      case 'P':
        return ControlCharacter.F1;
      case 'Q':
        return ControlCharacter.F2;
      case 'R':
        return ControlCharacter.F3;
      case 'S':
        return ControlCharacter.F4;
      default:
        return ControlCharacter.unknown;
    }
  }

  /// Reads a single key from the input, including a variety of control
  /// characters.
  ///
  /// Keys are represented by the [KeyStroke] class. Keys may be printable (if so,
  /// `Key.isControl` is `false`, and the `Key.char` property may be used to
  /// identify the key pressed. Non-printable keys have `Key.isControl` set
  /// to `true`, and if so the `Key.char` property is empty and instead the
  /// `KeyStroke.controlChar` property will be set to a value from the
  /// [ControlCharacter] enumeration that describes which key was pressed.
  ///
  /// Owing to the limitations of terminal key handling, certain keys may
  /// be represented by multiple control key sequences. An example showing
  /// basic key handling can be found in the `example/command_line.dart`
  /// file in the package source code.
  KeyStroke readKey() {
    int charCode;
    var codeUnit = 0;

    rawMode = true;
    while (codeUnit <= 0) {
      codeUnit = stdin.readByteSync();
    }

    KeyStroke key;

    if (codeUnit >= 0x01 && codeUnit <= 0x1a) {
      // Ctrl+A thru Ctrl+Z are mapped to the 1st-26th entries in the
      // enum, so it's easy to convert them across
      key = KeyStroke.control(ControlCharacter.values[codeUnit]);
    } else if (codeUnit == 0x1b) {
      // escape sequence (e.g. \x1b[A for up arrow)
      charCode = stdin.readByteSync();
      if (charCode == -1) {
        rawMode = false;
        return KeyStroke.control(ControlCharacter.escape);
      }
      final firstChar = String.fromCharCode(charCode);

      if (charCode == 127) {
        key = KeyStroke.control(ControlCharacter.wordBackspace);
      } else if (firstChar == '[') {
        // CSI sequence
        charCode = stdin.readByteSync();
        if (charCode == -1) {
          rawMode = false;
          return KeyStroke.control(ControlCharacter.escape);
        }
        final secondChar = String.fromCharCode(charCode);

        final csiResult = _parseCsiSequence(secondChar);
        if (csiResult != ControlCharacter.unknown) {
          key = KeyStroke.control(csiResult);
        } else if (secondChar.codeUnits[0] >= '0'.codeUnits[0] &&
            secondChar.codeUnits[0] <= '9'.codeUnits[0]) {
          // Numeric CSI sequence (e.g., ESC [ 3 ~ or ESC [ 15 ~)
          // Collect all digits until we hit a non-digit character
          final numBuffer = StringBuffer(secondChar);
          ControlCharacter resultChar = ControlCharacter.escape;
          while (true) {
            charCode = stdin.readByteSync();
            if (charCode == -1) {
              rawMode = false;
              return KeyStroke.control(ControlCharacter.escape);
            }
            final nextChar = String.fromCharCode(charCode);
            if (nextChar.codeUnits[0] >= '0'.codeUnits[0] &&
                nextChar.codeUnits[0] <= '9'.codeUnits[0]) {
              numBuffer.write(nextChar);
            } else if (nextChar == '~') {
              resultChar = _parseNumericCsiSequence(numBuffer.toString());
              break;
            } else {
              resultChar = ControlCharacter.unknown;
              break;
            }
          }
          key = KeyStroke.control(resultChar);
        } else {
          key = KeyStroke.control(ControlCharacter.unknown);
        }
      } else if (firstChar == 'O') {
        // SS3 sequence
        charCode = stdin.readByteSync();
        if (charCode == -1) {
          rawMode = false;
          return KeyStroke.control(ControlCharacter.escape);
        }
        final secondChar = String.fromCharCode(charCode);
        key = KeyStroke.control(_parseSs3Sequence(secondChar));
      } else if (firstChar == 'b') {
        key = KeyStroke.control(ControlCharacter.wordLeft);
      } else if (firstChar == 'f') {
        key = KeyStroke.control(ControlCharacter.wordRight);
      } else {
        key = KeyStroke.control(ControlCharacter.unknown);
      }
    } else if (codeUnit == 0x7f) {
      key = KeyStroke.control(ControlCharacter.backspace);
    } else if (codeUnit == 0x00 || (codeUnit >= 0x1c && codeUnit <= 0x1f)) {
      key = KeyStroke.control(ControlCharacter.unknown);
    } else {
      // assume other characters are printable
      key = KeyStroke.printable(String.fromCharCode(codeUnit));
    }
    rawMode = false;
    return key;
  }

  /// Reads a line of input, handling basic keyboard navigation commands.
  ///
  /// The Dart [stdin.readLineSync()] function reads a line from the input,
  /// however it does not handle cursor navigation (e.g. arrow keys, home and
  /// end keys), and has side-effects that may be unhelpful for certain console
  /// applications. For example, Ctrl+C is processed as the break character,
  /// which causes the application to immediately exit.
  ///
  /// The implementation does not currently allow for multi-line input. It
  /// is best suited for short text fields that are not longer than the width
  /// of the current screen.
  ///
  /// By default, readLine ignores break characters (e.g. Ctrl+C) and the Esc
  /// key, but if enabled, the function will exit and return a null string if
  /// those keys are pressed.
  ///
  /// A callback function may be supplied, as a peek-ahead for what is being
  /// entered. This is intended for scenarios like auto-complete, where the
  /// text field is coupled with some other content.
  ///
  /// If [maskChar] is provided, each character of the input will be displayed
  /// as the mask character (e.g., '*' for password fields). The actual input
  /// is still returned as the result.
  String? readLine({
    bool cancelOnBreak = false,
    bool cancelOnEscape = false,
    bool cancelOnEOF = false,
    String? maskChar,
    void Function(String text, KeyStroke lastPressed)? callback,
  }) {
    var buffer = '';
    var index = 0; // cursor position relative to buffer, not screen

    final screenRow = cursorPosition!.row;
    final screenColOffset = cursorPosition!.col;

    final bufferMaxLength = windowWidth - screenColOffset - 3;

    while (true) {
      final key = readKey();

      if (key.isControl) {
        switch (key.controlChar) {
          case ControlCharacter.enter:
            if (_scrollbackBuffer != null) {
              _scrollbackBuffer.add(buffer);
            }
            writeLine();
            return buffer;
          case ControlCharacter.ctrlC:
            if (cancelOnBreak) return null;
            break;
          case ControlCharacter.escape:
            if (cancelOnEscape) return null;
            break;
          case ControlCharacter.backspace:
          case ControlCharacter.ctrlH:
            if (index > 0) {
              buffer = buffer.substring(0, index - 1) + buffer.substring(index);
              index--;
            }
            break;
          case ControlCharacter.ctrlU:
            buffer = buffer.substring(index, buffer.length);
            index = 0;
            break;
          case ControlCharacter.delete:
          case ControlCharacter.ctrlD:
            if (index < buffer.length) {
              buffer = buffer.substring(0, index) + buffer.substring(index + 1);
            } else if (cancelOnEOF) {
              return null;
            }
            break;
          case ControlCharacter.ctrlK:
            buffer = buffer.substring(0, index);
            break;
          case ControlCharacter.arrowLeft:
          case ControlCharacter.ctrlB:
            index = index > 0 ? index - 1 : index;
            break;
          case ControlCharacter.arrowUp:
            if (_scrollbackBuffer != null) {
              buffer = _scrollbackBuffer.up(buffer);
              index = buffer.length;
            }
            break;
          case ControlCharacter.arrowDown:
            if (_scrollbackBuffer != null) {
              final temp = _scrollbackBuffer.down();
              if (temp != null) {
                buffer = temp;
                index = buffer.length;
              }
            }
            break;
          case ControlCharacter.arrowRight:
          case ControlCharacter.ctrlF:
            index = index < buffer.length ? index + 1 : index;
            break;
          case ControlCharacter.wordLeft:
            if (index > 0) {
              final bufferLeftOfCursor = buffer.substring(0, index - 1);
              final lastSpace = bufferLeftOfCursor.lastIndexOf(' ');
              index = lastSpace != -1 ? lastSpace + 1 : 0;
            }
            break;
          case ControlCharacter.wordRight:
            if (index < buffer.length) {
              final bufferRightOfCursor = buffer.substring(index + 1);
              final nextSpace = bufferRightOfCursor.indexOf(' ');
              index = nextSpace != -1
                  ? min(index + nextSpace + 2, buffer.length)
                  : buffer.length;
            }
            break;
          case ControlCharacter.home:
          case ControlCharacter.ctrlA:
            index = 0;
            break;
          case ControlCharacter.end:
          case ControlCharacter.ctrlE:
            index = buffer.length;
            break;
          default:
            break;
        }
      } else {
        if (buffer.length < bufferMaxLength) {
          if (index == buffer.length) {
            buffer += key.char;
            index++;
          } else {
            buffer =
                buffer.substring(0, index) + key.char + buffer.substring(index);
            index++;
          }
        }
      }

      cursorPosition = Coordinate(screenRow, screenColOffset);
      eraseCursorToEnd();
      // Display masked characters if maskChar is provided, otherwise show actual buffer
      final displayBuffer = maskChar != null
          ? maskChar * buffer.length
          : buffer;
      write(displayBuffer); // allow for backspace condition
      cursorPosition = Coordinate(screenRow, screenColOffset + index);

      if (callback != null) callback(buffer, key);
    }
  }
}
