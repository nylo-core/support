import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/live/ny_live.dart';
import 'package:nylo_support/live/src/seed_recorder.dart';
import 'package:nylo_support/local_storage/ny_local_storage.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/providers/ny_providers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

EnvGetter _env(Map<String, dynamic> values) =>
    (String key, {dynamic defaultValue}) => values[key] ?? defaultValue;

class _DemoUserSeeder extends Seeder {
  @override
  String get description => 'Jane Doe, signed in, onboarding done';

  @override
  Future<void> up() async {
    await Auth.authenticate(data: {'name': 'Jane Doe', 'token': 'demo-token'});
    await saveToStorage({
      'onboarding_complete': true,
      'preferred_language': 'en',
    });
    success('Signed in as Jane Doe');
  }

  @override
  Future<void> down() async {
    await restore();
  }
}

class _FavouritesSeeder extends Seeder {
  @override
  Future<void> up() async {
    await saveToStorage({
      'favourite_ids': [101, 205],
    });
  }
}

class _DemoSeeder extends Seeder {
  @override
  String get description => 'Jane, her favourites and a basket';

  @override
  Future<void> up() async {
    await seed([_DemoUserSeeder(), _FavouritesSeeder()]);
    saveToBackpack({'basket_count': 2});
  }
}

class _BrokenSeeder extends Seeder {
  @override
  Future<void> up() async {
    await NyStorage.save('half_done', 'yes');
    Backpack.instance.save('half_done', true);
    throw StateError('API unavailable');
  }
}

class _ParentOfBrokenSeeder extends Seeder {
  @override
  Future<void> up() async {
    await NyStorage.save('parent_key', 'parent');
    await seed([_FavouritesSeeder(), _BrokenSeeder()]);
  }
}

class _FlakyParentSeeder extends Seeder {
  static bool fail = false;

  @override
  Future<void> up() async {
    await seed([_FavouritesSeeder()]);
    await NyStorage.save('flaky_key', 'yes');
    if (fail) throw StateError('flaky failure');
  }
}

class _OrderHistorySeeder extends Seeder {
  static final List<String> calls = [];

  @override
  Future<void> up() async => NyStorage.saveJson('test_order_ids', [1, 2, 3]);

  @override
  Future<void> down() async {
    final List<dynamic>? ids = await NyStorage.readJson('test_order_ids');
    calls.add('deleted orders $ids');
    await restore();
  }
}

class _ForgetfulSeeder extends Seeder {
  @override
  Future<void> up() async => NyStorage.save('forgotten', 'still here');

  @override
  Future<void> down() async {}
}

class _GatedSeeder extends Seeder {
  static Completer<void> gate = Completer<void>();

  @override
  Future<void> up() async {
    await NyStorage.save('inside', 1);
    await gate.future;
  }
}

class _SeedDemoCommand extends LiveCommand {
  @override
  Future<void> handle(CommandResult result) async {
    info('Seeding the demo');
    await seed([_DemoUserSeeder(), _FavouritesSeeder()]);
  }
}

class _SeedBrokenCommand extends LiveCommand {
  @override
  Future<void> handle(CommandResult result) => seed([_BrokenSeeder()]);
}

Future<void> _boot() async {
  await Nylo.init(
    env: _env({'APP_NAME': 'Seeder Test'}),
    setup: BootConfig(
      setup: () async {
        final Nylo nylo = Nylo();
        nylo.addAuthKey('SK_USER');
        nylo.addSeeders({
          'demo_user': _DemoUserSeeder.new,
          'favourites': _FavouritesSeeder.new,
          'demo': _DemoSeeder.new,
          'broken': _BrokenSeeder.new,
          'parent_of_broken': _ParentOfBrokenSeeder.new,
          'order_history': _OrderHistorySeeder.new,
          'forgetful': _ForgetfulSeeder.new,
        });
        nylo.addLiveCommands({
          'demo:seed_demo': () => _SeedDemoCommand(),
          'demo:seed_broken': () => _SeedBrokenCommand(),
        });
        return nylo;
      },
      boot: (Nylo nylo) async {},
    ),
  );
}

