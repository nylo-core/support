import 'dart:math' as math;

import 'package:intl/intl.dart';

/// Static utility methods for working with numbers.
///
/// ```dart
/// Number.format(1234567);              // '1,234,567'
/// Number.currency(1234.56);             // '$1,234.56'
/// Number.percentage(10);                // '10%'
/// Number.fileSize(1024);                // '1 KB'
/// Number.abbreviate(1500);              // '2K'
/// Number.forHumans(1500, maxPrecision: 1); // '1.5 thousand'
/// Number.ordinal(21);                   // '21st'
/// Number.spell(123);                    // 'one hundred twenty-three'
/// ```
///
/// Available helpers:
///
/// Locale / currency defaults:
///   - [defaultLocale], [useLocale], [defaultCurrency], [useCurrency]
///
/// Formatting:
///   - [format], [currency], [percentage], [fileSize]
///   - [forHumans], [abbreviate]
///
/// Ordinal / spelling (English):
///   - [ordinal], [spell], [spellOrdinal]
///
/// Parsing:
///   - [parseInt], [parseFloat]
///
/// Math / utility:
///   - [clamp], [trim], [pairs], [between]
///   - [round], [floor], [ceil]
///   - [lerp], [scale]
///   - [gcd], [lcm], [degrees], [radians]
///
/// Random:
///   - [random]
///
/// File-size inverse / duration:
///   - [toBytes], [duration]
///
/// Range / aggregates:
///   - [range], [sum], [average], [median], [min], [max]
class Number {
  Number._();

  static String _defaultLocale = 'en_US';
  static String _defaultCurrency = 'USD';

  /// Returns the default locale used by formatting methods.
  static String defaultLocale() => _defaultLocale;

  /// Sets the default locale used by formatting methods.
  static void useLocale(String locale) => _defaultLocale = locale;

  /// Returns the default currency code.
  static String defaultCurrency() => _defaultCurrency;

  /// Sets the default currency code.
  static void useCurrency(String currency) => _defaultCurrency = currency;

  // ---------------------------------------------------------------------------
  // Formatting
  // ---------------------------------------------------------------------------

  /// Formats [number] with locale-aware separators.
  static String format(
    num number, {
    String? locale,
    int? precision,
    int? maxPrecision,
  }) {
    final formatter = NumberFormat.decimalPattern(locale ?? _defaultLocale);
    if (precision != null) formatter.minimumFractionDigits = precision;
    formatter.maximumFractionDigits = maxPrecision ?? precision ?? 3;
    return formatter.format(number);
  }

  /// Formats [number] as a currency value.
  static String currency(num number, {String? currency, String? locale}) {
    final formatter = NumberFormat.simpleCurrency(
      locale: locale ?? _defaultLocale,
      name: currency ?? _defaultCurrency,
    );
    return formatter.format(number);
  }

  /// Formats [number] as a percentage. The number is treated as the whole
  /// percentage value: `10` produces `'10%'`, not `'1000%'`.
  static String percentage(
    num number, {
    int precision = 0,
    int? maxPrecision,
    String? locale,
  }) {
    final formatter = NumberFormat.percentPattern(locale ?? _defaultLocale);
    formatter.minimumFractionDigits = precision;
    formatter.maximumFractionDigits = maxPrecision ?? precision;
    return formatter.format(number / 100);
  }

