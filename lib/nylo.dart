import 'dart:io';

import 'package:error_stack/error_stack.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import '/helpers/ny_cache.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import '/widgets/ny_form.dart';
import '/controllers/ny_controller.dart';
import '/event_bus/event_bus_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '/alerts/toast_enums.dart';
import '/alerts/toast_meta.dart';
import '/events/events.dart';
import '/helpers/backpack.dart';
import '/helpers/helper.dart';
import '/networking/ny_api_service.dart';
import '/router/models/arguments_wrapper.dart';
import '/router/models/ny_argument.dart';
import '/router/observers/ny_route_history_observer.dart';
import '/router/router.dart';
import '/themes/base_color_styles.dart';
import '/themes/base_theme_config.dart';
import '/widgets/event_bus/update_state.dart';
import 'package:theme_provider/theme_provider.dart';
import 'helpers/ny_app_usage.dart';
import 'helpers/ny_scheduler.dart';
import 'local_storage/local_storage.dart';
import 'localization/app_localization.dart';
export '/exceptions/validation_exception.dart';
export '/alerts/toast_enums.dart';

class Nylo {
  String? _initialRoute;
  Widget _appLoader;
  Widget _appLogo;
  NyRouter? router;
  bool? _monitorAppUsage;
  bool? _showDateTimeInLogs;
  bool? _enableErrorStack;
  ErrorStackLogLevel? _errorStackLogLevel;
  String? authStorageKey;
  Widget Function(FlutterErrorDetails errorDetails)? _errorStackErrorWidget;
  InitializationSettings? _initializationSettings;
  final Map<Type, NyEvent> _events = {};
  final Map<String, dynamic> _validationRules = {};
  final Map<String, dynamic> _formCasts = {};
  final Map<Type, NyApiService Function()> _apiDecoders = {};
  final Map<Type, NyApiService> _singletonApiDecoders = {};
  final List<BaseThemeConfig> _appThemes = [];
  final List<NavigatorObserver> _navigatorObservers = [];
  Widget Function({
    required ToastNotificationStyleType style,
    Function(ToastNotificationStyleMetaHelper helper)?
        toastNotificationStyleMeta,
    Function? onDismiss,
  })? _toastNotification;
  final Map<Type, dynamic> _modelDecoders = {};
  final Map<Type, dynamic> _controllerDecoders = {};
  final Map<Type, dynamic> _singletonControllers = {};
  Function(String route, dynamic data)? onDeepLinkAction;
  NyFormStyle? _formStyle;
  FlutterLocalNotificationsPlugin? _localNotifications;
  bool? _useLocalNotifications;
  Function(NotificationResponse details)? _onDidReceiveLocalNotification;
  Function(NotificationResponse details)?
      _onDidReceiveBackgroundNotificationResponse;
  NyCache? _cache;
  bool isFlutterLocalNotificationsInitialized = false;
  bool? _broadcastEvents;
  Map<AppLifecycleState, Function()>? _appLifecycle;

  /// Get the cache instance
  NyCache? get getCache => _cache;

  /// Create a new Nylo instance.
  Nylo({this.router, bool useNyRouteObserver = true})
      : _appLoader = const CircularProgressIndicator(),
        _appLogo = const SizedBox.shrink() {
    _navigatorObservers.addAll(useNyRouteObserver
        ? [
            NyRouteHistoryObserver(),
          ]
        : []);
  }

  /// Set the initial route from a [routeName].
  void setInitialRoute(String routeName) {
    _initialRoute = routeName;
    if (!Backpack.instance.isNyloInitialized()) {
      Backpack.instance.save("nylo", this);
    }
  }

  /// Sync keys to the backpack instance.
  Future<void> syncKeys(keys) async {
    Future<List<Object?>> Function() keysToSync = await keys();
    List finalKeys = await keysToSync();
    for (var key in finalKeys) {
      if (key is Future Function(bool)) {
        await key(true);
        continue;
      }
      dynamic keyValue = await NyStorage.read(key);
      Backpack.instance.save(key, keyValue);
    }
  }

