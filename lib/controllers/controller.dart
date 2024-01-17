import 'package:flutter/cupertino.dart';
import 'package:nylo_support/router/models/ny_argument.dart';
import 'package:nylo_support/widgets/ny_stateful_widget.dart';
import '../router/models/ny_query_parameters.dart';

/// Base class to handle requests
class NyRequest {
  String? currentRoute;
  NyArgument? _args;
  NyQueryParameters? _queryParameters;
  NyRequest(
      {this.currentRoute,
      NyArgument? args,
      NyQueryParameters? queryParameters}) {
    _args = args;
    _queryParameters = queryParameters;
  }

  /// Write [data] to controller
  setData(dynamic data) {
    _args!.data = data;
  }

  /// Returns data passed as an argument to a page
  /// e.g. routeTo("/my-page", data: {"hello": "world"})
  dynamic data({String? key}) {
    if (_args == null) {
      return null;
    }

    dynamic data = _args!.data;

    if (key != null && data is Map) {
      if (data.containsKey(key)) {
        return data[key];
      } else {
        return null;
      }
    }

    return data;
  }

  /// Returns the queryParameters passed to a page
  /// e.g. /my-page?hello=world
  dynamic queryParameters({String? key}) {
    if (_queryParameters == null) {
      return null;
    }

    dynamic data = _queryParameters!.data;
    if (key != null && data is Map) {
      if (data.containsKey(key)) {
        return data[key];
      } else {
        return null;
      }
    }

    return data;
  }
}

/// Nylo's base controller class
abstract class BaseController {
  BuildContext? context;
  NyRequest? request;
  String? state;

  BaseController({this.context, this.request, this.state = "/"});

  /// Returns any data passed through a [Navigator] or [routeTo] method.
  dynamic data({String? key}) => this.request?.data(key: key);

  /// Returns any query parameters passed in a route
  /// e.g. /my-page?hello=world
  /// Result {"hello": "world"}
  dynamic queryParameters({String? key}) =>
      this.request?.queryParameters(key: key);

  /// Initialize your controller with this method.
  /// It contains same [BuildContext] as the [NyStatefulWidget].
  @mustCallSuper
  construct(BuildContext context) async {
    this.context = context;
  }
}
