/// Base class for every file storage error.
///
/// Carries the name of the disk and the disk-relative path when they are
/// known, and the underlying error in [cause] when one was wrapped.
class DiskException implements Exception {
  /// Creates a new [DiskException].
  const DiskException(this.message, {this.disk, this.path, this.cause});

  /// What went wrong.
  final String message;

  /// The name of the disk, e.g. `local`.
  final String? disk;

  /// The path on the disk, as the caller wrote it.
  final String? path;

  /// The error this one wraps, e.g. a `FileSystemException`.
  final Object? cause;

  /// The name printed by [toString].
  String get kind => 'DiskException';

  /// The same error, reported against [disk] and [path].
  ///
  /// Drivers throw with the path they were given; [Disk] calls this so the
  /// caller sees its own disk name and path.
  DiskException relocate(String disk, String path) =>
      DiskException(message, disk: disk, path: path, cause: cause);

  @override
  String toString() {
    final StringBuffer buffer = StringBuffer('$kind: $message');
    if (disk != null) buffer.write(' (disk: $disk)');
    if (path != null) buffer.write(' (path: $path)');
    if (cause != null) buffer.write('\n$cause');
    return buffer.toString();
  }
}

/// Thrown when a file does not exist.
class DiskFileNotFoundException extends DiskException {
  /// Creates a new [DiskFileNotFoundException].
  const DiskFileNotFoundException(String path, {super.disk})
    : super('File not found', path: path);

  @override
  String get kind => 'DiskFileNotFoundException';

  @override
  DiskFileNotFoundException relocate(String disk, String path) =>
      DiskFileNotFoundException(path, disk: disk);
}

/// Thrown when a path climbs above the disk's root with `..`.
class DiskPathTraversalException extends DiskException {
  /// Creates a new [DiskPathTraversalException].
  const DiskPathTraversalException(String path, {super.disk})
    : super('Path escapes the disk root', path: path);

  @override
  String get kind => 'DiskPathTraversalException';

  @override
  DiskPathTraversalException relocate(String disk, String path) =>
      DiskPathTraversalException(path, disk: disk);
}

/// Thrown when a path contains control characters.
class DiskCorruptedPathException extends DiskException {
  /// Creates a new [DiskCorruptedPathException].
  const DiskCorruptedPathException(String path, {super.disk})
    : super('Path contains control characters', path: path);

  @override
  String get kind => 'DiskCorruptedPathException';

  @override
  DiskCorruptedPathException relocate(String disk, String path) =>
      DiskCorruptedPathException(path, disk: disk);
}

/// Thrown when something writes to a read-only disk, such as `assets`.
class DiskReadOnlyException extends DiskException {
  /// Creates a new [DiskReadOnlyException] for [operation].
  const DiskReadOnlyException(this.operation, {super.disk, super.path})
    : super('The disk is read-only, so $operation is not allowed');

  /// The refused operation, e.g. `put`.
  final String operation;

  @override
  String get kind => 'DiskReadOnlyException';

  @override
  DiskReadOnlyException relocate(String disk, String path) =>
      DiskReadOnlyException(operation, disk: disk, path: path);
}

/// Thrown by `disk('name')` when no disk has that name.
class DiskNotConfiguredException extends DiskException {
  /// Creates a new [DiskNotConfiguredException] for [disk].
  const DiskNotConfiguredException(String disk)
    : super(
        'No disk is configured with this name. Add it to '
        'FileStorageConfig.disks, or build one with FileStorage.build()',
        disk: disk,
      );

  @override
  String get kind => 'DiskNotConfiguredException';

  @override
  DiskNotConfiguredException relocate(String disk, String path) =>
      DiskNotConfiguredException(disk);
}