  /// Set the form style
  void addFormStyle(NyFormStyle formStyle) {
    _formStyle = formStyle;
  }

  /// Get the form style
  NyFormStyle? getFormStyle() => _formStyle;

  /// Update the stack on the router.
  /// [routes] is a list of routes to navigate to. E.g. [HomePage.path, SettingPage.path]
  /// [replace] is a boolean that determines if the current route should be replaced.
  /// [dataForRoute] is a map of data to pass to the route. E.g. {HomePage.path: {"name": "John Doe"}}
  /// Example:
  /// ```dart
  /// Nylo.updateStack([
  ///  HomePage.path,
  ///  SettingPage.path
  ///  ], replace: true, dataForRoute: {
  ///  HomePage.path: {"name": "John Doe"}
  ///  });
  ///  ```
  ///  This will navigate to the HomePage and SettingPage with the data passed to the HomePage.
  static void updateRouteStack(List<String> routes,
      {bool replace = true,
      bool deepLink = false,
      Map<String, dynamic>? dataForRoute}) {
    if (deepLink == true) {
      routes.removeLast();
    }
    NyNavigator.updateStack(routes,
        replace: replace, dataForRoute: dataForRoute);
  }

  /// Set the deep link action.
  /// e.g. nylo.onDeepLink((route, data) {
  ///  print("Deep link route: $route");
  ///  print("Deep link data: $data");
  ///  });
  void onDeepLink(Function(String route, dynamic data) callback) {
    onDeepLinkAction = callback;
  }

  /// Get the toast notification.
  Widget Function({
    required ToastNotificationStyleType style,
    Function(ToastNotificationStyleMetaHelper helper)?
        toastNotificationStyleMeta,
    Function? onDismiss,
  })? get toastNotification => _toastNotification;

  /// Find a [controller]
  dynamic getController(dynamic controller) {
    if (controller == null) return null;

    dynamic controllerValue = _controllerDecoders[controller];
    if (controllerValue == null) {
      if (!_singletonControllers.containsKey(controller)) return null;
    }

    if (_singletonControllers.containsKey(controller)) {
      return _singletonControllers[controller];
    }

    if (controllerValue is NyController) return controllerValue;

    dynamic controllerFound = controllerValue();
    if (controllerFound is! NyController) return null;

    if (controllerFound.singleton) {
      _singletonControllers[controller] = controllerFound;
      return _singletonControllers[controller];
    }
    return controllerFound;
  }

  /// Get the initial route.
  String getInitialRoute() => _initialRoute ?? '/';

  /// Initialize routes
  void initRoutes({String? initialRoute}) {
    if (initialRoute != null) {
      setInitialRoute(initialRoute);
      return;
    }
    if (_initialRoute != null) {
      return;
    }
    setInitialRoute(NyRouter.getInitialRoute());
  }

  /// Allows you to add additional Router's to your project.
  ///
  /// file: e.g. /lib/routes/account_router.dart
  /// accountRouter() => nyRoutes((router) {
  ///    Add your routes here
  ///    router.add(AccountPage.path);
  ///    router.add(AccountUpdatePage.path);
  /// });
  ///
  /// Usage in /app/providers/route_provider.dart e.g. Nylo.addRouter(accountRouter());
  Future<void> addRouter(NyRouter router) async {
    if (this.router == null) {
      this.router = NyRouter();
    }
    this.router?.setRegisteredRoutes(router.getRegisteredRoutes());
    this.router?.setUnknownRoutes(router.getUnknownRoutes());
    NyNavigator.instance.router = this.router!;
  }

  /// Add themes to Nylo
  void addThemes<T extends BaseColorStyles>(List<BaseThemeConfig<T>> themes) {
    _appThemes.addAll(themes);
  }

