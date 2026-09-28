import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/file_storage/ny_file_storage.dart';
import 'package:nylo_support/testing/ny_testing.dart';

/// A bundle with a real AssetManifest.bin, so AssetDiskDriver can list it.
class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.bin') {
      return const StandardMessageCodec().encodeMessage({
        for (final String asset in assets.keys) asset: <Object?>[],
      })!;
    }
    final String? content = assets[key];
    if (content == null) throw StateError('Unable to load asset: "$key".');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(content)));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory root;
  testDiskDriver(
    'LocalDiskDriver',
    () async {
      root = await Directory.systemTemp.createTemp('nylo_disk_contract_');
      return LocalDiskDriver.at(root.path);
    },
    cleanUp: () async {
      if (await root.exists()) await root.delete(recursive: true);
    },
  );

  testDiskDriver('MemoryDiskDriver', MemoryDiskDriver.new);

  group('LocalDiskDriver', () {
    late Directory dir;
    setUp(() async => dir = await Directory.systemTemp.createTemp('nylo_ldd_'));
    tearDown(() async {
      if (await dir.exists()) await dir.delete(recursive: true);
    });

    test('writes atomically and leaves no temp files behind', () async {
      final LocalDiskDriver driver = LocalDiskDriver.at(dir.path);
      const int size = 4 * 1024 * 1024;
      final Uint8List a = Uint8List(size)..fillRange(0, size, 0x61);
      final Uint8List b = Uint8List(size)..fillRange(0, size, 0x62);
      await driver.write('cache.bin', a);

      int reads = 0;
      int torn = 0;
      bool writing = true;
      final Future<void> reader = () async {
        final File file = File('${dir.path}/cache.bin');
        while (writing) {
          final Uint8List seen = await file.readAsBytes();
          reads++;
          final bool whole =
              seen.length == size &&
              (seen.every((x) => x == 0x61) || seen.every((x) => x == 0x62));
          if (!whole) torn++;
        }
      }();
      for (int i = 0; i < 6; i++) {
        await driver.write('cache.bin', i.isEven ? b : a);
      }
      writing = false;
      await reader;

      expect(reads, greaterThan(0));
      expect(torn, 0);
      expect(dir.listSync().map((e) => e.uri.pathSegments.last), ['cache.bin']);
    });

    test('hides temp files from listings', () async {
      final LocalDiskDriver driver = LocalDiskDriver.at(dir.path);
      await driver.write('a.txt', utf8.encode('a'));
      await File(
        '${dir.path}/.b.txt${LocalDiskDriver.tempMarker}123',
      ).writeAsString('partial');
      final List<String> paths = await driver
          .list('', recursive: true)
          .map((e) => e.path)
          .toList();
      expect(paths, ['a.txt']);
    });

    test('never follows symlinks out of its root', () async {
      final Directory outside = await Directory.systemTemp.createTemp(
        'nylo_out_',
      );
      addTearDown(() => outside.delete(recursive: true));
      await File('${outside.path}/secret.txt').writeAsString('secret');
      await Link('${dir.path}/outside').create(outside.path);

      final Disk disk = Disk('local', LocalDiskDriver.at(dir.path));
      await disk.put('mine.txt', 'mine');
      expect(await disk.allFiles(), ['mine.txt']);
    });

    test(
      'resolves its root once, on first use, and retries a failure',
      () async {
        int calls = 0;
        bool fail = true;
        final LocalDiskDriver driver = LocalDiskDriver(() async {
          calls++;
          if (fail) throw StateError('not yet');
          return dir.path;
        });
        expect(calls, 0, reason: 'building a driver touches nothing');

        await expectLater(driver.fileExists('a.txt'), throwsStateError);
        fail = false;
        await driver.write('a.txt', utf8.encode('a'));
        await driver.write('b.txt', utf8.encode('b'));
        expect(await driver.fileExists('a.txt'), isTrue);
        expect(calls, 2, reason: 'one failed attempt, then one success');
      },
    );

    test('empties its root without deleting the root folder', () async {
      final LocalDiskDriver driver = LocalDiskDriver.at(dir.path);
      await driver.write('a/b.txt', utf8.encode('b'));
      expect(await driver.deleteDirectory(''), isTrue);
      expect(await dir.exists(), isTrue);
      expect(dir.listSync(), isEmpty);
    });

    test('reports the absolute path', () async {
      final LocalDiskDriver driver = LocalDiskDriver.at(dir.path);
      expect(
        await driver.absolutePath('a/b.txt'),
        '${dir.path}${Platform.pathSeparator}a${Platform.pathSeparator}b.txt',
      );
      expect(await driver.absolutePath(''), dir.path);
    });
  });

  group('MemoryDiskDriver', () {
    test('answers synchronously for fakes', () async {
      final MemoryDiskDriver driver = MemoryDiskDriver();
      await driver.write('a/b/c.txt', utf8.encode('c'));
      await driver.createDirectory('empty');
      expect(driver.fileExistsSync('a/b/c.txt'), isTrue);
      expect(driver.directoryExistsSync('a/b'), isTrue);
      expect(driver.directoryExistsSync('empty'), isTrue);
      expect(driver.directoryExistsSync('nope'), isFalse);
      expect(driver.filesSync('a'), isEmpty);
      expect(driver.filesSync('a', recursive: true), ['a/b/c.txt']);
      expect(utf8.decode(driver.readSync('a/b/c.txt')!), 'c');
      expect(await driver.absolutePath('a/b/c.txt'), isNull);
    });

    test('returns copies, so callers cannot change stored bytes', () async {
      final MemoryDiskDriver driver = MemoryDiskDriver();
      final Uint8List bytes = Uint8List.fromList([1, 2, 3]);
      await driver.write('x.bin', bytes);
      bytes[0] = 9;
      final Uint8List read = await driver.read('x.bin');
      read[1] = 9;
      expect(await driver.read('x.bin'), [1, 2, 3]);
    });
  });

  group('AssetDiskDriver', () {
    final _FakeBundle bundle = _FakeBundle({
      'assets/sample/hello.txt': 'hello from the bundle',
      'assets/sample/nested/data.json': '{"a":1}',
      'lang/en.json': '{}',
    });

    test('lists and reads the bundle under its prefix', () async {
      final Disk assets = FileStorage.build(
        DiskConfig.assets(bundle: bundle),
        name: 'assets',
      );
      expect(await assets.allFiles(), [
        'sample/hello.txt',
        'sample/nested/data.json',
      ]);
      expect(await assets.directories('sample'), ['sample/nested']);
      expect(await assets.get('sample/hello.txt'), 'hello from the bundle');
      expect(
        await assets.json<Map<String, dynamic>>('sample/nested/data.json'),
        {'a': 1},
      );
      expect(await assets.exists('sample/missing.txt'), isFalse);
      expect(await assets.size('sample/hello.txt'), 21);
    });

    test('is read-only', () async {
      final Disk assets = FileStorage.build(
        DiskConfig.assets(bundle: bundle),
        name: 'assets',
      );
      expect(assets.readOnly, isTrue);
      await expectLater(
        assets.put('sample/new.txt', 'x'),
        throwsA(
          isA<DiskReadOnlyException>()
              .having((e) => e.operation, 'operation', 'put')
              .having((e) => e.disk, 'disk', 'assets'),
        ),
      );
      await expectLater(
        assets.delete('sample/hello.txt'),
        throwsA(isA<DiskReadOnlyException>()),
      );
      await expectLater(
        assets.lastModified('sample/hello.txt'),
        throwsA(isA<DiskException>()),
      );
      await expectLater(
        assets.path('sample/hello.txt'),
        throwsA(isA<DiskException>()),
      );
    });

    test('reports missing assets as missing files', () async {
      final Disk assets = FileStorage.build(
        DiskConfig.assets(bundle: bundle),
        name: 'assets',
      );
      await expectLater(
        assets.get('sample/nope.txt'),
        throwsA(
          isA<DiskFileNotFoundException>().having(
            (e) => e.path,
            'path',
            'sample/nope.txt',
          ),
        ),
      );
    });
  });
}
