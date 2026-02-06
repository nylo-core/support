import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  // ===========================================================================
  // FormValidator constructor tests
  // ===========================================================================

  nyGroup('FormValidator constructors', () {
    nyTest('default constructor should have empty rules', () async {
      final validator = FormValidator();
      expect(validator.rules, isEmpty);
    });

    nyTest('email constructor should add email rule', () async {
      final validator = FormValidator.email();
      expect(validator.rules, hasLength(1));
    });

    nyTest('notEmpty constructor should add notEmpty rule', () async {
      final validator = FormValidator.notEmpty();
      expect(validator.rules, hasLength(1));
    });

    nyTest('password constructor should add password rule', () async {
      final validator = FormValidator.password(strength: 1);
      expect(validator.rules, hasLength(1));
    });

    nyTest('url constructor should add url rule', () async {
      final validator = FormValidator.url();
      expect(validator.rules, hasLength(1));
    });

    nyTest('numeric constructor should add numeric rule', () async {
      final validator = FormValidator.numeric();
      expect(validator.rules, hasLength(1));
    });

    nyTest('date constructor should add date rule', () async {
      final validator = FormValidator.date();
      expect(validator.rules, hasLength(1));
    });

    nyTest('minLength constructor should add minLength rule', () async {
      final validator = FormValidator.minLength(5);
      expect(validator.rules, hasLength(1));
    });

    nyTest('maxLength constructor should add maxLength rule', () async {
      final validator = FormValidator.maxLength(10);
      expect(validator.rules, hasLength(1));
    });

    nyTest('contains constructor should add contains rule', () async {
      final validator = FormValidator.contains(['a', 'b']);
      expect(validator.rules, hasLength(1));
    });

    nyTest('beginsWith constructor should add beginsWith rule', () async {
      final validator = FormValidator.beginsWith('http');
      expect(validator.rules, hasLength(1));
    });

    nyTest('endsWith constructor should add endsWith rule', () async {
      final validator = FormValidator.endsWith('.com');
      expect(validator.rules, hasLength(1));
    });

    nyTest('booleanTrue constructor should add booleanTrue rule', () async {
      final validator = FormValidator.booleanTrue();
      expect(validator.rules, hasLength(1));
    });

    nyTest('booleanFalse constructor should add booleanFalse rule', () async {
      final validator = FormValidator.booleanFalse();
      expect(validator.rules, hasLength(1));
    });

    nyTest('capitalized constructor should add capitalized rule', () async {
      final validator = FormValidator.capitalized();
      expect(validator.rules, hasLength(1));
    });

    nyTest('lowercase constructor should add lowercase rule', () async {
      final validator = FormValidator.lowercase();
      expect(validator.rules, hasLength(1));
    });

    nyTest('uppercase constructor should add uppercase rule', () async {
      final validator = FormValidator.uppercase();
      expect(validator.rules, hasLength(1));
    });

    nyTest('regex constructor should add regex rule', () async {
      final validator = FormValidator.regex(r'^[a-z]+$');
      expect(validator.rules, hasLength(1));
    });

    nyTest('custom constructor should add custom rule', () async {
      final validator = FormValidator.custom(validate: (data) => data != null);
      expect(validator.rules, hasLength(1));
    });

    nyTest('rule constructor should accept rules list', () async {
      final validator = FormValidator.rule([
        FormRuleEmail(),
        FormRuleNotEmpty(null),
      ]);
      expect(validator.rules, hasLength(2));
    });
  });

  // ===========================================================================
  // FormValidator chaining tests
  // ===========================================================================

  nyGroup('FormValidator chaining', () {
    nyTest('should chain email', () async {
      final validator = FormValidator().email();
      expect(validator.rules, hasLength(1));
      expect(validator, isA<FormValidator>());
    });

    nyTest('should chain multiple rules', () async {
      final validator = FormValidator().notEmpty().email().minLength(5);
      expect(validator.rules, hasLength(3));
    });

    nyTest('should chain password', () async {
      final validator = FormValidator().password(strength: 1);
      expect(validator.rules, hasLength(1));
    });

    nyTest('should chain contains', () async {
      final validator = FormValidator().contains(['a']);
      expect(validator.rules, hasLength(1));
    });

    nyTest('should chain beginsWith', () async {
      final validator = FormValidator().beginsWith('abc');
      expect(validator.rules, hasLength(1));
    });

    nyTest('should chain endsWith', () async {
      final validator = FormValidator().endsWith('xyz');
      expect(validator.rules, hasLength(1));
    });

    nyTest('should chain custom', () async {
      final validator = FormValidator().custom(validate: (data) => true);
      expect(validator.rules, hasLength(1));
    });

    nyTest('should chain equals', () async {
      final validator = FormValidator().equals('test');
      expect(validator.rules, hasLength(1));
    });
  });

  // ===========================================================================
  // FormValidator.check tests
  // ===========================================================================

  nyGroup('FormValidator.check', () {
    nyTest('email should pass for valid email', () async {
      final result = FormValidator.email().check('test@example.com');
      expect(result.isValid, isTrue);
    });

    nyTest('email should fail for invalid email', () async {
      final result = FormValidator.email().check('invalid');
      expect(result.isValid, isFalse);
    });

    nyTest('notEmpty should pass for non-empty string', () async {
      final result = FormValidator.notEmpty().check('hello');
      expect(result.isValid, isTrue);
    });

    nyTest('notEmpty should fail for empty string', () async {
      final result = FormValidator.notEmpty().check('');
      expect(result.isValid, isFalse);
    });

    nyTest('minLength should pass for string meeting minimum', () async {
      final result = FormValidator.minLength(3).check('abc');
      expect(result.isValid, isTrue);
    });

    nyTest('minLength should fail for short string', () async {
      final result = FormValidator.minLength(5).check('ab');
      expect(result.isValid, isFalse);
    });

    nyTest('maxLength should pass for string within maximum', () async {
      final result = FormValidator.maxLength(5).check('abc');
      expect(result.isValid, isTrue);
    });

    nyTest('maxLength should fail for long string', () async {
      final result = FormValidator.maxLength(3).check('abcdef');
      expect(result.isValid, isFalse);
    });

    nyTest('url should pass for valid URL', () async {
      final result = FormValidator.url().check('https://example.com');
      expect(result.isValid, isTrue);
    });

    nyTest('url should fail for invalid URL', () async {
      final result = FormValidator.url().check('not a url');
      expect(result.isValid, isFalse);
    });

    nyTest('numeric should pass for num value', () async {
      final result = FormValidator.numeric().check(123);
      expect(result.isValid, isTrue);
    });

    nyTest('numeric should pass for double value', () async {
      final result = FormValidator.numeric().check(3.14);
      expect(result.isValid, isTrue);
    });

    nyTest('numeric should fail for string value', () async {
      final result = FormValidator.numeric().check('abc');
      expect(result.isValid, isFalse);
    });

    nyTest('contains should pass when value is in list', () async {
      final result = FormValidator.contains(['a', 'b', 'c']).check('b');
      expect(result.isValid, isTrue);
    });

    nyTest('contains should fail when value not in list', () async {
      final result = FormValidator.contains(['a', 'b']).check('x');
      expect(result.isValid, isFalse);
    });

    nyTest('beginsWith should pass for matching prefix', () async {
      final result = FormValidator.beginsWith('Hello').check('Hello World');
      expect(result.isValid, isTrue);
    });

    nyTest('beginsWith should fail for non-matching prefix', () async {
      final result = FormValidator.beginsWith('Hello').check('World');
      expect(result.isValid, isFalse);
    });

    nyTest('endsWith should pass for matching suffix', () async {
      final result = FormValidator.endsWith('World').check('Hello World');
      expect(result.isValid, isTrue);
    });

    nyTest('endsWith should fail for non-matching suffix', () async {
      final result = FormValidator.endsWith('.com').check('example.org');
      expect(result.isValid, isFalse);
    });

    nyTest('capitalized should pass for capitalized string', () async {
      final result = FormValidator.capitalized().check('Hello');
      expect(result.isValid, isTrue);
    });

    nyTest('capitalized should fail for lowercase start', () async {
      final result = FormValidator.capitalized().check('hello');
      expect(result.isValid, isFalse);
    });

    nyTest('lowercase should pass for lowercase string', () async {
      final result = FormValidator.lowercase().check('hello');
      expect(result.isValid, isTrue);
    });

    nyTest('lowercase should fail for uppercase string', () async {
      final result = FormValidator.lowercase().check('HELLO');
      expect(result.isValid, isFalse);
    });

    nyTest('uppercase should pass for uppercase string', () async {
      final result = FormValidator.uppercase().check('HELLO');
      expect(result.isValid, isTrue);
    });

    nyTest('uppercase should fail for lowercase string', () async {
      final result = FormValidator.uppercase().check('hello');
      expect(result.isValid, isFalse);
    });

    nyTest('regex should pass for matching pattern', () async {
      final result = FormValidator.regex(r'^[a-z]+$').check('abc');
      expect(result.isValid, isTrue);
    });

    nyTest('regex should fail for non-matching pattern', () async {
      final result = FormValidator.regex(r'^[a-z]+$').check('ABC');
      expect(result.isValid, isFalse);
    });

    nyTest('booleanTrue should pass for true', () async {
      final result = FormValidator.booleanTrue().check(true);
      expect(result.isValid, isTrue);
    });

    nyTest('booleanTrue should fail for false', () async {
      final result = FormValidator.booleanTrue().check(false);
      expect(result.isValid, isFalse);
    });

    nyTest('booleanFalse should pass for false', () async {
      final result = FormValidator.booleanFalse().check(false);
      expect(result.isValid, isTrue);
    });

    nyTest('booleanFalse should fail for true', () async {
      final result = FormValidator.booleanFalse().check(true);
      expect(result.isValid, isFalse);
    });

    nyTest('custom should use custom validation function', () async {
      final result = FormValidator.custom(
        validate: (data) => data == 'magic',
      ).check('magic');
      expect(result.isValid, isTrue);
    });

    nyTest('custom should fail for failing validation', () async {
      final result = FormValidator.custom(
        validate: (data) => data == 'magic',
      ).check('not magic');
      expect(result.isValid, isFalse);
    });
  });

  // ===========================================================================
  // FormValidator.check with data parameter
  // ===========================================================================

  nyGroup('FormValidator.check with data parameter', () {
    nyTest('should accept data in check method', () async {
      final validator = FormValidator.notEmpty();
      final result = validator.check('hello');
      expect(result.isValid, isTrue);
    });

    nyTest('should use setData method', () async {
      final validator = FormValidator.notEmpty();
      validator.setData('hello');
      final result = validator.check();
      expect(result.isValid, isTrue);
    });
  });

  // ===========================================================================
  // FormValidator setAttribute
  // ===========================================================================

  nyGroup('FormValidator.setAttribute', () {
    nyTest('should set attribute name', () async {
      final validator = FormValidator();
      validator.setAttribute('email');
      expect(validator.attribute, 'email');
    });
  });

  // ===========================================================================
  // FormValidationResult tests
  // ===========================================================================

  nyGroup('FormValidationResult', () {
    nyTest('isValid should be true when all pass', () async {
      final result = FormValidator().notEmpty().email().check('test@email.com');
      expect(result.isValid, isTrue);
    });

    nyTest('isValid should be false when any fail', () async {
      final result = FormValidator().notEmpty().email().check('');
      expect(result.isValid, isFalse);
    });

    nyTest('errorMessages should return list of error messages', () async {
      final result = FormValidator.notEmpty(message: 'Required').check('');
      expect(result.errorMessages(), contains('Required'));
    });

    nyTest('errorResponses should return only errors', () async {
      final result = FormValidator().notEmpty().email().check('');
      expect(result.errorResponses, isNotEmpty);
    });

    nyTest('getFirstErrorMessage should return first error', () async {
      final result = FormValidator.notEmpty(message: 'Required').check('');
      expect(result.getFirstErrorMessage(), 'Required');
    });

    nyTest('getFirstErrorMessage should return null when valid', () async {
      final result = FormValidator.notEmpty().check('hello');
      expect(result.getFirstErrorMessage(), isNull);
    });

    nyTest('getFirstErrorRule should return first rule on failure', () async {
      final result = FormValidator.notEmpty().check('');
      expect(result.getFirstErrorRule(), isNotNull);
    });

    nyTest('getFirstErrorRule should return null when valid', () async {
      final result = FormValidator.notEmpty().check('hello');
      expect(result.getFirstErrorRule(), isNull);
    });

    nyTest('getErrorRules should return all error rules', () async {
      final result = FormValidator().notEmpty().email().check('');
      expect(result.getErrorRules(), hasLength(result.errorResponses.length));
    });

    nyTest('getRules should return all rules', () async {
      final result = FormValidator().notEmpty().email().check('test@e.com');
      expect(result.getRules(), hasLength(2));
    });

    nyTest('responsesMap should contain data as key', () async {
      final result = FormValidator.notEmpty().check('hello');
      final map = result.responsesMap;
      expect(map, isA<Map>());
      expect(map.isNotEmpty, isTrue);
    });

    nyTest('attribute substitution in error messages', () async {
      final validator = FormValidator.notEmpty(
        message: '{{attribute}} is required',
      );
      validator.setAttribute('Email');
      final result = validator.check('');
      expect(result.errorMessages(), contains('Email is required'));
    });
  });
}
