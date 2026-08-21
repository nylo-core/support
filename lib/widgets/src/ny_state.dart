import '/widgets/ny_widgets.dart';
import 'package:flutter/material.dart';

abstract class NyState<T extends StatefulWidget> extends NyBaseState<T> {
  /// Base NyState
  NyState({super.name, super.path});

  @override
  void initState() {
    super.initState();

    /// Set the state name if the widget is a NyStatefulWidget
    if (widget is NyStatefulWidget) {
      final _controller = (widget as NyStatefulWidget).controller;
      if (_controller.context == null) {
        _controller.construct(context);
      }
      /// Take the name from the widget, so this state listens on the name its
      /// senders use. A `name` or `path` given to this state wins over it.
      stateName ??= (widget as NyStatefulWidget).state;

      /// Point the controller at this page, so `controller.refreshPage()` and
      /// the other controller state helpers address the page the controller is
      /// being used from. A controller declared as a singleton is shared by
      /// every page that asks for it, so the name an earlier page left behind
      /// is replaced rather than kept.
      _controller.state = stateName;
    }

    /// Set the state name from a NyStateManaged widget that declares its baseState
    if (widget is NyStateManaged) {
      final managed = widget as NyStateManaged;
      if (managed.baseState != null) {
        stateName = managed.stateKey;
      }
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
