import '/event_bus/ny_event_bus.dart';
import 'backpack.dart';
import 'ny_logger.dart';
import 'state_name.dart';
import '/router/ny_router.dart';
import '/widgets/ny_widgets.dart';

/// Update's the state of a NyState Widget in your application.
/// Provide the [name] of the state and then return a value in the callback [setValue].
///
/// Example using data param
/// `updateState<double>(NotificationCounter.state, data: {"value": 10});`
///
/// Example in your NyState widget
/// @override
/// stateUpdated(dynamic data) async {
///   print(data['value']); // 10
/// }
///
///
/// Example using setValue param
/// `updateState<double>(ShoppingCartIcon.state, setValue: (currentValue) { ... });`
///
/// `updateState<double>(ShoppingCartIcon.state, setValue: (currentValue) { ... });`
///
/// Example in your NyState widget
/// @override
/// stateUpdated(dynamic data) async {
///   print(data); // 2
/// }
///
void updateState<T>(
  dynamic name, {
  dynamic data,
  dynamic Function(T? currentValue)? setValue,
}) {
  EventBus? eventBus = Backpack.instance.read("event_bus");
  if (eventBus == null) {
    NyLogger.error(
      'Event bus not defined. Please ensure that your project has called nylo.addEventBus() in one of your providers.',
    );
    return;
  }

  String stateName = '';
  if (name is String) {
    stateName = name;
  }
  if (name is RouteView) {
    stateName = nyStateNameForRoute(name);
  }

  dynamic dataUpdate = data;
  if (setValue != null) {
    List<EventBusHistoryEntry> eventHistory = eventBus.history.where((element) {
      final event = element.event;
      if (event is! UpdateState) {
        return false;
      }
      return event.stateName == stateName;
    }).toList();
    if (eventHistory.isNotEmpty) {
      T? lastValue = (eventHistory.last.event as UpdateState).data as T?;
      dataUpdate = setValue(lastValue);
    }
  }

  final event = UpdateState(data: dataUpdate, stateName: stateName);
  eventBus.fire(event);
}

/// Send a state action to a [NyState] or [NyPage] in your application.
/// Provide the [state] and the [action] you want to send.
///
/// Pass [id] to target a specific instance of a `NyStateManaged` widget — the
/// routing key becomes `"${state}_$id"`.
void stateAction(
  String action, {
  required dynamic state,
  dynamic data,
  String? id,
}) {
  dynamic target = state;
  if (id != null && state is String) {
    target = "${state}_$id";
  }
  updateState(target, data: {"action": action, "data": data});
}
