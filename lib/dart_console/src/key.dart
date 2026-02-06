enum ControlCharacter {
  none,

  ctrlA,
  ctrlB,
  ctrlC, // Break
  ctrlD, // End of File
  ctrlE,
  ctrlF,
  ctrlG, // Bell
  ctrlH, // Backspace
  tab,
  ctrlJ,
  ctrlK,
  ctrlL,
  enter,
  ctrlN,
  ctrlO,
  ctrlP,
  ctrlQ,
  ctrlR,
  ctrlS,
  ctrlT,
  ctrlU,
  ctrlV,
  ctrlW,
  ctrlX,
  ctrlY,
  ctrlZ, // Suspend

  arrowLeft,
  arrowRight,
  arrowUp,
  arrowDown,
  pageUp,
  pageDown,
  wordLeft,
  wordRight,

  home,
  end,
  escape,
  delete,
  backspace,
  wordBackspace,

  // ignore: constant_identifier_names
  F1,
  // ignore: constant_identifier_names
  F2,
  // ignore: constant_identifier_names
  F3,
  // ignore: constant_identifier_names
  F4,
  // ignore: constant_identifier_names
  F5,
  // ignore: constant_identifier_names
  F6,
  // ignore: constant_identifier_names
  F7,
  // ignore: constant_identifier_names
  F8,
  // ignore: constant_identifier_names
  F9,
  // ignore: constant_identifier_names
  F10,
  // ignore: constant_identifier_names
  F11,
  // ignore: constant_identifier_names
  F12,

  unknown,
}

/// A representation of a keystroke.
///
/// This class is immutable. Use the factory constructors to create instances.
class KeyStroke {
  /// Whether this keystroke represents a control character.
  final bool isControl;

  /// The printable character, if this is a printable keystroke.
  final String char;

  /// The control character, if this is a control keystroke.
  final ControlCharacter controlChar;

  /// Creates a keystroke for a printable character.
  const KeyStroke.printable(this.char)
    : assert(char.length == 1),
      isControl = false,
      controlChar = ControlCharacter.none;

  /// Creates a keystroke for a control character.
  const KeyStroke.control(this.controlChar) : char = '', isControl = true;

  @override
  String toString() => isControl ? controlChar.toString() : char.toString();
}
