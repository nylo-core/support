import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '/alerts/ny_alerts.dart';
import '/events/ny_events.dart';
import '/helpers/ny_helpers.dart';
import '/local_storage/ny_local_storage.dart';
import '/localization/ny_localization.dart';
import '/nylo.dart';
import '/router/ny_router.dart';
import '/themes/ny_themes.dart';
import 'ny_live.dart';
import 'live_command.dart';
import 'live_exception.dart';
import 'live_state_inspector.dart';
import 'ny_live_json.dart';
import 'seed_recorder.dart';
import 'storage_snapshot.dart';

/// Runs a live command with its decoded arguments.
typedef NyLiveHandler = Future<Object?> Function(Map<String, dynamic> args);

/// Every built-in live command, keyed by the name after `ext.nylo.`.
final Map<String, NyLiveHandler> nyLiveBuiltIns = {
  'status': _status,
  'routes': _routes,
  'route.current': _routeCurrent,
  'route.push': _routePush,
  'route.back': _routeBack,
  'deeplink.show': _deepLinkShow,
  'deeplink.open': _deepLinkOpen,
  'storage.list': _storageList,
  'storage.get': _storageGet,
  'storage.set': _storageSet,
  'storage.delete': _storageDelete,
  'storage.clear': _storageClear,
  'storage.export': _storageExport,
  'snapshot.import': _snapshotImport,
  'backpack.list': _backpackList,
  'backpack.get': _backpackGet,
  'backpack.set': _backpackSet,
  'backpack.delete': _backpackDelete,
  'auth.show': _authShow,
  'auth.login': _authLogin,
  'auth.logout': _authLogout,
  'locale.set': _localeSet,
  'theme.set': _themeSet,
  'state.data': _stateData,
  'state.update': _stateUpdate,
  'event.fire': _eventFire,
  'toast.show': _toastShow,
  'commands.list': _commandsList,
  'commands.run': _commandsRun,
  'seeders.list': _seedersList,
  'seeders.run': _seedersRun,
};

// ---------------------------------------------------------------------------
// App
// ---------------------------------------------------------------------------

Future<Object?> _status(Map<String, dynamic> args) async => {
  'protocol': NyLive.protocolVersion,
  'app': _env('APP_NAME'),
  'env': _env('APP_ENV'),
  'mode': NyLive.isDebugBuild ? 'debug' : 'profile',
  'platform': kIsWeb ? 'web' : defaultTargetPlatform.name.toLowerCase(),
  'osVersion': kIsWeb ? null : Platform.operatingSystemVersion,
  'route': Nylo.getCurrentRouteName(),
  'stack': _stack(),
  'locale': _orNull(() => NyLocalization.instance.locale.languageCode),
  'theme': _orNull(() {
    final String id = NyThemeManager.instance.currentThemeId;
    return id.isEmpty ? null : id;
  }),
  'authenticated': await _isAuthenticated(),
  'commands': NyLive.commandNames,
  'seeders': NyLive.seederNames,
};

// ---------------------------------------------------------------------------
// Routing
// ---------------------------------------------------------------------------

Future<Object?> _routes(Map<String, dynamic> args) async {
  final NyRouter router = NyNavigator.instance.router;
  final Map<String, NyRouterRoute> routes = router.getRegisteredRoutes();
  String? authRoute;
  String? unknownRoute;
  for (final NyRouterRoute route in routes.values) {
    if (authRoute == null && route.getAuthRoute()) authRoute = route.name;
    if (unknownRoute == null && route.getUnknownRoute()) {
      unknownRoute = route.name;
    }
  }
  if (unknownRoute == null && router.getUnknownRoutes().isNotEmpty) {
    unknownRoute = router.getUnknownRouteName();
  }
  return {
    'initial': router.getInitialRouteName(),
    'auth': authRoute,
    'unknown': unknownRoute,
    'routes': routes.keys.toList(),
  };
}

Future<Object?> _routeCurrent(Map<String, dynamic> args) async {
  final Route<dynamic>? route = _topRoute();
  return {
    'current': route?.settings.name,
    'data': _routeData(route),
    'stack': _stack(),
  };
}

