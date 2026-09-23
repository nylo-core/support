import 'dart:convert';

import '/helpers/ny_helpers.dart';
import '/local_storage/ny_local_storage.dart';
import '/nylo.dart';
import '/testing/src/ny_time.dart';
import 'live_exception.dart';
import 'seed_recorder.dart';
import 'seed_zone.dart';
import 'seeder.dart';

/// What an app holds in `NyStorage` and `Backpack`, in a form that can be
/// kept in a file or a seeder and put back into an app.
///
/// `export` in `metro live` takes one with [capture]; `seed <file>` and an
/// exported seeder's `importSnapshot()` put it back with [apply].
///
/// Storage values are written the way Dart types them: `7`, `1.5`, `true`,
/// `'Jane'`, `null`, or a map or list for JSON. A value is written as
/// `{'type': ..., 'value': ...}` only when the literal alone can't rebuild
/// the storage envelope Nylo keeps it in:
///
/// - `model` for a saved `Model`, so `NyStorage.read<User>()` still decodes it
/// - `raw` for a value Nylo didn't write as an envelope, put back byte for byte
/// - a `ttl` (seconds left) for a value that expires
/// - `json` for a JSON object that has a `type` key of its own
///
/// Backpack values are written as JSON. An object is tagged with its class
/// name - every `Model`, and every other class the app registered a model
/// decoder for - and [apply] rebuilds it through that decoder, so
/// `Backpack.read<User>()` gets a `User` back and not the map it was written
/// from.
class StorageSnapshot {
  /// Creates a snapshot of [storage] and [backpack] values.
  const StorageSnapshot({
    this.storage = const {},
    this.backpack = const {},
    this.skipped = const [],
  });

  /// The version of the snapshot format, written as `nylo` by [toJson].
  static const int formatVersion = 1;

  /// The type names a tagged storage value can have.
  static const Set<String> storageTypes = {
    'int',
    'double',
    'bool',
    'string',
    'null',
    'json',
    'model',
    'raw',
  };

  static const Set<String> _storageInternal = {SeedRecorder.recordKey};
  static const Set<String> _backpackInternal = {'nylo', 'event_bus'};
  static const Set<String> _tagKeys = {'type', 'value', 'ttl'};
  static const Object _notJson = Object();

  /// The storage values, by key.
  final Map<String, Object?> storage;

  /// The Backpack values, by key.
  final Map<String, Object?> backpack;

  /// What [capture] left out, each as `{store, key, reason}`.
  final List<Map<String, String>> skipped;

  /// How many values the snapshot holds.
  int get length => storage.length + backpack.length;

  /// Whether the snapshot holds nothing.
  bool get isEmpty => storage.isEmpty && backpack.isEmpty;

  /// The snapshot as JSON: `{nylo, storage, backpack}`.
  Map<String, Object?> toJson() => {
    'nylo': formatVersion,
    'storage': storage,
    'backpack': backpack,
  };

  /// Reads a snapshot from [json], as written by [toJson] or held by an
  /// exported seeder. Only `storage` and `backpack` are read; both are
  /// optional.
  ///
  /// Throws a [LiveException] when a value can't be put into storage.
  factory StorageSnapshot.fromJson(Map<Object?, Object?> json) {
    final Map<String, Object?> storage = _stringKeyed(
      json['storage'],
      'storage',
    );
    final Map<String, Object?> backpack = _stringKeyed(
      json['backpack'],
      'backpack',
    );
    storage.forEach(_validateStorageEntry);
    backpack.forEach(_validateBackpackEntry);
    return StorageSnapshot(storage: storage, backpack: backpack);
  }

  // ---------------------------------------------------------------------------
  // Capture
  // ---------------------------------------------------------------------------

