import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '/helpers/ny_helpers.dart';
import '/local_storage/ny_local_storage.dart';
import '/nylo.dart';
import 'live_exception.dart';
import 'live_output.dart';
import 'seed_zone.dart';
import 'seeder.dart';
import 'storage_snapshot.dart';

/// What happened when a seeder ran up or down.
class SeedRun {
  /// Creates a run of the seeder [name] in [direction] (`up` or `down`).
  ///
  /// Everything added to the run is also added to [parent], so a seeder that
  /// runs other seeders shows their changes too.
  SeedRun(this.name, this.direction, {SeedRun? parent}) : _parent = parent;

  /// The seeder's name, e.g. `demo_user`.
  final String name;

  /// `up` or `down`.
  final String direction;

  final SeedRun? _parent;
  final List<Map<String, String>> _log = [];
  final Stopwatch _stopwatch = Stopwatch()..start();
  int? _ms;

  /// Why the run failed, or null when it succeeded.
  String? error;

  /// Whether the run failed.
  bool get failed => error != null;

  /// How long the run took, in milliseconds.
  int get ms => _ms ?? _stopwatch.elapsedMilliseconds;

  /// The changes (entries with `level: change`) and messages, in the order
  /// they happened.
  List<Map<String, String>> get log => [
    for (final Map<String, String> entry in _log)
      if (entry['level'] != 'change' || (entry['change'] ?? '').isNotEmpty)
        entry,
  ];

  /// Adds a change or message to the run.
  void add(Map<String, String> entry) {
    _log.add(entry);
    _parent?.add(entry);
  }

  void _finish() {
    _stopwatch.stop();
    _ms = _stopwatch.elapsedMilliseconds;
  }

  /// The JSON sent to Metro.
  Map<String, Object?> toJson() => {
    'name': name,
    'direction': direction,
    'log': log,
    'ms': ms,
    'failed': failed,
    if (error != null) 'error': error,
  };
}

/// Runs seeders, records what they change, and puts it back.
///
/// `metro live:seed` and [Seeder.seed] use it. While a seeder's `up()` runs,
/// `NyStorage` and `Backpack` report each change to a recording held in the
/// current zone. The record of every seeded seeder is kept in storage under
/// [recordKey], so it survives hot restarts.
class SeedRecorder {
  SeedRecorder._();

  /// The storage key the record of seeded seeders is kept under.
  static const String recordKey = 'ny_seeders';

  static const Symbol _batchZoneKey = #nyloSeedBatch;
  static const Symbol _runZoneKey = #nyloSeedRun;
  static const Symbol _downZoneKey = #nyloSeedDown;

  /// Backpack values from before each seeder ran, by seeder name. Backpack
  /// objects can't be stored as text, so they only last until a restart.
  static final Map<String, Map<String, Object?>> _memory = {};

  static Future<void> _queue = Future<void>.value();

  /// The seeders registered on the running Nylo instance.
  static Map<String, Seeder Function()> get registry =>
      Nylo.isInitialized() ? Nylo.instance.getSeeders() : const {};

  /// Forgets the Backpack values kept in memory, as a restart would.
  @visibleForTesting
  static void forgetBackpackValues() => _memory.clear();

  /// The name [seeder] runs by: its key in the registered seeders, otherwise
  /// its own [Seeder.name], otherwise its class name in snake case without
  /// `Seeder` (`DemoUserSeeder` is `demo_user`).
  static String nameOf(Seeder seeder) {
    for (final MapEntry<String, Seeder Function()> entry in registry.entries) {
      if (entry.value().runtimeType == seeder.runtimeType) return entry.key;
    }
    final String? own = seeder.name?.trim();
    if (own != null && own.isNotEmpty) return own;
    return nameFromClass(seeder.runtimeType.toString());
  }

