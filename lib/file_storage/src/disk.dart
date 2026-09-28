import 'dart:async';
import 'dart:convert';
import 'dart:io' show File, FileSystemException;
import 'dart:math';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:dio/dio.dart';
import 'package:mime/mime.dart' as mime;
import 'package:path/path.dart' as p;

import '/helpers/src/helper.dart' show dataToModel;
import '/helpers/src/ny_env.dart' show NyEnvRegistry;
import '/helpers/src/ny_logger.dart' show NyLogger;
import '/networking/src/ny_api_service.dart' show NyApiService;
import 'disk_driver.dart';
import 'disk_exceptions.dart';
import 'disk_image.dart';
import 'drivers/local_disk_driver.dart';
import 'file_storage.dart';
import 'path_normalizer.dart';

/// One named place to keep files: a folder on the device, the app bundle,
/// memory, or any [DiskDriver].
///
/// Get one with `disk('name')` or `FileStorage.disk('name')`. Paths are
/// relative to the disk and always use `/`; `..` can never climb above the
/// disk's root. Every failure throws a [DiskException] that names the disk
/// and the path.
///
/// ```dart
/// await disk('documents').put('reports/q3.pdf', pdfBytes);
/// final String avatar = await disk().putFile('avatars', photo);
/// final List<Order>? orders = await disk().json<List<Order>>('orders.json');
/// ```
class Disk {
  /// A disk named [name] over [driver], rooted at [prefix] inside it.
  Disk(
    this.name,
    this.driver, {
    String prefix = '',
    this.readOnly = false,
    bool protectRoot = false,
    Duration? prune,
  }) : prefix = normalizeDiskPath(prefix, disk: name),
       _home = normalizeDiskPath(prefix, disk: name),
       _protectRoot = protectRoot,
       _prune = prune;

  Disk._scope(Disk parent, this.prefix)
    : name = parent.name,
      driver = parent.driver,
      readOnly = parent.readOnly,
      _home = parent._home,
      _protectRoot = false,
      _prune = null;

  /// The disk's name, e.g. `local`.
  final String name;

  /// The backend that stores the bytes.
  final DiskDriver driver;

  /// The folder inside [driver] this disk treats as its root.
  final String prefix;

  /// Whether writes are refused.
  final bool readOnly;

  /// The named disk's own root, which [scope] keeps; image-cache keys are
  /// relative to it.
  final String _home;
  final bool _protectRoot;
  final Duration? _prune;
  bool _pruneStarted = false;

  static final Random _random = Random.secure();
  static const String _nameAlphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';

  /// A disk rooted at [directory] inside this one, e.g. one per user:
  /// `disk().scope('users/${user.id}')`.
  Disk scope(String directory) => Disk._scope(
    this,
    joinDiskPath(prefix, normalizeDiskPath(directory, disk: name)),
  );

  // ---------------------------------------------------------------------------
  // Reading
  // ---------------------------------------------------------------------------

  /// Whether a file exists at [path].
  Future<bool> exists(String path) =>
      _run(path, () => driver.fileExists(_resolve(path)));

  /// Whether no file exists at [path].
  Future<bool> missing(String path) async => !await exists(path);

  /// Whether a folder exists at [path].
  Future<bool> directoryExists(String path) =>
      _run(path, () => driver.directoryExists(_resolve(path)));

  /// The file at [path] as UTF-8 text.
  Future<String> get(String path) async {
    final Uint8List data = await bytes(path);
    try {
      return utf8.decode(data);
    } on FormatException catch (error) {
      throw DiskException(
        'The file is not UTF-8 text',
        disk: name,
        path: path,
        cause: error,
      );
    }
  }

  /// The file at [path] as bytes.
  Future<Uint8List> bytes(String path) =>
      _run(path, () => driver.read(_resolve(path)));

  /// The file at [path], decoded from JSON.
  ///
  /// For a model type, the JSON goes through [modelDecoders], or your app's
  /// model decoders when null, the same as `NyStorage.read<T>()`:
  /// `await disk().json<List<Order>>('orders.json')`.
  Future<T?> json<T>(String path, {Map<Type, dynamic>? modelDecoders}) async {
    final String text = await get(path);
    final dynamic data;
    try {
      data = jsonDecode(text);
    } on FormatException catch (error) {
      throw DiskException(
        'The file is not valid JSON',
        disk: name,
        path: path,
        cause: error,
      );
    }
    if (data == null) return null;
    if (T == dynamic || data is T) return data as T;
    return dataToModel<T>(data: data, modelDecoders: modelDecoders);
  }

