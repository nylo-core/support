import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/router/router.dart';

abstract class NyAppPlugin {
  initPackage(Nylo nylo) async {}
  construct() async {}
  routes() {}
}

class BasePlugin implements NyAppPlugin {
  late Nylo app;

  initPackage(Nylo nylo) async {
    app = nylo;
    await this.construct();
  }

  construct() async {}

  NyRouter routes() => nyRoutes((router) {});
}

class NyPlugin extends BasePlugin {
  construct() async {}

  NyRouter routes() => nyRoutes((router) {
        // Add your routes here
        // router.route("/new-page", (context) => NewPage());
      });
}
