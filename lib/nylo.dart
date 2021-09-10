import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nylo_support/plugin/nylo_plugin.dart';
import 'package:nylo_support/router/router.dart';

class Nylo {
  late NyRouter? router;

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

  /// Run to init Nylo
  static Future<Nylo> init({required router}) async {
    await dotenv.load(fileName: ".env");

    return Nylo(router: router);
  }
}
