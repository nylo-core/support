import 'package:nylo_support/ny_core.dart';

/// State actions
abstract class StateActions {
  String state;

  StateActions(this.state);

  /// Call an action on a state.
  /// The [action] is a string that represents the action you want to perform on the state.
  /// The [state] is the state you want to perform the action on.
  /// The [data] is the data you want to pass to the action.
  void action(String action, {dynamic data}) {
    stateAction(action, state: state, data: data);
  }

  /// Call the [name] action on the state, with optional [data].
  ///
  /// The same as [action] with the data positional, so an actions object reads
  /// like a command: `HomePage.actions.call("shake_the_logo", {"times": 3})`.
  /// As the method is named `call`, the object is callable as well:
  /// `HomePage.actions("shake_the_logo")`.
  void call(String name, [dynamic data]) {
    action(name, data: data);
  }
}
