import '/helpers/extensions.dart';

import '/local_storage/local_storage.dart';

/// Nylo's NyAction class
class NyAction {
  /// Limit the number of times an action can be performed in a day.
  /// Provide an [actionKey] for the action you want to limit.
  /// Provide an [perform] to execute if the user is authorized.
  /// Provide a [maxPerDay] to limit the number of times the action can be performed.
  static Future<void> limitPerDay(String actionKey, Function() perform,
      {int maxPerDay = 5, Function()? unauthorized}) async {
    String key = "action_$actionKey";

    /// check that the actions occur on the same day
    Map<String, dynamic>? value = await NyStorage.readJson(key);
    if (value == null) {
      await NyStorage.saveJson(
          key, {"date": DateTime.now().toDateString(), "value": "1"});
      await perform();
      return;
    }
    int valueInt = int.parse(value['value']);

    // reset the value if the date is not today
    if (value['date'] != DateTime.now().toDateString()) {
      await NyStorage.saveJson(
          key, {"date": DateTime.now().toDateString(), "value": "1"});
      await perform();
      return;
    }

    if (valueInt >= maxPerDay) {
      if (unauthorized != null) {
        await unauthorized();
      }
      return;
    }
    await NyStorage.saveJson(key, {
      "date": DateTime.now().toDateString(),
      "value": (valueInt + 1).toString()
    });
    await perform();
  }

  /// Perform an action only if the user is authorized to do so.
  /// Provide a [perform] function to execute if the user is authorized.
  /// Provide a [when] function to check if the user is authorized.
  /// Provide an [unauthorized] function to execute if the user is not authorized.
  static Future<void> authorized(Function() perform,
      {required bool Function() when, Function()? unauthorized}) async {
    bool canPerform = when();
    if (!canPerform) {
      if (unauthorized != null) {
        await unauthorized();
      }
      return;
    }
    await perform();
  }
}
