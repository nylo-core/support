import 'form_rule.dart';

class FormRuleEmail extends FormRule {
  @override
  String? rule;

  @override
  String? message = "The {{attribute}} must be a valid email address.";

  FormRuleEmail({this.rule = "email", String? message}) {
    if (message != null) {
      this.message = message;
    }
  }

  /// Email validation regex
  static final RegExp _emailRegex = RegExp(
    r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?",
  );

  @override
  bool validate(data) {
    if (data is! String) return false;
    return _isEmail(data.toLowerCase());
  }

  /// Check if string [input] is an email
  bool _isEmail(String input) {
    if (input.length > 254) {
      return false;
    }
    var valid = _emailRegex.hasMatch(input);
    if (!valid) {
      return false;
    }

    var parts = input.split('@');
    if (parts.length != 2) {
      return false;
    }
    if (parts[0].isEmpty || parts[0].length > 64) {
      return false;
    }

    var domainParts = parts[1].split(".");
    if (domainParts.any((part) => part.isEmpty || part.length > 63)) {
      return false;
    }

    return true;
  }
}

class FormRulePassword extends FormRule {
  @override
  String? rule;

  final int strength;

  @override
  String? message = "The {{attribute}} must be a valid password.";

  FormRulePassword({
    this.rule = "password",
    String? message,
    required this.strength,
  }) {
    if (message != null) {
      this.message = message;
      return;
    }
    if (strength == 2) {
      this.message =
          "The {{attribute}} must contain at least one uppercase letter, one digit, a minimum of 8 characters, and at least one special character.";
    } else {
      this.message =
          "The {{attribute}} must contain at least one uppercase letter, one digit, and a minimum of 8 characters.";
    }
  }

  @override
  bool validate(data) {
    if (data == null) return false;

    if (strength == 2) {
      /// - At least one uppercase letter
      /// - At least one digit
      /// - Minimum of 8 characters
      /// - At least one special character
      RegExp regExp = RegExp(
        r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$',
      );
      return regExp.hasMatch(data.toString());
    }

    /// This rule is used to validate a password with the following requirements:
    /// - At least one uppercase letter
    /// - At least one digit
    /// - Minimum of 8 characters
    RegExp regExp = RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$');
    return regExp.hasMatch(data.toString());
  }
}

/// FormRuleEquals
/// This rule checks if the input data is equal to a specified data source.
class FormRuleEquals extends FormRule {
  @override
  String? rule;

  final dynamic dataSource;

  @override
  String? message = "The {{attribute}} must match.";

  FormRuleEquals({
    this.rule = "equals",
    String? message,
    required this.dataSource,
  }) {
    if (message != null) {
      this.message = message;
    }
  }

  @override
  bool validate(data) {
    return dataSource == data;
  }
}

class FormRuleCustom extends FormRule {
  @override
  String? rule;

  final bool Function(dynamic data) customValidation;

  @override
  String? message = "The {{attribute}} is invalid.";

  FormRuleCustom({
    this.rule = "custom",
    String? message,
    required this.customValidation,
  }) {
    if (message != null) {
      this.message = message;
    }
  }

  @override
  bool validate(data) {
    return customValidation(data);
  }
}

class FormRuleMinLength extends FormRule {
  @override
  String? rule;

  final int minLength;

  @override
  String? message;

  FormRuleMinLength(this.minLength, [this.message]) {
    this.rule = "min_length";
    if (message == null) {
      message =
          "The {{attribute}} must be at least $minLength characters long.";
      return;
    } else {
      this.message = message?.replaceAll("{{minLength}}", minLength.toString());
    }
  }

  @override
  bool validate(data) {
    if (data is String) {
      return data.length >= minLength;
    }
    return false;
  }
}

class FormRuleMinSize extends FormRule {
  @override
  String? rule;

  final int minSize;

  @override
  String? message;

  FormRuleMinSize(this.minSize, [String? message]) {
    this.rule = "min_size";
    if (message == null) {
      this.message = "The {{attribute}} must be at least $minSize in size.";
    } else {
      this.message = message.replaceAll("{{minSize}}", minSize.toString());
    }
  }

  @override
  bool validate(data) {
    if (data is List || data is String) {
      return data.length >= minSize;
    }
    return false;
  }
}

class FormRuleMinValue extends FormRule {
  @override
  String? rule;

  final int minValue;

  @override
  String? message;