Future<Object?> _routePush(Map<String, dynamic> args) async {
  final String path = _requireString(args, 'path');
  final NavigationType navigationType = switch (args['navigation'] ?? 'push') {
    'push' => NavigationType.push,
    'replace' => NavigationType.pushReplace,
    'clear' => NavigationType.pushAndForgetAll,
    final Object? other => throw LiveException.invalidParams(
      '"navigation" must be push, replace or clear, not "$other".',
    ),
  };
  _requireNavigator();

  final Route<dynamic>? before = _topRoute();
  Object? navigationError;
  bool navigationEnded = false;
  // A successful push only completes when the pushed route pops, so routeTo is
  // never awaited. It completes early when a route guard stops the navigation.
  unawaited(
    routeTo(path, data: args['data'], navigationType: navigationType).then(
      (_) {
        navigationEnded = true;
      },
      onError: (Object error) {
        navigationError = error;
      },
    ),
  );
  await _waitUntil(
    () => navigationError != null || navigationEnded || _topRoute() != before,
  );

  if (navigationError != null) {
    throw LiveException(
      navigationError is RouteNotFoundError
          ? 'No route named "$path" is registered. Run metro live:run routes to list them.'
          : 'Navigating to "$path" failed: $navigationError',
    );
  }
  // Let the new page build, so the next command can use it straight away.
  await _waitForPage();
  return {
    'from': before?.settings.name,
    'current': Nylo.getCurrentRouteName(),
    'stack': _stack(),
    'changed': _topRoute() != before,
  };
}

Future<Object?> _routeBack(Map<String, dynamic> args) async {
  final NavigatorState navigator = _requireNavigator();
  final String? path = _optionalString(args, 'path');
  final Route<dynamic>? before = _topRoute();

  if (path != null) {
    final bool inStack = NyNavigator.instance.router.getRouteHistory().any(
      (Route<dynamic> route) => route.settings.name == path,
    );
    if (!inStack) {
      throw LiveException(
        '"$path" isn\'t in the navigation stack (${_stack().join(' → ')}).',
      );
    }
    navigator.popUntil((Route<dynamic> route) => route.settings.name == path);
  } else {
    if (!navigator.canPop()) {
      throw const LiveException('There is no page to go back to.');
    }
    // maybePop asks the page on top, which needs to have built first.
    await _waitForPage();
    final bool popped = await navigator.maybePop();
    if (!popped) {
      throw const LiveException('The current page blocked going back.');
    }
  }
  await _waitUntil(
    () => _topRoute() != before,
    timeout: const Duration(milliseconds: 600),
  );
  return {
    'from': before?.settings.name,
    'current': Nylo.getCurrentRouteName(),
    'stack': _stack(),
  };
}

/// How deep links are set up, and every route a link could reach.
Future<Object?> _deepLinkShow(Map<String, dynamic> args) async {
  if (!Nylo.isInitialized()) {
    throw const LiveException('Nylo hasn\'t finished booting yet.');
  }
  return {
    ...Nylo.instance.deepLinkStatus,
    'routes': NyNavigator.instance.router.getRegisteredRoutes().keys.toList(),
  };
}

/// Sends a link through the deep link chain and reports what each step did.
Future<Object?> _deepLinkOpen(Map<String, dynamic> args) async {
  final String link = _requireString(args, 'uri');
  final Uri? uri = Uri.tryParse(link);
  if (uri == null || !uri.hasScheme) {
    throw LiveException.invalidParams(
      '"$link" isn\'t a link. It needs a scheme, e.g. myapp://product/42 or '
      'https://example.com/product/42.',
    );
  }
  if (!Nylo.isInitialized()) {
    throw const LiveException('Nylo hasn\'t finished booting yet.');
  }
  final bool dry = args['dry'] == true;
  if (!dry) _requireNavigator();

  final Route<dynamic>? before = _topRoute();
  // Let the current frame finish before the link touches navigation.
  await Future<void>.delayed(Duration.zero);

  final Map<String, Object?> result = await Nylo.instance.handleDeepLink(
    uri,
    dry: dry,
    runCallback: args['callback'] != false,
  );

  if (result['routed'] == true) {
    await _waitUntil(() => _topRoute() != before);
    await _waitForPage();
  }
  return {...result, 'current': Nylo.getCurrentRouteName(), 'stack': _stack()};
}

