import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '/nylo.dart';
import '/helpers/ny_helpers.dart';
import '/widgets/ny_widgets.dart';

/// Defines how the locale should be determined
enum LocaleType {
  /// Use the device's system locale
  device,

  /// Use the locale defined in the app configuration
  asDefined,
}

/// Configuration class for NyLocalization.
///
/// Used with [Nylo.configure] to set up localization in a single call.
///
/// Example:
/// ```dart
/// NyLocalizationConfig(
///   localeType: LocaleType.device,
///   languageCode: 'en',
///   assetsDirectory: 'lang/',
/// )
/// ```
class NyLocalizationConfig {
  /// How the locale should be determined.
  final LocaleType localeType;

  /// The default language code (e.g., 'en', 'es', 'fr').
  final String languageCode;

  /// The directory containing language JSON files.
  final String assetsDirectory;

  const NyLocalizationConfig({
    this.localeType = LocaleType.asDefined,
    required this.languageCode,
    this.assetsDirectory = 'lang/',
  });
}

/// Translate [String].
extension Translation on String {
  String tr({Map<String, String>? arguments}) =>
      NyLocalization.instance.translate(this, arguments);
}

/// NyLocalization
/// Singleton object that handles localization in Nylo
class NyLocalization {
  NyLocalization._privateConstructor();

  static final NyLocalization instance = NyLocalization._privateConstructor();

  LocaleType? _localeType;
  String? _assetsDir;
  Locale? _locale;
  Map<String, dynamic>? _values;
  Map<String, dynamic>? _fallbackValues;
  String? _fallbackLanguageCode;
  bool _debugMissingKeys = false;

  /// Enable or disable debug logging for missing translation keys
  void setDebugMissingKeys(bool enabled) {
    _debugMissingKeys = enabled;
  }

  /// Initialize NyLocalization with the specified configuration.
  Future<void> init({
    LocaleType localeType = LocaleType.asDefined,
    required String languageCode,
    String assetsDirectory = 'lang/',
  }) async {
    if (!assetsDirectory.endsWith('/')) {
      assetsDirectory = '$assetsDirectory/';
    }
    _assetsDir = assetsDirectory;
    _localeType = localeType;

    _locale = Locale(languageCode);

    if (_localeType == LocaleType.device) {
      final deviceLocale = PlatformDispatcher.instance.locale;
      _locale = Locale(deviceLocale.languageCode);
    }

    // Get the current language from the language switcher if available.
    // Skip in test mode to avoid storage hangs.
    if (!Nylo.isTestMode) {
      final savedLanguage = await LanguageSwitcher.currentLanguage();
      if (savedLanguage != null) {
        _locale = Locale(savedLanguage.entries.first.key);
      }
    }

    _fallbackLanguageCode = languageCode;

    _values = await _loadLanguageFile(
      _locale!.languageCode,
      fallbackLanguageCode: languageCode,
    );

    if (_locale!.languageCode != languageCode) {
      _fallbackValues = await _loadLanguageFile(languageCode);
    } else {
      _fallbackValues = null;
    }
  }

  /// Loads a language JSON file from assets.
  /// Falls back to [fallbackLanguageCode] if the primary file is not found.
  Future<Map<String, dynamic>> _loadLanguageFile(
    String languageCode, {
    String? fallbackLanguageCode,
  }) async {
    final filePath = "$_assetsDir$languageCode.json";
    try {
      final content = await rootBundle.loadString(filePath);
      return json.decode(content) as Map<String, dynamic>;
    } catch (e) {
      if (fallbackLanguageCode != null &&
          fallbackLanguageCode != languageCode) {
        NyLogger.error(
          "Language file not found: $filePath. Loading fallback: $fallbackLanguageCode.",
        );
        final fallbackPath = "$_assetsDir$fallbackLanguageCode.json";
        final content = await rootBundle.loadString(fallbackPath);
        return json.decode(content) as Map<String, dynamic>;
      }
      throw Exception('Language file not found: $filePath');
    }
  }

  /// Translates a key to its localized string value.
  /// Supports nested keys using dot notation (e.g., "section.greeting").
  /// Supports argument interpolation using {{argName}} syntax.
  String translate(String key, [Map<String, String>? arguments]) {
    // Return key if values not initialized
    if (_values == null) {
      if (_debugMissingKeys) {
        NyLogger.debug("Missing translation key (not initialized): $key");
      }
      return key;
    }

    String? translatedValue;
    bool isMissing = false;

    if (_isNestedKey(key)) {
      translatedValue = _getNested(key);
      isMissing = translatedValue == null;
    } else {
      translatedValue = _values![key];
      isMissing = translatedValue == null;
    }

    // Try fallback locale if key is missing
    if (translatedValue == null && _fallbackValues != null) {
      if (_isNestedKeyIn(key, _fallbackValues!)) {
        translatedValue = _getNestedFrom(key, _fallbackValues!);
      } else {
        translatedValue = _fallbackValues![key];
      }
      isMissing = translatedValue == null;
    }

    // Log missing key in debug mode
    if (_debugMissingKeys && isMissing) {
      NyLogger.debug("Missing translation key: $key");
    }

    if (translatedValue == null) {
      return key;
    }

    if (arguments == null) return translatedValue;

    // Replace argument placeholders
    for (final entry in arguments.entries) {
      translatedValue = translatedValue?.replaceAll(
        "{{${entry.key}}}",
        entry.value,
      );
    }

    return translatedValue ?? key;
  }

