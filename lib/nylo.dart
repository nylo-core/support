import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nylo_support/events/events.dart';
import 'package:nylo_support/plugin/nylo_plugin.dart';
import 'package:nylo_support/router/router.dart';
import 'package:nylo_support/themes/base_theme_config.dart';
export 'package:nylo_support/exceptions/validation_exception.dart';
export 'package:nylo_support/alerts/toast_enums.dart';

class Nylo {
  String initialRoute;
  Widget appLoader;
  Widget appLogo;

  late NyRouter? router;
  late Map<Type, NyEvent> _events = {};
  late List<BaseThemeConfig> appThemes = [];

  Nylo({this.router})
      : initialRoute = '/',
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

  /// Allows you to add additional Router's to your project.
  ///
  /// file: e.g. /lib/routes/account_router.dart
  /// NyRouter accountRouter() => nyRoutes((router) {
  ///    Add your routes here
  ///    router.route("/account", (context) => AccountPage());
  ///    router.route("/account/update", (context) => AccountUpdatePage());
  /// });
  ///
  /// Usage in /lib/main.dart e.g. Nylo.addRouter(accountRouter());
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

  /// Initialize Nylo
  static Future<Nylo> init(
      {Function? setup, Function(Nylo nylo)? setupFinished}) async {
    await dotenv.load(fileName: ".env");

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
