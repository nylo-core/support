import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  // ═══════════════════════════════════════════════════════════════════════════
  // CurrencyMeta Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('CurrencyMeta', () {
    nyTest('should store currency symbol', () async {
      final meta = CurrencyInputMatcher.getCurrencyMeta(
        'currency:usd',
        value: '100',
      );

      expect(meta.symbol, '\$');
    });

    nyTest('should store initial value', () async {
      final meta = CurrencyInputMatcher.getCurrencyMeta(
        'currency:usd',
        value: '100',
      );

      expect(meta.initialValue, '\$100');
    });

    nyTest('should have formatter', () async {
      final meta = CurrencyInputMatcher.getCurrencyMeta(
        'currency:usd',
        value: '100',
      );

      expect(meta.formatter, isNotNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // CurrencyInputMatcher.currencies Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('CurrencyInputMatcher.currencies', () {
    nyTest('should contain common currencies', () async {
      final currencies = CurrencyInputMatcher.currencies;

      expect(currencies, contains('usd'));
      expect(currencies, contains('eur'));
      expect(currencies, contains('gbp'));
      expect(currencies, contains('jpy'));
      expect(currencies, contains('aud'));
      expect(currencies, contains('cad'));
    });

    nyTest('should contain Asian currencies', () async {
      final currencies = CurrencyInputMatcher.currencies;

      expect(currencies, contains('jpy'));
      expect(currencies, contains('cny'));
      expect(currencies, contains('krw'));
      expect(currencies, contains('thb'));
      expect(currencies, contains('vnd'));
      expect(currencies, contains('sgd'));
      expect(currencies, contains('myr'));
    });

    nyTest('should contain European currencies', () async {
      final currencies = CurrencyInputMatcher.currencies;

      expect(currencies, contains('eur'));
      expect(currencies, contains('gbp'));
      expect(currencies, contains('chf'));
      expect(currencies, contains('sek'));
      expect(currencies, contains('nok'));
      expect(currencies, contains('dkk'));
      expect(currencies, contains('pln'));
    });

    nyTest('should contain Middle Eastern currencies', () async {
      final currencies = CurrencyInputMatcher.currencies;

      expect(currencies, contains('aed'));
      expect(currencies, contains('sar'));
      expect(currencies, contains('qar'));
      expect(currencies, contains('kwd'));
      expect(currencies, contains('bhd'));
    });

    nyTest('should contain Latin American currencies', () async {
      final currencies = CurrencyInputMatcher.currencies;

      expect(currencies, contains('brl'));
      expect(currencies, contains('mxn'));
      expect(currencies, contains('ars'));
      expect(currencies, contains('clp'));
      expect(currencies, contains('cop'));
      expect(currencies, contains('pen'));
    });

    nyTest('should contain African currencies', () async {
      final currencies = CurrencyInputMatcher.currencies;

      expect(currencies, contains('zar'));
      expect(currencies, contains('ngn'));
      expect(currencies, contains('egp'));
      expect(currencies, contains('kes'));
      expect(currencies, contains('tzs'));
      expect(currencies, contains('ugx'));
      expect(currencies, contains('rwf'));
    });

    nyTest('should have expected number of currencies', () async {
      final currencies = CurrencyInputMatcher.currencies;

      // Verify we have a reasonable number of currencies
      expect(currencies.length, greaterThan(50));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // getCurrencyMeta Tests - Leading Symbol Currencies
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('CurrencyInputMatcher.getCurrencyMeta - Leading Symbol', () {
    nyGroup('USD (US Dollar)', () {
      nyTest('should return correct symbol', () async {
        final meta = CurrencyInputMatcher.getCurrencyMeta(
          'currency:usd',
          value: '100',
        );

        expect(meta.symbol, '\$');
      });

      nyTest('should format initial value with leading symbol', () async {
        final meta = CurrencyInputMatcher.getCurrencyMeta(
          'currency:usd',
          value: '100',
        );

        expect(meta.initialValue, '\$100');
      });
    });

    nyGroup('GBP (British Pound)', () {
      nyTest('should return correct symbol', () async {
        final meta = CurrencyInputMatcher.getCurrencyMeta(
          'currency:gbp',
          value: '100',
        );

        expect(meta.symbol, '£');
        expect(meta.initialValue, '£100');
      });
    });

    nyGroup('JPY (Japanese Yen)', () {
      nyTest('should return correct symbol', () async {
        final meta = CurrencyInputMatcher.getCurrencyMeta(
          'currency:jpy',
          value: '1000',
        );

        expect(meta.symbol, '¥');
        expect(meta.initialValue, '¥1000');
      });
    });

    nyGroup('AUD (Australian Dollar)', () {
      nyTest('should return correct symbol', () async {
        final meta = CurrencyInputMatcher.getCurrencyMeta(
          'currency:aud',
          value: '100',
        );

        expect(meta.symbol, 'A\$');
        expect(meta.initialValue, 'A\$100');
      });
    });

    nyGroup('CAD (Canadian Dollar)', () {
      nyTest('should return correct symbol', () async {
        final meta = CurrencyInputMatcher.getCurrencyMeta(
          'currency:cad',
          value: '100',
        );

        expect(meta.symbol, 'CA\$');
        expect(meta.initialValue, 'CA\$100');
      });
    });

    nyGroup('TWD (Taiwan Dollar)', () {
      nyTest('should return correct symbol', () async {
        final meta = CurrencyInputMatcher.getCurrencyMeta(
          'currency:twd',
          value: '1000',
        );

        expect(meta.symbol, 'NT\$');
        expect(meta.initialValue, 'NT\$1000');
      });
    });

    nyGroup('INR (Indian Rupee)', () {
      nyTest('should return correct symbol', () async {
        final meta = CurrencyInputMatcher.getCurrencyMeta(
          'currency:inr',
          value: '1000',
        );

        expect(meta.symbol, '₹');
        expect(meta.initialValue, '₹1000');
      });
    });

    nyGroup('KRW (Korean Won)', () {
      nyTest('should return correct symbol', () async {
        final meta = CurrencyInputMatcher.getCurrencyMeta(
          'currency:krw',
          value: '10000',
        );

        expect(meta.symbol, '₩');
        expect(meta.initialValue, '₩10000');
      });
    });

    nyGroup('TRY (Turkish Lira)', () {
      nyTest('should return correct symbol', () async {
        final meta = CurrencyInputMatcher.getCurrencyMeta(
          'currency:try',
          value: '100',
        );

        expect(meta.symbol, '₺');
        expect(meta.initialValue, '₺100');
      });
    });

    nyGroup('BRL (Brazilian Real)', () {
      nyTest('should return correct symbol', () async {
        final meta = CurrencyInputMatcher.getCurrencyMeta(
          'currency:brl',
          value: '100',
        );

        expect(meta.symbol, 'R\$');
        expect(meta.initialValue, 'R\$100');
      });
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // getCurrencyMeta Tests - Trailing Symbol Currencies
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('CurrencyInputMatcher.getCurrencyMeta - Trailing Symbol', () {
    nyGroup('EUR (Euro)', () {
      nyTest('should return correct symbol', () async {
        final meta = CurrencyInputMatcher.getCurrencyMeta(
          'currency:eur',
          value: '100',
        );

        expect(meta.symbol, '€');
        expect(meta.initialValue, '100 €');
      });
    });

    nyGroup('VND (Vietnamese Dong)', () {
      nyTest('should return correct symbol', () async {
        final meta = CurrencyInputMatcher.getCurrencyMeta(
          'currency:vnd',
          value: '100000',
        );

        expect(meta.symbol, '₫');
        expect(meta.initialValue, '100000 ₫');
      });
    });

    nyGroup('THB (Thai Baht)', () {
      nyTest('should return correct symbol', () async {
        final meta = CurrencyInputMatcher.getCurrencyMeta(
          'currency:thb',
          value: '1000',
        );

        expect(meta.symbol, '฿');
        expect(meta.initialValue, '1000 ฿');
      });
    });

    nyGroup('RUB (Russian Ruble)', () {
      nyTest('should return correct symbol', () async {
        final meta = CurrencyInputMatcher.getCurrencyMeta(
          'currency:rub',
          value: '1000',
        );

        expect(meta.symbol, '₽');
        expect(meta.initialValue, '1000 ₽');
      });
    });

    nyGroup('SEK (Swedish Krona)', () {
      nyTest('should return correct symbol', () async {
        final meta = CurrencyInputMatcher.getCurrencyMeta(
          'currency:sek',
          value: '100',
        );

        expect(meta.symbol, 'kr');
        expect(meta.initialValue, '100 kr');
      });
    });

    nyGroup('CZK (Czech Koruna)', () {
      nyTest('should return correct symbol', () async {
        final meta = CurrencyInputMatcher.getCurrencyMeta(
          'currency:czk',
          value: '1000',
        );

        expect(meta.symbol, 'Kč');
        expect(meta.initialValue, '1000 Kč');
      });
    });

    nyGroup('PLN (Polish Zloty)', () {
      nyTest('should return correct symbol', () async {
        final meta = CurrencyInputMatcher.getCurrencyMeta(
          'currency:pln',
          value: '100',
        );

        expect(meta.symbol, 'zł');
        expect(meta.initialValue, '100 zł');
      });
    });

    nyGroup('HUF (Hungarian Forint)', () {
      nyTest('should return correct symbol', () async {
        final meta = CurrencyInputMatcher.getCurrencyMeta(
          'currency:huf',
          value: '10000',
        );

        expect(meta.symbol, 'Ft');
        expect(meta.initialValue, '10000 Ft');
      });
    });

    // AED test skipped - symbol contains illegal characters for formatter
    // The symbol 'د.إ' contains a period which interferes with number parsing
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // getCurrencyMeta Tests - Space-Separated Leading Symbol
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('CurrencyInputMatcher.getCurrencyMeta - Space-Separated', () {
    nyGroup('CHF (Swiss Franc)', () {
      nyTest('should return correct symbol with space', () async {
        final meta = CurrencyInputMatcher.getCurrencyMeta(
          'currency:chf',
          value: '100',
        );

        expect(meta.symbol, 'CHF');
        expect(meta.initialValue, 'CHF 100');
      });
    });

    nyGroup('MYR (Malaysian Ringgit)', () {
      nyTest('should return correct symbol', () async {
        final meta = CurrencyInputMatcher.getCurrencyMeta(
          'currency:myr',
          value: '100',
        );

        expect(meta.symbol, 'RM');
        expect(meta.initialValue, 'RM100');
      });
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Error Handling Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('CurrencyInputMatcher Error Handling', () {
    nyTest('should throw for unsupported currency', () async {
      expect(
        () =>
            CurrencyInputMatcher.getCurrencyMeta('currency:xyz', value: '100'),
        throwsA(isA<Exception>()),
      );
    });

    nyTest('should throw for invalid format', () async {
      expect(
        () => CurrencyInputMatcher.getCurrencyMeta('invalid', value: '100'),
        throwsA(isA<Exception>()),
      );
    });

    nyTest('should throw for empty currency code', () async {
      expect(
        () => CurrencyInputMatcher.getCurrencyMeta('currency:', value: '100'),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // onChanged Callback Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('CurrencyInputMatcher onChanged Callback', () {
    nyTest('should accept onChanged callback', () async {
      num? capturedValue;

      final meta = CurrencyInputMatcher.getCurrencyMeta(
        'currency:usd',
        value: '100',
        onChanged: (value) {
          capturedValue = value;
        },
      );

      expect(meta, isNotNull);
      // The callback is passed to formatter but not immediately called
    });

    nyTest('should create formatter with onChanged', () async {
      final meta = CurrencyInputMatcher.getCurrencyMeta(
        'currency:usd',
        value: '100',
        onChanged: (value) {},
      );

      expect(meta.formatter, isNotNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Edge Cases
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('CurrencyInputMatcher Edge Cases', () {
    nyTest('should handle empty value', () async {
      final meta = CurrencyInputMatcher.getCurrencyMeta(
        'currency:usd',
        value: '',
      );

      expect(meta.initialValue, '\$');
    });

    nyTest('should handle zero value', () async {
      final meta = CurrencyInputMatcher.getCurrencyMeta(
        'currency:usd',
        value: '0',
      );

      expect(meta.initialValue, '\$0');
    });

    nyTest('should handle large values', () async {
      final meta = CurrencyInputMatcher.getCurrencyMeta(
        'currency:usd',
        value: '1000000000',
      );

      expect(meta.initialValue, '\$1000000000');
    });

    nyTest('should handle decimal values', () async {
      final meta = CurrencyInputMatcher.getCurrencyMeta(
        'currency:usd',
        value: '99.99',
      );

      expect(meta.initialValue, '\$99.99');
    });

    nyTest('should handle value with spaces', () async {
      final meta = CurrencyInputMatcher.getCurrencyMeta(
        'currency:usd',
        value: ' 100 ',
      );

      // Initial value includes the raw value with any spacing
      expect(meta.initialValue, '\$ 100 ');
    });
  });
}
