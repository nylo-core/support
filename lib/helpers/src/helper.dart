import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:app_badge_plus/app_badge_plus.dart';
import '/events/ny_events.dart' show NyEvent, NyListener, NyEventExtension;
import 'backpack.dart';
import '/localization/ny_localization.dart';
import '/networking/ny_networking.dart';
import '/themes/ny_themes.dart';
import '/nylo.dart';
import 'ny_env.dart';
import 'ny_logger.dart';

/// Returns a value from the generated env.g.dart file.
/// The [key] must exist as a string value e.g. APP_NAME.
///
/// Before using this function, ensure you have:
/// 1. Run `metro make:key` to generate an APP_KEY
/// 2. Run `metro make:env` to generate your env.g.dart file
/// 3. Registered the Env class in your app_provider.dart:
///    `nylo.addEnv(Env.get);`
///
/// Returns a String|bool|null|dynamic depending on the value type.
dynamic getEnv(String key, {dynamic defaultValue}) {
  return NyEnvRegistry.get(key, defaultValue: defaultValue);
}

/// Returns the full image path for a image in /assets/images/ directory.
/// Provide the name of the image, using [imageName] parameter.
///
/// Returns a [String].
String getImageAsset(String imageName, {String? path = '/images'}) =>
    getAsset("$path/$imageName");

/// Returns the full path for an asset in /assets directory.
/// Usage e.g. getAsset('videos/welcome.mp4');
///
/// Returns a [String].
String getAsset(String asset) {
  // remove the first slash if it exists
  if (asset.startsWith('/')) {
    asset = asset.substring(1);
  }
  return "${getEnv("ASSET_PATH")}/$asset";
}

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

/// Return an object from your modelDecoders using [data].
T dataToModel<T>({required dynamic data, Map<Type, dynamic>? modelDecoders}) {
  assert(
    T != dynamic,
    "You must provide a Type from your modelDecoders from within your bootstrap/decoders.dart file",
  );
  if (modelDecoders != null && (modelDecoders.isNotEmpty)) {
    assert(
      modelDecoders.containsKey(T),
      "ModelDecoders not found for Type: $T",
    );
    return modelDecoders[T](data);
  }
  Nylo nylo = Backpack.instance.nylo();
  Map<Type, dynamic> nyloModelDecoders = nylo.getModelDecoders();
  assert(
    nyloModelDecoders.containsKey(T),
    "Your modelDecoders variable inside bootstrap/decoders.dart must contain a decoder for Type: $T",
  );
  return nyloModelDecoders[T](data);
}

/// Returns the translation value from the [key] you provide.
/// E.g. trans("hello")
/// lang translation will be returned for the app locale.
String trans(String key, {Map<String, String>? arguments}) =>
    NyLocalization.instance.translate(key, arguments);

/// Event helper
Future<void> nyEvent<T>({
  Map? params,
  Map<Type, NyEvent> events = const {},
  bool? broadcast,
}) async {
  assert(
    T.toString() != 'dynamic',
    'You must provide an Event type for this method.\nE.g. event<LoginEvent>({"User": "#1 User"});',
  );

  Map<Type, NyEvent> appEvents = events;

  Nylo? nylo;
  if (Backpack.instance.read('nylo') != null) {
    nylo = Backpack.instance.read('nylo');
  }

  if (events.isEmpty && nylo != null) {
    appEvents = nylo.getEvents();
  }

  broadcast ??= nylo?.shouldBroadcastEvents();

  assert(
    appEvents.containsKey(T),
    'Your config/events.dart is missing this class ${T.toString()}',
  );

  NyEvent nyEvent = appEvents[T]!;

  // Use the extension method
  await nyEvent.fireAll(params, broadcast: broadcast ?? false);
}

