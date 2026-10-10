import 'package:nylo_support/events/ny_events.dart';

/// Mock event for testing event registration
class MockEvent extends NyEvent {
  bool wasFired = false;

  MockEvent() {
    listeners[MockListener] = MockListener();
  }
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
    final NyEvent? nyEvent = getEvent();
    if (nyEvent is MockEvent) {
      nyEvent.wasFired = true;
    }
  }
}
