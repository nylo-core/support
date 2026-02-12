import 'package:recase/recase.dart';

import '/local_storage/ny_local_storage.dart';
import 'backpack.dart';
import 'ny_logger.dart';

/// Nylo's Model class
///
/// Usage
/// class User extends Model {
///   String? name;
///   String? email;
///   User();
///   User.fromJson(dynamic data) {
///     name = data['name'];
///     email = data['email'];
///   }
///   toJson() => {
///     "name": name,
///     "email": email
///   };
/// }
/// This class can be used to authenticate a model and store the object in storage.
class Model<T> {
  String? _key;

  Model({String? key}) {
    _key = key;
  }

  /// Save the object to secure storage using a unique [key].
  /// E.g. User class
  ///
  /// User user = new User();
  /// user.name = "Anthony";
  /// user.save('com.company.app.auth_user');
  ///
  /// Get user
  /// `User user = await NyStorage.read<User>('com.company.app.auth_user', model: new User());`
  Future save({bool inBackpack = false}) async {
    if (_key == null) {
      NyLogger.error(
        'static StorageKey key = "${runtimeType.toString()}" is not defined for ${runtimeType.toString()}. Please define a key for this model.'
        '${runtimeType.toString()}() : super(key: key);'
        '',
      );
      return;
    }
    await NyStorage.save(_key!, this);
    if (inBackpack) {
      Backpack.instance.save(_key!, this);
    }
  }

  /// Convert the model to a JSON map. Override this in subclasses.
  Map<String, dynamic> toJson() => {};

  /// Attempt to login a user using a [storageKey].
  Future<bool> syncToBackpack() async {
    if (_key == null) {
      NyLogger.error(
        'The storageKey is not defined for ${runtimeType.toString()}. Please define a storageKey for this model.',
      );
      return false;
    }

    dynamic authUser = await NyStorage.read<T>(_key!);
    if (authUser != null) {
      Backpack.instance.save(_key!, authUser);
      return true;
    }
    return false;
  }

  /// Save an item to a collection.
  ///
  /// Example:
  /// ```dart
  /// User userAnthony = User(name: 'Anthony');
  /// await userAnthony.saveToCollection();
  ///
  /// User userKyle = User(name: 'Kyle');
  /// await userKyle.saveToCollection();
  ///
  /// // Get the collection back with the users included.
  /// List<User> users = await NyStorage.read<List<User>>('user');
  /// ```
  ///
  /// You can also save the collection to the [Backpack] class using [inBackpack].
  Future saveToCollection({bool inBackpack = false}) async {
    if (_key == null) {
      NyLogger.error(
        'static StorageKey key = "${(runtimeType.toString()).snakeCase}" is not defined for ${runtimeType.toString()}, please define a key.'
        '\n\nExample:\nstatic StorageKey key = "${(runtimeType.toString()).snakeCase}";\n${runtimeType.toString()}() : super(key: key);'
        '',
      );
      return;
    }
    await NyStorage.addToCollection<T>(_key!, item: this as T);
    if (inBackpack) {
      Backpack.instance.save(_key!, this);
    }
  }
}