  /// `DemoUserSeeder`, `DemoUser` and `demo-user` all become `demo_user`.
  static String nameFromClass(String className) {
    String base = className.trim();
    if (base.endsWith('Seeder') && base.length > 'Seeder'.length) {
      base = base.substring(0, base.length - 'Seeder'.length);
    }
    return base
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (Match match) => '${match[1]}_${match[2]}',
        )
        .replaceAllMapped(
          RegExp(r'([A-Z]+)([A-Z][a-z])'),
          (Match match) => '${match[1]}_${match[2]}',
        )
        .replaceAll('-', '_')
        .toLowerCase();
  }

  /// Each registered seeder's name, description and when it was last seeded,
  /// followed by seeders that are still recorded but no longer registered.
  static Future<List<Map<String, Object?>>> list() => _operation((
    _Batch batch,
  ) async {
    final Map<String, Seeder Function()> seeders = registry;
    return [
      for (final MapEntry<String, Seeder Function()> entry in seeders.entries)
        {
          'name': entry.key,
          'description': entry.value().description,
          'seededAt': batch.records[entry.key]?['seededAt'],
          'registered': true,
          if (batch.records[entry.key]?['source'] case final String source)
            'source': source,
        },
      for (final String name in batch.records.keys)
        if (!seeders.containsKey(name))
          {
            'name': name,
            'description': null,
            'seededAt': batch.records[name]?['seededAt'],
            'registered': false,
            if (batch.records[name]?['source'] case final String source)
              'source': source,
          },
    ];
  });

  /// Runs each seeder's `up()` in order, stopping at the first failure.
  ///
  /// A seeder that was already seeded just runs `up()` again. Its record keeps
  /// the values from before its first run, so rolling it back returns to how
  /// the app was before it was ever seeded.
  ///
  /// When [fresh], the first seeder starts by clearing storage and Backpack.
  /// The clearing is recorded, so rolling the seeder back brings the values
  /// back.
  static Future<List<SeedRun>> upAll(
    List<Seeder> seeders, {
    bool fresh = false,
  }) => _operation((_Batch batch) async {
    final List<SeedRun> runs = [];
    for (int i = 0; i < seeders.length; i++) {
      final SeedRun run = await _up(batch, seeders[i], fresh: fresh && i == 0);
      runs.add(run);
      if (run.failed) break;
    }
    return runs;
  });

  /// Runs each seeder's `down()`, last seeder first, stopping at the first
  /// failure.
  static Future<List<SeedRun>> downAll(List<Seeder> seeders) =>
      _operation((_Batch batch) async {
        final List<SeedRun> runs = [];
        for (final Seeder seeder in seeders.reversed) {
          final SeedRun run = await _down(batch, seeder);
          runs.add(run);
          if (run.failed) break;
        }
        return runs;
      });

  /// Runs the seeders named [names] in [direction]: `up` or `down`.
  ///
  /// Names can also be written as class names (`DemoUserSeeder`). Seeders
  /// that are recorded but no longer registered can still be rolled back.
  /// Throws a [LiveException] for a name that matches nothing.
  static Future<List<SeedRun>> runNamed(
    List<String> names, {
    required String direction,
    bool fresh = false,
  }) => _operation((_Batch batch) async {
    if (direction != 'up' && direction != 'down') {
      throw LiveException.invalidParams(
        '"direction" must be up or down, not "$direction".',
      );
    }
    final Map<String, Seeder Function()> seeders = registry;
    final List<String> resolved = [];
    for (final String name in names) {
      String? match = seeders.containsKey(name) ? name : null;
      final String normalized = nameFromClass(name);
      if (match == null && seeders.containsKey(normalized)) match = normalized;
      if (match == null && direction == 'down') {
        if (batch.records.containsKey(name)) match = name;
        if (batch.records.containsKey(normalized)) match = normalized;
      }
      if (match == null) {
        throw LiveException(
          'No seeder named "$name" is registered in this build. Create it with '
          'metro make:seeder $normalized, then hot restart.'
          '${seeders.isEmpty ? '' : ' Registered: ${seeders.keys.join(', ')}.'}',
        );
      }
      resolved.add(match);
    }

    final List<SeedRun> runs = [];
    if (direction == 'down') {
      for (final String name in resolved.reversed) {
        final Seeder? seeder = seeders[name]?.call();
        final SeedRun run;
        if (seeder != null) {
          run = await _down(batch, seeder);
        } else {
          run = SeedRun(name, 'down');
          await _restoreRecord(batch, name, run);
          run._finish();
        }
        runs.add(run);
        if (run.failed) return runs;
      }
      return runs;
    }
    for (int i = 0; i < resolved.length; i++) {
      final SeedRun run = await _up(
        batch,
        seeders[resolved[i]]!(),
        fresh: fresh && i == 0,
      );
      runs.add(run);
      if (run.failed) return runs;
    }
    return runs;
  });

  /// Runs [seeders] from inside another seeder's `up()`, each recorded as its
  /// own run. Throws when one fails, so the parent fails too.
  static Future<void> seedChildren(List<Seeder> seeders) =>
      _operation((_Batch batch) async {
        final bool nested = Zone.current[seedRecordingZoneKey] is _Recording;
        for (final Seeder seeder in seeders) {
          final SeedRun run = await _up(batch, seeder, fresh: false);
          if (run.failed) {
            throw nested
                ? _ChildFailure(run)
                : LiveException('${run.name} failed: ${run.error}');
          }
        }
      });

  /// Puts back everything [seeder] changed when it was seeded.
  ///
  /// Called by `Seeder.restore()`. Inside the seeder's own `down()` it
  /// restores that run; elsewhere it runs on its own.
  static Future<void> restore(Seeder seeder) async {
    final String name = nameOf(seeder);
    final Object? context = Zone.current[_downZoneKey];
    final Object? batch = Zone.current[_batchZoneKey];
    if (context is _DownContext && context.name == name && batch is _Batch) {
      if (context.restored) return;
      context.restored = true;
      await _restoreRecord(batch, name, context.run);
      return;
    }
    await _operation((_Batch batch) async {
      final SeedRun run = SeedRun(name, 'down', parent: _currentRun);
      await _restoreRecord(batch, name, run);
      run._finish();
    });
  }

  // ---------------------------------------------------------------------------
  // Runs
  // ---------------------------------------------------------------------------

  static Future<SeedRun> _up(
    _Batch batch,
    Seeder seeder, {
    required bool fresh,
  }) async {
    final String name = nameOf(seeder);
    final SeedRun run = SeedRun(name, 'up', parent: _currentRun);
    final Object? parentRecording = Zone.current[seedRecordingZoneKey];

    final _Recording recording = _Recording(name, run);
    _ChildRun? child;
    if (parentRecording is _Recording) {
      parentRecording.steps.add({'seeder': name});
      child = _ChildRun(name, recording, batch.records[name], _memory[name]);
      parentRecording.children.add(child);
    }
    Object? failure;
    await runZoned(
      () async {
        try {
          if (fresh) await NyStorage.deleteAll(andFromBackpack: true);
          await seeder.up();
        } catch (error) {
          failure = error;
        }
      },
      zoneValues: {
        seedRecordingZoneKey: recording,
        _runZoneKey: run,
        _downZoneKey: null,
        liveOutputZoneKey: run.add,
      },
    );
    await recording.finish();

    final Object? error = failure;
    if (error != null) {
      if (error is _ChildFailure) {
        run.error = error.toString();
      } else {
        run.error = _describe(error);
        run.add(_message('error', run.error!));
      }
      // up() may have cleared storage, seeder records included.
      batch.dirty = true;
      final int restored = await _restoreSteps(
        batch,
        recording.steps,
        recording.backpackBefore,
        run,
        log: false,
        children: recording.children,
      );
      if (restored > 0) {
        run.add(
          _message(
            'info',
            'Put back the ${restored == 1 ? 'change' : '$restored changes'} '
                'made before the error',
          ),
        );
      }
      run._finish();
      return run;
    }

    _record(
      batch,
      name,
      recording,
      source: seeder is SnapshotSeeder ? seeder.source : null,
    );
    child?.succeeded = true;
    run._finish();
    return run;
  }

  /// Saves what [recording] changed as the record of [name].
  ///
  /// When [name] was already seeded, the record keeps the values from before
  /// its first run and only adds the values this run changed for the first
  /// time, so rolling back returns to how the app was before any run.
  ///
  /// [source] is where an imported snapshot came from, kept for
  /// `seeders.list`.
  static void _record(
    _Batch batch,
    String name,
    _Recording recording, {
    String? source,
  }) {
    final Object? earlier = batch.records[name]?['steps'];
    final List<Object?> steps = [if (earlier is List) ...earlier];
    final Set<String> recorded = {
      for (final Object? step in steps)
        if (step is Map) _stepKey(step),
    };
    final Map<String, Object?> backpackBefore = {..._memory[name] ?? const {}};
    for (final Map<String, Object?> step in recording.steps) {
      if (!recorded.add(_stepKey(step))) continue;
      steps.add(step);
      final Object? key = step['backpack'];
      if (key is String && recording.backpackBefore.containsKey(key)) {
        backpackBefore[key] = recording.backpackBefore[key];
      }
    }
    batch.records[name] = {
      'seededAt': DateTime.now().toUtc().toIso8601String(),
      'steps': steps,
      if (source != null) 'source': source,
    };
    _memory[name] = backpackBefore;
    batch.dirty = true;
  }

  /// What a record step is about: `storage:<key>`, `backpack:<key>` or
  /// `seeder:<name>`.
  static String _stepKey(Map<Object?, Object?> step) =>
      step.containsKey('storage')
      ? 'storage:${step['storage']}'
      : step.containsKey('backpack')
      ? 'backpack:${step['backpack']}'
      : 'seeder:${step['seeder']}';

  static Future<SeedRun> _down(_Batch batch, Seeder seeder) async {
    final String name = nameOf(seeder);
    final SeedRun run = SeedRun(name, 'down', parent: _currentRun);
    final _DownContext context = _DownContext(name, run);
    Object? failure;
    await runZoned(
      () async {
        try {
          await seeder.down();
        } catch (error) {
          failure = error;
        }
      },
      zoneValues: {
        seedRecordingZoneKey: null,
        _runZoneKey: run,
        _downZoneKey: context,
        liveOutputZoneKey: run.add,
      },
    );

    final Object? error = failure;
    if (error != null) {
      run.error = _describe(error);
      run.add(_message('error', run.error!));
    } else if (!context.restored && batch.records.remove(name) != null) {
      _memory.remove(name);
      batch.dirty = true;
      run.add(
        _message(
          'warning',
          'down() didn\'t call restore(), so the values $name changed were '
              'left as they are',
        ),
      );
    }
    run._finish();
    return run;
  }

  // ---------------------------------------------------------------------------
  // Restoring
  // ---------------------------------------------------------------------------

  static Future<void> _restoreRecord(
    _Batch batch,
    String name,
    SeedRun run,
  ) async {
    final Map<String, Object?>? record = batch.records[name];
    if (record == null) {
      run.add(
        _message(
          'info',
          'Nothing to put back: $name hasn\'t been seeded on this device',
        ),
      );
      return;
    }
    final Object? steps = record['steps'];
    await _restoreSteps(
      batch,
      steps is List ? steps : const [],
      _memory[name],
      run,
    );
    batch.records.remove(name);
    _memory.remove(name);
    batch.dirty = true;
  }

  /// Undoes [steps] newest first and returns how many values changed.
  ///
  /// [memory] holds the Backpack values from before the run, or is null when
  /// the app restarted since. A Backpack value that is also in storage is
  /// then reloaded from the restored storage, as `syncKeys` does at startup.
  ///
  /// Seeders run inside this one are rolled back in full, or, when
  /// [children] holds their runs from a run that failed, only what they
  /// changed in that run.
  static Future<int> _restoreSteps(
    _Batch batch,
    List<Object?> steps,
    Map<String, Object?>? memory,
    SeedRun run, {
    bool log = true,
    List<_ChildRun>? children,
  }) {
    return runZoned(() async {
      final Backpack backpack = Backpack.instance;
      final Set<String> storageKeys = {
        for (final Object? step in steps)
          if (step is Map && step['storage'] is String)
            step['storage'] as String,
      };
      final List<String> reload = [];
      int count = 0;

      void changed(String store, String key, String change) {
        count++;
        if (log) run.add(_changeEntry(store, key, change));
      }

      for (final Object? step in steps.reversed) {
        if (step is! Map) continue;
        final Object? child = step['seeder'];
        final Object? storageKey = step['storage'];
        final Object? backpackKey = step['backpack'];

        if (child is String) {
          if (children != null) {
            final _ChildRun? childRun = children.isEmpty
                ? null
                : children.removeLast();
            if (childRun != null && childRun.succeeded) {
              count += await _undoChildRun(batch, childRun, run);
            }
            continue;
          }
          if (!batch.records.containsKey(child)) continue;
          final Seeder? seeder = registry[child]?.call();
          if (seeder == null) {
            await _restoreRecord(batch, child, run);
          } else {
            await _down(batch, seeder);
          }
        } else if (storageKey is String) {
          final Object? before = step['before'];
          final String? now = await NyStorage.manager().read(key: storageKey);
          if (before is String) {
            if (now == before) continue;
            await NyStorage.manager().write(key: storageKey, value: before);
            changed('storage', storageKey, 'restored');
          } else if (now != null) {
            await NyStorage.manager().delete(key: storageKey);
            changed('storage', storageKey, 'removed');
          }
        } else if (backpackKey is String) {
          if (step['existed'] != true) {
            if (!backpack.contains(backpackKey)) continue;
            backpack.delete(backpackKey);
            changed('backpack', backpackKey, 'removed');
          } else if (memory != null && memory.containsKey(backpackKey)) {
            final Object? before = memory[backpackKey];
            if (backpack.contains(backpackKey) &&
                _same(before, backpack.read<dynamic>(backpackKey))) {
              continue;
            }
            backpack.save(backpackKey, before);
            changed('backpack', backpackKey, 'restored');
          } else if (storageKeys.contains(backpackKey)) {
            reload.add(backpackKey);
          } else {
            run.add(
              _message(
                'warning',
                'Couldn\'t put back Backpack "$backpackKey" because the app '
                    'restarted after it was seeded',
              ),
            );
          }
        }
      }

      for (final String key in reload) {
        if (await NyStorage.manager().read(key: key) == null) {
          if (!backpack.contains(key)) continue;
          backpack.delete(key);
          changed('backpack', key, 'removed');
        } else {
          backpack.save(key, await NyStorage.read(key));
          changed('backpack', key, 'restored');
        }
      }
      return count;
    }, zoneValues: {seedRecordingZoneKey: null});
  }

  /// Undoes what [child] changed in a run whose parent then failed, and puts
  /// its record back to how it was before that run.
  static Future<int> _undoChildRun(
    _Batch batch,
    _ChildRun child,
    SeedRun run,
  ) async {
    final int count = await _restoreSteps(
      batch,
      child.recording.steps,
      child.recording.backpackBefore,
      run,
      log: false,
      children: child.recording.children,
    );
    final Map<String, Object?>? record = child.record;
    if (record == null) {
      batch.records.remove(child.name);
    } else {
      batch.records[child.name] = record;
    }
    final Map<String, Object?>? memory = child.memory;
    if (memory == null) {
      _memory.remove(child.name);
    } else {
      _memory[child.name] = memory;
    }
    return count;
  }

  // ---------------------------------------------------------------------------
  // Operations and records
  // ---------------------------------------------------------------------------

  /// Runs [action] with the seeder records, one operation at a time, and
  /// saves the records afterwards when they changed. Nested calls share the
  /// operation they're part of.
  static Future<T> _operation<T>(Future<T> Function(_Batch batch) action) {
    final Object? current = Zone.current[_batchZoneKey];
    if (current is _Batch) return action(current);

    final Completer<T> result = Completer<T>();
    _queue = _queue.then((_) async {
      _Batch? batch;
      try {
        final _Batch loaded = _Batch(await _loadRecords());
        batch = loaded;
        final T value = await runZoned(
          () => action(loaded),
          zoneValues: {_batchZoneKey: loaded},
        );
        result.complete(value);
      } catch (error, stackTrace) {
        result.completeError(error, stackTrace);
      } finally {
        if (batch != null && batch.dirty) await _saveRecords(batch.records);
      }
    });
    return result.future;
  }

  static Future<Map<String, Map<String, Object?>>> _loadRecords() async {
    final String? raw = await NyStorage.manager().read(key: recordKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      return {
        for (final MapEntry<Object?, Object?> entry in decoded.entries)
          if (entry.key is String && entry.value is Map)
            entry.key as String: Map<String, Object?>.from(entry.value as Map),
      };
    } on FormatException {
      return {};
    }
  }

  static Future<void> _saveRecords(
    Map<String, Map<String, Object?>> records,
  ) async {
    if (records.isEmpty) {
      await NyStorage.manager().delete(key: recordKey);
    } else {
      await NyStorage.manager().write(
        key: recordKey,
        value: jsonEncode(records),
      );
    }
  }

  static SeedRun? get _currentRun {
    final Object? run = Zone.current[_runZoneKey];
    return run is SeedRun ? run : null;
  }

  static String _describe(Object error) =>
      error is LiveException ? error.message : error.toString();
}

