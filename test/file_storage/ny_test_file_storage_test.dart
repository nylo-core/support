import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/file_storage/ny_file_storage.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  test('NyTest.init puts every writable disk in memory', () async {
    expect(disk('local'), isA<FakeDisk>());
    expect(disk('documents'), isA<FakeDisk>());
    expect(disk('cache'), isA<FakeDisk>());
    expect(disk('temp'), isA<FakeDisk>());
    expect(disk('assets'), isNot(isA<FakeDisk>()));

    await disk().put('drafts/post.md', '# hi');
    (disk() as FakeDisk).assertExists('drafts/post.md');
  });

  test('each test starts with empty disks', () async {
    expect(await disk().exists('drafts/post.md'), isFalse);
  });

  testWidgets('faked disks work inside testWidgets', (tester) async {
    final FakeDisk local = FileStorage.fake('local');
    await disk('local').putFile('avatars', FakeFile.image('me.png'));
    local.assertCount('avatars', 1);
  });

  test('NyTest.dump lists the files on faked disks', () async {
    await disk('cache').put('thumbs/1.jpg', 'x');
    final List<String> lines = [];
    runZoned(
      NyTest.dump,
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) => lines.add(line),
      ),
    );
    expect(lines, contains('║ Faked Disks: 1'));
    expect(lines, contains('║   - cache: 1 files'));
    expect(lines, contains('║       thumbs/1.jpg'));
  });
}
