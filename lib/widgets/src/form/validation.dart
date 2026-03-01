import 'validation/form_rule.dart';
import 'validation/form_validation_response.dart';
import 'validation/rules.dart';

export 'validation/form_rule.dart';
export 'validation/form_validation_response.dart';
export 'validation/rules.dart';

class FormValidator {
  String? attribute;
  dynamic data;
  List<FormRule> rules = [];
  bool _isNullable = false;

  /// Create a new form validator with [message] and [data]
  FormValidator({this.data, this.attribute});

  /// Create a new form validator with [rules]
  FormValidator.rule(this.rules, {this.data});

  /// Sets the attribute name for error messages.
  void setAttribute(String? attribute) {
    this.attribute = attribute;
  }

  /// Validate a password with a strength of 1 or 2
  /// [strength] 1: 1 uppercased letter, 1 digit, 8 characters
  /// [strength] 2: 1 uppercased letter, 1 digit, 1 special character, 8 characters
  /// [message] The message to display if the password is invalid
  FormValidator.password({int strength = 1, String? message}) {
    assert(
      strength > 0 && strength < 3,
      "Password strength must be between 1 and 2",
    );
    rules.add(FormRulePassword(strength: strength, message: message));
  }

  /// Validate a custom rule
  /// [message] The message to display if the custom validation fails
  /// [validate] The custom validation function that takes the data and returns a boolean
  FormValidator.custom({
    String? message,
    required bool Function(dynamic data) validate,
  }) {
    rules.add(FormRuleCustom(message: message, customValidation: validate));
  }

  /// Validate an email
  /// [message] The message to display if the email is invalid
  FormValidator.email({String? message}) {
    rules.add(FormRuleEmail(message: message));
  }

  /// Validate a UK phone number
  /// [message] The message to display if the phone number is invalid
  FormValidator.phoneNumberUk({String? message}) {
    rules.add(FormRulePhoneNumberUk(message: message));
  }

  /// Validate a US phone number
  /// [message] The message to display if the phone number is invalid
  FormValidator.phoneNumberUs({String? message}) {
    rules.add(FormRulePhoneNumberUs(message: message));
  }

  /// Validate a URL
  /// [message] The message to display if the URL is invalid
  FormValidator.url({String? message}) {
    rules.add(FormRuleUrl(message: message));
  }

  /// Validate the value contains one of the [values]
  /// [message] The message to display if the value is invalid
  FormValidator.contains(List<String> values, {String? message}) {
    rules.add(FormRuleContains(values, message));
  }

  /// Validate that the value begins with [prefix]
  /// [message] The message to display if the value is invalid
  FormValidator.beginsWith(String prefix, {String? message}) {
    rules.add(FormRuleBeginsWith(prefix, message));
  }

  /// Validate that the value ends with [suffix]
  /// [message] The message to display if the value is invalid
  FormValidator.endsWith(String suffix, {String? message}) {
    rules.add(FormRuleEndsWith(suffix, message));
  }

  /// Validate a value is a boolean
  /// [message] The message to display if the value is invalid
  FormValidator.booleanTrue({String? message}) {
    rules.add(FormRuleBooleanTrue(message: message));
  }

  /// Validate a value is a boolean
  /// [message] The message to display if the value is invalid
  FormValidator.booleanFalse({String? message}) {
    rules.add(FormRuleBooleanFalse(message: message));
  }

  /// Validate that the value is a minimum of [value] characters
  /// [message] The message to display if the value is invalid
  /// [value] The minimum number of characters
  FormValidator.minLength(int value, {String? message}) {
    rules.add(FormRuleMinLength(value, message));
  }

  /// Validate that the value is a minimum size of [value]
  /// [message] The message to display if the value is invalid
  /// [value] The minimum size
  FormValidator.minSize(int value, {String? message}) {
    rules.add(FormRuleMinSize(value, message));
  }

  /// Validate that the value is a minimum of [value]
  /// [message] The message to display if the value is invalid
  /// [value] The minimum value
  FormValidator.minValue(int value, {String? message}) {
    rules.add(FormRuleMinValue(value, message));
  }

