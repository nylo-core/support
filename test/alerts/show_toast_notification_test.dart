import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/alerts/ny_alerts.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('showToastNotification', () {
    nySetUp(() {
      ToastNotificationRegistry.instance.clear();
    });

    nyTearDown(() {
      ToastNotificationRegistry.instance.clear();
    });

    nyGroup('ToastMeta creation', () {
      nyTest(
        'creates ToastMeta with default values when no parameters provided',
        () async {
          // Verify default ToastMeta behavior that showToastNotification uses
          final meta = ToastMeta(
            title: '',
            description: '',
            duration: const Duration(seconds: 5),
            position: ToastNotificationPosition.top,
          );

          expect(meta.title, '');
          expect(meta.description, '');
          expect(meta.duration, const Duration(seconds: 5));
          expect(meta.position, ToastNotificationPosition.top);
          expect(meta.action, isNull);
          expect(meta.onDismiss, isNull);
          expect(meta.onShow, isNull);
        },
      );

      nyTest('creates ToastMeta with custom title and description', () async {
        final meta = ToastMeta(
          title: 'Custom Title',
          description: 'Custom Description',
        );

        expect(meta.title, 'Custom Title');
        expect(meta.description, 'Custom Description');
      });

      nyTest('creates ToastMeta with custom duration', () async {
        final meta = ToastMeta(duration: const Duration(seconds: 10));

        expect(meta.duration, const Duration(seconds: 10));
      });

      nyTest('creates ToastMeta with custom position', () async {
        final meta = ToastMeta(position: ToastNotificationPosition.bottom);

        expect(meta.position, ToastNotificationPosition.bottom);
      });

      nyTest('creates ToastMeta with action callback', () async {
        var actionCalled = false;

        final meta = ToastMeta(action: () => actionCalled = true);

        expect(meta.action, isNotNull);
        meta.action!();
        expect(actionCalled, isTrue);
      });

      nyTest('creates ToastMeta with onDismiss callback', () async {
        var onDismissCalled = false;

        final meta = ToastMeta(onDismiss: () => onDismissCalled = true);

        expect(meta.onDismiss, isNotNull);
        meta.onDismiss!();
        expect(onDismissCalled, isTrue);
      });

      nyTest('creates ToastMeta with onShow callback', () async {
        var onShowCalled = false;

        final meta = ToastMeta(onShow: () => onShowCalled = true);

        expect(meta.onShow, isNotNull);
        meta.onShow!();
        expect(onShowCalled, isTrue);
      });
    });

    nyGroup('registry integration', () {
      nyTest('uses registry to look up styles by id', () async {
        final registry = ToastNotificationRegistry.instance;
        var factoryCalled = false;

        Widget successFactory(ToastMeta meta, void Function(ToastMeta) update) {
          factoryCalled = true;
          return const SizedBox();
        }

        registry.register('success', successFactory);

        // Verify factory is registered
        expect(registry.has('success'), isTrue);

        // Simulate what showToastNotification does
        final factory = registry.get('success');
        expect(factory, isNotNull);

        final testMeta = ToastMeta(title: 'Test');
        factory!(testMeta, (updated) {});

        expect(factoryCalled, isTrue);
      });

      nyTest('factory can update ToastMeta via callback', () async {
        final registry = ToastNotificationRegistry.instance;
        ToastMeta? updatedMeta;

        Widget factory(ToastMeta meta, void Function(ToastMeta) update) {
          // Factory updates meta with new position
          update(meta.copyWith(position: ToastNotificationPosition.bottom));
          return const SizedBox();
        }

        registry.register('custom', factory);

        final retrievedFactory = registry.get('custom');
        final originalMeta = ToastMeta(
          title: 'Original',
          position: ToastNotificationPosition.top,
        );

        retrievedFactory!(originalMeta, (updated) {
          updatedMeta = updated;
        });

        expect(updatedMeta, isNotNull);
        expect(updatedMeta!.position, ToastNotificationPosition.bottom);
        // Original meta position unchanged
        expect(originalMeta.position, ToastNotificationPosition.top);
      });

      nyTest(
        'falls back to DefaultToastNotification when no styles registered',
        () async {
          final registry = ToastNotificationRegistry.instance;

          // Registry is empty
          expect(registry.styleIds, isEmpty);

          // get returns null when no success fallback
          final factory = registry.get('nonexistent');
          expect(factory, isNull);
        },
      );

      nyTest('falls back to success style for unknown id', () async {
        final registry = ToastNotificationRegistry.instance;

        Widget successFactory(ToastMeta meta, void Function(ToastMeta) update) {
          return const Text('Success');
        }

        registry.register('success', successFactory);

        // Unknown id should fall back to success
        final factory = registry.get('unknown_style');
        expect(factory, successFactory);
      });
    });

    nyGroup('standard toast IDs', () {
      nyTest('supports success style', () async {
        final registry = ToastNotificationRegistry.instance;

        Widget successFactory(ToastMeta meta, void Function(ToastMeta) update) {
          return const Icon(Icons.check, color: Colors.green);
        }

        registry.register('success', successFactory);

        expect(registry.has('success'), isTrue);
        expect(registry.get('success'), isNotNull);
      });

      nyTest('supports warning style', () async {
        final registry = ToastNotificationRegistry.instance;

        Widget warningFactory(ToastMeta meta, void Function(ToastMeta) update) {
          return const Icon(Icons.warning, color: Colors.orange);
        }

        registry.register('warning', warningFactory);

        expect(registry.has('warning'), isTrue);
        expect(registry.get('warning'), isNotNull);
      });

      nyTest('supports info style', () async {
        final registry = ToastNotificationRegistry.instance;

        Widget infoFactory(ToastMeta meta, void Function(ToastMeta) update) {
          return const Icon(Icons.info, color: Colors.blue);
        }

        registry.register('info', infoFactory);

        expect(registry.has('info'), isTrue);
        expect(registry.get('info'), isNotNull);
      });

      nyTest('supports danger style', () async {
        final registry = ToastNotificationRegistry.instance;

        Widget dangerFactory(ToastMeta meta, void Function(ToastMeta) update) {
          return const Icon(Icons.error, color: Colors.red);
        }

        registry.register('danger', dangerFactory);

        expect(registry.has('danger'), isTrue);
        expect(registry.get('danger'), isNotNull);
      });

      nyTest('supports custom style IDs', () async {
        final registry = ToastNotificationRegistry.instance;

        Widget customFactory(ToastMeta meta, void Function(ToastMeta) update) {
          return const Text('Custom Style');
        }

        registry.register('my_custom_toast', customFactory);

        expect(registry.has('my_custom_toast'), isTrue);
        expect(registry.get('my_custom_toast'), isNotNull);
      });
    });

    nyGroup('position mapping', () {
      nyTest('top position is correctly represented', () async {
        const position = ToastNotificationPosition.top;
        expect(position, ToastNotificationPosition.top);
        expect(position.name, 'top');
        expect(position.index, 0);
      });

      nyTest('bottom position is correctly represented', () async {
        const position = ToastNotificationPosition.bottom;
        expect(position, ToastNotificationPosition.bottom);
        expect(position.name, 'bottom');
        expect(position.index, 1);
      });

      nyTest('center position is correctly represented', () async {
        const position = ToastNotificationPosition.center;
        expect(position, ToastNotificationPosition.center);
        expect(position.name, 'center');
        expect(position.index, 2);
      });
    });

    nyGroup('callback behavior', () {
      nyTest('onShow callback can be chained with action', () async {
        var onShowCalled = false;
        var actionCalled = false;
        final callOrder = <String>[];

        final meta = ToastMeta(
          onShow: () {
            onShowCalled = true;
            callOrder.add('onShow');
          },
          action: () {
            actionCalled = true;
            callOrder.add('action');
          },
        );

        // Simulate show notification behavior
        meta.onShow!();
        meta.action!();

        expect(onShowCalled, isTrue);
        expect(actionCalled, isTrue);
        expect(callOrder, ['onShow', 'action']);
      });

      nyTest('onDismiss callback can be chained with dismiss', () async {
        var dismissCalled = false;
        var onDismissCalled = false;
        final callOrder = <String>[];

        final meta = ToastMeta(
          dismiss: () {
            dismissCalled = true;
            callOrder.add('dismiss');
          },
          onDismiss: () {
            onDismissCalled = true;
            callOrder.add('onDismiss');
          },
        );

        // Simulate dismiss behavior
        meta.dismiss!();
        meta.onDismiss!();

        expect(dismissCalled, isTrue);
        expect(onDismissCalled, isTrue);
        expect(callOrder, ['dismiss', 'onDismiss']);
      });

      nyTest('all callbacks can work together', () async {
        var actionCalled = false;
        var dismissCalled = false;
        var onDismissCalled = false;
        var onShowCalled = false;

        final meta = ToastMeta(
          action: () => actionCalled = true,
          dismiss: () => dismissCalled = true,
          onDismiss: () => onDismissCalled = true,
          onShow: () => onShowCalled = true,
        );

        // All callbacks should be set
        expect(meta.action, isNotNull);
        expect(meta.dismiss, isNotNull);
        expect(meta.onDismiss, isNotNull);
        expect(meta.onShow, isNotNull);

        // All callbacks should work independently
        meta.action!();
        meta.dismiss!();
        meta.onDismiss!();
        meta.onShow!();

        expect(actionCalled, isTrue);
        expect(dismissCalled, isTrue);
        expect(onDismissCalled, isTrue);
        expect(onShowCalled, isTrue);
      });
    });

    nyGroup('edge cases', () {
      nyTest('handles empty title and description', () async {
        final meta = ToastMeta(title: '', description: '');

        expect(meta.title, '');
        expect(meta.description, '');
      });

      nyTest('handles very long title', () async {
        final longTitle = 'A' * 1000;
        final meta = ToastMeta(title: longTitle);

        expect(meta.title, longTitle);
        expect(meta.title.length, 1000);
      });

      nyTest('handles very long description', () async {
        final longDescription = 'B' * 5000;
        final meta = ToastMeta(description: longDescription);

        expect(meta.description, longDescription);
        expect(meta.description.length, 5000);
      });

      nyTest('handles special characters in title', () async {
        const specialTitle =
            '<script>alert("xss")</script> & "quotes" \'apostrophes\'';
        final meta = ToastMeta(title: specialTitle);

        expect(meta.title, specialTitle);
      });

      nyTest('handles unicode characters in title', () async {
        const unicodeTitle = 'Hello World! Emoji test';
        final meta = ToastMeta(title: unicodeTitle);

        expect(meta.title, unicodeTitle);
      });

      nyTest('handles newlines in description', () async {
        const multilineDescription = 'Line 1\nLine 2\nLine 3';
        final meta = ToastMeta(description: multilineDescription);

        expect(meta.description, multilineDescription);
        expect(meta.description.contains('\n'), isTrue);
      });

      nyTest('handles zero duration', () async {
        final meta = ToastMeta(duration: Duration.zero);

        expect(meta.duration, Duration.zero);
        expect(meta.duration.inMilliseconds, 0);
      });

      nyTest('handles very short duration', () async {
        final meta = ToastMeta(duration: const Duration(milliseconds: 1));

        expect(meta.duration, const Duration(milliseconds: 1));
      });

      nyTest('handles very long duration', () async {
        final meta = ToastMeta(duration: const Duration(hours: 24));

        expect(meta.duration, const Duration(hours: 24));
      });
    });

    nyGroup('data factory support', () {
      nyTest('registerWithData stores a ToastStyleDataFactory', () async {
        final registry = ToastNotificationRegistry.instance;

        registry.registerWithData('custom_data', (Map<String, dynamic> data) {
          return (ToastMeta meta, void Function(ToastMeta) update) {
            return Text(data['message'] ?? 'default');
          };
        });

        expect(registry.has('custom_data'), isTrue);
      });

      nyTest('resolve calls data factory with provided data', () async {
        final registry = ToastNotificationRegistry.instance;
        Map<String, dynamic>? receivedData;

        registry.registerWithData('data_toast', (Map<String, dynamic> data) {
          receivedData = data;
          return (ToastMeta meta, void Function(ToastMeta) update) {
            return const SizedBox();
          };
        });

        final factory = registry.resolve('data_toast', {'name': 'Alice'});
        expect(factory, isNotNull);
        expect(receivedData, {'name': 'Alice'});
      });

      nyTest(
        'resolve works with old-style ToastStyleFactory (backward compat)',
        () async {
          final registry = ToastNotificationRegistry.instance;
          var factoryCalled = false;

          registry.register('old_style', (
            ToastMeta meta,
            void Function(ToastMeta) update,
          ) {
            factoryCalled = true;
            return const SizedBox();
          });

          final factory = registry.resolve('old_style', {'ignored': true});
          expect(factory, isNotNull);

          factory!(ToastMeta(title: 'Test'), (updated) {});
          expect(factoryCalled, isTrue);
        },
      );

      nyTest(
        'registerAll accepts mix of old and new style factories',
        () async {
          final registry = ToastNotificationRegistry.instance;

          ToastStyleFactory oldFactory =
              (ToastMeta meta, void Function(ToastMeta) update) {
                return const Text('old');
              };

          ToastStyleDataFactory newFactory = (Map<String, dynamic> data) {
            return (ToastMeta meta, void Function(ToastMeta) update) {
              return Text(data['label'] ?? 'new');
            };
          };

          registry.registerAll({'old': oldFactory, 'new': newFactory});

          expect(registry.has('old'), isTrue);
          expect(registry.has('new'), isTrue);

          // Both should resolve
          final resolvedOld = registry.resolve('old', {});
          final resolvedNew = registry.resolve('new', {'label': 'hello'});
          expect(resolvedOld, isNotNull);
          expect(resolvedNew, isNotNull);
        },
      );

      nyTest('resolve returns null when no styles registered', () async {
        final registry = ToastNotificationRegistry.instance;
        final factory = registry.resolve('nonexistent', {});
        expect(factory, isNull);
      });

      nyTest('resolve falls back to success style for unknown id', () async {
        final registry = ToastNotificationRegistry.instance;

        registry.register('success', (
          ToastMeta meta,
          void Function(ToastMeta) update,
        ) {
          return const Text('Success');
        });

        final factory = registry.resolve('unknown', {});
        expect(factory, isNotNull);
      });

      nyTest(
        'data map with title and description keys is passed through',
        () async {
          final registry = ToastNotificationRegistry.instance;
          Map<String, dynamic>? receivedData;

          registry.registerWithData('follower', (Map<String, dynamic> data) {
            receivedData = data;
            return (ToastMeta meta, void Function(ToastMeta) update) {
              return const SizedBox();
            };
          });

          registry.resolve('follower', {
            'title': 'New Follower',
            'description': 'Kanye followed you',
            'avatar': 'https://example.com/avatar.png',
          });

          expect(receivedData!['title'], 'New Follower');
          expect(receivedData!['description'], 'Kanye followed you');
          expect(receivedData!['avatar'], 'https://example.com/avatar.png');
        },
      );
    });
  });
}
