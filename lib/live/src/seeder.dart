import 'package:flutter/foundation.dart';

import '/helpers/ny_helpers.dart';
import '/local_storage/ny_local_storage.dart';
import 'live_output.dart';
import 'seed_recorder.dart';
import 'storage_snapshot.dart';

/// Puts a running app into a known state, and takes it back out.
///
/// Write [up] to add the data. While it runs, Nylo records every storage and
/// Backpack value it changes, so [down] can put each one back as it was.
///
/// ```dart
/// class DemoUserSeeder extends Seeder {
///   @override
///   String get description => 'Jane Doe, signed in, onboarding done';
///
///   @override
///   Future<void> up() async {
///     await Auth.authenticate(data: {'name': 'Jane Doe', 'token': 'demo'});
///     await saveToStorage({'onboarding_complete': true});
///     success('Signed in as Jane Doe');
///   }
///
///   @override
///   Future<void> down() async {
///     await restore();
///   }
/// }
/// ```
///
/// Create one with `metro make:seeder demo_user`, run it with
/// `metro live:seed demo_user`, and undo it with
/// `metro live:seed:rollback demo_user`.
abstract class Seeder with LiveOutput {
  /// One line shown next to the seeder's name by `metro live:seed`.
  String? get description => null;

  /// The name this seeder is recorded under when it isn't registered with
  /// Nylo. Registered seeders run under their key in the registry, and
  /// others under their class name in snake case (`DemoUserSeeder` is
  /// `demo_user`), so most seeders leave this null.
  String? get name => null;

  /// Adds the data.
  ///
  /// Runs inside the app, so it can use your models, `Auth`, `NyStorage` and
  /// API services. Every storage and Backpack change made here is recorded.
  /// Seeding again runs it again; rolling back still returns to how the app
  /// was before the first run.
  Future<void> up();

  /// Removes the data. Defaults to [restore].
  ///
  /// Override it to undo what Nylo can't record, like records on your API,
  /// then call [restore] for the rest.
  Future<void> down() => restore();

  /// Undoes everything [up] changed, newest first.
  ///
  /// Storage and Backpack values go back to how they were before the seeder
  /// ran, and seeders it ran with [seed] are rolled back too.
  @nonVirtual
  Future<void> restore() => SeedRecorder.restore(this);

  /// Runs other seeders as part of this one.
  ///
  /// Their changes are recorded as their own runs, and rolling this seeder
  /// back rolls them back too.
  @nonVirtual
  Future<void> seed(List<Seeder> seeders) => SeedRecorder.seedChildren(seeders);

  /// Saves each value to storage. Maps and lists are saved as JSON.
  ///
  /// Pass [inBackpack] to put the values in Backpack as well.
  @protected
  Future<void> saveToStorage(
    Map<String, dynamic> values, {
    bool inBackpack = false,
  }) async {
    for (final MapEntry<String, dynamic> entry in values.entries) {
      if (entry.value is Map || entry.value is List) {
        await NyStorage.saveJson(
          entry.key,
          entry.value,
          inBackpack: inBackpack,
        );
      } else {
        await NyStorage.save(entry.key, entry.value, inBackpack: inBackpack);
      }
    }
  }

  /// Saves each value to Backpack, which lives in memory.
  @protected
  void saveToBackpack(Map<String, dynamic> values) =>
      values.forEach(Backpack.instance.save);

  /// Puts a [snapshot] taken with `metro live:export` into storage and
  /// Backpack, and returns how many values it wrote.
  ///
  /// [snapshot] is the map an exported seeder holds:
  /// `{'storage': {...}, 'backpack': {...}}`. Every value is recorded, so
  /// [restore] puts the old ones back. See [StorageSnapshot] for the format.
  @protected
  Future<int> importSnapshot(Map<String, Object?> snapshot) =>
      StorageSnapshot.fromJson(snapshot).apply();
}