  /// Set if the app should monitor app usage like:
  /// - App launch count
  /// - Days since first launch
  /// If [_monitorAppUsage] is set to true, you'll be able to use the
  /// functions from the [NyAppUsage] class.
  void monitorAppUsage() {
    _monitorAppUsage = true;
  }

  /// Use ErrorStack
  /// [level] is the log level for ErrorStack
  /// [errorWidget] is a custom error widget
  void useErrorStack(
      {ErrorStackLogLevel level = ErrorStackLogLevel.verbose,
      Widget Function(FlutterErrorDetails errorDetails)? errorWidget}) {
    _enableErrorStack = true;
    _errorStackLogLevel = level;
    _errorStackErrorWidget = errorWidget;
  }

  /// Use local notifications
  void useLocalNotifications({
    DarwinInitializationSettings? iosSettings,
    AndroidInitializationSettings? androidSettings,
    LinuxInitializationSettings? linuxSettings,
    Function(NotificationResponse details)? onDidReceiveLocalNotification,
    Function(NotificationResponse details)?
        onDidReceiveBackgroundNotificationResponse,
  }) {
    _useLocalNotifications = true;

    if (kIsWeb) {
      return;
    }
    late InitializationSettings initializationSettings;
    if (Platform.isAndroid) {
      initializationSettings = InitializationSettings(
        android: androidSettings ?? AndroidInitializationSettings('app_icon'),
      );
    }
    if (Platform.isIOS || Platform.isMacOS) {
      initializationSettings = InitializationSettings(
        iOS: iosSettings ?? const DarwinInitializationSettings(),
      );
    }
    if (Platform.isLinux) {
      initializationSettings = InitializationSettings(
        linux: linuxSettings ??
            const LinuxInitializationSettings(
                defaultActionName: 'Open notification'),
      );
    }

    _initializationSettings = initializationSettings;
    _onDidReceiveLocalNotification = onDidReceiveLocalNotification;
    _onDidReceiveBackgroundNotificationResponse =
        onDidReceiveBackgroundNotificationResponse;
  }

  /// Check if the app should monitor app usage
  bool shouldMonitorAppUsage() => _monitorAppUsage ?? false;

  /// Show date time in logs
  void showDateTimeInLogs() {
    _showDateTimeInLogs = true;
  }

  /// Check if the app should show date time in logs
  bool shouldShowDateTimeInLogs() => _showDateTimeInLogs ?? false;

  /// Set if you want to broadcast all events
  void broadcastEvents([bool broadcast = true]) {
    _broadcastEvents = broadcast;
  }

  /// Check if the app should broadcast events
  bool shouldBroadcastEvents() => _broadcastEvents ?? false;

  /// Add toast notification
  void addToastNotification(
      Widget Function({
        required ToastNotificationStyleType style,
        Function(ToastNotificationStyleMetaHelper helper)?
            toastNotificationStyleMeta,
        Function? onDismiss,
      }) toastNotification) {
    _toastNotification = toastNotification;
  }

  /// Get all app themes
  static List<AppTheme> getAppThemes() {
    return instance._appThemes
        .map((appTheme) => appTheme.toAppTheme())
        .toList();
  }

  /// Set API decoders
  void addApiDecoders(Map<Type, dynamic> apiDecoders) {
    for (var apiDecoder in apiDecoders.entries) {
      if (apiDecoder.value is NyApiService Function()) {
        _apiDecoders.addAll({apiDecoder.key: apiDecoder.value});
      }

      if (apiDecoder.value is NyApiService) {
        _singletonApiDecoders.addAll({apiDecoder.key: apiDecoder.value});
      }
    }
  }

  /// Get API decoders
  Map<Type, NyApiService Function()> getApiDecoders() => _apiDecoders;

  /// Add [events] to Nylo
  Future<void> addEvents(Map<Type, NyEvent> events) async {
    _events.addAll(events);
  }

  /// Return all the registered events.
  Map<Type, NyEvent> getEvents() => _events;

