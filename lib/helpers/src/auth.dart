import '/nylo.dart';
import 'package:uuid/uuid.dart';
import '/local_storage/ny_local_storage.dart';
import 'backpack.dart';
import 'model.dart';

/// Authentication class for managing user sessions.
///
/// Supports multiple named sessions for different auth contexts
/// (e.g., user auth, device auth, etc.).
///
/// Learn more: https://nylo.dev/docs/7.x/authentication
///
/// Example:
/// ```dart
/// // Default session (user)
/// await Auth.authenticate(data: user);
/// Auth.data(field: 'token');
///
/// // Named session (device)
/// await Auth.authenticate(data: device, session: 'device');
/// Auth.data(session: 'device');
/// ```
class Auth {
  /// The default session name.
  static const String defaultSession = 'default';

  /// Storage key for device ID.
  static const String _deviceIdKey = 'ny_device_id';

  /// Get the storage key for a session.
  ///
  /// When [session] is null or 'default', returns the base auth key.
  /// Otherwise, returns a namespaced key like 'auth_key_sessionName'.
  static String key([String? session]) {
    final baseKey = Nylo.authKey();
    if (session == null || session == defaultSession) {
      return baseKey;
    }
    return '${baseKey}_$session';
  }

  /// Authenticate and store session data.
  ///
  /// [data] can be a [Map] or a [Model]. If null, stores a timestamp.
  /// [session] specifies which auth session to use (default: 'default').
  ///
  /// Example:
  /// ```dart
  /// await Auth.authenticate(data: user);
  /// await Auth.authenticate(data: device, session: 'device');
  /// ```
  static Future<void> authenticate({dynamic data, String? session}) async {
    if (data != null) {
      assert(
        data is Map || data is Model,
        'Data must be a Map or a Model. Example:\n'
        'Auth.authenticate(data: {"token": "abc123"});\n'
        'or\n'
        'Auth.authenticate(data: user);',
      );
      if (data is Model) {
        data = data.toJson();
      }
    }

    final authData = data ?? {"date": DateTime.now().toIso8601String()};
    await NyStorage.saveJson(key(session), authData, inBackpack: true);
  }

  /// Logout from a specific session.
  ///
  /// [session] specifies which auth session to logout from (default: 'default').
  static Future<void> logout({String? session}) async {
    await NyStorage.delete(key(session), andFromBackpack: true);
  }

  /// Logout from all known sessions.
  ///
  /// [sessions] is a list of session names to logout from.
  /// Always includes the default session.
  static Future<void> logoutAll({List<String> sessions = const []}) async {
    await logout(); // Default session
    for (final session in sessions) {
      if (session != defaultSession) {
        await logout(session: session);
      }
    }
  }

  /// Check if a session is authenticated.
  ///
  /// [session] specifies which auth session to check (default: 'default').
  static Future<bool> isAuthenticated({String? session}) async {
    final data = await NyStorage.read(key(session));
    return data != null;
  }

  /// Get auth data for a session.
  ///
  /// [field] returns a specific field from the auth data.
  /// [session] specifies which auth session to read from (default: 'default').
  ///
  /// Example:
  /// ```dart
  /// Auth.data();                              // Full user data
  /// Auth.data(field: 'token');                // User's token
  /// Auth.data(session: 'device');             // Full device data
  /// Auth.data(field: 'id', session: 'device'); // Device's ID
  /// ```
  static dynamic data({String? field, String? session}) {
    final authData = Backpack.instance.read(key(session));
    if (field != null && authData is Map) {
      return authData[field];
    }
    return authData;
  }

  /// Update the auth data for a session.
  ///
  /// [update] is a callback that receives current data and returns updated data.
  /// [session] specifies which auth session to update (default: 'default').
  static Future<void> set(
    dynamic Function(dynamic data) update, {
    String? session,
  }) async {
    final currentData = await NyStorage.readJson(key(session));
    final updatedData = update(currentData);
    await authenticate(data: updatedData, session: session);
  }

  /// Get or generate a unique device ID.
  ///
  /// The device ID is generated once and persisted across app sessions.
  static Future<String> deviceId() async {
    String? deviceUid = await NyStorage.read(_deviceIdKey);
    if (deviceUid == null) {
      const uuid = Uuid();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      deviceUid = "${uuid.v4()}-$timestamp";
      await NyStorage.save(_deviceIdKey, deviceUid);
    }
    return deviceUid;
  }

  /// Sync auth data from storage to backpack for a session.
  ///
  /// [session] specifies which auth session to sync (default: 'default').
  static Future<void> syncToBackpack({String? session}) async {
    final sessionKey = key(session);
    final data = await NyStorage.readJson(sessionKey);
    Backpack.instance.save(sessionKey, data);
  }

  /// Sync all sessions to backpack.
  ///
  /// [sessions] is a list of additional session names to sync.
  /// Always includes the default session.
  static Future<void> syncAllToBackpack({
    List<String> sessions = const [],
  }) async {
    await syncToBackpack(); // Default session
    for (final session in sessions) {
      if (session != defaultSession) {
        await syncToBackpack(session: session);
      }
    }
  }
}

/// Authenticate a session.
///
/// [data] can be a Map or Model. [session] specifies the auth session.
Future<void> authAuthenticate({dynamic data, String? session}) async {
  await Auth.authenticate(data: data, session: session);
}

/// Logout from a session.
///
/// [session] specifies which auth session to logout from.
Future<void> authLogout({String? session}) async {
  await Auth.logout(session: session);
}

/// Logout from all sessions.
///
/// [sessions] is a list of session names to logout from.
Future<void> authLogoutAll({List<String> sessions = const []}) async {
  await Auth.logoutAll(sessions: sessions);
}

/// Check if a session is authenticated.
///
/// [session] specifies which auth session to check.
Future<bool> authIsAuthenticated({String? session}) async {
  return await Auth.isAuthenticated(session: session);
}

/// Get auth data for a session.
///
/// [field] returns a specific field. [session] specifies which auth session.
dynamic authData({String? field, String? session}) {
  return Auth.data(field: field, session: session);
}

/// Update auth data for a session.
///
/// [update] receives current data and returns updated data.
/// [session] specifies which auth session to update.
Future<void> authSet(
  dynamic Function(dynamic data) update, {
  String? session,
}) async {
  await Auth.set(update, session: session);
}

/// Sync auth data to backpack for a session.
///
/// [session] specifies which auth session to sync.
Future<void> authSyncToBackpack({String? session}) async {
  await Auth.syncToBackpack(session: session);
}

/// Get the storage key for a session.
///
/// [session] specifies which auth session.
String authKey([String? session]) {
  return Auth.key(session);
}

/// Get the device ID.
Future<String> authDeviceId() async {
  return await Auth.deviceId();
}
