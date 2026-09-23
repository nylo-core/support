/// Nylo Live: run commands inside your running app from Metro.
///
/// Built-in commands (`metro live:run route`, `metro live:run storage`, ...),
/// your own [LiveCommand]s from `lib/app/commands/` and your [Seeder]s from
/// `lib/app/seeders/` are exposed to Metro as Dart VM service extensions while
/// the app runs in debug or profile mode. Release builds never register them.
library;

export 'src/ny_live.dart' show NyLive, NyLiveNavigatorObserver;
export 'src/live_command.dart';
export 'src/live_exception.dart';
export 'src/live_output.dart' show LiveOutput;
export 'src/seeder.dart';
export 'src/storage_snapshot.dart' show StorageSnapshot;