  /// Add [validators] to Nylo
  void addValidationRules(Map<String, dynamic> validators) {
    _validationRules.addAll(validators);
  }

  /// Get [validators] from Nylo
  Map<String, dynamic> getValidationRules() => _validationRules;

  /// Add form casts to Nylo
  void addFormCasts(Map<String, dynamic> formTypes) {
    _formCasts.addAll(formTypes);
  }

  /// Get form types from Nylo
  Map<String, dynamic> getFormCasts() => _formCasts;

  /// Add [modelDecoders] to Nylo
  void addModelDecoders(Map<Type, dynamic> modelDecoders) {
    _modelDecoders.addAll(modelDecoders);
    if (!Backpack.instance.isNyloInitialized()) {
      Backpack.instance.save("nylo", this);
    }
  }

  /// Return all the registered events.
  Map<Type, dynamic> getModelDecoders() => _modelDecoders;

  /// Return an event.
  NyEvent? getEvent(Type event) {
    assert(_events.containsKey(event),
        "Your events.dart file doesn't contain ${event.toString()}");
    return _events[event];
  }

  /// Add an [EventBus] to your Nylo project.
  void addEventBus({int maxHistoryLength = 10, bool allowLogging = false}) {
    EventBus eventBus = EventBus(
      maxHistoryLength: maxHistoryLength,
      allowLogging: allowLogging,
    );
    const event = UpdateState();
    eventBus.watch(event);

    Backpack.instance.save("event_bus", eventBus);
  }

  /// Add appLoader
  void addLoader(Widget appLoader) {
    _appLoader = appLoader;
  }

  /// Add appLogo
  void addLogo(Widget appLogo) {
    _appLogo = appLogo;
  }

  /// Add Controllers to your Nylo project.
  void addControllers(Map<Type, dynamic> controllers) {
    for (var controllerDecoder in controllers.entries) {
      if (controllerDecoder.value is NyController Function()) {
        _controllerDecoders
            .addAll({controllerDecoder.key: controllerDecoder.value});
      }

      if (controllerDecoder.value is NyController) {
        _singletonControllers
            .addAll({controllerDecoder.key: controllerDecoder.value});
      }
    }

    if (!Backpack.instance.isNyloInitialized()) {
      Backpack.instance.save("nylo", this);
    }
  }

  /// Configure the app to use local timezone
  static Future<void> _configureLocalTimeZone() async {
    if (kIsWeb || Platform.isLinux) {
      return;
    }
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  /// Get initialization settings
  InitializationSettings? getInitializationSettings() =>
      _initializationSettings;

  /// Get local notifications
  FlutterLocalNotificationsPlugin? getLocalNotifications() =>
      _localNotifications;

  /// Set local notifications
  void setLocalNotifications(
      FlutterLocalNotificationsPlugin localNotifications) {
    _localNotifications = localNotifications;
  }

  /// Get the local notifications plugin
  static Future<void> localNotifications(
      Function(FlutterLocalNotificationsPlugin localNotifications)
          callback) async {
    Nylo nylo = Nylo.instance;
    FlutterLocalNotificationsPlugin? flutterLocalNotifications =
        nylo.getLocalNotifications();
    if (flutterLocalNotifications == null) {
      flutterLocalNotifications = FlutterLocalNotificationsPlugin();
      nylo.setLocalNotifications(flutterLocalNotifications);
    }
    if (nylo.isFlutterLocalNotificationsInitialized) {
      await callback(flutterLocalNotifications);
      return;
    }
    nylo.isFlutterLocalNotificationsInitialized =
        await flutterLocalNotifications.initialize(
              nylo.getInitializationSettings() ?? InitializationSettings(),
              onDidReceiveBackgroundNotificationResponse:
                  notificationTapBackground,
              onDidReceiveNotificationResponse:
                  onDidReceiveNotificationResponse,
            ) ??
            false;
    await callback(flutterLocalNotifications);
  }

  @pragma('vm:entry-point')
  static void notificationTapBackground(
      NotificationResponse notificationResponse) {
    Function(NotificationResponse notificationResponse)?
        onDidReceiveBackgroundNotificationResponse =
        Nylo.instance.getOnDidReceiveBackgroundNotificationResponse();
    if (onDidReceiveBackgroundNotificationResponse != null) {
      onDidReceiveBackgroundNotificationResponse(notificationResponse);
    }
  }

  /// On did receive notification response
  static void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    Function(NotificationResponse notificationResponse)?
        onDidReceiveNotificationResponse =
        Nylo.instance.getOnDidReceiveNotificationResponse();
    if (onDidReceiveNotificationResponse != null) {
      onDidReceiveNotificationResponse(notificationResponse);
    }
  }

