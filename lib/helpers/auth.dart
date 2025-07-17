import 'package:dio/dio.dart';
import '/networking/ny_api_service.dart';
import '/nylo.dart';
import 'package:uuid/uuid.dart';
import '/local_storage/local_storage.dart';
import '/helpers/backpack.dart';
import 'model.dart';

/// HasApiService mixin
mixin HasApiService<T extends NyApiService> {
  /// Get the ApiService
  T? _apiService;

  /// Set the onSuccess callback
  void onApiSuccess(Function(Response response, dynamic data) onSuccess) {
    _apiService ??= apiService;
    _apiService!.onSuccess(onSuccess);
  }

  /// Set the onError callback
  void onApiError(Function(dynamic error) onError) {
    _apiService ??= apiService;
    _apiService!.onError(onError);
  }

  /// Get the ApiService
  T get apiService {
    return _apiService ??= (Nylo.apiDecoder<T>() as T);
  }
}

/// Authentication class
/// Learn more: https://nylo.dev/docs/6.x/authentication
class Auth {
  /// Get the auth key
  static String key() => Nylo.authKey();

  /// Authenticate user
  static Future<void> authenticate({dynamic data}) async {
    if (data != null) {
      assert(data is Map || data is Model, '''Data must be a Map or a Model
      Example:
      Auth.authenticate(data: {
        "token": "abc123",
      });
      or
      Auth.authenticate(data: user);''');
      if (data is Model) {
        data = data.toJson();
      }
    }
    await NyStorage.saveJson(
      key(),
      data ??= {
        "date": DateTime.now().toIso8601String(),
      },
      inBackpack: true,
    );
  }

  /// Logout auth.
  static Future logout() async {
    await NyStorage.delete(key(), andFromBackpack: true);
  }

  /// Check if the user is authenticated.
  static Future<bool> isAuthenticated() async {
    return (await Nylo.user()) != null;
  }

  /// Get the user data.
  static dynamic data({String? key}) {
    if (key != null) {
      Map<String, dynamic>? bpData = Backpack.instance.read(key);
      return (bpData?.containsKey(key) ?? false) ? bpData![key] : null;
    }
    return Backpack.instance.read(Auth.key());
  }

  /// Update the auth user data.
  static Future<void> update(Function(dynamic data) update) async {
    dynamic data = await NyStorage.read(key());
    dynamic updatedData = await update(data);
    await authenticate(data: updatedData);
  }

  /// Get the device id.
  static Future<String?> deviceId() async {
    String key = "ny_device_id";
    String? deviceUid = await NyStorage.read(key);
    if (deviceUid == null) {
      Uuid uuid = const Uuid();
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      deviceUid = "${uuid.v4()}-${timestamp.toString()}";
      await NyStorage.save(key, deviceUid);
    }
    return deviceUid;
  }

  /// Sync the auth user data to the backpack.
  static Future<void> syncToBackpack() async {
    dynamic data = await NyStorage.readJson(key());
    Backpack.instance.save(key(), data);
  }
}

/// Authenticate user
Future<void> authAuthenticate({dynamic data}) async {
  await Auth.authenticate(data: data);
}

/// Logout user
Future<void> authLogout() async {
  await Auth.logout();
}

/// Check if the user is authenticated
Future<bool> authIsAuthenticated() async {
  return await Auth.isAuthenticated();
}

/// Get the user data
dynamic authData({String? key}) {
  return Auth.data(key: key);
}

/// Update the auth user data
Future<void> authUpdate(Function(dynamic data) update) async {
  await Auth.update(update);
}

/// Sync the auth user data to the backpack
Future<void> authSyncToBackpack() async {
  await Auth.syncToBackpack();
}

/// Get the auth key
String authKey() {
  return Auth.key();
}

/// Get the device id
Future<String?> authDeviceId() async {
  return await Auth.deviceId();
}
