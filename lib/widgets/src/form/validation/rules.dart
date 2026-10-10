import 'form_rule.dart';

class FormRuleEmail extends FormRule {
  FormRuleEmail({super.rule = "email", String? message})
    : super(message: message ?? "nylo.validation.email");

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
    bool valid = _emailRegex.hasMatch(input);
    if (!valid) {
      return false;
    }

    List<String> parts = input.split('@');
    if (parts.length != 2) {
      return false;
    }
    if (parts[0].isEmpty || parts[0].length > 64) {
      return false;
    }

    List<String> domainParts = parts[1].split(".");
    if (domainParts.any((part) => part.isEmpty || part.length > 63)) {
      return false;
    }

    return true;
  }
}

class FormRulePassword extends FormRule {
  final int strength;

  FormRulePassword({
    super.rule = "password",
    String? message,
    required this.strength,
  }) {
    if (message != null) {
      this.message = message;
      return;
    }
    if (strength == 2) {
      this.message = "nylo.validation.password_strength_2";
    } else {
      this.message = "nylo.validation.password_strength_1";
    }
  }

  @override
  bool validate(data) {
    if (data == null) return false;

    if (strength == 2) {
      return _strength2.hasMatch(data.toString());
    }
    return _strength1.hasMatch(data.toString());
  }

  /// Strength 1:
  /// - At least one uppercase letter
  /// - At least one digit
  /// - Minimum of 8 characters
  static final RegExp _strength1 = RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$');

  /// Strength 2: strength 1 plus at least one special character.
  static final RegExp _strength2 = RegExp(
    r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$',
  );
}

/// FormRuleEquals
/// This rule checks if the input data is equal to a specified data source.
class FormRuleEquals extends FormRule {
  final dynamic dataSource;

  FormRuleEquals({
    super.rule = "equals",
    String? message,
    required this.dataSource,
  }) : super(message: message ?? "nylo.validation.equals");

  @override
  bool validate(data) {
    return dataSource == data;
  }
}

class FormRuleCustom extends FormRule {
  final bool Function(dynamic data) customValidation;

  FormRuleCustom({
    super.rule = "custom",
    String? message,
    required this.customValidation,
  }) : super(message: message ?? "nylo.validation.custom");

  @override
  bool validate(data) {
    return customValidation(data);
  }
}

class FormRuleMinLength extends FormRule {
  final int minLength;

  FormRuleMinLength(this.minLength, [String? message]) {
    rule = "min_length";
    if (message == null) {
      this.message = "nylo.validation.min_length";
    } else {
      this.message = message.replaceAll("{{minLength}}", minLength.toString());
    }
  }

  @override
  Map<String, String> get messageArguments => {"minLength": "$minLength"};

  @override
  bool validate(data) {
    if (data is String) {
      return data.length >= minLength;
    }
    return false;
  }
}

class FormRuleMinSize extends FormRule {
  final int minSize;

  FormRuleMinSize(this.minSize, [String? message]) {
    rule = "min_size";
    if (message == null) {
      this.message = "nylo.validation.min_size";
    } else {
      this.message = message.replaceAll("{{minSize}}", minSize.toString());
    }
  }

  @override
  Map<String, String> get messageArguments => {"minSize": "$minSize"};

  @override
  bool validate(data) {
    if (data is List || data is String) {
      return data.length >= minSize;
    }
    return false;
  }
}

class FormRuleMinValue extends FormRule {
  final int minValue;

  FormRuleMinValue(this.minValue, [String? message]) {
    rule = "min_value";
    if (message != null) {
      this.message = message.replaceAll("{{minValue}}", minValue.toString());
    } else {
      this.message = "nylo.validation.min_value";
    }
  }

  @override
  Map<String, String> get messageArguments => {"minValue": "$minValue"};

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
  final int maxLength;

  FormRuleMaxLength(this.maxLength, [String? message]) {
    rule = "max_length";
    if (message == null) {
      this.message = "nylo.validation.max_length";
    } else {
      this.message = message.replaceAll("{{maxLength}}", maxLength.toString());
    }
  }

  @override
  Map<String, String> get messageArguments => {"maxLength": "$maxLength"};

  @override
  bool validate(data) {
    if (data is String) {
      return data.length <= maxLength;
    }
    return false;
  }
}

class FormRuleMaxSize extends FormRule {
  final int maxSize;

