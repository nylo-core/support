import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';

void main() {
  NyTest.init();

  nyGroup('FormRuleEmail', () {
    nyTest('validates correct email addresses', () async {
      final rule = FormRuleEmail();

      expect(rule.validate('test@example.com'), true);
      expect(rule.validate('user.name@domain.org'), true);
      expect(rule.validate('user+tag@email.co.uk'), true);
    });

    nyTest('rejects invalid email addresses', () async {
      final rule = FormRuleEmail();

      expect(rule.validate('@nodomain.com'), false);
      expect(rule.validate(''), false);
      expect(rule.validate('double@@at.com'), false);
    });

    nyTest('rejects non-string data', () async {
      final rule = FormRuleEmail();

      expect(rule.validate(123), false);
      expect(rule.validate(null), false);
      expect(rule.validate(['email@test.com']), false);
    });

    nyTest('has default message', () async {
      final rule = FormRuleEmail();

      expect(rule.message, contains('valid email address'));
    });

    nyTest('accepts custom message', () async {
      final rule = FormRuleEmail(message: 'Custom email error');

      expect(rule.message, 'Custom email error');
    });
  });

  nyGroup('FormRulePassword', () {
    nyTest('validates strength 1 password', () async {
      final rule = FormRulePassword(strength: 1);

      expect(rule.validate('Password1'), true);
      expect(rule.validate('UPPERCASE1'), true);
      expect(rule.validate('12345678'), false); // No uppercase
      expect(rule.validate('Password'), false); // No digit
      expect(rule.validate('Pass1'), false); // Too short
    });

    nyTest('validates strength 2 password with special char', () async {
      final rule = FormRulePassword(strength: 2);

      expect(rule.validate('Password1!'), true);
      expect(rule.validate('Complex@Pass1'), true);
      expect(rule.validate('Password1'), false); // No special char
    });

    nyTest('has appropriate message for strength level', () async {
      final rule1 = FormRulePassword(strength: 1);
      final rule2 = FormRulePassword(strength: 2);

      expect(rule1.message, contains('uppercase'));
      expect(rule1.message, contains('digit'));
      expect(rule2.message, contains('special character'));
    });
  });

  nyGroup('FormRuleEquals', () {
    nyTest('validates equal values', () async {
      final rule = FormRuleEquals(dataSource: 'expected');

      expect(rule.validate('expected'), true);
      expect(rule.validate('different'), false);
    });

    nyTest('validates equal numbers', () async {
      final rule = FormRuleEquals(dataSource: 42);

      expect(rule.validate(42), true);
      expect(rule.validate(43), false);
    });

    nyTest('has default message', () async {
      final rule = FormRuleEquals(dataSource: 'test');

      expect(rule.message, contains('must match'));
    });
  });

  nyGroup('FormRuleCustom', () {
    nyTest('uses custom validation function', () async {
      final rule = FormRuleCustom(
        customValidation: (data) => data is String && data.length > 5,
      );

      expect(rule.validate('longer'), true);
      expect(rule.validate('short'), false);
    });

    nyTest('accepts custom message', () async {
      final rule = FormRuleCustom(
        customValidation: (data) => true,
        message: 'Custom validation error',
      );

      expect(rule.message, 'Custom validation error');
    });
  });

  nyGroup('FormRuleMinLength', () {
    nyTest('validates minimum string length', () async {
      final rule = FormRuleMinLength(5);

      expect(rule.validate('12345'), true);
      expect(rule.validate('123456'), true);
      expect(rule.validate('1234'), false);
    });

    nyTest('rejects non-string data', () async {
      final rule = FormRuleMinLength(3);

      expect(rule.validate(12345), false);
    });

    nyTest('has appropriate message', () async {
      final rule = FormRuleMinLength(10);

      expect(rule.message, contains('10'));
      expect(rule.message, contains('characters'));
    });
  });

  nyGroup('FormRuleMaxLength', () {
    nyTest('validates maximum string length', () async {
      final rule = FormRuleMaxLength(5);

      expect(rule.validate('12345'), true);
      expect(rule.validate('1234'), true);
      expect(rule.validate('123456'), false);
    });

    nyTest('has appropriate message', () async {
      final rule = FormRuleMaxLength(100);

      expect(rule.message, contains('100'));
    });
  });

  nyGroup('FormRuleMinValue', () {
    nyTest('validates minimum numeric value', () async {
      final rule = FormRuleMinValue(10);

      expect(rule.validate(10), true);
      expect(rule.validate(15), true);
      expect(rule.validate(5), false);
    });

    nyTest('validates string length as well', () async {
      final rule = FormRuleMinValue(3);

      expect(rule.validate('abc'), true);
      expect(rule.validate('ab'), false);
    });

    nyTest('validates list length', () async {
      final rule = FormRuleMinValue(2);

      expect(rule.validate([1, 2]), true);
      expect(rule.validate([1]), false);
    });
  });

  nyGroup('FormRuleMaxValue', () {
    nyTest('validates maximum numeric value', () async {
      final rule = FormRuleMaxValue(10);

      expect(rule.validate(10), true);
      expect(rule.validate(5), true);
      expect(rule.validate(15), false);
    });
  });

  nyGroup('FormRuleRegex', () {
    nyTest('validates against regex pattern', () async {
      final rule = FormRuleRegex(RegExp(r'^\d{3}-\d{4}$'));

      expect(rule.validate('123-4567'), true);
      expect(rule.validate('123-456'), false);
      expect(rule.validate('abc-defg'), false);
    });
  });

  nyGroup('FormRuleNotEmpty', () {
    nyTest('validates non-empty strings', () async {
      final rule = FormRuleNotEmpty();

      expect(rule.validate('content'), true);
      expect(rule.validate(''), false);
    });

    nyTest('validates non-empty lists', () async {
      final rule = FormRuleNotEmpty();

      expect(rule.validate([1, 2, 3]), true);
      expect(rule.validate([]), false);
    });

    nyTest('has default message', () async {
      final rule = FormRuleNotEmpty();

      expect(rule.message, contains('not be empty'));
    });
  });

  nyGroup('FormRuleNumeric', () {
    nyTest('validates numeric values', () async {
      final rule = FormRuleNumeric();

      expect(rule.validate(42), true);
      expect(rule.validate(3.14), true);
      expect(rule.validate('42'), false);
      expect(rule.validate('not a number'), false);
    });
  });

  nyGroup('FormRuleDate', () {
    nyTest('validates DateTime objects', () async {
      final rule = FormRuleDate();

      expect(rule.validate(DateTime.now()), true);
    });

    nyTest('validates parseable date strings', () async {
      final rule = FormRuleDate();

      expect(rule.validate('2024-01-15'), true);
      expect(rule.validate('not a date'), false);
    });
  });

  nyGroup('FormRuleDateInPast', () {
    nyTest('validates dates in the past', () async {
      final rule = FormRuleDateInPast();

      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      final futureDate = DateTime.now().add(const Duration(days: 1));

      expect(rule.validate(pastDate), true);
      expect(rule.validate(futureDate), false);
    });
  });

  nyGroup('FormRuleDateInFuture', () {
    nyTest('validates dates in the future', () async {
      final rule = FormRuleDateInFuture();

      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      final futureDate = DateTime.now().add(const Duration(days: 1));

      expect(rule.validate(futureDate), true);
      expect(rule.validate(pastDate), false);
    });
  });

  nyGroup('FormRuleDateAgeIsYounger', () {
    nyTest('validates age is younger than specified', () async {
      final rule = FormRuleDateAgeIsYounger(30);

      final youngBirthDate = DateTime.now().subtract(
        const Duration(days: 365 * 20),
      );
      final oldBirthDate = DateTime.now().subtract(
        const Duration(days: 365 * 40),
      );

      expect(rule.validate(youngBirthDate), true);
      expect(rule.validate(oldBirthDate), false);
    });
  });

  nyGroup('FormRuleDateAgeIsOlder', () {
    nyTest('validates age is older than specified', () async {
      final rule = FormRuleDateAgeIsOlder(18);

      final youngBirthDate = DateTime.now().subtract(
        const Duration(days: 365 * 15),
      );
      final oldBirthDate = DateTime.now().subtract(
        const Duration(days: 365 * 25),
      );

      expect(rule.validate(oldBirthDate), true);
      expect(rule.validate(youngBirthDate), false);
    });
  });

  nyGroup('FormRuleUrl', () {
    nyTest('validates valid URLs', () async {
      final rule = FormRuleUrl();

      expect(rule.validate('https://example.com'), true);
      expect(rule.validate('http://test.org/path'), true);
      expect(rule.validate('ftp://files.example.com'), true);
    });

    nyTest('rejects invalid URLs', () async {
      final rule = FormRuleUrl();

      expect(rule.validate('not-a-url'), false);
      expect(rule.validate('www.example.com'), false);
    });
  });

  nyGroup('FormRulePhoneNumberUs', () {
    nyTest('validates US phone numbers', () async {
      final rule = FormRulePhoneNumberUs();

      expect(rule.validate('123-456-7890'), true);
      expect(rule.validate('(123) 456-7890'), true);
      expect(rule.validate('1234567890'), true);
    });

    nyTest('rejects invalid phone numbers', () async {
      final rule = FormRulePhoneNumberUs();

      expect(rule.validate('123-456'), false);
      expect(rule.validate('abcdefghij'), false);
    });
  });

  nyGroup('FormRulePhoneNumberUk', () {
    nyTest('validates UK phone numbers', () async {
      final rule = FormRulePhoneNumberUk();

      expect(rule.validate('01onal234 567890'), false);
      expect(rule.validate('+44 1onal 567 8910'), false);
    });
  });

  nyGroup('FormRuleContains', () {
    nyTest('validates string contains values', () async {
      final rule = FormRuleContains(['cat', 'dog']);

      expect(rule.validate('I have a cat'), true);
      expect(rule.validate('I have a dog'), true);
      expect(rule.validate('I have a bird'), false);
    });
  });

  nyGroup('FormRuleBeginsWith', () {
    nyTest('validates string begins with prefix', () async {
      final rule = FormRuleBeginsWith('Hello');

      expect(rule.validate('Hello World'), true);
      expect(rule.validate('Hi World'), false);
    });
  });

  nyGroup('FormRuleEndsWith', () {
    nyTest('validates string ends with suffix', () async {
      final rule = FormRuleEndsWith('.com');

      expect(rule.validate('example.com'), true);
      expect(rule.validate('example.org'), false);
    });
  });

  nyGroup('FormRuleBooleanTrue', () {
    nyTest('validates true boolean', () async {
      final rule = FormRuleBooleanTrue();

      expect(rule.validate(true), true);
      expect(rule.validate(false), false);
      expect(rule.validate('true'), false);
    });
  });

  nyGroup('FormRuleBooleanFalse', () {
    nyTest('validates false boolean', () async {
      final rule = FormRuleBooleanFalse();

      expect(rule.validate(false), true);
      expect(rule.validate(true), false);
      expect(rule.validate('false'), false);
    });
  });

  nyGroup('FormRuleCapitalized', () {
    nyTest('validates capitalized strings', () async {
      final rule = FormRuleCapitalized();

      expect(rule.validate('Hello'), true);
      expect(rule.validate('hello'), false);
      expect(rule.validate('HELLO'), true);
    });

    nyTest('rejects empty strings', () async {
      final rule = FormRuleCapitalized();

      expect(rule.validate(''), false);
    });
  });

  nyGroup('FormRuleLowercase', () {
    nyTest('validates lowercase strings', () async {
      final rule = FormRuleLowercase();

      expect(rule.validate('hello'), true);
      expect(rule.validate('Hello'), false);
      expect(rule.validate('HELLO'), false);
    });
  });

  nyGroup('FormRuleUppercase', () {
    nyTest('validates uppercase strings', () async {
      final rule = FormRuleUppercase();

      expect(rule.validate('HELLO'), true);
      expect(rule.validate('Hello'), false);
      expect(rule.validate('hello'), false);
    });
  });

  nyGroup('FormRuleZipcodeUs', () {
    nyTest('validates US zip codes', () async {
      final rule = FormRuleZipcodeUs();

      expect(rule.validate('12345'), true);
      expect(rule.validate('12345-6789'), true);
      expect(rule.validate('1234'), false);
    });
  });

  nyGroup('FormRulePostcodeUk', () {
    nyTest('validates UK postcodes', () async {
      final rule = FormRulePostcodeUk();

      expect(rule.validate('SW1A 1AA'), true);
      expect(rule.validate('M1 1AE'), true);
      expect(rule.validate('INVALID'), false);
    });
  });

  nyGroup('FormRuleMinSize', () {
    nyTest('validates minimum list size', () async {
      final rule = FormRuleMinSize(3);

      expect(rule.validate([1, 2, 3]), true);
      expect(rule.validate([1, 2, 3, 4]), true);
      expect(rule.validate([1, 2]), false);
    });

    nyTest('validates minimum string size', () async {
      final rule = FormRuleMinSize(3);

      expect(rule.validate('abc'), true);
      expect(rule.validate('ab'), false);
    });
  });

  nyGroup('FormRuleMaxSize', () {
    nyTest('validates maximum list size', () async {
      final rule = FormRuleMaxSize(3);

      expect(rule.validate([1, 2, 3]), true);
      expect(rule.validate([1, 2]), true);
      expect(rule.validate([1, 2, 3, 4]), false);
    });

    nyTest('validates maximum string size', () async {
      final rule = FormRuleMaxSize(3);

      expect(rule.validate('abc'), true);
      expect(rule.validate('abcd'), false);
    });
  });
}
