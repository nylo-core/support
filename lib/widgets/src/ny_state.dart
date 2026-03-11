import '/widgets/ny_widgets.dart';
import 'package:flutter/material.dart';

abstract class NyState<T extends StatefulWidget> extends NyBaseState<T> {
  /// Base NyState
  NyState({super.path});

  @override
  void initState() {
    super.initState();

    /// Set the state name if the widget is a NyStatefulWidget
    if (widget is NyStatefulWidget) {
      final _controller = (widget as NyStatefulWidget).controller;
      if (_controller.context == null) {
        _controller.construct(context);
      }
      if ((widget as NyStatefulWidget).state != null &&
          _controller.state == "/") {
        _controller.state = (widget as NyStatefulWidget).state!;
      }

      stateName = _controller.state;
    }

    if (allowStateUpdates && eventBus != null) {
      _restoreStateFromHistory();
      _subscribeToStateUpdates();
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

  /// Restores state data from the event bus history.
  void _restoreStateFromHistory() {
    final lastEvent = eventBus!.history
        .where((entry) => entry.event is UpdateState)
        .map((entry) => entry.event as UpdateState)
        .where((event) => event.stateName == stateName)
        .lastOrNull;

    if (lastEvent != null) {
      stateData = lastEvent.data;
    }
  }

  /// Subscribes to UpdateState events for this state.
  void _subscribeToStateUpdates() {
    eventSubscription = eventBus!.on<UpdateState>().listen((event) async {
      if (event.stateName != stateName) return;

      await stateUpdated(event.data);
      await _whenStateAction(event.data);
      if (mounted) setState(() {});
    });
  }

  /// Handle a state action for the current state.
  Future<void> _whenStateAction(dynamic data) async {
    if (data is! Map || !data.containsKey('action')) return;

    final action = data['action'] as String;
    final actionData = data['data'];

    final function = stateActions[action];
    if (function == null) return;

    try {
      await Function.apply(function, [actionData]);
    } on NoSuchMethodError {
      await Function.apply(function, []);
    }
  }
}
