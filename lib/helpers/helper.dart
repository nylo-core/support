import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:nylo_support/events/events.dart';
import 'package:nylo_support/helpers/backpack.dart';
import 'package:nylo_support/localization/app_localization.dart';

/// Returns a value from the .env file
/// the [key] must exist as a string value e.g. APP_NAME.
///
/// Returns a String|bool|null|dynamic
/// depending on the value type.
dynamic getEnv(String key, {dynamic defaultValue}) {
  if (!dotenv.env.containsKey(key) && defaultValue != null) {
    return defaultValue;
  }

  String? value = dotenv.env[key];

  if (value == 'null' || value == null) {
    return null;
  }

  if (value.toLowerCase() == 'true') {
    return true;
  }

  if (value.toLowerCase() == 'false') {
    return false;
  }

  return value.toString();
}

/// Returns the full image path for a image in /public/assets/images/ directory.
/// Provide the name of the image, using [imageName] parameter.
///
/// Returns a [String].
String getImageAsset(String imageName) =>
    "${getEnv("ASSET_PATH_IMAGES")}/$imageName";

/// Returns the full path for an asset in /public/assets directory.
/// Usage e.g. getPublicAsset('videos/welcome.mp4');
///
/// Returns a [String].
String getPublicAsset(String asset) => "${getEnv("ASSET_PATH_PUBLIC")}/$asset";

/// Returns a text theme for a app font.
/// Returns a [TextTheme].
TextTheme getAppTextTheme(TextStyle appThemeFont, TextTheme textTheme) {
  return TextTheme(
    displayLarge: appThemeFont.merge(textTheme.displayLarge),
    displayMedium: appThemeFont.merge(textTheme.displayMedium),
    displaySmall: appThemeFont.merge(textTheme.displaySmall),
    headlineLarge: appThemeFont.merge(textTheme.headlineLarge),
    headlineMedium: appThemeFont.merge(textTheme.headlineMedium),
    headlineSmall: appThemeFont.merge(textTheme.headlineSmall),
    titleLarge: appThemeFont.merge(textTheme.titleLarge),
    titleMedium: appThemeFont.merge(textTheme.titleMedium),
    titleSmall: appThemeFont.merge(textTheme.titleSmall),
    bodyLarge: appThemeFont.merge(textTheme.bodyLarge),
    bodyMedium: appThemeFont.merge(textTheme.bodyMedium),
    bodySmall: appThemeFont.merge(textTheme.bodySmall),
    labelLarge: appThemeFont.merge(textTheme.labelLarge),
    labelMedium: appThemeFont.merge(textTheme.labelMedium),
    labelSmall: appThemeFont.merge(textTheme.labelSmall),
  );
}

/// Extensions for String
extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${this.substring(1)}";
}

/// Storable class to implement local storage for Models.
/// This class can be used to then storage models using the [NyStorage] class.
abstract class Storable {
  /// Return a representation of the model class.
  /// E.g. Product class
  ///
  ///import 'package:nylo_support/helpers/helper.dart';
  ///
  /// class Product extends Storable {
  /// ...
  ///   @override
  ///   toStorage() {
  ///     return {
  ///       "title": title,
  ///       "price": price,
  ///       "imageUrl": imageUrl
  ///     };
  ///   }
  /// }
  ///

  toStorage() {
    return {};
  }

  /// Used to initialize the object using the [data] parameter.
  /// E.g. Product class
  ///
  ///import 'package:nylo_support/helpers/helper.dart';
  ///
  /// class Product extends Storable {
  /// ...
  ///   @override
  ///   fromStorage(dynamic data) {
  ///     this.title = data["title"];
  ///     this.price = data["price"];
  ///     this.imageUrl = data["imageUrl"];
  ///   }
  /// }
  ///
  fromStorage(dynamic data) {}

  /// Save the object to secure storage using a unique [key].
  /// E.g. User class
  ///
  /// User user = new User();
  /// user.name = "Anthony";
  /// user.save('com.company.app.auth_user');
  ///
  /// Get user
  /// User user = await NyStorage.read<User>('com.company.app.auth_user', model: new User());
  Future save(String key, {bool inBackpack = false}) async {
    await NyStorage.store(key, this);
    if (inBackpack) {
      Backpack.instance.set(key, this);
    }
  }

  /// Read a [key] value from NyStorage
  Future read(String key) async {
    dynamic data = await NyStorage.read(key);
    if (data == null) {
      return null;
    }
    this.fromStorage(jsonDecode(data));
    return this;
  }
}

class StorageManager {
  static final storage = new FlutterSecureStorage();
}

/// Base class to help manage local storage
class NyStorage {
  /// Saves an [object] to local storage.
  static Future store(String key, object, {bool inBackpack = false}) async {
    if (inBackpack == true) {
      Backpack.instance.set(key, object);
    }

    if (object is String) {
      return await StorageManager.storage.write(key: key, value: object);
    }

    if (object is int) {
      return await StorageManager.storage
          .write(key: key, value: object.toString());
    }

    if (object is double) {
      return await StorageManager.storage
          .write(key: key, value: object.toString());
    }

    if (object is Storable) {
      return await StorageManager.storage
          .write(key: key, value: jsonEncode(object.toStorage()));
    }

    return await StorageManager.storage
        .write(key: key, value: object.toString());
  }

