import 'package:flutter/cupertino.dart';
import '/controllers/ny_controllers.dart';
import '/helpers/ny_helpers.dart';
import '/helpers/src/state_name.dart';
import '/nylo.dart';

/// StatefulWidget's include a [BaseController] to access from your child state.
abstract class NyStatefulWidget<T extends BaseController>
    extends StatefulWidget {
  /// Get the route [controller].
  late final T controller;

  /// The state name passed to the constructor, when one was given.
  final String? declaredStateName;

  /// Child state
  final dynamic child;

  /// State name
  ///
  /// The `stateName` given to the constructor, otherwise the name derived from
  /// this widget's class - e.g. `MyPage` -> `Closure: () => _MyPageState`.
  ///
  /// This is the name the widget's [NyPage] or [NyState] listens on, and the
  /// same name [RouteViewExt.stateName] gives a sender holding the widget's
  /// [RouteView], so both ends read one class: this one.
  String? get state =>
      declaredStateName ?? nyStateNameForWidget(runtimeType.toString());

  NyStatefulWidget({super.key, this.child, String? stateName})
    : declaredStateName = stateName {
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
