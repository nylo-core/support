import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../disk_driver.dart';
import '../disk_exceptions.dart';

/// Files in a folder on the device.
///
/// The root folder is resolved the first time the driver is used, then
/// cached, so building a disk costs nothing. Writes go to a hidden temp file
/// that is then renamed over the target, so a file is never seen half
/// written. Listings skip those temp files and never follow symlinks.
class LocalDiskDriver implements DiskDriver {
  /// A driver whose root folder comes from [root], e.g. a path_provider call.
  LocalDiskDriver(Future<String> Function() root) : _resolveRoot = root;

  /// A driver rooted at the absolute path [root].
  LocalDiskDriver.at(String root) : _resolveRoot = (() async => root);

  final Future<String> Function() _resolveRoot;
  Future<String>? _root;

  static final Random _random = Random();

  /// Marks the hidden temp files written during an atomic replace.
  static const String tempMarker = '.nytmp-';

  /// The absolute root folder. Resolved once; a failed attempt is retried
  /// on the next call.
  Future<String> get root {
    final Future<String>? cached = _root;
    if (cached != null) return cached;
    final Future<String> resolving = _resolveRoot();
    _root = resolving;
    resolving.then<void>(
      (_) {},
      onError: (Object _) {
        if (identical(_root, resolving)) _root = null;
      },
    );
    return resolving;
  }

  Future<String> _full(String path) async {
    final String base = await root;
    return path.isEmpty ? base : p.join(base, path);
  }

  String _tempFor(String full) => p.join(
    p.dirname(full),
    '.${p.basename(full)}$tempMarker'
    '${DateTime.now().microsecondsSinceEpoch}${_random.nextInt(1 << 32)}',
  );

  Future<void> _ensureParent(String full) =>
      Directory(p.dirname(full)).create(recursive: true);

  @override
  Future<bool> fileExists(String path) async =>
      File(await _full(path)).exists();

  @override
  Future<bool> directoryExists(String path) async =>
      Directory(await _full(path)).exists();

  @override
  Future<Uint8List> read(String path) async {
    final File file = File(await _full(path));
    if (!await file.exists()) throw DiskFileNotFoundException(path);
    return file.readAsBytes();
  }

  @override
  Stream<List<int>> readStream(String path) async* {
    final File file = File(await _full(path));
    if (!await file.exists()) throw DiskFileNotFoundException(path);
    yield* file.openRead();
  }

  @override
  Future<void> write(
    String path,
    List<int> bytes, {
    bool append = false,
  }) async {
    final String full = await _full(path);
    await _ensureParent(full);
    if (append) {
      await File(full).writeAsBytes(bytes, mode: FileMode.append, flush: true);
      return;
    }
    final File temp = File(_tempFor(full));
    try {
      await temp.writeAsBytes(bytes, flush: true);
      await temp.rename(full);
    } catch (_) {
      await _deleteQuietly(temp);
      rethrow;
    }
  }

  @override
  Future<void> writeStream(String path, Stream<List<int>> stream) async {
    final String full = await _full(path);
    await _ensureParent(full);
    final File temp = File(_tempFor(full));
    final IOSink sink = temp.openWrite();
    try {
      await sink.addStream(stream);
      await sink.flush();
      await sink.close();
      await temp.rename(full);
    } catch (_) {
      try {
        await sink.close();
      } catch (_) {}
      await _deleteQuietly(temp);
      rethrow;
    }
  }

  @override
  Future<bool> delete(String path) async {
    final File file = File(await _full(path));
    if (!await file.exists()) return false;
    await file.delete();
    return true;
  }

  @override
  Future<void> createDirectory(String path) async {
    await Directory(await _full(path)).create(recursive: true);
  }

  @override
  Future<bool> deleteDirectory(String path) async {
    final Directory directory = Directory(await _full(path));
    if (!await directory.exists()) return false;
    if (path.isEmpty) {
      await for (final FileSystemEntity entity in directory.list(
        followLinks: false,
      )) {
        await entity.delete(recursive: true);
      }
      return true;
    }
    await directory.delete(recursive: true);
    return true;
  }

  @override
  Future<DiskEntry?> stat(String path) async {
    final FileStat stat = await FileStat.stat(await _full(path));
    switch (stat.type) {
      case FileSystemEntityType.file:
        return DiskEntry(
          path: path,
          type: DiskEntryType.file,
          size: stat.size,
          lastModified: stat.modified,
        );
      case FileSystemEntityType.directory:
        return DiskEntry(
          path: path,
          type: DiskEntryType.directory,
          lastModified: stat.modified,
        );
      default:
        return null;
    }
  }

  @override
  Stream<DiskEntry> list(String directory, {bool recursive = false}) async* {
    final String base = await root;
    final Directory folder = Directory(await _full(directory));
    if (!await folder.exists()) return;
    await for (final FileSystemEntity entity in folder.list(
      recursive: recursive,
      followLinks: false,
    )) {
      if (p.basename(entity.path).contains(tempMarker)) continue;
      final String relative = p
          .split(p.relative(entity.path, from: base))
          .join('/');
      if (entity is File) {
        final FileStat stat = await entity.stat();
        yield DiskEntry(
          path: relative,
          type: DiskEntryType.file,
          size: stat.size,
          lastModified: stat.modified,
        );
      } else if (entity is Directory) {
        yield DiskEntry(path: relative, type: DiskEntryType.directory);
      }
    }
  }

  @override
  Future<void> copy(String from, String to) async {
    final File source = File(await _full(from));
    if (!await source.exists()) throw DiskFileNotFoundException(from);
    final String full = await _full(to);
    await _ensureParent(full);
    final File temp = File(_tempFor(full));
    try {
      await source.copy(temp.path);
      await temp.rename(full);
    } catch (_) {
      await _deleteQuietly(temp);
      rethrow;
    }
  }

  @override
  Future<void> move(String from, String to) async {
    final File source = File(await _full(from));
    if (!await source.exists()) throw DiskFileNotFoundException(from);
    final String full = await _full(to);
    await _ensureParent(full);
    try {
      await source.rename(full);
    } on FileSystemException {
      // A rename can't cross volumes; copy, then remove the original.
      await copy(from, to);
      await source.delete();
    }
  }

  @override
  Future<String?> absolutePath(String path) => _full(path);

  static Future<void> _deleteQuietly(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }
}
