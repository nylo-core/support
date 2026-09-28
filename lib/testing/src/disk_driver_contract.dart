import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import '/file_storage/src/disk.dart';
import '/file_storage/src/disk_driver.dart';
import '/file_storage/src/disk_exceptions.dart';
import 'fake_disk.dart';

/// Checks that a writable [DiskDriver] behaves the way `Disk` relies on.
///
/// Every built-in writable driver passes this suite; run it against your
/// own before you ship it. [create] is called before each test and should
/// return an empty driver; [cleanUp] runs after each test.
///
/// ```dart
/// void main() {
///   testDiskDriver(
///     'FirebaseStorageDriver',
///     () => FirebaseStorageDriver(FirebaseStorage.instance.ref('test')),
///     cleanUp: () => deleteEverything('test'),
///   );
/// }
/// ```
void testDiskDriver(
  String description,
  FutureOr<DiskDriver> Function() create, {
  FutureOr<void> Function()? cleanUp,
}) {
  group('$description meets the DiskDriver contract', () {
    late Disk subject;
    setUp(() async => subject = Disk('contract', await create()));
    if (cleanUp != null) tearDown(cleanUp);

    test('round-trips text, bytes and streams', () async {
      await subject.put('notes/hello.txt', 'héllo ✓');
      expect(await subject.get('notes/hello.txt'), 'héllo ✓');

      await subject.put('data.bin', Uint8List.fromList([0, 1, 2, 255]));
      expect(await subject.bytes('data.bin'), [0, 1, 2, 255]);

      await subject.put(
        'big/stream.bin',
        Stream<List<int>>.fromIterable([
          List<int>.filled(1000, 7),
          List<int>.filled(24, 8),
        ]),
      );
      final List<int> streamed = await subject
          .readStream('big/stream.bin')
          .expand((chunk) => chunk)
          .toList();
      expect(streamed.length, 1024);
      expect(streamed.last, 8);
    });

    test('reports what exists', () async {
      await subject.put('a/b.txt', 'x');
      expect(await subject.exists('a/b.txt'), isTrue);
      expect(await subject.exists('/a/b.txt'), isTrue);
      expect(await subject.missing('a/c.txt'), isTrue);
      expect(await subject.directoryExists('a'), isTrue);
      expect(await subject.directoryExists('z'), isFalse);
      expect(await subject.exists('a'), isFalse, reason: 'a is a folder');
    });

    test('replaces a file with new contents', () async {
      await subject.put('file.txt', 'a much longer first version');
      await subject.put('file.txt', 'short');
      expect(await subject.get('file.txt'), 'short');
      expect(await subject.size('file.txt'), 5);
    });

    test('appends and prepends with a separator', () async {
      await subject.append('log.txt', 'one');
      await subject.append('log.txt', 'two');
      await subject.prepend('log.txt', 'zero');
      expect(await subject.get('log.txt'), 'zero\none\ntwo');
    });

    test('copies, moves and deletes', () async {
      await subject.put('old/photo.jpg', 'img');
      await subject.copy('old/photo.jpg', 'new/copy.jpg');
      await subject.move('old/photo.jpg', 'new/moved.jpg');
      expect(await subject.missing('old/photo.jpg'), isTrue);
      expect(await subject.get('new/copy.jpg'), 'img');
      expect(await subject.get('new/moved.jpg'), 'img');

      await subject.put('new/copy.jpg', 'replaced');
      await subject.move('new/copy.jpg', 'new/moved.jpg');
      expect(await subject.get('new/moved.jpg'), 'replaced');

      expect(await subject.delete(['new/moved.jpg']), isTrue);
      expect(await subject.delete('new/moved.jpg'), isFalse);
    });

    test('lists files and folders', () async {
      await subject.put('photos/a.jpg', '1');
      await subject.put('photos/b.jpg', '2');
      await subject.put('photos/2026/c.jpg', '3');
      await subject.makeDirectory('photos/empty');

      expect(await subject.files('photos'), ['photos/a.jpg', 'photos/b.jpg']);
      expect(await subject.allFiles('photos'), [
        'photos/2026/c.jpg',
        'photos/a.jpg',
        'photos/b.jpg',
      ]);
      expect(await subject.directories('photos'), [
        'photos/2026',
        'photos/empty',
      ]);
      expect(await subject.allDirectories(), [
        'photos',
        'photos/2026',
        'photos/empty',
      ]);
      expect(await subject.files('nothing-here'), isEmpty);

      final List<DiskEntry> entries = await subject.list('photos');
      final DiskEntry a = entries.firstWhere((e) => e.path == 'photos/a.jpg');
      expect(a.isFile, isTrue);
      expect(a.size, 1);
      expect(a.name, 'a.jpg');
    });

    test('deletes folders, and empties the root', () async {
      await subject.put('keep/a.txt', 'a');
      await subject.put('drop/b.txt', 'b');
      await subject.put('drop/deep/c.txt', 'c');
      expect(await subject.deleteDirectory('drop'), isTrue);
      expect(await subject.deleteDirectory('drop'), isFalse);
      expect(await subject.allFiles(), ['keep/a.txt']);

      expect(await subject.deleteDirectory(''), isTrue);
      expect(await subject.allFiles(), isEmpty);
    });

    test('reports size, date, type and checksum', () async {
      await subject.put('hello.txt', 'hello');
      expect(await subject.size('hello.txt'), 5);
      final DateTime modified = await subject.lastModified('hello.txt');
      expect(
        modified.isAfter(DateTime.now().subtract(const Duration(days: 1))),
        isTrue,
      );
      expect(await subject.mimeType('hello.txt'), 'text/plain');
      expect(
        await subject.checksum('hello.txt'),
        '5d41402abc4b2a76b9719d911017c592',
      );
      expect(
        await subject.checksum('hello.txt', algorithm: 'sha256'),
        '2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824',
      );
    });

    test('stores files under generated names', () async {
      final String path = await subject.putFile(
        'avatars',
        FakeFile.image('me.png'),
      );
      expect(path, matches(RegExp(r'^avatars/[a-z0-9]{40}\.png$')));
      expect(await subject.mimeType(path), 'image/png');

      final String jpeg = await subject.putFile(
        'avatars',
        Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0, 0x10]),
      );
      expect(jpeg, endsWith('.jpg'));

      expect(
        await subject.putFileAs('avatars', FakeFile.image('x.png'), '42.png'),
        'avatars/42.png',
      );
    });

    test('keeps a scoped disk inside its folder', () async {
      final Disk user = subject.scope('users/42');
      await user.put('profile.json', jsonEncode({'id': 42}));
      expect(await subject.exists('users/42/profile.json'), isTrue);
      expect(await user.files(), ['profile.json']);
      expect(await user.json<Map<String, dynamic>>('profile.json'), {'id': 42});
      await expectLater(
        user.get('../41/profile.json'),
        throwsA(isA<DiskPathTraversalException>()),
      );
    });

    test('throws typed errors that name the disk and path', () async {
      await expectLater(
        subject.get('nope.txt'),
        throwsA(
          isA<DiskFileNotFoundException>()
              .having((e) => e.disk, 'disk', 'contract')
              .having((e) => e.path, 'path', 'nope.txt'),
        ),
      );
      await expectLater(
        subject.readStream('nope.txt').toList(),
        throwsA(isA<DiskFileNotFoundException>()),
      );
      await expectLater(
        subject.size('nope.txt'),
        throwsA(isA<DiskFileNotFoundException>()),
      );
      await expectLater(
        subject.put('../escape.txt', 'x'),
        throwsA(isA<DiskPathTraversalException>()),
      );
      await expectLater(
        subject.copy('nope.txt', 'other.txt'),
        throwsA(isA<DiskFileNotFoundException>()),
      );
    });
  });
}
