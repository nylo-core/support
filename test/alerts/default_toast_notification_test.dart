import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/alerts/ny_alerts.dart';
import 'package:nylo_support/localization/ny_localization.dart';
import 'package:nylo_support/testing/ny_testing.dart';

/// Tests for DefaultToastNotification widget.
///
/// Its built-in text uses `nylo.*` translation keys, which fall back to English
/// when no language files are loaded, so the widget renders in plain tests.
void main() {
  NyTest.init();

  nyGroup('DefaultToastNotification', () {
    nyGroup('instantiation', () {
      nyTest('can be instantiated with ToastMeta', () async {
        final meta = ToastMeta(
          title: 'Test Title',
          description: 'Test Description',
        );

        // Widget can be created without throwing
        final widget = DefaultToastNotification(meta);

        expect(widget, isA<DefaultToastNotification>());
        expect(widget, isA<StatelessWidget>());
      });

      nyTest('can be instantiated with minimal ToastMeta', () async {
        final meta = ToastMeta();

        final widget = DefaultToastNotification(meta);

        expect(widget, isA<DefaultToastNotification>());
      });

      nyTest('can be instantiated with custom icon', () async {
        final meta = ToastMeta(
          icon: const Icon(Icons.warning, color: Colors.amber),
        );

        final widget = DefaultToastNotification(meta);

        expect(widget, isA<DefaultToastNotification>());
      });

      nyTest('can be instantiated with all ToastMeta properties', () async {
        var actionCalled = false;
        var dismissCalled = false;

        final meta = ToastMeta(
          icon: const Icon(Icons.info),
          title: 'Information',
          description: 'This is an information toast',
          color: Colors.blue,
          action: () => actionCalled = true,
          dismiss: () => dismissCalled = true,
          duration: const Duration(seconds: 3),
          position: ToastNotificationPosition.bottom,
        );

        final widget = DefaultToastNotification(meta);

        expect(widget, isA<DefaultToastNotification>());

        // Verify callbacks are properly set in meta
        meta.action!();
        expect(actionCalled, isTrue);

        meta.dismiss!();
        expect(dismissCalled, isTrue);
      });
    });

    nyGroup('widget key', () {
      nyTest('accepts Key parameter', () async {
        final meta = ToastMeta();
        const testKey = Key('test_toast');

        final widget = DefaultToastNotification(meta, key: testKey);

        expect(widget.key, testKey);
      });
    });

    nyGroup('ToastMeta integration', () {
      nyTest('different meta creates different widgets', () async {
        final meta1 = ToastMeta(title: 'Toast 1');
        final meta2 = ToastMeta(title: 'Toast 2');

        final widget1 = DefaultToastNotification(meta1);
        final widget2 = DefaultToastNotification(meta2);

        // Both should be valid widgets
        expect(widget1, isA<DefaultToastNotification>());
        expect(widget2, isA<DefaultToastNotification>());

        // They should be different instances
        expect(identical(widget1, widget2), isFalse);
      });

      nyTest('meta callbacks remain functional', () async {
        var onShowCalled = false;
        var onDismissCalled = false;

        final meta = ToastMeta(
          onShow: () => onShowCalled = true,
          onDismiss: () => onDismissCalled = true,
        );

        // Widget creation should not trigger callbacks
        DefaultToastNotification(meta);

        expect(onShowCalled, isFalse);
        expect(onDismissCalled, isFalse);

        // Callbacks should be callable
        meta.onShow!();
        expect(onShowCalled, isTrue);

        meta.onDismiss!();
        expect(onDismissCalled, isTrue);
      });
    });

    nyGroup('position support', () {
      nyTest('supports all ToastNotificationPosition values', () async {
        for (final position in ToastNotificationPosition.values) {
          final meta = ToastMeta(position: position);
          final widget = DefaultToastNotification(meta);

          expect(widget, isA<DefaultToastNotification>());
        }
      });
    });

    nyGroup('color support', () {
      nyTest('accepts various color values', () async {
        final colors = [
          Colors.red,
          Colors.green,
          Colors.blue,
          Colors.amber,
          Colors.purple,
          Colors.orange.shade100,
          Colors.grey.shade50,
        ];

        for (final color in colors) {
          final meta = ToastMeta(color: color);
          final widget = DefaultToastNotification(meta);

          expect(widget, isA<DefaultToastNotification>());
        }
      });

      nyTest('accepts null color', () async {
        final meta = ToastMeta(color: null);
        final widget = DefaultToastNotification(meta);

        expect(widget, isA<DefaultToastNotification>());
      });
    });

    nyGroup('icon support', () {
      nyTest('accepts various icon widgets', () async {
        final icons = [
          const Icon(Icons.check),
          const Icon(Icons.warning, color: Colors.orange),
          const Icon(Icons.error, color: Colors.red, size: 24),
          const Icon(Icons.info_outline),
        ];

        for (final icon in icons) {
          final meta = ToastMeta(icon: icon);
          final widget = DefaultToastNotification(meta);

          expect(widget, isA<DefaultToastNotification>());
        }
      });

      nyTest('accepts null icon (uses default)', () async {
        final meta = ToastMeta(icon: null);
        final widget = DefaultToastNotification(meta);

        expect(widget, isA<DefaultToastNotification>());
      });
    });

    nyGroup('duration support', () {
      nyTest('accepts various duration values', () async {
        final durations = [
          const Duration(seconds: 1),
          const Duration(seconds: 5),
          const Duration(seconds: 10),
          const Duration(milliseconds: 2500),
        ];

        for (final duration in durations) {
          final meta = ToastMeta(duration: duration);
          final widget = DefaultToastNotification(meta);

          expect(widget, isA<DefaultToastNotification>());
          expect(meta.duration, duration);
        }
      });
    });

    nyGroup('metaData support', () {
      nyTest('passes through metaData from ToastMeta', () async {
        final testData = {
          'key1': 'value1',
          'key2': 123,
          'nested': {'a': 'b'},
        };

        final meta = ToastMeta(metaData: testData);
        final widget = DefaultToastNotification(meta);

        expect(widget, isA<DefaultToastNotification>());
        expect(meta.metaData, testData);
        expect(meta.metaData!['key1'], 'value1');
        expect(meta.metaData!['key2'], 123);
      });
    });

    nyGroup('built-in text', () {
      Widget toast(ToastMeta meta) =>
          MaterialApp(home: Scaffold(body: DefaultToastNotification(meta)));

      nyWidgetTest('titles an untitled toast "Success"', (tester) async {
        final semantics = tester.ensureSemantics();
        await tester.pumpWidget(toast(ToastMeta(description: 'Saved')));

        expect(find.text('Success'), findsOneWidget);
        expect(find.byTooltip('Dismiss notification'), findsOneWidget);
        expect(
          find.bySemanticsLabel(RegExp(r'^Success: Saved')),
          findsOneWidget,
        );
        semantics.dispose();
      });

      nyWidgetTest('follows the active language', (tester) async {
        NyLocalization.instance.setValuesForTesting(
          values: {
            'nylo': {
              'toast': {'success': 'Éxito', 'dismiss': 'Cerrar notificación'},
            },
          },
        );
        addTearDown(
          () => NyLocalization.instance.setValuesForTesting(values: {}),
        );
        final semantics = tester.ensureSemantics();
        await tester.pumpWidget(toast(ToastMeta(description: 'Guardado')));

        expect(find.text('Éxito'), findsOneWidget);
        expect(find.byTooltip('Cerrar notificación'), findsOneWidget);
        expect(
          find.bySemanticsLabel(RegExp(r'^Éxito: Guardado')),
          findsOneWidget,
        );
        semantics.dispose();
      });
    });
  });
}
