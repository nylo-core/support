import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'file_storage.dart';
import 'path_normalizer.dart';

/// Shows an image stored on a disk.
///
/// ```dart
/// CircleAvatar(backgroundImage: DiskImage('avatars/me.jpg'));
/// Image(image: DiskImage('thumbs/42.jpg', disk: 'cache'));
/// ```
///
/// It reads through the disk, so it works with every driver and with
/// `FileStorage.fake()`. Writing the file through its disk evicts it from
/// the image cache, so the new picture shows on the next frame; Flutter's
/// `FileImage` keeps showing the old one because it caches by path.
@immutable
class DiskImage extends ImageProvider<DiskImage> {
  /// The image at [path] on [disk], or on the default disk when null.
  DiskImage(String path, {String? disk, this.scale = 1.0})
    : path = normalizeDiskPath(path),
      disk = disk ?? FileStorage.defaultDisk;

  /// The image's path on [disk].
  final String path;

  /// The name of the disk the image is on.
  final String disk;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  /// Keys given to the image cache, so a write can evict every scale.
  static final Set<DiskImage> _loaded = {};

  /// Evicts the cached images of [path] on [disk].
  static void evictFile(String disk, String path) {
    if (_loaded.isEmpty) return;
    _evictWhere((key) => key.disk == disk && key.path == path);
  }

  /// Evicts the cached images inside [directory] on [disk].
  static void evictDirectory(String disk, String directory) {
    if (_loaded.isEmpty) return;
    _evictWhere(
      (key) => key.disk == disk && isWithinDiskPath(directory, key.path),
    );
  }

  static void _evictWhere(bool Function(DiskImage key) test) {
    for (final DiskImage key in _loaded.where(test).toList()) {
      PaintingBinding.instance.imageCache.evict(key);
      _loaded.remove(key);
    }
  }

  @override
  Future<DiskImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<DiskImage>(this);

  @override
  ImageStreamCompleter loadImage(DiskImage key, ImageDecoderCallback decode) {
    // The image cache drops entries on its own; forget those keys too, so a
    // long-running gallery doesn't grow this set without bound.
    if (_loaded.length >= 512) {
      final ImageCache cache = PaintingBinding.instance.imageCache;
      _loaded.removeWhere((loaded) => !cache.containsKey(loaded));
    }
    _loaded.add(key);
    return MultiFrameImageStreamCompleter(
      codec: _load(key, decode),
      scale: key.scale,
      debugLabel: 'DiskImage(${key.disk}:${key.path})',
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<DiskImage>('Image key', key),
      ],
    );
  }

  Future<ui.Codec> _load(DiskImage key, ImageDecoderCallback decode) async {
    final Uint8List bytes = await FileStorage.disk(key.disk).bytes(key.path);
    if (bytes.isEmpty) {
      throw StateError('DiskImage(${key.disk}:${key.path}) is an empty file');
    }
    return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
  }

  @override
  bool operator ==(Object other) =>
      other is DiskImage &&
      other.disk == disk &&
      other.path == path &&
      other.scale == scale;

  @override
  int get hashCode => Object.hash(disk, path, scale);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'DiskImage')}("$disk:$path", scale: $scale)';
}