  /// Validate that the value is a maximum of [value] characters
  /// [message] The message to display if the value is invalid
  /// [value] The maximum number of characters
  FormValidator.maxLength(int value, {String? message}) {
    rules.add(FormRuleMaxLength(value, message));
  }

  /// Validate that the value is a maximum size of [value]
  /// [message] The message to display if the value is invalid
  /// [value] The maximum size
  FormValidator.maxSize(int value, {String? message}) {
    rules.add(FormRuleMaxSize(value, message));
  }

  /// Validate that the value is a maximum of [value]
  /// [message] The message to display if the value is invalid
  /// [value] The maximum value
  FormValidator.maxValue(int value, {String? message}) {
    rules.add(FormRuleMaxValue(value, message));
  }

  /// Validate that the value is not empty
  /// [message] The message to display if the value is invalid
  FormValidator.notEmpty({String? message}) {
    rules.add(FormRuleNotEmpty(message));
  }

  /// Validate that the value is numeric
  /// [message] The message to display if the value is invalid
  FormValidator.numeric({String? message}) {
    rules.add(FormRuleNumeric(message: message));
  }

  /// Validate that the value is a date
  /// [message] The message to display if the value is invalid
  FormValidator.date({String? message}) {
    rules.add(FormRuleDate(message: message));
  }

  /// Validate that the value is capitalized
  /// [message] The message to display if the value is invalid
  FormValidator.capitalized({String? message}) {
    rules.add(FormRuleCapitalized(message: message));
  }

  /// Validate that the value is lowercase
  /// [message] The message to display if the value is invalid
  FormValidator.lowercase({String? message}) {
    rules.add(FormRuleLowercase(message: message));
  }

  /// Validate that the value is uppercase
  /// [message] The message to display if the value is invalid
  FormValidator.uppercase({String? message}) {
    rules.add(FormRuleUppercase(message: message));
  }

  /// Validate that the value is a valid zipcode for the US
  /// [message] The message to display if the value is invalid
  FormValidator.zipcodeUs({String? message}) {
    rules.add(FormRuleZipcodeUs(message: message));
  }

  /// Validate that the value is a valid postcode for the UK
  /// [message] The message to display if the value is invalid
  FormValidator.postcodeUk({String? message}) {
    rules.add(FormRulePostcodeUk(message: message));
  }

  /// Validate that the value matches a [regex] pattern
  /// [message] The message to display if the value is invalid
  FormValidator.regex(String regex, {String? message}) {
    rules.add(FormRuleRegex(RegExp(regex), message));
  }

  /// Validate that the date is younger than [age]
  /// [message] The message to display if the value is invalid
  /// [age] The age to compare
  FormValidator.dateAgeIsYounger(int age, {String? message}) {
    rules.add(FormRuleDateAgeIsYounger(age, message));
  }

  /// Validate that the date is older than [age]
  /// [message] The message to display if the value is invalid
  /// [age] The age to compare
  FormValidator.dateAgeIsOlder(int age, {String? message}) {
    rules.add(FormRuleDateAgeIsOlder(age, message));
  }

  /// Validate that the date is in the past
  /// [message] The message to display if the value is invalid
  FormValidator.dateInPast({String? message}) {
    rules.add(FormRuleDateInPast(message));
  }

  /// Validate that the date is in the future
  /// [message] The message to display if the value is invalid
  FormValidator.dateInFuture({String? message}) {
    rules.add(FormRuleDateInFuture(message));
  }

  /// Validate an email
  FormValidator email({String? message}) {
    _addRule(FormRuleEmail(message: message));
    return this;
  }

  /// Validate a UK phone number
  FormValidator phoneNumberUk({String? message}) {
    _addRule(FormRulePhoneNumberUk(message: message));
    return this;
  }

  /// Validate a US phone number
  FormValidator phoneNumberUs({String? message}) {
    _addRule(FormRulePhoneNumberUs(message: message));
    return this;
  }

  /// Validate a URL
  FormValidator url({String? message}) {
    _addRule(FormRuleUrl(message: message));
    return this;
  }