  /// Check if a translation key exists
  bool hasTranslation(String key) {
    if (_values == null) return false;
    if (_values!.containsKey(key)) return true;
    if (key.contains('.')) {
      return _getNested(key) != null;
    }
    return false;
  }

  /// Get all available translation keys (for debugging)
  List<String> getAllKeys() {
    if (_values == null) return [];
    return _values!.keys.toList();
  }

  /// Get nested values in a string
  /// E.g. "intros.hello".
  /// Output if [key] is "intros" = "hello"
  String? _getNested(String key) {
    if (_isNestedCached(key)) return _values![key];

    final result = _getNestedFrom(key, _values!);

    /// If we found the value, cache it. If the value is null then
    /// we're not going to cache it, and returning null instead.
    if (result != null) {
      _cacheNestedKey(key, result);
    }

    return result;
  }

  /// Look up a dot-notated [key] in an arbitrary [source] map.
  String? _getNestedFrom(String key, Map<String, dynamic> source) {
    final keys = key.split('.');
    var value = source[keys.first];
    for (var i = 1; i < keys.length; i++) {
      if (value is Map<String, dynamic>) value = value[keys[i]];
    }
    return value is String ? value : null;
  }

  /// Check if [key] should be treated as nested in the given [source] map.
  bool _isNestedKeyIn(String key, Map<String, dynamic> source) =>
      !source.containsKey(key) && key.contains('.');

  /// Check if there is a cached value for [key].
  bool _isNestedCached(String key) => _values!.containsKey(key);

  /// Set the [value] for a cache [key].
  void _cacheNestedKey(String key, String value) {
    if (!_isNestedKey(key)) {
      throw Exception('Cannot cache a key that is not nested.');
    }

    _values![key] = value;
  }

  bool _isNestedKey(String key) =>
      !_values!.containsKey(key) && key.contains('.');

  /// Changes the active language and optionally restarts the app.
  Future<void> setLanguage(
    BuildContext context, {
    required String language,
    bool restart = true,
  }) async {
    if (_assetsDir == null) {
      NyLogger.error("Cannot set language: assets directory not initialized");
      return;
    }

    try {
      _values = await _loadLanguageFile(language);
      _locale = Locale(language);
      if (_fallbackLanguageCode != null && language != _fallbackLanguageCode) {
        _fallbackValues = await _loadLanguageFile(_fallbackLanguageCode!);
      } else {
        _fallbackValues = null;
      }
    } catch (e) {
      NyLogger.error("Failed to load language: $language");
      return;
    }

    if (restart) {
      // ignore: use_build_context_synchronously
      NyApp.restart(context);
    }
  }

  /// Changes the locale without restarting the app.
  Future<void> setLocale({required Locale locale}) async {
    if (_assetsDir == null) {
      NyLogger.error("Cannot set locale: assets directory not initialized");
      return;
    }

    try {
      _values = await _loadLanguageFile(locale.languageCode);
      _locale = locale;
      if (_fallbackLanguageCode != null &&
          locale.languageCode != _fallbackLanguageCode) {
        _fallbackValues = await _loadLanguageFile(_fallbackLanguageCode!);
      } else {
        _fallbackValues = null;
      }
    } catch (e) {
      NyLogger.error("Failed to load locale: ${locale.languageCode}");
    }
  }

  /// Returns `true` if the active language direction is RTL.
  bool isDirectionRTL(BuildContext context) =>
      Directionality.of(context) == TextDirection.rtl;

  /// reloads the app
  void restart(BuildContext context) => NyApp.restart(context);

  /// Returns language code as string
  String get languageCode => locale.languageCode;

  /// Returns locale code as Locale
  Locale get locale {
    return _locale ?? const Locale('en');
  }

  /// Returns app delegates.
  /// used in app entry point e.g. MaterialApp()
  Iterable<LocalizationsDelegate> get delegates => [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    DefaultCupertinoLocalizations.delegate,
  ];

  /// Sets translation values directly for testing purposes.
  @visibleForTesting
  void setValuesForTesting({
    required Map<String, dynamic> values,
    Map<String, dynamic>? fallbackValues,
  }) {
    _values = values;
    _fallbackValues = fallbackValues;
  }
}
