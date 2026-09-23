import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/live/ny_live.dart';
import 'package:nylo_support/live/src/seed_recorder.dart';
import 'package:nylo_support/live/src/storage_snapshot.dart';
import 'package:nylo_support/local_storage/ny_local_storage.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/providers/ny_providers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

EnvGetter _env(Map<String, dynamic> values) =>
    (String key, {dynamic defaultValue}) => values[key] ?? defaultValue;

/// The storage docs' model, declared the boilerplate way.
class User extends Model {
  static const String key = 'user';
  String? name;
  String? email;
  User() : super(key: key);
  User.fromJson(dynamic data) : super(key: key) {
    name = data['name'];
    email = data['email'];
  }
  @override
  Map<String, dynamic> toJson() => {'name': name, 'email': email};
}

class Order extends Model {
  static const String key = 'orders';
  int? id;
  Order({this.id}) : super(key: key);
  Order.fromJson(dynamic data) : id = data['id'], super(key: key);
  @override
  Map<String, dynamic> toJson() => {'id': id};
}

/// A class an app registers a decoder for without extending [Model], the way
/// a generated API resource usually looks.
class UserResource {
  UserResource({this.id, this.name});
  UserResource.fromJson(dynamic data) : id = data['id'], name = data['name'];
  final int? id;
  final String? name;
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

/// A class the app never registered, so a snapshot has no way to rebuild it.
class Unregistered {
  Map<String, dynamic> toJson() => {'a': 1};
}

/// What `export exported` in `metro live` would generate.
class _ExportedSeeder extends Seeder {
  @override
  String get description => 'Onboarded Pro user';

  @override
  Future<void> up() async {
    final int count = await importSnapshot(snapshot);
    success('Imported $count values');
  }

  static const Map<String, Object?> snapshot = {
    'storage': {
      'Pro': true,
      'onboarding_complete': true,
      'user_name': 'Dummy User(s)',
      'coins': 12,
      'user': {
        'type': 'model',
        'value': {'name': 'Anthony', 'email': 'anthony@example.com'},
      },
    },
    'backpack': {
      'cart': [
        {'id': 9, 'qty': 2},
      ],
    },
  };
}

class _NamedSeeder extends Seeder {
  @override
  String? get name => 'custom_name';