  /// Reads every storage and Backpack value from the running app.
  ///
  /// [only] keeps just the keys matching one of its patterns, and [except]
  /// drops the keys matching one of its patterns; `*` matches anything, so
  /// `cache_*` covers every cache key. Pass [backpack] false to leave
  /// Backpack out.
  ///
  /// Nylo's own seeder record, expired values and Backpack values that can't
  /// be written as JSON are left out and listed in [skipped].
  static Future<StorageSnapshot> capture({
    List<String> only = const [],
    List<String> except = const [],
    bool backpack = true,
  }) async {
    bool wanted(String key) =>
        (only.isEmpty || _matchesAny(key, only)) && !_matchesAny(key, except);

    final Map<String, Object?> storage = {};
    final List<Map<String, String>> skipped = [];
    final int now = NyTime.now().millisecondsSinceEpoch;
    final Map<String, String> values = await NyStorage.manager().readAll();
    final List<String> keys = values.keys.toList()..sort();
    for (final String key in keys) {
      if (_storageInternal.contains(key) || !wanted(key)) continue;
      final String raw = values[key]!;
      final _Envelope? envelope = _Envelope.parse(raw);
      if (envelope == null) {
        storage[key] = {'type': 'raw', 'value': raw};
        continue;
      }
      int? ttl;
      final int? expiresAt = envelope.expiresAt;
      if (expiresAt != null) {
        if (expiresAt <= now) {
          skipped.add({'store': 'storage', 'key': key, 'reason': 'expired'});
          continue;
        }
        ttl = ((expiresAt - now) / 1000).ceil();
      }
      storage[key] = _literal(envelope, raw, ttl);
    }

    final Map<String, Object?> values2 = {};
    if (backpack) {
      final Backpack bag = Backpack.instance;
      final List<String> bagKeys = bag.keys.toList()..sort();
      for (final String key in bagKeys) {
        if (_backpackInternal.contains(key) || !wanted(key)) continue;
        final dynamic value = bag.read<dynamic>(key);
        final Object? written = _backpackLiteral(value);
        if (identical(written, _notJson)) {
          skipped.add({
            'store': 'backpack',
            'key': key,
            'reason': '${value.runtimeType} can\'t be written as JSON',
          });
          continue;
        }
        values2[key] = written;
      }
    }
    return StorageSnapshot(
      storage: storage,
      backpack: values2,
      skipped: skipped,
    );
  }

  /// The literal for a storage [envelope]: plain when Dart's type says
  /// enough, tagged otherwise. [raw] is written back as `raw` when the
  /// envelope can't be read.
  static Object? _literal(_Envelope envelope, String raw, int? ttl) {
    final String type = envelope.type.toLowerCase();
    final String data = envelope.data;
    Object? value;
    bool plain = true;
    switch (type) {
      case 'int':
        value = int.tryParse(data);
        if (value == null) return {'type': 'raw', 'value': raw};
      case 'double':
        value = double.tryParse(data);
        if (value == null) return {'type': 'raw', 'value': raw};
      case 'bool':
        if (data != 'true' && data != 'false') {
          return {'type': 'raw', 'value': raw};
        }
        value = data == 'true';
      case 'null':
        value = null;
      case 'string':
        value = data;
      case 'json':
        try {
          value = jsonDecode(data);
        } on FormatException {
          return {'type': 'raw', 'value': raw};
        }
        // A JSON object with a type key would read as a tag.
        if (value is Map && value.containsKey('type')) plain = false;
      case 'model':
        try {
          value = jsonDecode(data);
        } on FormatException {
          return {'type': 'raw', 'value': raw};
        }
        if (value is! Map) return {'type': 'raw', 'value': raw};
        plain = false;
      default:
        return {'type': 'raw', 'value': raw};
    }
    if (plain && ttl == null) return value;
    return {'type': type, 'value': value, if (ttl != null) 'ttl': ttl};
  }