  /// Validate the value contains one of the [values]
  FormValidator contains(List<String> values, {String? message}) {
    _addRule(FormRuleContains(values, message));
    return this;
  }

  /// Validate that the value begins with [prefix]
  FormValidator beginsWith(String prefix, {String? message}) {
    _addRule(FormRuleBeginsWith(prefix, message));
    return this;
  }

  /// Validate that the value ends with [suffix]
  FormValidator endsWith(String suffix, {String? message}) {
    _addRule(FormRuleEndsWith(suffix, message));
    return this;
  }

  /// Validate a value is a boolean
  FormValidator booleanTrue({String? message}) {
    _addRule(FormRuleBooleanTrue(message: message));
    return this;
  }

  /// Validate a value is a boolean (must be false)
  FormValidator booleanFalse({String? message}) {
    _addRule(FormRuleBooleanFalse(message: message));
    return this;
  }

  /// Validate that the value is a minimum of [value] characters
  FormValidator minLength(int value, {String? message}) {
    _addRule(FormRuleMinLength(value, message));
    return this;
  }

  /// Validate that the value is a minimum size of [value]
  FormValidator minSize(int value, {String? message}) {
    _addRule(FormRuleMinSize(value, message));
    return this;
  }

  /// Validate that the value is a minimum of [value]
  FormValidator minValue(int value, {String? message}) {
    _addRule(FormRuleMinValue(value, message));
    return this;
  }

  /// Validate that the value is a maximum of [value] characters
  FormValidator maxLength(int value, {String? message}) {
    _addRule(FormRuleMaxLength(value, message));
    return this;
  }

  /// Validate that the value is a maximum size of [value]
  FormValidator maxSize(int value, {String? message}) {
    _addRule(FormRuleMaxSize(value, message));
    return this;
  }

  /// Validate that the value is a maximum of [value]
  FormValidator maxValue(int value, {String? message}) {
    _addRule(FormRuleMaxValue(value, message));
    return this;
  }

  /// Validate that the value is not empty
  FormValidator notEmpty({String? message}) {
    _addRule(FormRuleNotEmpty(message));
    return this;
  }

  /// Validate that the value is numeric
  FormValidator numeric({String? message}) {
    _addRule(FormRuleNumeric(message: message));
    return this;
  }

  /// Validate that the value is a date
  FormValidator date({String? message}) {
    _addRule(FormRuleDate(message: message));
    return this;
  }

  /// Validate that the value is capitalized
  FormValidator capitalized({String? message}) {
    _addRule(FormRuleCapitalized(message: message));
    return this;
  }

  /// Validate that the value is lowercase
  FormValidator lowercase({String? message}) {
    _addRule(FormRuleLowercase(message: message));
    return this;
  }

  /// Validate that the value is uppercase
  FormValidator uppercase({String? message}) {
    _addRule(FormRuleUppercase(message: message));
    return this;
  }

  /// Validate that the value is a valid zipcode for the US
  FormValidator zipcodeUs({String? message}) {
    _addRule(FormRuleZipcodeUs(message: message));
    return this;
  }

  /// Validate that the value is a valid postcode for the UK
  FormValidator postcodeUk({String? message}) {
    _addRule(FormRulePostcodeUk(message: message));
    return this;
  }

  /// Validate that the value matches a [regex] pattern
  FormValidator regex(String regex, {String? message}) {
    _addRule(FormRuleRegex(RegExp(regex), message));
    return this;
  }

  /// Validate that the date is younger than [age]
  FormValidator dateAgeIsYounger(int age, {String? message}) {
    _addRule(FormRuleDateAgeIsYounger(age, message));
    return this;
  }

  /// Validate that the date is older than [age]
  FormValidator dateAgeIsOlder(int age, {String? message}) {
    _addRule(FormRuleDateAgeIsOlder(age, message));
    return this;
  }

  /// Validate that the date is in the past
  FormValidator dateInPast({String? message}) {
    _addRule(FormRuleDateInPast(message));
    return this;
  }