Future<String?> _raw(String key) => NyStorage.manager().read(key: key);

Future<Map<String, dynamic>> _records() async {
  final String? raw = await _raw(SeedRecorder.recordKey);
  return raw == null ? {} : Map<String, dynamic>.from(jsonDecode(raw));
}

/// The change lines of [run], e.g. `storage SK_USER added`.
List<String> _changes(SeedRun run) => [
  for (final Map<String, String> entry in run.log)
    if (entry['level'] == 'change') entry['message']!,
];

List<String> _messages(SeedRun run) => [
  for (final Map<String, String> entry in run.log)
    if (entry['level'] != 'change') '${entry['level']}: ${entry['message']}',
];

Future<SeedRun> _up(Seeder seeder, {bool fresh = false}) async =>
    (await SeedRecorder.upAll([seeder], fresh: fresh)).single;

Future<SeedRun> _down(Seeder seeder) async =>
    (await SeedRecorder.downAll([seeder])).single;

void main() {
  NyTest.init();

  setUp(() async {
    Nylo.isTestMode = true;
    await _boot();
  });

  tearDown(() async {
    SeedRecorder.forgetBackpackValues();
    _OrderHistorySeeder.calls.clear();
    _FlakyParentSeeder.fail = false;
    await NyStorage.deleteAll(andFromBackpack: true);
  });

  nyGroup('recording', () {
    nyTest('records what up() adds and changes, in order', () async {
      await NyStorage.save('preferred_language', 'fr');

      final SeedRun run = await _up(_DemoUserSeeder());

      expect(run.failed, isFalse);
      expect(run.name, 'demo_user');
      expect(_changes(run), [
        'backpack SK_USER added',
        'storage SK_USER added',
        'storage onboarding_complete added',
        'storage preferred_language changed',
      ]);
      expect(_messages(run), ['success: Signed in as Jane Doe']);
      expect(run.log.last['message'], 'Signed in as Jane Doe');

      final Map<String, dynamic> record = (await _records())['demo_user'];
      expect(DateTime.tryParse(record['seededAt']), isNotNull);
      expect(record['steps'], [
        {'backpack': 'SK_USER', 'existed': false},
        {'storage': 'SK_USER', 'before': null},
        {'storage': 'onboarding_complete', 'before': null},
        {'storage': 'preferred_language', 'before': isA<String>()},
      ]);
    });

    nyTest('down puts every value back exactly', () async {
      await NyStorage.save('preferred_language', 'fr');
      final String? french = await _raw('preferred_language');

      await _up(_DemoUserSeeder());
      expect(await Auth.isAuthenticated(), isTrue);

      final SeedRun run = await _down(_DemoUserSeeder());

      expect(run.failed, isFalse);
      expect(run.direction, 'down');
      expect(_changes(run), [
        'storage preferred_language put back',
        'storage onboarding_complete removed',
        'storage SK_USER removed',
        'backpack SK_USER removed',
      ]);
      expect(await _raw('preferred_language'), french);
      expect(await _raw('onboarding_complete'), isNull);
      expect(await Auth.isAuthenticated(), isFalse);
      expect(Backpack.instance.contains('SK_USER'), isFalse);
      expect(await _records(), isEmpty);
    });

    nyTest('records only the first change to a key', () async {
      await NyStorage.save('counter', 0);
      final String? before = await _raw('counter');

      final SeedRun run = await _up(
        _ClosureSeeder(() async {
          await NyStorage.save('counter', 1);
          await NyStorage.delete('counter');
          await NyStorage.save('counter', 3);
        }),
      );

      expect(_changes(run), ['storage counter changed']);
      expect((await _records()).values.single['steps'], hasLength(1));

      await SeedRecorder.downAll([_ClosureSeeder(() async {})]);
      expect(await _raw('counter'), before);
    });

    nyTest('leaves out keys that end up unchanged', () async {
      await NyStorage.save('theme', 'dark');

      final SeedRun run = await _up(
        _ClosureSeeder(() async {
          await NyStorage.save('theme', 'light');
          await NyStorage.save('theme', 'dark');
        }),
      );

      expect(_changes(run), isEmpty);
    });

    nyTest('puts back values saved with an expiry exactly', () async {
      await NyStorage.saveWithExpiry(
        'promo',
        'SPRING',
        ttl: const Duration(hours: 1),
      );
      final String? before = await _raw('promo');

      await _up(_ClosureSeeder(() => NyStorage.save('promo', 'SUMMER')));
      await _down(_ClosureSeeder(() async {}));

      expect(await _raw('promo'), before);
      expect(await NyStorage.getTimeToLive('promo'), isNotNull);
    });

    nyTest('ignores writes made outside the seeder while it runs', () async {
      _GatedSeeder.gate = Completer<void>();
      final Future<List<SeedRun>> running = SeedRecorder.upAll([
        _GatedSeeder(),
      ]);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await NyStorage.save('outside', 1);
      _GatedSeeder.gate.complete();

      final SeedRun run = (await running).single;

      expect(_changes(run), ['storage inside added']);
      await _down(_GatedSeeder());
      expect(await NyStorage.read('outside'), 1);
      expect(await NyStorage.read('inside'), isNull);
    });

    nyTest('records Backpack sessions and changes made in place', () async {
      Backpack.instance.sessionUpdate('cart', 'items', 1);

      final SeedRun run = await _up(
        _ClosureSeeder(() async {
          Backpack.instance.sessionUpdate('cart', 'items', 5);
          Backpack.instance.save('coupon', 'SAVE10');
        }),
      );

      expect(_changes(run), ['backpack cart changed', 'backpack coupon added']);

      await _down(_ClosureSeeder(() async {}));
      expect(Backpack.instance.sessionGet('cart', 'items'), 1);
      expect(Backpack.instance.contains('coupon'), isFalse);
    });

    nyTest('restore() works outside down()', () async {
      await _up(_FavouritesSeeder());

      await _FavouritesSeeder().restore();

      expect(await _raw('favourite_ids'), isNull);
      expect(await _records(), isEmpty);
    });
  });

  nyGroup('failures', () {
    nyTest('puts back what up() changed before it threw', () async {
      final SeedRun run = await _up(_BrokenSeeder());

      expect(run.failed, isTrue);
      expect(run.error, contains('API unavailable'));
      expect(_messages(run), [
        'error: Bad state: API unavailable',
        'info: Put back the 2 changes made before the error',
      ]);
      expect(await _raw('half_done'), isNull);
      expect(Backpack.instance.contains('half_done'), isFalse);
      expect(await _records(), isEmpty);
    });

    nyTest(
      'down() that skips restore() leaves values and forgets the run',
      () async {
        await _up(_ForgetfulSeeder());

        final SeedRun run = await _down(_ForgetfulSeeder());

        expect(run.failed, isFalse);
        expect(_messages(run).single, contains('didn\'t call restore()'));
        expect(await NyStorage.read('forgotten'), 'still here');
        expect(await _records(), isEmpty);
      },
    );

    nyTest('a custom down() runs before restore()', () async {
      await _up(_OrderHistorySeeder());

      await _down(_OrderHistorySeeder());

      expect(_OrderHistorySeeder.calls, ['deleted orders [1, 2, 3]']);
      expect(await _raw('test_order_ids'), isNull);
    });

    nyTest('says so when rolling back something that wasn\'t seeded', () async {
      final SeedRun run = await _down(_DemoUserSeeder());

      expect(run.failed, isFalse);
      expect(_messages(run).single, contains('hasn\'t been seeded'));
    });
  });

  nyGroup('seeders inside seeders', () {
    nyTest('rolls children back with the parent, newest first', () async {
      final SeedRun run = await _up(_DemoSeeder());

      expect(_changes(run), [
        'backpack SK_USER added',
        'storage SK_USER added',
        'storage onboarding_complete added',
        'storage preferred_language added',
        'storage favourite_ids added',
        'backpack basket_count added',
      ]);
      final Map<String, dynamic> records = await _records();
      expect(records.keys, containsAll(['demo', 'demo_user', 'favourites']));
      expect(records['demo']['steps'], [
        {'seeder': 'demo_user'},
        {'seeder': 'favourites'},
        {'backpack': 'basket_count', 'existed': false},
      ]);

      final SeedRun down = await _down(_DemoSeeder());

      expect(_changes(down), [
        'backpack basket_count removed',
        'storage favourite_ids removed',
        'storage preferred_language removed',
        'storage onboarding_complete removed',
        'storage SK_USER removed',
        'backpack SK_USER removed',
      ]);
      expect(await _records(), isEmpty);
      expect(Backpack.instance.contains('basket_count'), isFalse);
    });

    nyTest(
      'a failing child fails the parent and puts everything back',
      () async {
        final SeedRun run = await _up(_ParentOfBrokenSeeder());

        expect(run.failed, isTrue);
        expect(run.error, 'broken failed: Bad state: API unavailable');
        expect(await _raw('parent_key'), isNull);
        expect(await _raw('favourite_ids'), isNull);
        expect(await _raw('half_done'), isNull);
        expect(await _records(), isEmpty);
      },
    );
  });

  nyGroup('fresh and seeding again', () {
    nyTest(
      'fresh clears storage and Backpack, and down brings them back',
      () async {
        await NyStorage.save('existing', 'keep me');
        Backpack.instance.save('in_memory', 42);

        final SeedRun run = await _up(_FavouritesSeeder(), fresh: true);

        expect(await NyStorage.read('existing'), isNull);
        expect(Backpack.instance.contains('in_memory'), isFalse);
        expect(Backpack.instance.contains('nylo'), isTrue);
        expect(
          _changes(run),
          containsAll([
            'storage existing removed',
            'backpack in_memory removed',
            'storage favourite_ids added',
          ]),
        );

        await _down(_FavouritesSeeder());

        expect(await NyStorage.read('existing'), 'keep me');
        expect(Backpack.instance.read('in_memory'), 42);
        expect(await _raw('favourite_ids'), isNull);
      },
    );

    nyTest(
      'seeding again only runs up(), and down returns to before the first run',
      () async {
        await NyStorage.save('preferred_language', 'fr');
        final String? french = await _raw('preferred_language');

        await _up(_DemoUserSeeder());
        await NyStorage.save('preferred_language', 'de');
        final SeedRun again = await _up(_DemoUserSeeder());

        expect(again.failed, isFalse);
        expect(_messages(again), ['success: Signed in as Jane Doe']);
        expect(_changes(again), ['storage preferred_language changed']);
        final List steps = (await _records())['demo_user']['steps'];
        expect(steps, hasLength(4));
        expect(steps.last, {'storage': 'preferred_language', 'before': french});

        await _down(_DemoUserSeeder());

        expect(await _raw('preferred_language'), french);
        expect(await _raw('onboarding_complete'), isNull);
        expect(await Auth.isAuthenticated(), isFalse);
        expect(await _records(), isEmpty);
      },
    );

    nyTest('down also puts back keys only a later run changed', () async {
      await _up(_ClosureSeeder(() => NyStorage.save('first_key', 1)));
      await _up(_ClosureSeeder(() => NyStorage.save('second_key', 2)));

      expect((await _records()).values.single['steps'], [
        {'storage': 'first_key', 'before': null},
        {'storage': 'second_key', 'before': null},
      ]);

      await _down(_ClosureSeeder(() async {}));

      expect(await _raw('first_key'), isNull);
      expect(await _raw('second_key'), isNull);
      expect(await _records(), isEmpty);
    });

    nyTest('a failed seed keeps the earlier run and its values', () async {
      await _up(_ClosureSeeder(() => NyStorage.save('counter', 1)));
      final String? seeded = await _raw('counter');

      final SeedRun failed = await _up(
        _ClosureSeeder(() async {
          await NyStorage.save('counter', 2);
          await NyStorage.save('extra', 'x');
          throw StateError('boom');
        }),
      );

      expect(failed.failed, isTrue);
      expect(await _raw('counter'), seeded);
      expect(await _raw('extra'), isNull);
      expect((await _records()).values.single['steps'], [
        {'storage': 'counter', 'before': null},
      ]);

      await _down(_ClosureSeeder(() async {}));
      expect(await _raw('counter'), isNull);
    });

    nyTest('seeding a parent again rolls back in one go', () async {
      await _up(_DemoSeeder());
      final SeedRun again = await _up(_DemoSeeder());

      expect(again.failed, isFalse);
      expect((await _records())['demo']['steps'], [
        {'seeder': 'demo_user'},
        {'seeder': 'favourites'},
        {'backpack': 'basket_count', 'existed': false},
      ]);

      await _down(_DemoSeeder());

      expect(await _raw('favourite_ids'), isNull);
      expect(await _raw('onboarding_complete'), isNull);
      expect(Backpack.instance.contains('basket_count'), isFalse);
      expect(await _records(), isEmpty);
    });

    nyTest(
      'a failing parent only undoes what its children changed in that run',
      () async {
        await _up(_FavouritesSeeder());
        final String? favourites = await _raw('favourite_ids');

        _FlakyParentSeeder.fail = true;
        final SeedRun run = await _up(_FlakyParentSeeder());

        expect(run.failed, isTrue);
        expect(await _raw('flaky_key'), isNull);
        expect(await _raw('favourite_ids'), favourites);
        expect((await _records()).keys, ['favourites']);

        await _down(_FavouritesSeeder());
        expect(await _raw('favourite_ids'), isNull);
        expect(await _records(), isEmpty);
      },
    );
  });

  nyGroup('after a restart', () {
    nyTest('reloads Backpack from storage and warns about the rest', () async {
      await Auth.authenticate(data: {'name': 'Real Developer'});
      Backpack.instance.save('feature_flag', 'on');

      await _up(
        _ClosureSeeder(() async {
          await Auth.authenticate(data: {'name': 'Jane Doe'});
          Backpack.instance.save('feature_flag', 'off');
          Backpack.instance.save('new_in_memory', true);
        }),
      );
      SeedRecorder.forgetBackpackValues();

      final SeedRun run = await _down(_ClosureSeeder(() async {}));

      expect(Auth.data()['name'], 'Real Developer');
      expect(Backpack.instance.contains('new_in_memory'), isFalse);
      expect(Backpack.instance.read('feature_flag'), 'off');
      expect(
        _messages(run),
        contains(contains('Couldn\'t put back Backpack "feature_flag"')),
      );
    });
  });

  nyGroup('seeders.list and seeders.run', () {
    nyTest('lists seeders with descriptions and when they ran', () async {
      await NyLive.dispatch('seeders.run', {
        'names': ['demo_user'],
      });

      final Map payload = (await NyLive.dispatch('seeders.list')) as Map;
      final List seeders = payload['seeders'];

      expect(seeders.first, {
        'name': 'demo_user',
        'description': 'Jane Doe, signed in, onboarding done',
        'seededAt': isA<String>(),
        'registered': true,
      });
      expect(
        seeders.firstWhere((seeder) => seeder['name'] == 'favourites'),
        containsPair('seededAt', null),
      );
    });

    nyTest('runs seeders by name or class name', () async {
      final Map payload =
          (await NyLive.dispatch('seeders.run', {
                'names': ['DemoUserSeeder', 'favourites'],
              }))
              as Map;

      expect(payload['failed'], isFalse);
      expect((payload['runs'] as List).map((run) => run['name']), [
        'demo_user',
        'favourites',
      ]);
      expect((payload['runs'] as List).first['log'], isNotEmpty);
      expect(() => jsonEncode(payload), returnsNormally);

      final Map down =
          (await NyLive.dispatch('seeders.run', {
                'names': ['demo_user', 'favourites'],
                'direction': 'down',
              }))
              as Map;
      expect((down['runs'] as List).map((run) => run['name']), [
        'favourites',
        'demo_user',
      ]);
      expect(await _records(), isEmpty);
    });

    nyTest('runs only up or down', () async {
      await expectLater(
        NyLive.dispatch('seeders.run', {
          'names': ['favourites'],
          'direction': 'refresh',
        }),
        throwsA(
          isA<LiveException>().having(
            (e) => e.message,
            'message',
            contains('up or down'),
          ),
        ),
      );
    });

    nyTest('rejects unknown names and fresh when rolling back', () async {
      await expectLater(
        NyLive.dispatch('seeders.run', {
          'names': ['ghost'],
        }),
        throwsA(
          isA<LiveException>().having(
            (e) => e.message,
            'message',
            allOf(contains('metro make:seeder ghost'), contains('demo_user')),
          ),
        ),
      );
      await expectLater(
        NyLive.dispatch('seeders.run', {
          'names': ['demo_user'],
          'direction': 'down',
          'fresh': true,
        }),
        throwsA(isA<LiveException>()),
      );
      await expectLater(
        NyLive.dispatch('seeders.run', {'names': []}),
        throwsA(isA<LiveException>()),
      );
    });

    nyTest('reports failures without throwing', () async {
      final Map payload =
          (await NyLive.dispatch('seeders.run', {
                'names': ['broken'],
              }))
              as Map;

      expect(payload['failed'], isTrue);
      expect(
        (payload['runs'] as List).single['error'],
        'Bad state: API unavailable',
      );
    });

    nyTest('status lists seeders and storage hides the record', () async {
      await NyLive.dispatch('seeders.run', {
        'names': ['favourites'],
      });

      final Map status = (await NyLive.dispatch('status')) as Map;
      expect(status['seeders'], contains('demo_user'));

      final Map storage = (await NyLive.dispatch('storage.list')) as Map;
      expect(
        (storage['items'] as List).map((item) => item['key']),
        isNot(contains(SeedRecorder.recordKey)),
      );
    });

    nyTest('seeding is debug only, listing works in profile builds', () async {
      NyLive.debugBuildOverride = false;
      addTearDown(() => NyLive.debugBuildOverride = null);

      expect(await NyLive.dispatch('seeders.list'), isA<Map>());
      await expectLater(
        NyLive.dispatch('seeders.run', {
          'names': ['demo_user'],
        }),
        throwsA(isA<LiveException>()),
      );
    });
  });

  nyGroup('LiveCommand.seed', () {
    nyTest('shows what the seeders changed in the command output', () async {
      final Map payload =
          (await NyLive.dispatch('commands.run', {'name': 'demo:seed_demo'}))
              as Map;

      expect(payload['failed'], isFalse);
      final List<String> lines = [
        for (final Map line in payload['output'] as List)
          '${line['level']}: ${line['message']}',
      ];
      expect(lines.first, 'info: Seeding the demo');
      expect(lines, contains('change: storage SK_USER added'));
      expect(lines, anyElement(startsWith('success: Seeded demo_user in ')));
      expect((await _records()).keys, containsAll(['demo_user', 'favourites']));
    });

    nyTest('fails the command when a seeder fails', () async {
      final Map payload =
          (await NyLive.dispatch('commands.run', {'name': 'demo:seed_broken'}))
              as Map;

      expect(payload['failed'], isTrue);
      expect(
        (payload['output'] as List).last['message'],
        'broken failed: Bad state: API unavailable',
      );
    });
  });

  nyGroup('names', () {
    nyTest('come from the registry, or the class name', () async {
      expect(SeedRecorder.nameOf(_DemoUserSeeder()), 'demo_user');
      expect(SeedRecorder.nameOf(_ClosureSeeder(() async {})), '_closure');
      expect(SeedRecorder.nameFromClass('DemoUserSeeder'), 'demo_user');
      expect(SeedRecorder.nameFromClass('APIUserSeeder'), 'api_user');
      expect(SeedRecorder.nameFromClass('demo-user'), 'demo_user');
      expect(SeedRecorder.nameFromClass('Seeder'), 'seeder');
    });
  });
}

/// A seeder whose up() runs [body]; every instance shares one name.
class _ClosureSeeder extends Seeder {
  _ClosureSeeder(this.body);

  final Future<void> Function() body;

  @override
  Future<void> up() => body();
}
