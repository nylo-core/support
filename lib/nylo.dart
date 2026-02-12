import 'dart:async';
import 'dart:io';

import 'package:error_stack/error_stack.dart';
import 'package:service_runner/service_runner.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import '/controllers/ny_controllers.dart';
import '/helpers/ny_helpers.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import '/event_bus/ny_event_bus.dart';
import 'package:flutter/material.dart';
import 'alerts/src/toast_meta.dart';
import '/networking/ny_networking.dart';
import '/providers/ny_providers.dart' show BootConfig;
import '/router/ny_router.dart';
import '/themes/ny_themes.dart';
import '/widgets/ny_widgets.dart';
import 'local_storage/ny_local_storage.dart';
import 'localization/ny_localization.dart';
import '/events/ny_events.dart' show NyEvent;

class Nylo {
  /// Flag to indicate if the app is running in test mode.
  /// When true, certain operations like timezone configuration are skipped,
  /// and in-memory cache is used instead of file-based cache.
  static bool isTestMode = false;

  /// Registered services initialized during Nylo.init()
  static List<Runnable> _services = [];

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
  final Map<String, dynamic> _formCasts = {};
  final Map<Type, NyApiService Function()> _apiDecoders = {};
  final Map<Type, NyApiService> _singletonApiDecoders = {};
  final List<NavigatorObserver> _navigatorObservers = [];
  final Map<Type, dynamic> _modelDecoders = {};
  final Map<Type, dynamic> _controllerDecoders = {};
  final Map<Type, dynamic> _singletonControllers = {};
  Function(String route, dynamic data)? onDeepLinkAction;
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

  /// Get the registered services
  static List<Runnable> get services => _services;

  /// Create a new Nylo instance.
  Nylo({this.router, bool useNyRouteObserver = true})
    : _appLoader = const CircularProgressIndicator(),
      _appLogo = const SizedBox.shrink() {
    _navigatorObservers.addAll(
      useNyRouteObserver ? [NyRouteHistoryObserver()] : [],
    );
  }

  /// Set the initial route from a [routeName].
  void setInitialRoute(String routeName) {
    _initialRoute = routeName;
    if (!Backpack.instance.isNyloInitialized()) {
      Backpack.instance.save("nylo", this);
    }
  }

