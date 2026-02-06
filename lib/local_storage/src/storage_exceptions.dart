/// Base exception class for storage-related errors.
class StorageException implements Exception {
  /// The error message.
  final String message;

  /// The storage key associated with the error, if applicable.
  final String? key;

  /// Creates a new [StorageException].
  const StorageException(this.message, {this.key});

  @override
  String toString() {
    if (key != null) {
      return 'StorageException: $message (key: $key)';
    }
    return 'StorageException: $message';
  }
}

/// Exception thrown when serialization of an object to storage fails.
class StorageSerializationException extends StorageException {
  /// The type of object that failed to serialize.
  final Type? objectType;

  /// Creates a new [StorageSerializationException].
  const StorageSerializationException(
    super.message, {
    super.key,
    this.objectType,
  });

  @override
  String toString() {
    final buffer = StringBuffer('StorageSerializationException: $message');
    if (objectType != null) {
      buffer.write(' (type: $objectType)');
    }
    if (key != null) {
      buffer.write(' (key: $key)');
    }
    return buffer.toString();
  }
}

/// Exception thrown when deserialization of stored data fails.
class StorageDeserializationException extends StorageException {
  /// The expected type that failed to deserialize.
  final Type? expectedType;

  /// Creates a new [StorageDeserializationException].
  const StorageDeserializationException(
    super.message, {
    super.key,
    this.expectedType,
  });

  @override
  String toString() {
    final buffer = StringBuffer('StorageDeserializationException: $message');
    if (expectedType != null) {
      buffer.write(' (expected type: $expectedType)');
    }
    if (key != null) {
      buffer.write(' (key: $key)');
    }
    return buffer.toString();
  }
}

/// Exception thrown when a storage key is not found.
class StorageKeyNotFoundException extends StorageException {
  /// Creates a new [StorageKeyNotFoundException].
  const StorageKeyNotFoundException(String key)
    : super('Key not found in storage', key: key);

  @override
  String toString() => 'StorageKeyNotFoundException: Key "$key" not found';
}

/// Exception thrown when a storage operation times out.
class StorageTimeoutException extends StorageException {
  /// The duration after which the timeout occurred.
  final Duration? timeout;

  /// Creates a new [StorageTimeoutException].
  const StorageTimeoutException(super.message, {super.key, this.timeout});

  @override
  String toString() {
    final buffer = StringBuffer('StorageTimeoutException: $message');
    if (timeout != null) {
      buffer.write(' (timeout: ${timeout!.inMilliseconds}ms)');
    }
    if (key != null) {
      buffer.write(' (key: $key)');
    }
    return buffer.toString();
  }
}