// ---------------------------------------------------------------------------
// Storage
// ---------------------------------------------------------------------------

Future<Object?> _storageList(Map<String, dynamic> args) async {
  final Map<String, String> values = await NyStorage.readAll();
  final List<String> keys =
      values.keys.where((String key) => key != SeedRecorder.recordKey).toList()
        ..sort();
  return {
    'items': [
      for (final String key in keys)
        NyLiveJson.describeStorageValue(key, values[key])..remove('exists'),
    ],
  };
}

Future<Object?> _storageGet(Map<String, dynamic> args) async {
  final String key = _requireString(args, 'key');
  return NyLiveJson.describeStorageValue(key, await _readRaw(key));
}

Future<Object?> _storageSet(Map<String, dynamic> args) async {
  final String key = _requireString(args, 'key');
  if (!args.containsKey('value')) {
    throw const LiveException.invalidParams('Missing "value".');
  }
  final dynamic value = args['value'];
  final dynamic ttl = args['ttl'];
  final bool inBackpack = args['backpack'] == true;
  if (ttl != null && (ttl is! num || ttl <= 0)) {
    throw const LiveException.invalidParams(
      '"ttl" must be a positive number of seconds.',
    );
  }

  if (value is Map || value is List) {
    if (ttl != null) {
      throw const LiveException.invalidParams(
        '"ttl" only works with plain values (strings, numbers and booleans).',
      );
    }
    await NyStorage.saveJson(key, value, inBackpack: inBackpack);
  } else if (ttl != null) {
    await NyStorage.saveWithExpiry(
      key,
      value,
      ttl: Duration(milliseconds: ((ttl as num) * 1000).round()),
      inBackpack: inBackpack,
    );
  } else {
    await NyStorage.save(key, value, inBackpack: inBackpack);
  }

  final Map<String, Object?> saved = NyLiveJson.describeStorageValue(
    key,
    await _readRaw(key),
  );
  return {
    'key': key,
    'type': saved['type'],
    if (saved['expiresAt'] != null) 'expiresAt': saved['expiresAt'],
  };
}

Future<Object?> _storageDelete(Map<String, dynamic> args) async {
  final String key = _requireString(args, 'key');
  final bool existed = await _readRaw(key) != null;
  await NyStorage.delete(key, andFromBackpack: true);
  return {'key': key, 'deleted': true, 'existed': existed};
}

Future<Object?> _storageClear(Map<String, dynamic> args) async {
  final dynamic keep = args['keep'] ?? const [];
  if (keep is! List || keep.any((dynamic key) => key is! String)) {
    throw const LiveException.invalidParams(
      '"keep" must be a list of storage keys.',
    );
  }
  final List<String> kept = keep.cast<String>();
  await NyStorage.deleteAll(
    andFromBackpack: true,
    excludeKeys: kept.isEmpty ? null : kept,
  );
  return {'cleared': true, 'kept': kept};
}

Future<Object?> _storageExport(Map<String, dynamic> args) async {
  final dynamic backpack = args['backpack'] ?? true;
  if (backpack is! bool) {
    throw const LiveException.invalidParams(
      '"backpack" must be true or false.',
    );
  }
  final StorageSnapshot snapshot = await StorageSnapshot.capture(
    only: _stringList(args, 'only'),
    except: _stringList(args, 'except'),
    backpack: backpack,
  );
  return {
    ...snapshot.toJson(),
    'skipped': snapshot.skipped,
    'exportedAt': DateTime.now().toUtc().toIso8601String(),
    'app': _env('APP_NAME'),
    'env': _env('APP_ENV'),
    'route': Nylo.getCurrentRouteName(),
  };
}

