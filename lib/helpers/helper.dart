import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '/router/router.dart';
import '/event_bus/event_bus_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import '/events/events.dart';
import '/helpers/backpack.dart';
import '/helpers/extensions.dart';
import '/localization/app_localization.dart';
import '/networking/ny_api_service.dart';
import '/themes/base_theme_config.dart';
import '/widgets/event_bus/update_state.dart';
import 'package:theme_provider/theme_provider.dart';
import '/nylo.dart';
import 'ny_logger.dart';

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

  if (value == '""') {
    return '';
  }

  return value.toString();
}

/// Returns the full image path for a image in /public/images/ directory.
/// Provide the name of the image, using [imageName] parameter.
///
/// Returns a [String].
String getImageAsset(String imageName) =>
    "${getEnv("ASSET_PATH_IMAGES")}/$imageName";

/// Returns the full path for an asset in /public directory.
/// Usage e.g. getPublicAsset('videos/welcome.mp4');
///
/// Returns a [String].
String getPublicAsset(String asset) {
  // remove the first slash if it exists
  if (asset.startsWith('/')) {
    asset = asset.substring(1);
  }
  return "${getEnv("ASSET_PATH_PUBLIC")}/$asset";
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
  assert(T != dynamic,
      "You must provide a Type from your modelDecoders from within your config/decoders.dart file");
  if (modelDecoders != null && (modelDecoders.isNotEmpty)) {
    assert(
        modelDecoders.containsKey(T), "ModelDecoders not found for Type: $T");
    return modelDecoders[T](data);
  }
  Nylo nylo = Backpack.instance.nylo();
  Map<Type, dynamic> nyloModelDecoders = nylo.getModelDecoders();
  assert(nyloModelDecoders.containsKey(T),
      "Your modelDecoders variable inside config/decoders.dart must contain a decoder for Type: $T");
  return nyloModelDecoders[T](data);
}

/// Returns the translation value from the [key] you provide.
/// E.g. trans("hello")
/// lang translation will be returned for the app locale.
String trans(String key, {Map<String, String>? arguments}) =>
    NyLocalization.instance.translate(key, arguments);

/// Event helper
Future<void> nyEvent<T>(
    {Map? params,
    Map<Type, NyEvent> events = const {},
    bool? broadcast}) async {
  assert(T.toString() != 'dynamic',
      'You must provide an Event type for this method.\nE.g. event<LoginEvent>({"User": "#1 User"});');

  Map<Type, NyEvent> appEvents = events;

  Nylo? nylo;
  if (Backpack.instance.read('nylo') != null) {
    nylo = Backpack.instance.read('nylo');
  }

  if (events.isEmpty && nylo != null) {
    appEvents = nylo.getEvents();
  }

  broadcast ??= nylo?.shouldBroadcastEvents();

  assert(appEvents.containsKey(T),
      'Your config/events.dart is missing this class ${T.toString()}');

  NyEvent nyEvent = appEvents[T]!;

  // Use the extension method
  await nyEvent.fireAll(params, broadcast: broadcast ?? false);
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
    Function(Response response, dynamic data)? onSuccess,
    Function(DioException dioException)? onError,
    Duration? cacheDuration,
    String? cacheKey,
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
        "");

    assert(
        cacheDuration != null,
        "Cache duration is required when using cache key\n"
        "Example: cacheDuration: Duration(seconds: 60)"
        "");
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
      if (context.isDeviceInDarkMode) {
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
    hexColor = "FF$hexColor";
  }
  return Color(int.parse(hexColor, radix: 16));
}

/// Match a value from a Map of data.
/// It will return null if a match is not found.
T match<T>(dynamic value, Map<dynamic, T> Function() values,
    {dynamic defaultValue}) {
  if (value == null) {
    return defaultValue;
  }

  Map<dynamic, T> valuesMeta = values();

  for (var val in valuesMeta.entries) {
    if (val.key == value) {
      return val.value;
    }
  }

  if (!valuesMeta.containsKey(value)) {
    NyLogger.error('The value "$value" does not match any values provided');
    if (defaultValue != null) {
      return defaultValue;
    } else {
      throw Exception('The value "$value" does not match any values provided');
    }
  }
  return valuesMeta[value] as T;
}

/// If you call [showNextLog] it will force the app to display the next
/// 'NyLogger' log even if your app's APP_DEBUG is set to false.
void showNextLog() {
  Backpack.instance.save('SHOW_LOG', true);
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
void updateState<T>(dynamic name,
    {dynamic data, dynamic Function(T? currentValue)? setValue}) {
  EventBus? eventBus = Backpack.instance.read("event_bus");
  if (eventBus == null) {
    NyLogger.error(
        'Event bus not defined. Please ensure that your project has called nylo.addEventBus() in one of your providers.');
    return;
  }

  dynamic dataUpdate = data;
  if (setValue != null) {
    List<EventBusHistoryEntry> eventHistory = eventBus.history
        .where(
            (element) => element.event.runtimeType.toString() == 'UpdateState')
        .toList();
    if (eventHistory.isNotEmpty) {
      T? lastValue = eventHistory.last.event.props[1] as T?;
      dataUpdate = setValue(lastValue);
    }
  }

  String stateName = '';
  if (name is String) {
    stateName = name;
  }
  if (name is RouteView) {
    stateName =
        "Closure: ${"${name.$2.runtimeType.toString().replaceAll("BuildContext", "")}State".replaceAll("() => ", "() => _")}";
  }

  final event = UpdateState(data: dataUpdate, stateName: stateName);
  eventBus.fire(event);
}

/// Send a state action to a [NyState] or [NyPage] in your application.
/// Provide the [state] and the [action] you want to send.
void stateAction(String action, {required dynamic state, dynamic data}) {
  updateState(state, data: {"action": action, "data": data});
}

/// api helper
/// Example:
/// ```dart
/// await api<ApiService>((request) => request.get("https://jsonplaceholder.typicode.com/posts"));
/// ```
/// The above example will send an API request and return the data.
Future api<T extends NyApiService>(dynamic Function(T request) request,
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
        Function(Response response, dynamic data)? onSuccess,
        Function(DioException dioException)? onError,
        Duration? cacheDuration,
        String? cacheKey,
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
  await Future.delayed(Duration(
    seconds: seconds,
    microseconds: microseconds,
  ));
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
void printInfo(dynamic message, {bool alwaysPrint = false}) {
  NyLogger.info(message, alwaysPrint: alwaysPrint);
}

/// Print a message to the console.
/// Log level: Error
void printError(dynamic message, {bool alwaysPrint = false}) {
  NyLogger.error(message, alwaysPrint: alwaysPrint);
}

/// Print a message to the console.
/// Log level: Debug
void printDebug(dynamic message, {bool alwaysPrint = false}) {
  NyLogger.debug(message, alwaysPrint: alwaysPrint);
}
