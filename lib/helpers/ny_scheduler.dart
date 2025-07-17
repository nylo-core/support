import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/helpers/extensions.dart';

import '/local_storage/local_storage.dart';
import 'helper.dart';

/// Nylo's Scheduler class
/// This class is used to schedule tasks to run at a later time.
class NyScheduler {
  /// The prefix for the scheduler
  static const prefix = "ny_scheduler_";

  /// The secure storage key
  static String key(String name) => prefix + name;

  /// The secure storage instance
  static final FlutterSecureStorage _secureStorage = NyStorage.manager();

  /// Read a value from the local storage
  /// Provide a [name] for the value you want to read.
  static Future<String?> readValue(String name) async {
    return await _secureStorage.read(key: key(name));
  }

  /// Read a boolean value from the local storage
  /// Provide a [name] for the value you want to read.
  static Future<bool> readBool(String name) async {
    return (await readValue(name) ?? "") == "true";
  }

  /// Write a value to the local storage
  /// Provide a [name] for the value and a [value] to write.
  static Future writeValue(String name, String value) async {
    return await _secureStorage.write(key: key(name), value: value);
  }

  /// Write a bool value to the local storage
  /// Provide a [name] for the value and a [value] to write.
  static Future writeBool(String name, bool value) async {
    return await writeValue(name, (value == true ? "true" : "false"));
  }

  /// Run a function once
  /// Provide a [name] for the function and a [callback] to execute.
  /// The function will only execute once.
  ///
  /// Example:
  /// ```dart
  /// NyScheduler.once("myFunction", () {
  ///  print("This will only execute once");
  ///  });
  ///  ```
  ///  The above example will only execute once.
  ///  The next time you call NyScheduler.once("myFunction", () {}) it will not execute.
  static Future<void> taskOnce(String name, Function() callback) async {
    String key = "${name}_once";
    bool alreadyExecuted = await readBool(key);
    if (!alreadyExecuted) {
      await writeBool(key, true);
      await callback();
    }
  }

  /// Check if a task has been executed
  static Future<bool> hasExecutedTaskOnce(String name) async {
    String key = "${name}_once";
    return await readBool(key);
  }

  /// Get the key for a task that runs once
  static String getKeyTaskOnce(String name) {
    return "${name}_once";
  }

  /// Run a task daily
  /// Provide a [name] for the function and a [callback] to execute.
  /// The function will execute every day.
  /// You can also provide an [endAt] date to stop the task from running.
  /// You can also provide a [frequency] to run the task weekly, monthly or yearly.
  /// Example:
  /// ```dart
  /// NyScheduler.taskDaily("myFunction", () {
  ///   print("This will execute every day");
  /// });
  /// ```
  /// The above example will execute every day.
  static Future<void> taskDaily(String name, Function() callback,
      {DateTime? endAt}) async {
    if (endAt != null && !endAt.isInFuture()) {
      return;
    }

    String key = "${name}_daily";
    String? lastTime = await readValue(key);

    if (lastTime == null || lastTime.isEmpty) {
      await _executeTaskAndSetDateTime(key, callback);
      return;
    }

    DateTime todayDateTime = now();
    DateTime lastDateTime = DateTime.parse(lastTime);
    Duration difference = todayDateTime.difference(lastDateTime);
    bool canExecute = (difference.inDays >= 1);

    if (canExecute) {
      // set the time
      await _executeTaskAndSetDateTime(key, callback);
    }
  }

  /// Execute a task
  static Future<void> _executeTaskAndSetDateTime(
      String key, Function() callback) async {
    DateTime dateTime = DateTime.now();
    await writeValue(key, dateTime.toString());

    await callback();
  }

  /// Run a task after date
  /// Provide a [name] for the function and a [callback] to execute.
  /// The function will execute after the [date] provided.
  /// Example:
  /// ```dart
  /// NyScheduler.taskAfterDate("myFunction", () {
  ///   print("This will execute after the date");
  /// }, date: DateTime.now().add(Duration(days: 1)));
  /// ```
  /// The above example will execute after the date provided.
  static Future<void> taskOnceAfterDate(String name, Function() callback,
      {required DateTime date}) async {
    /// Check if the date is in the past
    if (!date.isInPast()) {
      return;
    }
    String key = "${name}_after_date_$date";

    /// Check if we have already executed the task
    String keyExecuted = "${key}_executed";
    bool alreadyExecuted = await readBool(keyExecuted);

    if (!alreadyExecuted) {
      await writeBool(keyExecuted, true);
      await callback();
    }
  }
}