Future<Object?> _snapshotImport(Map<String, dynamic> args) async {
  final String name = _requireString(args, 'name');
  final dynamic snapshot = args['snapshot'];
  if (snapshot is! Map) {
    throw const LiveException.invalidParams(
      '"snapshot" must be a JSON object with "storage" and "backpack".',
    );
  }
  final String? source = _optionalString(args, 'source');
  final dynamic fresh = args['fresh'] ?? false;
  if (fresh is! bool) {
    throw const LiveException.invalidParams('"fresh" must be true or false.');
  }
  final StorageSnapshot parsed = StorageSnapshot.fromJson(snapshot);

  // Let the current frame finish before the import touches state.
  await Future<void>.delayed(Duration.zero);

  final List<SeedRun> runs = await SeedRecorder.upAll([
    SnapshotSeeder(parsed, name: name, source: source),
  ], fresh: fresh);
  return {
    'runs': [for (final SeedRun run in runs) run.toJson()],
    'failed': runs.any((SeedRun run) => run.failed),
  };
}

/// Keys the app needs to run, which the Backpack listing leaves out and
/// `Backpack.deleteAll` keeps.
const Set<String> _backpackInternal = {'nylo', 'event_bus'};

Future<Object?> _backpackList(Map<String, dynamic> args) async {
  final Backpack backpack = Backpack.instance;
  final List<String> keys =
      backpack.keys
          .where((String key) => !_backpackInternal.contains(key))
          .toList()
        ..sort();
  final List<Map<String, Object?>> items = [];
  for (final String key in keys) {
    // Read as dynamic. A typed read decodes a value stored as a JSON string
    // into a model of that type, which needs a decoder this listing has no
    // reason to ask for - and replaces what the app stored with the model.
    final dynamic value = backpack.read<dynamic>(key);
    items.add({
      'key': key,
      'type': value == null ? 'Null' : value.runtimeType.toString(),
      'value': NyLiveJson.encodable(value),
    });
  }
  return {'items': items};
}

Future<Object?> _backpackSet(Map<String, dynamic> args) async {
  final String key = _requireString(args, 'key');
  if (!args.containsKey('value')) {
    throw const LiveException.invalidParams('Missing "value".');
  }
  if (_backpackInternal.contains(key)) {
    throw LiveException(
      'The app needs "$key" in the Backpack to run, so it can\'t be replaced.',
    );
  }
  final dynamic value = args['value'];
  // The Backpack holds whatever it's given; nothing is written to storage,
  // and `storage <key> <value> --backpack` is the command that does both.
  Backpack.instance.save(key, value);
  return {
    'key': key,
    'type': value == null ? 'Null' : value.runtimeType.toString(),
  };
}

Future<Object?> _backpackDelete(Map<String, dynamic> args) async {
  final String key = _requireString(args, 'key');
  if (_backpackInternal.contains(key)) {
    throw LiveException(
      'The app needs "$key" in the Backpack to run, so it can\'t be deleted.',
    );
  }
  final Backpack backpack = Backpack.instance;
  final bool existed = backpack.contains(key);
  // Only the Backpack: anything saved to local storage under this key stays,
  // and `storage <key> --delete` is the command that removes both.
  backpack.delete(key);
  return {'key': key, 'deleted': true, 'existed': existed};
}

Future<Object?> _backpackGet(Map<String, dynamic> args) async {
  final String key = _requireString(args, 'key');
  final Backpack backpack = Backpack.instance;
  if (!backpack.contains(key)) {
    return {'key': key, 'exists': false, 'type': null, 'value': null};
  }
  // Read as dynamic, for the reason _backpackList does.
  final dynamic value = backpack.read<dynamic>(key);
  return {
    'key': key,
    'exists': true,
    'type': value == null ? 'Null' : value.runtimeType.toString(),
    'value': NyLiveJson.encodable(value),
  };
}

// ---------------------------------------------------------------------------
// Auth
// ---------------------------------------------------------------------------

