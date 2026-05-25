import 'package:flutter/cupertino.dart';

class NyStateManaged extends StatefulWidget {
  /// Child state
  final dynamic child;

  /// Base state name for this widget type — used to compose the routing key.
  final String? baseState;

  /// Instance identifier used to namespace state actions for multi-instance widgets.
  final String? id;

  NyStateManaged({
    super.key,
    this.child,
    this.baseState,
    String? id,
    @Deprecated('Use `id` instead of `stateName`') String? stateName,
  }) : id = id ?? stateName;

  /// Full routing key: `baseState` when [id] is null, otherwise `"${baseState}_$id"`.
  String? get stateKey {
    if (baseState == null) return null;
    return id == null ? baseState : "${baseState}_$id";
  }

  @Deprecated('Use `id` instead of `stateName`')
  String? get stateName => id;

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
}
