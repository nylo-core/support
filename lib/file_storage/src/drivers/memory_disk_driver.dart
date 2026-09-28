import 'dart:collection';
import 'dart:typed_data';

import '../disk_driver.dart';
import '../disk_exceptions.dart';
import '../path_normalizer.dart';

class _MemoryFile {
  _MemoryFile(this.bytes) : modified = DateTime.now();

  Uint8List bytes;
  DateTime modified;
}

/// A disk that lives in memory: the driver behind `FileStorage.fake()`, and
/// what local disks use on the web.
///
/// Nothing touches the device, so it also works inside `testWidgets`,
/// where real file I/O never completes. Folders exist when something is in
/// them, or when [createDirectory] made them.
class MemoryDiskDriver implements DiskDriver {
  final SplayTreeMap<String, _MemoryFile> _files = SplayTreeMap();
  final SplayTreeSet<String> _directories = SplayTreeSet();

  /// Whether a file exists at [path], answered synchronously.
  bool fileExistsSync(String path) => _files.containsKey(path);

  /// Whether a folder exists at [path], answered synchronously.
  bool directoryExistsSync(String path) {
    if (path.isEmpty || _directories.contains(path)) return true;
    final String inside = '$path/';
    return _files.keys.any((key) => key.startsWith(inside)) ||
        _directories.any((dir) => dir.startsWith(inside));
  }

  /// The files in [directory], or in all its sub-folders when [recursive].
  List<String> filesSync(String directory, {bool recursive = false}) => [
    for (final String key in _files.keys)
      if (recursive
          ? isWithinDiskPath(directory, key) && key != directory
          : parentDiskPath(key) == directory)
        key,
  ];

  /// The contents of the file at [path], or null.
  Uint8List? readSync(String path) => _files[path]?.bytes;

  Set<String> _allDirectories() {
    final Set<String> all = SplayTreeSet.of(_directories);
    for (final String path in [..._files.keys, ..._directories]) {
      String parent = parentDiskPath(path);
      while (parent.isNotEmpty) {
        all.add(parent);
        parent = parentDiskPath(parent);
      }
    }
    return all;
  }

  @override
  Future<bool> fileExists(String path) async => fileExistsSync(path);

  @override
  Future<bool> directoryExists(String path) async => directoryExistsSync(path);

  @override
  Future<Uint8List> read(String path) async {
    final _MemoryFile? file = _files[path];
    if (file == null) throw DiskFileNotFoundException(path);
    return Uint8List.fromList(file.bytes);
  }

  @override
  Stream<List<int>> readStream(String path) async* {
    yield await read(path);
  }

  @override
  Future<void> write(
    String path,
    List<int> bytes, {
    bool append = false,
  }) async {
    final _MemoryFile? existing = _files[path];
    if (append && existing != null) {
      existing.bytes = Uint8List.fromList([...existing.bytes, ...bytes]);
      existing.modified = DateTime.now();
      return;
    }
    _files[path] = _MemoryFile(Uint8List.fromList(bytes));
  }

  @override
  Future<void> writeStream(String path, Stream<List<int>> stream) async {
    final BytesBuilder builder = BytesBuilder(copy: false);
    await for (final List<int> chunk in stream) {
      builder.add(chunk);
    }
    await write(path, builder.takeBytes());
  }

  @override
  Future<bool> delete(String path) async => _files.remove(path) != null;

  @override
  Future<void> createDirectory(String path) async {
    if (path.isNotEmpty) _directories.add(path);
  }

  @override
  Future<bool> deleteDirectory(String path) async {
    if (!directoryExistsSync(path)) return false;
    _files.removeWhere((key, _) => isWithinDiskPath(path, key));
    _directories.removeWhere((dir) => isWithinDiskPath(path, dir));
    return true;
  }

  @override
  Future<DiskEntry?> stat(String path) async {
    final _MemoryFile? file = _files[path];
    if (file != null) {
      return DiskEntry(
        path: path,
        type: DiskEntryType.file,
        size: file.bytes.length,
        lastModified: file.modified,
      );
    }
    if (path.isNotEmpty && directoryExistsSync(path)) {
      return DiskEntry(path: path, type: DiskEntryType.directory);
    }
    return null;
  }

  @override
  Stream<DiskEntry> list(String directory, {bool recursive = false}) async* {
    for (final String dir in _allDirectories()) {
      if (dir == directory) continue;
      if (recursive
          ? isWithinDiskPath(directory, dir)
          : parentDiskPath(dir) == directory) {
        yield DiskEntry(path: dir, type: DiskEntryType.directory);
      }
    }
    for (final String key in filesSync(directory, recursive: recursive)) {
      final _MemoryFile file = _files[key]!;
      yield DiskEntry(
        path: key,
        type: DiskEntryType.file,
        size: file.bytes.length,
        lastModified: file.modified,
      );
    }
  }

  @override
  Future<void> copy(String from, String to) async {
    final _MemoryFile? file = _files[from];
    if (file == null) throw DiskFileNotFoundException(from);
    _files[to] = _MemoryFile(Uint8List.fromList(file.bytes));
  }

  @override
  Future<void> move(String from, String to) async {
    final _MemoryFile? file = _files.remove(from);
    if (file == null) throw DiskFileNotFoundException(from);
    _files[to] = file..modified = DateTime.now();
  }

  @override
  Future<String?> absolutePath(String path) async => null;
}