Future<Object?> _authShow(Map<String, dynamic> args) async {
  final String? key = Nylo.isInitialized() ? Nylo.instance.getAuthKey() : null;
  if (key == null) return {'key': null, 'sessions': const []};

  final String? only = _optionalString(args, 'session');
  final Map<String, String> stored = await NyStorage.readAll();
  // A named session is kept under `<authKey>_<name>`, the default under the
  // key itself, so the sessions are whatever storage holds for them.
  final List<String> sessions = [
    if (stored.containsKey(key)) Auth.defaultSession,
    for (final String name in stored.keys)
      if (name.startsWith('${key}_') && name.length > key.length + 1)
        name.substring(key.length + 1),
  ]..sort();

  return {
    'key': key,
    'sessions': [
      for (final String session in sessions)
        if (only == null || only == session)
          {
            'session': session,
            'user': await NyStorage.readJson(
              Auth.key(session == Auth.defaultSession ? null : session),
            ),
          },
    ],
  };
}

Future<Object?> _authLogin(Map<String, dynamic> args) async {
  final dynamic data = args['data'];
  if (data is! Map) {
    throw const LiveException.invalidParams(
      '"data" must be a JSON object, for example {"id": 1, "name": "Jane"}.',
    );
  }
  _requireAuthKey();
  final String? session = _optionalString(args, 'session');
  await Auth.authenticate(
    data: Map<String, dynamic>.from(data),
    session: session,
  );
  return {
    'authenticated': await Auth.isAuthenticated(session: session),
    'session': session ?? Auth.defaultSession,
    'user': Auth.data(session: session),
  };
}

Future<Object?> _authLogout(Map<String, dynamic> args) async {
  _requireAuthKey();
  final String? session = _optionalString(args, 'session');
  await Auth.logout(session: session);
  return {
    'authenticated': await Auth.isAuthenticated(session: session),
    'session': session ?? Auth.defaultSession,
  };
}

// ---------------------------------------------------------------------------
// App state
// ---------------------------------------------------------------------------

Future<Object?> _localeSet(Map<String, dynamic> args) async {
  final String language = _requireString(args, 'language');
  final BuildContext context = _requirePageContext();
  await NyLocalization.instance.setLanguage(context, language: language);
  final String current = NyLocalization.instance.locale.languageCode;
  if (current != language) {
    throw LiveException(
      'Couldn\'t switch to "$language". Check that lang/$language.json exists and is listed in your assets.',
    );
  }
  return {'locale': current};
}

Future<Object?> _themeSet(Map<String, dynamic> args) async {
  final String id = _requireString(args, 'id');
  final NyThemeManager manager = NyThemeManager.instance;
  final List<String> ids = manager.themes
      .map((BaseThemeConfig theme) => theme.id)
      .toList();
  if (!ids.contains(id)) {
    throw LiveException(
      ids.isEmpty
          ? 'No themes are registered.'
          : 'No theme with id "$id". Registered themes: ${ids.join(', ')}.',
    );
  }
  await manager.setTheme(id, remember: args['remember'] == true);
  return {'theme': manager.currentThemeId};
}

Future<Object?> _stateData(Map<String, dynamic> args) async =>
    LiveStateInspector.data(target: _optionalString(args, 'target'));

Future<Object?> _stateUpdate(Map<String, dynamic> args) async {
  final String state = _requireString(args, 'state');
  if (Backpack.instance.read<dynamic>('event_bus') == null) {
    throw const LiveException(
      'This app has no event bus, so states can\'t be updated. Call nylo.addEventBus() in a provider.',
    );
  }
  updateState(state, data: args['data']);
  return {'state': state};
}

Future<Object?> _eventFire(Map<String, dynamic> args) async {
  final String name = _requireString(args, 'event');
  final dynamic data = args['data'];
  if (data != null && data is! Map) {
    throw const LiveException.invalidParams('"data" must be a JSON object.');
  }
  if (!Nylo.isInitialized()) {
    throw const LiveException('Nylo hasn\'t finished booting yet.');
  }
  final Map<Type, NyEvent> events = Nylo.instance.getEvents();
  NyEvent? event;
  for (final MapEntry<Type, NyEvent> entry in events.entries) {
    if (entry.key.toString() == name) {
      event = entry.value;
      break;
    }
  }
  if (event == null) {
    throw LiveException(
      events.isEmpty
          ? 'No events are registered.'
          : 'No event named "$name". Registered events: ${events.keys.join(', ')}.',
    );
  }
  final dynamic broadcast = args['broadcast'];
  await event.fireAll(
    data == null ? null : Map<dynamic, dynamic>.from(data),
    broadcast: broadcast is bool
        ? broadcast
        : Nylo.instance.shouldBroadcastEvents(),
  );
  return {'event': name};
}

