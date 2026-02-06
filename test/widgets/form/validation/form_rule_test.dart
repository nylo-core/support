import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';

/// Concrete implementation of FormRule for testing
class _TestFormRule extends FormRule {
  final bool returnValue;

  _TestFormRule({String? rule, String? message, this.returnValue = true})
    : super(rule: rule, message: message);

  @override
  bool validate(dynamic data) => returnValue;
}

void main() {
  NyTest.init();

  nyGroup('FormRule', () {
    nyGroup('constructor', () {
      nyTest('creates with default null values', () async {
        final rule = _TestFormRule();

        expect(rule.rule, isNull);
        expect(rule.message, isNull);
      });

      nyTest('creates with rule identifier', () async {
        final rule = _TestFormRule(rule: 'test_rule');

        expect(rule.rule, 'test_rule');
      });

      nyTest('creates with message', () async {
        final rule = _TestFormRule(message: 'Test error message');

        expect(rule.message, 'Test error message');
      });

      nyTest('creates with both rule and message', () async {
        final rule = _TestFormRule(
          rule: 'custom_rule',
          message: 'Custom error message',
        );

        expect(rule.rule, 'custom_rule');
        expect(rule.message, 'Custom error message');
      });
    });

    nyGroup('validate', () {
      nyTest('returns true when validation passes', () async {
        final rule = _TestFormRule(returnValue: true);

        expect(rule.validate('any data'), true);
      });

      nyTest('returns false when validation fails', () async {
        final rule = _TestFormRule(returnValue: false);

        expect(rule.validate('any data'), false);
      });
    });

    nyGroup('getMessage', () {
      nyTest('returns message without attribute', () async {
        final rule = _TestFormRule(message: 'Simple message');

        expect(rule.getMessage(), 'Simple message');
      });

      nyTest('replaces {{attribute}} placeholder', () async {
        final rule = _TestFormRule(
          message: 'The {{attribute}} field is required',
        );

        expect(rule.getMessage('email'), 'The email field is required');
      });

      nyTest('replaces {{attribute}} with default "data" when null', () async {
        final rule = _TestFormRule(message: 'The {{attribute}} is invalid');

        expect(rule.getMessage(), 'The data is invalid');
      });

      nyTest('returns null when message is null', () async {
        final rule = _TestFormRule();

        expect(rule.getMessage(), isNull);
      });

      nyTest('handles multiple {{attribute}} placeholders', () async {
        final rule = _TestFormRule(
          message: 'The {{attribute}} must match {{attribute}}',
        );

        expect(rule.getMessage('password'), 'The password must match password');
      });
    });

    nyGroup('data property', () {
      nyTest('can be set and retrieved', () async {
        final rule = _TestFormRule();
        rule.data = 'test data';

        expect(rule.data, 'test data');
      });

      nyTest('accepts various data types', () async {
        final rule = _TestFormRule();

        rule.data = 42;
        expect(rule.data, 42);

        rule.data = ['a', 'b', 'c'];
        expect(rule.data, ['a', 'b', 'c']);

        rule.data = {'key': 'value'};
        expect(rule.data, {'key': 'value'});
      });
    });
  });
}
