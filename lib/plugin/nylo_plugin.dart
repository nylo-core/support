import '/events/events.dart';
import '/nylo.dart';
import '/router/router.dart';

/// [NyAppPlugin] interface class.
abstract class NyAppPlugin {
  initPackage(Nylo nylo) async {}
  construct() async {}
  routes() {}
  events() {}
}

/// [BasePlugin] class for NyPlugin.
class BasePlugin implements NyAppPlugin {
  late Nylo app;

  /// Provides the plugin with an instance of the [Nylo] app.
  /// After setting the [app] variable, construct() will be called.
  initPackage(Nylo nylo) async {
    app = nylo;
    await this.construct();
  }

  /// Initialize your plugin in the construct method.
  construct() async {}

  /// Add additional routes to a Nylo project via the [router].
  NyRouter routes() => nyRoutes((router) {});

  /// Add events to a Nylo project.
  Map<Type, NyEvent> events() => {};
}

class NyPlugin extends BasePlugin {
  /// Initialize your plugin.
  construct() async {}

  /// Add additional routes to a Nylo project via the [router].
  NyRouter routes() => nyRoutes((router) {
        // Add your routes here
        // router.route("/new-page", (context) => NewPage());
      });

  /// Add events to a Nylo project.
  Map<Type, NyEvent> events() => {};
}
