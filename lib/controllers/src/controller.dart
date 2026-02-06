import 'package:flutter/cupertino.dart';
import '/router/ny_router.dart';
import '/widgets/ny_widgets.dart';

/// Base class to handle requests
class NyRequest {
  String? currentRoute;
  NyArgument? _args;
  NyQueryParameters? _queryParameters;

  NyRequest({
    this.currentRoute,
    NyArgument? args,
    NyQueryParameters? queryParameters,
  }) {
    _args = args;
    _queryParameters = queryParameters;
  }

  /// Write [data] to controller
  void setData(dynamic data) {
    _args?.data = data;
  }

  /// Returns data passed as an argument to a page
  /// e.g. routeTo("/my-page", data: {"hello": "world"})
  T? data<T>({dynamic defaultValue}) {
    if (_args == null) {
      return defaultValue;
    }

    dynamic data = _args!.data;
    if (data == null) {
      return defaultValue;
    }

    return data;
  }

  /// Returns the queryParameters passed to a page
  /// e.g. /my-page?hello=world
  T? queryParameters<T>({String? key}) {
    if (_queryParameters == null) {
      return null;
    }

    dynamic data = _queryParameters!.data;
    if (key != null && data is Map) {
      if (data.containsKey(key)) {
        return data[key] as T?;
      } else {
        return null;
      }
    }

    return data as T?;
  }
}

/// Nylo's base controller class
abstract class BaseController {
  BuildContext? context;
  NyRequest? request;
  String? state;

  /// List of route guards
  List<RouteGuard> routeGuards = [];

  BaseController({this.context, this.request, this.state = "/"});

  /// Returns any data passed through a [Navigator] or [routeTo] method.
  T? data<T>({dynamic defaultValue}) =>
      request?.data(defaultValue: defaultValue) ?? defaultValue;

  /// Returns any query parameters passed in a route
  /// e.g. /my-page?hello=world
  /// Result {"hello": "world"}
  T? queryParameters<T>({String? key}) => request?.queryParameters<T>(key: key);

  /// Initialize your controller with this method.
  /// It contains same [BuildContext] as the [NyStatefulWidget].
  @mustCallSuper
  Future<void> construct(BuildContext context) async {
    this.context = context;
  }
}