  FormRuleMinValue(this.minValue, [String? message]) {
    this.rule = "min_value";
    if (message != null) {
      this.message = message.replaceAll("{{minValue}}", minValue.toString());
    } else {
      this.message = "The {{attribute}} must be at least $minValue.";
    }
  }

  @override
  bool validate(data) {
    if (data is String) {
      return data.length >= minValue;
    }
    if (data is num) {
      return data >= minValue;
    }
    if (data is List) {
      return data.length >= minValue;
    }
    if (data is Map) {
      return data.length >= minValue;
    }
    return false;
  }
}

class FormRuleMaxLength extends FormRule {
  @override
  String? rule;

  final int maxLength;

  @override
  String? message;

  FormRuleMaxLength(this.maxLength, [String? message]) {
    this.rule = "max_length";
    if (message == null) {
      this.message =
          "The {{attribute}} must be at most $maxLength characters long.";
    } else {
      this.message = message.replaceAll("{{maxLength}}", maxLength.toString());
    }
  }

  @override
  bool validate(data) {
    if (data is String) {
      return data.length <= maxLength;
    }
    return false;
  }
}

class FormRuleMaxSize extends FormRule {
  @override
  String? rule;

  final int maxSize;

  @override
  String? message;

  FormRuleMaxSize(this.maxSize, [String? message]) {
    this.rule = "max_size";
    if (message == null) {
      this.message = "The {{attribute}} must be at most $maxSize in size.";
    } else {
      this.message = message.replaceAll("{{maxSize}}", maxSize.toString());
    }
  }

  @override
  bool validate(data) {
    if (data is List || data is String) {
      return data.length <= maxSize;
    }
    return false;
  }
}

class FormRuleMaxValue extends FormRule {
  @override
  String? rule;

  final int maxValue;

  @override
  String? message;

  FormRuleMaxValue(this.maxValue, [String? message]) {
    rule = "max_value";
    if (message == null) {
      this.message = "The {{attribute}} must be at most $maxValue.";
    } else {
      this.message = message.replaceAll("{{maxValue}}", maxValue.toString());
    }
  }

  @override
  bool validate(data) {
    if (data is num) {
      return data <= maxValue;
    }
    return false;
  }
}

class FormRuleRegex extends FormRule {
  @override
  String? rule;

  final RegExp regex;

  @override
  String? message;

  FormRuleRegex(this.regex, [String? message]) {
    this.rule = "regex";
    if (message == null) {
      this.message = "The {{attribute}} is invalid.";
    } else {
      this.message = message;
    }
  }

  @override
  bool validate(data) {
    if (data is String) {
      return regex.hasMatch(data);
    }
    return false;
  }
}

class FormRuleDateAgeIsYounger extends FormRule {
  @override
  String? rule;

  final int age;

  @override
  String? message;

  FormRuleDateAgeIsYounger(this.age, [String? message]) {
    this.rule = "date_age_is_younger";
    if (message == null) {
      this.message = "The {{attribute}} must be younger than $age years.";
    } else {
      this.message = message.replaceAll("{{age}}", age.toString());
    }
  }

  @override
  bool validate(data) {
    if (data is DateTime) {
      final now = DateTime.now();
      int ageInYears = now.year - data.year;
      // Adjust if birthday hasn't occurred yet this year
      if (now.month < data.month ||
          (now.month == data.month && now.day < data.day)) {
        ageInYears--;
      }
      return ageInYears < age;
    }
    return false;
  }
}

class FormRuleDateAgeIsOlder extends FormRule {
  @override
  String? rule;

  final int age;

  @override
  String? message;

  FormRuleDateAgeIsOlder(this.age, [String? message]) {
    this.rule = "date_age_is_older";
    if (message == null) {
      this.message = "The {{attribute}} must be older than $age years.";
    } else {
      this.message = message.replaceAll("{{age}}", age.toString());
    }
  }

  @override
  bool validate(data) {
    if (data is DateTime) {
      final now = DateTime.now();
      int ageInYears = now.year - data.year;
      // Adjust if birthday hasn't occurred yet this year
      if (now.month < data.month ||
          (now.month == data.month && now.day < data.day)) {
        ageInYears--;
      }
      return ageInYears > age;
    }
    return false;
  }
}

class FormRuleDateInPast extends FormRule {
  @override
  String? rule;

  @override
  String? message;

  FormRuleDateInPast([String? message]) {
    this.rule = "date_in_past";
    if (message == null) {
      this.message = "The {{attribute}} must be in the past.";
    } else {
      this.message = message;
    }
  }

