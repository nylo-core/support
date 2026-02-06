/// NyTime - Time manipulation utilities for testing.
///
/// This class allows you to freeze time, travel to specific dates,
/// and control the flow of time in your tests.
///
/// Example:
/// ```dart
/// NyTime.setTestNow(DateTime(2025, 1, 1));
/// expect(NyTime.now().year, 2025);
/// NyTime.reset();
/// ```
class NyTime {
  static DateTime? _testNow;

  /// Returns the current DateTime.
  /// If a test time is set, returns that instead of the real time.
  static DateTime now() {
    return _testNow ?? DateTime.now();
  }

  /// Sets a fixed time for testing.
  /// All subsequent calls to [now()] will return this time.
  ///
  /// Example:
  /// ```dart
  /// NyTime.setTestNow(DateTime(2025, 12, 25, 10, 30));
  /// print(NyTime.now()); // 2025-12-25 10:30:00.000
  /// ```
  static void setTestNow(DateTime date) {
    _testNow = date;
  }

  /// Resets the time to use the real system time.
  static void reset() {
    _testNow = null;
  }

  /// Checks if test time is currently active.
  static bool get isFrozen => _testNow != null;

  /// Travel forward in time by a duration.
  ///
  /// Example:
  /// ```dart
  /// NyTime.setTestNow(DateTime(2025, 1, 1));
  /// NyTime.advanceBy(Duration(days: 30));
  /// print(NyTime.now()); // 2025-01-31
  /// ```
  static void advanceBy(Duration duration) {
    if (_testNow != null) {
      _testNow = _testNow!.add(duration);
    } else {
      _testNow = DateTime.now().add(duration);
    }
  }

  /// Travel backward in time by a duration.
  static void rewindBy(Duration duration) {
    if (_testNow != null) {
      _testNow = _testNow!.subtract(duration);
    } else {
      _testNow = DateTime.now().subtract(duration);
    }
  }

  /// Freeze time at the current moment.
  static void freeze() {
    _testNow = DateTime.now();
  }

  /// Execute a callback with a specific frozen time, then restore.
  ///
  /// Example:
  /// ```dart
  /// await NyTime.withFrozenTime(DateTime(2025, 1, 1), () async {
  ///   // Time is frozen to 2025-01-01 here
  ///   await someAsyncOperation();
  /// });
  /// // Time is back to normal here
  /// ```
  static Future<T> withFrozenTime<T>(
    DateTime time,
    Future<T> Function() callback,
  ) async {
    final previous = _testNow;
    _testNow = time;
    try {
      return await callback();
    } finally {
      _testNow = previous;
    }
  }

  /// Synchronous version of [withFrozenTime].
  static T withFrozenTimeSync<T>(DateTime time, T Function() callback) {
    final previous = _testNow;
    _testNow = time;
    try {
      return callback();
    } finally {
      _testNow = previous;
    }
  }

  /// Get the current test time or null if using real time.
  static DateTime? get testNow => _testNow;

  /// Travel to start of current day.
  static void travelToStartOfDay() {
    final now = _testNow ?? DateTime.now();
    _testNow = DateTime(now.year, now.month, now.day);
  }

  /// Travel to end of current day.
  static void travelToEndOfDay() {
    final now = _testNow ?? DateTime.now();
    _testNow = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
  }

  /// Travel to start of current month.
  static void travelToStartOfMonth() {
    final now = _testNow ?? DateTime.now();
    _testNow = DateTime(now.year, now.month, 1);
  }

  /// Travel to end of current month.
  static void travelToEndOfMonth() {
    final now = _testNow ?? DateTime.now();
    _testNow = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
  }

  /// Travel to start of current year.
  static void travelToStartOfYear() {
    final now = _testNow ?? DateTime.now();
    _testNow = DateTime(now.year, 1, 1);
  }

  /// Travel to end of current year.
  static void travelToEndOfYear() {
    final now = _testNow ?? DateTime.now();
    _testNow = DateTime(now.year, 12, 31, 23, 59, 59, 999);
  }
}
