import 'package:flutter/cupertino.dart';
import 'package:nylo_support/controllers/controller.dart';

/// StatefulWidget's include a [BaseController] to access from your child state.
abstract class NyStatefulWidget extends StatefulWidget {
  final BaseController? controller;
  final String? routeName;

  String get route {
    assert(routeName != null,
        '${this.runtimeType.toString()} is missing a routeName');
    return (routeName ?? "");
  }

  NyStatefulWidget({Key? key, this.controller, this.routeName})
      : super(key: key);

  StatefulElement createElement() => StatefulElement(this);

  /// Get the route name for a page.
  /// e.g.
  /// getRouteName() {
  ///   return "/about-page";
  /// }
  String getRouteName() {
    if (this.routeName != null) {
      return this.routeName!;
    } else if (controller != null && controller!.context != null) {
      return ModalRoute.of(controller!.context!)!.settings.name ?? "";
    } else {
      return "";
    }
  }

  @override
  State<StatefulWidget> createState() {
    throw UnimplementedError();
  }

  /// Returns data that's sent via the Navigator or [routeTo] method.
  dynamic data() {
    if (this.controller == null) {
      return null;
    }
    if (this.controller!.request == null) {
      return null;
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
