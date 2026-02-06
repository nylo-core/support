import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';

/// Simple mock rule for testing
class _MockFormRule extends FormRule {
  _MockFormRule({String? rule, String? message})
    : super(rule: rule ?? 'mock', message: message);

  @override
  bool validate(dynamic data) => true;
}

void main() {
  NyTest.init();

  nyGroup('FormValidationResponse', () {
    nyGroup('constructor', () {
      nyTest('creates with rule only', () async {
        final rule = _MockFormRule(message: 'Test message');
        final response = FormValidationResponse(rule);

        expect(response.rule, equals(rule));
        expect(response.data, isNull);
      });

      nyTest('creates with rule and data', () async {
        final rule = _MockFormRule(message: 'Test message');
        final response = FormValidationResponse(rule, data: 'test data');

        expect(response.rule, equals(rule));
        expect(response.data, 'test data');
      });

      nyTest('accepts various data types', () async {
        final rule = _MockFormRule();

        final withString = FormValidationResponse(rule, data: 'string');
        final withInt = FormValidationResponse(rule, data: 42);
        final withList = FormValidationResponse(rule, data: [1, 2, 3]);
        final withMap = FormValidationResponse(rule, data: {'key': 'value'});

        expect(withString.data, 'string');
        expect(withInt.data, 42);
        expect(withList.data, [1, 2, 3]);
        expect(withMap.data, {'key': 'value'});
      });
    });

    nyGroup('toString', () {
      nyTest('formats correctly', () async {
        final rule = _MockFormRule(rule: 'test_rule', message: 'Test message');
        final response = FormValidationResponse(rule, data: 'some data');

        final result = response.toString();

        expect(result, contains('FormValidationResponse'));
        expect(result, contains('rule:'));
        expect(result, contains('data:'));
      });
    });
  });

  nyGroup('FormValidationError', () {
    nyGroup('constructor', () {
      nyTest('creates with rule', () async {
        final rule = _MockFormRule(message: 'Error message');
        final error = FormValidationError(rule);

        expect(error.rule, equals(rule));
        expect(error, isA<FormValidationResponse>());
      });
    });

    nyGroup('inheritance', () {
      nyTest('extends FormValidationResponse', () async {
        final error = FormValidationError(_MockFormRule());

        expect(error, isA<FormValidationResponse>());
      });
    });

    nyGroup('toString', () {
      nyTest('formats correctly', () async {
        final rule = _MockFormRule(rule: 'error_rule', message: 'Error');
        final error = FormValidationError(rule);

        final result = error.toString();

        expect(result, contains('FormValidationError'));
        expect(result, contains('rule:'));
      });
    });
  });

  nyGroup('FormValidationSuccess', () {
    nyGroup('constructor', () {
      nyTest('creates with rule', () async {
        final rule = _MockFormRule(message: 'Success');
        final success = FormValidationSuccess(rule);

        expect(success.rule, equals(rule));
        expect(success, isA<FormValidationResponse>());
      });
    });

    nyGroup('inheritance', () {
      nyTest('extends FormValidationResponse', () async {
        final success = FormValidationSuccess(_MockFormRule());

        expect(success, isA<FormValidationResponse>());
      });
    });

    nyGroup('toString', () {
      nyTest('formats correctly', () async {
        final rule = _MockFormRule(rule: 'success_rule', message: 'Success');
        final success = FormValidationSuccess(rule);

        final result = success.toString();

        expect(result, contains('FormValidationSuccess'));
        expect(result, contains('rule:'));
      });
    });
  });
}
