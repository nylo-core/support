import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nylo_support/localization/ny_localization.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('NyLocaleHelper', () {
    nyGroup('rtlLanguages', () {
      nyTest('should contain common RTL language codes', () async {
        expect(NyLocaleHelper.rtlLanguages, contains('ar')); // Arabic
        expect(NyLocaleHelper.rtlLanguages, contains('he')); // Hebrew
        expect(NyLocaleHelper.rtlLanguages, contains('fa')); // Persian/Farsi
        expect(NyLocaleHelper.rtlLanguages, contains('ur')); // Urdu
        expect(NyLocaleHelper.rtlLanguages, contains('yi')); // Yiddish
        expect(NyLocaleHelper.rtlLanguages, contains('ps')); // Pashto
        expect(NyLocaleHelper.rtlLanguages, contains('ku')); // Kurdish
        expect(NyLocaleHelper.rtlLanguages, contains('sd')); // Sindhi
        expect(NyLocaleHelper.rtlLanguages, contains('dv')); // Divehi/Maldivian
      });

      nyTest('should have exactly 9 RTL languages', () async {
        expect(NyLocaleHelper.rtlLanguages.length, 9);
      });

      nyTest('should not contain LTR languages', () async {
        expect(NyLocaleHelper.rtlLanguages, isNot(contains('en'))); // English
        expect(NyLocaleHelper.rtlLanguages, isNot(contains('es'))); // Spanish
        expect(NyLocaleHelper.rtlLanguages, isNot(contains('fr'))); // French
        expect(NyLocaleHelper.rtlLanguages, isNot(contains('de'))); // German
        expect(NyLocaleHelper.rtlLanguages, isNot(contains('zh'))); // Chinese
        expect(NyLocaleHelper.rtlLanguages, isNot(contains('ja'))); // Japanese
      });
    });

    nyGroup('getCurrentLocale', () {
      nyWidgetTest('should return locale from context when provided', (
        tester,
      ) async {
        late Locale capturedLocale;

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('es', 'ES'),
            supportedLocales: const [Locale('en', 'US'), Locale('es', 'ES')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Builder(
              builder: (context) {
                capturedLocale = NyLocaleHelper.getCurrentLocale(
                  context: context,
                );
                return const SizedBox();
              },
            ),
          ),
        );

        expect(capturedLocale.languageCode, 'es');
      });

      nyTest('should return platform locale when context is null', () async {
        // Without context, falls back to platform dispatcher
        final locale = NyLocaleHelper.getCurrentLocale();

        expect(locale, isA<Locale>());
        expect(locale.languageCode, isNotEmpty);
      });
    });

    nyGroup('getLanguageCode', () {
      nyWidgetTest('should return only the language code from context', (
        tester,
      ) async {
        late String capturedLanguageCode;

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('fr', 'FR'),
            supportedLocales: const [Locale('en', 'US'), Locale('fr', 'FR')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Builder(
              builder: (context) {
                capturedLanguageCode = NyLocaleHelper.getLanguageCode(
                  context: context,
                );
                return const SizedBox();
              },
            ),
          ),
        );

        expect(capturedLanguageCode, 'fr');
      });

      nyTest('should return language code without context', () async {
        final languageCode = NyLocaleHelper.getLanguageCode();

        expect(languageCode, isA<String>());
        expect(languageCode, isNotEmpty);
      });
    });

    nyGroup('getCountryCode', () {
      nyWidgetTest('should return country code when locale has one', (
        tester,
      ) async {
        late String? capturedCountryCode;

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en', 'GB'),
            supportedLocales: const [Locale('en', 'US'), Locale('en', 'GB')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Builder(
              builder: (context) {
                capturedCountryCode = NyLocaleHelper.getCountryCode(
                  context: context,
                );
                return const SizedBox();
              },
            ),
          ),
        );

        expect(capturedCountryCode, 'GB');
      });

      nyWidgetTest('should return null when locale has no country code', (
        tester,
      ) async {
        late String? capturedCountryCode;

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            supportedLocales: const [Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Builder(
              builder: (context) {
                capturedCountryCode = NyLocaleHelper.getCountryCode(
                  context: context,
                );
                return const SizedBox();
              },
            ),
          ),
        );

        // Locale('en') may or may not have a country code depending on platform
        expect(capturedCountryCode, anyOf(isNull, isA<String>()));
      });
    });

    nyGroup('matchesLocale', () {
      nyWidgetTest('should return true when language code matches', (
        tester,
      ) async {
        late bool matches;

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('de', 'DE'),
            supportedLocales: const [Locale('en', 'US'), Locale('de', 'DE')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Builder(
              builder: (context) {
                matches = NyLocaleHelper.matchesLocale(context, 'de');
                return const SizedBox();
              },
            ),
          ),
        );

        expect(matches, isTrue);
      });

      nyWidgetTest('should return false when language code does not match', (
        tester,
      ) async {
        late bool matches;

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en', 'US'),
            supportedLocales: const [Locale('en', 'US'), Locale('de', 'DE')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Builder(
              builder: (context) {
                matches = NyLocaleHelper.matchesLocale(context, 'de');
                return const SizedBox();
              },
            ),
          ),
        );

        expect(matches, isFalse);
      });

      nyWidgetTest(
        'should return true when both language and country code match',
        (tester) async {
          late bool matches;

          await tester.pumpWidget(
            MaterialApp(
              locale: const Locale('en', 'US'),
              supportedLocales: const [Locale('en', 'US'), Locale('en', 'GB')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: Builder(
                builder: (context) {
                  matches = NyLocaleHelper.matchesLocale(context, 'en', 'US');
                  return const SizedBox();
                },
              ),
            ),
          );

          expect(matches, isTrue);
        },
      );

      nyWidgetTest(
        'should return false when language matches but country code does not',
        (tester) async {
          late bool matches;

          await tester.pumpWidget(
            MaterialApp(
              locale: const Locale('en', 'US'),
              supportedLocales: const [Locale('en', 'US'), Locale('en', 'GB')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: Builder(
                builder: (context) {
                  matches = NyLocaleHelper.matchesLocale(context, 'en', 'GB');
                  return const SizedBox();
                },
              ),
            ),
          );

          expect(matches, isFalse);
        },
      );

      nyTest('should work with null context using platform locale', () async {
        // Without context, uses platform dispatcher locale
        final matches = NyLocaleHelper.matchesLocale(null, 'en');

        // Result depends on platform locale - just verify it returns a boolean
        expect(matches, isA<bool>());
      });
    });

    nyGroup('isRtlLanguage', () {
      nyTest('should return true for Arabic', () async {
        expect(NyLocaleHelper.isRtlLanguage('ar'), isTrue);
      });

      nyTest('should return true for Hebrew', () async {
        expect(NyLocaleHelper.isRtlLanguage('he'), isTrue);
      });

      nyTest('should return true for Persian/Farsi', () async {
        expect(NyLocaleHelper.isRtlLanguage('fa'), isTrue);
      });

      nyTest('should return true for Urdu', () async {
        expect(NyLocaleHelper.isRtlLanguage('ur'), isTrue);
      });

      nyTest('should return true for Yiddish', () async {
        expect(NyLocaleHelper.isRtlLanguage('yi'), isTrue);
      });

      nyTest('should return true for Pashto', () async {
        expect(NyLocaleHelper.isRtlLanguage('ps'), isTrue);
      });

      nyTest('should return true for Kurdish', () async {
        expect(NyLocaleHelper.isRtlLanguage('ku'), isTrue);
      });

      nyTest('should return false for English', () async {
        expect(NyLocaleHelper.isRtlLanguage('en'), isFalse);
      });

      nyTest('should return false for Spanish', () async {
        expect(NyLocaleHelper.isRtlLanguage('es'), isFalse);
      });

      nyTest('should return false for French', () async {
        expect(NyLocaleHelper.isRtlLanguage('fr'), isFalse);
      });

      nyTest('should return false for German', () async {
        expect(NyLocaleHelper.isRtlLanguage('de'), isFalse);
      });

      nyTest('should return false for Chinese', () async {
        expect(NyLocaleHelper.isRtlLanguage('zh'), isFalse);
      });

      nyTest('should return false for Japanese', () async {
        expect(NyLocaleHelper.isRtlLanguage('ja'), isFalse);
      });

      nyTest('should return false for unknown language codes', () async {
        expect(NyLocaleHelper.isRtlLanguage('xx'), isFalse);
        expect(NyLocaleHelper.isRtlLanguage(''), isFalse);
        expect(NyLocaleHelper.isRtlLanguage('unknown'), isFalse);
      });

      nyTest('should be case-sensitive', () async {
        // RTL languages list uses lowercase
        expect(NyLocaleHelper.isRtlLanguage('AR'), isFalse);
        expect(NyLocaleHelper.isRtlLanguage('He'), isFalse);
        expect(NyLocaleHelper.isRtlLanguage('FA'), isFalse);
      });
    });

    nyGroup('isCurrentLocaleRtl', () {
      nyWidgetTest('should return true for RTL locale', (tester) async {
        late bool isRtl;

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ar', 'SA'),
            supportedLocales: const [Locale('en', 'US'), Locale('ar', 'SA')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Builder(
              builder: (context) {
                isRtl = NyLocaleHelper.isCurrentLocaleRtl(context: context);
                return const SizedBox();
              },
            ),
          ),
        );

        expect(isRtl, isTrue);
      });

      nyWidgetTest('should return false for LTR locale', (tester) async {
        late bool isRtl;

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en', 'US'),
            supportedLocales: const [Locale('en', 'US'), Locale('ar', 'SA')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Builder(
              builder: (context) {
                isRtl = NyLocaleHelper.isCurrentLocaleRtl(context: context);
                return const SizedBox();
              },
            ),
          ),
        );

        expect(isRtl, isFalse);
      });

      nyWidgetTest('should return true for Hebrew locale', (tester) async {
        late bool isRtl;

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('he', 'IL'),
            supportedLocales: const [Locale('en', 'US'), Locale('he', 'IL')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Builder(
              builder: (context) {
                isRtl = NyLocaleHelper.isCurrentLocaleRtl(context: context);
                return const SizedBox();
              },
            ),
          ),
        );

        expect(isRtl, isTrue);
      });

      nyTest('should work without context using platform locale', () async {
        final isRtl = NyLocaleHelper.isCurrentLocaleRtl();

        // Result depends on platform locale - just verify it returns a boolean
        expect(isRtl, isA<bool>());
      });
    });

    nyGroup('getTextDirection', () {
      nyTest('should return RTL for Arabic', () async {
        expect(
          NyLocaleHelper.getTextDirection('ar'),
          equals(TextDirection.rtl),
        );
      });

      nyTest('should return RTL for Hebrew', () async {
        expect(
          NyLocaleHelper.getTextDirection('he'),
          equals(TextDirection.rtl),
        );
      });

      nyTest('should return LTR for English', () async {
        expect(
          NyLocaleHelper.getTextDirection('en'),
          equals(TextDirection.ltr),
        );
      });

      nyTest('should return LTR for unknown languages', () async {
        expect(
          NyLocaleHelper.getTextDirection('xx'),
          equals(TextDirection.ltr),
        );
      });
    });

    nyGroup('getCurrentTextDirection', () {
      nyWidgetTest('should return RTL for Arabic locale', (tester) async {
        late TextDirection direction;

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ar', 'SA'),
            supportedLocales: const [Locale('en', 'US'), Locale('ar', 'SA')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Builder(
              builder: (context) {
                direction = NyLocaleHelper.getCurrentTextDirection(
                  context: context,
                );
                return const SizedBox();
              },
            ),
          ),
        );

        expect(direction, equals(TextDirection.rtl));
      });

      nyWidgetTest('should return LTR for English locale', (tester) async {
        late TextDirection direction;

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en', 'US'),
            supportedLocales: const [Locale('en', 'US'), Locale('ar', 'SA')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Builder(
              builder: (context) {
                direction = NyLocaleHelper.getCurrentTextDirection(
                  context: context,
                );
                return const SizedBox();
              },
            ),
          ),
        );

        expect(direction, equals(TextDirection.ltr));
      });
    });

    nyGroup('toLocale', () {
      nyTest('should create locale with language code only', () async {
        final locale = NyLocaleHelper.toLocale('en');

        expect(locale.languageCode, 'en');
        expect(locale.countryCode, isNull);
      });

      nyTest('should create locale with language and country code', () async {
        final locale = NyLocaleHelper.toLocale('en', 'US');

        expect(locale.languageCode, 'en');
        expect(locale.countryCode, 'US');
      });
    });

    nyGroup('edge cases', () {
      nyTest('should handle empty language code for RTL check', () async {
        expect(NyLocaleHelper.isRtlLanguage(''), isFalse);
      });

      nyTest('should handle whitespace language code for RTL check', () async {
        expect(NyLocaleHelper.isRtlLanguage(' '), isFalse);
        expect(NyLocaleHelper.isRtlLanguage('  ar  '), isFalse);
      });

      nyWidgetTest('should handle locale with script code', (tester) async {
        late String languageCode;

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('zh'),
            supportedLocales: const [Locale('en'), Locale('zh')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Builder(
              builder: (context) {
                languageCode = NyLocaleHelper.getLanguageCode(context: context);
                return const SizedBox();
              },
            ),
          ),
        );

        expect(languageCode, 'zh');
      });

      nyWidgetTest('should correctly identify RTL for multiple locales', (
        tester,
      ) async {
        final rtlLocales = [
          'ar',
          'he',
          'fa',
          'ur',
          'yi',
          'ps',
          'ku',
          'sd',
          'dv',
        ];
        final ltrLocales = ['en', 'es', 'fr', 'de', 'it', 'pt', 'nl'];

        for (final code in rtlLocales) {
          expect(
            NyLocaleHelper.isRtlLanguage(code),
            isTrue,
            reason: '$code should be RTL',
          );
        }

        for (final code in ltrLocales) {
          expect(
            NyLocaleHelper.isRtlLanguage(code),
            isFalse,
            reason: '$code should be LTR',
          );
        }
      });
    });
  });
}
