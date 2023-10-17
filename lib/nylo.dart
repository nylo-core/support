import 'package:nylo_support/event_bus/event_bus_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nylo_support/alerts/toast_enums.dart';
import 'package:nylo_support/alerts/toast_meta.dart';
import 'package:nylo_support/events/events.dart';
import 'package:nylo_support/helpers/backpack.dart';
import 'package:nylo_support/plugin/nylo_plugin.dart';
import 'package:nylo_support/router/router.dart';
import 'package:nylo_support/themes/base_theme_config.dart';
import 'package:nylo_support/widgets/event_bus/update_state.dart';
export 'package:nylo_support/exceptions/validation_exception.dart';
export 'package:nylo_support/alerts/toast_enums.dart';

class Nylo {
  String? _initialRoute;
  Widget appLoader;
  Widget appLogo;
  NyRouter? router;
  Map<Type, NyEvent> _events = {};
  Map<String, dynamic> _validationRules = {};
  List<BaseThemeConfig> appThemes = [];
  Widget Function({
    required ToastNotificationStyleType style,
    Function(ToastNotificationStyleMetaHelper helper)?
        toastNotificationStyleMeta,
    Function? onDismiss,
  })? toastNotification;
  Map<Type, dynamic> _modelDecoders = {};
  Map<Type, dynamic> _controllers = {};

  Nylo({this.router})
      : appLoader = CircularProgressIndicator(),
        appLogo = SizedBox.shrink();

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
}