  /// Sync keys to the backpack instance.
  Future<void> syncKeys(dynamic keys) async {
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
  static void updateRouteStack(
    List<String> routes, {
    bool replace = true,
    bool deepLink = false,
    Map<String, dynamic>? dataForRoute,
  }) {
    if (deepLink == true) {
      routes.removeLast();
    }
    NyNavigator.updateStack(
      routes,
      replace: replace,
      dataForRoute: dataForRoute,
    );
  }

  /// Set the deep link action.
  /// e.g. nylo.onDeepLink((route, data) {
  ///  print("Deep link route: $route");
  ///  print("Deep link data: $data");
  ///  });
  void onDeepLink(Function(String route, dynamic data) callback) {
    onDeepLinkAction = callback;
  }

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
  void addRouter(NyRouter router) {
    if (this.router == null) {
      this.router = NyRouter();
    }
    this.router?.setRegisteredRoutes(router.getRegisteredRoutes());
    this.router?.setUnknownRoutes(router.getUnknownRoutes());
    NyNavigator.instance.router = this.router!;
  }

  /// Add themes to Nylo.
  ///
  /// [themes] - List of theme configurations to register.
  /// [initialThemeId] - Optional theme ID to use on first launch. If not provided,
  ///                    the system brightness will be used to select a matching theme.
  ///
  /// Example:
  /// ```dart
  /// nylo.addThemes(appThemes);
  /// // Or with initial theme:
  /// nylo.addThemes(appThemes, initialThemeId: 'light_theme');
  /// ```
  void addThemes<T extends ThemeColor>(
    List<BaseThemeConfig<T>> themes, {
    String? initialThemeId,
  }) {
    NyThemeManager.instance.registerThemes(
      themes,
      initialThemeId: initialThemeId,
    );
  }

  /// Get all registered themes.
  static List<BaseThemeConfig> getThemes() {
    return NyThemeManager.instance.themes;
  }

  /// Get the current theme.
  static BaseThemeConfig? getCurrentTheme() {
    return NyThemeManager.instance.currentTheme;
  }

  /// Get the current theme data.
  static ThemeData? getThemeData() {
    return NyThemeManager.instance.themeData;
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
  void useErrorStack({
    ErrorStackLogLevel level = ErrorStackLogLevel.verbose,
    Widget Function(FlutterErrorDetails errorDetails)? errorWidget,
  }) {
    _enableErrorStack = true;
    _errorStackLogLevel = level;
    _errorStackErrorWidget = errorWidget;
  }

  /// Enable external dev panel logging integration.
  ///
  /// This sets up callbacks for both console logging ([NyLogger]) and route
  /// tracking ([NyRouteHistoryObserver]) to forward events to an external
  /// logging system like DevPanelStore.
  ///
  /// The [onLog] callback receives console log messages with:
  /// - `message`: The log message content
  /// - `level`: The log level (`debug`, `info`, `warning`, `error`)
  /// - `tag`: Optional tag for categorizing logs
  /// - `stackTrace`: Optional stack trace for error logs
  /// - `metadata`: Optional additional metadata
  ///
  /// The [onRouteChange] callback receives route navigation events with:
  /// - `action`: The navigation action (`push`, `pop`, `remove`, `replace`)
  /// - `routeName`: The name of the route
  /// - `arguments`: Optional route arguments
  /// - `previousRoute`: The name of the previous route
  ///
  /// Example with DevPanelStore:
  /// ```dart
  /// nylo.useDevPanelLogging(
  ///   onLog: (message, level, {tag, stackTrace, metadata}) {
  ///     DevPanelStore.instance.log(
  ///       message,
  ///       level: DevPanelLogLevel.values.byName(level),
  ///       tag: tag,
  ///       stackTrace: stackTrace,
  ///       metadata: metadata,
  ///     );
  ///   },
  ///   onRouteChange: (action, routeName, {arguments, previousRoute}) {
  ///     switch (action) {
  ///       case 'push':
  ///         DevPanelStore.instance.trackRoutePush(routeName, arguments: arguments, previousRoute: previousRoute);
  ///         break;
  ///       case 'pop':
  ///         DevPanelStore.instance.trackRoutePop(routeName, previousRoute: previousRoute);
  ///         break;
  ///       case 'replace':
  ///         DevPanelStore.instance.trackRouteReplace(routeName, arguments: arguments, previousRoute: previousRoute);
  ///         break;
  ///       case 'remove':
  ///         DevPanelStore.instance.trackRoutePop(routeName, previousRoute: previousRoute);
  ///         break;
  ///     }
  ///   },
  /// );
  /// ```
  void useDevPanelLogging({
    void Function(
      String message,
      String level, {
      String? tag,
      String? stackTrace,
      Map<String, dynamic>? metadata,
    })?
    onLog,
    void Function(
      String action,
      String routeName, {
      Object? arguments,
      String? previousRoute,
    })?
    onRouteChange,
  }) {
    if (onRouteChange != null) {
      NyRouteHistoryObserver.onRouteChange = onRouteChange;
    }
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
        linux:
            linuxSettings ??
            const LinuxInitializationSettings(
              defaultActionName: 'Open notification',
            ),
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

  /// Add toast notification styles to the registry.
  /// Pass a map of style IDs to widget factory functions.
  ///
  /// Example:
  /// ```dart
  /// nylo.addToastNotifications(ToastNotification.styles);
  /// ```
  ///
  /// To add custom styles:
  /// ```dart
  /// nylo.addToastNotifications({
  ///   ...ToastNotification.styles,
  ///   'custom': ToastNotification.style(
  ///     icon: Icon(Icons.star, color: Colors.purple, size: 20),
  ///     color: Colors.purple.shade50,
  ///     defaultTitle: 'Custom!',
  ///     position: ToastNotificationPosition.bottom,
  ///   ),
  /// });
  /// ```
  void addToastNotifications(Map<String, ToastStyleFactory> styles) {
    ToastNotificationRegistry.instance.registerAll(styles);
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
  void addEvents(Map<Type, NyEvent> events) {
    _events.addAll(events);
  }

  /// Return all the registered events.
  Map<Type, NyEvent> getEvents() => _events;

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
    assert(
      _events.containsKey(event),
      "Your events.dart file doesn't contain ${event.toString()}",
    );
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
        _controllerDecoders.addAll({
          controllerDecoder.key: controllerDecoder.value,
        });
      }

      if (controllerDecoder.value is NyController) {
        _singletonControllers.addAll({
          controllerDecoder.key: controllerDecoder.value,
        });
      }
    }

    if (!Backpack.instance.isNyloInitialized()) {
      Backpack.instance.save("nylo", this);
    }
  }

  /// Configure the app to use local timezone
  static Future<void> _configureLocalTimeZone() async {
    if (isTestMode || kIsWeb || Platform.isLinux) {
      return;
    }
    tz.initializeTimeZones();
    final TimezoneInfo timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName.identifier));
  }

  /// Get initialization settings
  InitializationSettings? getInitializationSettings() =>
      _initializationSettings;

  /// Get local notifications
  FlutterLocalNotificationsPlugin? getLocalNotifications() =>
      _localNotifications;

  /// Set local notifications
  void setLocalNotifications(
    FlutterLocalNotificationsPlugin localNotifications,
  ) {
    _localNotifications = localNotifications;
  }

  /// Get the local notifications plugin
  static Future<void> localNotifications(
    Function(FlutterLocalNotificationsPlugin localNotifications) callback,
  ) async {
    Nylo nylo = Nylo.instance;
    FlutterLocalNotificationsPlugin? flutterLocalNotifications = nylo
        .getLocalNotifications();
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
          settings:
              nylo.getInitializationSettings() ?? InitializationSettings(),
          onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
          onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
        ) ??
        false;
    await callback(flutterLocalNotifications);
  }

  @pragma('vm:entry-point')
  static void notificationTapBackground(
    NotificationResponse notificationResponse,
  ) {
    Function(NotificationResponse notificationResponse)?
    onDidReceiveBackgroundNotificationResponse = Nylo.instance
        .getOnDidReceiveBackgroundNotificationResponse();
    if (onDidReceiveBackgroundNotificationResponse != null) {
      onDidReceiveBackgroundNotificationResponse(notificationResponse);
    }
  }

  /// On did receive notification response
  static void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    Function(NotificationResponse notificationResponse)?
    onDidReceiveNotificationResponse = Nylo.instance
        .getOnDidReceiveNotificationResponse();
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
  ///
  /// [env] - The environment getter function from your generated env.g.dart file.
  /// Run `metro make:key` then `metro make:env` to generate this file.
  /// Example: `env: Env.get`
  ///
  /// [services] - List of services to initialize after setup completes.
  /// Services are initialized in order and must extend [Runnable] or [NyService].
  /// Supports both sync and async service factories (e.g., `Future<Runnable>`).
  ///
  /// Example:
  /// ```dart
  /// await Nylo.init(
  ///   env: Env.get,
  ///   setup: Boot.nylo,
  ///   services: [
  ///     // Async factory pattern - returns Future<Runnable>
  ///     FirebaseKit.init(
  ///       options: DefaultFirebaseOptions.currentPlatform,
  ///       services: [
  ///         FirebaseKitMessaging(sendTokenOnBoot: true),
  ///         FirebaseKitAnalytics(enableAutoTracking: true),
  ///       ],
  ///     ),
  ///     // Direct instantiation
  ///     MyCustomService(),
  ///   ],
  /// );
  ///
  /// // Later in your app, retrieve services:
  /// final firebase = service<FirebaseKit>();
  /// final messaging = firebase.getService<FirebaseKitMessaging>();
  /// ```
  ///
  /// Services go through three lifecycle phases:
  /// 1. `onInit()` - Called for each service in order
  /// 2. `onReady()` - Called after all services are initialized
  /// 3. `onAppReady()` - Called when the app is fully ready
  static Future<Nylo> init({
    required EnvGetter env,
    BootConfig? setup,
    Map<AppLifecycleState, Function()>? appLifecycle,
    List<FutureOr<Runnable>>? services,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();
    // Register environment configuration first
    NyEnvRegistry.register(getter: env);

    Intl.defaultLocale = getEnv('DEFAULT_LOCALE', defaultValue: 'en');

    try {
      await _configureLocalTimeZone();
    } catch (e) {
      // Timezone configuration failed, continue without it
    }

    Nylo nyloApp = Nylo();

    if (setup != null) {
      nyloApp = await setup.setup();
    }
    if (!isTestMode) {
      try {
        nyloApp._cache = await NyCache.getInstance();
      } catch (e) {
        // Cache initialization failed (e.g. path_provider native library issue)
      }
    }

    // Initialize theme manager after themes are registered
    await NyThemeManager.instance.init();

    if (nyloApp._enableErrorStack == true) {
      await ErrorStack.init(
        level: nyloApp._errorStackLogLevel ?? ErrorStackLogLevel.verbose,
        initialRoute: nyloApp.getInitialRoute(),
        errorWidget: nyloApp._errorStackErrorWidget,
      );
      nyloApp.addNavigatorObserver(ErrorStackNavigatorObserver());
    }
    if (nyloApp._useLocalNotifications == true) {
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      if (nyloApp._initializationSettings != null) {
        nyloApp.setLocalNotifications(flutterLocalNotificationsPlugin);
      }
    }

    // Initialize services
    if (services != null && services.isNotEmpty) {
      // Resolve all FutureOr<Runnable> to Runnable instances
      final List<Runnable> resolvedServices = [];
      for (final serviceOrFuture in services) {
        final Runnable resolvedService = await serviceOrFuture;
        resolvedServices.add(resolvedService);
        // Register in the service registry by type
        Runnable.register(resolvedService);
      }
      _services = resolvedServices;

      // Phase 1: Initialize all services
      for (final service in resolvedServices) {
        await service.onInit();
      }
      // Phase 2: All services ready
      for (final service in resolvedServices) {
        await service.onReady();
      }
      // Phase 3: App fully ready (navigation available)
      for (final service in resolvedServices) {
        await service.onAppReady();
      }
    }

    Backpack.instance.save("nylo", nyloApp);

    // Call boot after all initialization is complete
    if (setup != null) {
      await setup.boot(nyloApp);
    }

    return nyloApp;
  }

  /// Initialize local notifications
  Future<bool?>? initializeLocalNotifications() async {
    return await _localNotifications?.initialize(
      settings: _initializationSettings!,
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

  /// Get Nylo from Backpack.
  /// Throws [StateError] if Nylo has not been initialized via [Nylo.init()].
  static Nylo get instance {
    if (!Backpack.instance.isNyloInitialized()) {
      throw StateError(
        'Nylo has not been initialized. Call Nylo.init() first.',
      );
    }
    return Backpack.instance.nylo();
  }

  /// Get appLoader
  static Widget appLoader() => instance.getAppLoader;

  /// Get appLogo
  static Widget appLogo() => instance.getAppLogo;

  /// Get events
  static Map<Type, NyEvent> events() => instance.getEvents();

  /// Get a service by type.
  ///
  /// Example:
  /// ```dart
  /// final firebase = Nylo.getService<FirebaseKit>();
  /// final messaging = firebase?.getService<FirebaseKitMessaging>();
  /// ```
  static T? getService<T extends Runnable>() {
    try {
      return _services.firstWhere((s) => s is T) as T;
    } catch (_) {
      return null;
    }
  }

  /// Check if a service is registered.
  ///
  /// Example:
  /// ```dart
  /// if (Nylo.hasService<FirebaseKit>()) {
  ///   // Firebase is available
  /// }
  /// ```
  static bool hasService<T extends Runnable>() {
    return _services.any((s) => s is T);
  }

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
    List<Route<dynamic>> history = NyNavigator.instance.router
        .getRouteHistory();
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
    dynamic argumentsWrapper = NyNavigator.instance.router
        .getCurrentRoute()
        ?.settings
        .arguments;
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
    dynamic argumentsWrapper = NyNavigator.instance.router
        .getPreviousRoute()
        ?.settings
        .arguments;
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
  static Future<void> scheduleOnceDaily(
    String name,
    Function() callback, {
    DateTime? endAt,
  }) async {
    await NyScheduler.taskDaily(name, callback, endAt: endAt);
  }

  /// Schedule something to happen once after a date
  static Future<void> scheduleOnceAfterDate(
    String name,
    Function() callback, {
    required DateTime date,
  }) async {
    await NyScheduler.taskOnceAfterDate(name, callback, date: date);
  }

  /// Wipe all storage data.
  /// [excludeKeys] - Optional list of keys to exclude from deletion.
  /// [andFromBackpack] - Whether to also remove data from Backpack (default: true).
  static Future<void> wipeStorage({
    List<String>? excludeKeys,
    bool andFromBackpack = true,
  }) async {
    await NyStorage.deleteAll(
      andFromBackpack: andFromBackpack,
      excludeKeys: excludeKeys,
    );
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

  /// Configure Nylo with all settings in a single call.
  ///
  /// This method provides a cleaner way to initialize Nylo by consolidating
  /// all configuration options into a single method call.
  ///
  /// Example:
  /// ```dart
  /// await nylo.configure(
  ///   loader: DesignConfig.loader,
  ///   logo: DesignConfig.logo,
  ///   themes: appThemes,
  ///   initialThemeId: 'light_theme',
  ///   toastNotifications: ToastNotificationConfig.styles,
  ///   modelDecoders: modelDecoders,
  ///   controllers: controllers,
  ///   apiDecoders: apiDecoders,
  ///   authKey: StorageKeysConfig.auth,
  ///   syncKeys: StorageKeysConfig.syncedOnBoot,
  ///   useErrorStack: true,
  ///   monitorAppUsage: true,
  ///   localization: LocalizationConfig(
  ///     localeType: localeType,
  ///     languageCode: 'en',
  ///     assetsDirectory: 'lang/',
  ///   ),
  /// );
  /// ```
  Future<void> configure({
    // UI
    Widget? loader,
    Widget? logo,

    // Themes
    List<BaseThemeConfig>? themes,
    String? initialThemeId,

    // Notifications
    Map<String, ToastStyleFactory>? toastNotifications,

    // Decoders & Controllers
    Map<Type, dynamic>? modelDecoders,
    Map<Type, dynamic>? controllers,
    Map<Type, dynamic>? apiDecoders,

    // Events
    Map<Type, NyEvent>? events,
    Map<String, dynamic>? formCasts,

    // Auth & Storage
    String? authKey,
    dynamic syncKeys,

    // Features
    bool useErrorStack = false,
    ErrorStackLogLevel? errorStackLevel,
    Widget Function(FlutterErrorDetails)? errorStackWidget,
    bool monitorAppUsage = false,
    bool showDateTimeInLogs = false,
    bool broadcastEvents = false,
    NyLogCallback? onLog,

    // Localization
    NyLocalizationConfig? localization,
  }) async {
    // Localization
    if (localization != null) {
      await NyLocalization.instance.init(
        localeType: localization.localeType,
        languageCode: localization.languageCode,
        assetsDirectory: localization.assetsDirectory,
      );
    }

    // UI
    if (loader != null) addLoader(loader);
    if (logo != null) addLogo(logo);

    // Themes
    if (themes != null) {
      NyThemeManager.instance.registerThemes(
        themes,
        initialThemeId: initialThemeId,
      );
    }

    // Notifications
    if (toastNotifications != null) {
      addToastNotifications(toastNotifications);
    }

    // Decoders & Controllers
    if (modelDecoders != null) addModelDecoders(modelDecoders);
    if (controllers != null) addControllers(controllers);
    if (apiDecoders != null) addApiDecoders(apiDecoders);

    // Events
    if (events != null) addEvents(events);
    if (formCasts != null) addFormCasts(formCasts);

    // Auth & Storage
    if (authKey != null) addAuthKey(authKey);
    if (syncKeys != null) await this.syncKeys(syncKeys);

    // Features
    if (useErrorStack) {
      this.useErrorStack(
        level: errorStackLevel ?? ErrorStackLogLevel.verbose,
        errorWidget: errorStackWidget,
      );

      // Auto-wire NyLogger to DevPanelStore
      NyLogger.onLog = (entry) {
        // Forward to DevPanelStore
        switch (entry.type) {
          case 'debug':
            DevPanelStore.instance.debug(entry.message);
            break;
          case 'info':
            DevPanelStore.instance.info(entry.message);
            break;
          case 'error':
            DevPanelStore.instance.error(entry.message);
            break;
          case 'warning':
            DevPanelStore.instance.warning(entry.message);
            break;
          default:
            DevPanelStore.instance.debug(entry.message);
        }
        // Also call user's custom callback if provided
        onLog?.call(entry);
      };
    } else if (onLog != null) {
      // No ErrorStack, just use custom callback
      NyLogger.onLog = onLog;
    }
    if (monitorAppUsage) this.monitorAppUsage();
    if (showDateTimeInLogs) this.showDateTimeInLogs();
    if (broadcastEvents) this.broadcastEvents(true);
  }

  /// Sync a model to the backpack instance.
  void syncToBackpack(String key, dynamic data) {
    Backpack.instance.save(key, data);
  }
}
