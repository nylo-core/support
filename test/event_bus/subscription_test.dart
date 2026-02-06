import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/event_bus/src/subscription.dart';

void main() {
  group('Subscription', () {
    test('creates from stream', () {
      final controller = StreamController.broadcast();
      final subscription = Subscription(controller.stream);

      expect(subscription, isNotNull);
      expect(subscription.subscriptions, isEmpty);

      controller.close();
    });

    test('respond adds subscription to list', () {
      final controller = StreamController.broadcast();
      final subscription = Subscription(controller.stream);

      subscription.respond<String>((event) {});

      expect(subscription.subscriptions.length, equals(1));

      subscription.dispose();
      controller.close();
    });

    test('respond can be chained', () {
      final controller = StreamController.broadcast();
      final subscription = Subscription(controller.stream);

      subscription.respond<String>((event) {}).respond<int>((event) {});

      expect(subscription.subscriptions.length, equals(2));

      subscription.dispose();
      controller.close();
    });

    test('respond receives events of matching type', () async {
      final controller = StreamController.broadcast();
      final subscription = Subscription(controller.stream);
      final receivedEvents = <String>[];

      subscription.respond<String>((event) {
        receivedEvents.add(event);
      });

      controller.add('hello');
      controller.add('world');
      controller.add(123); // Should be filtered out

      // Allow stream to process events
      await Future.delayed(const Duration(milliseconds: 10));

      expect(receivedEvents, equals(['hello', 'world']));

      subscription.dispose();
      controller.close();
    });

    test('respond with dynamic receives all events', () async {
      final controller = StreamController.broadcast();
      final subscription = Subscription(controller.stream);
      final receivedEvents = <dynamic>[];

      subscription.respond((event) {
        receivedEvents.add(event);
      });

      controller.add('hello');
      controller.add(123);
      controller.add(true);

      // Allow stream to process events
      await Future.delayed(const Duration(milliseconds: 10));

      expect(receivedEvents, equals(['hello', 123, true]));

      subscription.dispose();
      controller.close();
    });

    test('dispose cancels all subscriptions', () async {
      final controller = StreamController.broadcast();
      final subscription = Subscription(controller.stream);
      final receivedEvents = <String>[];

      subscription.respond<String>((event) {
        receivedEvents.add(event);
      });

      controller.add('before');
      await Future.delayed(const Duration(milliseconds: 10));

      subscription.dispose();

      controller.add('after');
      await Future.delayed(const Duration(milliseconds: 10));

      expect(receivedEvents, equals(['before']));
      expect(subscription.subscriptions, isEmpty);

      controller.close();
    });

    test('dispose can be called multiple times safely', () {
      final controller = StreamController.broadcast();
      final subscription = Subscription(controller.stream);

      subscription.respond<String>((event) {});

      expect(() {
        subscription.dispose();
        subscription.dispose();
        subscription.dispose();
      }, returnsNormally);

      controller.close();
    });

    test('dispose on empty subscription does nothing', () {
      final controller = StreamController.broadcast();
      final subscription = Subscription(controller.stream);

      expect(() => subscription.dispose(), returnsNormally);

      controller.close();
    });
  });

  group('Subscription.empty()', () {
    test('creates empty subscription', () {
      final subscription = Subscription.empty();

      expect(subscription, isNotNull);
    });

    test('subscriptions returns empty unmodifiable list', () {
      final subscription = Subscription.empty();

      expect(subscription.subscriptions, isEmpty);
    });

    test('dispose does nothing', () {
      final subscription = Subscription.empty();

      expect(() => subscription.dispose(), returnsNormally);
    });

    test('respond throws exception', () {
      final subscription = Subscription.empty();

      expect(() => subscription.respond<String>((event) {}), throwsException);
    });
  });
}
