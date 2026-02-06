import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/alerts/ny_alerts.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('ToastNotificationPosition', () {
    nyGroup('enum values', () {
      nyTest('has top value', () async {
        expect(ToastNotificationPosition.top, isNotNull);
        expect(ToastNotificationPosition.top.name, 'top');
      });

      nyTest('has bottom value', () async {
        expect(ToastNotificationPosition.bottom, isNotNull);
        expect(ToastNotificationPosition.bottom.name, 'bottom');
      });

      nyTest('has center value', () async {
        expect(ToastNotificationPosition.center, isNotNull);
        expect(ToastNotificationPosition.center.name, 'center');
      });

      nyTest('has exactly 3 values', () async {
        expect(ToastNotificationPosition.values.length, 3);
      });

      nyTest('values list contains all positions', () async {
        final values = ToastNotificationPosition.values;

        expect(values, contains(ToastNotificationPosition.top));
        expect(values, contains(ToastNotificationPosition.bottom));
        expect(values, contains(ToastNotificationPosition.center));
      });
    });

    nyGroup('usage with ToastMeta', () {
      nyTest('can be assigned to ToastMeta position', () async {
        final topMeta = ToastMeta(position: ToastNotificationPosition.top);
        final bottomMeta = ToastMeta(
          position: ToastNotificationPosition.bottom,
        );
        final centerMeta = ToastMeta(
          position: ToastNotificationPosition.center,
        );

        expect(topMeta.position, ToastNotificationPosition.top);
        expect(bottomMeta.position, ToastNotificationPosition.bottom);
        expect(centerMeta.position, ToastNotificationPosition.center);
      });

      nyTest('defaults to top in ToastMeta', () async {
        final meta = ToastMeta();
        expect(meta.position, ToastNotificationPosition.top);
      });

      nyTest('can be changed via copyWith', () async {
        final meta = ToastMeta(position: ToastNotificationPosition.top);
        final updated = meta.copyWith(
          position: ToastNotificationPosition.bottom,
        );

        expect(updated.position, ToastNotificationPosition.bottom);
        expect(
          meta.position,
          ToastNotificationPosition.top,
        ); // Original unchanged
      });
    });

    nyGroup('enum comparison', () {
      nyTest('equality works correctly', () async {
        const position1 = ToastNotificationPosition.top;
        const position2 = ToastNotificationPosition.top;
        const position3 = ToastNotificationPosition.bottom;

        expect(position1 == position2, isTrue);
        expect(position1 == position3, isFalse);
      });

      nyTest('can be used in switch statements', () async {
        String positionToString(ToastNotificationPosition position) {
          switch (position) {
            case ToastNotificationPosition.top:
              return 'top';
            case ToastNotificationPosition.bottom:
              return 'bottom';
            case ToastNotificationPosition.center:
              return 'center';
          }
        }

        expect(positionToString(ToastNotificationPosition.top), 'top');
        expect(positionToString(ToastNotificationPosition.bottom), 'bottom');
        expect(positionToString(ToastNotificationPosition.center), 'center');
      });

      nyTest('index values are sequential', () async {
        expect(ToastNotificationPosition.top.index, 0);
        expect(ToastNotificationPosition.bottom.index, 1);
        expect(ToastNotificationPosition.center.index, 2);
      });
    });
  });
}
