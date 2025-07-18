import '/widgets/ny_base_state.dart';
import '/event_bus/event_bus_plus.dart';
import 'package:flutter/material.dart';
import '/widgets/event_bus/update_state.dart';
import '/widgets/ny_stateful_widget.dart';

abstract class NyState<T extends StatefulWidget> extends NyBaseState<T> {
  /// Base NyState
  NyState({super.path});

  @override
  void initState() {
    super.initState();

    /// Set the state name if the widget is a NyStatefulWidget
    if (widget is NyStatefulWidget) {
      stateName = (widget as NyStatefulWidget).controller.state;
    }

    if (allowStateUpdates) {
      List<EventBusHistoryEntry> eventHistory = eventBus!.history
          .where((element) =>
              element.event.runtimeType.toString() == 'UpdateState')
          .toList();
      if (eventHistory.isNotEmpty) {
        List<Object?> props = eventHistory
                .where((element) {
                  return element.event.props.isNotEmpty &&
                      element.event.props[0] == stateName;
                })
                .map((e) => e.event.props)
                .firstOrNull ??
            [];
        if (props.isNotEmpty) {
          stateData = props[1];
        }
      }
      eventSubscription = eventBus!.on<UpdateState>().listen((event) async {
        if (event.stateName != stateName) return;

        await stateUpdated(event.data);
        await _whenStateAction(event.data);
        setState(() {});
      });
    }

    if (!shouldLoadView) {
      init();
      hasInitComplete = true;
      return;
    }

    awaitData(
      perform: () async {
        await init();
        hasInitComplete = true;
      },
      shouldSetStateBefore: false,
    );
  }

  /// Handle a state action for the current state
  Future _whenStateAction(dynamic data) async {
    if (data is! Map) {
      return;
    }

    if (!(data.containsKey('action'))) {
      return;
    }

    String action = data['action'];
    dynamic actionData = data.containsKey('data') ? data['data'] : null;

    if (stateActions.containsKey(action)) {
      final function = stateActions[action]!;

      String functionString = function.runtimeType.toString();

      // Determine if the function takes parameters based on its toString representation
      bool hasParameters = functionString.contains("(dynamic)") ||
          functionString.contains("(Object?)") ||
          !functionString.contains("()");

      if (hasParameters) {
        await Function.apply(function, [actionData]);
        return;
      }

      await Function.apply(function, []);
    }
  }
}