  /// Formats [bytes] as a human-readable file size.
  static String fileSize(num bytes, {int precision = 0, int? maxPrecision}) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    var i = 0;
    var value = bytes.toDouble();
    while (value.abs() >= 1024 && i < units.length - 1) {
      value /= 1024;
      i++;
    }
    return '${_formatNumber(value, precision, maxPrecision)} ${units[i]}';
  }

  /// Returns a human-readable form of [number] (1 thousand, 1 million).
  static String forHumans(num number, {int precision = 0, int? maxPrecision}) =>
      _summarize(number, precision, maxPrecision, abbreviate: false);

  /// Returns an abbreviated form of [number] (1K, 1M, 1B).
  static String abbreviate(
    num number, {
    int precision = 0,
    int? maxPrecision,
  }) => _summarize(number, precision, maxPrecision, abbreviate: true);

  static const List<List<Object>> _shortScales = [
    [1e3, 'K'],
    [1e6, 'M'],
    [1e9, 'B'],
    [1e12, 'T'],
    [1e15, 'Q'],
  ];

  static const List<List<Object>> _longScales = [
    [1e3, ' thousand'],
    [1e6, ' million'],
    [1e9, ' billion'],
    [1e12, ' trillion'],
    [1e15, ' quadrillion'],
  ];

  static String _summarize(
    num n,
    int precision,
    int? maxPrecision, {
    required bool abbreviate,
  }) {
    final scales = abbreviate ? _shortScales : _longScales;
    if (n.abs() < 1000) return _formatNumber(n, precision, maxPrecision);
    for (var i = scales.length - 1; i >= 0; i--) {
      final divisor = scales[i][0] as num;
      final suffix = scales[i][1] as String;
      if (n.abs() >= divisor) {
        return '${_formatNumber(n / divisor, precision, maxPrecision)}$suffix';
      }
    }
    return _formatNumber(n, precision, maxPrecision);
  }

  static String _formatNumber(num n, int precision, int? maxPrecision) {
    final p = maxPrecision ?? precision;
    var formatted = n.toStringAsFixed(p);
    if (maxPrecision != null) formatted = _trimZeros(formatted);
    return formatted;
  }

  // ---------------------------------------------------------------------------
  // Ordinal
  // ---------------------------------------------------------------------------

  /// Returns the ordinal form of [number] (1st, 2nd, 3rd, 4th).
  static String ordinal(int number) {
    final mod100 = number.abs() % 100;
    final mod10 = number.abs() % 10;
    String suffix;
    if (mod100 >= 11 && mod100 <= 13) {
      suffix = 'th';
    } else if (mod10 == 1) {
      suffix = 'st';
    } else if (mod10 == 2) {
      suffix = 'nd';
    } else if (mod10 == 3) {
      suffix = 'rd';
    } else {
      suffix = 'th';
    }
    return '$number$suffix';
  }

  // ---------------------------------------------------------------------------
  // Spelling (English)
  // ---------------------------------------------------------------------------

  static const List<String> _ones = [
    'zero',
    'one',
    'two',
    'three',
    'four',
    'five',
    'six',
    'seven',
    'eight',
    'nine',
    'ten',
    'eleven',
    'twelve',
    'thirteen',
    'fourteen',
    'fifteen',
    'sixteen',
    'seventeen',
    'eighteen',
    'nineteen',
  ];

  static const List<String> _tens = [
    '',
    '',
    'twenty',
    'thirty',
    'forty',
    'fifty',
    'sixty',
    'seventy',
    'eighty',
    'ninety',
  ];

  static const List<List<Object>> _spellScales = [
    [1000000000000, 'trillion'],
    [1000000000, 'billion'],
    [1000000, 'million'],
    [1000, 'thousand'],
  ];

  /// Spells out [number] in English.
  static String spell(int number) {
    if (number < 0) return 'negative ${spell(-number)}';
    if (number < 20) return _ones[number];
    if (number < 100) {
      final t = number ~/ 10;
      final o = number % 10;
      return o == 0 ? _tens[t] : '${_tens[t]}-${_ones[o]}';
    }
    if (number < 1000) {
      final h = number ~/ 100;
      final rem = number % 100;
      return rem == 0
          ? '${_ones[h]} hundred'
          : '${_ones[h]} hundred ${spell(rem)}';
    }
    for (final scale in _spellScales) {
      final divisor = scale[0] as int;
      final name = scale[1] as String;
      if (number >= divisor) {
        final whole = number ~/ divisor;
        final rem = number % divisor;
        return rem == 0
            ? '${spell(whole)} $name'
            : '${spell(whole)} $name ${spell(rem)}';
      }
    }
    return number.toString();
  }

  static const Map<String, String> _ordinalIrregular = {
    'one': 'first',
    'two': 'second',
    'three': 'third',
    'five': 'fifth',
    'eight': 'eighth',
    'nine': 'ninth',
    'twelve': 'twelfth',
  };

  /// Spells out the ordinal form of [number] in English (first, second, third).
  static String spellOrdinal(int number) {
    final spelled = spell(number);
    final words = spelled.split(RegExp(r'[\s-]'));
    final last = words.last;
    String ordinalLast;
    if (_ordinalIrregular.containsKey(last)) {
      ordinalLast = _ordinalIrregular[last]!;
    } else if (last.endsWith('y')) {
      ordinalLast = '${last.substring(0, last.length - 1)}ieth';
    } else {
      ordinalLast = '${last}th';
    }
    return spelled.substring(0, spelled.length - last.length) + ordinalLast;
  }

  // ---------------------------------------------------------------------------
  // Parsing
  // ---------------------------------------------------------------------------

  /// Parses [value] as an int, locale-aware. Returns null on failure.
  static int? parseInt(String value, {String? locale}) {
    try {
      final parsed = NumberFormat.decimalPattern(
        locale ?? _defaultLocale,
      ).parse(value);
      return parsed.toInt();
    } catch (_) {
      return null;
    }
  }

  /// Parses [value] as a double, locale-aware. Returns null on failure.
  static double? parseFloat(String value, {String? locale}) {
    try {
      return NumberFormat.decimalPattern(
        locale ?? _defaultLocale,
      ).parse(value).toDouble();
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Math / utility
  // ---------------------------------------------------------------------------

  /// Clamps [value] between [min] and [max] (inclusive).
  static T clamp<T extends num>(T value, T min, T max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  /// Removes trailing zeros from the decimal portion of [value].
  ///
  /// ```dart
  /// Number.trim(12.0);   // '12'
  /// Number.trim(12.30);  // '12.3'
  /// ```
  static String trim(num value) => _trimZeros(value.toString());

  static String _trimZeros(String value) {
    if (!value.contains('.')) return value;
    return value.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  /// Generates pairs (sub-ranges) from a range up to [to], stepping by [by].
  ///
  /// ```dart
  /// Number.pairs(25, 10);             // [[0, 9], [10, 19], [20, 25]]
  /// Number.pairs(25, 10, offset: 0);  // [[0, 10], [10, 20], [20, 25]]
  /// ```
  static List<List<int>> pairs(int to, int by, {int offset = 1}) {
    final result = <List<int>>[];
    var start = 0;
    while (start < to) {
      final end = (start + by - offset).clamp(0, to);
      result.add([start, end]);
      start += by;
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Random
  // ---------------------------------------------------------------------------

  static final math.Random _random = math.Random.secure();

  /// Returns a random integer in `[min, max]` (inclusive).
  ///
  /// Pass [seed] for a deterministic sequence (useful in tests). The default
  /// upper bound is `0x7fffffff` (2^31 - 1) so the call is safe on all
  /// platforms including dart2js.
  static int random({int min = 0, int max = 0x7fffffff, int? seed}) {
    if (max < min) throw ArgumentError('max must be >= min');
    final rng = seed == null ? _random : math.Random(seed);
    return min + rng.nextInt(max - min + 1);
  }

  // ---------------------------------------------------------------------------
  // Predicate / clamp helpers
  // ---------------------------------------------------------------------------

  /// Returns true when [value] is between [min] and [max] (inclusive).
  static bool between(num value, {required num min, required num max}) =>
      value >= min && value <= max;

  // ---------------------------------------------------------------------------
  // Precision rounding
  // ---------------------------------------------------------------------------

  /// Rounds [value] to [precision] decimal places.
  static double round(num value, [int precision = 0]) {
    final f = math.pow(10, precision);
    return (value * f).round() / f;
  }

  /// Floors [value] to [precision] decimal places.
  static double floor(num value, [int precision = 0]) {
    final f = math.pow(10, precision);
    return (value * f).floor() / f;
  }

  /// Ceils [value] to [precision] decimal places.
  static double ceil(num value, [int precision = 0]) {
    final f = math.pow(10, precision);
    return (value * f).ceil() / f;
  }

  // ---------------------------------------------------------------------------
  // Interpolation / scaling
  // ---------------------------------------------------------------------------

  /// Linearly interpolates between [a] and [b] by [t] (0..1).
  static double lerp(num a, num b, double t) => a + (b - a) * t;

  /// Re-maps [value] from one range to another.
  ///
  /// ```dart
  /// Number.scale(0.5, fromMin: 0, fromMax: 1, toMin: 0, toMax: 100); // 50
  /// ```
  static double scale(
    num value, {
    required num fromMin,
    required num fromMax,
    required num toMin,
    required num toMax,
  }) {
    final fromRange = fromMax - fromMin;
    if (fromRange == 0) return toMin.toDouble();
    return toMin + (value - fromMin) * (toMax - toMin) / fromRange;
  }

  // ---------------------------------------------------------------------------
  // Math
  // ---------------------------------------------------------------------------

  /// Greatest common divisor of [a] and [b].
  static int gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  /// Least common multiple of [a] and [b].
  static int lcm(int a, int b) {
    if (a == 0 || b == 0) return 0;
    return (a.abs() ~/ gcd(a, b)) * b.abs();
  }

  /// Converts radians to degrees.
  static double degrees(num radians) => radians * 180 / math.pi;

  /// Converts degrees to radians.
  static double radians(num degrees) => degrees * math.pi / 180;

  // ---------------------------------------------------------------------------
  // File-size inverse / duration
  // ---------------------------------------------------------------------------

  static const Map<String, int> _byteUnits = {
    'B': 1,
    'KB': 1024,
    'MB': 1024 * 1024,
    'GB': 1024 * 1024 * 1024,
    'TB': 1024 * 1024 * 1024 * 1024,
    'PB': 1024 * 1024 * 1024 * 1024 * 1024,
  };

  /// Converts a file size to bytes. Inverse of [fileSize].
  ///
  /// Pass either a parseable string (`'1.5 KB'`) or a number with [unit]
  /// (`Number.toBytes(1.5, 'KB')`). Returns `null` on parse failure.
  static num? toBytes(Object value, [String? unit]) {
    if (value is num) {
      final mult = _byteUnits[(unit ?? 'B').toUpperCase()];
      if (mult == null) return null;
      return value * mult;
    }
    if (value is String) {
      final m = RegExp(
        r'^\s*(-?\d+(?:\.\d+)?)\s*([a-zA-Z]+)\s*$',
      ).firstMatch(value);
      if (m == null) return null;
      final num n = double.parse(m.group(1)!);
      final mult = _byteUnits[m.group(2)!.toUpperCase()];
      if (mult == null) return null;
      return n * mult;
    }
    return null;
  }

  /// Formats [seconds] as a human-readable duration.
  ///
  /// Short form: `'1h 2m 5s'`. Long form: `'1:02:05'`.
  static String duration(num seconds, {bool short = true}) {
    final total = seconds.abs().floor();
    final negative = seconds < 0;
    final days = total ~/ 86400;
    final hours = (total % 86400) ~/ 3600;
    final minutes = (total % 3600) ~/ 60;
    final secs = total % 60;
    final sign = negative ? '-' : '';
    if (short) {
      final parts = <String>[];
      if (days > 0) parts.add('${days}d');
      if (hours > 0) parts.add('${hours}h');
      if (minutes > 0) parts.add('${minutes}m');
      if (secs > 0 || parts.isEmpty) parts.add('${secs}s');
      return '$sign${parts.join(' ')}';
    }
    final h = hours + days * 24;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = secs.toString().padLeft(2, '0');
    return h > 0 ? '$sign$h:$mm:$ss' : '$sign$minutes:$ss';
  }

  // ---------------------------------------------------------------------------
  // Range / aggregates
  // ---------------------------------------------------------------------------

  /// Generates a list of integers from [start] (inclusive) to [end] (inclusive),
  /// stepping by [step].
  static List<int> range(int start, int end, {int step = 1}) {
    if (step == 0) throw ArgumentError('step must not be zero');
    final result = <int>[];
    if (step > 0) {
      for (var i = start; i <= end; i += step) {
        result.add(i);
      }
    } else {
      for (var i = start; i >= end; i += step) {
        result.add(i);
      }
    }
    return result;
  }

  /// Returns the sum of [values].
  static num sum(Iterable<num> values) {
    var total = 0.0;
    for (final v in values) {
      total += v;
    }
    return total == total.toInt() ? total.toInt() : total;
  }

  /// Returns the arithmetic mean of [values], or `0` if empty.
  static double average(Iterable<num> values) {
    if (values.isEmpty) return 0;
    return values.fold<double>(0, (a, b) => a + b) / values.length;
  }

  /// Returns the median of [values], or `0` if empty.
  static double median(Iterable<num> values) {
    if (values.isEmpty) return 0;
    final sorted = [...values]..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length.isOdd) return sorted[mid].toDouble();
    return (sorted[mid - 1] + sorted[mid]) / 2;
  }

  /// Returns the smallest value in [values].
  static num min(Iterable<num> values) {
    if (values.isEmpty) {
      throw ArgumentError('values must not be empty');
    }
    return values.reduce(math.min);
  }

  /// Returns the largest value in [values].
  static num max(Iterable<num> values) {
    if (values.isEmpty) {
      throw ArgumentError('values must not be empty');
    }
    return values.reduce(math.max);
  }
}
