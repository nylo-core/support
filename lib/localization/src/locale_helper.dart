import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Helper class for locale-related operations.
class NyLocaleHelper {
  /// Common RTL (right-to-left) language codes.
  /// Includes Arabic, Hebrew, Persian, Urdu, Yiddish, Pashto, Kurdish,
  /// Sindhi, and Divehi (Maldivian).
  static const List<String> rtlLanguages = [
    'ar', // Arabic
    'he', // Hebrew
    'fa', // Persian/Farsi
    'ur', // Urdu
    'yi', // Yiddish
    'ps', // Pashto
    'ku', // Kurdish
    'sd', // Sindhi
    'dv', // Divehi/Maldivian
  ];

  /// Get the current system locale.
  /// Uses the context if available, otherwise falls back to platform dispatcher.
  static Locale getCurrentLocale({BuildContext? context}) {
    if (context != null) {
      return Localizations.localeOf(context);
    }
    return ui.PlatformDispatcher.instance.locale;
  }

  /// Get the language code of the current locale.
  static String getLanguageCode({BuildContext? context}) {
    return getCurrentLocale(context: context).languageCode;
  }

  /// Get the country code of the current locale, if available.
  static String? getCountryCode({BuildContext? context}) {
    return getCurrentLocale(context: context).countryCode;
  }

  /// Check if the current locale matches a specific language (and optionally country).
  static bool matchesLocale(
    BuildContext? context,
    String languageCode, [
    String? countryCode,
  ]) {
    final currentLocale = getCurrentLocale(context: context);
    if (countryCode != null) {
      return currentLocale.languageCode == languageCode &&
          currentLocale.countryCode == countryCode;
    }
    return currentLocale.languageCode == languageCode;
  }

  /// Check if a language code uses right-to-left text direction.
  static bool isRtlLanguage(String languageCode) =>
      rtlLanguages.contains(languageCode);

  /// Check if the current locale uses right-to-left text direction.
  static bool isCurrentLocaleRtl({BuildContext? context}) {
    return isRtlLanguage(getLanguageCode(context: context));
  }

  /// Get the text direction for a language code.
  static TextDirection getTextDirection(String languageCode) {
    return isRtlLanguage(languageCode) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Get the text direction for the current locale.
  static TextDirection getCurrentTextDirection({BuildContext? context}) {
    return getTextDirection(getLanguageCode(context: context));
  }

  /// Create a Locale from a language code and optional country code.
  static Locale toLocale(String languageCode, [String? countryCode]) {
    return Locale(languageCode, countryCode);
  }
}
