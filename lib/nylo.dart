import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nylo_support/plugin/nylo_plugin.dart';
import 'package:nylo_support/router/router.dart';
export 'package:nylo_support/exceptions/validation_exception.dart';
export 'package:nylo_support/alerts/toast_enums.dart';

class Nylo {
  late NyRouter? router;
  late Map<Type, NyEvent> _events = {};

  Nylo({this.router});

  /// Assign a [NyPlugin] to add extra functionality to your app from a plugin.
  /// e.g. from main.dart
  /// Nylo.use(CustomPlugin());
  use(NyPlugin plugin) async {
    await plugin.initPackage(this);
    if (router == null) {
      router = NyRouter();
    }
    router!.setNyRoutes(plugin.routes());
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
  }

  addEvents(Map<Type, NyEvent> events) async {
    if (this.router == null) {
      _events = {};
    }
    _events.addAll(events);
  }

  Map<Type, NyEvent> getEvents() => _events;

  /// Run to init Nylo
  static Future<Nylo> init({NyRouter? router, Function? setup}) async {
    await dotenv.load(fileName: ".env");

    if (setup != null) {
      return await setup();
    }
    if (router != null) {
      return Nylo(router: router);
    }
    return Nylo();
  }
}

abstract class NyEvent {
  final Map<Type, NyListener> listeners = {};
}

class NyListener {
  late NyEvent _event;

  setEvent(NyEvent event) {
    _event = event;
  }

  NyEvent getEvent() => _event;

  Future<dynamic> handle(Map params) async {}
}
