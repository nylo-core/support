import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nylo_support/events/events.dart';
import 'package:nylo_support/helpers/backpack.dart';
import 'package:nylo_support/plugin/nylo_plugin.dart';
import 'package:nylo_support/router/router.dart';
import 'package:nylo_support/themes/base_theme_config.dart';
export 'package:nylo_support/exceptions/validation_exception.dart';
export 'package:nylo_support/alerts/toast_enums.dart';

class Nylo {
  String _initialRoute;
  Widget appLoader;
  Widget appLogo;

  NyRouter? router;
  Map<Type, NyEvent> _events = {};
  Map<String, dynamic> _validationRules = {};
  List<BaseThemeConfig> appThemes = [];
  Map<Type, dynamic> _modelDecoders = {};

  Nylo({this.router})
      : _initialRoute = '/',
        appLoader = CircularProgressIndicator(),
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
    Backpack.instance.set("nylo", this);
  }

  /// Get the initial route.
  String getInitialRoute() => _initialRoute;

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

  addValidationRules(Map<String, dynamic> validators) {
    _validationRules.addAll(validators);
  }

  Map<String, dynamic> getValidationRules() => _validationRules;

  /// Add [events] to Nylo
  addModelDecoders(Map<Type, dynamic> events) async {
    _modelDecoders.addAll(events);
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