  /// The file at [path], in chunks, without loading it all into memory.
  Stream<List<int>> readStream(String path) async* {
    _startPrune();
    try {
      yield* driver.readStream(_resolve(path));
    } on DiskException catch (error) {
      throw error.relocate(name, path);
    } on FileSystemException catch (error) {
      throw _fileSystemError(path, error);
    }
  }

  // ---------------------------------------------------------------------------
  // Writing
  // ---------------------------------------------------------------------------

  /// Writes [contents] to [path]: a `String` (as UTF-8), a `List<int>` of
  /// bytes, or a `Stream<List<int>>`. Replaces any file there.
  Future<void> put(String path, Object contents) => _run(path, () async {
    _guardWrite('put');
    final String target = _resolve(path);
    if (contents is String) {
      await driver.write(target, utf8.encode(contents));
    } else if (contents is List<int>) {
      await driver.write(target, contents);
    } else if (contents is Stream<List<int>>) {
      await driver.writeStream(target, contents);
    } else {
      throw ArgumentError.value(
        contents,
        'contents',
        'Expected a String, a List<int> of bytes, or a Stream<List<int>>',
      );
    }
    _written(target);
  });

  /// Writes [value] as JSON. Models are encoded through their `toJson()`.
  Future<void> putJson(String path, Object? value) =>
      put(path, jsonEncode(value));

  /// Stores [file] in [directory] under a random 40-character name, with
  /// the extension its contents show it to have, and returns the path.
  ///
  /// [file] is an `XFile` (from image_picker, file_picker or camera), a
  /// `File`, a file path, or bytes. The file is streamed, not loaded into
  /// memory.
  ///
  /// ```dart
  /// final String path = await disk().putFile('avatars', photo);
  /// // avatars/k3v0q…9q.jpg
  /// ```
  Future<String> putFile(String directory, Object file) async {
    final _FileSource source = _FileSource.of(file);
    final List<int> header = await _run(directory, () => source.header(32));
    final String generated = _randomName(40);
    final String? extension = source.extension(header);
    return putFileAs(
      directory,
      file,
      extension == null ? generated : '$generated.$extension',
    );
  }

