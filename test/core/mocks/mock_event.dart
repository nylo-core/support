import 'package:nylo_support/events/ny_events.dart';

/// Mock event for testing event registration
class MockEvent extends NyEvent {
  bool wasFired = false;

  @override
  final Map<dynamic, NyListener> listeners = {MockListener: MockListener()};
}

/// Mock listener for testing event registration
class MockListener extends NyListener {
  static bool listenerCalled = false;

  static void reset() {
    listenerCalled = false;
  }

  @override
  Future handle(Map? params) async {
    listenerCalled = true;
    final nyEvent = getEvent();
    if (nyEvent is MockEvent) {
      nyEvent.wasFired = true;
    }
  }
}
