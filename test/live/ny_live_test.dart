import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/events/ny_events.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/live/ny_live.dart';
import 'package:nylo_support/local_storage/ny_local_storage.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/providers/ny_providers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

EnvGetter _env(Map<String, dynamic> values) =>
    (String key, {dynamic defaultValue}) => values[key] ?? defaultValue;

class OrderShippedEvent extends NyEvent {
  OrderShippedEvent(_RecordingListener listener) {
    listeners[_RecordingListener] = listener;
  }
}

class _RecordingListener extends NyListener {
  final List<Map?> calls = [];

  @override
  Future handle(Map? event) async => calls.add(event);
}

class _SeedCommand extends LiveCommand {
  @override
  String? get description => 'Seed sample data';

  @override
  CommandBuilder builder(CommandBuilder command) {
    command.addOption('count', defaultValue: '3');
    command.addFlag('open');
    return command;
  }

  @override
  Future<Map<String, dynamic>> handle(CommandResult result) async {
    final int count = result.getInt('count')!;
    success('Seeded $count');
    if (result.getBool('open') == true) info('Opening');
    return {'count': count, 'rest': result.rest};
  }
}

class _BrokenCommand extends LiveCommand {
  @override
  Future<void> handle(CommandResult result) async {
    info('Starting');
    throw StateError('database locked');
  }
}

Future<void> _boot({String? authKey = 'SK_USER', bool eventBus = true}) async {
  await Nylo.init(
    env: _env({'APP_NAME': 'Live Test', 'APP_ENV': 'testing'}),
    setup: BootConfig(
      setup: () async {
        final Nylo nylo = Nylo();
        if (authKey != null) nylo.addAuthKey(authKey);
        if (eventBus) nylo.addEventBus();
        nylo.addLiveCommands({
          'demo:seed': () => _SeedCommand(),
          'demo:broken': () => _BrokenCommand(),
        });
        return nylo;
      },
      boot: (Nylo nylo) async {},
    ),
  );
}

Matcher _liveError(int code, [Object? message]) => isA<LiveException>()
    .having((e) => e.code, 'code', code)
    .having((e) => e.message, 'message', message ?? anything);