  /// Read a value from the local storage
  static Future<dynamic> read<T>(String key, {Storable? model}) async {
    String? data = await StorageManager.storage.read(key: key);
    if (data == null) {
      return null;
    }

    if (model != null) {
      try {
        String? data = await StorageManager.storage.read(key: key);
        if (data == null) {
          return null;
        }

        model.fromStorage(jsonDecode(data));
        return model;
      } on Exception catch (e) {
        print(e.toString());
      }
    }

    if (T.toString() == "String") {
      return data.toString();
    }

    if (T.toString() == "int") {
      return int.parse(data.toString());
    }

    if (T.toString() == "double") {
      return double.parse(data);
    }

    if (_isInteger(data)) {
      return int.parse(data);
    }

    if (_isDouble(data)) {
      return double.parse(data);
    }

    return data;
  }

  /// Deletes all keys with associated values.
  static Future deleteAll({bool andFromBackpack = false}) async {
    if (andFromBackpack == true) {
      Backpack.instance.deleteAll();
    }
    await StorageManager.storage.deleteAll();
  }

  /// Decrypts and returns all keys with associated values.
  static Future<Map<String, String>> readAll() async =>
      await StorageManager.storage.readAll();

  /// Deletes associated value for the given [key].
  static Future delete(String key, {bool andFromBackpack = false}) async {
    if (andFromBackpack == true) {
      Backpack.instance.delete(key);
    }
    return await StorageManager.storage.delete(key: key);
  }

  /// Sync all the keys stored to the [Backpack] instance.
  Future syncToBackpack() async {
    Map<String, String> values = await readAll();
    for (var data in values.entries) {
      Backpack.instance.set(data.key, data.value);
    }
  }
}

bool _isInteger(String? s) {
  if (s == null) {
    return false;
  }

  RegExp regExp = new RegExp(
    r"^-?[0-9]+$",
    caseSensitive: false,
    multiLine: false,
  );

  return regExp.hasMatch(s);
}

bool _isDouble(String? s) {
  if (s == null) {
    return false;
  }

  RegExp regExp = new RegExp(
    r"^[0-9]{1,13}([.]?[0-9]*)?$",
    caseSensitive: false,
    multiLine: false,
  );

  return regExp.hasMatch(s);
}

/// Logger used for messages you want to print to the console.
class NyLogger {
  Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 100,
      colors: true,
      printEmojis: false,
      printTime: true,
    ),
  );

  NyLogger.debug(String? message) {
    _logger.d(message);
  }

  NyLogger.error(String message) {
    _logger.e(message);
  }

  NyLogger.info(String message) {
    _logger.i(message);
  }
}

/// Returns the translation value from the [key] you provide.
/// E.g. trans("hello")
/// lang translation will be returned for the app locale.
String trans(String key, {Map<String, String>? arguments}) =>
    NyLocalization.instance.translate(key, arguments);

/// Event helper
nyEvent<T>({
  Map? params,
  Map<Type, NyEvent> events = const {},
}) async {
  assert(T.toString() != 'dynamic',
      'You must provide an Event type for this method.\nE.g. event<LoginEvent>({"User": "#1 User"});');

  Map<Type, NyEvent> appEvents = events;

  if (events.isEmpty) {
    appEvents = Backpack.instance.read('nylo').getEvents();
  }
  assert(appEvents.containsKey(T),
      'Your config/events.dart is missing this class ${T.toString()}');

  NyEvent nyEvent = appEvents[T]!;
  Map<dynamic, NyListener> listeners = nyEvent.listeners;

  if (listeners.isEmpty) {
    return;
  }
  for (NyListener listener in listeners.values.toList()) {
    listener.setEvent(nyEvent);
    dynamic result = await listener.handle(params);
    if (result != null && result == false) {
      break;
    }
  }
}

/// API helper
Future<dynamic> nyApi<T>(
    {required dynamic Function(T) request,
    Map<Type, dynamic> apiDecoders = const {},
    BuildContext? context,
    Map<String, dynamic> headers = const {},
    String? bearerToken,
    String? baseUrl}) async {
  assert(apiDecoders.containsKey(T),
      'Your config/decoders.dart is missing this class ${T.toString()} in apiDecoders.');

  dynamic apiService = apiDecoders[T];

  if (context != null) {
    apiService.setContext(context);
  }

  // add headers
  if (headers.isNotEmpty) {
    apiService.setHeaders(headers);
  }

  // add bearer token
  if (bearerToken != null) {
    apiService.setBearerToken(bearerToken);
  }

  // add baseUrl
  if (baseUrl != null) {
    apiService.setBaseUrl(baseUrl);
  }

  return await request(apiService);
}