  /// Validate that the date is in the future
  FormValidator dateInFuture({String? message}) {
    _addRule(FormRuleDateInFuture(message));
    return this;
  }

  /// Validate that the value is a password
  FormValidator password({required int strength, String? message}) {
    assert(
      strength > 0 && strength < 3,
      "Password strength must be between 1 and 2",
    );
    _addRule(FormRulePassword(strength: strength, message: message));
    return this;
  }

  /// Validate that the value equals another value
  FormValidator equals(dynamic data, {String? message}) {
    _addRule(FormRuleEquals(dataSource: data, message: message));
    return this;
  }

  /// Validate a custom rule
  /// [message] The message to display if the custom validation fails
  /// [validate] The custom validation function that takes the data and returns a boolean
  FormValidator custom({
    String? message,
    required bool Function(dynamic data) validate,
  }) {
    _addRule(FormRuleCustom(message: message, customValidation: validate));
    return this;
  }

  /// Mark this validator as nullable.
  /// When nullable, if the value is null or empty, validation will pass.
  /// If the value is not null/empty, all rules will be applied.
  FormValidator nullable() {
    _isNullable = true;
    return this;
  }

  /// Add a rule to the form validator
  void _addRule(FormRule rule) {
    rules.add(rule);
  }

  /// Set the data for the form validator
  void setData(dynamic data) {
    this.data = data ?? "";
  }

  /// Check the validation of the data against the rules
  /// Returns a [FormValidationResponse] indicating success or error
  FormValidationResult check([dynamic data]) {
    if (data != null) {
      setData(data);
    }
    FormValidationResult result = FormValidationResult(
      this.data,
      this.attribute,
    );

    if (_isNullable && (this.data == null || this.data.toString().isEmpty)) {
      return result;
    }

    for (FormRule rule in rules) {
      bool response = rule.validate(this.data);
      if (!response) {
        result.responses.add(FormValidationError(rule));
      } else {
        result.responses.add(FormValidationSuccess(rule));
      }
    }

    return result;
  }
}

class FormValidationResult {
  String? attribute;
  List<FormValidationResponse> responses = [];
  dynamic data;

  FormValidationResult(this.data, [this.attribute]);

  /// Check if all validations are valid
  bool get isValid =>
      responses.every((response) => (response is FormValidationSuccess));

  /// Get the error messages from the validation responses
  List<String> errorMessages() {
    return errorResponses
        .map((response) => _formatMessage(response.rule))
        .toList();
  }

  /// Get the error responses from the validation responses
  List<FormValidationError> get errorResponses =>
      responses.whereType<FormValidationError>().toList();

  /// Get the validated data from the validation responses
  List<dynamic> validatedData() {
    return responses.map((response) => response.data).toList();
  }

  /// Get the error message for the validation failure.
  String? getFirstErrorMessage() {
    if (errorResponses.isEmpty) {
      return null;
    }

    return _formatMessage(errorResponses.first.rule);
  }

  /// Get the first error rule from the validation responses.
  FormRule? getFirstErrorRule() {
    if (errorResponses.isEmpty) {
      return null;
    }
    return errorResponses.first.rule;
  }

  /// Get all error rules from the validation responses.
  List<FormRule> getErrorRules() {
    return errorResponses.map((response) => response.rule).toList();
  }

  /// Get all error messages from the validation responses.
  List<String> getErrorMessages() {
    return errorMessages();
  }

  /// Get all rules from the validation responses.
  List<FormRule> getRules() {
    return responses.map((response) => response.rule).toList();
  }

  /// Get a map of responses with the rule as the key and the response as the value.
  Map<dynamic, Map<FormRule, FormValidationResponse>> get responsesMap {
    return {
      data: Map.fromIterable(
        responses,
        key: (response) => response.rule,
        value: (response) => response,
      ),
    };
  }

  /// Format the message for the validation rule.
  String _formatMessage(FormRule rule) {
    if (rule.message != null) {
      return rule.message!.replaceAll('{{attribute}}', attribute ?? 'data');
    }
    return '';
  }
}
