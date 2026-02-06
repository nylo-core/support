import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'base_theme_config.dart';
import 'ny_theme_storage.dart';

/// Singleton class to manage app themes.
///
/// Features:
/// - Reactive theme updates via [themeNotifier]
/// - System theme following with [followSystemTheme]
/// - Theme change stream via [onThemeChanged]
/// - Typed color styles access via [colorStyles]
/// - Multi-theme support with preferred themes for system following
///
/// Example:
/// ```dart
/// // Register themes
/// NyThemeManager.instance.registerThemes(appThemes, initialThemeId: 'light_theme');
///
/// // Change theme (auto-disables followSystemTheme)
/// NyThemeManager.instance.setTheme('dark_theme');
///
/// // Change theme and remember as preferred for its type
/// NyThemeManager.instance.setTheme('dark_amoled', remember: true);
///
/// // Listen to theme changes
/// NyThemeManager.instance.onThemeChanged.listen((themeId) {
///   print('Theme changed to: $themeId');
/// });
///
/// // Get all dark themes
/// final darkThemes = NyThemeManager.instance.darkThemes;
///
/// // Get color styles
/// final colors = NyThemeManager.instance.colorStyles<MyColorStyles>();
/// ```
class NyThemeManager with WidgetsBindingObserver {
  NyThemeManager._internal();

  static final NyThemeManager _instance = NyThemeManager._internal();

  /// Get the singleton instance of [NyThemeManager].
  static NyThemeManager get instance => _instance;

  /// Storage service for theme persistence.
  final NyThemeStorage _storage = NyThemeStorage();

  /// List of registered themes.
  final List<BaseThemeConfig> _themes = [];

  /// ValueNotifier for reactive theme updates.
  ValueNotifier<String> _themeNotifier = ValueNotifier<String>('');

  /// StreamController for theme change events.
  StreamController<String> _themeStreamController =
      StreamController<String>.broadcast();

  /// Whether the app should follow system theme changes.
  bool _followSystemTheme = false;

  /// Whether the manager has been initialized.
  bool _isInitialized = false;

  /// Initial theme ID set during registration.
  String? _initialThemeId;

  /// Preferred light theme ID for system theme following.
  String? _preferredLightThemeId;

  /// Preferred dark theme ID for system theme following.
  String? _preferredDarkThemeId;

  /// Get the theme notifier for reactive updates.
  ValueNotifier<String> get themeNotifier => _themeNotifier;

  /// Stream of theme change events.
  Stream<String> get onThemeChanged => _themeStreamController.stream;

  /// Get the current theme ID.
  String get currentThemeId => _themeNotifier.value;

  /// Get whether the app is following system theme.
  bool get followSystemTheme => _followSystemTheme;

  /// Get whether the manager has been initialized.
  bool get isInitialized => _isInitialized;

  /// Get the preferred light theme ID.
  String? get preferredLightThemeId => _preferredLightThemeId;

  /// Get the preferred dark theme ID.
  String? get preferredDarkThemeId => _preferredDarkThemeId;

  /// Get the current [BaseThemeConfig].
  BaseThemeConfig? get currentTheme {
    if (_themes.isEmpty || currentThemeId.isEmpty) return null;
    return _themes.firstWhere(
      (theme) => theme.id == currentThemeId,
      orElse: () => _themes.first,
    );
  }

  /// Get the current [ThemeData].
  ThemeData? get themeData => currentTheme?.themeData;

  /// Check if the current theme is dark.
  bool get isDark {
    final theme = currentTheme;
    if (theme == null) return false;
    return theme.type == NyThemeType.dark;
  }

  /// Get all registered themes.
  List<BaseThemeConfig> get themes => List.unmodifiable(_themes);

  /// Get all light themes.
  List<BaseThemeConfig> get lightThemes =>
      _themes.where((theme) => theme.type == NyThemeType.light).toList();

  /// Get all dark themes.
  List<BaseThemeConfig> get darkThemes =>
      _themes.where((theme) => theme.type == NyThemeType.dark).toList();

  /// Get themes by type.
  List<BaseThemeConfig> getThemesByType(NyThemeType type) =>
      _themes.where((theme) => theme.type == type).toList();

