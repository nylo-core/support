import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nylo_support/localization/ny_localization.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('LocaleType enum', () {
    nyTest('should have device value', () async {
      expect(LocaleType.device, isNotNull);
      expect(LocaleType.device.index, 0);
    });

    nyTest('should have asDefined value', () async {
      expect(LocaleType.asDefined, isNotNull);
      expect(LocaleType.asDefined.index, 1);
    });

    nyTest('should have exactly 2 values', () async {
      expect(LocaleType.values.length, 2);
    });

    nyTest('should contain both values', () async {
      expect(LocaleType.values, contains(LocaleType.device));
      expect(LocaleType.values, contains(LocaleType.asDefined));
    });
  });

  nyGroup('NyLocalization', () {
    nyGroup('singleton', () {
      nyTest('should return same instance on multiple calls', () async {
        final instance1 = NyLocalization.instance;
        final instance2 = NyLocalization.instance;

        expect(identical(instance1, instance2), isTrue);
      });

      nyTest('should be a NyLocalization instance', () async {
        expect(NyLocalization.instance, isA<NyLocalization>());
      });
    });

    nyGroup('locale property', () {
      nyTest(
        'should return default English locale when not initialized',
        () async {
          // Note: In test mode, without initialization, defaults to 'en'
          final locale = NyLocalization.instance.locale;

          expect(locale, isA<Locale>());
        },
      );

      nyTest('should return languageCode as string', () async {
        final languageCode = NyLocalization.instance.languageCode;

        expect(languageCode, isA<String>());
        expect(languageCode, isNotEmpty);
      });
    });

    nyGroup('delegates', () {
      nyTest('should return localization delegates', () async {
        final delegates = NyLocalization.instance.delegates;

        expect(delegates, isA<Iterable<LocalizationsDelegate>>());
        expect(delegates, isNotEmpty);
      });

      nyTest('should contain GlobalMaterialLocalizations delegate', () async {
        final delegates = NyLocalization.instance.delegates.toList();

        expect(delegates, contains(GlobalMaterialLocalizations.delegate));
      });

      nyTest('should contain GlobalWidgetsLocalizations delegate', () async {
        final delegates = NyLocalization.instance.delegates.toList();

        expect(delegates, contains(GlobalWidgetsLocalizations.delegate));
      });

      nyTest('should contain GlobalCupertinoLocalizations delegate', () async {
        final delegates = NyLocalization.instance.delegates.toList();

        expect(delegates, contains(GlobalCupertinoLocalizations.delegate));
      });

      nyTest('should contain DefaultCupertinoLocalizations delegate', () async {
        final delegates = NyLocalization.instance.delegates.toList();

        expect(delegates, contains(DefaultCupertinoLocalizations.delegate));
      });

      nyTest('should contain exactly 4 delegates', () async {
        final delegates = NyLocalization.instance.delegates.toList();

        expect(delegates.length, 4);
      });
    });

    nyGroup('translate', () {
      nyTest(
        'should return key when values not loaded and key contains dot',
        () async {
          // Without initialization, _values is null, returns key safely
          final result = NyLocalization.instance.translate('nested.key');
          expect(result, 'nested.key');
        },
      );

      nyTest(
        'should return key directly when values null and no dot in key',
        () async {
          // For non-nested keys, returns key when values null
          final result = NyLocalization.instance.translate('simple_key');
          expect(result, 'simple_key');
        },
      );
    });

    nyGroup('hasTranslation', () {
      nyTest('should return false when values not loaded', () async {
        // Without initialization, _values is null
        // hasTranslation returns false when _values is null
        final result = NyLocalization.instance.hasTranslation('any_key');

        // hasTranslation checks _values == null first, returns false
        expect(result, isFalse);
      });
    });

    nyGroup('getAllKeys', () {
      nyTest('should return empty list when values not loaded', () async {
        // Without proper initialization, getAllKeys returns empty
        final keys = NyLocalization.instance.getAllKeys();

        expect(keys, isA<List<String>>());
      });

      nyTest('should return a list type', () async {
        final keys = NyLocalization.instance.getAllKeys();

        expect(keys, isA<List<String>>());
      });
    });

    nyGroup('setDebugMissingKeys', () {
      nyTest('should accept true value', () async {
        // This should not throw
        NyLocalization.instance.setDebugMissingKeys(true);

        // No assertion needed - if it doesn't throw, it passed
        expect(true, isTrue);
      });

      nyTest('should accept false value', () async {
        // This should not throw
        NyLocalization.instance.setDebugMissingKeys(false);

        expect(true, isTrue);
      });

      nyTest('should be able to toggle multiple times', () async {
        NyLocalization.instance.setDebugMissingKeys(true);
        NyLocalization.instance.setDebugMissingKeys(false);
        NyLocalization.instance.setDebugMissingKeys(true);
        NyLocalization.instance.setDebugMissingKeys(false);

        expect(true, isTrue);
      });
    });

    nyGroup('nested key handling', () {
      nyTest(
        'should return key when accessing nested keys without initialization',
        () async {
          // Keys with dots return the key safely when _values is null
          final result = NyLocalization.instance.translate(
            'parent.child.grandchild',
          );
          expect(result, 'parent.child.grandchild');
        },
      );
    });

    nyGroup('argument substitution', () {
      nyTest(
        'should return key without initialization when translate called',
        () async {
          // Without initialization, _values is null, returns key safely
          final result = NyLocalization.instance.translate('hello_{{name}}', {
            'name': 'World',
          });
          expect(result, 'hello_{{name}}');
        },
      );
    });

    nyGroup('isDirectionRTL', () {
      nyWidgetTest('should return true for RTL context', (tester) async {
        late bool isRtl;

        await tester.pumpWidget(
          MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Builder(
                builder: (context) {
                  isRtl = NyLocalization.instance.isDirectionRTL(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        );

        expect(isRtl, isTrue);
      });

      nyWidgetTest('should return false for LTR context', (tester) async {
        late bool isRtl;

        await tester.pumpWidget(
          MaterialApp(
            home: Directionality(
              textDirection: TextDirection.ltr,
              child: Builder(
                builder: (context) {
                  isRtl = NyLocalization.instance.isDirectionRTL(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        );

        expect(isRtl, isFalse);
      });
    });
  });

  nyGroup('Translation extension on String', () {
    nyTest('should return key when localization not initialized', () async {
      // The tr() extension method calls translate internally
      // which returns key when _values is null
      final result = 'test_key'.tr();
      expect(result, 'test_key');
    });

    nyTest('should return key with arguments when not initialized', () async {
      final result = 'greeting_{{name}}'.tr(arguments: {'name': 'Test'});
      expect(result, 'greeting_{{name}}');
    });
  });

  nyGroup('NyLocalization setLocale', () {
    nyTest('should throw when loading fails without environment setup', () async {
      // setLocale will try to load file and when it fails, NyLogger.error is called
      // NyLogger.error requires environment to be initialized
      expect(
        () => NyLocalization.instance.setLocale(locale: const Locale('fr')),
        throwsA(isA<StateError>()),
      );
    });
  });

  nyGroup('edge cases and error handling', () {
    nyTest('should return key when translate called without init', () async {
      // translate returns key safely when _values is null
      final result = NyLocalization.instance.translate('any_key');
      expect(result, 'any_key');
    });

    nyTest('hasTranslation should return false safely without init', () async {
      // hasTranslation has null check so it should return false safely
      final result = NyLocalization.instance.hasTranslation('any_key');
      expect(result, isFalse);
    });

    nyTest('getAllKeys should return empty list safely without init', () async {
      // getAllKeys has null check so it should return empty safely
      final result = NyLocalization.instance.getAllKeys();
      expect(result, isEmpty);
    });
  });

  nyGroup('concurrent operations', () {
    nyTest('should handle multiple hasTranslation calls', () async {
      final results = <bool>[];

      for (int i = 0; i < 10; i++) {
        results.add(NyLocalization.instance.hasTranslation('key_$i'));
      }

      expect(results.length, 10);
      for (int i = 0; i < 10; i++) {
        expect(results[i], isFalse);
      }
    });
  });

  nyGroup('fallback locale', () {
    nyTest(
      'should return fallback translation for missing top-level key',
      () async {
        NyLocalization.instance.setValuesForTesting(
          values: {'farewell': 'Tschüss'},
          fallbackValues: {'greeting': 'Hello', 'farewell': 'Goodbye'},
        );

        // 'greeting' missing in de, present in en fallback
        expect(NyLocalization.instance.translate('greeting'), 'Hello');
        // 'farewell' present in de, should use de value
        expect(NyLocalization.instance.translate('farewell'), 'Tschüss');
      },
    );

    nyTest(
      'should return fallback translation for missing nested key',
      () async {
        NyLocalization.instance.setValuesForTesting(
          values: {
            'content': {'videos': 'Videos'},
          },
          fallbackValues: {
            'content': {'ebooks': 'Ebooks', 'videos': 'Videos'},
          },
        );

        // 'content.ebooks' missing in current locale
        expect(NyLocalization.instance.translate('content.ebooks'), 'Ebooks');
        // 'content.videos' present in current locale
        expect(NyLocalization.instance.translate('content.videos'), 'Videos');
      },
    );

    nyTest(
      'should return key when missing in both current and fallback',
      () async {
        NyLocalization.instance.setValuesForTesting(
          values: {'a': '1'},
          fallbackValues: {'b': '2'},
        );

        expect(NyLocalization.instance.translate('missing'), 'missing');
      },
    );

    nyTest('should return key when no fallback values are set', () async {
      NyLocalization.instance.setValuesForTesting(values: {'a': '1'});

      expect(NyLocalization.instance.translate('missing'), 'missing');
    });

    nyTest(
      'should support argument substitution with fallback value',
      () async {
        NyLocalization.instance.setValuesForTesting(
          values: {},
          fallbackValues: {'welcome': 'Welcome, {{name}}!'},
        );

        expect(
          NyLocalization.instance.translate('welcome', {'name': 'Alice'}),
          'Welcome, Alice!',
        );
      },
    );
  });
}
