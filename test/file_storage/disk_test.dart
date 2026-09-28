import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/file_storage/ny_file_storage.dart';
import 'package:nylo_support/testing/ny_testing.dart';

class Order {
  Order(this.id);
  Order.fromJson(Map<String, dynamic> json) : id = json['id'] as int;
  final int id;
  Map<String, dynamic> toJson() => {'id': id};
}

final Map<Type, dynamic> orderDecoders = {
  Order: (dynamic data) => Order.fromJson(data as Map<String, dynamic>),
  List<Order>: (dynamic data) => [
    for (final dynamic item in data as List)
      Order.fromJson(item as Map<String, dynamic>),
  ],
};

void main() {
  // No TestWidgetsFlutterBinding here: it swaps in HttpOverrides that answer
  // every request with a 400, and the download tests talk to a real server.
  late Directory root;
  late Disk local;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('nylo_disk_');
    local = Disk('local', LocalDiskDriver.at(root.path), prefix: 'nylo');
  });
  tearDown(() async {
    FileStorage.reset();
    if (await root.exists()) await root.delete(recursive: true);
  });

  group('reading and writing', () {
    test('keeps files inside the prefix and reports caller paths', () async {
      await local.put('notes/a.txt', 'a');
      expect(File('${root.path}/nylo/notes/a.txt').existsSync(), isTrue);
      expect(await local.allFiles(), ['notes/a.txt']);
      await expectLater(
        local.get('notes/missing.txt'),
        throwsA(
          isA<DiskFileNotFoundException>()
              .having((e) => e.disk, 'disk', 'local')
              .having((e) => e.path, 'path', 'notes/missing.txt'),
        ),
      );
    });

    test('decodes JSON into models with model decoders', () async {
      await local.putJson('orders.json', [Order(1), Order(2)]);
      final List<Order>? orders = await local.json<List<Order>>(
        'orders.json',
        modelDecoders: orderDecoders,
      );
      expect(orders!.map((o) => o.id), [1, 2]);

      await local.putJson('order.json', Order(7));
      final Order? order = await local.json<Order>(
        'order.json',
        modelDecoders: orderDecoders,
      );
      expect(order!.id, 7);

      await local.putJson('nothing.json', null);
      expect(await local.json<Map<String, dynamic>>('nothing.json'), isNull);
      expect(await local.json<dynamic>('orders.json'), [
        {'id': 1},
        {'id': 2},
      ]);
    });

    test('reports invalid JSON and non-UTF-8 text as disk errors', () async {
      await local.put('broken.json', '{"a":');
      await expectLater(
        local.json<Map<String, dynamic>>('broken.json'),
        throwsA(
          isA<DiskException>()
              .having((e) => e.message, 'message', 'The file is not valid JSON')
              .having((e) => e.cause, 'cause', isA<FormatException>()),
        ),
      );
      await local.put('binary.bin', Uint8List.fromList([0xFF, 0xFE, 0xC0]));
      await expectLater(local.get('binary.bin'), throwsA(isA<DiskException>()));
    });

    test('refuses contents it cannot write', () async {
      expect(() => local.put('a.txt', 42), throwsArgumentError);
      expect(() => local.delete(42), throwsArgumentError);
    });

    test('wraps file system failures with the disk and path', () async {
      await local.put('taken', 'a file');
      await expectLater(
        local.put('taken/child.txt', 'x'),
        throwsA(
          isA<DiskException>()
              .having((e) => e.disk, 'disk', 'local')
              .having((e) => e.path, 'path', 'taken/child.txt')
              .having((e) => e.cause, 'cause', isA<FileSystemException>()),
        ),
      );
    });
  });

  group('putFile', () {
    test('takes a File, a path, an XFile or bytes', () async {
      final File source = File('${root.path}/source.pdf')
        ..writeAsBytesSync(utf8.encode('%PDF-1.7 fake'));

      final String fromFile = await local.putFile('docs', source);
      final String fromPath = await local.putFile('docs', source.path);
      final String fromXFile = await local.putFile(
        'avatars',
        FakeFile.image('me.png'),
      );
      final String fromBytes = await local.putFile(
        'raw',
        Uint8List.fromList([1, 2, 3]),
      );

      expect(fromFile, matches(RegExp(r'^docs/[a-z0-9]{40}\.pdf$')));
      expect(fromPath, matches(RegExp(r'^docs/[a-z0-9]{40}\.pdf$')));
      expect(fromXFile, matches(RegExp(r'^avatars/[a-z0-9]{40}\.png$')));
      expect(fromBytes, matches(RegExp(r'^raw/[a-z0-9]{40}$')));
      expect(await local.get(fromFile), '%PDF-1.7 fake');
      expect(await local.bytes(fromBytes), [1, 2, 3]);
    });

    test('keeps the source extension when the type is unknown', () async {
      final File source = File('${root.path}/save.nylogame')
        ..writeAsStringSync('level 3');
      expect(
        await local.putFile('saves', source),
        matches(RegExp(r'^saves/[a-z0-9]{40}\.nylogame$')),
      );
    });

    test('putFileAs needs a name and normalizes it', () async {
      expect(
        await local.putFileAs('avatars', FakeFile.image('x.png'), '/42.png'),
        'avatars/42.png',
      );
      expect(
        () => local.putFileAs('avatars', FakeFile.image('x.png'), ''),
        throwsArgumentError,
      );
      expect(() => local.putFile('avatars', Object()), throwsArgumentError);
    });

    test('streams large files instead of loading them', () async {
      final File big = File('${root.path}/video.mp4');
      final IOSink sink = big.openWrite();
      for (int i = 0; i < 64; i++) {
        sink.add(Uint8List(64 * 1024));
      }
      await sink.close();
      final String stored = await local.putFileAs('videos', big, 'clip.mp4');
      expect(await local.size(stored), 64 * 64 * 1024);
    });
  });

  group('metadata', () {
    test('sniffs the MIME type from content, then the extension', () async {
      await local.put('photo', await FakeFile.image('p.png').readAsBytes());
      expect(await local.mimeType('photo'), 'image/png');
      await local.put('notes.md', '# hi');
      expect(await local.mimeType('notes.md'), 'text/markdown');
      await local.put('mystery', 'x');
      expect(await local.mimeType('mystery'), isNull);
    });

    test('rejects an unknown checksum algorithm', () async {
      await local.put('a.txt', 'a');
      expect(await local.checksum('a.txt', algorithm: 'sha1'), isNotEmpty);
      await expectLater(
        local.checksum('a.txt', algorithm: 'crc32'),
        throwsArgumentError,
      );
    });

    test('gives local files a device path and a file URL', () async {
      await local.put('a/b.txt', 'b');
      final String path = await local.path('a/b.txt');
      expect(File(path).readAsStringSync(), 'b');
      expect((await local.url('a/b.txt')).toFilePath(), path);

      final Disk memory = Disk('memory', MemoryDiskDriver());
      await memory.put('a.txt', 'a');
      await expectLater(memory.path('a.txt'), throwsA(isA<DiskException>()));
      await expectLater(memory.url('a.txt'), throwsA(isA<DiskException>()));
    });
  });

  group('rules', () {
    test('a read-only disk refuses every write', () async {
      final Disk readOnly = Disk('ro', MemoryDiskDriver(), readOnly: true);
      final List<Future<Object?> Function()> writes = [
        () => readOnly.put('a', 'a'),
        () => readOnly.putJson('a', 1),
        () => readOnly.putFileAs('d', Uint8List(1), 'a'),
        () => readOnly.append('a', 'a'),
        () => readOnly.prepend('a', 'a'),
        () => readOnly.copy('a', 'b'),
        () => readOnly.move('a', 'b'),
        () => readOnly.delete('a'),
        () => readOnly.makeDirectory('d'),
        () => readOnly.deleteDirectory('d'),
        () => readOnly.prune(olderThan: Duration.zero),
        () => readOnly.download('http://127.0.0.1:1/x', 'x'),
      ];
      for (final Future<Object?> Function() write in writes) {
        await expectLater(write(), throwsA(isA<DiskReadOnlyException>()));
      }
    });

    test('a shared OS folder refuses to be emptied whole', () async {
      final Disk documents = Disk(
        'documents',
        LocalDiskDriver.at(root.path),
        protectRoot: true,
      );
      await documents.put('mine/report.pdf', 'r');
      await File('${root.path}/sqflite.db').writeAsString('someone else');

      await expectLater(
        documents.deleteDirectory(''),
        throwsA(
          isA<DiskException>().having((e) => e.disk, 'disk', 'documents'),
        ),
      );
      expect(File('${root.path}/sqflite.db').existsSync(), isTrue);
      expect(await documents.deleteDirectory('mine'), isTrue);
      expect(
        await documents.scope('mine').deleteDirectory(''),
        isFalse,
        reason: 'a scope inside it is yours to empty',
      );
    });

    test('scopes nest and keep their name', () async {
      final Disk user = local.scope('users/42');
      final Disk photos = user.scope('photos');
      await photos.put('a.jpg', 'a');
      expect(photos.name, 'local');
      expect(await local.exists('users/42/photos/a.jpg'), isTrue);
      expect(await user.allFiles(), ['photos/a.jpg']);
      await expectLater(
        photos.put('../../41/x.jpg', 'x'),
        throwsA(isA<DiskPathTraversalException>()),
      );
    });
  });

  group('between disks', () {
    test('copies and moves to another disk', () async {
      FileStorage.configure(
        disks: {
          'inbox': DiskConfig.memory(),
          'archive': DiskConfig.memory(prefix: 'archive'),
        },
      );
      final Disk inbox = FileStorage.disk('inbox');
      await inbox.put('reports/q3.csv', 'a,b');

      await inbox.copyToDisk('archive', 'reports/q3.csv');
      await inbox.moveToDisk('archive', 'reports/q3.csv', '2026/q3.csv');

      final Disk archive = FileStorage.disk('archive');
      expect(await archive.allFiles(), ['2026/q3.csv', 'reports/q3.csv']);
      expect(await inbox.missing('reports/q3.csv'), isTrue);
      await expectLater(
        inbox.copyToDisk('archive', 'reports/q3.csv'),
        throwsA(
          isA<DiskFileNotFoundException>().having(
            (e) => e.disk,
            'disk',
            'inbox',
          ),
        ),
      );
    });
  });

  group('upkeep', () {
    test('usage adds up file sizes', () async {
      await local.put('a.txt', 'aaaa');
      await local.put('b/c.txt', 'cc');
      expect(await local.usage(), 6);
    });

    test('prune deletes files older than the cutoff', () async {
      await local.put('old.txt', 'old');
      await local.put('keep/new.txt', 'new');
      File(
        '${root.path}/nylo/old.txt',
      ).setLastModifiedSync(DateTime.now().subtract(const Duration(days: 3)));

      expect(await local.prune(olderThan: const Duration(days: 1)), 1);
      expect(await local.allFiles(), ['keep/new.txt']);
    });

    test('a disk with prune set prunes itself on first use', () async {
      final File stale = File('${root.path}/tmp/stale.txt')
        ..createSync(recursive: true)
        ..writeAsStringSync('stale')
        ..setLastModifiedSync(DateTime.now().subtract(const Duration(days: 2)));
      final Disk temp = Disk(
        'temp',
        LocalDiskDriver.at(root.path),
        prefix: 'tmp',
        prune: const Duration(days: 1),
      );
      expect(stale.existsSync(), isTrue, reason: 'nothing runs until used');

      await temp.put('fresh.txt', 'fresh');
      for (int i = 0; i < 100 && stale.existsSync(); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      expect(stale.existsSync(), isFalse);
      expect(await temp.allFiles(), ['fresh.txt']);
    });
  });

  group('download', () {
    late HttpServer server;
    late String base;
    final List<String?> acceptHeaders = [];

    setUp(() async {
      acceptHeaders.clear();
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      base = 'http://${server.address.host}:${server.port}';
      server.listen((HttpRequest request) async {
        acceptHeaders.add(request.headers.value(HttpHeaders.acceptHeader));
        if (request.uri.path == '/report.pdf') {
          final Uint8List body = Uint8List.fromList(
            List<int>.generate(200 * 1024, (i) => i % 251),
          );
          request.response
            ..headers.contentType = ContentType('application', 'pdf')
            ..contentLength = body.length
            ..add(body);
        } else {
          request.response.statusCode = HttpStatus.notFound;
        }
        await request.response.close();
      });
    });
    tearDown(() => server.close(force: true));

    test('streams a URL into a local disk, with progress', () async {
      final List<int> progress = [];
      await local.download(
        '$base/report.pdf',
        'invoices/042.pdf',
        onProgress: (received, total) => progress.add(received),
      );
      expect(await local.size('invoices/042.pdf'), 200 * 1024);
      expect((await local.bytes('invoices/042.pdf'))[251], 0);
      expect(progress.last, 200 * 1024);
      expect(acceptHeaders.single, '*/*');
      expect(
        Directory(
          '${root.path}/nylo/invoices',
        ).listSync().map((e) => e.uri.pathSegments.last),
        ['042.pdf'],
        reason: 'the temp download was renamed into place',
      );
    });

    test('downloads into a memory disk too', () async {
      final Disk memory = Disk('memory', MemoryDiskDriver());
      await memory.download('$base/report.pdf', 'report.pdf');
      expect(await memory.size('report.pdf'), 200 * 1024);
    });

    test('a failed download leaves the old file and no temp file', () async {
      await local.put('invoices/042.pdf', 'previous');
      await expectLater(
        local.download('$base/missing.pdf', 'invoices/042.pdf'),
        throwsA(
          isA<DiskException>()
              .having((e) => e.path, 'path', 'invoices/042.pdf')
              .having((e) => e.cause, 'cause', isA<DioException>()),
        ),
      );
      expect(await local.get('invoices/042.pdf'), 'previous');
      expect(
        Directory(
          '${root.path}/nylo/invoices',
        ).listSync().map((e) => e.uri.pathSegments.last),
        ['042.pdf'],
      );
    });
  });
}