/// API helper
Future<dynamic> nyApi<T>({
  required dynamic Function(T) request,
  Map<Type, dynamic> apiDecoders = const {},
  Map<String, dynamic> headers = const {},
  String? bearerToken,
  String? baseUrl,
  int? page,
  int? perPage,
  String queryParamPage = "page",
  String? queryParamPerPage,
  int retry = 0,
  Duration? retryDelay,
  bool Function(DioException dioException)? retryIf,
  bool? shouldSetAuthHeaders,
  Function(Response response, dynamic data)? onSuccess,
  Function(DioException dioException)? onError,
  Duration? cacheDuration,
  String? cacheKey,
  List<Type> events = const [],
}) async {
  assert(
    apiDecoders.containsKey(T),
    'Your bootstrap/decoders.dart is missing this class ${T.toString()} in apiDecoders.',
  );

  dynamic apiService = apiDecoders[T];

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
    apiService.setPagination(
      page,
      paramPage: queryParamPage,
      paramPerPage: queryParamPerPage,
      perPage: perPage,
    );
  }

  if (retry > 0) {
    apiService.setRetry(retry);
  }

  if (retryDelay != null) {
    apiService.setRetryDelay(retryDelay);
  }

  if (shouldSetAuthHeaders != null) {
    apiService.setShouldSetAuthHeaders(shouldSetAuthHeaders);
  }

  if (onSuccess != null) {
    apiService.onSuccess(onSuccess);
  }

  if (onError != null) {
    apiService.onError(onError);
  }

  if (cacheDuration != null || cacheKey != null) {
    assert(
      cacheKey != null,
      "Cache key is required when using cache duration\n"
      "Example: cacheKey: 'api_all_users'"
      "",
    );

    assert(
      cacheDuration != null,
      "Cache duration is required when using cache key\n"
      "Example: cacheDuration: Duration(seconds: 60)"
      "",
    );
    apiService.setCache(cacheDuration, cacheKey);
  }

  dynamic result = await request(apiService);

  if (events.isNotEmpty) {
    Nylo nylo = Backpack.instance.nylo();

    for (var event in events) {
      NyEvent? nyEvent = nylo.getEvent(event);
      if (nyEvent == null) {
        continue;
      }
      Map listeners = nyEvent.listeners;

      if (listeners.isEmpty) {
        continue;
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
///
/// Example:
/// ```dart
/// final colors = nyColorStyle<MyColorStyles>(context);
/// print(colors.primaryAccent);
/// ```
///
/// Or get colors from a specific theme:
/// ```dart
/// final colors = nyColorStyle<MyColorStyles>(context, themeId: 'dark_theme');
/// ```
T nyColorStyle<T>(BuildContext context, {String? themeId}) {
  if (themeId != null) {
    return NyThemeManager.instance.colorStylesFromTheme<T>(themeId);
  }
  return NyThemeManager.instance.colorStyles<T>();
}

/// Hex Color
Color nyHexColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF$hexColor";
  }
  return Color(int.parse(hexColor, radix: 16));
}

/// Match a value from a Map of data.
/// Returns [defaultValue] if no match is found, or throws if no default provided.
T match<T>(
  dynamic value,
  Map<dynamic, T> Function() values, {
  T? defaultValue,
}) {
  if (value == null) {
    if (defaultValue != null) return defaultValue;
    throw ArgumentError(
      'Value cannot be null when no defaultValue is provided',
    );
  }

  final valuesMeta = values();

  if (valuesMeta.containsKey(value)) {
    return valuesMeta[value] as T;
  }

  NyLogger.error('The value "$value" does not match any values provided');
  if (defaultValue != null) {
    return defaultValue;
  }
  throw ArgumentError('The value "$value" does not match any values provided');
}

/// If you call [showNextLog] it will force the app to display the next
/// 'NyLogger' log even if your app's APP_DEBUG is set to false.
void showNextLog() {
  Backpack.instance.save('SHOW_LOG', true);
}

/// api helper
/// Example:
/// ```dart
/// await api<ApiService>((request) => request.get("https://jsonplaceholder.typicode.com/posts"));
/// ```
/// The above example will send an API request and return the data.
Future api<T extends NyApiService>(
  dynamic Function(T request) request, {
  Map<String, dynamic> headers = const {},
  String? bearerToken,
  String? baseUrl,
  int? page,
  String? queryNamePage,
  String? queryNamePerPage,
  int? perPage,
  int retry = 0,
  Duration? retryDelay,
  bool Function(DioException dioException)? retryIf,
  bool? shouldSetAuthHeaders,
  Function(Response response, dynamic data)? onSuccess,
  Function(DioException dioException)? onError,
  Duration? cacheDuration,
  String? cacheKey,
  List<Type> events = const [],
}) async => await nyApi<T>(
  request: request,
  apiDecoders: Nylo.apiDecoders(),
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
  onSuccess: onSuccess,
  onError: onError,
  cacheKey: cacheKey,
  cacheDuration: cacheDuration,
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
Future event<T>({Map? data, bool? broadcast}) async =>
    await nyEvent<T>(params: data, events: Nylo.events(), broadcast: broadcast);

/// Dump a message to the console.
/// Example:
/// ```dart
/// dump("Hello World");
/// ```
void dump(dynamic value, {String? tag, bool alwaysPrint = false}) =>
    NyLogger.dump(value, tag, alwaysPrint: alwaysPrint);

/// Get the DateTime.now() value.
DateTime now() => DateTime.now();

/// Delays execution for the specified duration.
///
/// Parameters:
///   [seconds]: Integer seconds to sleep (backward compatible usage)
///   [microseconds]: Optional microseconds to sleep
///
/// Examples:
///   await sleep(2);                // Sleeps for 2 seconds
///   await sleep(0, 500);           // Sleeps for 500 microseconds
///   await sleep(1, 500000);        // Sleeps for 1.5 seconds
Future<void> sleep(int seconds, [int microseconds = 0]) async {
  await Future.delayed(Duration(seconds: seconds, microseconds: microseconds));
}

/// Load a json file from the assets folder.
Future<T?> loadJson<T>(String fileName, {bool cache = true}) async {
  try {
    String data = await rootBundle.loadString(fileName, cache: cache);
    dynamic dataJson = jsonDecode(data);
    if (!([String, int, double, dynamic].contains(T))) {
      return dataToModel<T>(data: dataJson);
    }
    return dataJson;
  } on Exception catch (e) {
    NyLogger.error(e.toString());
    return null;
  }
}

/// Clear badge number
Future<void> clearBadgeNumber() async {
  if (kIsWeb) {
    return;
  }
  if (Platform.isAndroid || Platform.isIOS) {
    await AppBadgePlus.updateBadge(0);
  }
}

/// Set badge number
Future<void> setBadgeNumber(int number) async {
  if (kIsWeb) {
    return;
  }
  if (Platform.isAndroid || Platform.isIOS) {
    await AppBadgePlus.updateBadge(number);
  }
}

/// Print a message to the console.
/// Log level: Info
/// Use [context] to interpolate values into the message, e.g. 'User {id}' with {'id': '123'}.
void printInfo(
  dynamic message, {
  Map<String, dynamic>? context,
  bool alwaysPrint = false,
}) {
  NyLogger.info(message, context: context, alwaysPrint: alwaysPrint);
}

/// Print a message to the console.
/// Log level: Error
/// Use [context] to interpolate values into the message, e.g. 'User {id}' with {'id': '123'}.
void printError(
  dynamic message, {
  Map<String, dynamic>? context,
  bool alwaysPrint = false,
}) {
  NyLogger.error(message, context: context, alwaysPrint: alwaysPrint);
}

/// Print a message to the console.
/// Log level: Debug
/// Use [context] to interpolate values into the message, e.g. 'User {id}' with {'id': '123'}.
void printDebug(
  dynamic message, {
  Map<String, dynamic>? context,
  bool alwaysPrint = false,
}) {
  NyLogger.debug(message, context: context, alwaysPrint: alwaysPrint);
}

/// Print a message to the console.
/// Log level: Warning
/// Use [context] to interpolate values into the message, e.g. 'User {id}' with {'id': '123'}.
void printWarning(
  dynamic message, {
  Map<String, dynamic>? context,
  bool alwaysPrint = false,
}) {
  NyLogger.warning(message, context: context, alwaysPrint: alwaysPrint);
}

/// Print a message to the console.
/// Log level: Success
/// Use [context] to interpolate values into the message, e.g. 'User {id}' with {'id': '123'}.
void printSuccess(
  dynamic message, {
  Map<String, dynamic>? context,
  bool alwaysPrint = false,
}) {
  NyLogger.success(message, context: context, alwaysPrint: alwaysPrint);
}

/// Print a message to the console.
/// Log level: Verbose
/// Use [context] to interpolate values into the message, e.g. 'User {id}' with {'id': '123'}.
void printVerbose(
  dynamic message, {
  Map<String, dynamic>? context,
  bool alwaysPrint = false,
}) {
  NyLogger.verbose(message, context: context, alwaysPrint: alwaysPrint);
}

/// Print a message to the console.
/// Log level: Emergency (highest severity)
/// Use [context] to interpolate values into the message, e.g. 'User {id}' with {'id': '123'}.
void printEmergency(
  dynamic message, {
  Map<String, dynamic>? context,
  bool alwaysPrint = false,
}) {
  NyLogger.emergency(message, context: context, alwaysPrint: alwaysPrint);
}

/// Print a message to the console.
/// Log level: Alert
/// Use [context] to interpolate values into the message, e.g. 'User {id}' with {'id': '123'}.
void printAlert(
  dynamic message, {
  Map<String, dynamic>? context,
  bool alwaysPrint = false,
}) {
  NyLogger.alert(message, context: context, alwaysPrint: alwaysPrint);
}

/// Print a message to the console as JSON.
void printJson(dynamic message, {bool alwaysPrint = false}) {
  NyLogger.json(message, alwaysPrint: alwaysPrint);
}
