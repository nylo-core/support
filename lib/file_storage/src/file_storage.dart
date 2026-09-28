import 'dart:typed_data';

import 'package:dio/dio.dart' show CancelToken, ProgressCallback;

import '/testing/src/fake_disk.dart';
import 'disk.dart';
import 'disk_config.dart';
import 'disk_driver.dart';
import 'disk_exceptions.dart';
import 'path_normalizer.dart';

/// Nylo's file storage: named disks, the way Laravel's `Storage` facade
/// works.
///
/// ```dart
/// await FileStorage.disk('documents').put('reports/q3.pdf', pdfBytes);
/// await FileStorage.put('notes.txt', 'Hello'); // the default disk
/// ```
///
/// `disk('documents')` is the short form. Five disks exist without any
/// configuration (`local`, `documents`, `cache`, `temp` and `assets`); add or
/// change them in `lib/config/file_storage.dart`, which is passed to
/// `nylo.configure(disks: ...)`.
class FileStorage {
  FileStorage._();

  /// The disks every app starts with.
  ///
  /// | Disk        | Where                                   | Notes                     |
  /// |-------------|-----------------------------------------|---------------------------|
  /// | `local`     | Application Support/nylo (iOS), files/nylo (Android) | the default disk |
  /// | `documents` | Documents (iOS), app_flutter (Android)  | the user's files          |
  /// | `cache`     | Caches/nylo (iOS), cache/nylo (Android) | the OS may clear it       |
  /// | `temp`      | tmp/nylo (iOS), cache/tmp/nylo (Android)| pruned after a day        |
  /// | `assets`    | the app bundle, under `assets/`         | read-only                 |
  static Map<String, DiskConfig> get defaultDisks => {
    'local': DiskConfig.local(DiskRoot.support, prefix: 'nylo'),
    'documents': DiskConfig.local(DiskRoot.documents),
    'cache': DiskConfig.local(DiskRoot.cache, prefix: 'nylo'),
    'temp': DiskConfig.local(
      DiskRoot.temporary,
      prefix: 'nylo',
      prune: const Duration(days: 1),
    ),
    'assets': DiskConfig.assets(),
  };

  static Map<String, DiskConfig> _configs = defaultDisks;
  static String _defaultDisk = 'local';
  static final Map<String, Disk> _disks = {};
  static final Map<String, FakeDisk> _fakes = {};
  static bool _fakeWritableDisks = false;

  /// The name of the disk used when no name is given.
  static String get defaultDisk => _defaultDisk;

  /// The names of the configured disks.
  static List<String> get names => _configs.keys.toList();

  /// The disks swapped for fakes, by name.
  static Map<String, FakeDisk> get fakes => Map.unmodifiable(_fakes);

  /// Adds [disks] to the defaults, replacing any with the same name, and
  /// sets the [defaultDisk].
  static void configure({Map<String, DiskConfig>? disks, String? defaultDisk}) {
    final Map<String, DiskConfig> configs = disks == null
        ? _configs
        : {...defaultDisks, ...disks};
    final String name = defaultDisk ?? _defaultDisk;
    if (!configs.containsKey(name)) throw DiskNotConfiguredException(name);
    _configs = configs;
    _defaultDisk = name;
    _disks.clear();
  }

  /// Restores the default disks and drops every fake.
  static void reset() {
    _configs = defaultDisks;
    _defaultDisk = 'local';
    _disks.clear();
    _fakes.clear();
    _fakeWritableDisks = false;
  }

  /// The disk named [name], or the default disk.
  ///
  /// Throws [DiskNotConfiguredException] for an unknown name.
  static Disk disk([String? name]) {
    final String key = name ?? _defaultDisk;
    final FakeDisk? fake = _fakes[key];
    if (fake != null) return fake;
    final Disk? built = _disks[key];
    if (built != null) return built;
    final DiskConfig? config = _configs[key];
    if (config == null) throw DiskNotConfiguredException(key);
    if (_fakeWritableDisks && config.scopes == null && !config.readOnly) {
      return _fakes[key] = FakeDisk(key);
    }
    return _disks[key] = _build(key, config);
  }

  /// A disk that isn't in the config; Laravel's `Storage::build`.
  ///
  /// ```dart
  /// final Disk exports = FileStorage.build(DiskConfig.path(folder));
  /// ```
  static Disk build(DiskConfig config, {String name = 'on-demand'}) =>
      _build(name, config);

  static Disk _build(String name, DiskConfig config) {
    final String? parent = config.scopes;
    if (parent != null) {
      final Disk base = disk(parent);
      return Disk(
        name,
        base.driver,
        prefix: joinDiskPath(
          base.prefix,
          normalizeDiskPath(config.prefix, disk: name),
        ),
        readOnly: config.readOnly || base.readOnly,
      );
    }
    final DiskDriver Function()? createDriver = config.createDriver;
    if (createDriver == null) {
      throw DiskException('This disk config has no driver', disk: name);
    }
    return Disk(
      name,
      createDriver(),
      prefix: config.prefix,
      readOnly: config.readOnly,
      protectRoot: config.protectRoot,
      prune: config.prune,
    );
  }

  /// Swaps the disk named [name] (or the default disk) for an empty
  /// in-memory [FakeDisk], and returns it for assertions.
  ///
  /// ```dart
  /// final FakeDisk photos = FileStorage.fake('photos');
  /// // ...run the code under test...
  /// photos.assertExists('avatars/1.jpg');
  /// ```
  static FakeDisk fake([String? name]) {
    final String key = name ?? _defaultDisk;
    _disks.clear(); // scoped disks built over the old disk must rebuild
    return _fakes[key] = FakeDisk(key);
  }

