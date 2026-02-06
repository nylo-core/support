import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/alerts/ny_alerts.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('ToastMeta', () {
    nyGroup('default values', () {
      nyTest('creates with default values', () async {
        final meta = ToastMeta();

        expect(meta.icon, isNull);
        expect(meta.title, '');
        expect(meta.style, '');
        expect(meta.description, '');
        expect(meta.color, isNull);
        expect(meta.action, isNull);
        expect(meta.dismiss, isNull);
        expect(meta.onDismiss, isNull);
        expect(meta.onShow, isNull);
        expect(meta.duration, const Duration(seconds: 5));
        expect(meta.position, ToastNotificationPosition.top);
        expect(meta.metaData, isNull);
      });
    });

    nyGroup('custom values', () {
      nyTest('creates with custom values', () async {
        final testIcon = const Icon(Icons.warning);
        final testColor = Colors.orange;
        var actionCalled = false;
        var dismissCalled = false;
        var onDismissCalled = false;
        var onShowCalled = false;

        final meta = ToastMeta(
          icon: testIcon,
          title: 'Warning',
          style: 'warning',
          description: 'This is a warning message',
          color: testColor,
          action: () => actionCalled = true,
          dismiss: () => dismissCalled = true,
          onDismiss: () => onDismissCalled = true,
          onShow: () => onShowCalled = true,
          duration: const Duration(seconds: 10),
          position: ToastNotificationPosition.bottom,
          metaData: {'key': 'value'},
        );

        expect(meta.icon, testIcon);
        expect(meta.title, 'Warning');
        expect(meta.style, 'warning');
        expect(meta.description, 'This is a warning message');
        expect(meta.color, testColor);
        expect(meta.duration, const Duration(seconds: 10));
        expect(meta.position, ToastNotificationPosition.bottom);
        expect(meta.metaData, {'key': 'value'});

        // Test callbacks are set correctly
        meta.action!();
        expect(actionCalled, isTrue);

        meta.dismiss!();
        expect(dismissCalled, isTrue);

        meta.onDismiss!();
        expect(onDismissCalled, isTrue);

        meta.onShow!();
        expect(onShowCalled, isTrue);
      });
    });

    nyGroup('copyWith', () {
      nyTest('preserves unchanged fields', () async {
        final original = ToastMeta(
          title: 'Original Title',
          description: 'Original Description',
          style: 'success',
          duration: const Duration(seconds: 7),
          position: ToastNotificationPosition.center,
        );

        final copied = original.copyWith();

        expect(copied.title, original.title);
        expect(copied.description, original.description);
        expect(copied.style, original.style);
        expect(copied.duration, original.duration);
        expect(copied.position, original.position);
      });

      nyTest('updates specified fields only', () async {
        final original = ToastMeta(
          title: 'Original Title',
          description: 'Original Description',
          position: ToastNotificationPosition.top,
        );

        final copied = original.copyWith(
          title: 'New Title',
          position: ToastNotificationPosition.bottom,
        );

        // Changed fields
        expect(copied.title, 'New Title');
        expect(copied.position, ToastNotificationPosition.bottom);

        // Unchanged fields
        expect(copied.description, 'Original Description');
        expect(copied.duration, original.duration);
        expect(copied.style, original.style);
      });

      nyTest('can update all fields', () async {
        final original = ToastMeta();
        final newIcon = const Icon(Icons.error);
        var newActionCalled = false;

        final copied = original.copyWith(
          icon: newIcon,
          title: 'Error',
          style: 'danger',
          description: 'An error occurred',
          color: Colors.red,
          action: () => newActionCalled = true,
          duration: const Duration(seconds: 3),
          position: ToastNotificationPosition.center,
          metaData: {'error_code': 500},
        );

        expect(copied.icon, newIcon);
        expect(copied.title, 'Error');
        expect(copied.style, 'danger');
        expect(copied.description, 'An error occurred');
        expect(copied.color, Colors.red);
        expect(copied.duration, const Duration(seconds: 3));
        expect(copied.position, ToastNotificationPosition.center);
        expect(copied.metaData, {'error_code': 500});

        copied.action!();
        expect(newActionCalled, isTrue);
      });

      nyTest('does not mutate original', () async {
        final original = ToastMeta(
          title: 'Original',
          description: 'Original Desc',
        );

        original.copyWith(title: 'Modified', description: 'Modified Desc');

        // Original should remain unchanged
        expect(original.title, 'Original');
        expect(original.description, 'Original Desc');
      });
    });

    nyGroup('property accessibility', () {
      nyTest('all properties are readable', () async {
        final icon = const Icon(Icons.info);
        final color = Colors.blue;
        final metaData = {'custom': 'data'};

        final meta = ToastMeta(
          icon: icon,
          title: 'Info',
          style: 'info',
          description: 'Information message',
          color: color,
          duration: const Duration(seconds: 4),
          position: ToastNotificationPosition.bottom,
          metaData: metaData,
        );

        // Verify all getters work
        expect(meta.icon, isA<Icon>());
        expect(meta.title, isA<String>());
        expect(meta.style, isA<String>());
        expect(meta.description, isA<String>());
        expect(meta.color, isA<Color>());
        expect(meta.duration, isA<Duration>());
        expect(meta.position, isA<ToastNotificationPosition>());
        expect(meta.metaData, isA<Map<String, dynamic>>());
      });
    });
  });
}
