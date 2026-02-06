import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

/// Currency meta data
class CurrencyMeta {
  /// Currency symbol
  String symbol;

  /// Initial value
  String initialValue = "";

  /// Currency formatter
  CurrencyInputFormatter formatter;

  CurrencyMeta({
    required this.symbol,
    required this.formatter,
    this.initialValue = "",
  });
}

/// Symbol position for currency formatting
enum _SymbolPosition { leading, trailing, leadingWithSpace, trailingWithSpace }

/// Currency definition
class _CurrencyDef {
  final String symbol;
  final _SymbolPosition position;

  const _CurrencyDef(this.symbol, this.position);
}

/// Currency input matcher
class CurrencyInputMatcher {
  static const _currencyDefinitions = <String, _CurrencyDef>{
    'gbp': _CurrencyDef('£', _SymbolPosition.leading),
    'usd': _CurrencyDef('\$', _SymbolPosition.leading),
    'vnd': _CurrencyDef('₫', _SymbolPosition.trailingWithSpace),
    'thb': _CurrencyDef('฿', _SymbolPosition.trailingWithSpace),
    'twd': _CurrencyDef('NT\$', _SymbolPosition.leading),
    'eur': _CurrencyDef('€', _SymbolPosition.trailingWithSpace),
    'myr': _CurrencyDef('RM', _SymbolPosition.leading),
    'jpy': _CurrencyDef('¥', _SymbolPosition.leading),
    'aud': _CurrencyDef('A\$', _SymbolPosition.leading),
    'cny': _CurrencyDef('¥', _SymbolPosition.leading),
    'cad': _CurrencyDef('CA\$', _SymbolPosition.leading),
    'inr': _CurrencyDef('₹', _SymbolPosition.leading),
    'idr': _CurrencyDef('Rp', _SymbolPosition.leading),
    'sgd': _CurrencyDef('S\$', _SymbolPosition.leading),
    'zar': _CurrencyDef('R', _SymbolPosition.leading),
    'pkr': _CurrencyDef('Rs', _SymbolPosition.leading),
    'chf': _CurrencyDef('CHF', _SymbolPosition.leadingWithSpace),
    'brl': _CurrencyDef('R\$', _SymbolPosition.leading),
    'rub': _CurrencyDef('₽', _SymbolPosition.trailingWithSpace),
    'krw': _CurrencyDef('₩', _SymbolPosition.leading),
    'mxn': _CurrencyDef('MX\$', _SymbolPosition.leading),
    'hkd': _CurrencyDef('HK\$', _SymbolPosition.leading),
    'nzd': _CurrencyDef('NZ\$', _SymbolPosition.leading),
    'sek': _CurrencyDef('kr', _SymbolPosition.trailingWithSpace),
    'aed': _CurrencyDef('د.إ', _SymbolPosition.trailingWithSpace),
    'dkk': _CurrencyDef('kr', _SymbolPosition.trailingWithSpace),
    'pln': _CurrencyDef('zł', _SymbolPosition.trailingWithSpace),
    'try': _CurrencyDef('₺', _SymbolPosition.leading),
    'ngn': _CurrencyDef('₦', _SymbolPosition.leading),
    'php': _CurrencyDef('₱', _SymbolPosition.leading),
    'egp': _CurrencyDef('E£', _SymbolPosition.leading),
    'ars': _CurrencyDef('AR\$', _SymbolPosition.leading),
    'clp': _CurrencyDef('CL\$', _SymbolPosition.leading),
    'cop': _CurrencyDef('CO\$', _SymbolPosition.leading),
    'pen': _CurrencyDef('S/', _SymbolPosition.leading),
    'uah': _CurrencyDef('₴', _SymbolPosition.leading),
    'ils': _CurrencyDef('₪', _SymbolPosition.leading),
    'czk': _CurrencyDef('Kč', _SymbolPosition.trailingWithSpace),
    'nok': _CurrencyDef('kr', _SymbolPosition.trailingWithSpace),
    'bhd': _CurrencyDef('BD', _SymbolPosition.trailingWithSpace),
    'kwd': _CurrencyDef('KD', _SymbolPosition.trailingWithSpace),
    'qar': _CurrencyDef('QR', _SymbolPosition.trailingWithSpace),
    'sar': _CurrencyDef('SR', _SymbolPosition.trailingWithSpace),
    'ron': _CurrencyDef('lei', _SymbolPosition.trailingWithSpace),
    'hrk': _CurrencyDef('kn', _SymbolPosition.trailingWithSpace),
    'bgn': _CurrencyDef('лв', _SymbolPosition.trailingWithSpace),
    'huf': _CurrencyDef('Ft', _SymbolPosition.trailingWithSpace),
    'mad': _CurrencyDef('DH', _SymbolPosition.trailingWithSpace),
    'isk': _CurrencyDef('kr', _SymbolPosition.trailingWithSpace),
    'kzt': _CurrencyDef('₸', _SymbolPosition.trailingWithSpace),
    'lkr': _CurrencyDef('Rs', _SymbolPosition.leadingWithSpace),
    'mmk': _CurrencyDef('K', _SymbolPosition.trailingWithSpace),
    'bdt': _CurrencyDef('৳', _SymbolPosition.leading),
    'kes': _CurrencyDef('KSh', _SymbolPosition.leadingWithSpace),
    'tzs': _CurrencyDef('TSh', _SymbolPosition.leadingWithSpace),
    'ugx': _CurrencyDef('USh', _SymbolPosition.leadingWithSpace),
    'rwf': _CurrencyDef('FRw', _SymbolPosition.leadingWithSpace),
  };

  /// Get all supported currencies
  static List<String> get currencies => _currencyDefinitions.keys.toList();

  /// Get the currency meta data
  static CurrencyMeta getCurrencyMeta(
    String castTo, {
    required String value,
    void Function(num? value)? onChanged,
  }) {
    final code = castTo.replaceFirst('currency:', '');
    final def = _currencyDefinitions[code];

    if (def == null) {
      throw Exception('Currency not supported: $code');
    }

    final symbol = def.symbol;
    String defaultValue;
    CurrencyInputFormatter formatter;

    switch (def.position) {
      case _SymbolPosition.leading:
        defaultValue = '$symbol$value';
        formatter = CurrencyInputFormatter(
          onValueChange: onChanged,
          leadingSymbol: symbol,
        );
      case _SymbolPosition.leadingWithSpace:
        defaultValue = '$symbol $value';
        formatter = CurrencyInputFormatter(
          onValueChange: onChanged,
          leadingSymbol: '$symbol ',
        );
      case _SymbolPosition.trailing:
        defaultValue = '$value$symbol';
        formatter = CurrencyInputFormatter(
          onValueChange: onChanged,
          trailingSymbol: symbol,
        );
      case _SymbolPosition.trailingWithSpace:
        defaultValue = '$value $symbol';
        formatter = CurrencyInputFormatter(
          onValueChange: onChanged,
          trailingSymbol: ' $symbol',
        );
    }

    return CurrencyMeta(
      symbol: symbol,
      formatter: formatter,
      initialValue: defaultValue,
    );
  }
}
