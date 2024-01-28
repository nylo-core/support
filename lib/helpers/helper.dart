import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:nylo_support/event_bus/event_bus_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nylo_support/events/events.dart';
import 'package:nylo_support/helpers/auth.dart';
import 'package:nylo_support/helpers/backpack.dart';
import 'package:nylo_support/helpers/extensions.dart';
import 'package:nylo_support/localization/app_localization.dart';
import 'package:nylo_support/networking/ny_api_service.dart';
import 'package:nylo_support/themes/base_theme_config.dart';
import 'package:nylo_support/widgets/event_bus/update_state.dart';
import 'package:theme_provider/theme_provider.dart';
import '/nylo.dart';

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
abstract class Model {
  /// Authenticate the model.
  Future<void> auth({String? key}) async {
    await Auth.set(this, key: key);
  }

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
    if (inBackpack == true) {
      Backpack.instance.set(key, this);
    }
  }

  /// Convert the model toJson.
  toJson() {}

  /// Save an item to a collection
  /// E.g. List of numbers
  ///
  /// User userAnthony = new User(name: 'Anthony');
  /// await userAnthony.saveToCollection('mystoragekey');
  ///
  /// User userKyle = new User(name: 'Kyle');
  /// await userKyle.saveToCollection('mystoragekey');
  ///
  /// Get the collection back with the user included.
  /// List<User> users = await NyStorage.read<List<User>('mystoragekey');
  ///
  /// The [key] is the collection you want to access, you can also save
  /// the collection to the [Backpack] class.
  Future saveToCollection<T>(String key, {bool inBackpack = false}) async {
    await NyStorage.addToCollection<T>(key, item: this);
    if (inBackpack == true) {
      Backpack.instance.set(key, this);
    }
  }
}

