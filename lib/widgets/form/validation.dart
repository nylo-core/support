/// FormValidator is a class that helps in managing form validation
/// It is used in the [NyFormData] class
/// Example:
/// ```dart
/// class RegisterForm extends NyFormData {
///
///  @override
///   Map<String, dynamic> validate() => {
///     "Email": FormValidator.rule("email", message: "Invalid email")
///   };
///```
class FormValidator {
  dynamic data;
  dynamic rules;
  String? message;
  bool Function(dynamic data)? customRule;

  /// Create a new form validator with [message] and [data]
  FormValidator({this.message, this.data});

  /// Create a new form validator with [rules]
  FormValidator.rule(this.rules, {this.message, this.data});

  /// Create a new custom validation rule
  FormValidator.custom(this.customRule, {this.message});

  /// Validate a password with a strength of 1 or 2
  /// [strength] 1: 1 uppercased letter, 1 digit, 8 characters
  /// [strength] 2: 1 uppercased letter, 1 digit, 1 special character, 8 characters
  /// [message] The message to display if the password is invalid
  FormValidator.password({int strength = 1, this.message}) {
    assert(strength > 0 && strength < 3,
        "Password strength must be between 1 and 2");
    rules = "password_v$strength";
  }

  /// Validate an email
  /// [message] The message to display if the email is invalid
  FormValidator.email({this.message}) {
    rules = "email";
  }

  /// Validate a UK phone number
  /// [message] The message to display if the phone number is invalid
  FormValidator.phoneNumber({this.message}) {
    rules = "phone_number_uk";
  }

  /// Validate a US phone number
  /// [message] The message to display if the phone number is invalid
  FormValidator.phoneNumberUs({this.message}) {
    rules = "phone_number_us";
  }

  /// Validate a URL
  /// [message] The message to display if the URL is invalid
  FormValidator.url({this.message}) {
    rules = "url";
  }

  /// Validate the value contains one of the [values]
  /// [message] The message to display if the value is invalid
  FormValidator.contains(List<String> values, {this.message}) {
    rules = "contains:${values.join(",")}";
  }

  /// Validate a value is a boolean
  /// [message] The message to display if the value is invalid
  FormValidator.boolean({this.message}) {
    rules = "boolean";
  }

  /// Validate that the value is a minimum of [value] characters
  /// [message] The message to display if the value is invalid
  /// [value] The minimum number of characters
  FormValidator.minLength(int value, {this.message}) {
    rules = "min:$value";
  }

  /// Validate that the value is a minimum size of [value]
  /// [message] The message to display if the value is invalid
  /// [value] The minimum size
  FormValidator.minSize(int value, {this.message}) {
    rules = "min:$value";
  }

  /// Validate that the value is a minimum of [value]
  /// [message] The message to display if the value is invalid
  /// [value] The minimum value
  FormValidator.minValue(int value, {this.message}) {
    rules = "min:$value";
  }

  /// Validate that the value is a maximum of [value] characters
  /// [message] The message to display if the value is invalid
  /// [value] The maximum number of characters
  FormValidator.maxLength(int value, {this.message}) {
    rules = "max:$value";
  }

  /// Validate that the value is a maximum size of [value]
  /// [message] The message to display if the value is invalid
  /// [value] The maximum size
  FormValidator.maxSize(int value, {this.message}) {
    rules = "max:$value";
  }

  /// Validate that the value is a maximum of [value]
  /// [message] The message to display if the value is invalid
  /// [value] The maximum value
  FormValidator.maxValue(int value, {this.message}) {
    rules = "max:$value";
  }

  /// Validate that the value is not empty
  /// [message] The message to display if the value is invalid
  FormValidator.notEmpty({this.message}) {
    rules = "not_empty";
  }

  /// Validate that the value is numeric
  /// [message] The message to display if the value is invalid
  FormValidator.numeric({this.message}) {
    rules = "numeric";
  }

  /// Validate that the value is a date
  /// [message] The message to display if the value is invalid
  FormValidator.date({this.message}) {
    rules = "date";
  }

  /// Validate that the value is capitalized
  /// [message] The message to display if the value is invalid
  FormValidator.capitalized({this.message}) {
    rules = "capitalized";
  }

  /// Validate that the value is lowercase
  /// [message] The message to display if the value is invalid
  FormValidator.lowercase({this.message}) {
    rules = "lowercase";
  }

  /// Validate that the value is uppercase
  /// [message] The message to display if the value is invalid
  FormValidator.uppercase({this.message}) {
    rules = "uppercase";
  }

  /// Validate that the value is a valid zipcode for the US
  /// [message] The message to display if the value is invalid
  FormValidator.zipcodeUs({this.message}) {
    rules = "zipcode_us";
  }

  /// Validate that the value is a valid postcode for the UK
  /// [message] The message to display if the value is invalid
  FormValidator.postcodeUk({this.message}) {
    rules = "postcode_uk";
  }

  /// Validate that the value matches a [regex] pattern
  /// [message] The message to display if the value is invalid
  FormValidator.regex(String regex, {this.message}) {
    rules = r'regex:' + regex;
  }

  /// Validate that the date is younger than [age]
  /// [message] The message to display if the value is invalid
  /// [age] The age to compare
  FormValidator.dateAgeIsYounger(int age, {this.message}) {
    rules = "date_age_is_younger:$age";
  }

