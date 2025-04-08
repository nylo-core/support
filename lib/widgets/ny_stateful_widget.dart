import 'package:flutter/cupertino.dart';
import '/controllers/controller.dart';
import '/controllers/ny_controller.dart';
import '/helpers/backpack.dart';
import '/nylo.dart';

/// StatefulWidget's include a [BaseController] to access from your child state.
abstract class NyStatefulWidget<T extends BaseController>
    extends StatefulWidget {
  /// Get the route [controller].
  late final T controller;

  /// State name
  final String? state;

  /// Child state
  final dynamic child;

  NyStatefulWidget({super.key, this.child, String? stateName})
      : state = stateName ?? child.toString() {
    Nylo nylo = Backpack.instance.nylo();
    controller = nylo.getController(T) ?? NyController();
  }

  @override
  StatefulElement createElement() => StatefulElement(this);

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() {
    if (child == null) {
      throw UnimplementedError();
    }
    if (child is State) {
      return child!;
    }
    if (child is Function) {
      dynamic child = this.child();
      assert(child is State, "Child must be a State");
      if (child is State) {
        return child;
      }
    }
    throw UnimplementedError();
  }

  /// Returns data that's sent via the Navigator or [routeTo] method.
  // ignore: avoid_shadowing_type_parameters
  T? data<T>({dynamic defaultValue}) {
    if (this.controller.request == null) return null;
    return this.controller.request!.data(defaultValue: defaultValue);
  }

  /// Returns query params
  dynamic queryParameters({String? key}) {
    if (this.controller.request == null) {
      return null;
    }
    return this.controller.request!.queryParameters(key: key);
  }

  /// Check if the [queryParameters] contains a specific key.
  bool hasQueryParameter(String key) {
    final queryParametersData = queryParameters();
    if (queryParametersData == null) return false;
    if (queryParametersData is Map) {
      return queryParametersData.containsKey(key);
    }
    return false;
  }
}
