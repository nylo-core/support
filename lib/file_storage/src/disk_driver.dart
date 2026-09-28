import 'dart:typed_data';

/// Whether a [DiskEntry] is a file or a folder.
enum DiskEntryType { file, directory }

/// A file or folder found by `Disk.list()`.
class DiskEntry {
  /// Creates a new [DiskEntry].
  const DiskEntry({
    required this.path,
    required this.type,
    this.size,
    this.lastModified,
  });

  /// The path on the disk: `/`-separated, with no leading slash.
  final String path;

  /// Whether this is a file or a folder.
  final DiskEntryType type;

  /// The size in bytes, for files.
  final int? size;

  /// When the entry last changed, if the driver knows.
  final DateTime? lastModified;

  /// Whether this entry is a file.
  bool get isFile => type == DiskEntryType.file;

  /// Whether this entry is a folder.
  bool get isDirectory => type == DiskEntryType.directory;

  /// The last segment of [path], e.g. `photo.jpg`.
  String get name => path.substring(path.lastIndexOf('/') + 1);

  @override
  String toString() =>
      'DiskEntry($path, ${type.name}${size == null ? '' : ', $size bytes'})';
}

/// The primitive operations a storage backend implements.
///
/// Every path a driver receives has already been checked and normalized by
/// `Disk`: `/`-separated, relative to the driver's root, with no `.` or `..`
/// segments and no leading or trailing slash. The root itself is `''`. A
/// driver only moves bytes; path rules, read-only disks, prefixes, JSON,
/// MIME types and checksums all live in `Disk`.
///
/// To check a new driver, run it through `testDiskDriver()` from Nylo's
/// testing library.
abstract class DiskDriver {
  /// Whether a file exists at [path].
  Future<bool> fileExists(String path);

  /// Whether a folder exists at [path]. The root always exists.
  Future<bool> directoryExists(String path);

  /// The contents of the file at [path].
  ///
  /// Throws `DiskFileNotFoundException` when there is no file.
  Future<Uint8List> read(String path);

  /// The contents of the file at [path], in chunks.
  ///
  /// The stream fails with `DiskFileNotFoundException` when there is no file.
  Stream<List<int>> readStream(String path);

  /// Writes [bytes] to [path], creating parent folders.
  ///
  /// Replaces an existing file atomically: a reader sees the old contents
  /// or the new ones, never a mix. With [append], adds to the end instead.
  Future<void> write(String path, List<int> bytes, {bool append = false});

  /// Writes a byte [stream] to [path], replacing any file atomically.
  Future<void> writeStream(String path, Stream<List<int>> stream);

  /// Deletes the file at [path]. Returns false when there was none.
  Future<bool> delete(String path);

  /// Creates the folder at [path] and any missing parents.
  Future<void> createDirectory(String path);

  /// Deletes the folder at [path] and everything in it. For the root
  /// (`''`), empties it instead. Returns false when there was no folder.
  Future<bool> deleteDirectory(String path);

  /// What is at [path], or null when nothing is.
  Future<DiskEntry?> stat(String path);

  /// The files and folders in [directory], or in all its sub-folders when
  /// [recursive]. Entry paths are relative to the driver's root.
  Stream<DiskEntry> list(String directory, {bool recursive = false});

  /// Copies the file at [from] to [to], replacing any file there.
  Future<void> copy(String from, String to);

  /// Moves the file at [from] to [to], replacing any file there.
  Future<void> move(String from, String to);

  /// The absolute device path for [path], or null when the driver has no
  /// files on the device (memory, the app bundle, remote storage).
  Future<String?> absolutePath(String path);
}