Future<Object?> _toastShow(Map<String, dynamic> args) async {
  final String description = _requireString(args, 'description');
  final BuildContext context = _requirePageContext();
  showToastNotification(
    context,
    id: _optionalString(args, 'style') ?? 'success',
    title: _optionalString(args, 'title'),
    description: description,
  );
  return {'shown': true};
}

// ---------------------------------------------------------------------------
// App-defined commands
// ---------------------------------------------------------------------------

Future<Object?> _commandsList(Map<String, dynamic> args) async => {
  'commands': [
    for (final MapEntry<String, LiveCommand Function()> entry
        in NyLive.commands.entries)
      _describeCommand(entry.key, entry.value()),
  ],
};

Future<Object?> _commandsRun(Map<String, dynamic> args) async {
  final String name = _requireString(args, 'name');
  final LiveCommand Function()? create = NyLive.commands[name];
  if (create == null) {
    final List<String> names = NyLive.commandNames;
    throw LiveException(
      'No live command named "$name" is registered in this build. '
      'Create it with metro make:command <name> --live (it registers the '
      'command in lib/bootstrap/live_commands.dart), then hot restart.'
      '${names.isEmpty ? '' : ' Registered: ${names.join(', ')}.'}',
    );
  }
  final dynamic values = args['args'] ?? const {};
  if (values is! Map) {
    throw const LiveException.invalidParams('"args" must be a JSON object.');
  }
  final dynamic rest = args['rest'] ?? const [];
  if (rest is! List) {
    throw const LiveException.invalidParams('"rest" must be a list.');
  }

  final LiveCommand command = create();
  final List<Map<String, Object?>> schema = command
      .builder(CommandBuilder())
      .schema;

  // Let the current frame finish before the command touches navigation or state.
  await Future<void>.delayed(Duration.zero);

  Object? result;
  bool failed = false;
  try {
    result = await command.handle(
      CommandResult(
        Map<String, dynamic>.from(values),
        schema: schema,
        rest: rest.map((dynamic item) => '$item').toList(),
      ),
    );
  } catch (e) {
    failed = true;
    command.error(e is LiveException ? e.message : e.toString());
  }
  return {
    'name': name,
    'output': command.output,
    'result': NyLiveJson.encodable(result),
    'failed': failed,
  };
}

Map<String, Object?> _describeCommand(String name, LiveCommand command) => {
  'name': name,
  'description': command.description,
  'options': command.builder(CommandBuilder()).schema,
};

// ---------------------------------------------------------------------------
// Seeders
// ---------------------------------------------------------------------------

Future<Object?> _seedersList(Map<String, dynamic> args) async => {
  'seeders': await SeedRecorder.list(),
};