  @override
  Future<void> up() async {}
}

class _PlainSeeder extends Seeder {
  @override
  Future<void> up() async {}
}

Future<void> _boot() async {
  await Nylo.init(
    env: _env({'APP_NAME': 'Snapshot Test', 'APP_ENV': 'testing'}),
    setup: BootConfig(
      setup: () async {
        final Nylo nylo = Nylo();
        nylo.addAuthKey('SK_USER');
        nylo.addModelDecoders({
          User: (dynamic data) => User.fromJson(data),
          Order: (dynamic data) => Order.fromJson(data),
          List<Order>: (dynamic data) => [
            for (final dynamic item in data) Order.fromJson(item),
          ],
          UserResource: (dynamic data) => UserResource.fromJson(data),
        });
        nylo.addSeeders({'exported': _ExportedSeeder.new});
        return nylo;
      },
      boot: (Nylo nylo) async {},
    ),
  );
}

Future<String?> _raw(String key) => NyStorage.manager().read(key: key);

Future<Map<String, String>> _allRaw() async {
  final Map<String, String> all = await NyStorage.manager().readAll();
  all.remove(SeedRecorder.recordKey);
  return all;
}

Future<Map<String, dynamic>> _records() async {
  final String? raw = await _raw(SeedRecorder.recordKey);
  return raw == null ? {} : Map<String, dynamic>.from(jsonDecode(raw));
}

List<String> _changes(SeedRun run) => [
  for (final Map<String, String> entry in run.log)
    if (entry['level'] == 'change') entry['message']!,
];

/// [snapshot] after a trip through a JSON file.
StorageSnapshot _viaJson(StorageSnapshot snapshot) => StorageSnapshot.fromJson(
  Map<String, Object?>.from(jsonDecode(jsonEncode(snapshot.toJson()))),
);

Matcher _invalidParams(Object message) => isA<LiveException>()
    .having((e) => e.code, 'code', LiveException.invalidParamsCode)
    .having((e) => e.message, 'message', message);

void main() {
  NyTest.init();

  setUp(() async {
    Nylo.isTestMode = true;
    await _boot();
  });

  tearDown(() async {
    SeedRecorder.forgetBackpackValues();
    NyLive.debugBuildOverride = null;
    await NyStorage.deleteAll(andFromBackpack: true);
  });

  nyGroup('StorageSnapshot.capture', () {
    nyTest('writes plain literals where Dart\'s type is enough', () async {
      await NyStorage.save('count', 7);
      await NyStorage.save('ratio', 1.5);
      await NyStorage.save('name', 'Jane');
      await NyStorage.save('flag', true);
      await NyStorage.save('nothing', null);
      await NyStorage.saveJson('prefs', {'dark': true, 'size': 12});
      await NyStorage.saveJson('ids', [1, 2]);

      final StorageSnapshot snapshot = await StorageSnapshot.capture();

      expect(snapshot.storage, {
        'count': 7,
        'ratio': 1.5,
        'name': 'Jane',
        'flag': true,
        'nothing': null,
        'prefs': {'dark': true, 'size': 12},
        'ids': [1, 2],
      });
      expect(snapshot.storage.containsKey('nothing'), isTrue);
      expect(snapshot.skipped, isEmpty);
    });

    nyTest(
      'tags models, raw values, expiring values and look-alikes',
      () async {
        await NyStorage.save('user', User()..name = 'Jane');
        await NyStorage.manager().write(
          key: 'ny_theme_id',
          value: 'dark_theme',
        );
        await NyStorage.saveWithExpiry(
          'session_hint',
          'abc',
          ttl: const Duration(hours: 1),
        );
        await NyStorage.saveWithExpiry(
          'gone',
          'expired',
          ttl: const Duration(milliseconds: 1),
        );
        await NyStorage.saveJson('looks_tagged', {'type': 'car', 'value': 3});
        await Future<void>.delayed(const Duration(milliseconds: 5));

        final StorageSnapshot snapshot = await StorageSnapshot.capture();

        expect(snapshot.storage['user'], {
          'type': 'model',
          'value': {'name': 'Jane', 'email': null},
        });
        expect(snapshot.storage['ny_theme_id'], {
          'type': 'raw',
          'value': 'dark_theme',
        });
        final Map<Object?, Object?> hint =
            snapshot.storage['session_hint'] as Map;
        expect(hint['type'], 'string');
        expect(hint['value'], 'abc');
        expect(hint['ttl'], inInclusiveRange(3590, 3600));
        expect(snapshot.storage['looks_tagged'], {
          'type': 'json',
          'value': {'type': 'car', 'value': 3},
        });
        expect(snapshot.storage.containsKey('gone'), isFalse);
        expect(snapshot.skipped, [
          {'store': 'storage', 'key': 'gone', 'reason': 'expired'},
        ]);
      },
    );

    nyTest('falls back to raw for envelopes it can\'t read', () async {
      const String badJson = '{"_v":"v1","_t":"json","_d":"{not json"}';
      const String oddType =
          '{"_v":"v1","_t":"_Map<String, dynamic>","_d":"x"}';
      await NyStorage.manager().write(key: 'bad', value: badJson);
      await NyStorage.manager().write(key: 'odd', value: oddType);

      final StorageSnapshot snapshot = await StorageSnapshot.capture();

      expect(snapshot.storage['bad'], {'type': 'raw', 'value': badJson});
      expect(snapshot.storage['odd'], {'type': 'raw', 'value': oddType});
    });

    nyTest(
      'leaves out the seeder record and Nylo\'s Backpack entries',
      () async {
        await SeedRecorder.upAll([_ExportedSeeder()]);
        expect(await _raw(SeedRecorder.recordKey), isNotNull);

        final StorageSnapshot snapshot = await StorageSnapshot.capture();

        expect(snapshot.storage.containsKey(SeedRecorder.recordKey), isFalse);
        expect(snapshot.backpack.containsKey('nylo'), isFalse);
        expect(snapshot.backpack.containsKey('event_bus'), isFalse);
        expect(snapshot.storage.keys, contains('Pro'));
      },
    );

    nyTest(
      'tags Backpack models by class and skips what isn\'t JSON',
      () async {
        Backpack.instance.save('me', User()..name = 'Anthony');
        Backpack.instance.save('orders', [Order(id: 1), Order(id: 2)]);
        Backpack.instance.save('cart', [
          {'id': 9},
        ]);
        Backpack.instance.save('when', DateTime.utc(2026, 9, 15));
        Backpack.instance.save('callback', () => 1);
        Backpack.instance.save('empty', null);

        final StorageSnapshot snapshot = await StorageSnapshot.capture();

        expect(snapshot.backpack, {
          'me': {
            'type': 'model',
            'model': 'User',
            'value': {'name': 'Anthony', 'email': null},
          },
          'orders': {
            'type': 'models',
            'model': 'Order',
            'value': [
              {'id': 1},
              {'id': 2},
            ],
          },
          'cart': [
            {'id': 9},
          ],
          'when': '2026-09-15T00:00:00.000Z',
          'empty': null,
        });
        expect(snapshot.skipped, [
          {
            'store': 'backpack',
            'key': 'callback',
            'reason': '() => int can\'t be written as JSON',
          },
        ]);
      },
    );

    nyTest('tags any class the app registered a decoder for', () async {
      // A class that isn't a Model still round trips through its decoder, so
      // dropping the name would leave a plain map where the app reads an
      // object.
      Backpack.instance.save('cached_user', UserResource(id: 5, name: 'Ant'));
      Backpack.instance.save('recent_users', [
        UserResource(id: 1, name: 'A'),
        UserResource(id: 2, name: 'B'),
      ]);

      final StorageSnapshot snapshot = await StorageSnapshot.capture();

      expect(snapshot.backpack['cached_user'], {
        'type': 'model',
        'model': 'UserResource',
        'value': {'id': 5, 'name': 'Ant'},
      });
      expect(snapshot.backpack['recent_users'], {
        'type': 'models',
        'model': 'UserResource',
        'value': [
          {'id': 1, 'name': 'A'},
          {'id': 2, 'name': 'B'},
        ],
      });
    });

    nyTest('writes a class it can\'t rebuild as plain JSON', () async {
      Backpack.instance.save('other', Unregistered());

      final StorageSnapshot snapshot = await StorageSnapshot.capture();

      expect(snapshot.backpack['other'], {'a': 1});
    });

    nyTest('filters both stores with only and except patterns', () async {
      await NyStorage.save('cache_a', 1);
      await NyStorage.save('cache_b', 2);
      await NyStorage.save('SK_USER', 'jane');
      Backpack.instance.save('cache_x', 3);
      Backpack.instance.save('SK_USER', 'jane');

      final StorageSnapshot except = await StorageSnapshot.capture(
        except: ['cache_*'],
      );
      expect(except.storage.keys, ['SK_USER']);
      expect(except.backpack.keys, ['SK_USER']);

      final StorageSnapshot only = await StorageSnapshot.capture(
        only: ['cache_a', 'SK_*'],
      );
      expect(only.storage.keys, ['SK_USER', 'cache_a']);
      expect(only.backpack.keys, ['SK_USER']);

      final StorageSnapshot noBackpack = await StorageSnapshot.capture(
        backpack: false,
      );
      expect(noBackpack.backpack, isEmpty);
      expect(noBackpack.storage, hasLength(3));
    });
  });

  nyGroup('StorageSnapshot.fromJson', () {
    nyTest('reads an exported seeder\'s const map', () async {
      final StorageSnapshot snapshot = StorageSnapshot.fromJson(
        _ExportedSeeder.snapshot,
      );

      expect(snapshot.length, 6);
      expect(snapshot.storage['coins'], 12);
      expect(snapshot.backpack['cart'], [
        {'id': 9, 'qty': 2},
      ]);
    });

    nyTest('accepts a missing store', () async {
      expect(StorageSnapshot.fromJson(const {}).isEmpty, isTrue);
      expect(
        StorageSnapshot.fromJson(const {
          'storage': {'a': 1},
        }).length,
        1,
      );
    });

    nyTest('rejects values that can\'t go into storage', () async {
      void rejects(Map<String, Object?> json, Object message) => expect(
        () => StorageSnapshot.fromJson(json),
        throwsA(_invalidParams(message)),
      );

      rejects({'storage': 'nope'}, contains('"storage" must be a JSON object'));
      rejects({'backpack': []}, contains('"backpack" must be a JSON object'));
      rejects({
        'storage': {
          'a': {'type': 'blob', 'value': 1},
        },
      }, contains('unknown type "blob"'));
      rejects({
        'storage': {
          'a': {'type': 'int', 'value': 'seven'},
        },
      }, contains('tagged as int but its value is a String'));
      rejects({
        'storage': {
          'a': {
            'type': 'model',
            'value': [1],
          },
        },
      }, contains('tagged as model'));
      rejects({
        'storage': {
          'a': {'type': 'raw', 'value': null},
        },
      }, contains('tagged as raw but its value is null'));
      rejects({
        'storage': {
          'a': {'type': 'string', 'value': 'x', 'ttl': 0},
        },
      }, contains('ttl'));
      rejects({
        'backpack': {
          'me': {'type': 'model', 'model': 'User', 'value': 'not a map'},
        },
      }, contains('Backpack "me" is tagged as a User model'));
    });
  });

  nyGroup('StorageSnapshot.apply', () {
    nyTest('puts a registered class back as the object', () async {
      Backpack.instance.save('cached_user', UserResource(id: 5, name: 'Ant'));
      Backpack.instance.save('recent_users', [UserResource(id: 1, name: 'A')]);

      final StorageSnapshot snapshot = _viaJson(
        await StorageSnapshot.capture(),
      );
      Backpack.instance.deleteAll();
      await snapshot.apply();

      final Object? user = Backpack.instance.read<dynamic>('cached_user');
      expect(user, isA<UserResource>());
      expect((user! as UserResource).name, 'Ant');

      final Object? users = Backpack.instance.read<dynamic>('recent_users');
      expect(users, isA<List<dynamic>>());
      expect((users! as List).single, isA<UserResource>());
    });

    nyTest('rebuilds every envelope byte for byte', () async {
      await NyStorage.save('count', 7);
      await NyStorage.save('ratio', 1.5);
      await NyStorage.save('name', 'Jane');
      await NyStorage.save('flag', true);
      await NyStorage.save('nothing', null);
      await NyStorage.saveJson('prefs', {'dark': true});
      await NyStorage.saveJson('looks_tagged', {'type': 'car', 'value': 3});
      await NyStorage.save('user', User()..name = 'Jane');
      await NyStorage.manager().write(key: 'ny_theme_id', value: 'dark_theme');
      await NyStorage.saveWithExpiry(
        'session_hint',
        'abc',
        ttl: const Duration(hours: 1),
      );
      final Map<String, String> before = await _allRaw();

      final StorageSnapshot snapshot = _viaJson(
        await StorageSnapshot.capture(),
      );
      await NyStorage.deleteAll(andFromBackpack: true);
      expect(await snapshot.apply(), 10);

      final Map<String, String> after = await _allRaw();
      for (final String key in before.keys) {
        if (key == 'session_hint') continue;
        expect(after[key], before[key], reason: key);
      }
      expect(await NyStorage.readWithExpiry<String>('session_hint'), 'abc');
      expect(
        (await NyStorage.getTimeToLive('session_hint'))!.inMinutes,
        inInclusiveRange(59, 60),
      );
      expect(await NyStorage.read<int>('count'), 7);
      expect(await NyStorage.readJson('looks_tagged'), {
        'type': 'car',
        'value': 3,
      });
    });

    nyTest('restores a signed-in user', () async {
      await Auth.authenticate(data: {'id': 1, 'name': 'Jane', 'token': 't'});
      final StorageSnapshot snapshot = _viaJson(
        await StorageSnapshot.capture(),
      );
      await NyStorage.deleteAll(andFromBackpack: true);
      expect(await Auth.isAuthenticated(), isFalse);

      await snapshot.apply();

      expect(await Auth.isAuthenticated(), isTrue);
      expect(Auth.data(field: 'name'), 'Jane');
    });

    nyTest('brings back models the way the storage docs save them', () async {
      final User user = User()
        ..name = 'Anthony'
        ..email = 'anthony@example.com';
      await user.save();
      final String? envelope = await _raw(User.key);

      final StorageSnapshot snapshot = _viaJson(
        await StorageSnapshot.capture(),
      );
      await NyStorage.deleteAll(andFromBackpack: true);
      await snapshot.apply();

      expect(await _raw(User.key), envelope);
      final User? back = await NyStorage.read<User>(User.key);
      expect(back?.name, 'Anthony');
      expect(back?.email, 'anthony@example.com');
      expect(await User().syncToBackpack(), isTrue);
      expect(Backpack.instance.read<User>(User.key)?.email, user.email);
    });

    nyTest(
      'rebuilds Backpack models as objects through the decoders',
      () async {
        await (User()
              ..name = 'Anthony'
              ..email = 'a@example.com')
            .save(inBackpack: true);
        Backpack.instance.save('orders', [Order(id: 1), Order(id: 2)]);

        final StorageSnapshot snapshot = _viaJson(
          await StorageSnapshot.capture(),
        );
        await NyStorage.deleteAll(andFromBackpack: true);
        await snapshot.apply();

        final dynamic untyped = Backpack.instance.read(User.key);
        expect(untyped, isA<User>());
        expect((untyped as User).name, 'Anthony');
        final dynamic orders = Backpack.instance.read('orders');
        expect(orders, isA<List<Object?>>());
        expect((orders as List).map((dynamic o) => (o as Order).id), [1, 2]);
      },
    );

    nyTest(
      'puts growable maps and lists in Backpack, not const ones',
      () async {
        const StorageSnapshot snapshot = StorageSnapshot(
          backpack: {
            'SK_USER': {'id': 1, 'name': 'Jane'},
            'cart': [1, 2],
            'nested': {
              'items': [
                {'id': 1},
              ],
            },
          },
        );

        await snapshot.apply();

        // The same in-place changes Nylo's session and append helpers make.
        Backpack.instance.sessionUpdate('SK_USER', 'plan', 'pro');
        expect(Backpack.instance.sessionGet('SK_USER', 'plan'), 'pro');
        Backpack.instance.append('cart', 3, append: true);
        expect(Backpack.instance.read('cart'), [1, 2, 3]);
        final Map<dynamic, dynamic> nested = Backpack.instance.read('nested');
        (nested['items'] as List).add({'id': 2});
        expect(
          (Backpack.instance.read('nested')['items'] as List),
          hasLength(2),
        );
      },
    );

    nyTest('keeps a Backpack model as a map when no decoder matches', () async {
      final StorageSnapshot snapshot = StorageSnapshot.fromJson(const {
        'backpack': {
          'ghost': {
            'type': 'model',
            'model': 'Ghost',
            'value': {'boo': true},
          },
        },
      });

      await snapshot.apply();

      expect(Backpack.instance.read('ghost'), {'boo': true});
    });

    nyTest('round-trips a model collection as typed items', () async {
      await Order(id: 1).saveToCollection();
      await Order(id: 2).saveToCollection();
      final String? envelope = await _raw(Order.key);

      final StorageSnapshot snapshot = _viaJson(
        await StorageSnapshot.capture(),
      );
      expect(snapshot.storage[Order.key], '[{"id":1},{"id":2}]');
      await NyStorage.deleteAll(andFromBackpack: true);
      await snapshot.apply();

      expect(await _raw(Order.key), envelope);
      final List<Order> orders = await NyStorage.readCollection<Order>(
        Order.key,
      );
      expect(orders.map((Order order) => order.id), [1, 2]);
    });

    nyTest(
      'never writes the seeder record or Nylo\'s Backpack entries',
      () async {
        final StorageSnapshot snapshot = StorageSnapshot.fromJson(const {
          'storage': {
            SeedRecorder.recordKey: {'type': 'raw', 'value': '{}'},
            'x': 1,
          },
          'backpack': {'nylo': 'bad', 'event_bus': 'bad', 'y': 2},
        });

        expect(await snapshot.apply(), 2);

        expect(await _raw(SeedRecorder.recordKey), isNull);
        expect(await NyStorage.read<int>('x'), 1);
        expect(Backpack.instance.isNyloInitialized(), isTrue);
        expect(Backpack.instance.read('y'), 2);
      },
    );

    nyTest('says which value can\'t be written', () async {
      final StorageSnapshot snapshot = StorageSnapshot.fromJson({
        'storage': {
          'weird': {'callback': () => 1},
        },
      });

      await expectLater(
        snapshot.apply(),
        throwsA(
          isA<LiveException>().having(
            (e) => e.message,
            'message',
            contains('Storage "weird" holds a value that can\'t be written'),
          ),
        ),
      );
    });
  });

  nyGroup('inside a seeder', () {
    nyTest(
      'importSnapshot is recorded, so rollback puts it all back',
      () async {
        await NyStorage.save('coins', 1);
        await NyStorage.save('keep_me', 'yes');
        Backpack.instance.save('cart', ['old']);
        final Map<String, String> before = await _allRaw();

        final SeedRun up = (await SeedRecorder.runNamed([
          'exported',
        ], direction: 'up')).single;

        expect(up.failed, isFalse, reason: up.error);
        expect(_changes(up), [
          'storage Pro added',
          'storage onboarding_complete added',
          'storage user_name added',
          'storage coins changed',
          'storage user added',
          'backpack cart changed',
        ]);
        expect(up.log.last['message'], 'Imported 6 values');
        expect(await NyStorage.read<int>('coins'), 12);
        expect(await NyStorage.read<String>('keep_me'), 'yes');
        expect((await NyStorage.read<User>('user'))?.name, 'Anthony');

        final SeedRun down = (await SeedRecorder.runNamed([
          'exported',
        ], direction: 'down')).single;

        expect(down.failed, isFalse, reason: down.error);
        expect(await _allRaw(), before);
        expect(Backpack.instance.read('cart'), ['old']);
      },
    );

    nyTest('SnapshotSeeder runs under its name and keeps its source', () async {
      final StorageSnapshot snapshot = StorageSnapshot.fromJson(const {
        'storage': {'Pro': true},
      });

      final SeedRun run = (await SeedRecorder.upAll([
        SnapshotSeeder(snapshot, name: 'pro_user', source: 'pro_user.json'),
      ])).single;

      expect(run.name, 'pro_user');
      expect(run.failed, isFalse, reason: run.error);
      expect(_changes(run), ['storage Pro added']);
      expect((await _records())['pro_user']['source'], 'pro_user.json');

      final List<Map<String, Object?>> list = await SeedRecorder.list();
      expect(
        list.where((entry) => entry['name'] == 'pro_user').single,
        allOf(
          containsPair('registered', false),
          containsPair('source', 'pro_user.json'),
          containsPair('seededAt', isA<String>()),
        ),
      );
      expect(
        list.where((entry) => entry['name'] == 'exported').single,
        isNot(contains('source')),
      );

      final SeedRun down = (await SeedRecorder.runNamed([
        'pro_user',
      ], direction: 'down')).single;
      expect(down.failed, isFalse, reason: down.error);
      expect(await _raw('Pro'), isNull);
      expect(await _records(), isEmpty);
    });

    nyTest(
      'fresh clears first, and rollback brings the old values back',
      () async {
        await NyStorage.save('keep_me', 'yes');
        Backpack.instance.save('cart', ['old']);
        final Map<String, String> before = await _allRaw();
        final StorageSnapshot snapshot = StorageSnapshot.fromJson(const {
          'storage': {'Pro': true},
        });

        final SeedRun run = (await SeedRecorder.upAll([
          SnapshotSeeder(snapshot, name: 'pro_user'),
        ], fresh: true)).single;

        expect(run.failed, isFalse, reason: run.error);
        expect(await _raw('keep_me'), isNull);
        expect(Backpack.instance.contains('cart'), isFalse);
        expect(await NyStorage.read<bool>('Pro'), isTrue);

        await SeedRecorder.runNamed(['pro_user'], direction: 'down');
        expect(await _allRaw(), before);
        expect(Backpack.instance.read('cart'), ['old']);
      },
    );

    nyTest('nameOf prefers the registry, then name, then the class', () async {
      expect(SeedRecorder.nameOf(_ExportedSeeder()), 'exported');
      expect(SeedRecorder.nameOf(_NamedSeeder()), 'custom_name');
      expect(SeedRecorder.nameOf(_PlainSeeder()), '_plain');
      expect(
        SeedRecorder.nameOf(
          SnapshotSeeder(const StorageSnapshot(), name: 'from_file'),
        ),
        'from_file',
      );
    });
  });

  nyGroup('built-ins', () {
    nyTest('storage.export returns the snapshot with its context', () async {
      await NyStorage.save('Pro', true);
      Backpack.instance.save('cart', [1]);
      Backpack.instance.save('callback', () => 1);

      final Map<String, Object?> payload =
          (await NyLive.dispatch('storage.export')) as Map<String, Object?>;

      expect(payload['nylo'], StorageSnapshot.formatVersion);
      expect(payload['storage'], {'Pro': true});
      expect(payload['backpack'], {
        'cart': [1],
      });
      expect(payload['skipped'], hasLength(1));
      expect(payload['app'], 'Snapshot Test');
      expect(payload['env'], 'testing');
      expect(DateTime.tryParse('${payload['exportedAt']}'), isNotNull);
      expect(payload.containsKey('route'), isTrue);
    });

    nyTest('storage.export is read-only, with filters', () async {
      NyLive.debugBuildOverride = false;
      await NyStorage.save('cache_a', 1);
      await NyStorage.save('SK_USER', 'jane');
      Backpack.instance.save('cache_x', 1);

      final Map<String, Object?> payload =
          (await NyLive.dispatch('storage.export', {
                'except': ['cache_*'],
                'backpack': false,
              }))
              as Map<String, Object?>;

      expect(payload['storage'], {'SK_USER': 'jane'});
      expect(payload['backpack'], isEmpty);
      await expectLater(
        NyLive.dispatch('storage.export', {'only': 'SK_USER'}),
        throwsA(_invalidParams(contains('"only" must be a list'))),
      );
      await expectLater(
        NyLive.dispatch('storage.export', {'backpack': 'no'}),
        throwsA(_invalidParams(contains('"backpack" must be true or false'))),
      );
    });

    nyTest('snapshot.import checks its arguments', () async {
      await expectLater(
        NyLive.dispatch('snapshot.import', {
          'snapshot': {'storage': {}},
        }),
        throwsA(_invalidParams(contains('Missing "name"'))),
      );
      await expectLater(
        NyLive.dispatch('snapshot.import', {'name': 'x', 'snapshot': []}),
        throwsA(_invalidParams(contains('"snapshot" must be a JSON object'))),
      );
      await expectLater(
        NyLive.dispatch('snapshot.import', {
          'name': 'x',
          'snapshot': {'storage': {}},
          'fresh': 'yes',
        }),
        throwsA(_invalidParams(contains('"fresh" must be true or false'))),
      );
      await expectLater(
        NyLive.dispatch('snapshot.import', {
          'name': 'x',
          'snapshot': {
            'storage': {
              'a': {'type': 'blob', 'value': 1},
            },
          },
        }),
        throwsA(_invalidParams(contains('unknown type "blob"'))),
      );
      NyLive.debugBuildOverride = false;
      await expectLater(
        NyLive.dispatch('snapshot.import', {
          'name': 'x',
          'snapshot': {'storage': {}},
        }),
        throwsA(
          isA<LiveException>().having(
            (e) => e.message,
            'message',
            contains('debug builds'),
          ),
        ),
      );
    });

    nyTest(
      'snapshot.import runs a recorded seeder named after the file',
      () async {
        await NyStorage.save('Pro', false);

        final Map<String, Object?> payload =
            (await NyLive.dispatch('snapshot.import', {
                  'name': 'pro_user',
                  'source': 'pro_user.json',
                  'snapshot': {
                    'storage': {'Pro': true, 'user_name': 'Dummy User(s)'},
                    'backpack': {
                      'cart': [1],
                    },
                  },
                }))
                as Map<String, Object?>;

        expect(payload['failed'], isFalse);
        final Map<Object?, Object?> run =
            (payload['runs'] as List).single as Map;
        expect(run['name'], 'pro_user');
        expect(run['direction'], 'up');
        final List<Object?> log = run['log'] as List;
        expect(
          log.map((entry) => (entry as Map)['message']),
          containsAll([
            'storage Pro changed',
            'storage user_name added',
            'backpack cart added',
            'Imported 3 values',
          ]),
        );
        expect(await NyStorage.read<bool>('Pro'), isTrue);

        final Map<String, Object?> list =
            (await NyLive.dispatch('seeders.list')) as Map<String, Object?>;
        expect(
          (list['seeders'] as List).cast<Map>().where(
            (Map seeder) => seeder['name'] == 'pro_user',
          ),
          [
            allOf(
              containsPair('registered', false),
              containsPair('source', 'pro_user.json'),
            ),
          ],
        );

        final Map<String, Object?> rollback =
            (await NyLive.dispatch('seeders.run', {
                  'names': ['pro_user'],
                  'direction': 'down',
                }))
                as Map<String, Object?>;
        expect(rollback['failed'], isFalse);
        expect(await NyStorage.read<bool>('Pro'), isFalse);
        expect(await _raw('user_name'), isNull);
        expect(Backpack.instance.contains('cart'), isFalse);
      },
    );

    nyTest('snapshot.import with fresh clears the app first', () async {
      await NyStorage.save('keep_me', 'yes');

      final Map<String, Object?> payload =
          (await NyLive.dispatch('snapshot.import', {
                'name': 'clean',
                'fresh': true,
                'snapshot': {
                  'storage': {'Pro': true},
                },
              }))
              as Map<String, Object?>;

      expect(payload['failed'], isFalse);
      expect(await _raw('keep_me'), isNull);
      expect(await NyStorage.read<bool>('Pro'), isTrue);

      await NyLive.dispatch('seeders.run', {
        'names': ['clean'],
        'direction': 'down',
      });
      expect(await NyStorage.read<String>('keep_me'), 'yes');
      expect(await _raw('Pro'), isNull);
    });
  });
}