  /// A Backpack [value] as JSON, with objects tagged by class name, or
  /// [_notJson] when it can't be written.
  static Object? _backpackLiteral(Object? value) {
    final String? className = _taggableName(value);
    if (className != null) {
      final Object? json = _jsonSafe(_toJsonOrNull(value));
      if (identical(json, _notJson) || json is! Map) return _notJson;
      return {'type': 'model', 'model': className, 'value': json};
    }
    if (value is List && value.isNotEmpty) {
      final String? itemName = _taggableName(value.first);
      if (itemName != null &&
          value.every((dynamic item) => _taggableName(item) == itemName)) {
        final List<Object?> items = [];
        for (final dynamic item in value) {
          final Object? json = _jsonSafe(_toJsonOrNull(item));
          if (identical(json, _notJson) || json is! Map) return _notJson;
          items.add(json);
        }
        return {'type': 'models', 'model': itemName, 'value': items};
      }
    }
    return _jsonSafe(value);
  }

  /// The class name to tag [value] with, or null to write it as plain JSON.
  ///
  /// A [Model] is always tagged, and so is any other class the app registered
  /// a model decoder for - `Backpack.read<T>()` decodes both, so a snapshot
  /// that dropped the name would put a plain map where the app expects its
  /// own object.
  static String? _taggableName(Object? value) {
    if (value == null ||
        value is bool ||
        value is num ||
        value is String ||
        value is Map ||
        value is Iterable) {
      return null;
    }
    final String name = value.runtimeType.toString();
    if (value is Model) return name;
    return _decoderNamed(name) == null ? null : name;
  }

  static Object? _toJsonOrNull(Object? value) {
    try {
      return (value as dynamic).toJson();
    } catch (_) {
      return _notJson;
    }
  }

  /// [value] as something `jsonEncode` accepts, or [_notJson].
  static Object? _jsonSafe(Object? value, [int depth = 0]) {
    if (identical(value, _notJson)) return _notJson;
    if (value == null || value is bool || value is String) return value;
    if (value is num) return value.isFinite ? value : value.toString();
    if (depth > 12) return _notJson;
    if (value is Map) {
      final Map<String, Object?> out = {};
      for (final MapEntry<dynamic, dynamic> entry in value.entries) {
        final Object? item = _jsonSafe(entry.value, depth + 1);
        if (identical(item, _notJson)) return _notJson;
        out['${entry.key}'] = item;
      }
      return out;
    }
    if (value is Iterable) {
      final List<Object?> out = [];
      for (final dynamic element in value) {
        final Object? item = _jsonSafe(element, depth + 1);
        if (identical(item, _notJson)) return _notJson;
        out.add(item);
      }
      return out;
    }
    if (value is DateTime) return value.toIso8601String();
    if (value is Duration) return value.inMilliseconds;
    if (value is Enum) return value.name;
    if (value is Model) return _jsonSafe(_toJsonOrNull(value), depth + 1);
    try {
      return _jsonSafe((value as dynamic).toJson(), depth + 1);
    } catch (_) {
      return _notJson;
    }
  }

  // ---------------------------------------------------------------------------
  // Apply
  // ---------------------------------------------------------------------------

  /// Writes every value into storage and Backpack, and returns how many were
  /// written.
  ///
  /// Inside a seeder each write is recorded, so `restore()` puts the old
  /// values back. Nylo's own seeder record and the Backpack `nylo` and
  /// `event_bus` entries are never written.
  Future<int> apply() async {
    int count = 0;
    final int now = NyTime.now().millisecondsSinceEpoch;
    for (final MapEntry<String, Object?> entry in storage.entries) {
      if (_storageInternal.contains(entry.key)) continue;
      final String raw = _envelopeFor(entry.key, entry.value, now);
      // The same two steps as NyStorage._write, so the seed recorder sees it.
      await currentSeedRecording?.storageWillChange(entry.key);
      await NyStorage.manager().write(key: entry.key, value: raw);
      count++;
    }
    for (final MapEntry<String, Object?> entry in backpack.entries) {
      if (_backpackInternal.contains(entry.key)) continue;
      // An exported seeder holds a const map; Backpack values get changed in
      // place (sessions, append), so they must be ordinary maps and lists.
      final Object? value = _mutableCopy(entry.value);
      Backpack.instance.save(entry.key, _rebuild(entry.key, value));
      count++;
    }
    return count;
  }

