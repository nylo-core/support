import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Storage service for theme persistence.
///
/// Uses [FlutterSecureStorage] for storing theme preferences.
/// Includes migration logic from [SharedPreferences] (used by theme_provider).
class NyThemeStorage {
  /// Secure storage instance.
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Storage keys.
  static const String _themeIdKey = 'ny_theme_id';
  static const String _followSystemKey = 'ny_theme_follow_system';
  static const String _migrationCompleteKey = 'ny_theme_migration_complete';
  static const String _preferredLightThemeIdKey = 'ny_preferred_light_theme_id';
  static const String _preferredDarkThemeIdKey = 'ny_preferred_dark_theme_id';

  /// Save the current theme ID.
  Future<void> saveThemeId(String themeId) async {
    await _secureStorage.write(key: _themeIdKey, value: themeId);
  }

  /// Read the saved theme ID.
  Future<String?> readThemeId() async {
    return await _secureStorage.read(key: _themeIdKey);
  }

  /// Save the follow system theme preference.
  Future<void> saveFollowSystem(bool follow) async {
    await _secureStorage.write(key: _followSystemKey, value: follow.toString());
  }

  /// Read the follow system theme preference.
  Future<bool?> readFollowSystem() async {
    final value = await _secureStorage.read(key: _followSystemKey);
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }

  /// Save the preferred light theme ID.
  Future<void> savePreferredLightThemeId(String themeId) async {
    await _secureStorage.write(key: _preferredLightThemeIdKey, value: themeId);
  }

  /// Read the preferred light theme ID.
  Future<String?> readPreferredLightThemeId() async {
    return await _secureStorage.read(key: _preferredLightThemeIdKey);
  }

  /// Save the preferred dark theme ID.
  Future<void> savePreferredDarkThemeId(String themeId) async {
    await _secureStorage.write(key: _preferredDarkThemeIdKey, value: themeId);
  }

  /// Read the preferred dark theme ID.
  Future<String?> readPreferredDarkThemeId() async {
    return await _secureStorage.read(key: _preferredDarkThemeIdKey);
  }

  /// Clear all theme storage data.
  Future<void> clear() async {
    await _secureStorage.delete(key: _themeIdKey);
    await _secureStorage.delete(key: _followSystemKey);
    await _secureStorage.delete(key: _preferredLightThemeIdKey);
    await _secureStorage.delete(key: _preferredDarkThemeIdKey);
  }

  /// Clear all theme storage data including migration flag.
  /// Useful for testing and development.
  Future<void> clearAll() async {
    await clear();
    await _secureStorage.delete(key: _migrationCompleteKey);
  }

  /// Delete migration flag (useful for testing).
  Future<void> resetMigration() async {
    await _secureStorage.delete(key: _migrationCompleteKey);
  }
}
