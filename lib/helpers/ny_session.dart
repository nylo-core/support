import '/local_storage/local_storage.dart';
import 'backpack.dart';

/// Create a new session
NySession session(String name, [Map<String, dynamic> items = const {}]) {
  NySession nySession = NySession(name: name);
  if (items.isNotEmpty) {
    for (MapEntry key in items.entries) {
      nySession.add(key.key, key.value);
    }
  }
  return nySession;
}

class NySession {
  String name;

  NySession({required this.name});

  /// Add a value to the session
  NySession add(String key, dynamic value) {
    Backpack.instance.sessionUpdate(name, key, value);
    return this;
  }

  /// Set a value in the session
  NySession set(String key, dynamic value) {
    return add(key, value);
  }

  /// Get a value from the session
  T? get<T>(String key) {
    return Backpack.instance.sessionGet<T>(name, key);
  }

  /// Delete a value from the session
  NySession delete(String key) {
    Backpack.instance.sessionRemove(name, key);
    return this;
  }

  /// Clear the session
  NySession flush() {
    Backpack.instance.sessionFlush(name);
    return this;
  }

  /// Clear the session
  NySession clear() {
    return flush();
  }

  /// Get all the session data
  Map<String, dynamic>? data([String? key]) {
    Map<String, dynamic>? sessionData = Backpack.instance.sessionData(name);
    if (key != null) {
      return {key: sessionData?[key]};
    }
    return sessionData;
  }

  /// Sync to Storage
  Future syncToStorage() async {
    Map<String, dynamic>? sessionData = data();
    if (sessionData == null) {
      return;
    }
    await NyStorage.saveJson("${name}_session", sessionData);
  }

  /// Sync from Storage
  Future syncFromStorage() async {
    final sessionData = await NyStorage.readJson("${name}_session");
    if (sessionData == null) {
      return;
    }
    for (MapEntry key in sessionData.entries) {
      add(key.key, key.value);
    }
  }
}
