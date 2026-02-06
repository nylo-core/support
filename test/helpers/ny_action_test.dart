import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('NyAction', () {
    nyGroup('authorized', () {
      nyTest('should execute perform when authorized', () async {
        bool performed = false;
        await NyAction.authorized(() async {
          performed = true;
        }, when: () async => true);
        expect(performed, isTrue);
      });

      nyTest('should not execute perform when unauthorized', () async {
        bool performed = false;
        await NyAction.authorized(() async {
          performed = true;
        }, when: () async => false);
        expect(performed, isFalse);
      });

      nyTest('should call unauthorized callback when not authorized', () async {
        bool unauthorizedCalled = false;
        await NyAction.authorized(
          () async {},
          when: () async => false,
          unauthorized: () async {
            unauthorizedCalled = true;
          },
        );
        expect(unauthorizedCalled, isTrue);
      });

      nyTest('should not call unauthorized callback when authorized', () async {
        bool unauthorizedCalled = false;
        await NyAction.authorized(
          () async {},
          when: () async => true,
          unauthorized: () async {
            unauthorizedCalled = true;
          },
        );
        expect(unauthorizedCalled, isFalse);
      });

      nyTest('should support synchronous when callback', () async {
        bool performed = false;
        await NyAction.authorized(() {
          performed = true;
        }, when: () => true);
        expect(performed, isTrue);
      });

      nyTest('should support synchronous perform callback', () async {
        bool performed = false;
        await NyAction.authorized(() {
          performed = true;
        }, when: () async => true);
        expect(performed, isTrue);
      });
    });
  });
}
