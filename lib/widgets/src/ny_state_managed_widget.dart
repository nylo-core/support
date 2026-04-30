import 'package:flutter/cupertino.dart';

class NyStateManaged extends StatefulWidget {
  /// Child state
  final dynamic child;

  /// State name
  final String? stateName;

  NyStateManaged({super.key, this.child, String? stateName})
    : stateName = stateName;

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
