import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import '/event_bus/ny_event_bus.dart';
import '/helpers/ny_helpers.dart';
import '/widgets/ny_widgets.dart';

/// Helpers for testing EventBus-driven state management in NyPage and NyState.
///
/// These utilities allow you to fire [UpdateState] events, trigger state actions,
/// and assert on state data without needing to manually interact with the EventBus.
///
/// ## Quick Start
///
/// ```dart
/// // Fire an update to a widget's state
/// fireStateUpdate('MyWidget', data: {'count': 1});
/// await tester.pump();
///
/// // Fire a state action
/// fireStateAction('MyWidget', 'refresh-page');
/// await tester.pump();
///
/// // Assert on state data
/// expectStateData(tester, find.byType(MyWidget), equals({'count': 1}));
/// ```
class NyStateTestHelpers {
  NyStateTestHelpers._();

  /// Track fired state updates for assertion purposes.
  static final List<_FiredStateUpdate> _firedUpdates = [];

  /// Track fired state actions for assertion purposes.
  static final List<_FiredStateAction> _firedActions = [];

  /// Reset all tracked state updates and actions.
  static void reset() {
    _firedUpdates.clear();
    _firedActions.clear();
  }

  /// Get all fired updates for a given [stateName].
  static List<_FiredStateUpdate> getUpdatesFor(String stateName) {
    return _firedUpdates.where((u) => u.stateName == stateName).toList();
  }

  /// Get all fired actions for a given [stateName].
  static List<_FiredStateAction> getActionsFor(String stateName) {
    return _firedActions.where((a) => a.stateName == stateName).toList();
  }
}

class _FiredStateUpdate {
  final String stateName;
  final dynamic data;
  final DateTime timestamp;

  _FiredStateUpdate(this.stateName, this.data) : timestamp = DateTime.now();
}

class _FiredStateAction {
  final String stateName;
  final String action;
  final dynamic data;
  final DateTime timestamp;

  _FiredStateAction(this.stateName, this.action, this.data)
    : timestamp = DateTime.now();
}

/// Fire an [UpdateState] event to a widget identified by [stateName].
///
/// This simulates calling `updateState(stateName, data: data)` from
/// another widget or controller.
///
/// Example:
/// ```dart
/// fireStateUpdate('HomePageState', data: {'items': ['a', 'b']});
/// await tester.pump();
/// expect(find.text('a'), findsOneWidget);
/// ```
void fireStateUpdate(String stateName, {dynamic data}) {
  final eventBus = Backpack.instance.read<EventBus>("event_bus");
  if (eventBus == null) {
    throw StateError(
      'EventBus not found in Backpack. '
      'Ensure Nylo is initialized before firing state updates.',
    );
  }

  NyStateTestHelpers._firedUpdates.add(_FiredStateUpdate(stateName, data));
  eventBus.fire(UpdateState(stateName: stateName, data: data));
}

/// Fire a state action to a widget identified by [stateName].
///
/// This sends an [UpdateState] event with action data that will be
/// processed by `whenStateAction()` handlers in NyPage/NyState.
///
/// Example:
/// ```dart
/// fireStateAction('HomePageState', 'refresh-page');
/// await tester.pump();
///
/// fireStateAction('CartState', 'add-item', data: {'id': 42});
/// await tester.pump();
/// ```
void fireStateAction(String stateName, String action, {dynamic data}) {
  final actionData = <String, dynamic>{'action': action};
  if (data != null) {
    actionData['data'] = data;
  }
  fireStateUpdate(stateName, data: actionData);
  NyStateTestHelpers._firedActions.add(
    _FiredStateAction(stateName, action, data),
  );
}

/// Assert that a state update was fired to the given [stateName].
///
/// Optionally check that it was fired a specific number of [times].
///
/// Example:
/// ```dart
/// fireStateUpdate('MyWidget', data: 'hello');
/// expectStateUpdated('MyWidget');
/// expectStateUpdated('MyWidget', times: 1);
/// ```
void expectStateUpdated(String stateName, {int? times}) {
  final updates = NyStateTestHelpers.getUpdatesFor(stateName);
  if (times != null) {
    expect(
      updates.length,
      times,
      reason:
          'Expected $times state update(s) for "$stateName" '
          'but found ${updates.length}',
    );
  } else {
    expect(
      updates,
      isNotEmpty,
      reason: 'Expected at least one state update for "$stateName"',
    );
  }
}

/// Assert that a state action was fired to the given [stateName].
///
/// Optionally verify the specific [action] name and number of [times].
///
/// Example:
/// ```dart
/// fireStateAction('MyWidget', 'refresh-page');
/// expectStateAction('MyWidget', 'refresh-page');
/// ```
void expectStateAction(String stateName, String action, {int? times}) {
  final actions = NyStateTestHelpers.getActionsFor(
    stateName,
  ).where((a) => a.action == action).toList();
  if (times != null) {
    expect(
      actions.length,
      times,
      reason:
          'Expected action "$action" on "$stateName" to fire $times '
          'time(s) but found ${actions.length}',
    );
  } else {
    expect(
      actions,
      isNotEmpty,
      reason: 'Expected action "$action" to have been fired on "$stateName"',
    );
  }
}

/// Assert the [stateData] of a NyPage or NyState widget.
///
/// Finds the widget using [finder] and checks its [stateData] against
/// the provided [matcher]. The [finder] should match a [StatefulWidget]
/// whose state extends [NyBaseState].
///
/// Example:
/// ```dart
/// fireStateUpdate('MyWidget', data: 42);
/// await tester.pump();
/// expectStateData(tester, find.byType(MyWidget), equals(42));
/// ```
void expectStateData(WidgetTester tester, Finder finder, dynamic matcher) {
  final elements = finder.evaluate();
  if (elements.isEmpty) {
    fail('No widget found for finder: $finder');
  }
  final element = elements.first;

  if (element is StatefulElement && element.state is NyBaseState) {
    expect(
      (element.state as NyBaseState).stateData,
      matcher,
      reason: 'State data did not match expected value',
    );
  } else {
    fail(
      'Widget state is not a NyBaseState. '
      'Element: ${element.runtimeType}',
    );
  }
}
