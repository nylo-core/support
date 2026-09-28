import 'dart:io';
import 'dart:ui' show DartPluginRegistrant;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show AssetBundle, RootIsolateToken;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'disk_driver.dart';
import 'disk_exceptions.dart';
import 'drivers/asset_disk_driver.dart';
import 'drivers/local_disk_driver.dart';
import 'drivers/memory_disk_driver.dart';

/// The folders on the device a local disk can live in.
///
/// | Root        | iOS                          | Android                         |
/// |-------------|------------------------------|---------------------------------|
/// | `support`   | Library/Application Support  | files                           |
/// | `documents` | Documents                    | app_flutter                     |
/// | `cache`     | Library/Caches               | cache                           |
/// | `temporary` | tmp                          | cache/tmp                       |
/// | `library`   | Library                      | not available                   |
/// | `downloads` | Downloads (app-private)      | Android/data/…/files/Download   |
/// | `external`  | not available                | Android/data/…/files            |
///
/// `temporary` is the OS temp folder, not path_provider's
/// `getTemporaryDirectory()`, which returns the caches folder on iOS and
/// Android. `downloads` is private to the app on both platforms: it is not
/// the Downloads folder the user sees.
enum DiskRoot {
  /// Files the app manages. Backed up; not visible to the user.
  support,

  /// Files that belong to the user. Backed up, and shown in the iOS Files
  /// app when file sharing is turned on.
  documents,

  /// Files the app can fetch again. Not backed up; the OS may delete them
  /// when space is low.
  cache,

  /// Scratch files. Not backed up; iOS may delete them whenever the app
  /// isn't running.
  temporary,

  /// The iOS and macOS Library folder.
  library,

  /// An app-private downloads folder.
  downloads,

  /// Android's app-specific external storage.
  external;

  /// The absolute path of this folder on the current device.
  ///
  /// Throws [DiskException] when the platform has no such folder.
  Future<String> resolve() async {
    // path_provider calls the OS through FFI, which a background isolate
    // can only reach after registering the Dart plugin implementations.
    if (!kIsWeb && RootIsolateToken.instance == null) {
      DartPluginRegistrant.ensureInitialized();
    }
    try {
      switch (this) {
        case DiskRoot.support:
          return (await getApplicationSupportDirectory()).path;
        case DiskRoot.documents:
          return (await getApplicationDocumentsDirectory()).path;
        case DiskRoot.cache:
          return (await getApplicationCacheDirectory()).path;
        case DiskRoot.temporary:
          if (Platform.isIOS || Platform.isMacOS) {
            return Directory.systemTemp.path;
          }
          return p.join((await getApplicationCacheDirectory()).path, 'tmp');
        case DiskRoot.library:
          return (await getLibraryDirectory()).path;
        case DiskRoot.downloads:
          final Directory? downloads = await getDownloadsDirectory();
          if (downloads == null) throw UnsupportedError('No downloads folder');
          return downloads.path;
        case DiskRoot.external:
          final Directory? external = await getExternalStorageDirectory();
          if (external == null) throw UnsupportedError('No external storage');
          return external.path;
      }
    } catch (error) {
      throw DiskException(
        'Could not find the $name folder on this platform',
        cause: error,
      );
    }
  }
}

/// How to build a disk: its driver, its folder inside that driver, and
/// its rules.
///
/// Configs are plain objects, so a driver of your own needs no
/// registration: pass it to [DiskConfig.custom].
class DiskConfig {
  const DiskConfig._({
    this.createDriver,
    this.prefix = '',
    this.readOnly = false,
    this.prune,
    this.scopes,
    this.protectRoot = false,
  });

  /// A folder on the device, inside [root].
  ///
  /// Keep your files in their own [prefix] folder when other plugins write
  /// to the same root: without a prefix, emptying the whole disk is refused.
  /// With [prune], files older than that are deleted in the background the
  /// first time the disk is used in each session. On the web, which has no
  /// file system, the disk lives in memory.
  factory DiskConfig.local(
    DiskRoot root, {
    String prefix = '',
    bool readOnly = false,
    Duration? prune,
  }) => DiskConfig._(
    createDriver: () =>
        kIsWeb ? MemoryDiskDriver() : LocalDiskDriver(root.resolve),
    prefix: prefix,
    readOnly: readOnly,
    prune: prune,
    protectRoot: prefix.isEmpty,
  );

  /// The folder at the absolute path [root]; Laravel's on-demand disk.
  factory DiskConfig.path(
    String root, {
    String prefix = '',
    bool readOnly = false,
    Duration? prune,
  }) => DiskConfig._(
    createDriver: () => kIsWeb ? MemoryDiskDriver() : LocalDiskDriver.at(root),
    prefix: prefix,
    readOnly: readOnly,
    prune: prune,
  );

  /// The app bundle under [prefix], read-only.
  factory DiskConfig.assets({String prefix = 'assets', AssetBundle? bundle}) =>
      DiskConfig._(
        createDriver: () => AssetDiskDriver(bundle: bundle),
        prefix: prefix,
        readOnly: true,
      );

  /// A disk that only lives in memory.
  factory DiskConfig.memory({String prefix = '', bool readOnly = false}) =>
      DiskConfig._(
        createDriver: MemoryDiskDriver.new,
        prefix: prefix,
        readOnly: readOnly,
      );

  /// Another disk, under [prefix]; Laravel's `scoped` driver.
  factory DiskConfig.scoped(
    String disk,
    String prefix, {
    bool readOnly = false,
  }) => DiskConfig._(scopes: disk, prefix: prefix, readOnly: readOnly);

  /// A disk backed by your own [DiskDriver].
  factory DiskConfig.custom(
    DiskDriver Function() driver, {
    String prefix = '',
    bool readOnly = false,
    Duration? prune,
  }) => DiskConfig._(
    createDriver: driver,
    prefix: prefix,
    readOnly: readOnly,
    prune: prune,
  );

  /// Builds this disk's driver. Null for [DiskConfig.scoped] disks, which
  /// use the driver of the disk they scope.
  final DiskDriver Function()? createDriver;

  /// The folder inside the driver that the disk treats as its root.
  final String prefix;

  /// Whether writes are refused.
  final bool readOnly;

  /// Files older than this are deleted the first time the disk is used in
  /// each session.
  final Duration? prune;

  /// The disk a [DiskConfig.scoped] disk sits inside.
  final String? scopes;

  /// Whether emptying the whole disk is refused, because it is an OS folder
  /// that other plugins write to.
  final bool protectRoot;
}
