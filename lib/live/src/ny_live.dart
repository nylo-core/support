import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '/helpers/ny_helpers.dart';
import '/nylo.dart';
import 'ny_live_builtins.dart';
import 'live_command.dart';
import 'live_exception.dart';
import 'ny_live_json.dart';
import 'seeder.dart';

/// Exposes live commands to Metro while the app runs in debug or profile mode.
///
/// `Nylo.init` calls [install], which registers every built-in command as a
/// Dart VM service extension (`ext.nylo.<command>`) on the main isolate and
/// streams route and log events on the `nylo` stream. Metro discovers the
/// running app through the Dart Tooling Daemon and calls these extensions.
///
/// Nothing is registered in release builds. Read-only commands also work in
/// profile builds; commands that change the app are debug only.
class NyLive {
  NyLive._();

  /// The protocol version reported by the `status` command.
  ///
  /// 1: the first built-in commands, live commands and seeders.
  /// 2: storage snapshots (`storage.export` and `snapshot.import`).
  /// 3: page state (`state.data`).
  /// 4: one Backpack value (`backpack.get`).
  /// 5: removing a Backpack value (`backpack.delete`).
  /// 6: saving a Backpack value (`backpack.set`).
  /// 7: the signed-in sessions (`auth.show`).
  /// 8: deep links (`deeplink.show` and `deeplink.open`).
  static const int protocolVersion = 8;

  /// Prefix of every service extension Nylo registers.
  static const String extensionPrefix = 'ext.nylo.';

  /// The VM service stream route and log events are posted to.
  static const String eventStream = 'nylo';

  /// Commands that only read app state, so they're allowed in profile builds.
  static const Set<String> readOnlyCommands = {
    'status',
    'routes',
    'route.current',
    'deeplink.show',
    'storage.list',
    'storage.get',
    'storage.export',
    'backpack.list',
    'backpack.get',
    'auth.show',
    'state.data',
    'commands.list',
    'seeders.list',
  };

  /// Overrides the debug-build check in tests.
  @visibleForTesting
  static bool? debugBuildOverride;

  /// Receives every event passed to [emit], in addition to the VM service.
  @visibleForTesting
  static void Function(String kind, Map<String, Object?> data)? onEmit;

  static bool _extensionsRegistered = false;
  static bool _loggerAttached = false;

  /// Whether commands that change the app are allowed.
  static bool get isDebugBuild => debugBuildOverride ?? kDebugMode;

  /// Whether the service extensions have been registered in this isolate.
  static bool get isInstalled => _extensionsRegistered;

  /// The names of every built-in command.
  static List<String> get builtInCommands => nyLiveBuiltIns.keys.toList();

  /// The app-defined commands registered on the running Nylo instance.
  static Map<String, LiveCommand Function()> get commands =>
      Nylo.isInitialized() ? Nylo.instance.getLiveCommands() : const {};

  /// The names of the app-defined commands.
  static List<String> get commandNames => commands.keys.toList();

  /// The seeders registered on the running Nylo instance.
  static Map<String, Seeder Function()> get seeders =>
      Nylo.isInitialized() ? Nylo.instance.getSeeders() : const {};

  /// The names of the registered seeders.
  static List<String> get seederNames => seeders.keys.toList();

  /// Registers the service extensions, route observer and log listener.
  ///
  /// Safe to call more than once: extensions are registered once per isolate
  /// and the observer is only added to [nylo] if it isn't there already.
  static void install(Nylo nylo) {
    if (kReleaseMode) return;

    final bool hasObserver = nylo.getNavigatorObservers().any(
      (NavigatorObserver observer) => observer is NyLiveNavigatorObserver,
    );
    if (!hasObserver) {
      nylo.addNavigatorObserver(NyLiveNavigatorObserver());
    }

    if (!_loggerAttached) {
      NyLogger.addListener(_onLog);
      _loggerAttached = true;
    }

    if (_extensionsRegistered) return;
    _extensionsRegistered = true;
    for (final String command in nyLiveBuiltIns.keys) {
      developer.registerExtension(
        '$extensionPrefix$command',
        (String method, Map<String, String> parameters) =>
            handleExtension(command, parameters),
      );
    }
  }

  /// Runs the built-in [command] with [args] and returns its JSON-safe result.
  ///
  /// Throws [LiveException] when the command is unknown, not allowed in
  /// this build mode, or fails.
  static Future<Object?> dispatch(
    String command, [
    Map<String, dynamic> args = const {},
  ]) async {
    final NyLiveHandler? handler = nyLiveBuiltIns[command];
    if (handler == null) {
      throw LiveException('Unknown live command "$command".');
    }
    if (!isDebugBuild && !readOnlyCommands.contains(command)) {
      throw LiveException('"$command" is only available in debug builds.');
    }
    return NyLiveJson.encodable(await handler(args));
  }

  /// Handles a service extension call from Metro.
  @visibleForTesting
  static Future<developer.ServiceExtensionResponse> handleExtension(
    String command,
    Map<String, String> parameters,
  ) async {
    try {
      final Map<String, dynamic> args = decodeArgs(parameters['args']);
      final Object? result = await dispatch(command, args);
      return developer.ServiceExtensionResponse.result(
        jsonEncode({'result': result}),
      );
    } on LiveException catch (e) {
      return developer.ServiceExtensionResponse.error(e.code, e.message);
    } catch (e) {
      return developer.ServiceExtensionResponse.error(
        developer.ServiceExtensionResponse.extensionError,
        e.toString(),
      );
    }
  }

  /// Decodes the JSON-encoded `args` parameter of a service extension call.
  static Map<String, dynamic> decodeArgs(String? raw) {
    if (raw == null || raw.trim().isEmpty) return {};
    final dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      throw const LiveException.invalidParams('"args" must be a JSON object.');
    }
    if (decoded is! Map) {
      throw const LiveException.invalidParams('"args" must be a JSON object.');
    }
    return Map<String, dynamic>.from(decoded);
  }

  /// Posts a `nylo.<kind>` event to the `nylo` VM service stream.
  static void emit(String kind, Map<String, Object?> data) {
    onEmit?.call(kind, data);
    if (kReleaseMode || !_extensionsRegistered) return;
    try {
      developer.postEvent('nylo.$kind', data, stream: eventStream);
    } catch (_) {
      // The VM service isn't available (e.g. an unsupported web runtime).
    }
  }

  static void _onLog(NyLogEntry entry) => emit('log', {
    'type': entry.type,
    'message': entry.message,
    'time': entry.dateTime.toIso8601String(),
  });
}

/// Streams navigation changes to Metro as `nylo.route` events.
class NyLiveNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _emit('push', route, previousRoute);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _emit('pop', route, previousRoute);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _emit('replace', newRoute, oldRoute);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _emit('remove', route, previousRoute);

  void _emit(String action, Route<dynamic>? route, Route<dynamic>? previous) {
    NyLive.emit('route', {
      'action': action,
      'name': route?.settings.name,
      'previous': previous?.settings.name,
    });
  }
}
