import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import '../termlib.dart';
import 'termios.dart';
import 'unistd.dart';

/// Common libc library paths for different Linux distributions.
///
/// - `libc.so.6` - Standard glibc on most Linux distributions
/// - `libc.so` - Generic fallback
/// - `libc.musl-x86_64.so.1` - Alpine Linux (x86_64)
/// - `libc.musl-aarch64.so.1` - Alpine Linux (ARM64)
/// - `/lib/libc.so.6` - Some distributions with different lib paths
/// - `/lib64/libc.so.6` - 64-bit systems with separate lib64
const _linuxLibcPaths = [
  'libc.so.6',
  'libc.so',
  'libc.musl-x86_64.so.1',
  'libc.musl-aarch64.so.1',
  '/lib/libc.so.6',
  '/lib64/libc.so.6',
  '/lib/x86_64-linux-gnu/libc.so.6',
  '/lib/aarch64-linux-gnu/libc.so.6',
];

class TermLibUnix implements TermLib {
  late final DynamicLibrary _stdlib;

  late final Pointer<TermIOS> _origTermIOSPointer;

  late final TCGetAttrDart tcgetattr;
  late final TCSetAttrDart tcsetattr;

  /// Attempts to load libc from multiple possible paths.
  ///
  /// This handles differences between Linux distributions:
  /// - Standard glibc distributions (Debian, Ubuntu, Fedora, etc.)
  /// - musl-based distributions (Alpine Linux)
  /// - Different library path configurations
  static DynamicLibrary _loadLinuxLibc() {
    for (final path in _linuxLibcPaths) {
      try {
        return DynamicLibrary.open(path);
      } catch (_) {
        // Try next path
      }
    }
    throw UnsupportedError(
      'Could not load libc. Tried paths: ${_linuxLibcPaths.join(", ")}',
    );
  }

  @override
  int setWindowHeight(int height) {
    stdout.write('\x1b[8;$height;t');
    return height;
  }

  @override
  int setWindowWidth(int width) {
    stdout.write('\x1b[8;;${width}t');
    return width;
  }

  @override
  void enableRawMode() {
    final origTermIOS = _origTermIOSPointer.ref;

    final newTermIOSPointer = calloc<TermIOS>()
      ..ref.c_iflag =
          origTermIOS.c_iflag & ~(brkint | icrnl | inpck | istrip | ixon)
      ..ref.c_oflag = origTermIOS.c_oflag & ~opost
      ..ref.c_cflag = (origTermIOS.c_cflag & ~csize) | cs8
      ..ref.c_lflag = origTermIOS.c_lflag & ~(echo | icanon | iexten | isig)
      ..ref.c_cc = origTermIOS.c_cc
      ..ref.c_cc[vmin] =
          0 // VMIN -- return each byte, or 0 for timeout
      ..ref.c_cc[vtime] =
          1 // VTIME -- 100ms timeout (unit is 1/10s)
      ..ref.c_ispeed = origTermIOS.c_ispeed
      ..ref.c_oflag = origTermIOS.c_ospeed;

    tcsetattr(stdinFileno, tcsanow, newTermIOSPointer);

    calloc.free(newTermIOSPointer);
  }

  @override
  void disableRawMode() {
    if (nullptr == _origTermIOSPointer.cast()) return;
    tcsetattr(stdinFileno, tcsanow, _origTermIOSPointer);
  }

  @override
  void dispose() {
    if (_origTermIOSPointer != nullptr) {
      calloc.free(_origTermIOSPointer);
    }
  }

  TermLibUnix() {
    _stdlib = Platform.isMacOS
        ? DynamicLibrary.open('/usr/lib/libSystem.dylib')
        : _loadLinuxLibc();

    tcgetattr = _stdlib.lookupFunction<TCGetAttrNative, TCGetAttrDart>(
      'tcgetattr',
    );
    tcsetattr = _stdlib.lookupFunction<TCSetAttrNative, TCSetAttrDart>(
      'tcsetattr',
    );

    // store console mode settings so we can return them again as necessary
    _origTermIOSPointer = calloc<TermIOS>();
    tcgetattr(stdinFileno, _origTermIOSPointer);
  }
}
