import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/file_storage/ny_file_storage.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory base;
  final List<String> pathCalls = [];

  /// Answers path_provider's method channel with folders under [base], and
  /// records each call.
  void mockPathProvider() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall call) async {
            pathCalls.add(call.method);
            return switch (call.method) {
              'getApplicationSupportDirectory' => '${base.path}/Support',
              'getApplicationDocumentsDirectory' => '${base.path}/Documents',
              'getApplicationCacheDirectory' => '${base.path}/Caches',
              'getTemporaryDirectory' => '${base.path}/Caches',
              'getLibraryDirectory' => '${base.path}/Library',
              _ => null,
            };
          },
        );
  }

  setUp(() async {
    base = await Directory.systemTemp.createTemp('nylo_fs_');
    pathCalls.clear();
    mockPathProvider();
    FileStorage.reset();
  });
  tearDown(() async {
    FileStorage.reset();
    if (await base.exists()) await base.delete(recursive: true);
  });

  group('default disks', () {
    test('five disks exist without configuration', () {
      expect(FileStorage.names, [
        'local',
        'documents',
        'cache',
        'temp',
        'assets',
      ]);
      expect(FileStorage.defaultDisk, 'local');
      expect(disk().name, 'local');
      expect(disk().prefix, 'nylo');
      expect(disk('documents').prefix, '');
      expect(disk('cache').prefix, 'nylo');
      expect(disk('temp').prefix, 'nylo');
      expect(disk('assets').prefix, 'assets');
      expect(disk('assets').readOnly, isTrue);
    });

    test('disks resolve their folder on first use, once', () async {
      final Disk cache = disk('cache');
      expect(pathCalls, isEmpty, reason: 'getting a disk touches nothing');

      await cache.put('thumbs/1.jpg', 'x');
      await cache.put('thumbs/2.jpg', 'y');
      expect(pathCalls, ['getApplicationCacheDirectory']);
      expect(
        File('${base.path}/Caches/nylo/thumbs/1.jpg').existsSync(),
        isTrue,
      );

      await disk('local').put('drafts/post.md', '# hi');
      expect(
        File('${base.path}/Support/nylo/drafts/post.md').existsSync(),
        isTrue,
      );
      await disk('documents').put('Invoice.pdf', 'pdf');
      expect(File('${base.path}/Documents/Invoice.pdf').existsSync(), isTrue);
    });

    test('documents refuses to be emptied whole; its folders can go', () async {
      await disk('documents').put('reports/q3.pdf', 'r');
      await expectLater(
        disk('documents').deleteDirectory(''),
        throwsA(isA<DiskException>()),
      );
      expect(await disk('documents').deleteDirectory('reports'), isTrue);
      expect(await disk('local').deleteDirectory(''), isFalse);
    });
  });

  group('DiskRoot', () {
    test('maps each root to its folder', () async {
      expect(await DiskRoot.support.resolve(), '${base.path}/Support');
      expect(await DiskRoot.documents.resolve(), '${base.path}/Documents');
      expect(await DiskRoot.cache.resolve(), '${base.path}/Caches');
      if (Platform.isIOS || Platform.isMacOS) {
        expect(await DiskRoot.library.resolve(), '${base.path}/Library');
      } else {
        await expectLater(
          DiskRoot.library.resolve(),
          throwsA(isA<DiskException>()),
        );
      }
      expect(
        await DiskRoot.temporary.resolve(),
        Platform.isIOS || Platform.isMacOS
            ? Directory.systemTemp.path
            : '${base.path}/Caches/tmp',
        reason: 'the OS temp folder, not path_provider\'s caches folder',
      );
    });

    test('a folder the platform lacks is a DiskException', () async {
      await expectLater(
        DiskRoot.downloads.resolve(),
        throwsA(isA<DiskException>()),
      );
      await expectLater(
        DiskRoot.external.resolve(),
        throwsA(isA<DiskException>()),
      );
    });
  });

  group('configure', () {
    test('adds disks, replaces defaults and sets the default disk', () {
      FileStorage.configure(
        disks: {
          'photos': DiskConfig.memory(),
          'cache': DiskConfig.memory(prefix: 'custom'),
        },
        defaultDisk: 'photos',
      );
      expect(FileStorage.names, containsAll(['local', 'photos', 'cache']));
      expect(disk('cache').prefix, 'custom');
      expect(disk().name, 'photos');
    });

    test('an unknown disk is a DiskNotConfiguredException', () {
      expect(
        () => disk('nope'),
        throwsA(
          isA<DiskNotConfiguredException>().having(
            (e) => e.disk,
            'disk',
            'nope',
          ),
        ),
      );
      expect(
        () => FileStorage.configure(defaultDisk: 'nope'),
        throwsA(isA<DiskNotConfiguredException>()),
      );
      expect(FileStorage.defaultDisk, 'local');
    });

    test('a scoped disk lives inside another disk', () async {
      FileStorage.configure(
        disks: {
          'avatars': DiskConfig.scoped('local', 'avatars'),
          'frozen': DiskConfig.scoped('local', 'frozen', readOnly: true),
        },
      );
      await disk('avatars').put('42.png', 'png');
      expect(await disk('local').exists('avatars/42.png'), isTrue);
      expect(disk('avatars').prefix, 'nylo/avatars');
      await expectLater(
        disk('frozen').put('x', 'x'),
        throwsA(isA<DiskReadOnlyException>()),
      );
    });

    test('build makes a disk that is not in the config', () async {
      final Disk exports = FileStorage.build(
        DiskConfig.path('${base.path}/exports'),
        name: 'exports',
      );
      await exports.put('a.csv', 'a');
      expect(File('${base.path}/exports/a.csv').existsSync(), isTrue);
      expect(FileStorage.names, isNot(contains('exports')));
    });
  });

  group('fakes', () {
    test('fake swaps a disk for an empty one in memory', () async {
      final FakeDisk photos = FileStorage.fake('local');
      await disk('local').put('avatars/1.jpg', 'a');
      expect(identical(disk('local'), photos), isTrue);
      photos.assertExists('avatars/1.jpg');
      expect(pathCalls, isEmpty, reason: 'nothing touched the device');

      final FakeDisk fresh = FileStorage.fake('local');
      fresh.assertEmpty();
    });

    test('a scoped disk writes into its faked parent', () async {
      FileStorage.configure(
        disks: {'avatars': DiskConfig.scoped('local', 'avatars')},
      );
      await disk('avatars').put('warm-up.png', 'x'); // built over the real disk
      final FakeDisk local = FileStorage.fake('local');
      await disk('avatars').put('42.png', 'png');
      local.assertExists('avatars/42.png');
    });

    test('useFakes fakes every writable disk; read-only ones stay real', () {
      FileStorage.useFakes();
      expect(disk('local'), isA<FakeDisk>());
      expect(disk('documents'), isA<FakeDisk>());
      expect(disk('assets'), isNot(isA<FakeDisk>()));
      expect(FileStorage.fakes.keys, ['local', 'documents']);
    });

    test('clearFakes starts every faked disk empty again', () async {
      FileStorage.useFakes();
      await disk('local').put('a.txt', 'a');
      FileStorage.clearFakes();
      expect(await disk('local').exists('a.txt'), isFalse);
      expect(disk('local'), isA<FakeDisk>());
    });
  });

  group('the default disk', () {
    test('FileStorage forwards to the default disk', () async {
      final FakeDisk local = FileStorage.fake();
      await FileStorage.put('a.txt', 'a');
      await FileStorage.putJson('b.json', {'b': 1});
      await FileStorage.append('a.txt', 'more');
      await FileStorage.copy('a.txt', 'c.txt');
      await FileStorage.makeDirectory('empty');

      expect(await FileStorage.get('a.txt'), 'a\nmore');
      expect(await FileStorage.json<Map<String, dynamic>>('b.json'), {'b': 1});
      expect(await FileStorage.exists('c.txt'), isTrue);
      expect(await FileStorage.files(), ['a.txt', 'b.json', 'c.txt']);
      expect(await FileStorage.directories(), ['empty']);
      expect(await FileStorage.size('c.txt'), 6);
      expect(await FileStorage.usage(), 19);
      expect(await FileStorage.delete(['a.txt', 'b.json']), isTrue);
      local.assertMissing(['a.txt', 'b.json']);
      local.assertCount('', 1);
    });
  });
}