  /// Stores [file] in [directory] as [name], and returns the path.
  Future<String> putFileAs(String directory, Object file, String name) async {
    final String fileName = normalizeDiskPath(name, disk: this.name);
    if (fileName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'A file name is required');
    }
    final String path = joinDiskPath(
      normalizeDiskPath(directory, disk: this.name),
      fileName,
    );
    await put(path, _FileSource.of(file).open());
    return path;
  }

  /// Adds [text] to the end of the file at [path], after [separator] when
  /// the file already has content. Creates the file if needed.
  Future<void> append(String path, String text, {String separator = '\n'}) =>
      _run(path, () async {
        _guardWrite('append');
        final String target = _resolve(path);
        final DiskEntry? entry = await driver.stat(target);
        final bool hasContent =
            entry != null && entry.isFile && (entry.size ?? 0) > 0;
        await driver.write(
          target,
          utf8.encode(hasContent ? '$separator$text' : text),
          append: true,
        );
        _written(target);
      });

  /// Adds [text] to the start of the file at [path], before [separator]
  /// when the file already has content. Creates the file if needed.
  Future<void> prepend(String path, String text, {String separator = '\n'}) =>
      _run(path, () async {
        _guardWrite('prepend');
        final String target = _resolve(path);
        final String existing = await driver.fileExists(target)
            ? utf8.decode(await driver.read(target))
            : '';
        await driver.write(
          target,
          utf8.encode(existing.isEmpty ? text : '$text$separator$existing'),
        );
        _written(target);
      });

  /// Copies the file at [from] to [to].
  Future<void> copy(String from, String to) => _run(from, () async {
    _guardWrite('copy');
    final String target = _resolve(to);
    await driver.copy(_resolve(from), target);
    _written(target);
  });

  /// Moves the file at [from] to [to].
  Future<void> move(String from, String to) => _run(from, () async {
    _guardWrite('move');
    final String source = _resolve(from);
    final String target = _resolve(to);
    await driver.move(source, target);
    _written(source);
    _written(target);
  });

  /// Copies the file at [path] to the same path on [disk], or to [to].
  Future<void> copyToDisk(String disk, String path, [String? to]) async {
    // Checked first, so a missing file is reported against this disk rather
    // than surfacing mid-stream as the target's error.
    if (await missing(path)) throw DiskFileNotFoundException(path, disk: name);
    await FileStorage.disk(disk).put(to ?? path, readStream(path));
  }

  /// Moves the file at [path] to the same path on [disk], or to [to].
  Future<void> moveToDisk(String disk, String path, [String? to]) async {
    await copyToDisk(disk, path, to);
    await delete(path);
  }

  /// Deletes one path, or every path in an `Iterable<String>`.
  ///
  /// Returns true when every file existed.
  Future<bool> delete(Object paths) async {
    final Iterable<String> all = switch (paths) {
      String path => [path],
      Iterable<Object?> many => many.cast<String>(),
      _ => throw ArgumentError.value(
        paths,
        'paths',
        'Expected a path or an Iterable of paths',
      ),
    };
    bool deletedAll = true;
    for (final String path in all) {
      final bool deleted = await _run(path, () async {
        _guardWrite('delete');
        final String target = _resolve(path);
        final bool existed = await driver.delete(target);
        _written(target);
        return existed;
      });
      deletedAll = deleted && deletedAll;
    }
    return deletedAll;
  }

  /// Downloads [url] into [path], replacing any file there only once the
  /// download has finished.
  ///
  /// Uses Nylo's `NyApiService`, so your interceptors apply. [onProgress]
  /// receives bytes received and the total, or -1 when the server doesn't
  /// say.
  Future<void> download(
    String url,
    String path, {
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
  }) => _run(path, () async {
    _guardWrite('download');
    final String target = _resolve(path);
    final NyApiService api = NyApiService(
      useNetworkLogger: NyEnvRegistry.isInitialized ? null : false,
    );
    final Options options = Options(headers: {'Accept': '*/*', ...?headers});
    final String? absolute = await driver.absolutePath(target);

    if (absolute == null) {
      final Response<List<int>> response = await api.dio.get<List<int>>(
        url,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onReceiveProgress: onProgress,
        options: options.copyWith(responseType: ResponseType.bytes),
      );
      await driver.write(target, response.data ?? const <int>[]);
      _written(target);
      return;
    }

    // Download next to the target under a hidden temp name, then rename it
    // into place, so a half-finished download never looks complete.
    final String folder = parentDiskPath(target);
    final String temp = joinDiskPath(
      folder,
      '.${target.substring(folder.isEmpty ? 0 : folder.length + 1)}'
      '${LocalDiskDriver.tempMarker}download-${_randomName(8)}',
    );
    await driver.createDirectory(folder);
    try {
      await api.download(
        url,
        savePath: (await driver.absolutePath(temp))!,
        onProgress: onProgress,
        cancelToken: cancelToken,
        queryParameters: queryParameters,
        options: options,
      );
      await driver.move(temp, target);
    } catch (_) {
      try {
        await driver.delete(temp);
      } catch (_) {}
      rethrow;
    }
    _written(target);
  });

  // ---------------------------------------------------------------------------
  // Metadata
  // ---------------------------------------------------------------------------

  /// The size of the file at [path], in bytes.
  Future<int> size(String path) => _run(path, () async {
    final DiskEntry entry = await _file(path);
    return entry.size ?? (await driver.read(_resolve(path))).length;
  });

  /// When the file at [path] last changed.
  Future<DateTime> lastModified(String path) => _run(path, () async {
    final DateTime? modified = (await _file(path)).lastModified;
    if (modified == null) {
      throw DiskException(
        'This disk does not record when files change',
        path: path,
      );
    }
    return modified;
  });

  /// The MIME type of the file at [path], from its first bytes and its
  /// extension, e.g. `image/png`. Null when neither says.
  Future<String?> mimeType(String path) => _run(path, () async {
    final List<int> header = await _header(_resolve(path), 32);
    return mime.lookupMimeType(path, headerBytes: header);
  });

  /// A hash of the file at [path], as lowercase hex. [algorithm] is `md5`
  /// (the default, as in Laravel), `sha1`, `sha224`, `sha256`, `sha384` or
  /// `sha512`.
  Future<String> checksum(String path, {String algorithm = 'md5'}) =>
      _run(path, () async {
        final crypto.Hash hash = switch (algorithm) {
          'md5' => crypto.md5,
          'sha1' => crypto.sha1,
          'sha224' => crypto.sha224,
          'sha256' => crypto.sha256,
          'sha384' => crypto.sha384,
          'sha512' => crypto.sha512,
          _ => throw ArgumentError.value(
            algorithm,
            'algorithm',
            'Use md5, sha1, sha224, sha256, sha384 or sha512',
          ),
        };
        final crypto.Digest digest = await hash
            .bind(driver.readStream(_resolve(path)))
            .first;
        return digest.toString();
      });

  /// The absolute path of [path] on the device, for plugins that need a
  /// real file. Throws for disks with no files on the device, such as
  /// memory disks and the app bundle.
  Future<String> path(String path) => _run(path, () async {
    final String? absolute = await driver.absolutePath(_resolve(path));
    if (absolute == null) {
      throw DiskException('This disk has no files on the device', path: path);
    }
    return absolute;
  });

  /// A `file://` URL for [path], for web views and video players.
  Future<Uri> url(String path) async => Uri.file(await this.path(path));

  // ---------------------------------------------------------------------------
  // Folders
  // ---------------------------------------------------------------------------

  /// The files and folders in [directory], with their size and date, or in
  /// all its sub-folders when [recursive]. Sorted by path.
  Future<List<DiskEntry>> list([
    String directory = '',
    bool recursive = false,
  ]) => _run(directory, () async {
    final List<DiskEntry> entries = await driver
        .list(_resolve(directory), recursive: recursive)
        .map(
          (entry) => DiskEntry(
            path: stripDiskPrefix(prefix, entry.path),
            type: entry.type,
            size: entry.size,
            lastModified: entry.lastModified,
          ),
        )
        .toList();
    entries.sort((a, b) => a.path.compareTo(b.path));
    return entries;
  });

  /// The paths of the files in [directory].
  Future<List<String>> files([String directory = '']) async => [
    for (final DiskEntry entry in await list(directory))
      if (entry.isFile) entry.path,
  ];

  /// The paths of the files in [directory] and all its sub-folders.
  Future<List<String>> allFiles([String directory = '']) async => [
    for (final DiskEntry entry in await list(directory, true))
      if (entry.isFile) entry.path,
  ];

  /// The paths of the folders in [directory].
  Future<List<String>> directories([String directory = '']) async => [
    for (final DiskEntry entry in await list(directory))
      if (entry.isDirectory) entry.path,
  ];

  /// The paths of the folders in [directory] and all its sub-folders.
  Future<List<String>> allDirectories([String directory = '']) async => [
    for (final DiskEntry entry in await list(directory, true))
      if (entry.isDirectory) entry.path,
  ];

  /// Creates the folder at [path] and any missing parents.
  Future<void> makeDirectory(String path) => _run(path, () async {
    _guardWrite('makeDirectory');
    await driver.createDirectory(_resolve(path));
  });

  /// Deletes the folder at [path] and everything in it. Returns false when
  /// there was no folder.
  ///
  /// Emptying a whole disk that has no prefix inside a shared OS folder,
  /// such as `documents`, is refused: other plugins keep files there.
  Future<bool> deleteDirectory(String path) => _run(path, () async {
    _guardWrite('deleteDirectory');
    final String target = _resolve(path);
    if (target.isEmpty && _protectRoot) {
      throw DiskException(
        'Refusing to empty this disk: it is a folder other plugins also '
        'write to. Delete the paths you own instead',
        path: path,
      );
    }
    final bool deleted = await driver.deleteDirectory(target);
    DiskImage.evictDirectory(name, stripDiskPrefix(_home, target));
    return deleted;
  });

  // ---------------------------------------------------------------------------
  // Upkeep
  // ---------------------------------------------------------------------------

  /// The total size of the files on this disk, in bytes.
  Future<int> usage() async {
    int total = 0;
    for (final DiskEntry entry in await list('', true)) {
      if (entry.isFile) total += entry.size ?? 0;
    }
    return total;
  }

  /// Deletes the files last changed longer ago than [olderThan], and
  /// returns how many were deleted.
  Future<int> prune({required Duration olderThan}) => _run('', () async {
    _guardWrite('prune');
    final DateTime cutoff = DateTime.now().subtract(olderThan);
    int removed = 0;
    for (final DiskEntry entry in await list('', true)) {
      final DateTime? modified = entry.lastModified;
      if (!entry.isFile || modified == null || !modified.isBefore(cutoff)) {
        continue;
      }
      final String target = _resolve(entry.path);
      if (await driver.delete(target)) removed++;
      _written(target);
    }
    return removed;
  });

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  String _resolve(String path) =>
      joinDiskPath(prefix, normalizeDiskPath(path, disk: name));

  void _guardWrite(String operation) {
    if (readOnly) throw DiskReadOnlyException(operation);
  }

  void _written(String target) =>
      DiskImage.evictFile(name, stripDiskPrefix(_home, target));

  Future<DiskEntry> _file(String path) async {
    final DiskEntry? entry = await driver.stat(_resolve(path));
    if (entry == null || !entry.isFile) throw DiskFileNotFoundException(path);
    return entry;
  }

  Future<List<int>> _header(String target, int length) async {
    final List<int> header = [];
    await for (final List<int> chunk in driver.readStream(target)) {
      header.addAll(chunk.take(length - header.length));
      if (header.length >= length) break;
    }
    return header;
  }

  /// Runs [body], reporting any failure against this disk and [path].
  Future<T> _run<T>(String path, Future<T> Function() body) async {
    _startPrune();
    try {
      return await body();
    } on DiskException catch (error) {
      throw error.relocate(name, path);
    } on FileSystemException catch (error) {
      throw _fileSystemError(path, error);
    } on DioException catch (error) {
      throw DiskException(
        'Download failed: ${error.message ?? error.type.name}',
        disk: name,
        path: path,
        cause: error,
      );
    }
  }

  DiskException _fileSystemError(String path, FileSystemException error) =>
      DiskException(
        error.osError?.message ?? error.message,
        disk: name,
        path: path,
        cause: error,
      );

  /// Starts this disk's configured prune the first time it is used.
  void _startPrune() {
    final Duration? olderThan = _prune;
    if (olderThan == null || _pruneStarted || readOnly) return;
    _pruneStarted = true;
    prune(olderThan: olderThan).then<void>(
      (_) {},
      onError: (Object error) {
        if (NyEnvRegistry.isInitialized) {
          NyLogger.debug('Pruning disk [$name] failed: $error');
        }
      },
    );
  }

  static String _randomName(int length) => String.fromCharCodes(
    List<int>.generate(
      length,
      (_) => _nameAlphabet.codeUnitAt(_random.nextInt(_nameAlphabet.length)),
    ),
  );
}

