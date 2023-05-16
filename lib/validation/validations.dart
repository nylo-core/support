import 'package:nylo_support/validation/rules.dart';

/// Default validation rules for Nylo
final Map<Type, dynamic> nyDefaultValidations = {
  EmailRule: (attribute) => EmailRule(attribute),
  BooleanRule: (attribute) => BooleanRule(attribute),
  ContainsRule: (attribute) => ContainsRule(attribute),
  URLRule: (attribute) => URLRule(attribute),
  StringRule: (attribute) => StringRule(attribute),
  MaxRule: (attribute) => MaxRule(attribute),
  MinRule: (attribute) => MinRule(attribute),
  NotEmptyRule: (attribute) => NotEmptyRule(attribute),
  CapitalizedRule: (attribute) => CapitalizedRule(attribute),
  LowerCaseRule: (attribute) => LowerCaseRule(attribute),
  UpperCaseRule: (attribute) => UpperCaseRule(attribute),
  RegexRule: (attribute) => RegexRule(attribute),
  DateRule: (attribute) => DateRule(attribute),
  NumericRule: (attribute) => NumericRule(attribute),
  PhoneNumberUsaRule: (attribute) => PhoneNumberUsaRule(attribute),
  PhoneNumberUkRule: (attribute) => PhoneNumberUkRule(attribute),
  ZipCodeUsRule: (attribute) => ZipCodeUsRule(attribute),
  PostCodeUkRule: (attribute) => PostCodeUkRule(attribute),
};
