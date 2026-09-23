import 'dart:async';

import 'package:flutter/foundation.dart';

/// Receives the storage and Backpack changes made while a seeder runs.
///
/// `NyStorage` and `Backpack` tell the recording active in the current zone
/// before they change a value, so `restore()` can put every value back.
abstract class SeedRecording {
  /// The storage value at [key] is about to be written or deleted.
  Future<void> storageWillChange(String key);

  /// Every storage value is about to be deleted.
  Future<void> storageWillClear();

  /// The Backpack value at [key] in [values] is about to change.
  void backpackWillChange(String key, Map<String, dynamic> values);
}

/// The zone value a [SeedRecording] is kept under while a seeder runs.
const Symbol seedRecordingZoneKey = #nyloSeedRecording;

/// The recording of the seeder running in the current zone, if any.
///
/// Always null in release builds.
SeedRecording? get currentSeedRecording {
  if (kReleaseMode) return null;
  final Object? recording = Zone.current[seedRecordingZoneKey];
  return recording is SeedRecording ? recording : null;
}
