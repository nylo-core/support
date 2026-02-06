import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('NyLogEntry', () {
    nyTest('should create with required fields', () async {
      final entry = NyLogEntry(
        message: 'Test message',
        dateTime: DateTime(2025, 1, 1),
      );
      expect(entry.message, 'Test message');
      expect(entry.dateTime, DateTime(2025, 1, 1));
      expect(entry.type, isNull);
      expect(entry.stackTrace, isNull);
      expect(entry.context, isNull);
    });

    nyTest('should create with all fields', () async {
      final trace = StackTrace.current;
      final context = {'userId': '123', 'action': 'login'};
      final entry = NyLogEntry(
        message: 'Error occurred',
        type: 'error',
        dateTime: DateTime(2025, 6, 15),
        stackTrace: trace,
        context: context,
      );
      expect(entry.message, 'Error occurred');
      expect(entry.type, 'error');
      expect(entry.dateTime, DateTime(2025, 6, 15));
      expect(entry.stackTrace, trace);
      expect(entry.context, context);
    });

    nyTest('should store context map', () async {
      final entry = NyLogEntry(
        message: 'User action',
        dateTime: DateTime(2025, 1, 1),
        context: {'id': 42, 'name': 'test'},
      );
      expect(entry.context, isNotNull);
      expect(entry.context!['id'], 42);
      expect(entry.context!['name'], 'test');
    });
  });

  nyGroup('NyLogger color constants', () {
    nyTest('useColors defaults to true', () async {
      expect(NyLogger.useColors, isTrue);
    });

    nyTest('useColors can be set to false', () async {
      NyLogger.useColors = false;
      expect(NyLogger.useColors, isFalse);
      NyLogger.useColors = true; // reset
    });
  });

  nyGroup('NyLogger.onLog callback', () {
    nyTest('should be null by default', () async {
      expect(NyLogger.onLog, isNull);
    });

    nyTest('should accept a callback', () async {
      NyLogEntry? receivedEntry;
      NyLogger.onLog = (entry) {
        receivedEntry = entry;
      };
      expect(NyLogger.onLog, isNotNull);
      NyLogger.onLog = null; // reset
    });

    nyTest('should receive interpolated message with context', () async {
      NyLogEntry? receivedEntry;
      NyLogger.onLog = (entry) {
        receivedEntry = entry;
      };

      // The callback is called before env check, so we catch the exception
      try {
        NyLogger.info('User {id} logged in', context: {'id': '123'});
      } catch (_) {
        // Expected in test environment without full Nylo setup
      }

      expect(receivedEntry, isNotNull);
      expect(receivedEntry!.message, 'User 123 logged in');
      expect(receivedEntry!.type, 'info');
      expect(receivedEntry!.context, {'id': '123'});
      NyLogger.onLog = null; // reset
    });

    nyTest('should handle multiple context placeholders', () async {
      NyLogEntry? receivedEntry;
      NyLogger.onLog = (entry) {
        receivedEntry = entry;
      };

      try {
        NyLogger.error(
          'Order {orderId} failed for user {userId}',
          context: {'orderId': 'ORD-456', 'userId': 'USR-789'},
        );
      } catch (_) {}

      expect(receivedEntry, isNotNull);
      expect(receivedEntry!.message, 'Order ORD-456 failed for user USR-789');
      NyLogger.onLog = null; // reset
    });

    nyTest('should handle empty context', () async {
      NyLogEntry? receivedEntry;
      NyLogger.onLog = (entry) {
        receivedEntry = entry;
      };

      try {
        NyLogger.info('No placeholders here', context: {});
      } catch (_) {}

      expect(receivedEntry, isNotNull);
      expect(receivedEntry!.message, 'No placeholders here');
      NyLogger.onLog = null; // reset
    });

    nyTest('should handle null context', () async {
      NyLogEntry? receivedEntry;
      NyLogger.onLog = (entry) {
        receivedEntry = entry;
      };

      try {
        NyLogger.info('Message without context');
      } catch (_) {}

      expect(receivedEntry, isNotNull);
      expect(receivedEntry!.message, 'Message without context');
      expect(receivedEntry!.context, isNull);
      NyLogger.onLog = null; // reset
    });

    nyTest('should preserve unmatched placeholders', () async {
      NyLogEntry? receivedEntry;
      NyLogger.onLog = (entry) {
        receivedEntry = entry;
      };

      try {
        NyLogger.info('User {id} with {missing}', context: {'id': '123'});
      } catch (_) {}

      expect(receivedEntry, isNotNull);
      expect(receivedEntry!.message, 'User 123 with {missing}');
      NyLogger.onLog = null; // reset
    });
  });

  nyGroup('NyLogger log levels', () {
    nyTest('should log emergency messages', () async {
      NyLogEntry? receivedEntry;
      NyLogger.onLog = (entry) {
        receivedEntry = entry;
      };

      try {
        NyLogger.emergency('System is down!');
      } catch (_) {}

      expect(receivedEntry, isNotNull);
      expect(receivedEntry!.message, 'System is down!');
      expect(receivedEntry!.type, 'emergency');
      NyLogger.onLog = null;
    });

    nyTest('should log alert messages', () async {
      NyLogEntry? receivedEntry;
      NyLogger.onLog = (entry) {
        receivedEntry = entry;
      };

      try {
        NyLogger.alert('High memory usage detected');
      } catch (_) {}

      expect(receivedEntry, isNotNull);
      expect(receivedEntry!.message, 'High memory usage detected');
      expect(receivedEntry!.type, 'alert');
      NyLogger.onLog = null;
    });

    nyTest('emergency should support context', () async {
      NyLogEntry? receivedEntry;
      NyLogger.onLog = (entry) {
        receivedEntry = entry;
      };

      try {
        NyLogger.emergency(
          'Critical failure in {module}',
          context: {'module': 'auth'},
        );
      } catch (_) {}

      expect(receivedEntry, isNotNull);
      expect(receivedEntry!.message, 'Critical failure in auth');
      expect(receivedEntry!.type, 'emergency');
      NyLogger.onLog = null;
    });

    nyTest('alert should support context', () async {
      NyLogEntry? receivedEntry;
      NyLogger.onLog = (entry) {
        receivedEntry = entry;
      };

      try {
        NyLogger.alert(
          'Memory at {percent}% on {server}',
          context: {'percent': '95', 'server': 'web-01'},
        );
      } catch (_) {}

      expect(receivedEntry, isNotNull);
      expect(receivedEntry!.message, 'Memory at 95% on web-01');
      expect(receivedEntry!.type, 'alert');
      NyLogger.onLog = null;
    });

    nyTest('debug should support context', () async {
      NyLogEntry? receivedEntry;
      NyLogger.onLog = (entry) {
        receivedEntry = entry;
      };

      try {
        NyLogger.debug('Processing item {name}', context: {'name': 'Widget'});
      } catch (_) {}

      expect(receivedEntry, isNotNull);
      expect(receivedEntry!.message, 'Processing item Widget');
      expect(receivedEntry!.type, 'debug');
      NyLogger.onLog = null;
    });

    nyTest('warning should support context', () async {
      NyLogEntry? receivedEntry;
      NyLogger.onLog = (entry) {
        receivedEntry = entry;
      };

      try {
        NyLogger.warning(
          'Deprecated method {method} called',
          context: {'method': 'oldFetch'},
        );
      } catch (_) {}

      expect(receivedEntry, isNotNull);
      expect(receivedEntry!.message, 'Deprecated method oldFetch called');
      expect(receivedEntry!.type, 'warning');
      NyLogger.onLog = null;
    });

    nyTest('success should support context', () async {
      NyLogEntry? receivedEntry;
      NyLogger.onLog = (entry) {
        receivedEntry = entry;
      };

      try {
        NyLogger.success(
          'Deployed version {version}',
          context: {'version': '2.0.0'},
        );
      } catch (_) {}

      expect(receivedEntry, isNotNull);
      expect(receivedEntry!.message, 'Deployed version 2.0.0');
      expect(receivedEntry!.type, 'success');
      NyLogger.onLog = null;
    });

    nyTest('verbose should support context', () async {
      NyLogEntry? receivedEntry;
      NyLogger.onLog = (entry) {
        receivedEntry = entry;
      };

      try {
        NyLogger.verbose(
          'Cache hit for key {key}',
          context: {'key': 'user_profile_123'},
        );
      } catch (_) {}

      expect(receivedEntry, isNotNull);
      expect(receivedEntry!.message, 'Cache hit for key user_profile_123');
      expect(receivedEntry!.type, 'verbose');
      NyLogger.onLog = null;
    });
  });

  nyGroup('Context value types', () {
    nyTest('should convert numeric values to string', () async {
      NyLogEntry? receivedEntry;
      NyLogger.onLog = (entry) {
        receivedEntry = entry;
      };

      try {
        NyLogger.info('Count: {count}', context: {'count': 42});
      } catch (_) {}

      expect(receivedEntry, isNotNull);
      expect(receivedEntry!.message, 'Count: 42');
      NyLogger.onLog = null;
    });

    nyTest('should convert double values to string', () async {
      NyLogEntry? receivedEntry;
      NyLogger.onLog = (entry) {
        receivedEntry = entry;
      };

      try {
        NyLogger.info('Price: {price}', context: {'price': 19.99});
      } catch (_) {}

      expect(receivedEntry, isNotNull);
      expect(receivedEntry!.message, 'Price: 19.99');
      NyLogger.onLog = null;
    });

    nyTest('should convert boolean values to string', () async {
      NyLogEntry? receivedEntry;
      NyLogger.onLog = (entry) {
        receivedEntry = entry;
      };

      try {
        NyLogger.info('Active: {active}', context: {'active': true});
      } catch (_) {}

      expect(receivedEntry, isNotNull);
      expect(receivedEntry!.message, 'Active: true');
      NyLogger.onLog = null;
    });
  });
}
