import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/event_bus/ny_event_bus.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  test('NyTest.init gives forms an event bus to submit through', () {
    expect(Backpack.instance.read('event_bus'), isA<EventBus>());
  });

  test('the event bus outlives the reset between tests', () {
    expect(Backpack.instance.read('event_bus'), isA<EventBus>());
  });
}
