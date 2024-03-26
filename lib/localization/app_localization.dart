import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '/helpers/helper.dart';
import '/widgets/ny_language_switcher.dart';

/// Locale Types
enum LocaleType { device, asDefined }

/// LocalizedApp
/// A widget that reloads the app when the language is changed.
/// Use this widget as the root of your app.
/// ```dart
/// void main() {
///  runApp(LocalizedApp(child: MyApp()));
///  }
///  ```
class LocalizedApp extends StatefulWidget {
  final Widget? child;

  LocalizedApp({this.child});

  /// Reloads the app
  static void restart(BuildContext context) {
    context.findAncestorStateOfType<_LocalizedAppState>()!.restart();
  }

  @override
  _LocalizedAppState createState() => _LocalizedAppState();
}

class _LocalizedAppState extends State<LocalizedApp> {
  Key key = new UniqueKey();

  /// setState the widget and update the [key].
  void restart() {
    this.setState(() {
      key = new UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      key: key,
      child: widget.child,
    );
  }
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

  /// init NyLocalization
  Future<void> init(
      {LocaleType localeType = LocaleType.asDefined,
      required String languageCode,
      String assetsDirectory = 'lang/'}) async {
    if (!assetsDirectory.endsWith('/')) {
      assetsDirectory = '$assetsDirectory/';
    }
    _assetsDir = assetsDirectory;
    assert(_assetsDir != null, 'You must define assetsDirectory');
    _localeType = localeType;

    _locale = Locale(languageCode);

    if (_localeType == LocaleType.device) {
      Locale locale = PlatformDispatcher.instance.locale;
      _locale = locale;
      if (locale.toString().contains(RegExp('[-_]'))) {
        _locale = Locale(locale.toString().split(RegExp('[-_]'))[0]);
      }
    }

    /// Get the current language from the language switcher
    /// if it's available.
    Map<String, dynamic>? nyLangSwitcherLanguage =
        await NyLanguageSwitcher.currentLanguage();
    if (nyLangSwitcherLanguage != null) {
      _locale = Locale(nyLangSwitcherLanguage.entries.first.key);
    }

    if (_assetsDir == null) {
      return;
    }

    if (_assetsDir == null) {
      return;
    }
    _assetsDir = assetsDirectory;
    _values = await _initLanguage(_locale!.languageCode,
        defaultLanguageCode: languageCode);
  }

  /// Loads language file
  dynamic _initLanguage(String languageCode,
      {String? defaultLanguageCode}) async {
    String filePath = "$_assetsDir$languageCode.json";
    try {
      String content = await rootBundle.loadString(filePath);
      return json.decode(content);
    } catch (e) {
      NyLogger.error(
          "Language file not found: $filePath. Loading default language file: $defaultLanguageCode.");
      if (defaultLanguageCode != null) {
        String filePath = "$_assetsDir$defaultLanguageCode.json";
        String content = await rootBundle.loadString(filePath);
        return json.decode(content);
      }
      throw Exception('Language file not found');
    }
  }

  /// translates a word
  String translate(String key, [Map<String, String>? arguments]) {
    String value =
        (_values == null || _values![key] == null) ? '$key' : _values![key];

    String? returnValue = value;

    if (_isNestedKey(key)) {
      returnValue = _getNested(key);
    }

    if (returnValue == null) {
      return key;
    }

    if (arguments == null) return returnValue;

    for (var key in arguments.keys) {
      returnValue = returnValue?.replaceAll("{{$key}}", arguments[key]!);
    }
    return returnValue ?? "";
  }

  /// Get nested values in a string
  /// E.g. "intros.hello".
  /// Output if [key] is "intros" = "hello"
  String? _getNested(String key) {
    if (_isNestedCached(key)) return _values![key];

    final keys = key.split('.');
    final kHead = keys.first;

    var value = _values![kHead];

    for (var i = 1; i < keys.length; i++) {
      if (value is Map<String, dynamic>) value = value[keys[i]];
    }

    /// If we found the value, cache it. If the value is null then
    /// we're not going to cache it, and returning null instead.
    if (value != null) {
      _cacheNestedKey(key, value);
    }

    return value;
  }

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

  /// changes active language
  Future<void> setLanguage(
    BuildContext context, {
    required String language,
    bool restart = true,
  }) async {
    _locale = Locale(language, "");

    String filePath = "$_assetsDir$language.json";
    String content = await rootBundle.loadString(filePath);

    _values = json.decode(content);

    if (restart) {
      LocalizedApp.restart(context);
    }
  }

  /// changes locale
  Future<void> setLocale({
    required Locale locale,
  }) async {
    _locale = locale;

    String filePath = "$_assetsDir${_locale!.languageCode}.json";
    String content = await rootBundle.loadString(filePath);

    _values = json.decode(content);
  }

  /// isDirectionRTL(BuildContext context)
  /// returns `true` if active language direction is TRL
  bool isDirectionRTL(BuildContext context) =>
      Directionality.of(context) == TextDirection.rtl;

  /// reloads the app
  void restart(BuildContext context) => LocalizedApp.restart(context);

  /// Returns language code as string
  String get languageCode => locale.languageCode;

  /// Returns locale code as Locale
  Locale get locale {
    return _locale ?? Locale('en');
  }

  /// Returns app delegates.
  /// used in app entry point e.g. MaterialApp()
  Iterable<LocalizationsDelegate> get delegates => [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
      ];
}
