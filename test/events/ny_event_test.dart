import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/events/ny_events.dart';
import 'package:nylo_support/testing/ny_testing.dart';

/// Test implementation of NyEvent
class TestEvent extends NyEvent {}

/// Test implementation with custom listeners map
class TestEventWithListeners extends NyEvent {
  TestEventWithListeners() {
    listeners['listener1'] = TestListener();
    listeners['listener2'] = TestListener();
  }
}

/// Simple test listener
class TestListener extends NyListener {
  int handleCallCount = 0;
  Map? lastEventData;

  @override
  Future handle(Map? event) async {
    handleCallCount++;
    lastEventData = event;
  }
}

void main() {
  NyTest.init();

  nyGroup('NyEvent', () {
    nyGroup('constructor', () {
      nyTest('should create an instance with empty listeners map', () async {
        final event = TestEvent();

        expect(event.listeners, isA<Map>());
        expect(event.listeners, isEmpty);
      });
    });

    nyGroup('listeners', () {
      nyTest('should allow adding listeners', () async {
        final event = TestEvent();
        final listener = TestListener();

        event.listeners['myListener'] = listener;

        expect(event.listeners.length, 1);
        expect(event.listeners['myListener'], listener);
      });

      nyTest('should allow multiple listeners', () async {
        final event = TestEvent();
        final listener1 = TestListener();
        final listener2 = TestListener();

        event.listeners['listener1'] = listener1;
        event.listeners['listener2'] = listener2;

        expect(event.listeners.length, 2);
        expect(event.listeners['listener1'], listener1);
        expect(event.listeners['listener2'], listener2);
      });

      nyTest('should allow removing listeners', () async {
        final event = TestEvent();
        final listener = TestListener();

        event.listeners['myListener'] = listener;
        event.listeners.remove('myListener');

        expect(event.listeners, isEmpty);
      });

      nyTest('should initialize listeners in subclass constructor', () async {
        final event = TestEventWithListeners();

        expect(event.listeners.length, 2);
        expect(event.listeners.containsKey('listener1'), isTrue);
        expect(event.listeners.containsKey('listener2'), isTrue);
      });

      nyTest('should allow overwriting listeners', () async {
        final event = TestEvent();
        final listener1 = TestListener();
        final listener2 = TestListener();

        event.listeners['key'] = listener1;
        event.listeners['key'] = listener2;

        expect(event.listeners.length, 1);
        expect(event.listeners['key'], listener2);
      });

      nyTest('should support any key type', () async {
        final event = TestEvent();
        final listener = TestListener();

        event.listeners[1] = listener;
        event.listeners['string'] = listener;
        event.listeners[true] = listener;

        expect(event.listeners.length, 3);
      });
    });

    nyGroup('inheritance', () {
      nyTest('should be distinguishable by runtime type', () async {
        final event1 = TestEvent();
        final event2 = TestEventWithListeners();

        expect(event1.runtimeType, TestEvent);
        expect(event2.runtimeType, TestEventWithListeners);
        expect(event1.runtimeType, isNot(event2.runtimeType));
      });
    });
  });
}
