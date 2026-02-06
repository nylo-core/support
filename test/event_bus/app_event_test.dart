import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/event_bus/src/app_event.dart';

class TestEvent extends AppEvent {
  final String message;

  const TestEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class AnotherTestEvent extends AppEvent {
  final int value;

  const AnotherTestEvent(this.value);

  @override
  List<Object?> get props => [value];
}

void main() {
  group('AppEvent', () {
    test('can create subclass', () {
      const event = TestEvent('hello');

      expect(event, isA<AppEvent>());
      expect(event.message, equals('hello'));
    });

    test('timestamp returns current time', () {
      const event = TestEvent('test');
      final before = DateTime.now();
      final timestamp = event.timestamp;
      final after = DateTime.now();

      expect(
        timestamp.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(timestamp.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });

    test('implements Equatable', () {
      const event1 = TestEvent('hello');
      const event2 = TestEvent('hello');
      const event3 = TestEvent('world');

      expect(event1, equals(event2));
      expect(event1, isNot(equals(event3)));
    });

    test('different event types are not equal', () {
      const stringEvent = TestEvent('1');
      const intEvent = AnotherTestEvent(1);

      expect(stringEvent, isNot(equals(intEvent)));
    });
  });

  group('EventCompletionEvent', () {
    test('wraps another event', () {
      const originalEvent = TestEvent('original');
      const completionEvent = EventCompletionEvent(originalEvent);

      expect(completionEvent.event, equals(originalEvent));
    });

    test('implements Equatable', () {
      const event = TestEvent('test');
      const completion1 = EventCompletionEvent(event);
      const completion2 = EventCompletionEvent(event);

      expect(completion1, equals(completion2));
    });

    test('different wrapped events are not equal', () {
      const event1 = TestEvent('test1');
      const event2 = TestEvent('test2');
      const completion1 = EventCompletionEvent(event1);
      const completion2 = EventCompletionEvent(event2);

      expect(completion1, isNot(equals(completion2)));
    });

    test('props contains the wrapped event', () {
      const event = TestEvent('test');
      const completion = EventCompletionEvent(event);

      expect(completion.props, contains(event));
    });
  });

  group('EmptyEvent', () {
    test('can be created', () {
      final event = EmptyEvent();

      expect(event, isA<AppEvent>());
    });

    test('props is empty', () {
      final event = EmptyEvent();

      expect(event.props, isEmpty);
    });

    test('two empty events are equal', () {
      final event1 = EmptyEvent();
      final event2 = EmptyEvent();

      expect(event1, equals(event2));
    });
  });
}