Future<Object?> _seedersRun(Map<String, dynamic> args) async {
  final dynamic names = args['names'];
  if (names is! List ||
      names.isEmpty ||
      names.any((dynamic name) => name is! String || name.isEmpty)) {
    throw const LiveException.invalidParams(
      '"names" must be a list of seeder names.',
    );
  }
  final String direction = _optionalString(args, 'direction') ?? 'up';
  final dynamic fresh = args['fresh'] ?? false;
  if (fresh is! bool) {
    throw const LiveException.invalidParams('"fresh" must be true or false.');
  }
  if (fresh && direction == 'down') {
    throw const LiveException.invalidParams(
      '"fresh" only works when seeding, not when rolling back.',
    );
  }

  // Let the current frame finish before seeders touch navigation or state.
  await Future<void>.delayed(Duration.zero);

  final List<SeedRun> runs = await SeedRecorder.runNamed(
    names.cast<String>(),
    direction: direction,
    fresh: fresh,
  );
  return {
    'runs': [for (final SeedRun run in runs) run.toJson()],
    'failed': runs.any((SeedRun run) => run.failed),
  };
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _requireString(Map<String, dynamic> args, String key) {
  final dynamic value = args[key];
  if (value is String && value.isNotEmpty) return value;
  throw LiveException.invalidParams(
    value == null ? 'Missing "$key".' : '"$key" must be a non-empty string.',
  );
}

String? _optionalString(Map<String, dynamic> args, String key) {
  final dynamic value = args[key];
  if (value == null || value is String) return value;
  throw LiveException.invalidParams('"$key" must be a string.');
}

/// The list of strings at [key], or an empty list when it's absent.
List<String> _stringList(Map<String, dynamic> args, String key) {
  final dynamic value = args[key] ?? const [];
  if (value is! List || value.any((dynamic item) => item is! String)) {
    throw LiveException.invalidParams('"$key" must be a list of strings.');
  }
  return value.cast<String>();
}

NavigatorState _requireNavigator() {
  final NavigatorState? navigator =
      NyNavigator.instance.router.navigatorKey?.currentState;
  if (navigator == null) {
    throw const LiveException(
      'The app has no navigator yet. Wait for the first page to load, then try again.',
    );
  }
  return navigator;
}

/// A context inside the page on screen, below the Navigator's Overlay, which
/// toasts and app restarts look up. The navigator key's own context sits above
/// the Overlay, so it can't be used.
BuildContext _requirePageContext() {
  final Route<dynamic>? route = _topRoute();
  if (route is ModalRoute<dynamic>) {
    final BuildContext? context = route.subtreeContext;
    if (context != null && context.mounted) return context;
  }

  final OverlayState? overlay =
      NyNavigator.instance.router.navigatorKey?.currentState?.overlay;
  Element? child;
  (overlay?.context as Element?)?.visitChildElements((Element element) {
    child ??= element;
  });
  if (child != null) return child!;

  throw const LiveException(
    'The app has no page on screen yet. Wait for it to load, then try again.',
  );
}

void _requireAuthKey() {
  if (!Nylo.isInitialized() || Nylo.instance.getAuthKey() == null) {
    throw const LiveException(
      'No auth key is set. Pass authKey to nylo.configure(...) in your AppProvider.',
    );
  }
}

Future<bool?> _isAuthenticated() async {
  if (!Nylo.isInitialized() || Nylo.instance.getAuthKey() == null) return null;
  return Auth.isAuthenticated();
}

Future<String?> _readRaw(String key) => NyStorage.manager().read(key: key);

/// Waits until the page on top has built, for up to a second.
Future<void> _waitForPage() {
  final Route<dynamic>? route = _topRoute();
  if (route is! ModalRoute<dynamic>) return Future<void>.value();
  return _waitUntil(
    () => !route.isActive || route.subtreeContext != null,
    timeout: const Duration(seconds: 1),
  );
}

Route<dynamic>? _topRoute() {
  final List<Route<dynamic>> history = NyNavigator.instance.router
      .getRouteHistory();
  return history.isEmpty ? null : history.last;
}

List<String> _stack() => NyNavigator.instance.router
    .getRouteHistory()
    .map(
      (Route<dynamic> route) =>
          route.settings.name ?? route.runtimeType.toString(),
    )
    .toList();

Object? _routeData(Route<dynamic>? route) {
  final Object? arguments = route?.settings.arguments;
  if (arguments is ArgumentsWrapper) return arguments.baseArguments?.data;
  if (arguments is NyArgument) return arguments.data;
  return arguments;
}

String? _env(String key) {
  try {
    return getEnv(key, defaultValue: null)?.toString();
  } catch (_) {
    return null;
  }
}

T? _orNull<T>(T? Function() read) {
  try {
    return read();
  } catch (_) {
    return null;
  }
}

Future<void> _waitUntil(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 3),
}) async {
  const Duration tick = Duration(milliseconds: 16);
  final int ticks = timeout.inMilliseconds ~/ tick.inMilliseconds;
  for (int i = 0; i < ticks && !condition(); i++) {
    await Future<void>.delayed(tick);
  }
}
