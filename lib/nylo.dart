import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
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
import '/plugin/nylo_plugin.dart';
import '/router/models/arguments_wrapper.dart';
import '/router/models/ny_argument.dart';
import '/router/observers/ny_route_history_observer.dart';
import '/router/router.dart';
import '/themes/base_color_styles.dart';
import '/themes/base_theme_config.dart';
import '/widgets/event_bus/update_state.dart';
import 'package:theme_provider/theme_provider.dart';
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
  Map<Type, NyEvent> _events = {};
  Map<String, dynamic> _validationRules = {};
  final Map<Type, NyApiService Function()> _apiDecoders = {};
  final Map<Type, NyApiService> _singletonApiDecoders = {};
  List<BaseThemeConfig> _appThemes = [];
  List<NavigatorObserver> _navigatorObservers = [];
  Widget Function({
    required ToastNotificationStyleType style,
    Function(ToastNotificationStyleMetaHelper helper)?
        toastNotificationStyleMeta,
    Function? onDismiss,
  })? _toastNotification;
  Map<Type, dynamic> _modelDecoders = {};
  Map<Type, dynamic> _controllerDecoders = {};
  Map<Type, dynamic> _singletonControllers = {};

  /// Create a new Nylo instance.
  Nylo({this.router, bool useNyRouteObserver = true})
      : _appLoader = CircularProgressIndicator(),
        _appLogo = SizedBox.shrink(),
        _navigatorObservers = useNyRouteObserver
            ? [
                NyRouteHistoryObserver(),
              ]
            : [];

  /// Assign a [NyPlugin] to add extra functionality to your app from a plugin.
  /// e.g. from main.dart
  /// Nylo.use(CustomPlugin());
  use(NyPlugin plugin) async {
    await plugin.initPackage(this);
    if (router == null) {
      router = NyRouter();
    }
    router!.setNyRoutes(plugin.routes());
    _events.addAll(plugin.events());
    NyNavigator.instance.router = this.router!;
  }

  /// Set the initial route from a [routeName].
  setInitialRoute(String routeName) {
    _initialRoute = routeName;
    if (!Backpack.instance.isNyloInitialized()) {
      Backpack.instance.set("nylo", this);
    }
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

    if (_singletonControllers.containsKey(controller))
      return _singletonControllers[controller];

    if (controllerValue is NyController) return controllerValue;

    dynamic controllerFound = controllerValue();
    if (!(controllerFound is NyController)) return null;

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
  /// NyRouter accountRouter() => nyRoutes((router) {
  ///    Add your routes here
  ///    router.route("/account", (context) => AccountPage());
  ///    router.route("/account/update", (context) => AccountUpdatePage());
  /// });
  ///
  /// Usage in /app/providers/route_provider.dart e.g. Nylo.addRouter(accountRouter());
  addRouter(NyRouter router) async {
    if (this.router == null) {
      this.router = NyRouter();
    }
    this.router!.setRegisteredRoutes(router.getRegisteredRoutes());
    NyNavigator.instance.router = this.router!;
  }

  /// Add themes to Nylo
  addThemes<T extends BaseColorStyles>(List<BaseThemeConfig<T>> themes) {
    _appThemes.addAll(themes);
  }

  /// Set if the app should monitor app usage like:
  /// - App launch count
  /// - Days since first launch
  /// If [_monitorAppUsage] is set to true, you'll be able to use the
  /// functions from the [NyAppUsage] class.
  monitorAppUsage() {
    _monitorAppUsage = true;
  }

  /// Check if the app should monitor app usage
  bool shouldMonitorAppUsage() => _monitorAppUsage ?? false;

  /// Show date time in logs
  showDateTimeInLogs() {
    _showDateTimeInLogs = true;
  }

  /// Check if the app should show date time in logs
  bool shouldShowDateTimeInLogs() => _showDateTimeInLogs ?? false;

  /// Add toast notification
  addToastNotification(
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
  addApiDecoders(Map<Type, dynamic> apiDecoders) {
    apiDecoders.entries.forEach((apiDecoder) {
      if (apiDecoder.value is NyApiService Function()) {
        _apiDecoders.addAll({apiDecoder.key: apiDecoder.value});
      }

      if (apiDecoder.value is NyApiService) {
        _singletonApiDecoders.addAll({apiDecoder.key: apiDecoder.value});
      }
    });
  }

  /// Get API decoders
  Map<Type, NyApiService Function()> getApiDecoders() => _apiDecoders;

  /// Add [events] to Nylo
  addEvents(Map<Type, NyEvent> events) async {
    _events.addAll(events);
  }

  /// Return all the registered events.
  Map<Type, NyEvent> getEvents() => _events;

  /// Add [validators] to Nylo
  addValidationRules(Map<String, dynamic> validators) {
    _validationRules.addAll(validators);
  }

  /// Get [validators] from Nylo
  Map<String, dynamic> getValidationRules() => _validationRules;

  /// Add [modelDecoders] to Nylo
  addModelDecoders(Map<Type, dynamic> modelDecoders) async {
    _modelDecoders.addAll(modelDecoders);
    if (!Backpack.instance.isNyloInitialized()) {
      Backpack.instance.set("nylo", this);
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
  addEventBus({int maxHistoryLength = 10, bool allowLogging = false}) {
    EventBus eventBus = EventBus(
      maxHistoryLength: maxHistoryLength,
      allowLogging: allowLogging,
    );
    final event = UpdateState();
    eventBus.watch(event);

    Backpack.instance.set("event_bus", eventBus);
  }

  /// Add appLoader
  addLoader(Widget appLoader) {
    _appLoader = appLoader;
  }

  /// Add appLogo
  addLogo(Widget appLogo) {
    _appLogo = appLogo;
  }

  /// Add Controllers to your Nylo project.
  addControllers(Map<Type, dynamic> controllers) {
    controllers.entries.forEach((controllerDecoder) {
      if (controllerDecoder.value is NyController Function()) {
        _controllerDecoders
            .addAll({controllerDecoder.key: controllerDecoder.value});
      }

      if (controllerDecoder.value is NyController) {
        _singletonControllers
            .addAll({controllerDecoder.key: controllerDecoder.value});
      }
    });

    if (!Backpack.instance.isNyloInitialized()) {
      Backpack.instance.set("nylo", this);
    }
  }

  /// Initialize Nylo
  static Future<Nylo> init(
      {Function? setup, Function(Nylo nylo)? setupFinished}) async {
    const String ENV_FILE = String.fromEnvironment(
      'ENV_FILE',
      defaultValue: '.env',
    );
    await dotenv.load(fileName: ENV_FILE);
    Intl.defaultLocale = getEnv('DEFAULT_LOCALE', defaultValue: 'en');
    initializeDateFormatting(Intl.defaultLocale, null);

    Nylo _nylo = Nylo();

    if (setup == null) {
      if (setupFinished != null) {
        await setupFinished(_nylo);
      }
      return _nylo;
    }

    _nylo = await setup();

    if (setupFinished != null) {
      await setupFinished(_nylo);
    }
    return _nylo;
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

  /// Get api decoders
  static Map<Type, NyApiService> apiDecoders() {
    Map<Type, NyApiService> apiDecoders = {};
    instance._apiDecoders.entries
        .forEach((e) => apiDecoders.addAll({e.key: e.value()}));
    apiDecoders.addAll(instance._singletonApiDecoders);
    return apiDecoders;
  }

  /// Add a navigator observer.
  addNavigatorObserver(NavigatorObserver observer) {
    _navigatorObservers.add(observer);
  }

  /// Return all the registered navigator observers.
  List<NavigatorObserver> getNavigatorObservers() => _navigatorObservers;

  /// Remove a navigator observer.
  removeNavigatorObserver(NavigatorObserver observer) {
    _navigatorObservers.remove(observer);
  }

  /// Add a route to the route history.
  static addRouteHistory(Route<dynamic> route) {
    NyNavigator.instance.router.addRouteHistory(route);
  }

  /// Remove a route from the route history.
  static removeRouteHistory(Route<dynamic> route) {
    NyNavigator.instance.router.removeRouteHistory(route);
  }

  /// Get the route history.
  static List<dynamic> getRouteHistory() {
    List<Map<String, dynamic>> list = [];
    List<Route<dynamic>> history =
        NyNavigator.instance.router.getRouteHistory();
    history.forEach((route) {
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
    });
    return list;
  }

  /// Remove a route from the route history.
  static removeLastRouteHistory() {
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
  static canMonitorAppUsage() {
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
  static scheduleOnce(String name, Function() callback) async {
    await NyScheduler.taskOnce(name, callback);
  }

  /// Schedule something to happen once daily
  static scheduleOnceDaily(String name, Function() callback,
      {DateTime? endAt}) async {
    await NyScheduler.taskDaily(name, callback, endAt: endAt);
  }

  /// Schedule something to happen once after a date
  static scheduleOnceAfterDate(String name, Function() callback,
      {required DateTime date}) async {
    await NyScheduler.taskOnceAfterDate(name, callback, date: date);
  }

  /// Wipe all storage data
  static Future<void> wipeAllStorageData() async {
    await NyStorage.deleteAll(andFromBackpack: true);
  }
}