  @override
  bool validate(data) {
    if (data is DateTime) {
      return data.isBefore(DateTime.now());
    }
    return false;
  }
}

class FormRuleDateInFuture extends FormRule {
  @override
  String? rule;

  @override
  String? message;

  FormRuleDateInFuture([String? message]) {
    this.rule = "date_in_future";
    if (message == null) {
      this.message = "The {{attribute}} must be in the future.";
    } else {
      this.message = message;
    }
  }

  @override
  bool validate(data) {
    if (data is DateTime) {
      return data.isAfter(DateTime.now());
    }
    return false;
  }
}

class FormRulePhoneNumberUs extends FormRule {
  @override
  String? rule;

  @override
  String? message = "The {{attribute}} is not a valid phone number.";

  FormRulePhoneNumberUs({this.rule = "phone_number_us", String? message}) {
    if (message != null) {
      this.message = message;
    }
  }

  @override
  bool validate(data) {
    RegExp regExp = RegExp(
      r'^\(?(\d{3})\)?[-\. ]?(\d{3})[-\. ]?(\d{4})( x\d{4})?$',
    );
    return regExp.hasMatch(data.toString());
  }
}

class FormRulePhoneNumberUk extends FormRule {
  @override
  String? rule;

  @override
  String? message = "The {{attribute}} is not a valid phone number";

  FormRulePhoneNumberUk({this.rule = "phone_number_uk", String? message}) {
    if (message != null) {
      this.message = message;
    }
  }

  @override
  bool validate(data) {
    RegExp regExp = RegExp(
      r'^(((\+44\s?\d{4}|\(?0\d{4}\)?)\s?\d{3}\s?\d{3})|((\+44\s?\d{3}|\(?0\d{3}\)?)\s?\d{3}\s?\d{4})|((\+44\s?\d{2}|\(?0\d{2}\)?)\s?\d{4}\s?\d{4}))(\s?\#(\d{4}|\d{3}))?$',
    );

    return regExp.hasMatch(data.toString());
  }
}

class FormRuleUrl extends FormRule {
  @override
  String? rule;

  @override
  String? message = "The {{attribute}} must be a valid URL.";

  FormRuleUrl({this.rule = "url", String? message}) {
    if (message != null) {
      this.message = message;
    }
  }

  @override
  bool validate(data) {
    if (data is String) {
      final regex = RegExp(
        r'^(https?|ftp):\/\/[^\s/$.?#].[^\s]*$',
      ); // Basic URL validation regex
      return regex.hasMatch(data);
    }
    return false;
  }
}

class FormRuleContains extends FormRule {
  @override
  String? rule;

  final List<String> values;

  @override
  String? message;

  FormRuleContains(this.values, [String? message]) {
    this.rule = "contains";
    if (message == null) {
      this.message =
          "The {{attribute}} must contain one of the following values: ${values.join(", ")}.";
    } else {
      this.message = message.replaceAll(
        "{{values}}",
        values.map((e) => e.toString()).join(", "),
      );
    }
  }

  @override
  bool validate(data) {
    if (data is String) {
      return values.any((value) => data.contains(value));
    }
    return false;
  }
}

class FormRuleBeginsWith extends FormRule {
  @override
  String? rule;

  final String prefix;

  @override
  String? message;

  FormRuleBeginsWith(this.prefix, [String? message]) {
    this.rule = "begins_with";
    if (message != null) {
      this.message = message.replaceAll("{{prefix}}", prefix);
    } else {
      this.message = "The {{attribute}} must begin with '$prefix'.";
    }
  }

  @override
  bool validate(data) {
    if (data is String) {
      return data.startsWith(prefix);
    }
    return false;
  }
}

class FormRuleEndsWith extends FormRule {
  @override
  String? rule;

  final String suffix;

  @override
  String? message;

  FormRuleEndsWith(this.suffix, [String? message]) {
    this.rule = "ends_with";
    if (message != null) {
      this.message = message.replaceAll("{{suffix}}", suffix);
    } else {
      this.message = "The {{attribute}} must end with '$suffix'.";
    }
  }

  @override
  bool validate(data) {
    if (data is String) {
      return data.endsWith(suffix);
    }
    return false;
  }
}

class FormRuleBooleanTrue extends FormRule {
  @override
  String? rule;

  @override
  String? message = "The {{attribute}} must be true.";

  FormRuleBooleanTrue({this.rule = "boolean_true", String? message}) {
    if (message != null) {
      this.message = message;
    }
  }

