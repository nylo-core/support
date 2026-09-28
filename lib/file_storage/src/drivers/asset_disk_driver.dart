import 'package:flutter/services.dart';

import '../disk_driver.dart';
import '../disk_exceptions.dart';
import '../path_normalizer.dart';

/// The app bundle, read-only.
///
/// Files are listed through [AssetManifest], so only assets declared in
/// `pubspec.yaml` appear. Paths are asset keys, e.g. `assets/images/logo.png`;
/// the `assets` disk adds the `assets/` prefix for you.
class AssetDiskDriver implements DiskDriver {
  /// A driver over [bundle], or [rootBundle] when null.
  AssetDiskDriver({AssetBundle? bundle}) : _bundle = bundle;

  final AssetBundle? _bundle;
  Future<List<String>>? _assets;

  /// The bundle files are read from.
  AssetBundle get bundle => _bundle ?? rootBundle;

  Future<List<String>> _all() {
    final Future<List<String>>? cached = _assets;
    if (cached != null) return cached;
    final Future<List<String>> loading = () async {
      final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(
        bundle,
      );
      return manifest.listAssets().toList()..sort();
    }();
    _assets = loading;
    loading.then<void>(
      (_) {},
      onError: (Object _) {
        if (identical(_assets, loading)) _assets = null;
      },
    );
    return loading;
  }

  Never _readOnly(String operation) => throw DiskReadOnlyException(operation);

  @override
  Future<bool> fileExists(String path) async => (await _all()).contains(path);

  @override
  Future<bool> directoryExists(String path) async =>
      path.isEmpty || (await _all()).any((asset) => asset.startsWith('$path/'));

  @override
  Future<Uint8List> read(String path) async {
    if (!await fileExists(path)) throw DiskFileNotFoundException(path);
    final ByteData data = await bundle.load(path);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  @override
  Stream<List<int>> readStream(String path) async* {
    yield await read(path);
  }

  @override
  Future<DiskEntry?> stat(String path) async {
    if (await fileExists(path)) {
      return DiskEntry(
        path: path,
        type: DiskEntryType.file,
        size: (await read(path)).length,
      );
    }
    if (path.isNotEmpty && await directoryExists(path)) {
      return DiskEntry(path: path, type: DiskEntryType.directory);
    }
    return null;
  }

  @override
  Stream<DiskEntry> list(String directory, {bool recursive = false}) async* {
    final List<String> assets = await _all();
    bool within(String path) => recursive
        ? isWithinDiskPath(directory, path) && path != directory
        : parentDiskPath(path) == directory;

    final Set<String> directories = {};
    for (final String asset in assets) {
      String parent = parentDiskPath(asset);
      while (parent.isNotEmpty) {
        directories.add(parent);
        parent = parentDiskPath(parent);
      }
    }
    for (final String dir in directories.toList()..sort()) {
      if (within(dir))
        yield DiskEntry(path: dir, type: DiskEntryType.directory);
    }
    for (final String asset in assets) {
      if (within(asset)) yield DiskEntry(path: asset, type: DiskEntryType.file);
    }
  }

  @override
  Future<String?> absolutePath(String path) async => null;

  @override
  Future<void> write(String path, List<int> bytes, {bool append = false}) =>
      _readOnly('write');

  @override
  Future<void> writeStream(String path, Stream<List<int>> stream) =>
      _readOnly('writeStream');

  @override
  Future<bool> delete(String path) => _readOnly('delete');

  @override
  Future<void> createDirectory(String path) => _readOnly('createDirectory');

  @override
  Future<bool> deleteDirectory(String path) => _readOnly('deleteDirectory');

  @override
  Future<void> copy(String from, String to) => _readOnly('copy');

  @override
  Future<void> move(String from, String to) => _readOnly('move');
}
