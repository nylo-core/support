import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/alerts/ny_alerts.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('ToastNotificationRegistry', () {
    // Clean up registry before each test to ensure isolation
    nySetUp(() {
      ToastNotificationRegistry.instance.clear();
    });

    nyTearDown(() {
      ToastNotificationRegistry.instance.clear();
    });

    nyGroup('singleton', () {
      nyTest('returns same instance', () async {
        final instance1 = ToastNotificationRegistry.instance;
        final instance2 = ToastNotificationRegistry.instance;

        expect(identical(instance1, instance2), isTrue);
      });
    });

    nyGroup('register', () {
      nyTest('adds a factory', () async {
        final registry = ToastNotificationRegistry.instance;

        Widget factory(ToastMeta meta, void Function(ToastMeta) update) {
          return const SizedBox();
        }

        registry.register('custom', factory);

        expect(registry.has('custom'), isTrue);
      });

      nyTest('overwrites existing factory with same id', () async {
        final registry = ToastNotificationRegistry.instance;

        Widget factory1(ToastMeta meta, void Function(ToastMeta) update) {
          return const SizedBox(width: 100);
        }

        Widget factory2(ToastMeta meta, void Function(ToastMeta) update) {
          return const SizedBox(width: 200);
        }

        registry.register('test', factory1);
        registry.register('test', factory2);

        final retrieved = registry.get('test');
        expect(retrieved, factory2);
      });
    });

    nyGroup('registerAll', () {
      nyTest('adds multiple factories', () async {
        final registry = ToastNotificationRegistry.instance;

        Widget successFactory(ToastMeta meta, void Function(ToastMeta) update) {
          return const SizedBox();
        }

        Widget warningFactory(ToastMeta meta, void Function(ToastMeta) update) {
          return const SizedBox();
        }

        Widget errorFactory(ToastMeta meta, void Function(ToastMeta) update) {
          return const SizedBox();
        }

        registry.registerAll({
          'success': successFactory,
          'warning': warningFactory,
          'error': errorFactory,
        });

        expect(registry.has('success'), isTrue);
        expect(registry.has('warning'), isTrue);
        expect(registry.has('error'), isTrue);
      });

      nyTest('merges with existing factories', () async {
        final registry = ToastNotificationRegistry.instance;

        Widget existing(ToastMeta meta, void Function(ToastMeta) update) {
          return const SizedBox();
        }

        Widget new1(ToastMeta meta, void Function(ToastMeta) update) {
          return const SizedBox();
        }

        Widget new2(ToastMeta meta, void Function(ToastMeta) update) {
          return const SizedBox();
        }

        registry.register('existing', existing);
        registry.registerAll({'new1': new1, 'new2': new2});

        expect(registry.has('existing'), isTrue);
        expect(registry.has('new1'), isTrue);
        expect(registry.has('new2'), isTrue);
      });
    });

    nyGroup('get', () {
      nyTest('returns registered factory', () async {
        final registry = ToastNotificationRegistry.instance;

        Widget factory(ToastMeta meta, void Function(ToastMeta) update) {
          return const Text('Test');
        }

        registry.register('test', factory);

        final retrieved = registry.get('test');
        expect(retrieved, factory);
      });

      nyTest(
        'returns success fallback for unknown id when success is registered',
        () async {
          final registry = ToastNotificationRegistry.instance;

          Widget successFactory(
            ToastMeta meta,
            void Function(ToastMeta) update,
          ) {
            return const Text('Success');
          }

          registry.register('success', successFactory);

          final retrieved = registry.get('unknown');
          expect(retrieved, successFactory);
        },
      );

      nyTest(
        'returns null when id not found and no success fallback',
        () async {
          final registry = ToastNotificationRegistry.instance;
          // Registry is empty after clear()

          final retrieved = registry.get('nonexistent');
          expect(retrieved, isNull);
        },
      );
    });

    nyGroup('has', () {
      nyTest('returns true when id exists', () async {
        final registry = ToastNotificationRegistry.instance;

        Widget factory(ToastMeta meta, void Function(ToastMeta) update) {
          return const SizedBox();
        }

        registry.register('exists', factory);

        expect(registry.has('exists'), isTrue);
      });

      nyTest('returns false when id does not exist', () async {
        final registry = ToastNotificationRegistry.instance;

        expect(registry.has('nonexistent'), isFalse);
      });
    });

    nyGroup('clear', () {
      nyTest('removes all factories', () async {
        final registry = ToastNotificationRegistry.instance;

        Widget factory(ToastMeta meta, void Function(ToastMeta) update) {
          return const SizedBox();
        }

        registry.register('one', factory);
        registry.register('two', factory);
        registry.register('three', factory);

        expect(registry.has('one'), isTrue);
        expect(registry.has('two'), isTrue);
        expect(registry.has('three'), isTrue);

        registry.clear();

        expect(registry.has('one'), isFalse);
        expect(registry.has('two'), isFalse);
        expect(registry.has('three'), isFalse);
      });

      nyTest('styleIds is empty after clear', () async {
        final registry = ToastNotificationRegistry.instance;

        Widget factory(ToastMeta meta, void Function(ToastMeta) update) {
          return const SizedBox();
        }

        registry.register('test', factory);
        registry.clear();

        expect(registry.styleIds, isEmpty);
      });
    });

    nyGroup('styleIds getter', () {
      nyTest('returns all registered style IDs', () async {
        final registry = ToastNotificationRegistry.instance;

        Widget factory1(ToastMeta meta, void Function(ToastMeta) update) {
          return const SizedBox();
        }

        Widget factory2(ToastMeta meta, void Function(ToastMeta) update) {
          return const SizedBox();
        }

        registry.register('style1', factory1);
        registry.register('style2', factory2);

        final ids = registry.styleIds;

        expect(ids.length, 2);
        expect(ids.contains('style1'), isTrue);
        expect(ids.contains('style2'), isTrue);
      });

      nyTest('returns empty set when no styles registered', () async {
        final registry = ToastNotificationRegistry.instance;

        expect(registry.styleIds, isEmpty);
      });
    });

    nyGroup('factory invocation', () {
      nyTest('factory receives ToastMeta and update callback', () async {
        final registry = ToastNotificationRegistry.instance;
        ToastMeta? receivedMeta;
        void Function(ToastMeta)? receivedUpdate;

        Widget factory(ToastMeta meta, void Function(ToastMeta) update) {
          receivedMeta = meta;
          receivedUpdate = update;
          return const SizedBox();
        }

        registry.register('test', factory);

        final retrievedFactory = registry.get('test');
        final testMeta = ToastMeta(title: 'Test Title');

        retrievedFactory!(testMeta, (updated) {});

        expect(receivedMeta, isNotNull);
        expect(receivedMeta!.title, 'Test Title');
        expect(receivedUpdate, isNotNull);
      });

      nyTest('update callback can modify meta', () async {
        final registry = ToastNotificationRegistry.instance;
        ToastMeta? updatedMeta;

        Widget factory(ToastMeta meta, void Function(ToastMeta) update) {
          // Simulate widget updating meta
          update(meta.copyWith(title: 'Updated Title'));
          return const SizedBox();
        }

        registry.register('test', factory);

        final retrievedFactory = registry.get('test');
        final testMeta = ToastMeta(title: 'Original');

        retrievedFactory!(testMeta, (updated) {
          updatedMeta = updated;
        });

        expect(updatedMeta, isNotNull);
        expect(updatedMeta!.title, 'Updated Title');
      });
    });
  });
}
