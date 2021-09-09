import 'dart:io';

class MetroConsole {
  static writeInGreen(String message) {
    stdout.writeln('\x1B[92m' + message + '\x1B[0m');
  }

  static writeInRed(String message) {
    stdout.writeln('\x1B[91m' + message + '\x1B[0m');
  }

  static writeInBlack(String message) {
    stdout.writeln(message);
  }
}