/// What `putFile` accepts, read the same way whatever it is.
class _FileSource {
  _FileSource({required this.name, required this.mimeType, required this.open});

  factory _FileSource.of(Object file) {
    if (file is XFile) {
      return _FileSource(
        name: file.name.isEmpty ? null : file.name,
        mimeType: file.mimeType,
        open: ([int? start, int? end]) => file.openRead(start, end),
      );
    }
    if (file is File) {
      return _FileSource(
        name: p.basename(file.path),
        mimeType: null,
        open: ([int? start, int? end]) => file.openRead(start, end),
      );
    }
    if (file is String) return _FileSource.of(File(file));
    if (file is List<int>) {
      return _FileSource(
        name: null,
        mimeType: null,
        open: ([int? start, int? end]) => Stream<List<int>>.value(
          file.sublist(
            min(start ?? 0, file.length),
            min(end ?? file.length, file.length),
          ),
        ),
      );
    }
    throw ArgumentError.value(
      file,
      'file',
      'Expected an XFile, a File, a file path, or a List<int> of bytes',
    );
  }

  final String? name;
  final String? mimeType;
  final Stream<List<int>> Function([int? start, int? end]) open;

  /// The first [length] bytes.
  Future<List<int>> header(int length) async {
    final List<int> header = [];
    await for (final List<int> chunk in open(0, length)) {
      header.addAll(chunk.take(length - header.length));
      if (header.length >= length) break;
    }
    return header;
  }

  /// The extension the contents point to, then the one in the name.
  String? extension(List<int> header) {
    final String? type =
        mime.lookupMimeType(name ?? '', headerBytes: header) ?? mimeType;
    final String? fromType = type == null ? null : mime.extensionFromMime(type);
    if (fromType != null && fromType.isNotEmpty) return fromType;
    final String? fileName = name;
    if (fileName == null) return null;
    final String fromName = p.extension(fileName).replaceFirst('.', '');
    return fromName.isEmpty ? null : fromName.toLowerCase();
  }
}
