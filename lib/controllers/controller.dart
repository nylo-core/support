import 'package:flutter/cupertino.dart';
import 'package:nylo_support/router/models/ny_argument.dart';
import 'package:nylo_support/widgets/ny_stateful_widget.dart';

/// Base class to handle requests
class NyRequest {
  String? currentRoute;
  NyArgument? _args;
  NyRequest({this.currentRoute, NyArgument? args}) {
    _args = args;
  }

  /// Write [data] to controller
  setData(dynamic data) {
    _args!.data = data;
  }

  /// Returns data passed as an argument to a route
  dynamic data() => (_args == null ? null : _args!.data);
}

/// Nylo's base controller class
abstract class BaseController {
  BuildContext? context;
  NyRequest? request;

  BaseController({this.context, this.request});

  /// Returns any data passed through a [Navigator] or [routeTo] method.
  dynamic data() => this.request!.data();

  /// Initialize your controller with this method.
  /// It contains same [BuildContext] as the [NyStatefulWidget].
  construct(BuildContext context) async {}
}