  /// Get on did receive notification response
  Function(NotificationResponse notificationResponse)?
      getOnDidReceiveNotificationResponse() => _onDidReceiveLocalNotification;

  /// Get on did receive background notification response
  Function(NotificationResponse notificationResponse)?
      getOnDidReceiveBackgroundNotificationResponse() =>
          _onDidReceiveBackgroundNotificationResponse;

  /// Initialize Nylo
  static Future<Nylo> init(
      {Function? setup,
      Function(Nylo nylo)? setupFinished,
      bool? showSplashScreen,
      Map<AppLifecycleState, Function()>? appLifecycle}) async {
    const String envFile = String.fromEnvironment(
      'ENV_FILE',
      defaultValue: '.env',
    );
    await dotenv.load(
        fileName: envFile,
        mergeWith: showSplashScreen != null
            ? {"SHOW_SPLASH_SCREEN": 'true'}
            : const {});
    Intl.defaultLocale = getEnv('DEFAULT_LOCALE', defaultValue: 'en');

    await _configureLocalTimeZone();

    Nylo nyloApp = Nylo();

    if (setup == null) {
      nyloApp._appLifecycle = appLifecycle;
      nyloApp._cache = await NyCache.getInstance();
      if (setupFinished != null) {
        await setupFinished(nyloApp);
      }
      if (nyloApp._enableErrorStack == true) {
        await ErrorStack.init(
            level: nyloApp._errorStackLogLevel ?? ErrorStackLogLevel.verbose,
            initialRoute: nyloApp.getInitialRoute(),
            errorWidget: nyloApp._errorStackErrorWidget);
      }
      if (nyloApp._useLocalNotifications == true) {
        FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();
        if (nyloApp._initializationSettings != null) {
          nyloApp.setLocalNotifications(flutterLocalNotificationsPlugin);
        }
      }
      return nyloApp;
    }

    nyloApp = await setup();
    nyloApp._cache = await NyCache.getInstance();
    nyloApp._appLifecycle = appLifecycle;

    if (setupFinished != null) {
      await setupFinished(nyloApp);
    }
    if (nyloApp._enableErrorStack == true) {
      await ErrorStack.init(
          level: nyloApp._errorStackLogLevel ?? ErrorStackLogLevel.verbose,
          initialRoute: nyloApp.getInitialRoute(),
          errorWidget: nyloApp._errorStackErrorWidget);
    }
    if (nyloApp._useLocalNotifications == true) {
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      if (nyloApp._initializationSettings != null) {
        nyloApp.setLocalNotifications(flutterLocalNotificationsPlugin);
      }
    }
    return nyloApp;
  }

  /// Initialize local notifications
  Future<bool?>? initializeLocalNotifications() async {
    return await _localNotifications?.initialize(
      _initializationSettings!,
      onDidReceiveBackgroundNotificationResponse:
          _onDidReceiveBackgroundNotificationResponse,
      onDidReceiveNotificationResponse: _onDidReceiveLocalNotification,
    );
  }

  /// Get the current locale
  String get locale => NyLocalization.instance.locale.languageCode;