/// Storage manager for Nylo.
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

    if (!(object is Model)) {
      return await StorageManager.storage
          .write(key: key, value: object.toString());
    }

    try {
      Map<String, dynamic> json = object.toJson();
      return await StorageManager.storage
          .write(key: key, value: jsonEncode(json));
    } on NoSuchMethodError catch (_) {
      NyLogger.error(
          '[NyStorage.store] ${object.runtimeType.toString()} model needs to implement the toJson() method.');
    }
  }

  /// Read a value from the local storage
  static Future<dynamic> read<T>(String key, {dynamic defaultValue}) async {
    String? data = await StorageManager.storage.read(key: key);
    if (data == null) {
      return defaultValue;
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

    if (T.toString() != 'dynamic') {
      try {
        String? data = await StorageManager.storage.read(key: key);
        if (data == null) return null;
        return dataToModel<T>(data: jsonDecode(data));
      } on Exception catch (e) {
        NyLogger.error(e.toString());
        return null;
      }
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

  /// Deletes a collection from the given [key].
  static Future deleteCollection(String key,
      {bool andFromBackpack = false}) async {
    await delete(key, andFromBackpack: andFromBackpack);
  }

  /// Add a newItem to the collection using a [key].
  static Future addToCollection<T>(String key,
      {required dynamic item, bool allowDuplicates = true}) async {
    List<T> collection = await readCollection<T>(key);
    if (allowDuplicates == false) {
      if (collection.any((collect) => collect == item)) {
        return;
      }
    }
    collection.add(item);
    await saveCollection<T>(key, collection);
  }

  /// Read the collection values using a [key].
  static Future<List<T>> readCollection<T>(String key) async {
    String? data = await read(key);
    if (data == null || data == "") return [];

    List<dynamic> listData = jsonDecode(data);

    if (!["dynamic", "string", "double", "int"]
        .contains(T.toString().toLowerCase())) {
      return List.from(listData)
          .map((json) => dataToModel<T>(data: json))
          .toList();
    }
    return List.from(listData).toList().cast();
  }

  /// Sets the [key] to null.
  static Future clear(String key) async => await NyStorage.store(key, null);

  /// Delete an item of a collection using a [index] and the collection [key].
  static Future deleteFromCollection<T>(int index,
      {required String key}) async {
    List<T> collection = await readCollection<T>(key);
    if (collection.isEmpty) return;
    collection.removeAt(index);
    await saveCollection<T>(key, collection);
  }

  /// Save a list of objects to a [collection] using a [key].
  static Future saveCollection<T>(String key, List collection) async {
    if (["dynamic", "string", "double", "int"]
        .contains(T.toString().toLowerCase())) {
      await store(key, jsonEncode(collection));
      return;
    }

    String json = jsonEncode(collection.map((item) {
      Map<String, dynamic>? data = _objectToJson(item);
      if (data != null) {
        return data;
      }
      return item;
    }).toList());
    await store(key, json);
  }

  /// Delete a value from a collection using a [key] and the [value] you want to remove.
  static Future deleteValueFromCollection<T>(String key,
      {dynamic value}) async {
    List<T> collection = await readCollection<T>(key);
    collection.removeWhere((item) => item == value);
    await saveCollection<T>(key, collection);
  }

  /// Checks if a collection is empty
  static Future<bool> isCollectionEmpty(String key) async =>
      (await readCollection(key)).isEmpty;

  /// Sync all the keys stored to the [Backpack] instance.
  static Future syncToBackpack({bool overwrite = false}) async {
    Map<String, String> values = await readAll();
    Backpack backpack = Backpack.instance;
    for (var data in values.entries) {
      if (overwrite == false && backpack.contains(data.key)) {
        continue;
      }
      dynamic result = await NyStorage.read(data.key);
      Backpack.instance.set(data.key, result);
    }
  }
}

/// Attempts to call toJson() on an [object].
Map<String, dynamic>? _objectToJson(dynamic object) {
  try {
    Map<String, dynamic> json = object.toJson();
    return json;
  } on NoSuchMethodError catch (_) {
    NyLogger.error(
        '[NyStorage.store] ${object.runtimeType.toString()} model needs to implement the toJson() method.');
  }
  return null;
}

/// Checks if the value is an integer.
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

/// Checks if the value is a double.
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
  /// Logs a debug [message] to the console.
  /// It will only print if your app's environment is in debug mode.
  /// You can override this by setting [alwaysPrint] = true.
  static debug(dynamic message, {bool alwaysPrint = false}) {
    _loggerPrint(message ?? "", 'debug', alwaysPrint);
  }

  /// Logs an error [message] to the console.
  /// It will only print if your app's environment is in debug mode.
  /// You can override this by setting [alwaysPrint] = true.
  static error(dynamic message, {bool alwaysPrint = false}) {
    if (message.runtimeType.toString() == 'Exception') {
      _loggerPrint(message.toString(), 'error', alwaysPrint);
    }
    _loggerPrint(message, 'error', alwaysPrint);
  }

  /// Log an info [message] to the console.
  /// It will only print if your app's environment is in debug mode.
  /// You can override this by setting [alwaysPrint] = true.
  static info(dynamic message, {bool alwaysPrint = false}) {
    _loggerPrint(message ?? "", 'info', alwaysPrint);
  }

  /// Dumps a [message] with a tag.
  static dump(dynamic message, String? tag, {bool alwaysPrint = false}) {
    _loggerPrint(message ?? "", tag, alwaysPrint);
  }

  /// Log json data [message] to the console.
  /// It will only print if your app's environment is in debug mode.
  /// You can override this by setting [alwaysPrint] = true.
  static json(dynamic message, {bool alwaysPrint = false}) {
    bool canPrint = (getEnv('APP_DEBUG', defaultValue: true));
    if (!canPrint && !alwaysPrint) return;
    try {
      log(jsonEncode(message));
    } on Exception catch (e) {
      NyLogger.error(e.toString());
    }
  }

  /// Print a new log message
  static _loggerPrint(dynamic message, String? type, bool alwaysPrint) {
    bool canPrint = (getEnv('APP_DEBUG', defaultValue: true));
    bool showLog = Backpack.instance.read('SHOW_LOG', defaultValue: false);
    if (!showLog && !canPrint && !alwaysPrint) return;
    if (showLog) {
      Backpack.instance.set('SHOW_LOG', false);
    }
    try {
      String dateTimeFormatted = "${DateTime.now().toDateTimeString()}";
      print('[$dateTimeFormatted] ${type != null ? "$type " : ""}$message');
    } on Exception catch (_) {
      print('${type != null ? "$type " : ""}$message');
    }
  }
}

/// Return an object from your modelDecoders using [data].
T dataToModel<T>({required dynamic data}) {
  assert(T != dynamic,
      "You must provide a Type from your modelDecoders from within your config/decoders.dart file");
  Nylo nylo = Backpack.instance.nylo();
  Map<Type, dynamic> modelDecoders = nylo.getModelDecoders();
  assert(modelDecoders.containsKey(T),
      "Your modelDecoders variable inside config/decoders.dart must contain a decoder for Type: $T");
  return modelDecoders[T](data);
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

  if (events.isEmpty && Backpack.instance.read('nylo') != null) {
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
    String? baseUrl,
    int? page,
    int? perPage,
    String queryParamPage = "page",
    String? queryParamPerPage,
    int? retry = 0,
    Duration? retryDelay,
    bool Function(DioException dioException)? retryIf,
    bool? shouldSetAuthHeaders,
    List<Type> events = const []}) async {
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

  // add retryIf
  if (retryIf != null) {
    apiService.setRetryIf(retryIf);
  }

  /// [queryParamPage] by default is 'page'
  /// [queryParamPerPage] by default is 'per_page'
  if (page != null) {
    apiService.setPagination(page,
        paramPage: queryParamPage,
        paramPerPage: queryParamPerPage,
        perPage: perPage);
  }

  if (retry != null) {
    apiService.setRetry(retry);
  }

  if (retryDelay != null) {
    apiService.setRetryDelay(retryDelay);
  }

  if (shouldSetAuthHeaders != null) {
    apiService.setShouldSetAuthHeaders(shouldSetAuthHeaders);
  }

  dynamic result = await request(apiService);
  if (events.isNotEmpty) {
    Nylo nylo = Backpack.instance.nylo();

    for (var event in events) {
      NyEvent? nyEvent = nylo.getEvent(event);
      if (nyEvent == null) {
        continue;
      }
      Map<dynamic, NyListener> listeners = nyEvent.listeners;

      if (listeners.isEmpty) {
        return;
      }
      for (NyListener listener in listeners.values.toList()) {
        listener.setEvent(nyEvent);

        dynamic eventResult = await listener.handle({'data': result});
        if (eventResult != null && eventResult == false) {
          break;
        }
      }
    }
  }
  return result;
}

/// Helper to get the color styles
/// Find a color style from the Nylo's [appThemes].
T nyColorStyle<T>(BuildContext context, {String? themeId}) {
  List<AppTheme> appThemes = Nylo.getAppThemes();

  if (themeId == null) {
    AppTheme themeFound = appThemes.firstWhere((theme) {
      if (context.isDarkMode) {
        return theme.id == getEnv('DARK_THEME_ID');
      }
      return theme.id == ThemeProvider.controllerOf(context).currentThemeId;
    }, orElse: () => appThemes.first);
    return (themeFound.options as NyThemeOptions).colors;
  }

  AppTheme themeFound = appThemes.firstWhere((theme) => theme.id == themeId,
      orElse: () => appThemes.first);
  return (themeFound.options as NyThemeOptions).colors;
}

/// Hex Color
Color nyHexColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  return Color(int.parse(hexColor, radix: 16));
}

