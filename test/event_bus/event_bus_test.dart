import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/event_bus/ny_event_bus.dart';
import 'package:nylo_support/testing/ny_testing.dart';

/// Test event for testing
class TestEvent extends AppEvent {
  final String message;

  const TestEvent(this.message);

  @override
  List<Object> get props => [message];
}

/// Another test event
class AnotherEvent extends AppEvent {
  final int value;

  const AnotherEvent(this.value);

  @override
  List<Object> get props => [value];
}

void main() {
  NyTest.init();

  late EventBus eventBus;

  setUp(() {
    eventBus = EventBus();
  });

  tearDown(() {
    eventBus.dispose();
  });

  nyGroup('EventBus', () {
    nyGroup('constructor', () {
      nyTest('should create with default values', () async {
        final bus = EventBus();
        expect(bus.maxHistoryLength, 100);
        expect(bus.allowLogging, isFalse);
        expect(bus.isBusy, isFalse);
        expect(bus.history, isEmpty);
        bus.dispose();
      });

      nyTest('should create with custom max history length', () async {
        final bus = EventBus(maxHistoryLength: 50);
        expect(bus.maxHistoryLength, 50);
        bus.dispose();
      });

      nyTest('should create with logging enabled', () async {
        final bus = EventBus(allowLogging: true);
        expect(bus.allowLogging, isTrue);
        bus.dispose();
      });
    });

    nyGroup('fire', () {
      nyTest('should fire an event', () async {
        final completer = Completer<TestEvent>();
        eventBus.on<TestEvent>().listen((event) {
          completer.complete(event);
        });

        eventBus.fire(TestEvent('hello'));

        final event = await completer.future.timeout(Duration(seconds: 1));
        expect(event.message, 'hello');
      });

      nyTest('should add event to history', () async {
        eventBus.fire(TestEvent('test'));

        // History contains TestEvent and EmptyEvent that follows
        expect(eventBus.history.length, greaterThanOrEqualTo(1));
        expect(eventBus.history.first.event, isA<TestEvent>());
      });

      nyTest('should limit history to maxHistoryLength', () async {
        final bus = EventBus(maxHistoryLength: 5);

        for (int i = 0; i < 10; i++) {
          bus.fire(TestEvent('event_$i'));
        }

        expect(bus.history.length, lessThanOrEqualTo(5));
        bus.dispose();
      });
    });

    nyGroup('on', () {
      nyTest('should filter events by type', () async {
        final testEvents = <TestEvent>[];
        final anotherEvents = <AnotherEvent>[];

        eventBus.on<TestEvent>().listen((e) => testEvents.add(e));
        eventBus.on<AnotherEvent>().listen((e) => anotherEvents.add(e));

        eventBus.fire(TestEvent('test'));
        eventBus.fire(AnotherEvent(42));
        eventBus.fire(TestEvent('test2'));

        await Future.delayed(Duration(milliseconds: 50));

        expect(testEvents.length, 2);
        expect(anotherEvents.length, 1);
      });
    });

    nyGroup('watch and complete', () {
      nyTest('should mark event as in progress when watched', () async {
        expect(eventBus.isBusy, isFalse);

        eventBus.watch(TestEvent('watching'));

        expect(eventBus.isBusy, isTrue);
        expect(eventBus.isInProgress<TestEvent>(), isTrue);
      });

      nyTest('should complete event and remove from in progress', () async {
        final event = TestEvent('complete-test');
        eventBus.watch(event);

        expect(eventBus.isInProgress<TestEvent>(), isTrue);

        eventBus.complete(event);

        expect(eventBus.isInProgress<TestEvent>(), isFalse);
        expect(eventBus.isBusy, isFalse);
      });

      nyTest('should fire completion event when completed', () async {
        final completions = <EventCompletionEvent>[];
        eventBus.on<EventCompletionEvent>().listen((e) => completions.add(e));

        final event = TestEvent('to-complete');
        eventBus.watch(event);
        eventBus.complete(event);

        await Future.delayed(Duration(milliseconds: 50));

        expect(completions.length, 1);
        expect(completions.first.event, event);
      });

      nyTest('should fire next event after completion', () async {
        final nextEvents = <AnotherEvent>[];
        eventBus.on<AnotherEvent>().listen((e) => nextEvents.add(e));

        final event = TestEvent('first');
        final nextEvent = AnotherEvent(99);

        eventBus.watch(event);
        eventBus.complete(event, nextEvent: nextEvent);

        await Future.delayed(Duration(milliseconds: 50));

        expect(nextEvents.length, 1);
        expect(nextEvents.first.value, 99);
      });
    });

    nyGroup('isInProgress', () {
      nyTest('should return false when no events are in progress', () async {
        expect(eventBus.isInProgress<TestEvent>(), isFalse);
      });

      nyTest('should return true for correct event type', () async {
        eventBus.watch(TestEvent('in-progress'));

        expect(eventBus.isInProgress<TestEvent>(), isTrue);
        expect(eventBus.isInProgress<AnotherEvent>(), isFalse);
      });
    });

    nyGroup('whileInProgress', () {
      nyTest('should emit true while event is in progress', () async {
        final statuses = <bool>[];
        eventBus.whileInProgress<TestEvent>().listen((s) => statuses.add(s));

        await Future.delayed(Duration(milliseconds: 10));
        eventBus.watch(TestEvent('progress-stream'));
        await Future.delayed(Duration(milliseconds: 10));

        expect(statuses.contains(true), isTrue);
      });
    });

    nyGroup('last', () {
      nyTest('should return null initially', () async {
        // last is null before any events are fired
        expect(eventBus.last, isNull);
      });
    });

    nyGroup('clearHistory', () {
      nyTest('should clear event history', () async {
        eventBus.fire(TestEvent('event1'));
        eventBus.fire(TestEvent('event2'));

        expect(eventBus.history, isNotEmpty);

        eventBus.clearHistory();

        expect(eventBus.history, isEmpty);
      });
    });

    nyGroup('reset', () {
      nyTest('should clear history and in progress events', () async {
        eventBus.fire(TestEvent('event'));
        eventBus.watch(TestEvent('in-progress'));

        expect(eventBus.history, isNotEmpty);
        expect(eventBus.isBusy, isTrue);

        eventBus.reset();

        expect(eventBus.history, isEmpty);
        expect(eventBus.isBusy, isFalse);
      });
    });
  });

  nyGroup('AppEvent', () {
    nyTest('should have timestamp', () async {
      final event = TestEvent('test');
      expect(event.timestamp, isA<DateTime>());
    });
  });

  nyGroup('EmptyEvent', () {
    nyTest('should have empty props', () async {
      final event = EmptyEvent();
      expect(event.props, isEmpty);
    });
  });

  nyGroup('EventCompletionEvent', () {
    nyTest('should contain the completed event', () async {
      final original = TestEvent('original');
      final completion = EventCompletionEvent(original);

      expect(completion.event, same(original));
      expect(completion.props, contains(original));
    });
  });
}
