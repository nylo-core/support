import 'disk_exceptions.dart';

final RegExp _controlCharacters = RegExp(r'[\x00-\x1F\x7F]');

/// Normalizes a disk path the way Flysystem does.
///
/// Backslashes become `/`, empty and `.` segments are dropped, and `..`
/// removes the segment before it. A `..` that would climb above the root
/// throws [DiskPathTraversalException], and control characters throw
/// [DiskCorruptedPathException]. A leading `/` is relative to the disk's
/// root, so `/avatars` and `avatars` are the same path. Nothing is
/// URL-decoded: `%2e%2e` is a file name, not `..`.
///
/// The result has no leading or trailing slash; the root is `''`.
String normalizeDiskPath(String path, {String? disk}) {
  if (_controlCharacters.hasMatch(path)) {
    throw DiskCorruptedPathException(path, disk: disk);
  }
  final List<String> segments = [];
  for (final String segment in path.replaceAll(r'\', '/').split('/')) {
    if (segment.isEmpty || segment == '.') continue;
    if (segment == '..') {
      if (segments.isEmpty) throw DiskPathTraversalException(path, disk: disk);
      segments.removeLast();
      continue;
    }
    segments.add(segment);
  }
  return segments.join('/');
}

/// Joins two normalized paths.
String joinDiskPath(String first, String second) {
  if (first.isEmpty) return second;
  if (second.isEmpty) return first;
  return '$first/$second';
}

/// Removes [prefix] from the front of a normalized [path].
String stripDiskPrefix(String prefix, String path) {
  if (prefix.isEmpty) return path;
  if (path == prefix) return '';
  return path.startsWith('$prefix/') ? path.substring(prefix.length + 1) : path;
}

/// The parent folder of a normalized [path]; `''` for the root.
String parentDiskPath(String path) {
  final int slash = path.lastIndexOf('/');
  return slash < 0 ? '' : path.substring(0, slash);
}

/// Whether normalized [path] is [directory] itself or inside it.
bool isWithinDiskPath(String directory, String path) =>
    directory.isEmpty || path == directory || path.startsWith('$directory/');
