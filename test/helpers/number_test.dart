import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  // ===========================================================================
  // Defaults
  // ===========================================================================

  nyGroup('Number defaults', () {
    nyTest('defaultLocale starts at en_US', () async {
      expect(Number.defaultLocale(), 'en_US');
    });
    nyTest('defaultCurrency starts at USD', () async {
      expect(Number.defaultCurrency(), 'USD');
    });
    nyTest('useLocale updates default', () async {
      Number.useLocale('de');
      expect(Number.defaultLocale(), 'de');
      Number.useLocale('en_US');
    });
    nyTest('useCurrency updates default', () async {
      Number.useCurrency('EUR');
      expect(Number.defaultCurrency(), 'EUR');
      Number.useCurrency('USD');
    });
  });

  // ===========================================================================
  // Format
  // ===========================================================================

  nyGroup('Number.format', () {
    nyTest('formats with thousand separators', () async {
      expect(Number.format(1000), '1,000');
      expect(Number.format(1234567), '1,234,567');
    });
    nyTest('respects precision', () async {
      expect(Number.format(1.123, precision: 2), '1.12');
    });
    nyTest('respects maxPrecision', () async {
      expect(Number.format(1.1, maxPrecision: 3), '1.1');
      expect(Number.format(1.123456, maxPrecision: 3), '1.123');
    });
    nyTest('respects locale', () async {
      expect(Number.format(1234.5, locale: 'de', precision: 1), '1.234,5');
    });
  });

  // ===========================================================================
  // Currency
  // ===========================================================================

  nyGroup('Number.currency', () {
    nyTest('formats with default currency and locale', () async {
      expect(Number.currency(1234.56), '\$1,234.56');
    });
    nyTest('respects custom currency', () async {
      final result = Number.currency(1234.56, currency: 'EUR');
      expect(result, contains('1,234.56'));
    });
  });

  // ===========================================================================
  // Percentage
  // ===========================================================================

  nyGroup('Number.percentage', () {
    nyTest('treats input as whole percentage', () async {
      expect(Number.percentage(10), '10%');
    });
    nyTest('respects precision', () async {
      expect(Number.percentage(10, precision: 2), '10.00%');
    });
    nyTest('respects maxPrecision', () async {
      expect(Number.percentage(10.123, maxPrecision: 2), '10.12%');
    });
  });

  // ===========================================================================
  // File size
  // ===========================================================================

  nyGroup('Number.fileSize', () {
    nyTest('formats bytes', () async {
      expect(Number.fileSize(0), '0 B');
      expect(Number.fileSize(500), '500 B');
    });
    nyTest('formats KB', () async {
      expect(Number.fileSize(1024), '1 KB');
    });
    nyTest('formats MB', () async {
      expect(Number.fileSize(1024 * 1024), '1 MB');
    });
    nyTest('formats GB', () async {
      expect(Number.fileSize(1024 * 1024 * 1024), '1 GB');
    });
    nyTest('respects maxPrecision and trims', () async {
      expect(Number.fileSize(1500, maxPrecision: 2), '1.46 KB');
      expect(Number.fileSize(1024, maxPrecision: 2), '1 KB');
    });
  });

  // ===========================================================================
  // forHumans / abbreviate
  // ===========================================================================

  nyGroup('Number.forHumans', () {
    nyTest('returns plain number under 1000', () async {
      expect(Number.forHumans(999), '999');
    });
    nyTest('uses thousand', () async {
      expect(Number.forHumans(1000), '1 thousand');
    });
    nyTest('uses million', () async {
      expect(Number.forHumans(1000000), '1 million');
    });
    nyTest('uses billion', () async {
      expect(Number.forHumans(1000000000), '1 billion');
    });
    nyTest('uses trillion', () async {
      expect(Number.forHumans(1000000000000), '1 trillion');
    });
    nyTest('respects maxPrecision', () async {
      expect(Number.forHumans(1500, maxPrecision: 1), '1.5 thousand');
      expect(Number.forHumans(1234567, maxPrecision: 2), '1.23 million');
    });
    nyTest('handles negative values', () async {
      expect(Number.forHumans(-1000), '-1 thousand');
    });
  });

  nyGroup('Number.abbreviate', () {
    nyTest('returns plain number under 1000', () async {
      expect(Number.abbreviate(999), '999');
    });
    nyTest('uses K for thousands', () async {
      expect(Number.abbreviate(1000), '1K');
    });
    nyTest('uses M for millions', () async {
      expect(Number.abbreviate(1000000), '1M');
    });
    nyTest('uses B for billions', () async {
      expect(Number.abbreviate(1000000000), '1B');
    });
    nyTest('uses T for trillions', () async {
      expect(Number.abbreviate(1000000000000), '1T');
    });
    nyTest('respects maxPrecision and trims', () async {
      expect(Number.abbreviate(1500, maxPrecision: 1), '1.5K');
      expect(Number.abbreviate(1000, maxPrecision: 2), '1K');
    });
  });

  // ===========================================================================
  // Ordinal
  // ===========================================================================

  nyGroup('Number.ordinal', () {
    nyTest('handles 1st, 2nd, 3rd, 4th', () async {
      expect(Number.ordinal(1), '1st');
      expect(Number.ordinal(2), '2nd');
      expect(Number.ordinal(3), '3rd');
      expect(Number.ordinal(4), '4th');
    });
    nyTest('handles teens (11th, 12th, 13th)', () async {
      expect(Number.ordinal(11), '11th');
      expect(Number.ordinal(12), '12th');
      expect(Number.ordinal(13), '13th');
    });
    nyTest('handles 21st, 22nd, 23rd', () async {
      expect(Number.ordinal(21), '21st');
      expect(Number.ordinal(22), '22nd');
      expect(Number.ordinal(23), '23rd');
    });
    nyTest('handles 100th, 101st, 111th', () async {
      expect(Number.ordinal(100), '100th');
      expect(Number.ordinal(101), '101st');
      expect(Number.ordinal(111), '111th');
    });
    nyTest('handles 0', () async {
      expect(Number.ordinal(0), '0th');
    });
  });

  // ===========================================================================
  // Spell
  // ===========================================================================

  nyGroup('Number.spell', () {
    nyTest('spells single digits', () async {
      expect(Number.spell(0), 'zero');
      expect(Number.spell(5), 'five');
      expect(Number.spell(9), 'nine');
    });
    nyTest('spells teens', () async {
      expect(Number.spell(10), 'ten');
      expect(Number.spell(15), 'fifteen');
      expect(Number.spell(19), 'nineteen');
    });
    nyTest('spells tens', () async {
      expect(Number.spell(20), 'twenty');
      expect(Number.spell(50), 'fifty');
      expect(Number.spell(90), 'ninety');
    });
    nyTest('spells two-digit compound', () async {
      expect(Number.spell(21), 'twenty-one');
      expect(Number.spell(99), 'ninety-nine');
    });
    nyTest('spells hundreds', () async {
      expect(Number.spell(100), 'one hundred');
      expect(Number.spell(123), 'one hundred twenty-three');
    });
    nyTest('spells thousands', () async {
      expect(Number.spell(1000), 'one thousand');
      expect(Number.spell(1234), 'one thousand two hundred thirty-four');
    });
    nyTest('spells millions', () async {
      expect(Number.spell(1000000), 'one million');
    });
    nyTest('spells negative', () async {
      expect(Number.spell(-5), 'negative five');
    });
  });

  nyGroup('Number.spellOrdinal', () {
    nyTest('handles irregular ordinals', () async {
      expect(Number.spellOrdinal(1), 'first');
      expect(Number.spellOrdinal(2), 'second');
      expect(Number.spellOrdinal(3), 'third');
      expect(Number.spellOrdinal(5), 'fifth');
      expect(Number.spellOrdinal(8), 'eighth');
      expect(Number.spellOrdinal(9), 'ninth');
      expect(Number.spellOrdinal(12), 'twelfth');
    });
    nyTest('handles regular ordinals', () async {
      expect(Number.spellOrdinal(4), 'fourth');
      expect(Number.spellOrdinal(6), 'sixth');
      expect(Number.spellOrdinal(7), 'seventh');
      expect(Number.spellOrdinal(10), 'tenth');
      expect(Number.spellOrdinal(11), 'eleventh');
    });
    nyTest('handles tens (twentieth, fortieth)', () async {
      expect(Number.spellOrdinal(20), 'twentieth');
      expect(Number.spellOrdinal(40), 'fortieth');
    });
    nyTest('handles compound (twenty-first)', () async {
      expect(Number.spellOrdinal(21), 'twenty-first');
      expect(Number.spellOrdinal(43), 'forty-third');
    });
    nyTest('handles larger numbers', () async {
      expect(Number.spellOrdinal(100), 'one hundredth');
      expect(Number.spellOrdinal(1000), 'one thousandth');
    });
  });

  // ===========================================================================
  // Parsing
  // ===========================================================================

  nyGroup('Number.parseInt', () {
    nyTest('parses plain number', () async {
      expect(Number.parseInt('123'), 123);
    });
    nyTest('parses with thousand separator', () async {
      expect(Number.parseInt('1,234'), 1234);
    });
    nyTest('parses with locale', () async {
      expect(Number.parseInt('1.234', locale: 'de'), 1234);
    });
    nyTest('returns null on failure', () async {
      expect(Number.parseInt('not a number'), isNull);
    });
  });

  nyGroup('Number.parseFloat', () {
    nyTest('parses plain decimal', () async {
      expect(Number.parseFloat('1.5'), 1.5);
    });
    nyTest('parses with thousand separator', () async {
      expect(Number.parseFloat('1,234.56'), 1234.56);
    });
    nyTest('parses with locale', () async {
      expect(Number.parseFloat('1.234,56', locale: 'de'), 1234.56);
    });
    nyTest('returns null on failure', () async {
      expect(Number.parseFloat('not a number'), isNull);
    });
  });

  // ===========================================================================
  // Clamp / trim / pairs
  // ===========================================================================

  nyGroup('Number.clamp', () {
    nyTest('returns value when in range', () async {
      expect(Number.clamp(5, 0, 10), 5);
    });
    nyTest('clamps below min', () async {
      expect(Number.clamp(-1, 0, 10), 0);
    });
    nyTest('clamps above max', () async {
      expect(Number.clamp(11, 0, 10), 10);
    });
    nyTest('works with doubles', () async {
      expect(Number.clamp(1.5, 0.0, 1.0), 1.0);
    });
  });

  nyGroup('Number.trim', () {
    nyTest('trims trailing zeros', () async {
      expect(Number.trim(12.0), '12');
      expect(Number.trim(12.30), '12.3');
    });
    nyTest('keeps integers unchanged', () async {
      expect(Number.trim(42), '42');
    });
    nyTest('trims multiple zeros', () async {
      expect(Number.trim(1.5000), '1.5');
    });
  });

  nyGroup('Number.pairs', () {
    nyTest('default offset 1', () async {
      expect(Number.pairs(25, 10), [
        [0, 9],
        [10, 19],
        [20, 25],
      ]);
    });
    nyTest('custom offset 0', () async {
      expect(Number.pairs(25, 10, offset: 0), [
        [0, 10],
        [10, 20],
        [20, 25],
      ]);
    });
    nyTest('exact range divisible by step', () async {
      expect(Number.pairs(20, 10), [
        [0, 9],
        [10, 19],
      ]);
    });
  });

  // ===========================================================================
  // New helpers
  // ===========================================================================

  nyGroup('Number.random', () {
    nyTest('produces values within range', () async {
      for (var i = 0; i < 100; i++) {
        final v = Number.random(min: 5, max: 10);
        expect(v >= 5 && v <= 10, isTrue);
      }
    });
    nyTest('is deterministic with seed', () async {
      final a = Number.random(min: 0, max: 1000, seed: 42);
      final b = Number.random(min: 0, max: 1000, seed: 42);
      expect(a, b);
    });
    nyTest('default upper bound does not overflow', () async {
      // Just calling it without args must not throw a RangeError.
      expect(() => Number.random(), returnsNormally);
    });
    nyTest('throws when max < min', () async {
      expect(() => Number.random(min: 10, max: 5), throwsArgumentError);
    });
  });

  nyGroup('Number.between', () {
    nyTest('returns true when within range', () async {
      expect(Number.between(5, min: 1, max: 10), isTrue);
    });
    nyTest('returns true at boundaries (inclusive)', () async {
      expect(Number.between(1, min: 1, max: 10), isTrue);
      expect(Number.between(10, min: 1, max: 10), isTrue);
    });
    nyTest('returns false outside range', () async {
      expect(Number.between(0, min: 1, max: 10), isFalse);
      expect(Number.between(11, min: 1, max: 10), isFalse);
    });
    nyTest('works with doubles', () async {
      expect(Number.between(1.5, min: 1.0, max: 2.0), isTrue);
    });
  });

  nyGroup('Number.round', () {
    nyTest('rounds to whole number by default', () async {
      expect(Number.round(1.5), 2.0);
      expect(Number.round(1.4), 1.0);
    });
    nyTest('rounds to precision', () async {
      expect(Number.round(1.235, 2), 1.24);
      expect(Number.round(1.234, 2), 1.23);
    });
  });

  nyGroup('Number.floor', () {
    nyTest('floors to whole number by default', () async {
      expect(Number.floor(1.9), 1.0);
    });
    nyTest('floors to precision', () async {
      expect(Number.floor(1.999, 2), 1.99);
    });
  });

  nyGroup('Number.ceil', () {
    nyTest('ceils to whole number by default', () async {
      expect(Number.ceil(1.1), 2.0);
    });
    nyTest('ceils to precision', () async {
      expect(Number.ceil(1.001, 2), 1.01);
    });
  });

  nyGroup('Number.lerp', () {
    nyTest('returns a at t=0', () async {
      expect(Number.lerp(0, 100, 0), 0);
    });
    nyTest('returns b at t=1', () async {
      expect(Number.lerp(0, 100, 1), 100);
    });
    nyTest('interpolates at t=0.5', () async {
      expect(Number.lerp(0, 100, 0.5), 50);
    });
  });

  nyGroup('Number.scale', () {
    nyTest('remaps from 0..1 to 0..100', () async {
      expect(
        Number.scale(0.5, fromMin: 0, fromMax: 1, toMin: 0, toMax: 100),
        50,
      );
    });
    nyTest('remaps inverted ranges', () async {
      expect(
        Number.scale(0.25, fromMin: 0, fromMax: 1, toMin: 100, toMax: 0),
        75,
      );
    });
    nyTest('returns toMin when fromRange is 0', () async {
      expect(Number.scale(5, fromMin: 5, fromMax: 5, toMin: 10, toMax: 20), 10);
    });
  });

  nyGroup('Number.gcd', () {
    nyTest('returns greatest common divisor', () async {
      expect(Number.gcd(12, 18), 6);
      expect(Number.gcd(100, 75), 25);
    });
    nyTest('handles zero', () async {
      expect(Number.gcd(0, 5), 5);
      expect(Number.gcd(5, 0), 5);
    });
    nyTest('handles negatives', () async {
      expect(Number.gcd(-12, 18), 6);
    });
  });

  nyGroup('Number.lcm', () {
    nyTest('returns least common multiple', () async {
      expect(Number.lcm(4, 6), 12);
      expect(Number.lcm(3, 5), 15);
    });
    nyTest('returns 0 when an input is 0', () async {
      expect(Number.lcm(0, 5), 0);
    });
  });

  nyGroup('Number.degrees / radians', () {
    nyTest('converts radians to degrees', () async {
      expect(Number.degrees(3.141592653589793), closeTo(180, 0.0001));
    });
    nyTest('converts degrees to radians', () async {
      expect(Number.radians(180), closeTo(3.141592653589793, 0.0001));
    });
    nyTest('round-trips', () async {
      expect(Number.degrees(Number.radians(90)), closeTo(90, 0.0001));
    });
  });

  nyGroup('Number.toBytes', () {
    nyTest('parses string with KB', () async {
      expect(Number.toBytes('1 KB'), 1024);
    });
    nyTest('parses string with decimal', () async {
      expect(Number.toBytes('1.5 KB'), 1536);
    });
    nyTest('parses string with MB', () async {
      expect(Number.toBytes('1 MB'), 1024 * 1024);
    });
    nyTest('accepts num + unit', () async {
      expect(Number.toBytes(2, 'KB'), 2048);
    });
    nyTest('returns null for unknown unit', () async {
      expect(Number.toBytes('1 XB'), isNull);
    });
    nyTest('returns null for invalid string', () async {
      expect(Number.toBytes('not a size'), isNull);
    });
  });

  nyGroup('Number.duration', () {
    nyTest('formats short under a minute', () async {
      expect(Number.duration(45), '45s');
    });
    nyTest('formats short with minutes', () async {
      expect(Number.duration(125), '2m 5s');
    });
    nyTest('formats short with hours', () async {
      expect(Number.duration(3725), '1h 2m 5s');
    });
    nyTest('formats short with days', () async {
      expect(Number.duration(90061), '1d 1h 1m 1s');
    });
    nyTest('formats long under an hour', () async {
      expect(Number.duration(125, short: false), '2:05');
    });
    nyTest('formats long with hours', () async {
      expect(Number.duration(3725, short: false), '1:02:05');
    });
    nyTest('handles zero', () async {
      expect(Number.duration(0), '0s');
    });
    nyTest('handles negative seconds', () async {
      expect(Number.duration(-65), '-1m 5s');
    });
  });

  nyGroup('Number.range', () {
    nyTest('generates inclusive range', () async {
      expect(Number.range(1, 5), [1, 2, 3, 4, 5]);
    });
    nyTest('respects step', () async {
      expect(Number.range(0, 10, step: 2), [0, 2, 4, 6, 8, 10]);
    });
    nyTest('supports descending with negative step', () async {
      expect(Number.range(5, 1, step: -1), [5, 4, 3, 2, 1]);
    });
    nyTest('throws on zero step', () async {
      expect(() => Number.range(0, 5, step: 0), throwsArgumentError);
    });
  });

  nyGroup('Number.sum', () {
    nyTest('sums integers', () async {
      expect(Number.sum([1, 2, 3, 4]), 10);
    });
    nyTest('sums doubles', () async {
      expect(Number.sum([1.5, 2.5]), 4);
    });
    nyTest('returns 0 for empty', () async {
      expect(Number.sum([]), 0);
    });
  });

  nyGroup('Number.average', () {
    nyTest('averages values', () async {
      expect(Number.average([1, 2, 3, 4]), 2.5);
    });
    nyTest('returns 0 for empty', () async {
      expect(Number.average([]), 0);
    });
  });

  nyGroup('Number.median', () {
    nyTest('returns middle value for odd-length', () async {
      expect(Number.median([3, 1, 2]), 2);
    });
    nyTest('averages middle two for even-length', () async {
      expect(Number.median([1, 2, 3, 4]), 2.5);
    });
    nyTest('returns 0 for empty', () async {
      expect(Number.median([]), 0);
    });
  });

  nyGroup('Number.min / max', () {
    nyTest('returns minimum', () async {
      expect(Number.min([5, 1, 3]), 1);
    });
    nyTest('returns maximum', () async {
      expect(Number.max([5, 1, 3]), 5);
    });
    nyTest('throws for empty', () async {
      expect(() => Number.min([]), throwsArgumentError);
      expect(() => Number.max([]), throwsArgumentError);
    });
  });
}