  /// [value] with every map and list copied into a new, growable one.
  static Object? _mutableCopy(Object? value) {
    if (value is Map) {
      return <String, dynamic>{
        for (final MapEntry<Object?, Object?> entry in value.entries)
          '${entry.key}': _mutableCopy(entry.value),
      };
    }
    if (value is List)
      return <dynamic>[for (final Object? item in value) _mutableCopy(item)];
    return value;
  }

  /// The raw storage string for [entry] at [key].
  static String _envelopeFor(String key, Object? entry, int now) {
    final _Tagged tagged = _untag(entry);
    if (tagged.type == 'raw') return '${tagged.value}';
    final String data;
    try {
      data = switch (tagged.type) {
        'json' || 'model' => jsonEncode(tagged.value),
        _ => '${tagged.value}',
      };
    } on JsonUnsupportedObjectError catch (e) {
      throw LiveException(
        'Storage "$key" holds a value that can\'t be written as JSON: '
        '${e.unsupportedObject.runtimeType}.',
      );
    }
    final int? ttl = tagged.ttl;
    return jsonEncode({
      '_v': 'v1',
      '_t': _envelopeType(tagged.type),
      '_d': data,
      if (ttl != null) '_e': now + ttl * 1000,
    });
  }

  /// The `_t` NyStorage writes for a tagged [type].
  static String _envelopeType(String type) => switch (type) {
    'string' => 'String',
    'null' => 'Null',
    _ => type,
  };

  /// The type, value and ttl of a storage [entry], reading its tag or its
  /// Dart type.
  static _Tagged _untag(Object? entry) {
    if (_isTagged(entry)) {
      final Map<Object?, Object?> map = entry as Map;
      final Object? ttl = map['ttl'];
      return _Tagged(
        '${map['type']}'.toLowerCase(),
        map['value'],
        ttl is num ? ttl.ceil() : null,
      );
    }
    return _Tagged(
      switch (entry) {
        int() => 'int',
        double() => 'double',
        bool() => 'bool',
        String() => 'string',
        null => 'null',
        _ => 'json',
      },
      entry,
      null,
    );
  }

  static bool _isTagged(Object? entry) =>
      entry is Map &&
      entry['type'] is String &&
      entry.keys.every((Object? key) => _tagKeys.contains(key));

  /// A Backpack [entry] with a model tag rebuilt as the app's own object,
  /// when a decoder for that class name is registered.
  static Object? _rebuild(String key, Object? entry) {
    if (!_isBackpackModel(entry)) return entry;
    final Map<Object?, Object?> map = entry as Map;
    final String className = '${map['model']}';
    final Object? value = map['value'];
    final dynamic Function(dynamic)? decoder = _decoderNamed(className);
    if (decoder == null) return value;
    try {
      if (map['type'] == 'models') {
        return [for (final Object? item in value as List) decoder(item)];
      }
      return decoder(value);
    } catch (e) {
      throw LiveException(
        'Couldn\'t rebuild Backpack "$key" as $className: $e',
      );
    }
  }

  static bool _isBackpackModel(Object? entry) =>
      entry is Map &&
      (entry['type'] == 'model' || entry['type'] == 'models') &&
      entry['model'] is String &&
      entry.containsKey('value');