  /// Get appLoader
  Widget get getAppLoader => _appLoader;

  /// Get appLogo
  Widget get getAppLogo => _appLogo;

  /// Get Nylo from Backpack
  static Nylo get instance => Backpack.instance.nylo();

  /// Get appLoader
  static Widget appLoader() => instance.getAppLoader;

  /// Get appLogo
  static Widget appLogo() => instance.getAppLogo;

  /// Get events
  static Map<Type, NyEvent> events() => instance.getEvents();

  /// Get AppLifecycleState
  Map<AppLifecycleState, Function()>? get appLifecycleStates => _appLifecycle;

  /// Get api decoders
  static Map<Type, NyApiService> apiDecoders() {
    Map<Type, NyApiService> apiDecoders = {};
    for (var e in instance._apiDecoders.entries) {
      apiDecoders.addAll({e.key: e.value()});
    }
    apiDecoders.addAll(instance._singletonApiDecoders);
    return apiDecoders;
  }

  /// Get a API Decoder
  static NyApiService apiDecoder<T>() {
    Map<Type, NyApiService> decoders = apiDecoders();
    if (decoders.containsKey(T)) {
      return decoders[T]!;
    }
    throw Exception("ApiService not found");
  }

  /// Add a navigator observer.
  void addNavigatorObserver(NavigatorObserver observer) {
    _navigatorObservers.add(observer);
  }

  /// Return all the registered navigator observers.
  List<NavigatorObserver> getNavigatorObservers() => _navigatorObservers;

  /// Remove a navigator observer.
  void removeNavigatorObserver(NavigatorObserver observer) {
    _navigatorObservers.remove(observer);
  }

  /// Add a route to the route history.
  static void addRouteHistory(Route<dynamic> route) {
    NyNavigator.instance.router.addRouteHistory(route);
  }

  /// Remove a route from the route history.
  static void removeRouteHistory(Route<dynamic> route) {
    NyNavigator.instance.router.removeRouteHistory(route);
  }

  /// Get the route history.
  static List<dynamic> getRouteHistory() {
    List<Map<String, dynamic>> list = [];
    List<Route<dynamic>> history =
        NyNavigator.instance.router.getRouteHistory();
    for (var route in history) {
      dynamic data = route.settings.arguments;
      if (data is ArgumentsWrapper) {
        data = data.getData();
      }
      if (data is NyArgument) {
        data = data.data;
      }
      list.add({
        "name": route.settings.name,
        "arguments": data,
        "route": route,
      });
    }
    return list;
  }

  /// Remove a route from the route history.
  static void removeLastRouteHistory() {
    NyNavigator.instance.router.removeLastRouteHistory();
  }

  /// Get current route
  static Route<dynamic>? getCurrentRoute() {
    return NyNavigator.instance.router.getCurrentRoute();
  }

  /// Get current route name
  static String? getCurrentRouteName() {
    return NyNavigator.instance.router.getCurrentRoute()?.settings.name;
  }

  /// Get current route arguments
  static dynamic getCurrentRouteArguments() {
    dynamic argumentsWrapper =
        NyNavigator.instance.router.getCurrentRoute()?.settings.arguments;
    if (argumentsWrapper is ArgumentsWrapper) {
      return argumentsWrapper.getData();
    }
    return argumentsWrapper;
  }

  /// Get previous route name
  static String? getPreviousRouteName() {
    return NyNavigator.instance.router.getPreviousRoute()?.settings.name;
  }

  /// Get previous route arguments
  static dynamic getPreviousRouteArguments() {
    dynamic argumentsWrapper =
        NyNavigator.instance.router.getPreviousRoute()?.settings.arguments;
    if (argumentsWrapper is ArgumentsWrapper) {
      return argumentsWrapper.getData();
    }
    return argumentsWrapper;
  }

  /// Get previous route
  static Route<dynamic>? getPreviousRoute() {
    return NyNavigator.instance.router.getPreviousRoute();
  }

