import 'package:nylo_support/events/auth_user_event.dart';
import 'package:nylo_support/helpers/backpack.dart';
import 'package:nylo_support/helpers/helper.dart';

/// Authentication class
/// Learn more: https://nylo.dev/docs/5.x/authentication
class Auth {
  /// Set the auth user
  static Future<void> set(dynamic auth, {String? key}) async =>
      await nyEvent<AuthUserEvent>(params: {"auth": auth, "key": key});

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

  /// Check if a user is logged in for a given [key].
  static Future<bool> loggedIn({String? key}) async {
    return (await user()) != null;
  }
}
