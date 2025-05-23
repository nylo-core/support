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

  unknown
}

/// A representation of a keystroke.
class KeyStroke {
  bool isControl = false;
  String char = '';
  ControlCharacter controlChar = ControlCharacter.unknown;

  KeyStroke.printable(this.char) : assert(char.length == 1) {
    controlChar = ControlCharacter.none;
  }

  KeyStroke.control(this.controlChar) {
    char = '';
    isControl = true;
  }

  @override
  String toString() => isControl ? controlChar.toString() : char.toString();
}
