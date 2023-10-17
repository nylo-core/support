import 'package:flutter/cupertino.dart';
import 'package:nylo_support/controllers/controller.dart';
import 'package:nylo_support/controllers/ny_controller.dart';
import 'package:nylo_support/helpers/backpack.dart';
import 'package:nylo_support/nylo.dart';

/// StatefulWidget's include a [BaseController] to access from your child state.
abstract class NyStatefulWidget<T extends BaseController>
    extends StatefulWidget {
  /// Get the route [controller].
  late final T? controller;

  /// Get the route [path] for the page.
  static const String? path = "";

  NyStatefulWidget({Key? key}) : super(key: key) {
    Nylo nylo = Backpack.instance.nylo();
    controller = nylo.getController(T) ?? NyController();
  }

  StatefulElement createElement() => StatefulElement(this);

  @override
  State<StatefulWidget> createState() {
    throw UnimplementedError();
  }

  /// Returns data that's sent via the Navigator or [routeTo] method.
  dynamic data({String? key}) {
    if (this.controller?.request == null) {
      return null;
    }
    if (key != null && this.controller!.request!.data() is Map) {
      return this.controller!.request!.data()[key];
    }
    return this.controller!.request!.data();
  }

  /// Returns query params
  dynamic queryParameters() {
    if (this.controller == null) {
      return null;
    }
    if (this.controller!.request == null) {
      return null;
    }
    return this.controller!.request!.queryParameters();
  }
}
