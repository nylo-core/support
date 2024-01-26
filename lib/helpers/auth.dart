import 'package:nylo_support/events/auth_user_event.dart';
import 'package:nylo_support/helpers/backpack.dart';
import 'package:nylo_support/helpers/extensions.dart';
import 'package:nylo_support/helpers/helper.dart';

/// Authentication class
/// Learn more: https://nylo.dev/docs/5.x/authentication
class Auth {
  /// Set the auth user
  static Future<void> set(dynamic auth, {String? key}) async =>
      await nyEvent<AuthUserEvent>(params: {"auth": auth, "key": key});

  /// Login a auth user for a given [key].
  static Future login(dynamic auth, {String? key}) async =>
      await set(auth, key: key);

  /// Get the auth user
  static T? user<T>({String? key}) {
    if (key != null) {
      return Backpack.instance.auth<T>(key: key);
    }
    return Backpack.instance.auth<T>();
  }

  /// Remove the auth user for a given [key].
  static Future remove({String? key}) async {
    String storageKey = getEnv('AUTH_USER_KEY', defaultValue: 'AUTH_USER');
    if (key != null) {
      storageKey = key;
    }
    await NyStorage.delete(storageKey, andFromBackpack: true);
  }

  /// Logout the auth user for a given [key].
  static Future logout({String? key}) async => await remove(key: key);

  /// Check if a user is logged in for a given [key].
  static Future<bool> loggedIn({String? key}) async {
    return (await user(key: key)) != null;
  }

  /// Login a model into the app.
  /// [key] that the user was stored under.
  /// [toModel] is a function that converts the data into a model.
  /// the [data] parameter will contain the data that was stored in the storage.
  /// Example:
  /// ```dart
  /// await Auth.loginModel('my_auth_key', (data) => Customer.fromJson(data));
  /// ```
  static loginModel(String key, Model Function(dynamic data) toModel) async {
    dynamic object = await NyStorage.read(key);
    if (object == null) return;

    if (object is String) {
      object = object.toJson();
    }
    Model model = toModel(object);

    Backpack.instance.set(key, model);
  }
}
