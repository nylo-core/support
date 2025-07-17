import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '/nylo.dart';
import '/local_storage/local_storage.dart';
import 'ny_logger.dart';

/// Nylo's NyAppUsage class
/// This class is used to monitor app usage.
class NyAppUsage {
  /// The prefix for the app usage
  static const prefix = "ny_app_usage_";

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

  /// Reset launch count
  static Future<void> resetLaunchCount() async {
    await useMonitoringMethod(() async {
      await writeValue("launch_count", "0");
    });
  }

  /// Reset first launch
  static Future<void> resetFirstLaunch() async {
    await useMonitoringMethod(() async {
      await writeValue("first_launch", DateTime.now().toString());
    });
  }

  /// Reset first launch
  static Future<void> resetLastLaunch() async {
    await useMonitoringMethod(() async {
      await writeValue("last_launch", DateTime.now().toString());
    });
  }

  /// Check if we can use this [method]
  static Future useMonitoringMethod(Function() method) async {
    Nylo.canMonitorAppUsage();
    return await method();
  }

  /// App launched
  /// This method will increment the app launch count.
  static Future<void> appLaunched() async {
    await useMonitoringMethod(() async {
      await writeValue("last_launch", DateTime.now().toString());
      int? count = await appLaunchCount();
      if (count == null) {
        await writeValue("first_launch", DateTime.now().toString());
        await writeValue("launch_count", "1");
        return;
      }
      count++;
      await writeValue("launch_count", count.toString());
    });
  }

  /// App launch count
  /// This method will return the app launch count.
  static Future<int?> appLaunchCount() async {
    return await useMonitoringMethod(() async {
      String? launchCount = await readValue("launch_count");
      if (launchCount == null || launchCount.isEmpty) {
        return null;
      }

      int count = int.parse(launchCount);
      return count;
    });
  }

  /// Days since first launch
  static Future<int> appTotalDaysSinceFirstLaunch() async {
    return await useMonitoringMethod(() async {
      String? firstLaunch = await readValue("first_launch");
      if (firstLaunch == null || firstLaunch.isEmpty) {
        return 0;
      }

      DateTime firstLaunchDateTime = DateTime.parse(firstLaunch);
      DateTime todayDateTime = DateTime.now();
      Duration difference = todayDateTime.difference(firstLaunchDateTime);
      return difference.inDays;
    });
  }

  /// Days since first launch
  static Future<DateTime?> appFirstLaunchDate() async {
    return await useMonitoringMethod(() async {
      String? firstLaunch = await readValue("first_launch");
      if (firstLaunch == null || firstLaunch.isEmpty) {
        return null;
      }

      try {
        return DateTime.parse(firstLaunch);
      } on Exception catch (e) {
        NyLogger.error(e.toString());
        return null;
      }
    });
  }
}