  /// The model decoder registered for the class named [name], if any.
  static dynamic Function(dynamic)? _decoderNamed(String name) {
    if (!Nylo.isInitialized()) return null;
    for (final MapEntry<Type, dynamic> entry
        in Nylo.instance.getModelDecoders().entries) {
      if (entry.key.toString() == name) {
        return (dynamic data) => entry.value(data);
      }
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Validation and helpers
  // ---------------------------------------------------------------------------

  static Map<String, Object?> _stringKeyed(Object? value, String store) {
    if (value == null) return {};
    if (value is! Map) {
      throw LiveException.invalidParams(
        '"$store" must be a JSON object of values by key.',
      );
    }
    return {
      for (final MapEntry<Object?, Object?> entry in value.entries)
        '${entry.key}': entry.value,
    };
  }

  static void _validateStorageEntry(String key, Object? entry) {
    if (!_isTagged(entry)) return;
    final Map<Object?, Object?> map = entry as Map;
    final String type = '${map['type']}'.toLowerCase();
    if (!storageTypes.contains(type)) {
      throw LiveException.invalidParams(
        'Storage "$key" has an unknown type "${map['type']}". Use one of: '
        '${storageTypes.join(', ')}.',
      );
    }
    final Object? value = map['value'];
    final bool valid = switch (type) {
      'int' => value is int,
      'double' => value is num,
      'bool' => value is bool,
      'string' || 'raw' => value is String,
      'null' => value == null,
      'json' => value is Map || value is List,
      'model' => value is Map,
      _ => true,
    };
    if (!valid) {
      throw LiveException.invalidParams(
        'Storage "$key" is tagged as $type but its value is '
        '${value == null ? 'null' : 'a ${value.runtimeType}'}.',
      );
    }
    final Object? ttl = map['ttl'];
    if (ttl != null && (ttl is! num || ttl <= 0)) {
      throw LiveException.invalidParams(
        'Storage "$key" has a ttl that isn\'t a positive number of seconds.',
      );
    }
  }

  static void _validateBackpackEntry(String key, Object? entry) {
    if (entry is! Map ||
        entry['type'] != 'model' && entry['type'] != 'models') {
      return;
    }
    if (entry['model'] is! String || '${entry['model']}'.isEmpty) {
      return; // Just a value that happens to have a type key.
    }
    final Object? value = entry['value'];
    if (entry['type'] == 'model' ? value is! Map : value is! List) {
      throw LiveException.invalidParams(
        'Backpack "$key" is tagged as a ${entry['model']} '
        '${entry['type']} but its value is '
        '${value == null ? 'null' : 'a ${value.runtimeType}'}.',
      );
    }
  }

  static bool _matchesAny(String key, List<String> patterns) =>
      patterns.any((String pattern) => _matches(key, pattern));

  /// Whether [key] matches [pattern], where `*` matches any run of characters.
  static bool _matches(String key, String pattern) {
    if (!pattern.contains('*')) return key == pattern;
    final String regex = pattern.split('*').map(RegExp.escape).join('.*');
    return RegExp('^$regex\$').hasMatch(key);
  }
}

/// The seeder `seed <file>` runs in `metro live`: puts a snapshot Metro sent
/// into the app, recorded like any other seeder so `seed:rollback` undoes it.
class SnapshotSeeder extends Seeder {
  /// Creates a seeder that applies [snapshot] under [name].
  ///
  /// [source] is where the snapshot came from, such as the file it was read
  /// from. It is kept in the seeder record, so `seed` lists the seeder as
  /// imported from there.
  SnapshotSeeder(this.snapshot, {required String name, this.source})
    : _name = name;

  /// The snapshot to apply.
  final StorageSnapshot snapshot;

  /// Where the snapshot came from, e.g. `pro_user.json`.
  final String? source;

  final String _name;

  @override
  String get name => _name;

  @override
  String get description =>
      source == null ? 'Imported snapshot' : 'Imported from $source';

  @override
  Future<void> up() async {
    final int count = await snapshot.apply();
    success('Imported $count ${count == 1 ? 'value' : 'values'}');
  }
}

/// A storage value's tag: its type, value and time to live in seconds.
class _Tagged {
  const _Tagged(this.type, this.value, this.ttl);

  final String type;
  final Object? value;
  final int? ttl;
}

/// The `{_v, _t, _d, _e}` envelope NyStorage keeps a value in.
class _Envelope {
  const _Envelope(this.type, this.data, this.expiresAt);

  final String type;
  final String data;
  final int? expiresAt;

  static _Envelope? parse(String raw) {
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map &&
          decoded.containsKey('_v') &&
          decoded['_t'] is String &&
          decoded['_d'] is String) {
        final Object? expiresAt = decoded['_e'];
        return _Envelope(
          decoded['_t'] as String,
          decoded['_d'] as String,
          expiresAt is int ? expiresAt : null,
        );
      }
    } catch (_) {
      // Not an envelope.
    }
    return null;
  }
}
