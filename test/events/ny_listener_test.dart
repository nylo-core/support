import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/events/ny_events.dart';
import 'package:nylo_support/testing/ny_testing.dart';

/// Test implementation of NyEvent
class TestEvent extends NyEvent {}

/// Another test event for type verification
class AnotherTestEvent extends NyEvent {}

/// Test listener that tracks handle calls
class TrackingListener extends NyListener {
  int handleCallCount = 0;
  Map? lastEventData;
  dynamic returnValue;

  @override
  Future handle(Map? event) async {
    handleCallCount++;
    lastEventData = event;
    return returnValue;
  }
}

/// Listener that throws an exception
class ThrowingListener extends NyListener {
  @override
  Future handle(Map? event) async {
    throw Exception('Test exception');
  }
}

/// Async listener with delay
class AsyncListener extends NyListener {
  int handleCallCount = 0;
  Duration delay;

  AsyncListener({this.delay = const Duration(milliseconds: 10)});

  @override
  Future handle(Map? event) async {
    await Future.delayed(delay);
    handleCallCount++;
  }
}

void main() {
  NyTest.init();

  nyGroup('NyListener', () {
    nyGroup('setEvent()', () {
      nyTest('should store the event', () async {
        final listener = TrackingListener();
        final event = TestEvent();

        listener.setEvent(event);

        expect(listener.getEvent(), event);
      });

      nyTest('should overwrite previously set event', () async {
        final listener = TrackingListener();
        final event1 = TestEvent();
        final event2 = AnotherTestEvent();

        listener.setEvent(event1);
        listener.setEvent(event2);

        expect(listener.getEvent(), event2);
      });

      nyTest('should store events of different types', () async {
        final listener = TrackingListener();
        final event = AnotherTestEvent();

        listener.setEvent(event);

        expect(listener.getEvent(), isA<AnotherTestEvent>());
      });
    });

    nyGroup('getEvent()', () {
      nyTest('should return the set event', () async {
        final listener = TrackingListener();
        final event = TestEvent();

        listener.setEvent(event);
        final retrieved = listener.getEvent();

        expect(retrieved, equals(event));
        expect(identical(retrieved, event), isTrue);
      });

      nyTest('should return the correct event type', () async {
        final listener = TrackingListener();
        final event = TestEvent();

        listener.setEvent(event);

        expect(listener.getEvent(), isA<NyEvent>());
        expect(listener.getEvent(), isA<TestEvent>());
      });
    });

    nyGroup('handle()', () {
      nyTest('should be callable with null event data', () async {
        final listener = TrackingListener();

        await listener.handle(null);

        expect(listener.handleCallCount, 1);
        expect(listener.lastEventData, isNull);
      });

      nyTest('should receive event data map', () async {
        final listener = TrackingListener();
        final eventData = {'key': 'value', 'number': 42};

        await listener.handle(eventData);

        expect(listener.handleCallCount, 1);
        expect(listener.lastEventData, eventData);
      });

      nyTest('should be callable multiple times', () async {
        final listener = TrackingListener();

        await listener.handle({'call': 1});
        await listener.handle({'call': 2});
        await listener.handle({'call': 3});

        expect(listener.handleCallCount, 3);
        expect(listener.lastEventData, {'call': 3});
      });

      nyTest('should handle empty map', () async {
        final listener = TrackingListener();

        await listener.handle({});

        expect(listener.handleCallCount, 1);
        expect(listener.lastEventData, isEmpty);
      });

      nyTest('should handle complex nested data', () async {
        final listener = TrackingListener();
        final complexData = {
          'user': {'id': 1, 'name': 'Test'},
          'items': [1, 2, 3],
          'nested': {
            'deep': {'value': true},
          },
        };

        await listener.handle(complexData);

        expect(listener.lastEventData, complexData);
      });

      nyTest('base class handle should complete without error', () async {
        final listener = NyListener();
        final event = TestEvent();
        listener.setEvent(event);

        // Should not throw
        await expectLater(listener.handle({'data': 'test'}), completes);
      });

      nyTest('should return value from handle', () async {
        final listener = TrackingListener();
        listener.returnValue = 'custom-return';

        final result = await listener.handle({'data': 'test'});

        expect(result, 'custom-return');
      });

      nyTest('should return false to stop propagation', () async {
        final listener = TrackingListener();
        listener.returnValue = false;

        final result = await listener.handle({'data': 'test'});

        expect(result, false);
      });
    });

    nyGroup('async behavior', () {
      nyTest('should support async handle', () async {
        final listener = AsyncListener(delay: const Duration(milliseconds: 5));

        await listener.handle(null);

        expect(listener.handleCallCount, 1);
      });

      nyTest('should await handle completion', () async {
        final listener = AsyncListener(delay: const Duration(milliseconds: 10));
        final stopwatch = Stopwatch()..start();

        await listener.handle(null);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(10));
      });
    });

    nyGroup('error handling', () {
      nyTest('should throw exceptions from handle', () async {
        final listener = ThrowingListener();

        await expectLater(
          () => listener.handle(null),
          throwsA(isA<Exception>()),
        );
      });
    });

    nyGroup('event and handle interaction', () {
      nyTest('should access event within handle', () async {
        final event = TestEvent();
        final listener = TrackingListener();

        listener.setEvent(event);
        await listener.handle({'action': 'test'});

        expect(listener.getEvent(), event);
        expect(listener.lastEventData, {'action': 'test'});
      });
    });
  });
}
