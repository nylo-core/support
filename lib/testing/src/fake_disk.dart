import 'dart:io' show ZLibCodec;
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mime/mime.dart' show lookupMimeType;

import '/file_storage/src/disk.dart';
import '/file_storage/src/drivers/memory_disk_driver.dart';
import '/file_storage/src/path_normalizer.dart';

/// An in-memory disk with Laravel's `Storage::fake()` assertions.
///
/// Get one from `FileStorage.fake('photos')`; `NyTest.init()` also swaps
/// every writable disk for one. The assertions are synchronous, so they
/// need no `await`.
///
/// ```dart
/// final FakeDisk photos = FileStorage.fake('photos');
/// await ProfileController().saveAvatar(FakeFile.image('me.png'));
/// photos.assertCount('avatars', 1);
/// ```
class FakeDisk extends Disk {
  /// An empty fake named [name].
  FakeDisk(String name) : this._(name, MemoryDiskDriver());

  FakeDisk._(String name, this.memory) : super(name, memory);

  /// The memory this disk writes to.
  final MemoryDiskDriver memory;

  Iterable<String> _paths(Object paths) => switch (paths) {
    String path => [path],
    Iterable<Object?> many => many.cast<String>(),
    _ => throw ArgumentError.value(paths, 'paths', 'Expected a path or paths'),
  };

  /// Asserts a file or folder exists at each of [paths].
  void assertExists(Object paths) {
    for (final String path in _paths(paths)) {
      final String normalized = normalizeDiskPath(path);
      expect(
        memory.fileExistsSync(normalized) ||
            memory.directoryExistsSync(normalized),
        isTrue,
        reason:
            'Unable to find a file or directory at path [$path] on disk [$name].',
      );
    }
  }

  /// Asserts nothing exists at any of [paths].
  void assertMissing(Object paths) {
    for (final String path in _paths(paths)) {
      final String normalized = normalizeDiskPath(path);
      expect(
        memory.fileExistsSync(normalized) ||
            (normalized.isNotEmpty && memory.directoryExistsSync(normalized)),
        isFalse,
        reason:
            'Found unexpected file or directory at path [$path] on disk [$name].',
      );
    }
  }

  /// Asserts [directory] holds [count] files, counting sub-folders when
  /// [recursive].
  void assertCount(String directory, int count, {bool recursive = false}) {
    final int found = memory
        .filesSync(normalizeDiskPath(directory), recursive: recursive)
        .length;
    expect(
      found,
      count,
      reason:
          'Expected [$count] files at [$directory] on disk [$name], but found [$found].',
    );
  }

  /// Asserts there are no files in [directory] or its sub-folders.
  void assertDirectoryEmpty(String directory) {
    expect(
      memory.filesSync(normalizeDiskPath(directory), recursive: true),
      isEmpty,
      reason: 'Directory [$directory] on disk [$name] is not empty.',
    );
  }

  /// Asserts the disk holds no files at all.
  void assertEmpty() {
    expect(
      memory.filesSync('', recursive: true),
      isEmpty,
      reason: 'Disk [$name] is not empty.',
    );
  }
}

/// Files for tests, like Laravel's `UploadedFile::fake()`.
///
/// ```dart
/// final XFile photo = FakeFile.image('avatar.png', width: 64, height: 64);
/// final XFile pdf = FakeFile.create('invoice.pdf', kilobytes: 120);
/// ```
///
/// They live in memory, so they work inside `testWidgets`.
class FakeFile {
  FakeFile._();

  /// A real, decodable PNG of [width] by [height] pixels. The contents are
  /// always PNG, whatever extension [name] has.
  static XFile image(String name, {int width = 10, int height = 10}) =>
      XFile.fromData(
        _png(width, height),
        path: name,
        name: name,
        mimeType: 'image/png',
        lastModified: DateTime.now(),
      );

  /// A file of [kilobytes] zero bytes, with the MIME type its [name]
  /// suggests unless [mimeType] is given.
  static XFile create(String name, {int kilobytes = 0, String? mimeType}) =>
      XFile.fromData(
        Uint8List(kilobytes * 1024),
        path: name,
        name: name,
        mimeType: mimeType ?? lookupMimeType(name),
        lastModified: DateTime.now(),
      );

  static Uint8List _png(int width, int height) {
    if (width < 1 || height < 1) {
      throw ArgumentError('A PNG needs at least one pixel');
    }
    // Each row is a filter byte (0) and RGB pixels in Nylo blue.
    final BytesBuilder rows = BytesBuilder(copy: false);
    final Uint8List row = Uint8List(1 + width * 3);
    for (int x = 0; x < width; x++) {
      row
        ..[1 + x * 3] = 0x32
        ..[2 + x * 3] = 0x8D
        ..[3 + x * 3] = 0xDF;
    }
    for (int y = 0; y < height; y++) {
      rows.add(row);
    }
    final ByteData header = ByteData(13)
      ..setUint32(0, width)
      ..setUint32(4, height)
      ..setUint8(8, 8) // bit depth
      ..setUint8(9, 2) // truecolour RGB
      ..setUint8(10, 0)
      ..setUint8(11, 0)
      ..setUint8(12, 0);
    return (BytesBuilder(copy: false)
          ..add(const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
          ..add(_chunk('IHDR', header.buffer.asUint8List()))
          ..add(_chunk('IDAT', ZLibCodec().encode(rows.takeBytes())))
          ..add(_chunk('IEND', const [])))
        .takeBytes();
  }

  static Uint8List _chunk(String type, List<int> data) {
    final List<int> typeAndData = [...type.codeUnits, ...data];
    final ByteData length = ByteData(4)..setUint32(0, data.length);
    final ByteData crc = ByteData(4)..setUint32(0, _crc32(typeAndData));
    return (BytesBuilder(copy: false)
          ..add(length.buffer.asUint8List())
          ..add(typeAndData)
          ..add(crc.buffer.asUint8List()))
        .takeBytes();
  }

  static final List<int> _crcTable = List<int>.generate(256, (int n) {
    int c = n;
    for (int k = 0; k < 8; k++) {
      c = (c & 1) != 0 ? 0xEDB88320 ^ (c >>> 1) : c >>> 1;
    }
    return c;
  });

  static int _crc32(List<int> bytes) {
    int crc = 0xFFFFFFFF;
    for (final int byte in bytes) {
      crc = _crcTable[(crc ^ byte) & 0xFF] ^ (crc >>> 8);
    }
    return (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF;
  }
}
