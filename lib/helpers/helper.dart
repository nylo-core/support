import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import '/event_bus/event_bus_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/events/events.dart';
import '/helpers/auth.dart';
import '/helpers/backpack.dart';
import '/helpers/extensions.dart';
import '/localization/app_localization.dart';
import '/networking/ny_api_service.dart';
import '/themes/base_theme_config.dart';
import '/widgets/event_bus/update_state.dart';
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
  static FlutterSecureStorage manager() {
    return StorageManager.storage;
  }

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

  /// Saves a JSON [object] to local storage.
  static Future storeJson(String key, object, {bool inBackpack = false}) async {
    if (inBackpack == true) {
      Backpack.instance.set(key, object);
    }

    try {
      return await StorageManager.storage
          .write(key: key, value: jsonEncode(object));
    } on Exception catch (e) {
      NyLogger.error(e.toString());
      NyLogger.error(
          '[NyStorage.store] Failed to store $object to local storage. Please ensure that the object is a valid JSON object.');
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
        return dataToModel<T>(data: jsonDecode(data));
      } on Exception catch (e) {
        NyLogger.error(e.toString());
        return null;
      }
    }
    return data;
  }

  /// Read a JSON value from the local storage
  static Future<dynamic> readJson<T>(String key, {dynamic defaultValue}) async {
    String? data = await StorageManager.storage.read(key: key);
    if (data == null) {
      return defaultValue;
    }

    try {
      return jsonDecode(data);
    } on Exception catch (e) {
      NyLogger.error(e.toString());
      return null;
    }
  }

  /// Deletes all keys with associated values.
  static Future deleteAll({bool andFromBackpack = false}) async {
    if (andFromBackpack == true) {
      Backpack.instance.deleteAll();
    }
    await StorageManager.storage.deleteAll();
  }

  /// Update a value in the local storage by [index].
  static Future<bool> updateCollectionByIndex<T>(
      int index, T Function(T item) object,
      {required String key}) async {
    List<T> collection = await readCollection<T>(key);

    // Check if the collection is empty or the index is out of bounds
    if (collection.isEmpty || index < 0 || index >= collection.length) {
      NyLogger.error(
          '[NyStorage.updateCollectionByIndex] The collection is empty or the index is out of bounds.');
      return false;
    }

    // Update the item
    T newItem = object(collection[index]);

    collection[index] = newItem;

    await saveCollection<T>(key, collection);
    return true;
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

  /// Delete item(s) from a collection using a where query.
  static Future deleteFromCollectionWhere<T>(bool Function(dynamic value) where,
      {required String key}) async {
    List<T> collection = await readCollection<T>(key);
    if (collection.isEmpty) return;

    collection.removeWhere((value) => where(value));

    await saveCollection<T>(key, collection);
  }

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
  } on NoSuchMethodError catch (e) {
    NyLogger.debug(e.toString());
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
T? match<T>(dynamic value, Map<String, dynamic> Function() values,
    {dynamic defaultValue}) {
  Map<String, dynamic> check = values();
  if (!check.containsKey(value)) {
    NyLogger.error('The value "$value" does not match any values provided');
    if (defaultValue != null) {
      return defaultValue;
    } else {
      return null;
    }
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

/// [StateAction] class
class StateAction {
  static refreshPage(String state, {Function()? setState}) {
    _updateState(state, "refresh-page", {"setState": setState});
  }

  /// Pop the page
  static pop(String state, {dynamic result}) {
    _updateState(state, "pop", {"setState": result});
  }

  /// Displays a Toast message containing "Sorry" for the title, you
  /// only need to provide a [description].
  static showToastSorry(String state,
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    _updateState(state, "toast-sorry", {
      "title": title ?? "Sorry",
      "description": description,
      "style": style ?? ToastNotificationStyleType.DANGER
    });
  }

  /// Displays a Toast message containing "Warning" for the title, you
  /// only need to provide a [description].
  static showToastWarning(String state,
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    _updateState(state, "toast-warning", {
      "title": title ?? "Warning",
      "description": description,
      "style": style ?? ToastNotificationStyleType.WARNING
    });
  }

  /// Displays a Toast message containing "Info" for the title, you
  /// only need to provide a [description].
  static showToastInfo(String state,
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    _updateState(state, "toast-info", {
      "title": title ?? "Info",
      "description": description,
      "style": style ?? ToastNotificationStyleType.INFO
    });
  }

  /// Displays a Toast message containing "Error" for the title, you
  /// only need to provide a [description].
  static showToastDanger(String state,
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    _updateState(state, "toast-danger", {
      "title": title ?? "Error",
      "description": description,
      "style": style ?? ToastNotificationStyleType.DANGER
    });
  }

  /// Displays a Toast message containing "Oops" for the title, you
  /// only need to provide a [description].
  static showToastOops(String state,
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    _updateState(state, "toast-oops", {
      "title": title ?? "Oops",
      "description": description,
      "style": style ?? ToastNotificationStyleType.DANGER
    });
  }

  /// Displays a Toast message containing "Success" for the title, you
  /// only need to provide a [description].
  static showToastSuccess(String state,
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    _updateState(state, "toast-success", {
      "title": title ?? "Success",
      "description": description,
      "style": style ?? ToastNotificationStyleType.SUCCESS
    });
  }

  /// Display a custom Toast message.
  static showToastCustom(String state,
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    _updateState(state, "toast-custom", {
      "title": title ?? "",
      "description": description,
      "style": style ?? ToastNotificationStyleType.CUSTOM
    });
  }

  /// Validate data from your widget.
  static validate(String state,
      {required Map<String, dynamic> rules,
      Map<String, dynamic>? data,
      Map<String, dynamic>? messages,
      bool showAlert = true,
      Duration? alertDuration,
      ToastNotificationStyleType alertStyle =
          ToastNotificationStyleType.WARNING,
      required Function()? onSuccess,
      Function(Exception exception)? onFailure,
      String? lockRelease}) {
    _updateState(state, "validate", {
      "rules": rules,
      "data": data,
      "messages": messages,
      "showAlert": showAlert,
      "alertDuration": alertDuration,
      "alertStyle": alertStyle,
      "onSuccess": onSuccess,
      "onFailure": onFailure,
      "lockRelease": lockRelease,
    });
  }

  /// Update the language in the application
  static changeLanguage(String state,
      {required String language, bool restartState = true}) {
    _updateState(state, "change-language", {
      "language": language,
      "restartState": restartState,
    });
  }

  /// Perform a confirm action
  static confirmAction(String state,
      {required Function() action,
      required String title,
      String dismissText = "Cancel"}) async {
    _updateState(state, "confirm-action",
        {"action": action, "title": title, "dismissText": dismissText});
  }

  /// Updates the page [state]
  /// Provide an [action] and [data] to call a method in the [NyState].
  static void _updateState(String state, String action, dynamic data) {
    updateState(state, data: {"action": action, "data": data});
  }
}

/// Nylo's Scheduler class
/// This class is used to schedule tasks to run at a later time.
class NyScheduler {
  /// The prefix for the scheduler
  static final prefix = "ny_scheduler_";

  /// The secure storage instance
  static final FlutterSecureStorage _secureStorage = NyStorage.manager();

  /// Read a value from the local storage
  /// Provide a [name] for the value you want to read.
  static Future<String?> readValue(String name) async {
    return await _secureStorage.read(key: prefix + name);
  }

  /// Read a boolean value from the local storage
  /// Provide a [name] for the value you want to read.
  static Future<bool> readBool(String name) async {
    return (await readValue(prefix + name) ?? "") == "true";
  }

  /// Write a value to the local storage
  /// Provide a [name] for the value and a [value] to write.
  static Future writeValue(String name, String value) async {
    return await _secureStorage.write(key: prefix + name, value: value);
  }

  /// Run a function once
  /// Provide a [name] for the function and a [callback] to execute.
  /// The function will only execute once.
  ///
  /// Example:
  /// ```dart
  /// NyScheduler.once("myFunction", () {
  ///  print("This will only execute once");
  ///  });
  ///  ```
  ///  The above example will only execute once.
  ///  The next time you call NyScheduler.once("myFunction", () {}) it will not execute.
  static taskOnce(String name, Function() callback) async {
    String key = name + "_once";
    bool alreadyExecuted = await readBool(key);
    if (!alreadyExecuted) {
      await callback();
      await writeValue(key, "true");
    }
  }

  /// Run a task daily
  /// Provide a [name] for the function and a [callback] to execute.
  /// The function will execute every day.
  /// You can also provide an [endAt] date to stop the task from running.
  /// You can also provide a [frequency] to run the task weekly, monthly or yearly.
  /// Example:
  /// ```dart
  /// NyScheduler.taskDaily("myFunction", () {
  ///   print("This will execute every day");
  /// });
  /// ```
  /// The above example will execute every day.
  static taskDaily(String name, Function() callback, {DateTime? endAt}) async {
    if (endAt != null && !endAt.isInFuture()) {
      return;
    }

    String key = name + "_daily";
    String? lastTime = await readValue(key);

    if (lastTime == null || lastTime.isEmpty) {
      await _executeTaskAndSetDateTime(key, callback);
      return;
    }

    DateTime todayDateTime = DateTime.now();
    DateTime lastDateTime = DateTime.parse(lastTime);
    Duration difference = todayDateTime.difference(lastDateTime);
    bool canExecute = (difference.inDays >= 1);

    if (canExecute) {
      // set the time
      await _executeTaskAndSetDateTime(key, callback);
    }
  }

  /// Execute a task
  static _executeTaskAndSetDateTime(String key, Function() callback) async {
    DateTime dateTime = DateTime.now();
    await writeValue(key, dateTime.toString());

    await callback();
  }

  /// Run a task after date
  /// Provide a [name] for the function and a [callback] to execute.
  /// The function will execute after the [date] provided.
  /// Example:
  /// ```dart
  /// NyScheduler.taskAfterDate("myFunction", () {
  ///   print("This will execute after the date");
  /// }, date: DateTime.now().add(Duration(days: 1)));
  /// ```
  /// The above example will execute after the date provided.
  static taskOnceAfterDate(String name, Function() callback,
      {required DateTime date}) async {
    String key = name + "_after_date";

    /// Check if we have already executed the task
    bool alreadyExecuted = await readBool(key);
    if (alreadyExecuted) {
      return;
    }

    if (date.isInPast()) {
      await callback();
      await writeValue(key, "true");
    }
  }
}
