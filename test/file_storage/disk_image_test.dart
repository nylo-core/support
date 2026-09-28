import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/file_storage/ny_file_storage.dart';
import 'package:nylo_support/testing/ny_testing.dart';

/// Counts reads, so a test can see an image load again.
class _CountingDriver extends MemoryDiskDriver {
  int reads = 0;

  @override
  Future<Uint8List> read(String path) {
    reads++;
    return super.read(path);
  }
}

Future<void> _show(WidgetTester tester, DiskImage image) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(
      MaterialApp(
        home: Image(image: image, key: UniqueKey()),
      ),
    );
    await precacheImage(image, tester.element(find.byType(Image)));
  });
  await tester.pump();
}

void main() {
  late _CountingDriver driver;
  late XFile photo;

  setUp(() {
    driver = _CountingDriver();
    FileStorage.configure(
      disks: {'photos': DiskConfig.custom(() => driver, prefix: 'app')},
    );
    photo = FakeFile.image('me.png');
  });
  tearDown(() {
    PaintingBinding.instance.imageCache.clear();
    FileStorage.reset();
  });

  testWidgets('shows an image from a disk and reloads it when rewritten', (
    tester,
  ) async {
    final Disk photos = disk('photos');
    await photos.put('avatars/me.png', await photo.readAsBytes());
    final DiskImage image = DiskImage('avatars/me.png', disk: 'photos');

    await _show(tester, image);
    expect(PaintingBinding.instance.imageCache.containsKey(image), isTrue);
    expect(driver.reads, 1);

    await photos.put('avatars/me.png', await photo.readAsBytes());
    expect(
      PaintingBinding.instance.imageCache.containsKey(image),
      isFalse,
      reason: 'the write evicted the stale image',
    );

    await _show(tester, image);
    expect(driver.reads, 2, reason: 'the new picture was read');
  });

  testWidgets('writes through a scope evict the same image', (tester) async {
    await disk('photos').put('users/1/me.png', await photo.readAsBytes());
    final DiskImage image = DiskImage('users/1/me.png', disk: 'photos');
    await _show(tester, image);

    await disk('photos').scope('users/1').put('me.png', 'new bytes');
    expect(PaintingBinding.instance.imageCache.containsKey(image), isFalse);
  });

  testWidgets('deletes, moves and folder deletes evict', (tester) async {
    final Disk photos = disk('photos');
    for (final String name in ['a', 'b', 'c']) {
      await photos.put('gallery/$name.png', await photo.readAsBytes());
    }
    final DiskImage a = DiskImage('gallery/a.png', disk: 'photos');
    final DiskImage b = DiskImage('gallery/b.png', disk: 'photos');
    final DiskImage c = DiskImage('gallery/c.png', disk: 'photos');
    for (final DiskImage image in [a, b, c]) {
      await _show(tester, image);
    }
    final ImageCache cache = PaintingBinding.instance.imageCache;

    await photos.delete('gallery/a.png');
    expect(cache.containsKey(a), isFalse);
    expect(cache.containsKey(b), isTrue);

    await photos.move('gallery/b.png', 'gallery/moved.png');
    expect(cache.containsKey(b), isFalse);

    await photos.deleteDirectory('gallery');
    expect(cache.containsKey(c), isFalse);
  });

  testWidgets('a missing file reports a DiskFileNotFoundException', (
    tester,
  ) async {
    final DiskImage image = DiskImage('nope.png', disk: 'photos');
    Object? failure;
    await tester.runAsync(() async {
      final ImageStream stream = image.resolve(ImageConfiguration.empty);
      final Completer<void> done = Completer<void>();
      stream.addListener(
        ImageStreamListener(
          (_, _) => done.complete(),
          onError: (Object error, _) {
            failure = error;
            done.complete();
          },
        ),
      );
      await done.future;
    });
    expect(failure, isA<DiskFileNotFoundException>());
  });

  test('keys compare by disk, path and scale', () {
    expect(
      DiskImage('a/b.png', disk: 'photos'),
      DiskImage('/a/b.png', disk: 'photos'),
    );
    expect(
      DiskImage('a.png', disk: 'photos') == DiskImage('a.png', disk: 'x'),
      isFalse,
    );
    expect(
      DiskImage('a.png', disk: 'photos', scale: 2) ==
          DiskImage('a.png', disk: 'photos'),
      isFalse,
    );
    expect(DiskImage('a.png').disk, FileStorage.defaultDisk);
    expect(
      DiskImage('a.png', disk: 'photos').toString(),
      'DiskImage("photos:a.png", scale: 1.0)',
    );
  });
}
