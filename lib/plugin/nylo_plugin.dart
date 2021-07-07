import 'package:nylo_support/nylo.dart';

class NyPlugin {
  late Nylo nyloApp;

  initPackage(Nylo nylo) async {
    nyloApp = nylo;
    await this.construct();
  }

  construct() async {}
}
