import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/event_bus/src/history_entry.dart';
import 'package:nylo_support/event_bus/src/app_event.dart';

class TestEvent extends AppEvent {
  final String message;

  const TestEvent(this.message);

  @override
  List<Object?> get props => [message];
}

void main() {
  group('EventBusHistoryEntry', () {
    test('creates with event and timestamp', () {
      final event = const TestEvent('test');
      final timestamp = DateTime(2025, 1, 15, 10, 30, 0);

      final entry = EventBusHistoryEntry(event, timestamp);

      expect(entry.event, equals(event));
      expect(entry.timestamp, equals(timestamp));
    });

    test('implements Equatable correctly', () {
      final event = const TestEvent('test');
      final timestamp = DateTime(2025, 1, 15, 10, 30, 0);

      final entry1 = EventBusHistoryEntry(event, timestamp);
      final entry2 = EventBusHistoryEntry(event, timestamp);

      expect(entry1, equals(entry2));
    });

    test('different events are not equal', () {
      final event1 = const TestEvent('test1');
      final event2 = const TestEvent('test2');
      final timestamp = DateTime(2025, 1, 15, 10, 30, 0);

      final entry1 = EventBusHistoryEntry(event1, timestamp);
      final entry2 = EventBusHistoryEntry(event2, timestamp);

      expect(entry1, isNot(equals(entry2)));
    });

    test('different timestamps are not equal', () {
      final event = const TestEvent('test');
      final timestamp1 = DateTime(2025, 1, 15, 10, 30, 0);
      final timestamp2 = DateTime(2025, 1, 15, 11, 30, 0);

      final entry1 = EventBusHistoryEntry(event, timestamp1);
      final entry2 = EventBusHistoryEntry(event, timestamp2);

      expect(entry1, isNot(equals(entry2)));
    });

    test('props contains event and timestamp', () {
      final event = const TestEvent('test');
      final timestamp = DateTime(2025, 1, 15, 10, 30, 0);

      final entry = EventBusHistoryEntry(event, timestamp);

      expect(entry.props, containsAll([event, timestamp]));
    });
  });
}