  /// Validate that the date is older than [age]
  /// [message] The message to display if the value is invalid
  /// [age] The age to compare
  FormValidator.dateAgeIsOlder(int age, {this.message}) {
    rules = "date_age_is_older:$age";
  }

  /// Validate that the date is in the past
  /// [message] The message to display if the value is invalid
  FormValidator.dateInPast({this.message}) {
    rules = "date_in_past";
  }

  /// Validate that the date is in the future
  /// [message] The message to display if the value is invalid
  FormValidator.dateInFuture({this.message}) {
    rules = "date_in_future";
  }

  /// Validate that the value is true
  /// [message] The message to display if the value is invalid
  FormValidator.isTrue({this.message}) {
    rules = "is_true";
  }

  /// Validate that the value is false
  /// [message] The message to display if the value is invalid
  FormValidator.isFalse({this.message}) {
    rules = "is_false";
  }

  /// Validate an email
  FormValidator email() {
    _addRule("email");
    return this;
  }

  /// Validate a UK phone number
  FormValidator phoneNumberUk() {
    _addRule("phone_number_uk");
    return this;
  }

  /// Validate a US phone number
  FormValidator phoneNumberUs() {
    _addRule("phone_number_us");
    return this;
  }

  /// Validate a URL
  FormValidator url() {
    _addRule("url");
    return this;
  }

  /// Validate the value contains one of the [values]
  FormValidator contains(List<String> values) {
    _addRule("contains:${values.join(",")}");
    return this;
  }

  /// Validate a value is a boolean
  FormValidator boolean() {
    _addRule("boolean");
    return this;
  }

  /// Validate that the value is a minimum of [value] characters
  FormValidator minLength(int value) {
    _addRule("min:$value");
    return this;
  }

  /// Validate that the value is a minimum size of [value]
  FormValidator minSize(int value) {
    _addRule("min:$value");
    return this;
  }

  /// Validate that the value is a minimum of [value]
  FormValidator minValue(int value) {
    _addRule("min:$value");
    return this;
  }

  /// Validate that the value is a maximum of [value] characters
  FormValidator maxLength(int value) {
    _addRule("max:$value");
    return this;
  }

  /// Validate that the value is a maximum size of [value]
  FormValidator maxSize(int value) {
    _addRule("max:$value");
    return this;
  }

  /// Validate that the value is a maximum of [value]
  FormValidator maxValue(int value) {
    _addRule("max:$value");
    return this;
  }

  /// Validate that the value is not empty
  FormValidator notEmpty() {
    _addRule("not_empty");
    return this;
  }

  /// Validate that the value is numeric
  FormValidator numeric() {
    _addRule("numeric");
    return this;
  }

  /// Validate that the value is a date
  FormValidator date() {
    _addRule("date");
    return this;
  }

  /// Validate that the value is capitalized
  FormValidator capitalized() {
    _addRule("capitalized");
    return this;
  }

  /// Validate that the value is lowercase
  FormValidator lowercase() {
    _addRule("lowercase");
    return this;
  }

  /// Validate that the value is uppercase
  FormValidator uppercase() {
    _addRule("uppercase");
    return this;
  }

  /// Validate that the value is a valid zipcode for the US
  FormValidator zipcodeUs() {
    _addRule("zipcode_us");
    return this;
  }

  /// Validate that the value is a valid postcode for the UK
  FormValidator postcodeUk() {
    _addRule("postcode_uk");
    return this;
  }

  /// Validate that the value matches a [regex] pattern
  FormValidator regex(String regex) {
    _addRule(r'regex:' + regex);
    return this;
  }

  /// Validate that the date is younger than [age]
  FormValidator dateAgeIsYounger(int age) {
    _addRule("date_age_is_younger:$age");
    return this;
  }

  /// Validate that the date is older than [age]
  FormValidator dateAgeIsOlder(int age) {
    _addRule("date_age_is_older:$age");
    return this;
  }

  /// Validate that the date is in the past
  FormValidator dateInPast() {
    _addRule("date_in_past");
    return this;
  }

  /// Validate that the date is in the future
  FormValidator dateInFuture() {
    _addRule("date_in_future");
    return this;
  }

  /// Validate that the value is true
  FormValidator isTrue() {
    _addRule("is_true");
    return this;
  }

  /// Validate that the value is false
  FormValidator isFalse() {
    _addRule("is_false");
    return this;
  }

  /// Validate that the value is a password
  FormValidator password({required int strength}) {
    assert(strength > 0 && strength < 3,
        "Password strength must be between 1 and 2");
    _addRule("password_v$strength");
    return this;
  }

  /// Add a rule to the form validator
  void _addRule(String rule) {
    if (rules == null) {
      rules = rule;
      return;
    }
    rules = rules += "|$rule";
  }

  /// Set the data for the form validator
  void setData(dynamic data) {
    if (data is List) {
      this.data = data.join(", ").toString();
      return;
    }
    if (data is double) {
      this.data = data.toString();
      return;
    }
    if (data is int) {
      this.data = data.toString();
      return;
    }
    this.data = data ?? "";
  }

  /// Transform the [FormValidator] into a validation rule
  List toValidationRule() {
    List listData = [data, rules];
    if (message != null) {
      listData.add(message);
    }
    return listData;
  }
}