  /// Get a theme by ID.
  ///
  /// Returns null if no theme with the given ID is found.
  BaseThemeConfig? getThemeById(String id) {
    try {
      return _themes.firstWhere((theme) => theme.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get the first light theme from registered themes.
  BaseThemeConfig? get lightTheme {
    try {
      return _themes.firstWhere((theme) => theme.type == NyThemeType.light);
    } catch (_) {
      return _themes.isNotEmpty ? _themes.first : null;
    }
  }

  /// Get the first dark theme from registered themes.
  BaseThemeConfig? get darkTheme {
    try {
      return _themes.firstWhere((theme) => theme.type == NyThemeType.dark);
    } catch (_) {
      return null;
    }
  }

  /// Get the effective light theme (preferred or first light theme).
  ///
  /// Returns the preferred light theme if set and exists,
  /// otherwise returns the first light theme.
  BaseThemeConfig? get effectiveLightTheme {
    if (_preferredLightThemeId != null) {
      final preferred = getThemeById(_preferredLightThemeId!);
      if (preferred != null && preferred.type == NyThemeType.light) {
        return preferred;
      }
    }
    return lightTheme;
  }

  /// Get the effective dark theme (preferred or first dark theme).
  ///
  /// Returns the preferred dark theme if set and exists,
  /// otherwise returns the first dark theme.
  BaseThemeConfig? get effectiveDarkTheme {
    if (_preferredDarkThemeId != null) {
      final preferred = getThemeById(_preferredDarkThemeId!);
      if (preferred != null && preferred.type == NyThemeType.dark) {
        return preferred;
      }
    }
    return darkTheme;
  }

  /// Check if the system is currently in dark mode.
  bool get _isSystemDarkMode =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;

  /// Get typed color styles from the current theme.
  ///
  /// Example:
  /// ```dart
  /// final colors = NyThemeManager.instance.colorStyles<MyColorStyles>();
  /// print(colors.primaryAccent);
  /// ```
  T colorStyles<T>() {
    final theme = currentTheme;
    if (theme == null) {
      throw StateError(
        'No theme registered. Call registerThemes() before accessing colorStyles.',
      );
    }
    return theme.colors as T;
  }

  /// Get color styles from a specific theme by ID.
  T colorStylesFromTheme<T>(String themeId) {
    final theme = _themes.firstWhere(
      (t) => t.id == themeId,
      orElse: () => throw ArgumentError('Theme with id "$themeId" not found.'),
    );
    return theme.colors as T;
  }

  /// Initialize the theme manager.
  ///
  /// This should be called during app startup after [registerThemes].
  /// Handles migration from shared_preferences and loads saved theme.
  Future<void> init() async {
    if (_isInitialized) return;

    // Add observer for system brightness changes
    WidgetsBinding.instance.addObserver(this);

    // Load saved preferences
    final savedThemeId = await _storage.readThemeId();
    final savedFollowSystem = await _storage.readFollowSystem();
    final savedPreferredLight = await _storage.readPreferredLightThemeId();
    final savedPreferredDark = await _storage.readPreferredDarkThemeId();

    // Load preferred themes
    _preferredLightThemeId = savedPreferredLight;
    _preferredDarkThemeId = savedPreferredDark;

    // Determine if this is first launch (no saved preferences)
    final isFirstLaunch = savedThemeId == null && savedFollowSystem == null;

    if (savedFollowSystem != null) {
      _followSystemTheme = savedFollowSystem;
    }

    if (savedThemeId != null && savedThemeId.isNotEmpty) {
      // Use saved theme if it exists in registered themes
      final themeExists = _themes.any((t) => t.id == savedThemeId);
      if (themeExists) {
        _setThemeInternal(savedThemeId, notify: true, persist: false);
      }
    } else if (isFirstLaunch && _initialThemeId != null) {
      // First launch: use initialThemeId if provided
      final themeExists = _themes.any((t) => t.id == _initialThemeId);
      if (themeExists) {
        _setThemeInternal(_initialThemeId!, notify: true, persist: true);
      }
    } else if (_followSystemTheme) {
      // Auto-detect from system brightness
      _applySystemTheme(notify: true, persist: true);
    }

    _isInitialized = true;
  }

  /// Register themes with the manager.
  ///
  /// [themes] - List of theme configurations to register.
  /// [initialThemeId] - Optional theme ID to use on first launch. If provided,
  ///                    it will disable system theme following.
  ///                    If not provided, the system brightness will be used
  ///                    to select a matching theme.
  void registerThemes<T>(
    List<BaseThemeConfig<T>> themes, {
    String? initialThemeId,
  }) {
    _themes.clear();
    _themes.addAll(themes);

    if (_themes.isEmpty) {
      throw ArgumentError('At least one theme must be registered.');
    }

    // Store initial theme ID for use in init()
    _initialThemeId = initialThemeId;

    // If initialThemeId is provided, disable follow system theme
    if (initialThemeId != null && initialThemeId.isNotEmpty) {
      _followSystemTheme = false;
      final themeExists = _themes.any((t) => t.id == initialThemeId);
      if (themeExists) {
        _setThemeInternal(initialThemeId, notify: false, persist: false);
      } else {
        _setThemeInternal(_themes.first.id, notify: false, persist: false);
      }
    } else {
      // Auto-detect from system brightness
      _applySystemTheme(notify: false, persist: false);
    }
  }

  /// Set the current theme by ID.
  ///
  /// This will automatically disable [followSystemTheme].
  /// To change theme while keeping system following enabled, use [setFollowSystemTheme].
  ///
  /// [themeId] - The ID of the theme to set.
  /// [remember] - If true, sets this theme as the preferred theme for its type
  ///              (light or dark). This is used when following system theme to
  ///              remember which theme variant the user prefers.
  Future<void> setTheme(String themeId, {bool remember = false}) async {
    final theme = getThemeById(themeId);
    if (theme == null) {
      throw ArgumentError('Theme with id "$themeId" not found.');
    }

    // Disable follow system theme on manual set
    if (_followSystemTheme) {
      _followSystemTheme = false;
      await _storage.saveFollowSystem(false);
    }

    // Optionally remember this theme as preferred for its type
    if (remember) {
      if (theme.type == NyThemeType.dark) {
        _preferredDarkThemeId = themeId;
        await _storage.savePreferredDarkThemeId(themeId);
      } else {
        _preferredLightThemeId = themeId;
        await _storage.savePreferredLightThemeId(themeId);
      }
    }

    _setThemeInternal(themeId, notify: true, persist: true);
  }

  /// Set the preferred dark theme for system theme following.
  ///
  /// This theme will be used when the system is in dark mode and
  /// [followSystemTheme] is enabled.
  ///
  /// Useful when you have multiple dark themes (e.g., dark, dark_amoled, dark_blue)
  /// and want the user to choose which one to use for dark mode.
  Future<void> setPreferredDarkTheme(String themeId) async {
    final theme = getThemeById(themeId);
    if (theme == null || theme.type != NyThemeType.dark) {
      throw ArgumentError('Dark theme with id "$themeId" not found.');
    }

    _preferredDarkThemeId = themeId;
    await _storage.savePreferredDarkThemeId(themeId);

    // If currently following system and in dark mode, apply immediately
    if (_followSystemTheme && _isSystemDarkMode) {
      _setThemeInternal(themeId, notify: true, persist: true);
    }
  }

  /// Set the preferred light theme for system theme following.
  ///
  /// This theme will be used when the system is in light mode and
  /// [followSystemTheme] is enabled.
  ///
  /// Useful when you have multiple light themes and want the user to choose
  /// which one to use for light mode.
  Future<void> setPreferredLightTheme(String themeId) async {
    final theme = getThemeById(themeId);
    if (theme == null || theme.type != NyThemeType.light) {
      throw ArgumentError('Light theme with id "$themeId" not found.');
    }

    _preferredLightThemeId = themeId;
    await _storage.savePreferredLightThemeId(themeId);

    // If currently following system and in light mode, apply immediately
    if (_followSystemTheme && !_isSystemDarkMode) {
      _setThemeInternal(themeId, notify: true, persist: true);
    }
  }

  /// Clear all saved theme data.
  ///
  /// Useful for testing and development to reset theme preferences.
  Future<void> clearSavedTheme() async {
    await _storage.clearAll();
    _preferredLightThemeId = null;
    _preferredDarkThemeId = null;
  }

  /// Set whether to follow system theme changes.
  ///
  /// When enabled, the app will automatically switch between light and dark
  /// themes based on the device's brightness setting.
  Future<void> setFollowSystemTheme(bool follow) async {
    _followSystemTheme = follow;
    await _storage.saveFollowSystem(follow);

    if (follow) {
      _applySystemTheme(notify: true, persist: true);
    }
  }

  /// Called when the platform brightness changes.
  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    if (_followSystemTheme) {
      _applySystemTheme(notify: true, persist: true);
    }
  }

  /// Apply theme based on system brightness.
  void _applySystemTheme({required bool notify, required bool persist}) {
    final isDarkMode = _isSystemDarkMode;

    BaseThemeConfig? targetTheme;
    if (isDarkMode) {
      targetTheme = effectiveDarkTheme ?? effectiveLightTheme;
    } else {
      targetTheme = effectiveLightTheme ?? effectiveDarkTheme;
    }

    if (targetTheme != null) {
      _setThemeInternal(targetTheme.id, notify: notify, persist: persist);
    }
  }

  /// Internal method to set theme.
  void _setThemeInternal(
    String themeId, {
    required bool notify,
    required bool persist,
  }) {
    // Allow setting on first call even if themeId matches (for initialization)
    final isInitialSet = _themeNotifier.value.isEmpty;
    if (!isInitialSet && _themeNotifier.value == themeId) return;

    _themeNotifier.value = themeId;

    if (notify) {
      _themeStreamController.add(themeId);
    }

    if (persist) {
      _storage.saveThemeId(themeId);
    }
  }

  /// Dispose of resources.
  ///
  /// Safe to call on a singleton — reinitializes internal resources
  /// so the manager can be used again after a subsequent [init] call.
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _themeStreamController.close();
    _themeNotifier.dispose();

    // Reinitialize resources so the singleton remains usable
    _themeStreamController = StreamController<String>.broadcast();
    _themeNotifier = ValueNotifier<String>('');
    _isInitialized = false;
  }
}

/// Helper function to get color styles from [NyThemeManager].
///
/// Example:
/// ```dart
/// final colors = nyColorStyles<MyColorStyles>();
/// ```
T nyColorStyles<T>() => NyThemeManager.instance.colorStyles<T>();