  @override
  bool validate(data) {
    return data is bool && data == true;
  }
}

class FormRuleBooleanFalse extends FormRule {
  @override
  String? rule;

  @override
  String? message = "The {{attribute}} must be false.";

  FormRuleBooleanFalse({this.rule = "boolean_false", String? message}) {
    if (message != null) {
      this.message = message;
    }
  }

  @override
  bool validate(data) {
    return data is bool && data == false;
  }
}

class FormRuleNotEmpty extends FormRule {
  @override
  String? rule;

  @override
  String? message = "The {{attribute}} must not be empty.";

  FormRuleNotEmpty([String? message]) {
    this.rule = "not_empty";
    if (message != null) {
      this.message = message;
    }
  }

  @override
  bool validate(data) {
    if (data == null) return false;
    if (data is String) return data.isNotEmpty;
    if (data is List) return data.isNotEmpty;
    if (data is Map) return data.isNotEmpty;
    return true; // Any other non-null value is valid
  }
}

class FormRuleNumeric extends FormRule {
  @override
  String? rule;

  @override
  String? message = "The {{attribute}} must be a numeric value.";

  FormRuleNumeric({this.rule = "numeric", String? message}) {
    if (message != null) {
      this.message = message;
    }
  }

  @override
  bool validate(data) {
    return data is num;
  }
}

class FormRuleDate extends FormRule {
  @override
  String? rule;

  @override
  String? message = "The {{attribute}} must be a valid date.";

  FormRuleDate({this.rule = "date", String? message}) {
    if (message != null) {
      this.message = message;
    }
  }

  @override
  bool validate(data) {
    if (data is DateTime) {
      return true;
    }
    if (data is String) {
      return DateTime.tryParse(data) != null;
    }
    return false;
  }
}

class FormRuleCapitalized extends FormRule {
  @override
  String? rule;

  @override
  String? message = "The {{attribute}} must be capitalized.";

  FormRuleCapitalized({this.rule = "capitalized", String? message}) {
    if (message != null) {
      this.message = message;
    }
  }

  @override
  bool validate(data) {
    if (data is String && data.isNotEmpty) {
      return _isCapitalized(data);
    }
    return false;
  }

  /// Check if string [input] is capitalized
  bool _isCapitalized(String input) {
    final capitalizedFirst = input[0].toUpperCase();
    final capitalized = "$capitalizedFirst${input.substring(1)}";
    return input == capitalized;
  }
}

class FormRuleLowercase extends FormRule {
  @override
  String? rule;

  @override
  String? message = "The {{attribute}} must be in lowercase.";

  FormRuleLowercase({this.rule = "lowercase", this.message});

  @override
  bool validate(data) {
    if (data is String) {
      return data == data.toLowerCase();
    }
    return false;
  }
}

class FormRuleUppercase extends FormRule {
  @override
  String? rule;

  @override
  String? message = "The {{attribute}} must be in uppercase.";

  FormRuleUppercase({this.rule = "uppercase", String? message}) {
    if (message != null) {
      this.message = message;
    }
  }

  @override
  bool validate(data) {
    if (data is String) {
      return data == data.toUpperCase();
    }
    return false;
  }
}

class FormRuleZipcodeUs extends FormRule {
  @override
  String? rule;

  @override
  String? message = "The {{attribute}} field is not a valid zip code";

  FormRuleZipcodeUs({this.rule = "zipcode_us", String? message}) {
    if (message != null) {
      this.message = message;
    }
  }

  @override
  bool validate(data) {
    RegExp regExp = RegExp(r'(^[0-9]{4}?[0-9]$|^[0-9]{4}?[0-9]-[0-9]{4}$)');
    return regExp.hasMatch(data.toString());
  }
}

class FormRulePostcodeUk extends FormRule {
  @override
  String? rule;

  @override
  String? message = "The {{attribute}} must be a valid UK postcode.";

  FormRulePostcodeUk({this.rule = "postcode_uk", String? message}) {
    if (message != null) {
      this.message = message;
    }
  }

  @override
  bool validate(data) {
    // Covers all UK postcode formats: A9 9AA, A9A 9AA, A99 9AA, AA9 9AA, AA9A 9AA, AA99 9AA
    RegExp regExp = RegExp(r'^([A-Za-z]{1,2}\d[A-Za-z\d]?)\s*(\d[A-Za-z]{2})$');
    return regExp.hasMatch(data.toString());
  }
}
