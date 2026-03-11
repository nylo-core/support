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
}