/// The records of every seeded seeder, loaded once per operation.
class _Batch {
  _Batch(this.records);

  final Map<String, Map<String, Object?>> records;
  bool dirty = false;
}

/// The seeder whose `down()` is running, so `restore()` knows what to undo.
class _DownContext {
  _DownContext(this.name, this.run);

  final String name;
  final SeedRun run;
  bool restored = false;
}

/// A seeder run from inside another seeder's `up()`, with its record and
/// Backpack values from before the run.
class _ChildRun {
  _ChildRun(this.name, this.recording, this.record, this.memory);

  final String name;
  final _Recording recording;
  final Map<String, Object?>? record;
  final Map<String, Object?>? memory;

  /// Whether the run finished, so its changes were added to its record.
  bool succeeded = false;
}

/// A seeder run from inside another seeder failed.
class _ChildFailure implements Exception {
  _ChildFailure(this.run);

  final SeedRun run;

  @override
  String toString() => '${run.name} failed: ${run.error}';
}

/// A change noted during a run, worked out once the run finishes.
class _Pending {
  _Pending(
    this.store,
    this.key,
    this.entry, {
    this.before,
    this.existed = false,
  });

  final String store;
  final String key;
  final Map<String, String> entry;
  final String? before;
  final bool existed;
}

/// Records the first change to each key while a seeder's `up()` runs.
class _Recording implements SeedRecording {
  _Recording(this.name, this.run);

