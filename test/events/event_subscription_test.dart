import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/events/ny_events.dart';

class TestEvent extends NyEvent {}

class AnotherTestEvent extends NyEvent {}

void main() {
  setUp(() {
    // Reset the event bus before each test
    NyEventBus().clear();
  });

  tearDown(() {
    NyEventBus().clear();
  });

  group('NyEventSubscription', () {
    test('isActive returns true initially', () {
      final listener = TestListener();
      final subscription = NyEventSubscription<TestEvent>(listener);

      expect(subscription.isActive, isTrue);
    });

    test('cancel sets isActive to false', () {
      final listener = TestListener();
      NyEventBus().on<TestEvent>(listener);
      final subscription = NyEventSubscription<TestEvent>(listener);

      subscription.cancel();

      expect(subscription.isActive, isFalse);
    });

    test('cancel removes listener from event bus', () async {
      var callCount = 0;
      final listener = TestListener(
        onHandle: () {
          callCount++;
        },
      );

      NyEventBus().on<TestEvent>(listener);
      final subscription = NyEventSubscription<TestEvent>(listener);

      await NyEventBus().broadcast(TestEvent(), null);
      expect(callCount, equals(1));

      subscription.cancel();

      await NyEventBus().broadcast(TestEvent(), null);
      expect(callCount, equals(1)); // Should not have incremented
    });

    test('cancel can be called multiple times safely', () {
      final listener = TestListener();
      NyEventBus().on<TestEvent>(listener);
      final subscription = NyEventSubscription<TestEvent>(listener);

      expect(() {
        subscription.cancel();
        subscription.cancel();
        subscription.cancel();
      }, returnsNormally);

      expect(subscription.isActive, isFalse);
    });
  });

  group('NyEventCallbackListener', () {
    test('calls callback with params', () async {
      Map? receivedData;
      final listener = NyEventCallbackListener((data) {
        receivedData = data;
        return true;
      });

      await listener.handle({'key': 'value'});

      expect(receivedData, equals({'key': 'value'}));
    });

    test('callback can receive null params', () async {
      Map? receivedData;
      var wasCalled = false;
      final listener = NyEventCallbackListener((data) {
        wasCalled = true;
        receivedData = data;
        return true;
      });

      await listener.handle(null);

      expect(wasCalled, isTrue);
      expect(receivedData, isNull);
    });

    test('shouldCancel is false initially', () {
      final listener = NyEventCallbackListener((data) => true);

      expect(listener.shouldCancel, isFalse);
    });

    test('shouldCancel becomes true when callback returns false', () async {
      final listener = NyEventCallbackListener((data) => false);

      await listener.handle(null);

      expect(listener.shouldCancel, isTrue);
    });

    test('shouldCancel stays false when callback returns true', () async {
      final listener = NyEventCallbackListener((data) => true);

      await listener.handle(null);

      expect(listener.shouldCancel, isFalse);
    });
  });

  group('listenOn()', () {
    test('returns NyEventSubscription', () {
      final subscription = listenOn<TestEvent>((data) => true);

      expect(subscription, isA<NyEventSubscription<TestEvent>>());
      expect(subscription.isActive, isTrue);

      subscription.cancel();
    });

    test('callback is called when event is broadcast', () async {
      var callCount = 0;
      Map? receivedData;

      final subscription = listenOn<TestEvent>((data) {
        callCount++;
        receivedData = data;
        return true;
      });

      await NyEventBus().broadcast(TestEvent(), {'key': 'value'});

      expect(callCount, equals(1));
      expect(receivedData, equals({'key': 'value'}));

      subscription.cancel();
    });

    test('only listens to matching event type', () async {
      var testEventCount = 0;
      var anotherEventCount = 0;

      final subscription1 = listenOn<TestEvent>((data) {
        testEventCount++;
        return true;
      });

      final subscription2 = listenOn<AnotherTestEvent>((data) {
        anotherEventCount++;
        return true;
      });

      await NyEventBus().broadcast(TestEvent(), null);

      expect(testEventCount, equals(1));
      expect(anotherEventCount, equals(0));

      subscription1.cancel();
      subscription2.cancel();
    });
  });
}

class TestListener extends NyListener {
  final Function()? onHandle;

  TestListener({this.onHandle});

  @override
  Future handle(Map? params) async {
    onHandle?.call();
    return null;
  }
}
