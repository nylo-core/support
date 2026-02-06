import 'package:nylo_support/event_bus/ny_event_bus.dart';
import 'package:nylo_support/widgets/src/event_bus/update_state.dart';

/// Mock implementation of [EventBus] for testing
/// Tracks all fired events for test assertions
class MockEventBus extends EventBus {
  /// List of all events that have been fired
  final List<AppEvent> firedEvents = [];

  /// List of events that are being watched
  final List<AppEvent> watchedEvents = [];

  /// List of events that have been completed
  final List<AppEvent> completedEvents = [];

  MockEventBus() : super();

  @override
  void fire(AppEvent event) {
    firedEvents.add(event);
    super.fire(event);
  }

  @override
  void watch(AppEvent event) {
    watchedEvents.add(event);
    super.watch(event);
  }

  @override
  void complete(AppEvent event, {AppEvent? nextEvent}) {
    completedEvents.add(event);
    super.complete(event, nextEvent: nextEvent);
  }

  @override
  void reset() {
    firedEvents.clear();
    watchedEvents.clear();
    completedEvents.clear();
    super.reset();
  }

  /// Helper to find UpdateState events
  List<UpdateState> get updateStateEvents =>
      firedEvents.whereType<UpdateState>().toList();

  /// Helper to check if an UpdateState was fired with a specific state name
  bool hasUpdateStateFor(String stateName) {
    return updateStateEvents.any((e) => e.stateName == stateName);
  }

  /// Helper to get UpdateState events for a specific state name
  List<UpdateState> getUpdateStatesFor(String stateName) {
    return updateStateEvents.where((e) => e.stateName == stateName).toList();
  }
}
