import 'dart:async';

import 'extensions.dart';

import '/local_storage/ny_local_storage.dart';

/// Nylo's NyAction class
class NyAction {
  /// Limit the number of times an action can be performed in a day.
  /// Provide an [actionKey] for the action you want to limit.
  /// Provide a [perform] callback to execute if the user is authorized.
  /// Provide a [maxPerDay] to limit the number of times the action can be performed.
  /// Provide an [unauthorized] callback to execute if the limit is reached.
  static Future<void> limitPerDay(
    String actionKey,
    FutureOr<void> Function() perform, {
    int maxPerDay = 5,
    FutureOr<void> Function()? unauthorized,
  }) async {
    final key = 'action_$actionKey';
    final today = DateTime.now().toDateString();

    final stored = await NyStorage.readJson(key);
    final isNewDay = stored == null || stored['date'] != today;
    final count = isNewDay ? 0 : (stored['count'] as int? ?? 0);

    if (count >= maxPerDay) {
      await unauthorized?.call();
      return;
    }

    await NyStorage.saveJson(key, {'date': today, 'count': count + 1});
    await perform();
  }

  /// Perform an action only if the user is authorized to do so.
  /// Provide a [perform] callback to execute if the user is authorized.
  /// Provide a [when] callback to check if the user is authorized.
  /// Provide an [unauthorized] callback to execute if the user is not authorized.
  static Future<void> authorized(
    FutureOr<void> Function() perform, {
    required FutureOr<bool> Function() when,
    FutureOr<void> Function()? unauthorized,
  }) async {
    final canPerform = await when();
    if (!canPerform) {
      await unauthorized?.call();
      return;
    }
    await perform();
  }
}