  final String name;
  final SeedRun run;

  /// What to undo, oldest first, as stored in the record.
  final List<Map<String, Object?>> steps = [];

  /// Backpack values from before the run.
  final Map<String, Object?> backpackBefore = {};

  /// Seeders run inside this one, in the order they ran.
  final List<_ChildRun> children = [];

  final Set<String> _storageKeys = {};
  final Set<String> _backpackKeys = {};
  final List<_Pending> _pending = [];

  @override
  Future<void> storageWillChange(String key) async {
    if (key == SeedRecorder.recordKey || !_storageKeys.add(key)) return;
    _addStorage(key, await NyStorage.manager().read(key: key));
  }

  @override
  Future<void> storageWillClear() async {
    final Map<String, String> values = await NyStorage.manager().readAll();
    for (final MapEntry<String, String> entry in values.entries) {
      if (entry.key == SeedRecorder.recordKey) continue;
      if (!_storageKeys.add(entry.key)) continue;
      _addStorage(entry.key, entry.value);
    }
  }

  void _addStorage(String key, String? before) {
    steps.add({'storage': key, 'before': before});
    final Map<String, String> entry = _changeEntry('storage', key, '');
    run.add(entry);
    _pending.add(
      _Pending('storage', key, entry, before: before, existed: before != null),
    );
  }