  FormRuleMaxSize(this.maxSize, [String? message]) {
    rule = "max_size";
    if (message == null) {
      this.message = "nylo.validation.max_size";
    } else {
      this.message = message.replaceAll("{{maxSize}}", maxSize.toString());
    }
  }

  @override
  Map<String, String> get messageArguments => {"maxSize": "$maxSize"};

  @override
  bool validate(data) {
    if (data is List || data is String) {
      return data.length <= maxSize;
    }
    return false;
  }
}

class FormRuleMaxValue extends FormRule {
  final int maxValue;

  FormRuleMaxValue(this.maxValue, [String? message]) {
    rule = "max_value";
    if (message == null) {
      this.message = "nylo.validation.max_value";
    } else {
      this.message = message.replaceAll("{{maxValue}}", maxValue.toString());
    }
  }

  @override
  Map<String, String> get messageArguments => {"maxValue": "$maxValue"};

  @override
  bool validate(data) {
    if (data is num) {
      return data <= maxValue;
    }
    return false;
  }
}

class FormRuleRegex extends FormRule {
  final RegExp regex;

  FormRuleRegex(this.regex, [String? message]) {
    rule = "regex";
    if (message == null) {
      this.message = "nylo.validation.regex";
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
  final int age;

  FormRuleDateAgeIsYounger(this.age, [String? message]) {
    rule = "date_age_is_younger";
    if (message == null) {
      this.message = "nylo.validation.date_age_is_younger";
    } else {
      this.message = message.replaceAll("{{age}}", age.toString());
    }
  }

  @override
  Map<String, String> get messageArguments => {"age": "$age"};

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
  final int age;

  FormRuleDateAgeIsOlder(this.age, [String? message]) {
    rule = "date_age_is_older";
    if (message == null) {
      this.message = "nylo.validation.date_age_is_older";
    } else {
      this.message = message.replaceAll("{{age}}", age.toString());
    }
  }

  @override
  Map<String, String> get messageArguments => {"age": "$age"};

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
  FormRuleDateInPast([String? message]) {
    rule = "date_in_past";
    if (message == null) {
      this.message = "nylo.validation.date_in_past";
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
  FormRuleDateInFuture([String? message]) {
    rule = "date_in_future";
    if (message == null) {
      this.message = "nylo.validation.date_in_future";
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
  FormRulePhoneNumberUs({super.rule = "phone_number_us", String? message})
    : super(message: message ?? "nylo.validation.phone_number_us");

  static final RegExp _regExp = RegExp(
    r'^\(?(\d{3})\)?[-\. ]?(\d{3})[-\. ]?(\d{4})( x\d{4})?$',
  );

  @override
  bool validate(data) => _regExp.hasMatch(data.toString());
}

class FormRulePhoneNumberUk extends FormRule {
  FormRulePhoneNumberUk({super.rule = "phone_number_uk", String? message})
    : super(message: message ?? "nylo.validation.phone_number_uk");

  static final RegExp _regExp = RegExp(
    r'^(((\+44\s?\d{4}|\(?0\d{4}\)?)\s?\d{3}\s?\d{3})|((\+44\s?\d{3}|\(?0\d{3}\)?)\s?\d{3}\s?\d{4})|((\+44\s?\d{2}|\(?0\d{2}\)?)\s?\d{4}\s?\d{4}))(\s?\#(\d{4}|\d{3}))?$',
  );

  @override
  bool validate(data) => _regExp.hasMatch(data.toString());
}

class FormRuleUrl extends FormRule {
  FormRuleUrl({super.rule = "url", String? message})
    : super(message: message ?? "nylo.validation.url");

  /// Basic URL validation regex.
  static final RegExp _regExp = RegExp(r'^(https?|ftp):\/\/[^\s/$.?#].[^\s]*$');

  @override
  bool validate(data) {
    if (data is String) {
      return _regExp.hasMatch(data);
    }
    return false;
  }
}

class FormRuleContains extends FormRule {
  final List<String> values;

  FormRuleContains(this.values, [String? message]) {
    rule = "contains";
    if (message == null) {
      this.message = "nylo.validation.contains";
    } else {
      this.message = message.replaceAll(
        "{{values}}",
        values.map((e) => e.toString()).join(", "),
      );
    }
  }

  @override
  Map<String, String> get messageArguments => {"values": values.join(", ")};

  @override
  bool validate(data) {
    if (data is String) {
      return values.any((value) => data.contains(value));
    }
    return false;
  }
}

class FormRuleBeginsWith extends FormRule {
  final String prefix;

  FormRuleBeginsWith(this.prefix, [String? message]) {
    rule = "begins_with";
    if (message != null) {
      this.message = message.replaceAll("{{prefix}}", prefix);
    } else {
      this.message = "nylo.validation.begins_with";
    }
  }

  @override
  Map<String, String> get messageArguments => {"prefix": prefix};

  @override
  bool validate(data) {
    if (data is String) {
      return data.startsWith(prefix);
    }
    return false;
  }
}

class FormRuleEndsWith extends FormRule {
  final String suffix;

  FormRuleEndsWith(this.suffix, [String? message]) {
    rule = "ends_with";
    if (message != null) {
      this.message = message.replaceAll("{{suffix}}", suffix);
    } else {
      this.message = "nylo.validation.ends_with";
    }
  }

  @override
  Map<String, String> get messageArguments => {"suffix": suffix};

  @override
  bool validate(data) {
    if (data is String) {
      return data.endsWith(suffix);
    }
    return false;
  }
}

class FormRuleBooleanTrue extends FormRule {
  FormRuleBooleanTrue({super.rule = "boolean_true", String? message})
    : super(message: message ?? "nylo.validation.boolean_true");

  @override
  bool validate(data) {
    return data is bool && data == true;
  }
}

class FormRuleBooleanFalse extends FormRule {
  FormRuleBooleanFalse({super.rule = "boolean_false", String? message})
    : super(message: message ?? "nylo.validation.boolean_false");

  @override
  bool validate(data) {
    return data is bool && data == false;
  }
}

class FormRuleNotEmpty extends FormRule {
  FormRuleNotEmpty([String? message])
    : super(rule: "not_empty", message: message ?? "nylo.validation.not_empty");

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
  FormRuleNumeric({super.rule = "numeric", String? message})
    : super(message: message ?? "nylo.validation.numeric");

  @override
  bool validate(data) {
    return data is num;
  }
}

class FormRuleDate extends FormRule {
  FormRuleDate({super.rule = "date", String? message})
    : super(message: message ?? "nylo.validation.date");

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
  FormRuleCapitalized({super.rule = "capitalized", String? message})
    : super(message: message ?? "nylo.validation.capitalized");

  @override
  bool validate(data) {
    if (data is String && data.isNotEmpty) {
      return _isCapitalized(data);
    }
    return false;
  }

  /// Check if string [input] is capitalized
  bool _isCapitalized(String input) {
    final String capitalizedFirst = input[0].toUpperCase();
    final capitalized = "$capitalizedFirst${input.substring(1)}";
    return input == capitalized;
  }
}

class FormRuleLowercase extends FormRule {
  FormRuleLowercase({super.rule = "lowercase", String? message})
    : super(message: message ?? "nylo.validation.lowercase");

  @override
  bool validate(data) {
    if (data is String) {
      return data == data.toLowerCase();
    }
    return false;
  }
}

class FormRuleUppercase extends FormRule {
  FormRuleUppercase({super.rule = "uppercase", String? message})
    : super(message: message ?? "nylo.validation.uppercase");

  @override
  bool validate(data) {
    if (data is String) {
      return data == data.toUpperCase();
    }
    return false;
  }
}

class FormRuleZipcodeUs extends FormRule {
  FormRuleZipcodeUs({super.rule = "zipcode_us", String? message})
    : super(message: message ?? "nylo.validation.zipcode_us");

  static final RegExp _regExp = RegExp(
    r'(^[0-9]{4}?[0-9]$|^[0-9]{4}?[0-9]-[0-9]{4}$)',
  );

  @override
  bool validate(data) => _regExp.hasMatch(data.toString());
}

class FormRulePostcodeUk extends FormRule {
  FormRulePostcodeUk({super.rule = "postcode_uk", String? message})
    : super(message: message ?? "nylo.validation.postcode_uk");

  /// Covers all UK postcode formats: A9 9AA, A9A 9AA, A99 9AA, AA9 9AA,
  /// AA9A 9AA, AA99 9AA.
  static final RegExp _regExp = RegExp(
    r'^([A-Za-z]{1,2}\d[A-Za-z\d]?)\s*(\d[A-Za-z]{2})$',
  );

  @override
  bool validate(data) => _regExp.hasMatch(data.toString());
}
