import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/local_storage/ny_local_storage.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('StorageException', () {
    nyGroup('constructor', () {
      nyTest('should create with message only', () async {
        const exception = StorageException('Test error message');

        expect(exception.message, 'Test error message');
        expect(exception.key, isNull);
      });

      nyTest('should create with message and key', () async {
        const exception = StorageException(
          'Test error message',
          key: 'test_key',
        );

        expect(exception.message, 'Test error message');
        expect(exception.key, 'test_key');
      });
    });

    nyGroup('toString', () {
      nyTest('should format message without key', () async {
        const exception = StorageException('Test error message');

        expect(exception.toString(), 'StorageException: Test error message');
      });

      nyTest('should format message with key', () async {
        const exception = StorageException(
          'Test error message',
          key: 'test_key',
        );

        expect(
          exception.toString(),
          'StorageException: Test error message (key: test_key)',
        );
      });
    });

    nyTest('should implement Exception interface', () async {
      const exception = StorageException('Test');

      expect(exception, isA<Exception>());
    });
  });

  nyGroup('StorageSerializationException', () {
    nyGroup('constructor', () {
      nyTest('should create with message only', () async {
        const exception = StorageSerializationException('Serialization failed');

        expect(exception.message, 'Serialization failed');
        expect(exception.key, isNull);
        expect(exception.objectType, isNull);
      });

      nyTest('should create with all parameters', () async {
        const exception = StorageSerializationException(
          'Serialization failed',
          key: 'test_key',
          objectType: String,
        );

        expect(exception.message, 'Serialization failed');
        expect(exception.key, 'test_key');
        expect(exception.objectType, String);
      });
    });

    nyGroup('toString', () {
      nyTest('should format message without optional fields', () async {
        const exception = StorageSerializationException('Serialization failed');

        expect(
          exception.toString(),
          'StorageSerializationException: Serialization failed',
        );
      });

      nyTest('should format message with object type only', () async {
        const exception = StorageSerializationException(
          'Serialization failed',
          objectType: String,
        );

        expect(
          exception.toString(),
          'StorageSerializationException: Serialization failed (type: String)',
        );
      });

      nyTest('should format message with key only', () async {
        const exception = StorageSerializationException(
          'Serialization failed',
          key: 'test_key',
        );

        expect(
          exception.toString(),
          'StorageSerializationException: Serialization failed (key: test_key)',
        );
      });

      nyTest('should format message with all fields', () async {
        const exception = StorageSerializationException(
          'Serialization failed',
          key: 'test_key',
          objectType: int,
        );

        expect(
          exception.toString(),
          'StorageSerializationException: Serialization failed (type: int) (key: test_key)',
        );
      });
    });

    nyTest('should extend StorageException', () async {
      const exception = StorageSerializationException('Test');

      expect(exception, isA<StorageException>());
    });
  });

  nyGroup('StorageDeserializationException', () {
    nyGroup('constructor', () {
      nyTest('should create with message only', () async {
        const exception = StorageDeserializationException(
          'Deserialization failed',
        );

        expect(exception.message, 'Deserialization failed');
        expect(exception.key, isNull);
        expect(exception.expectedType, isNull);
      });

      nyTest('should create with all parameters', () async {
        const exception = StorageDeserializationException(
          'Deserialization failed',
          key: 'test_key',
          expectedType: Map,
        );

        expect(exception.message, 'Deserialization failed');
        expect(exception.key, 'test_key');
        expect(exception.expectedType, Map);
      });
    });

    nyGroup('toString', () {
      nyTest('should format message without optional fields', () async {
        const exception = StorageDeserializationException(
          'Deserialization failed',
        );

        expect(
          exception.toString(),
          'StorageDeserializationException: Deserialization failed',
        );
      });

      nyTest('should format message with expected type only', () async {
        const exception = StorageDeserializationException(
          'Deserialization failed',
          expectedType: List,
        );

        expect(
          exception.toString(),
          'StorageDeserializationException: Deserialization failed (expected type: List<dynamic>)',
        );
      });

      nyTest('should format message with key only', () async {
        const exception = StorageDeserializationException(
          'Deserialization failed',
          key: 'test_key',
        );

        expect(
          exception.toString(),
          'StorageDeserializationException: Deserialization failed (key: test_key)',
        );
      });

      nyTest('should format message with all fields', () async {
        const exception = StorageDeserializationException(
          'Deserialization failed',
          key: 'test_key',
          expectedType: double,
        );

        expect(
          exception.toString(),
          'StorageDeserializationException: Deserialization failed (expected type: double) (key: test_key)',
        );
      });
    });

    nyTest('should extend StorageException', () async {
      const exception = StorageDeserializationException('Test');

      expect(exception, isA<StorageException>());
    });
  });

  nyGroup('StorageKeyNotFoundException', () {
    nyGroup('constructor', () {
      nyTest('should create with key', () async {
        const exception = StorageKeyNotFoundException('missing_key');

        expect(exception.message, 'Key not found in storage');
        expect(exception.key, 'missing_key');
      });
    });

    nyGroup('toString', () {
      nyTest('should format message with key', () async {
        const exception = StorageKeyNotFoundException('user_data');

        expect(
          exception.toString(),
          'StorageKeyNotFoundException: Key "user_data" not found',
        );
      });
    });

    nyTest('should extend StorageException', () async {
      const exception = StorageKeyNotFoundException('test');

      expect(exception, isA<StorageException>());
    });
  });

  nyGroup('StorageTimeoutException', () {
    nyGroup('constructor', () {
      nyTest('should create with message only', () async {
        const exception = StorageTimeoutException('Operation timed out');

        expect(exception.message, 'Operation timed out');
        expect(exception.key, isNull);
        expect(exception.timeout, isNull);
      });

      nyTest('should create with all parameters', () async {
        const exception = StorageTimeoutException(
          'Operation timed out',
          key: 'slow_key',
          timeout: Duration(seconds: 30),
        );

        expect(exception.message, 'Operation timed out');
        expect(exception.key, 'slow_key');
        expect(exception.timeout, const Duration(seconds: 30));
      });
    });

    nyGroup('toString', () {
      nyTest('should format message without optional fields', () async {
        const exception = StorageTimeoutException('Operation timed out');

        expect(
          exception.toString(),
          'StorageTimeoutException: Operation timed out',
        );
      });

      nyTest('should format message with timeout only', () async {
        const exception = StorageTimeoutException(
          'Operation timed out',
          timeout: Duration(milliseconds: 5000),
        );

        expect(
          exception.toString(),
          'StorageTimeoutException: Operation timed out (timeout: 5000ms)',
        );
      });

      nyTest('should format message with key only', () async {
        const exception = StorageTimeoutException(
          'Operation timed out',
          key: 'slow_key',
        );

        expect(
          exception.toString(),
          'StorageTimeoutException: Operation timed out (key: slow_key)',
        );
      });

      nyTest('should format message with all fields', () async {
        const exception = StorageTimeoutException(
          'Operation timed out',
          key: 'slow_key',
          timeout: Duration(seconds: 10),
        );

        expect(
          exception.toString(),
          'StorageTimeoutException: Operation timed out (timeout: 10000ms) (key: slow_key)',
        );
      });
    });

    nyTest('should extend StorageException', () async {
      const exception = StorageTimeoutException('Test');

      expect(exception, isA<StorageException>());
    });
  });
}
