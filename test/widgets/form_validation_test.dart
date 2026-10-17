import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';
import 'package:nylo_support/testing/ny_testing.dart';

import '../controllers/mocks/mock_event_bus.dart';

/// A one-field form whose only rule fails when the field is empty.
class _NameFormData extends NyFormData {
  _NameFormData() : super('name_form');

  @override
  List<dynamic> fields() => [
    Field.text("Name", validator: FormValidator.notEmpty()),
  ];
}

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
      final FormValidator validator = FormValidator().email();
      expect(validator.rules, hasLength(1));
      expect(validator, isA<FormValidator>());
    });

    nyTest('should chain multiple rules', () async {
      final FormValidator validator = FormValidator()
          .notEmpty()
          .email()
          .minLength(5);
      expect(validator.rules, hasLength(3));
    });

    nyTest('should chain password', () async {
      final FormValidator validator = FormValidator().password(strength: 1);
      expect(validator.rules, hasLength(1));
    });

    nyTest('should chain contains', () async {
      final FormValidator validator = FormValidator().contains(['a']);
      expect(validator.rules, hasLength(1));
    });

    nyTest('should chain beginsWith', () async {
      final FormValidator validator = FormValidator().beginsWith('abc');
      expect(validator.rules, hasLength(1));
    });

    nyTest('should chain endsWith', () async {
      final FormValidator validator = FormValidator().endsWith('xyz');
      expect(validator.rules, hasLength(1));
    });

    nyTest('should chain custom', () async {
      final FormValidator validator = FormValidator().custom(
        validate: (data) => true,
      );
      expect(validator.rules, hasLength(1));
    });

    nyTest('should chain equals', () async {
      final FormValidator validator = FormValidator().equals('test');
      expect(validator.rules, hasLength(1));
    });
  });

  // ===========================================================================
  // FormValidator.check tests
  // ===========================================================================

  nyGroup('FormValidator.check', () {
    nyTest('email should pass for valid email', () async {
      final FormValidationResult result = FormValidator.email().check(
        'test@example.com',
      );
      expect(result.isValid, isTrue);
    });

    nyTest('email should fail for invalid email', () async {
      final FormValidationResult result = FormValidator.email().check(
        'invalid',
      );
      expect(result.isValid, isFalse);
    });

    nyTest('notEmpty should pass for non-empty string', () async {
      final FormValidationResult result = FormValidator.notEmpty().check(
        'hello',
      );
      expect(result.isValid, isTrue);
    });

    nyTest('notEmpty should fail for empty string', () async {
      final FormValidationResult result = FormValidator.notEmpty().check('');
      expect(result.isValid, isFalse);
    });

    nyTest('minLength should pass for string meeting minimum', () async {
      final FormValidationResult result = FormValidator.minLength(
        3,
      ).check('abc');
      expect(result.isValid, isTrue);
    });

    nyTest('minLength should fail for short string', () async {
      final FormValidationResult result = FormValidator.minLength(
        5,
      ).check('ab');
      expect(result.isValid, isFalse);
    });

    nyTest('maxLength should pass for string within maximum', () async {
      final FormValidationResult result = FormValidator.maxLength(
        5,
      ).check('abc');
      expect(result.isValid, isTrue);
    });

    nyTest('maxLength should fail for long string', () async {
      final FormValidationResult result = FormValidator.maxLength(
        3,
      ).check('abcdef');
      expect(result.isValid, isFalse);
    });

    nyTest('url should pass for valid URL', () async {
      final FormValidationResult result = FormValidator.url().check(
        'https://example.com',
      );
      expect(result.isValid, isTrue);
    });

    nyTest('url should fail for invalid URL', () async {
      final FormValidationResult result = FormValidator.url().check(
        'not a url',
      );
      expect(result.isValid, isFalse);
    });

    nyTest('numeric should pass for num value', () async {
      final FormValidationResult result = FormValidator.numeric().check(123);
      expect(result.isValid, isTrue);
    });

    nyTest('numeric should pass for double value', () async {
      final FormValidationResult result = FormValidator.numeric().check(3.14);
      expect(result.isValid, isTrue);
    });

    nyTest('numeric should fail for string value', () async {
      final FormValidationResult result = FormValidator.numeric().check('abc');
      expect(result.isValid, isFalse);
    });

    nyTest('contains should pass when value is in list', () async {
      final FormValidationResult result = FormValidator.contains([
        'a',
        'b',
        'c',
      ]).check('b');
      expect(result.isValid, isTrue);
    });

    nyTest('contains should fail when value not in list', () async {
      final FormValidationResult result = FormValidator.contains([
        'a',
        'b',
      ]).check('x');
      expect(result.isValid, isFalse);
    });

    nyTest('beginsWith should pass for matching prefix', () async {
      final FormValidationResult result = FormValidator.beginsWith(
        'Hello',
      ).check('Hello World');
      expect(result.isValid, isTrue);
    });

    nyTest('beginsWith should fail for non-matching prefix', () async {
      final FormValidationResult result = FormValidator.beginsWith(
        'Hello',
      ).check('World');
      expect(result.isValid, isFalse);
    });

    nyTest('endsWith should pass for matching suffix', () async {
      final FormValidationResult result = FormValidator.endsWith(
        'World',
      ).check('Hello World');
      expect(result.isValid, isTrue);
    });

    nyTest('endsWith should fail for non-matching suffix', () async {
      final FormValidationResult result = FormValidator.endsWith(
        '.com',
      ).check('example.org');
      expect(result.isValid, isFalse);
    });

    nyTest('capitalized should pass for capitalized string', () async {
      final FormValidationResult result = FormValidator.capitalized().check(
        'Hello',
      );
      expect(result.isValid, isTrue);
    });

    nyTest('capitalized should fail for lowercase start', () async {
      final FormValidationResult result = FormValidator.capitalized().check(
        'hello',
      );
      expect(result.isValid, isFalse);
    });

    nyTest('lowercase should pass for lowercase string', () async {
      final FormValidationResult result = FormValidator.lowercase().check(
        'hello',
      );
      expect(result.isValid, isTrue);
    });

    nyTest('lowercase should fail for uppercase string', () async {
      final FormValidationResult result = FormValidator.lowercase().check(
        'HELLO',
      );
      expect(result.isValid, isFalse);
    });

    nyTest('uppercase should pass for uppercase string', () async {
      final FormValidationResult result = FormValidator.uppercase().check(
        'HELLO',
      );
      expect(result.isValid, isTrue);
    });

    nyTest('uppercase should fail for lowercase string', () async {
      final FormValidationResult result = FormValidator.uppercase().check(
        'hello',
      );
      expect(result.isValid, isFalse);
    });

    nyTest('regex should pass for matching pattern', () async {
      final FormValidationResult result = FormValidator.regex(
        r'^[a-z]+$',
      ).check('abc');
      expect(result.isValid, isTrue);
    });

    nyTest('regex should fail for non-matching pattern', () async {
      final FormValidationResult result = FormValidator.regex(
        r'^[a-z]+$',
      ).check('ABC');
      expect(result.isValid, isFalse);
    });

    nyTest('booleanTrue should pass for true', () async {
      final FormValidationResult result = FormValidator.booleanTrue().check(
        true,
      );
      expect(result.isValid, isTrue);
    });

    nyTest('booleanTrue should fail for false', () async {
      final FormValidationResult result = FormValidator.booleanTrue().check(
        false,
      );
      expect(result.isValid, isFalse);
    });

    nyTest('booleanFalse should pass for false', () async {
      final FormValidationResult result = FormValidator.booleanFalse().check(
        false,
      );
      expect(result.isValid, isTrue);
    });

    nyTest('booleanFalse should fail for true', () async {
      final FormValidationResult result = FormValidator.booleanFalse().check(
        true,
      );
      expect(result.isValid, isFalse);
    });

    nyTest('custom should use custom validation function', () async {
      final FormValidationResult result = FormValidator.custom(
        validate: (data) => data == 'magic',
      ).check('magic');
      expect(result.isValid, isTrue);
    });

    nyTest('custom should fail for failing validation', () async {
      final FormValidationResult result = FormValidator.custom(
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
      final FormValidationResult result = validator.check('hello');
      expect(result.isValid, isTrue);
    });

    nyTest('should use setData method', () async {
      final validator = FormValidator.notEmpty();
      validator.setData('hello');
      final FormValidationResult result = validator.check();
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
      final FormValidationResult result = FormValidator()
          .notEmpty()
          .email()
          .check('test@email.com');
      expect(result.isValid, isTrue);
    });

    nyTest('isValid should be false when any fail', () async {
      final FormValidationResult result = FormValidator()
          .notEmpty()
          .email()
          .check('');
      expect(result.isValid, isFalse);
    });

    nyTest('errorMessages should return list of error messages', () async {
      final FormValidationResult result = FormValidator.notEmpty(
        message: 'Required',
      ).check('');
      expect(result.errorMessages(), contains('Required'));
    });

    nyTest('errorResponses should return only errors', () async {
      final FormValidationResult result = FormValidator()
          .notEmpty()
          .email()
          .check('');
      expect(result.errorResponses, isNotEmpty);
    });

    nyTest('getFirstErrorMessage should return first error', () async {
      final FormValidationResult result = FormValidator.notEmpty(
        message: 'Required',
      ).check('');
      expect(result.getFirstErrorMessage(), 'Required');
    });

    nyTest('getFirstErrorMessage should return null when valid', () async {
      final FormValidationResult result = FormValidator.notEmpty().check(
        'hello',
      );
      expect(result.getFirstErrorMessage(), isNull);
    });

    nyTest('getFirstErrorRule should return first rule on failure', () async {
      final FormValidationResult result = FormValidator.notEmpty().check('');
      expect(result.getFirstErrorRule(), isNotNull);
    });

    nyTest('getFirstErrorRule should return null when valid', () async {
      final FormValidationResult result = FormValidator.notEmpty().check(
        'hello',
      );
      expect(result.getFirstErrorRule(), isNull);
    });

    nyTest('getErrorRules should return all error rules', () async {
      final FormValidationResult result = FormValidator()
          .notEmpty()
          .email()
          .check('');
      expect(result.getErrorRules(), hasLength(result.errorResponses.length));
    });

    nyTest('getRules should return all rules', () async {
      final FormValidationResult result = FormValidator()
          .notEmpty()
          .email()
          .check('test@e.com');
      expect(result.getRules(), hasLength(2));
    });

    nyTest('responsesMap should contain data as key', () async {
      final FormValidationResult result = FormValidator.notEmpty().check(
        'hello',
      );
      final Map<dynamic, Map<FormRule, FormValidationResponse>> map =
          result.responsesMap;
      expect(map, isA<Map>());
      expect(map.isNotEmpty, isTrue);
    });

    nyTest('attribute substitution in error messages', () async {
      final validator = FormValidator.notEmpty(
        message: '{{attribute}} is required',
      );
      validator.setAttribute('Email');
      final FormValidationResult result = validator.check('');
      expect(result.errorMessages(), contains('Email is required'));
    });

    nyTest('error responses name the field in their message', () async {
      final validator = FormValidator.notEmpty();
      validator.setAttribute('Name');
      final FormValidationResult result = validator.check('');
      expect(result.errorResponses.first.attribute, 'Name');
      expect(
        result.errorResponses.first.message,
        'The Name must not be empty.',
      );
    });

    nyTest('a field names itself in its error messages', () async {
      final field = Field.text('Name', validator: FormValidator.notEmpty());
      final FormValidationResult? result = field.validate();
      expect(
        result?.errorResponses.first.message,
        'The Name must not be empty.',
      );
    });

    nyTest('a field cleared back to null fails validation again', () async {
      // https://github.com/nylo-core/nylo/issues/311
      final field = Field.picker(
        'Reason',
        validator: FormValidator.notEmpty(),
        options: FormCollection.fromArray(['Info', 'Other']),
      );
      field.restoreValue('Info');
      expect(field.validate()?.isValid, isTrue);

      field.restoreValue(null);
      expect(field.validate()?.isValid, isFalse);
    });
  });

  // ===========================================================================
  // NyFormData.submit error toast
  // ===========================================================================

  nyGroup('NyFormData.submit', () {
    late MockEventBus mockEventBus;

    nySetUp(() {
      mockEventBus = MockEventBus();
      Backpack.instance.save('event_bus', mockEventBus);
    });

    nyTearDown(() {
      mockEventBus.reset();
    });

    nyTest('the error toast names the field that failed', () async {
      final form = _NameFormData()..initFields();
      List<FormValidationError>? errors;

      await form.submit(onSuccess: (_) {}, onFailure: (e) => errors = e);

      final UpdateState toast = mockEventBus.firedEvents
          .whereType<UpdateState>()
          .firstWhere((event) => event.data['action'] == 'showToast');
      expect(toast.data['data']['message'], 'The Name must not be empty.');
      expect(errors?.first.message, 'The Name must not be empty.');
    });
  });

  nyGroup('FormValidationResult.firstError', () {
    nyTest('is null when every rule passes', () async {
      final FormValidationResult result = FormValidator.notEmpty()
          .minLength(2)
          .check('hello');
      expect(result.firstError, isNull);
      expect(result.getFirstErrorMessage(), isNull);
      expect(result.getFirstErrorRule(), isNull);
    });

    nyTest('returns the first failing rule in rule order', () async {
      final FormValidationResult result = FormValidator.notEmpty()
          .minLength(5)
          .email()
          .check('ab');
      expect(result.firstError, isNotNull);
      expect(result.firstError!.rule, same(result.getFirstErrorRule()));
      expect(result.firstError!.rule, same(result.errorResponses.first.rule));
      expect(result.getFirstErrorMessage(), contains('at least 5'));
    });
  });
}
