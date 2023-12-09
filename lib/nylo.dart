import 'package:nylo_support/event_bus/event_bus_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nylo_support/alerts/toast_enums.dart';
import 'package:nylo_support/alerts/toast_meta.dart';
import 'package:nylo_support/events/events.dart';
import 'package:nylo_support/helpers/backpack.dart';
import 'package:nylo_support/networking/ny_api_service.dart';
import 'package:nylo_support/plugin/nylo_plugin.dart';
import 'package:nylo_support/router/observers/ny_route_history_observer.dart';
import 'package:nylo_support/router/router.dart';
import 'package:nylo_support/themes/base_color_styles.dart';
import 'package:nylo_support/themes/base_theme_config.dart';
import 'package:nylo_support/widgets/event_bus/update_state.dart';
import 'package:theme_provider/theme_provider.dart';
export 'package:nylo_support/exceptions/validation_exception.dart';
export 'package:nylo_support/alerts/toast_enums.dart';

class Nylo {
  String? _initialRoute;
  Widget _appLoader;
  Widget _appLogo;
  NyRouter? router;
  Map<Type, NyEvent> _events = {};
  Map<String, dynamic> _validationRules = {};
  final Map<Type, NyApiService> _apiDecoders = {};
  List<BaseThemeConfig> _appThemes = [];
  List<NavigatorObserver> _navigatorObservers = [];
  Widget Function({
    required ToastNotificationStyleType style,
    Function(ToastNotificationStyleMetaHelper helper)?
        toastNotificationStyleMeta,
    Function? onDismiss,
  })? _toastNotification;
  Map<Type, dynamic> _modelDecoders = {};
  Map<Type, dynamic> _controllers = {};

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
    return _controllers[controller];
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
  addApiDecoders(Map<Type, NyApiService> apiDecoders) {
    _apiDecoders.addAll(apiDecoders);
  }

  /// Get API decoders
  Map<Type, NyApiService> getApiDecoders() => _apiDecoders;

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
    _controllers.addAll(controllers);
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

  /// Get model decoders
  static Map<Type, NyApiService> apiDecoders() => instance.getApiDecoders();

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
  static List<Route<dynamic>> getRouteHistory() {
    return NyNavigator.instance.router.getRouteHistory();
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
    return NyNavigator.instance.router.getCurrentRoute()?.settings.arguments;
  }

  /// Get previous route name
  static String? getPreviousRouteName() {
    return NyNavigator.instance.router.getPreviousRoute()?.settings.name;
  }

  /// Get previous route arguments
  static dynamic getPreviousRouteArguments() {
    return NyNavigator.instance.router.getPreviousRoute()?.settings.arguments;
  }

  /// Get previous route
  static Route<dynamic>? getPreviousRoute() {
    return NyNavigator.instance.router.getPreviousRoute();
  }

  /// Check if the current route is [routeName]
  static bool isCurrentRoute(String routeName) =>
      getCurrentRouteName() == routeName;
}
