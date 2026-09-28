import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:mime/mime.dart';
import 'package:nylo_support/file_storage/ny_file_storage.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(FileStorage.reset);

  group('FakeDisk assertions', () {
    late FakeDisk photos;
    setUp(() async {
      photos = FileStorage.fake('photos');
      await photos.put('photo1.jpg', 'a');
      await photos.put('wallpapers/1.jpg', 'b');
      await photos.put('wallpapers/2.jpg', 'c');
      await photos.put('wallpapers/old/3.jpg', 'd');
      await photos.makeDirectory('empty');
    });

    test('pass when the disk matches', () {
      photos.assertExists('photo1.jpg');
      photos.assertExists(['photo1.jpg', 'wallpapers/1.jpg', '/wallpapers']);
      photos.assertMissing('missing.jpg');
      photos.assertMissing(['missing.jpg', 'non-existing.jpg']);
      photos.assertCount('/wallpapers', 2);
      photos.assertCount('wallpapers', 3, recursive: true);
      photos.assertDirectoryEmpty('empty');
      photos.assertDirectoryEmpty('never-made');
    });

    test('fail with Laravel\'s wording', () {
      expect(
        () => photos.assertExists('missing.jpg'),
        throwsA(
          isA<TestFailure>().having(
            (e) => e.message,
            'message',
            contains(
              'Unable to find a file or directory at path [missing.jpg] on disk [photos].',
            ),
          ),
        ),
      );
      expect(
        () => photos.assertMissing(['missing.jpg', 'photo1.jpg']),
        throwsA(
          isA<TestFailure>().having(
            (e) => e.message,
            'message',
            contains('Found unexpected file or directory at path [photo1.jpg]'),
          ),
        ),
      );
      expect(
        () => photos.assertMissing('wallpapers'),
        throwsA(isA<TestFailure>()),
      );
      expect(
        () => photos.assertCount('wallpapers', 5),
        throwsA(
          isA<TestFailure>().having(
            (e) => e.message,
            'message',
            contains(
              'Expected [5] files at [wallpapers] on disk [photos], but found [2].',
            ),
          ),
        ),
      );
      expect(
        () => photos.assertDirectoryEmpty('wallpapers'),
        throwsA(isA<TestFailure>()),
      );
      expect(() => photos.assertEmpty(), throwsA(isA<TestFailure>()));
    });
  });

  group('FakeFile', () {
    testWidgets('image is a real PNG that Flutter can decode', (tester) async {
      final XFile photo = FakeFile.image('avatar.png', width: 7, height: 3);
      final Uint8List bytes = await photo.readAsBytes();
      expect(photo.name, 'avatar.png');
      expect(photo.mimeType, 'image/png');
      expect(lookupMimeType('', headerBytes: bytes), 'image/png');

      final ui.Image? image = await tester.runAsync(() async {
        final ui.Codec codec = await ui.instantiateImageCodec(bytes);
        return (await codec.getNextFrame()).image;
      });
      expect(image!.width, 7);
      expect(image.height, 3);
    });

    test('create makes a file of a given size and type', () async {
      final XFile pdf = FakeFile.create('invoice.pdf', kilobytes: 3);
      expect(await pdf.length(), 3 * 1024);
      expect(pdf.mimeType, 'application/pdf');
      expect(pdf.name, 'invoice.pdf');
      expect(
        FakeFile.create('data.bin', mimeType: 'application/x-nylo').mimeType,
        'application/x-nylo',
      );
    });

    test('putFile stores a fake upload like a real one', () async {
      final FakeDisk local = FileStorage.fake('local');
      final String path = await disk(
        'local',
      ).putFile('avatars', FakeFile.image('me.jpg'));
      expect(path, endsWith('.png'), reason: 'fake images are always PNG');
      local.assertCount('avatars', 1);
      expect(await disk('local').mimeType(path), 'image/png');
    });
  });
}