  @override
  void backpackWillChange(String key, Map<String, dynamic> values) {
    if (!_backpackKeys.add(key)) return;
    final bool existed = values.containsKey(key);
    steps.add({'backpack': key, 'existed': existed});
    if (existed) backpackBefore[key] = _copy(values[key]);
    final Map<String, String> entry = _changeEntry('backpack', key, '');
    run.add(entry);
    _pending.add(_Pending('backpack', key, entry, existed: existed));
  }

  /// Works out whether each recorded value was added, changed or removed.
  Future<void> finish() async {
    for (final _Pending pending in _pending) {
      final bool exists;
      final bool same;
      if (pending.store == 'storage') {
        final String? now = await NyStorage.manager().read(key: pending.key);
        exists = now != null;
        same = now == pending.before;
      } else {
        exists = Backpack.instance.contains(pending.key);
        same =
            exists &&
            _same(
              backpackBefore[pending.key],
              Backpack.instance.read<dynamic>(pending.key),
            );
      }
      final String change = !pending.existed
          ? (exists ? 'added' : '')
          : (!exists ? 'removed' : (same ? '' : 'changed'));
      _setChange(pending.entry, change);
    }
  }
}

Map<String, String> _message(String level, String message) => {
  'level': level,
  'message': message,
};

Map<String, String> _changeEntry(String store, String key, String change) {
  final Map<String, String> entry = {
    'level': 'change',
    'store': store,
    'key': key,
  };
  _setChange(entry, change);
  return entry;
}

void _setChange(Map<String, String> entry, String change) {
  entry['change'] = change;
  final String verb = change == 'restored' ? 'put back' : change;
  entry['message'] = '${entry['store']} ${entry['key']} $verb'.trimRight();
}

/// A copy of Backpack maps and lists, so changes made in place are noticed.
Object? _copy(Object? value) {
  if (value is Map<String, dynamic>) return Map<String, dynamic>.of(value);
  if (value is Map) return Map<Object?, Object?>.of(value);
  if (value is List<String>) return List<String>.of(value);
  if (value is List) return List<Object?>.of(value);
  return value;
}

bool _same(Object? a, Object? b) {
  if (identical(a, b)) return true;
  try {
    return jsonEncode(a) == jsonEncode(b);
  } catch (_) {
    return a == b;
  }
}
