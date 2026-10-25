/// Screenshots: PNGs of the app's screen, or of one part of it.
///
/// [Screenshot.capture] reads the whole screen and [Screenshot.area] reads a
/// [ScreenshotArea], in any build mode. Metro captures a running app with
/// `metro live:run screenshot`.
library;

export 'src/screenshot.dart';
export 'src/screenshot_look.dart';
export 'src/screenshot_store.dart' show ScreenshotStore;