void main() {
  NyTest.init();

  setUp(() async {
    Nylo.isTestMode = true;
    await _boot();
  });

  tearDown(() async {
    NyLive.debugBuildOverride = null;
    NyLive.onEmit = null;
    await NyStorage.deleteAll(andFromBackpack: true);
  });

  nyGroup('NyLive.install', () {
    nyTest('is installed by Nylo.init and stays idempotent', () async {
      NyLive.install(Nylo.instance);
      NyLive.install(Nylo.instance);

      expect(NyLive.isInstalled, isTrue);
      expect(
        Nylo.instance
            .getNavigatorObservers()
            .whereType<NyLiveNavigatorObserver>(),
        hasLength(1),
      );
    });

    nyTest('is skipped when useLive is disabled', () async {
      await Nylo.init(
        env: _env({}),
        setup: BootConfig(
          setup: () async => Nylo()..useLive(false),
          boot: (Nylo nylo) async {},
        ),
      );

      expect(
        Nylo.instance
            .getNavigatorObservers()
            .whereType<NyLiveNavigatorObserver>(),
        isEmpty,
      );
    });

    nyTest('configure registers commands and the opt-out flag', () async {
      final Nylo nylo = Nylo();
      await nylo.configure(
        liveCommands: {'demo:seed': () => _SeedCommand()},
        useLive: false,
      );

      expect(nylo.getLiveCommands().keys, ['demo:seed']);
      expect(nylo.shouldUseLive(), isFalse);
    });

    nyTest('streams log entries as nylo.log events', () async {
      final List<MapEntry<String, Map<String, Object?>>> events = [];
      NyLive.onEmit = (kind, data) => events.add(MapEntry(kind, data));

      NyLogger.info('Checkout started');

      final MapEntry<String, Map<String, Object?>> log = events.firstWhere(
        (event) => event.key == 'log',
      );
      expect(log.value['type'], 'info');
      expect(log.value['message'], 'Checkout started');
      expect(DateTime.tryParse(log.value['time'] as String), isNotNull);
    });
  });

  nyGroup('NyLive.dispatch', () {
    nyTest('rejects unknown commands', () async {
      await expectLater(
        NyLive.dispatch('storage.explode'),
        throwsA(
          _liveError(LiveException.failedCode, contains('storage.explode')),
        ),
      );
    });

    nyTest(
      'blocks commands that change the app outside debug builds',
      () async {
        NyLive.debugBuildOverride = false;

        await expectLater(
          NyLive.dispatch('storage.set', {'key': 'k', 'value': 1}),
          throwsA(
            _liveError(LiveException.failedCode, contains('debug builds')),
          ),
        );
        expect(await NyLive.dispatch('storage.list'), {'items': []});
        expect(((await NyLive.dispatch('status')) as Map)['mode'], 'profile');
      },
    );

    nyTest('decodeArgs accepts only JSON objects', () async {
      expect(NyLive.decodeArgs(null), isEmpty);
      expect(NyLive.decodeArgs('  '), isEmpty);
      expect(NyLive.decodeArgs('{"a":1}'), {'a': 1});
      expect(
        () => NyLive.decodeArgs('{nope'),
        throwsA(_liveError(LiveException.invalidParamsCode)),
      );
      expect(
        () => NyLive.decodeArgs('[1]'),
        throwsA(_liveError(LiveException.invalidParamsCode)),
      );
    });
  });

  nyGroup('NyLive.handleExtension', () {
    nyTest('wraps results in a result object', () async {
      final developer.ServiceExtensionResponse response =
          await NyLive.handleExtension('storage.set', {
            'args': jsonEncode({'key': 'coins', 'value': 10}),
          });

      expect(response.isError(), isFalse);
      expect(jsonDecode(response.result!), {
        'result': {'key': 'coins', 'type': 'int'},
      });
    });

    nyTest('maps failures to JSON-RPC error codes', () async {
      final developer.ServiceExtensionResponse invalid =
          await NyLive.handleExtension('storage.get', {});
      final developer.ServiceExtensionResponse malformed =
          await NyLive.handleExtension('status', {'args': 'not json'});
      final developer.ServiceExtensionResponse failed =
          await NyLive.handleExtension('theme.set', {
            'args': jsonEncode({'id': 'neon'}),
          });

      expect(invalid.errorCode, LiveException.invalidParamsCode);
      expect(invalid.errorDetail, 'Missing "key".');
      expect(malformed.errorCode, LiveException.invalidParamsCode);
      expect(failed.errorCode, LiveException.failedCode);
    });
  });

  nyGroup('status', () {
    nyTest('describes the running app', () async {
      final Map status = (await NyLive.dispatch('status')) as Map;

      expect(status['protocol'], 8);
      expect(status['app'], 'Live Test');
      expect(status['env'], 'testing');
      expect(status['mode'], 'debug');
      expect(status['platform'], isA<String>());
      expect(status['authenticated'], isFalse);
      expect(status['commands'], ['demo:seed', 'demo:broken']);
      expect(status['stack'], isA<List>());
      expect(() => jsonEncode(status), returnsNormally);
    });

    nyTest('reports authentication as unknown without an auth key', () async {
      await _boot(authKey: null);

      final Map status = (await NyLive.dispatch('status')) as Map;

      expect(status['authenticated'], isNull);
    });
  });

  nyGroup('storage', () {
    nyTest('sets values with their storage type', () async {
      expect(
        await NyLive.dispatch('storage.set', {'key': 'name', 'value': 'Jane'}),
        {'key': 'name', 'type': 'string'},
      );
      expect(
        await NyLive.dispatch('storage.set', {'key': 'coins', 'value': 10}),
        {'key': 'coins', 'type': 'int'},
      );
      expect(
        await NyLive.dispatch('storage.set', {
          'key': 'cart',
          'value': [
            {'sku': 'A1'},
          ],
        }),
        {'key': 'cart', 'type': 'json'},
      );

      expect(await NyStorage.read<String>('name'), 'Jane');
      expect(await NyStorage.read<int>('coins'), 10);
      expect(await NyStorage.readJson('cart'), [
        {'sku': 'A1'},
      ]);
    });

    nyTest('sets plain values with a ttl', () async {
      final Map result =
          (await NyLive.dispatch('storage.set', {
                'key': 'otp',
                'value': '123456',
                'ttl': 60,
              }))
              as Map;

      expect(result['type'], 'string');
      expect(
        DateTime.parse(result['expiresAt'] as String).isAfter(DateTime.now()),
        isTrue,
      );
      expect(await NyStorage.getTimeToLive('otp'), isNotNull);
    });

    nyTest('can mirror a value into Backpack', () async {
      await NyLive.dispatch('storage.set', {
        'key': 'theme_pref',
        'value': 'dark',
        'backpack': true,
      });

      expect(Backpack.instance.read('theme_pref'), 'dark');
    });

    nyTest('rejects invalid set arguments', () async {
      await expectLater(
        NyLive.dispatch('storage.set', {'value': 1}),
        throwsA(_liveError(LiveException.invalidParamsCode, 'Missing "key".')),
      );
      await expectLater(
        NyLive.dispatch('storage.set', {'key': 'k'}),
        throwsA(
          _liveError(LiveException.invalidParamsCode, 'Missing "value".'),
        ),
      );
      await expectLater(
        NyLive.dispatch('storage.set', {
          'key': 'k',
          'value': {'a': 1},
          'ttl': 5,
        }),
        throwsA(
          _liveError(LiveException.invalidParamsCode, contains('plain values')),
        ),
      );
      await expectLater(
        NyLive.dispatch('storage.set', {'key': 'k', 'value': 1, 'ttl': -5}),
        throwsA(
          _liveError(LiveException.invalidParamsCode, contains('positive')),
        ),
      );
    });

    nyTest('lists decoded values sorted by key', () async {
      await NyStorage.save('b_count', 2);
      await NyStorage.saveJson('a_user', {'id': 42});

      expect(await NyLive.dispatch('storage.list'), {
        'items': [
          {
            'key': 'a_user',
            'type': 'json',
            'value': {'id': 42},
          },
          {'key': 'b_count', 'type': 'int', 'value': 2},
        ],
      });
    });

    nyTest('gets one value or reports it missing', () async {
      await NyStorage.save('flag', true);

      expect(await NyLive.dispatch('storage.get', {'key': 'flag'}), {
        'key': 'flag',
        'exists': true,
        'type': 'bool',
        'value': true,
      });
      expect(
        ((await NyLive.dispatch('storage.get', {'key': 'nope'}))
            as Map)['exists'],
        isFalse,
      );
    });

    nyTest('deletes a key from storage and Backpack', () async {
      await NyStorage.save('coins', 5, inBackpack: true);

      expect(await NyLive.dispatch('storage.delete', {'key': 'coins'}), {
        'key': 'coins',
        'deleted': true,
        'existed': true,
      });
      expect(await NyStorage.read('coins'), isNull);
      expect(Backpack.instance.read('coins'), isNull);
      expect(
        ((await NyLive.dispatch('storage.delete', {'key': 'coins'}))
            as Map)['existed'],
        isFalse,
      );
    });

    nyTest('clears storage while keeping chosen keys', () async {
      await NyStorage.save('keep_me', 'yes');
      await NyStorage.save('drop_me', 'no');

      expect(
        await NyLive.dispatch('storage.clear', {
          'keep': ['keep_me'],
        }),
        {
          'cleared': true,
          'kept': ['keep_me'],
        },
      );
      expect(await NyStorage.read('keep_me'), 'yes');
      expect(await NyStorage.read('drop_me'), isNull);

      await expectLater(
        NyLive.dispatch('storage.clear', {'keep': 'keep_me'}),
        throwsA(_liveError(LiveException.invalidParamsCode)),
      );
    });
  });

  nyGroup('backpack.list', () {
    nyTest('lists values without Nylo internals', () async {
      Backpack.instance.save('session_count', 3);
      Backpack.instance.save('when', DateTime.utc(2026, 9, 13));

      final List items =
          ((await NyLive.dispatch('backpack.list')) as Map)['items'] as List;
      final Iterable keys = items.map((item) => item['key']);

      expect(keys, isNot(contains('nylo')));
      expect(keys, isNot(contains('event_bus')));
      expect(
        items,
        contains(equals({'key': 'session_count', 'type': 'int', 'value': 3})),
      );
      expect(
        items,
        contains(
          equals({
            'key': 'when',
            'type': 'DateTime',
            'value': '2026-09-13T00:00:00.000Z',
          }),
        ),
      );
    });

    nyTest('lists a value stored as JSON without decoding it', () async {
      // Backpack.read<T> turns a JSON string into a model of T. Listing asks
      // for no type, so it must read the value as it was stored rather than
      // look for a decoder.
      Backpack.instance.save('cart', '{"items": 2}');
      Backpack.instance.save('profile', {'name': 'Jane'});

      final List items =
          ((await NyLive.dispatch('backpack.list')) as Map)['items'] as List;

      expect(
        items,
        contains(
          equals({'key': 'cart', 'type': 'String', 'value': '{"items": 2}'}),
        ),
      );
      expect(
        items.firstWhere((item) => item['key'] == 'profile'),
        containsPair('value', {'name': 'Jane'}),
      );
      expect(
        Backpack.instance.read<dynamic>('cart'),
        '{"items": 2}',
        reason: 'listing must not replace what the app stored',
      );
    });
  });

  nyGroup('backpack.get', () {
    nyTest('returns one value in full', () async {
      Backpack.instance.save('profile', {
        'name': 'Jane',
        'roles': ['admin'],
      });

      expect(await NyLive.dispatch('backpack.get', {'key': 'profile'}), {
        'key': 'profile',
        'exists': true,
        'type': '_Map<String, Object>',
        'value': {
          'name': 'Jane',
          'roles': ['admin'],
        },
      });
    });

    nyTest('reads a value stored as JSON without decoding it', () async {
      Backpack.instance.save('cart', '{"items": 2}');

      expect(await NyLive.dispatch('backpack.get', {'key': 'cart'}), {
        'key': 'cart',
        'exists': true,
        'type': 'String',
        'value': '{"items": 2}',
      });
    });

    nyTest('reaches a key the listing leaves out', () async {
      final Map result =
          (await NyLive.dispatch('backpack.get', {'key': 'nylo'})) as Map;

      expect(result['exists'], true);
      expect(result['type'], 'Nylo');
    });

    nyTest('says when a key was never saved', () async {
      expect(await NyLive.dispatch('backpack.get', {'key': 'nothing'}), {
        'key': 'nothing',
        'exists': false,
        'type': null,
        'value': null,
      });
    });

    nyTest('rejects a missing key', () async {
      expect(
        NyLive.dispatch('backpack.get'),
        throwsA(_liveError(LiveException.invalidParamsCode)),
      );
    });
  });

  nyGroup('auth.show', () {
    nyTest('lists every session that is signed in, with its user', () async {
      await NyLive.dispatch('auth.login', {
        'data': {'id': 42, 'name': 'Jane'},
      });
      await NyLive.dispatch('auth.login', {
        'data': {'id': 7},
        'session': 'device',
      });

      expect(await NyLive.dispatch('auth.show'), {
        'key': 'SK_USER',
        'sessions': [
          {
            'session': 'default',
            'user': {'id': 42, 'name': 'Jane'},
          },
          {
            'session': 'device',
            'user': {'id': 7},
          },
        ],
      });
    });

    nyTest('shows one session on its own', () async {
      await NyLive.dispatch('auth.login', {
        'data': {'id': 42},
      });
      await NyLive.dispatch('auth.login', {
        'data': {'id': 7},
        'session': 'device',
      });

      final Map result =
          (await NyLive.dispatch('auth.show', {'session': 'device'})) as Map;

      expect((result['sessions'] as List).single, {
        'session': 'device',
        'user': {'id': 7},
      });
    });

    nyTest('has no sessions when nobody is signed in', () async {
      expect(await NyLive.dispatch('auth.show'), {
        'key': 'SK_USER',
        'sessions': <Object?>[],
      });
    });

    nyTest('says when no auth key is configured', () async {
      await _boot(authKey: null);

      expect(await NyLive.dispatch('auth.show'), {
        'key': null,
        'sessions': <Object?>[],
      });
    });

    nyTest('is allowed in profile builds', () async {
      await NyLive.dispatch('auth.login', {
        'data': {'id': 42},
      });
      NyLive.debugBuildOverride = false;
      addTearDown(() => NyLive.debugBuildOverride = null);

      final Map result = (await NyLive.dispatch('auth.show')) as Map;

      expect((result['sessions'] as List), hasLength(1));
    });
  });

  nyGroup('backpack.set', () {
    nyTest('saves a value the listing then reports', () async {
      // Values arrive decoded from JSON, so a map is Map<String, dynamic>.
      expect(
        await NyLive.dispatch('backpack.set', {
          'key': 'cart',
          'value': <String, dynamic>{'items': 2},
        }),
        {'key': 'cart', 'type': '_Map<String, dynamic>'},
      );

      expect(Backpack.instance.read<dynamic>('cart'), {'items': 2});
    });

    nyTest('keeps the type it was given', () async {
      for (final (dynamic value, String type) in [
        (10, 'int'),
        ('ten', 'String'),
        (true, 'bool'),
        (null, 'Null'),
      ]) {
        expect(
          await NyLive.dispatch('backpack.set', {'key': 'v', 'value': value}),
          {'key': 'v', 'type': type},
        );
        expect(Backpack.instance.read<dynamic>('v'), value);
      }
    });

    nyTest('replaces a value that was already there', () async {
      Backpack.instance.save('coins', 1);

      await NyLive.dispatch('backpack.set', {'key': 'coins', 'value': 2});

      expect(Backpack.instance.read<dynamic>('coins'), 2);
    });

    nyTest('writes nothing to local storage', () async {
      await NyLive.dispatch('backpack.set', {'key': 'token', 'value': 'abc'});

      expect(Backpack.instance.read<dynamic>('token'), 'abc');
      expect(await NyStorage.read('token'), isNull);
    });

    nyTest('refuses to replace what the app needs to run', () async {
      for (final String key in ['nylo', 'event_bus']) {
        final Object? before = Backpack.instance.read<dynamic>(key);
        await expectLater(
          NyLive.dispatch('backpack.set', {'key': key, 'value': 'broken'}),
          throwsA(_liveError(LiveException.failedCode)),
        );
        expect(Backpack.instance.read<dynamic>(key), same(before));
      }
    });

    nyTest('rejects a missing key or value', () async {
      expect(
        NyLive.dispatch('backpack.set', {'value': 1}),
        throwsA(_liveError(LiveException.invalidParamsCode)),
      );
      expect(
        NyLive.dispatch('backpack.set', {'key': 'cart'}),
        throwsA(_liveError(LiveException.invalidParamsCode)),
      );
    });

    nyTest('is not allowed in profile builds', () async {
      NyLive.debugBuildOverride = false;
      addTearDown(() => NyLive.debugBuildOverride = null);

      await expectLater(
        NyLive.dispatch('backpack.set', {'key': 'cart', 'value': 1}),
        throwsA(isA<LiveException>()),
      );
      expect(Backpack.instance.contains('cart'), isFalse);
    });
  });

  nyGroup('backpack.delete', () {
    nyTest('removes a key from the Backpack', () async {
      Backpack.instance.save('cached_user_resource', {'id': 1});

      expect(
        await NyLive.dispatch('backpack.delete', {
          'key': 'cached_user_resource',
        }),
        {'key': 'cached_user_resource', 'deleted': true, 'existed': true},
      );
      expect(Backpack.instance.contains('cached_user_resource'), isFalse);
    });

    nyTest('leaves local storage alone', () async {
      await NyStorage.save('token', 'abc', inBackpack: true);

      await NyLive.dispatch('backpack.delete', {'key': 'token'});

      expect(Backpack.instance.contains('token'), isFalse);
      expect(await NyStorage.read('token'), 'abc');
    });

    nyTest('says when the key was not there', () async {
      expect(await NyLive.dispatch('backpack.delete', {'key': 'nothing'}), {
        'key': 'nothing',
        'deleted': true,
        'existed': false,
      });
    });

    nyTest('refuses to delete what the app needs to run', () async {
      for (final String key in ['nylo', 'event_bus']) {
        await expectLater(
          NyLive.dispatch('backpack.delete', {'key': key}),
          throwsA(_liveError(LiveException.failedCode)),
        );
        expect(Backpack.instance.contains(key), isTrue);
      }
    });

    nyTest('is not allowed in profile builds', () async {
      NyLive.debugBuildOverride = false;
      addTearDown(() => NyLive.debugBuildOverride = null);
      Backpack.instance.save('cart', 1);

      await expectLater(
        NyLive.dispatch('backpack.delete', {'key': 'cart'}),
        throwsA(isA<LiveException>()),
      );
      expect(Backpack.instance.contains('cart'), isTrue);
    });
  });

  nyGroup('auth', () {
    nyTest('logs a user in and out', () async {
      expect(
        await NyLive.dispatch('auth.login', {
          'data': {'id': 42, 'name': 'Jane'},
        }),
        {
          'authenticated': true,
          'session': 'default',
          'user': {'id': 42, 'name': 'Jane'},
        },
      );
      expect(await Auth.isAuthenticated(), isTrue);

      expect(await NyLive.dispatch('auth.logout'), {
        'authenticated': false,
        'session': 'default',
      });
      expect(await Auth.isAuthenticated(), isFalse);
    });

    nyTest('supports named sessions', () async {
      await NyLive.dispatch('auth.login', {
        'data': {'device': 'kiosk'},
        'session': 'device',
      });

      expect(await Auth.isAuthenticated(session: 'device'), isTrue);
      expect(await Auth.isAuthenticated(), isFalse);
    });

    nyTest('explains what is wrong', () async {
      await expectLater(
        NyLive.dispatch('auth.login', {'data': 'jane'}),
        throwsA(
          _liveError(LiveException.invalidParamsCode, contains('JSON object')),
        ),
      );

      await _boot(authKey: null);
      await expectLater(
        NyLive.dispatch('auth.login', {
          'data': {'id': 1},
        }),
        throwsA(_liveError(LiveException.failedCode, contains('No auth key'))),
      );
    });
  });

  nyGroup('event.fire', () {
    nyTest('fires a registered event by class name', () async {
      final _RecordingListener listener = _RecordingListener();
      Nylo.instance.addEvents({OrderShippedEvent: OrderShippedEvent(listener)});

      expect(
        await NyLive.dispatch('event.fire', {
          'event': 'OrderShippedEvent',
          'data': {'order': 7},
          'broadcast': false,
        }),
        {'event': 'OrderShippedEvent'},
      );
      expect(listener.calls, [
        {'order': 7},
      ]);
    });

    nyTest('lists registered events when the name is wrong', () async {
      Nylo.instance.addEvents({
        OrderShippedEvent: OrderShippedEvent(_RecordingListener()),
      });

      await expectLater(
        NyLive.dispatch('event.fire', {'event': 'OrderLost'}),
        throwsA(
          _liveError(LiveException.failedCode, contains('OrderShippedEvent')),
        ),
      );
      await expectLater(
        NyLive.dispatch('event.fire', {
          'event': 'OrderShippedEvent',
          'data': [1],
        }),
        throwsA(_liveError(LiveException.invalidParamsCode)),
      );
    });
  });

  nyGroup('state.update', () {
    nyTest('sends data to a named state through the event bus', () async {
      expect(
        await NyLive.dispatch('state.update', {
          'state': 'cart_badge',
          'data': {'count': 2},
        }),
        {'state': 'cart_badge'},
      );
    });

    nyTest('fails clearly without an event bus', () async {
      Backpack.instance.delete('event_bus');

      await expectLater(
        NyLive.dispatch('state.update', {'state': 'cart_badge'}),
        throwsA(_liveError(LiveException.failedCode, contains('event bus'))),
      );
    });
  });

  nyGroup('theme.set', () {
    nyTest('rejects themes that are not registered', () async {
      await expectLater(
        NyLive.dispatch('theme.set', {'id': 'neon'}),
        throwsA(_liveError(LiveException.failedCode)),
      );
    });
  });

  nyGroup('app-defined commands', () {
    nyTest('lists commands with their schema', () async {
      final List commands =
          ((await NyLive.dispatch('commands.list')) as Map)['commands'] as List;

      expect(commands.first, {
        'name': 'demo:seed',
        'description': 'Seed sample data',
        'options': [
          {
            'kind': 'option',
            'name': 'count',
            'abbr': null,
            'help': null,
            'allowed': null,
            'defaultValue': '3',
          },
          {
            'kind': 'flag',
            'name': 'open',
            'abbr': null,
            'help': null,
            'defaultValue': false,
          },
        ],
      });
    });

    nyTest('runs a command with parsed args, defaults and rest', () async {
      expect(
        await NyLive.dispatch('commands.run', {
          'name': 'demo:seed',
          'args': {'open': true},
          'rest': ['extra'],
        }),
        {
          'name': 'demo:seed',
          'output': [
            {'level': 'success', 'message': 'Seeded 3'},
            {'level': 'info', 'message': 'Opening'},
          ],
          'result': {
            'count': 3,
            'rest': ['extra'],
          },
          'failed': false,
        },
      );
    });

    nyTest('reports a command that throws without losing its output', () async {
      expect(await NyLive.dispatch('commands.run', {'name': 'demo:broken'}), {
        'name': 'demo:broken',
        'output': [
          {'level': 'info', 'message': 'Starting'},
          {'level': 'error', 'message': 'Bad state: database locked'},
        ],
        'result': null,
        'failed': true,
      });
    });

    nyTest('explains how to register an unknown command', () async {
      await expectLater(
        NyLive.dispatch('commands.run', {'name': 'cart:seed'}),
        throwsA(
          _liveError(
            LiveException.failedCode,
            allOf(
              contains('lib/bootstrap/live_commands.dart'),
              contains('demo:seed'),
            ),
          ),
        ),
      );
      await expectLater(
        NyLive.dispatch('commands.run', {
          'name': 'demo:seed',
          'args': [1],
        }),
        throwsA(_liveError(LiveException.invalidParamsCode)),
      );
    });
  });

  nyGroup('Backpack.keys', () {
    nyTest('lists stored keys', () async {
      Backpack.instance.save('alpha', 1);

      expect(Backpack.instance.keys, contains('alpha'));
      expect(() => Backpack.instance.keys.add('beta'), throwsUnsupportedError);
    });
  });

  nyGroup('NyLogger listeners', () {
    nyTest('notify every listener until removed', () async {
      final List<String> first = [];
      final List<String> second = [];
      void a(NyLogEntry entry) => first.add(entry.message);
      void b(NyLogEntry entry) => second.add(entry.message);

      NyLogger.addListener(a);
      NyLogger.addListener(a);
      NyLogger.addListener(b);
      NyLogger.debug('one');
      NyLogger.removeListener(a);
      NyLogger.debug('two');
      NyLogger.removeListener(b);

      expect(first, ['one']);
      expect(second, ['one', 'two']);
    });
  });

  nyGroup('NyLiveNavigatorObserver', () {
    nyTest('emits route events', () async {
      final List<Map<String, Object?>> events = [];
      NyLive.onEmit = (kind, data) {
        if (kind == 'route') events.add(data);
      };
      final NyLiveNavigatorObserver observer = NyLiveNavigatorObserver();
      final PageRouteBuilder<void> home = PageRouteBuilder(
        settings: const RouteSettings(name: '/home'),
        pageBuilder: (_, _, _) => const SizedBox(),
      );
      final PageRouteBuilder<void> cart = PageRouteBuilder(
        settings: const RouteSettings(name: '/cart'),
        pageBuilder: (_, _, _) => const SizedBox(),
      );

      observer.didPush(cart, home);
      observer.didPop(cart, home);
      observer.didReplace(newRoute: cart, oldRoute: home);
      observer.didRemove(cart, home);

      expect(events, [
        {'action': 'push', 'name': '/cart', 'previous': '/home'},
        {'action': 'pop', 'name': '/cart', 'previous': '/home'},
        {'action': 'replace', 'name': '/cart', 'previous': '/home'},
        {'action': 'remove', 'name': '/cart', 'previous': '/home'},
      ]);
    });
  });
}