  /// Get the current locale
  static String getLocale() {
    return NyLocalization.instance.locale.languageCode;
  }

  /// Check if the app is in debug mode
  static bool isDebuggingEnabled() {
    return getEnv('APP_DEBUG', defaultValue: false);
  }

  /// Check if the app is in production
  static bool isEnvProduction() {
    return getEnv('APP_ENV') == 'production';
  }

  /// Check if the app is in developing
  static bool isEnvDeveloping() {
    return getEnv('APP_ENV') == 'developing';
  }

  /// Check if [Nylo] is initialized
  static bool isInitialized() {
    return Backpack.instance.isNyloInitialized();
  }

  /// Check if the current route is [routeName]
  static bool isCurrentRoute(String routeName) =>
      getCurrentRouteName() == routeName;

  /// Check if the app can monitor data
  static void canMonitorAppUsage() {
    if (!Nylo.instance.shouldMonitorAppUsage()) {
      throw Exception("""\n
      You need to enable app usage monitoring in your Nylo instance.
      Go to your app_provider.dart file and add the following line:
      boot(Nylo nylo) async {
      ...
      nylo.monitorAppUsage(); // add this
      """);
    }
  }

  /// App launched - this method will increment the app launch count.
  static Future<void> appLaunched() async {
    await NyAppUsage.appLaunched();
  }

  /// App launch count - this method will return the app launch count.
  static Future<int?> appLaunchCount() async {
    return await NyAppUsage.appLaunchCount();
  }

  /// Days since first launch
  static Future<int> appTotalDaysSinceFirstLaunch() async {
    return await NyAppUsage.appTotalDaysSinceFirstLaunch();
  }

  /// Days since first launch
  static Future<DateTime?> appFirstLaunchDate() async {
    return await NyAppUsage.appFirstLaunchDate();
  }

  /// Schedule something to happen once
  static Future<void> scheduleOnce(String name, Function() callback) async {
    await NyScheduler.taskOnce(name, callback);
  }

  /// Schedule something to happen once daily
  static Future<void> scheduleOnceDaily(String name, Function() callback,
      {DateTime? endAt}) async {
    await NyScheduler.taskDaily(name, callback, endAt: endAt);
  }

  /// Schedule something to happen once after a date
  static Future<void> scheduleOnceAfterDate(String name, Function() callback,
      {required DateTime date}) async {
    await NyScheduler.taskOnceAfterDate(name, callback, date: date);
  }

  /// Wipe all storage data
  static Future<void> wipeAllStorageData({
    List<String>? excludeKeys,
    bool andFromBackpack = true,
  }) async {
    await NyStorage.deleteAll(
        andFromBackpack: andFromBackpack, excludeKeys: excludeKeys);
  }

  /// Check if the router contains specific [routes]
  static bool containsRoutes(List<String> routes) {
    return NyNavigator.instance.router.containsRoutes(routes);
  }

  /// Check if the router contains specific [route]
  static bool containsRoute(String route) {
    return NyNavigator.instance.router.containsRoutes([route]);
  }

  /// Get the auth user
  static T? user<T>() {
    return Backpack.instance.read<T>(authKey());
  }

  /// Get the auth user
  static String authKey() {
    String? authKey = instance.authStorageKey;
    if (authKey == null) {
      throw Exception("Auth key is not set in your Nylo instance");
    }
    return instance.authStorageKey!;
  }

  /// Get the auth key
  String? getAuthKey() {
    return authStorageKey;
  }

  /// Add an auth key to the Nylo instance
  void addAuthKey(String key) {
    authStorageKey = key;
  }

  /// Sync a model to the backpack instance.
  Future<void> syncToBackpack(String key, dynamic data) async {
    Backpack.instance.save(key, data);
  }

  /// Wipe all storage data
  Future<void> wipeStorage() async {
    await NyStorage.deleteAll();
  }
}
