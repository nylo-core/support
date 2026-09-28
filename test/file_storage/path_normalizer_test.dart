import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/file_storage/ny_file_storage.dart';
import 'package:nylo_support/file_storage/src/path_normalizer.dart';

void main() {
  group('normalizeDiskPath', () {
    const Map<String, String> cases = {
      'avatars/me.jpg': 'avatars/me.jpg',
      '/wallpapers': 'wallpapers',
      'a/./b//c/': 'a/b/c',
      'a/../b': 'b',
      r'a\b\c.txt': 'a/b/c.txt',
      '': '',
      '.': '',
      '/': '',
      '%2e%2e/x': '%2e%2e/x',
      '..hidden/x': '..hidden/x',
      'x..': 'x..',
      'users/42/../41/card.json': 'users/41/card.json',
    };
    cases.forEach((input, expected) {
      test('"$input" becomes "$expected"', () {
        expect(normalizeDiskPath(input), expected);
      });
    });

    for (final String input in [
      '..',
      '../x',
      '/../x',
      'a/../../x',
      r'..\x',
      'a/b/../../../etc/passwd',
    ]) {
      test('"$input" climbs above the root', () {
        expect(
          () => normalizeDiskPath(input, disk: 'local'),
          throwsA(
            isA<DiskPathTraversalException>()
                .having((e) => e.path, 'path', input)
                .having((e) => e.disk, 'disk', 'local'),
          ),
        );
      });
    }

    for (final String input in ['a\u0000b', 'a\nb', 'tab\there', 'bell\x07']) {
      test('${input.codeUnits} has control characters', () {
        expect(
          () => normalizeDiskPath(input),
          throwsA(isA<DiskCorruptedPathException>()),
        );
      });
    }
  });

  group('path helpers', () {
    test('joinDiskPath skips empty sides', () {
      expect(joinDiskPath('', 'a'), 'a');
      expect(joinDiskPath('a', ''), 'a');
      expect(joinDiskPath('a', 'b/c'), 'a/b/c');
    });

    test('stripDiskPrefix only strips whole segments', () {
      expect(stripDiskPrefix('nylo', 'nylo/a.txt'), 'a.txt');
      expect(stripDiskPrefix('nylo', 'nylo'), '');
      expect(stripDiskPrefix('nylo', 'nylon/a.txt'), 'nylon/a.txt');
      expect(stripDiskPrefix('', 'a.txt'), 'a.txt');
    });

    test('parentDiskPath and isWithinDiskPath', () {
      expect(parentDiskPath('a/b/c.txt'), 'a/b');
      expect(parentDiskPath('c.txt'), '');
      expect(isWithinDiskPath('a', 'a/b.txt'), isTrue);
      expect(isWithinDiskPath('a', 'a'), isTrue);
      expect(isWithinDiskPath('a', 'ab/c.txt'), isFalse);
      expect(isWithinDiskPath('', 'anything'), isTrue);
    });
  });

  group('DiskException', () {
    test('toString names the kind, disk, path and cause', () {
      const DiskException error = DiskException(
        'Could not write',
        disk: 'local',
        path: 'a.txt',
        cause: 'disk full',
      );
      expect(
        error.toString(),
        'DiskException: Could not write (disk: local) (path: a.txt)\ndisk full',
      );
      expect(
        const DiskFileNotFoundException('a.txt', disk: 'local').toString(),
        'DiskFileNotFoundException: File not found (disk: local) (path: a.txt)',
      );
    });

    test('relocate keeps the type and reports the caller\'s disk and path', () {
      final DiskException moved = const DiskReadOnlyException(
        'put',
      ).relocate('assets', 'x.txt');
      expect(
        moved,
        isA<DiskReadOnlyException>()
            .having((e) => e.operation, 'operation', 'put')
            .having((e) => e.disk, 'disk', 'assets')
            .having((e) => e.path, 'path', 'x.txt'),
      );
      expect(
        const DiskPathTraversalException('nylo/../x').relocate('local', '../x'),
        isA<DiskPathTraversalException>().having((e) => e.path, 'path', '../x'),
      );
    });
  });
}