/// Match a value from a Map of data.
/// It will return null if a match is not found.
T? match<T>(dynamic value, Map<String, dynamic> Function() values) {
  Map<String, dynamic> check = values();
  if (!check.containsKey(value)) {
    NyLogger.error('The value "$value" does not match any values provided');
    return null;
  }
  return check[value];
}

/// If you call [showNextLog] it will force the app to display the next
/// 'NyLogger' log even if your app's APP_DEBUG is set to false.
void showNextLog() {
  Backpack.instance.set('SHOW_LOG', true);
}

/// Update's the state of a NyState Widget in your application.
/// Provide the [name] of the state and then return a value in the callback [setValue].
///
/// Example using data param
/// updateState<double>(NotificationCounter.state, data: {
///   "value": 10
/// });
///
/// Example in your NyState widget
/// @override
/// stateUpdated(dynamic data) async {
///   print(data['value']); // 10
/// }
///
///
/// Example using setValue param
/// updateState<double>(ShoppingCartIcon.state, setValue: (currentValue) {
///   if (currentValue == null) return 1;
///   return (currentValue + 1);
/// });
///
/// updateState<double>(ShoppingCartIcon.state, setValue: (currentValue) {
///   [currentValue] will contain the last value e.g. 1
///   return (currentValue + 1);
/// });
///
/// Example in your NyState widget
/// @override
/// stateUpdated(dynamic data) async {
///   print(data); // 2
/// }
///
void updateState<T>(String name,
    {dynamic data, dynamic Function(T? currentValue)? setValue}) {
  EventBus? eventBus = Backpack.instance.read("event_bus");
  if (eventBus == null) {
    NyLogger.error(
        'Event bus not defined. Please ensure that your project has called nylo.addEventBus() in one of your providers.');
    return;
  }

  dynamic _data = data;
  if (setValue != null) {
    List<EventBusHistoryEntry> eventHistory = eventBus.history
        .where(
            (element) => element.event.runtimeType.toString() == 'UpdateState')
        .toList();
    if (eventHistory.isNotEmpty) {
      T? lastValue = eventHistory.last.event.props[1] as T?;
      _data = setValue(lastValue);
    }
  }

  final event = UpdateState(data: _data, stateName: name);
  eventBus.fire(event);
}

