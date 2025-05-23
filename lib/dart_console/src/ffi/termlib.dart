import 'dart:io';

import 'unix/termlib_unix.dart';
import 'win/termlib_win.dart';

abstract class TermLib {
  int setWindowHeight(int height);
  int setWindowWidth(int width);

  void enableRawMode();
  void disableRawMode();

  factory TermLib() {
    if (Platform.isWindows) {
      return TermLibWindows();
    } else {
      return TermLibUnix();
    }
  }
}