  /// When [enabled], every writable disk becomes an in-memory [FakeDisk]
  /// on first use. `NyTest.init()` turns this on, so tests never write to
  /// the machine running them. Read-only disks such as `assets` stay real.
  static void useFakes([bool enabled = true]) {
    _fakeWritableDisks = enabled;
    clearFakes();
  }

  /// Drops every fake; the next use of a faked disk starts empty.
  static void clearFakes() {
    _fakes.clear();
    _disks.clear();
  }

  // ---------------------------------------------------------------------------
  // The default disk
  // ---------------------------------------------------------------------------

  /// `Disk.exists` on the default disk.
  static Future<bool> exists(String path) => disk().exists(path);

  /// `Disk.missing` on the default disk.
  static Future<bool> missing(String path) => disk().missing(path);

  /// `Disk.directoryExists` on the default disk.
  static Future<bool> directoryExists(String path) =>
      disk().directoryExists(path);

  /// `Disk.get` on the default disk.
  static Future<String> get(String path) => disk().get(path);

  /// `Disk.bytes` on the default disk.
  static Future<Uint8List> bytes(String path) => disk().bytes(path);

  /// `Disk.json` on the default disk.
  static Future<T?> json<T>(String path, {Map<Type, dynamic>? modelDecoders}) =>
      disk().json<T>(path, modelDecoders: modelDecoders);

  /// `Disk.readStream` on the default disk.
  static Stream<List<int>> readStream(String path) => disk().readStream(path);

  /// `Disk.put` on the default disk.
  static Future<void> put(String path, Object contents) =>
      disk().put(path, contents);

  /// `Disk.putJson` on the default disk.
  static Future<void> putJson(String path, Object? value) =>
      disk().putJson(path, value);

  /// `Disk.putFile` on the default disk.
  static Future<String> putFile(String directory, Object file) =>
      disk().putFile(directory, file);

  /// `Disk.putFileAs` on the default disk.
  static Future<String> putFileAs(String directory, Object file, String name) =>
      disk().putFileAs(directory, file, name);

  /// `Disk.append` on the default disk.
  static Future<void> append(
    String path,
    String text, {
    String separator = '\n',
  }) => disk().append(path, text, separator: separator);

  /// `Disk.prepend` on the default disk.
  static Future<void> prepend(
    String path,
    String text, {
    String separator = '\n',
  }) => disk().prepend(path, text, separator: separator);

  /// `Disk.copy` on the default disk.
  static Future<void> copy(String from, String to) => disk().copy(from, to);

  /// `Disk.move` on the default disk.
  static Future<void> move(String from, String to) => disk().move(from, to);

  /// `Disk.copyToDisk` from the default disk.
  static Future<void> copyToDisk(String target, String path, [String? to]) =>
      disk().copyToDisk(target, path, to);

  /// `Disk.moveToDisk` from the default disk.
  static Future<void> moveToDisk(String target, String path, [String? to]) =>
      disk().moveToDisk(target, path, to);

  /// `Disk.delete` on the default disk.
  static Future<bool> delete(Object paths) => disk().delete(paths);

  /// `Disk.download` on the default disk.
  static Future<void> download(
    String url,
    String path, {
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
  }) => disk().download(
    url,
    path,
    onProgress: onProgress,
    cancelToken: cancelToken,
    headers: headers,
    queryParameters: queryParameters,
  );

  /// `Disk.size` on the default disk.
  static Future<int> size(String path) => disk().size(path);

  /// `Disk.lastModified` on the default disk.
  static Future<DateTime> lastModified(String path) =>
      disk().lastModified(path);

  /// `Disk.mimeType` on the default disk.
  static Future<String?> mimeType(String path) => disk().mimeType(path);

  /// `Disk.checksum` on the default disk.
  static Future<String> checksum(String path, {String algorithm = 'md5'}) =>
      disk().checksum(path, algorithm: algorithm);

  /// `Disk.path` on the default disk.
  static Future<String> path(String path) => disk().path(path);

  /// `Disk.url` on the default disk.
  static Future<Uri> url(String path) => disk().url(path);

  /// `Disk.list` on the default disk.
  static Future<List<DiskEntry>> list([
    String directory = '',
    bool recursive = false,
  ]) => disk().list(directory, recursive);

  /// `Disk.files` on the default disk.
  static Future<List<String>> files([String directory = '']) =>
      disk().files(directory);

  /// `Disk.allFiles` on the default disk.
  static Future<List<String>> allFiles([String directory = '']) =>
      disk().allFiles(directory);

  /// `Disk.directories` on the default disk.
  static Future<List<String>> directories([String directory = '']) =>
      disk().directories(directory);

  /// `Disk.allDirectories` on the default disk.
  static Future<List<String>> allDirectories([String directory = '']) =>
      disk().allDirectories(directory);

  /// `Disk.makeDirectory` on the default disk.
  static Future<void> makeDirectory(String path) => disk().makeDirectory(path);

  /// `Disk.deleteDirectory` on the default disk.
  static Future<bool> deleteDirectory(String path) =>
      disk().deleteDirectory(path);

  /// `Disk.scope` on the default disk.
  static Disk scope(String directory) => disk().scope(directory);

  /// `Disk.usage` on the default disk.
  static Future<int> usage() => disk().usage();

  /// `Disk.prune` on the default disk.
  static Future<int> prune({required Duration olderThan}) =>
      disk().prune(olderThan: olderThan);
}

/// The disk named [name], or the default disk:
/// `disk('documents').put('notes.txt', 'Hello')`.
Disk disk([String? name]) => FileStorage.disk(name);