/// api helper
/// Example:
/// ```dart
/// await api<ApiService>((request) => request.get("https://jsonplaceholder.typicode.com/posts"));
/// ```
/// The above example will send an API request and return the data.
api<T extends NyApiService>(dynamic Function(T request) request,
        {BuildContext? context,
        Map<String, dynamic> headers = const {},
        String? bearerToken,
        String? baseUrl,
        int? page,
        String? queryNamePage,
        String? queryNamePerPage,
        int? perPage,
        int? retry,
        Duration? retryDelay,
        bool Function(DioException dioException)? retryIf,
        bool? shouldSetAuthHeaders,
        List<Type> events = const []}) async =>
    await nyApi<T>(
      request: request,
      apiDecoders: Nylo.apiDecoders(),
      context: context,
      headers: headers,
      bearerToken: bearerToken,
      baseUrl: baseUrl,
      events: events,
      page: page,
      perPage: perPage,
      queryParamPage: queryNamePage ?? "page",
      queryParamPerPage: queryNamePerPage,
      retry: retry,
      retryDelay: retryDelay,
      retryIf: retryIf,
      shouldSetAuthHeaders: shouldSetAuthHeaders,
    );

/// Event helper for Nylo
/// Example:
/// ```dart
/// event<LoginEvent>(data: {
///  "User": "#1 User"
///  });
///  ```
///  The above example will send an event to LoginEvent.
event<T>({Map? data}) async =>
    await nyEvent<T>(params: data, events: Nylo.events());

/// Dump a message to the console.
/// Example:
/// ```dart
/// dump("Hello World");
/// ```
dump(dynamic value, {String? tag, bool alwaysPrint = false}) =>
    NyLogger.dump(value, tag, alwaysPrint: alwaysPrint);

/// Sleep for a given amount of milliseconds.
sleep(int seconds) async {
  await Future.delayed(Duration(seconds: seconds));
}
