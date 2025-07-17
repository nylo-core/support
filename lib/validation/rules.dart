import 'package:flutter/material.dart';
import '/helpers/ny_logger.dart';
import '/alerts/toast_enums.dart';
import '/alerts/toast_notification.dart';
import '/helpers/extensions.dart';
import 'package:validated/validated.dart' as validate;

/// BASE ValidationRule class
/// Define the required details in the constructor to extend and build your own
/// validation rule.
class ValidationRule {
  String signature;
  String attribute;
  String title;
  String description;
  String? textFieldMessage;
  Map<String, dynamic> info;

  ValidationRule(
      {required this.signature,
      this.attribute = "",
      this.title = "Invalid data",
      this.description = "",
      this.textFieldMessage,
      this.info = const {}});

  /// Handle the validation, the [info] variable will contain the following:
  /// info['rule'] = Validation rule i.e "min".
  /// info['data'] = Data the user has passed into the validation.
  /// info['message'] = Overriding message to be displayed for validation (optional).
  bool handle(Map<String, dynamic> info) {
    if (info.containsKey("message")) {
      String message = info['message'];
      if (message.contains("|")) {
        title = message.split("|").first;
        description = message.split("|").last;
        textFieldMessage = message.split("|").last;
      } else {
        title = "Invalid data";
        description = message;
        textFieldMessage = message;
      }
    }
    return true;
  }

  /// The alert which will be displayed.
  void alert(BuildContext context,
      {ToastNotificationStyleType style = ToastNotificationStyleType.warning,
      Duration? duration,
      Map<String, dynamic>? info}) {
    showToastNotification(
      context,
      style: style,
      title: title,
      description: description,
      duration: duration,
    );
  }
}

/// EMAIL RULE
class EmailRule extends ValidationRule {
  EmailRule(String attribute)
      : super(
            attribute: attribute,
            signature: "email",
            description: "The $attribute field is not a valid email",
            textFieldMessage: "Enter a valid email");

  @override
  handle(Map<String, dynamic> info) {
    super.handle(info);
    if (info['data'] == null) {
      return false;
    }
    return validate.isEmail(info['data'].toLowerCase());
  }
}

/// BOOLEAN RULE
class BooleanRule extends ValidationRule {
  BooleanRule(String attribute)
      : super(
            signature: "boolean",
            description: "The $attribute field is not a valid",
            textFieldMessage: "This value is not valid");

  @override
  bool handle(Map<String, dynamic> info) {
    super.handle(info);
    return validate.isBoolean(info['data']);
  }
}

/// IS_TRUE RULE
class IsTrueRule extends ValidationRule {
  IsTrueRule(String attribute)
      : super(
            signature: "is_true",
            description: "The $attribute field must be selected",
            textFieldMessage: "This value must be selected");

  @override
  bool handle(Map<String, dynamic> info) {
    super.handle(info);
    return info['data'].toString() == "true";
  }
}

/// IS_FALSE RULE
class IsFalseRule extends ValidationRule {
  IsFalseRule(String attribute)
      : super(
            signature: "is_false",
            description: "The $attribute field can't be selected",
            textFieldMessage: "This value can't be selected");

  @override
  bool handle(Map<String, dynamic> info) {
    super.handle(info);
    return info['data'].toString() == "false";
  }
}

/// IS_TYPE RULE
class IsTypeRule extends ValidationRule {
  IsTypeRule(String attribute)
      : super(
            signature: "is_type",
            description: "The $attribute field can't be selected",
            textFieldMessage: "This value can't be selected");

  @override
  bool handle(Map<String, dynamic> info) {
    super.handle(info);
    RegExp regExp = RegExp(r'is_type:([A-z0-9, ]+)');
    String match = regExp.firstMatch(info['rule'])!.group(1) ?? "";

    return info['data'].runtimeType.toString() == match;
  }
}

/// NOT EMPTY RULE
class NotEmptyRule extends ValidationRule {
  NotEmptyRule(String attribute)
      : super(
            signature: "not_empty",
            description: "The $attribute field cannot be empty",
            textFieldMessage: "Can't be empty");

  @override
  bool handle(Map<String, dynamic> info) {
    super.handle(info);
    dynamic data = info['data'];
    if (data == null) {
      return false;
    }
    if (data is List) {
      return data.isNotEmpty;
    }
    if (data is Map) {
      return data.isNotEmpty;
    }
    return (data.toString() != "");
  }
}

/// CONTAINS RULE
class ContainsRule extends ValidationRule {
  ContainsRule(String attribute)
      : super(
            signature: "contains",
            description: "The $attribute field is not a valid",
            textFieldMessage: "This value is not valid");

  @override
  bool handle(Map<String, dynamic> info) {
    super.handle(info);
    if (info['data'] == null) {
      return false;
    }
    RegExp regExp = RegExp(signature + r':([A-z0-9, ]+)');
    String match = regExp.firstMatch(info['rule'])!.group(1) ?? "";
    List<String> listMatches = match.split(",");

    return listMatches
        .any((element) => validate.contains(info['data'], element));
  }
}

/// URL RULE
class URLRule extends ValidationRule {
  URLRule(String attribute)
      : super(
            signature: "url",
            description: "The $attribute is not a valid URL",
            textFieldMessage: "Enter a valid URL");

  @override
  bool handle(Map<String, dynamic> info) {
    super.handle(info);
    if (info['data'] == null) {
      return false;
    }
    return validate.isURL(info['data']);
  }
}

/// STRING RULE
class StringRule extends ValidationRule {
  StringRule(String attribute)
      : super(
            signature: "string",
            description: "The $attribute is not valid",
            textFieldMessage: "This value is not valid");

  @override
  bool handle(Map<String, dynamic> info) {
    super.handle(info);
    return validate.isSameType("String", info['data']);
  }
}

/// LOWERCASE RULE
class UpperCaseRule extends ValidationRule {
  UpperCaseRule(String attribute)
      : super(
            signature: "uppercase",
            description: "The $attribute field is not uppercase",
            textFieldMessage: "Must be uppercase");

  @override
  bool handle(Map<String, dynamic> info) {
    super.handle(info);
    String data = info['data'];
    return data == data.toUpperCase();
  }
}

/// LOWERCASE RULE
class LowerCaseRule extends ValidationRule {
  LowerCaseRule(String attribute)
      : super(
            signature: "lowercase",
            description: "The $attribute field is not lowercase",
            textFieldMessage: "Must be lowercase");

  @override
  bool handle(Map<String, dynamic> info) {
    super.handle(info);
    return validate.isLowercase(info['data']);
  }
}

/// CAPITALIZED RULE
class CapitalizedRule extends ValidationRule {
  CapitalizedRule(String attribute)
      : super(
            signature: "capitalized",
            description: "The $attribute field is not capitalized",
            textFieldMessage: "Must be capitalized");

  @override
  bool handle(Map<String, dynamic> info) {
    super.handle(info);
    return validate.isCapitalized(info['data']);
  }
}

/// REGEX RULE
class DateRule extends ValidationRule {
  DateRule(String attribute)
      : super(
            signature: "date",
            description: "The $attribute field is not a valid date",
            textFieldMessage: "Must be a valid date");

  @override
  bool handle(Map<String, dynamic> info) {
    super.handle(info);
    return DateTime.tryParse(info['data']) != null;
  }
}

/// NUMERIC RULE
class NumericRule extends ValidationRule {
  NumericRule(String attribute)
      : super(
            signature: "numeric",
            description: "The $attribute field is not numeric",
            textFieldMessage: "Must be a numeric");

  @override
  bool handle(Map<String, dynamic> info) {
    super.handle(info);
    return RegExp(r'^-?[0-9]\d*(\.\d+)?$').hasMatch(info['data']);
  }
}

/// DATE AGE IS YOUNGER RULE
class DateAgeIsYoungerRule extends ValidationRule {
  DateAgeIsYoungerRule(String attribute)
      : super(signature: "date_age_is_younger", attribute: attribute);

  @override
  bool handle(Map<String, dynamic> info) {
    RegExp regExp = RegExp(signature + r':([0-9]+)');
    String match = regExp.firstMatch(info['rule'])?.group(1) ?? "";
    int intMatch = int.parse(match);
    info.dump();
    description = "The $attribute must be younger than $intMatch years old.";
    textFieldMessage = "Must be younger than $intMatch years old.";
    super.handle(info);
    dynamic date = info['data'];
    if (date is String) {
      DateTime? dateParsed = DateTime.tryParse(date);
      if (dateParsed == null) {
        NyLogger.error('Date is not valid');
        return false;
      }
      return dateParsed.isAgeYounger(intMatch) ?? false;
    }
    if (date is DateTime) {
      return date.isAgeYounger(intMatch) ?? false;
    }
    return false;
  }
}

/// DATE AGE IS OLDER RULE
class DateAgeIsOlderRule extends ValidationRule {
  DateAgeIsOlderRule(String attribute)
      : super(signature: "date_age_is_older", attribute: attribute);

  @override
  bool handle(Map<String, dynamic> info) {
    RegExp regExp = RegExp(signature + r':([0-9]+)');
    String match = regExp.firstMatch(info['rule'])?.group(1) ?? "";
    int intMatch = int.parse(match);

    description = "The $attribute must be older than $intMatch years old.";
    textFieldMessage = "Must be older than $intMatch years old.";
    super.handle(info);
    dynamic date = info['data'];
    if (date is String) {
      DateTime? dateParsed = DateTime.tryParse(date);
      if (dateParsed == null) {
        NyLogger.error('Date is not valid');
        return false;
      }
      return dateParsed.isAgeOlder(intMatch) ?? false;
    }
    if (date is DateTime) {
      return date.isAgeOlder(intMatch) ?? false;
    }
    return false;
  }
}

/// REGEX RULE
class RegexRule extends ValidationRule {
  RegexRule(String attribute)
      : super(
            signature: "regex",
            description: "The $attribute field is not valid",
            textFieldMessage: "This value is not valid");

  @override
  bool handle(Map<String, dynamic> info) {
    super.handle(info);
    RegExp regExp = RegExp(r'regex:(.+)');
    String match = regExp.firstMatch(info['rule'])!.group(1) ?? "";

    final check = RegExp(match);
    return check.hasMatch(info['data']);
  }
}

/// DATE IN FUTURE RULE
class DateInFutureRule extends ValidationRule {
  DateInFutureRule(String attribute)
      : super(
            signature: "date_in_future",
            description: "The $attribute field must be in the future",
            textFieldMessage: "Must be in the future");

  @override
  bool handle(Map<String, dynamic> info) {
    super.handle(info);
    dynamic date = info['data'];

    if (date is String) {
      DateTime? dateParsed = DateTime.tryParse(date);
      if (dateParsed == null) {
        return false;
      }
      return dateParsed.isInFuture();
    }

    if (date is DateTime) {
      return date.isInFuture();
    }
    return false;
  }
}

/// DATE IN PAST RULE
class DateInPastRule extends ValidationRule {
  DateInPastRule(String attribute)
      : super(
            signature: "date_in_past",
            description: "The $attribute field must be in the past",
            textFieldMessage: "Must not be in the future");

  @override
  bool handle(Map<String, dynamic> info) {
    super.handle(info);
    dynamic date = info['data'];

    if (date is String) {
      DateTime? dateParsed = DateTime.tryParse(date);
      if (dateParsed == null) {
        return false;
      }
      return dateParsed.isInPast();
    }

    if (date is DateTime) {
      return date.isInPast();
    }
    return false;
  }
}

/// MAX RULE
class MaxRule extends ValidationRule {
  MaxRule(String attribute) : super(attribute: attribute, signature: "max");

  @override
  bool handle(Map<String, dynamic> info) {
    RegExp regExp = RegExp(signature + r':([0-9]+)');
    String match = regExp.firstMatch(info['rule'])?.group(1) ?? "";
    int intMatch = int.parse(match);

    dynamic data = info['data'];
    if (data is String) {
      description =
          "$attribute must be a maximum length of $intMatch characters.";
      textFieldMessage = "Must be a maximum of $intMatch characters.";
      super.handle(info);
      return (data.length <= intMatch);
    }

    if (data is int) {
      description = "$attribute must be a maximum of $intMatch.";
      textFieldMessage = "Must be a maximum of $intMatch.";
      super.handle(info);
      return (data <= intMatch);
    }

    if (data is List) {
      description = "$attribute must be a maximum of $intMatch.";
      textFieldMessage = "Must be a maximum of $intMatch.";
      super.handle(info);
      return (data.length <= intMatch);
    }

    if (data is Map) {
      description = "$attribute must be a maximum of $intMatch.";
      textFieldMessage = "Must be a maximum of $intMatch.";
      super.handle(info);
      return (data.length <= intMatch);
    }

    if (data is double) {
      description = "$attribute must be a maximum of $intMatch.";
      textFieldMessage = "Must be a maximum of $intMatch.";
      super.handle(info);
      return (data <= intMatch);
    }

    return false;
  }
}

/// MIN RULE
class MinRule extends ValidationRule {
  MinRule(String attribute)
      : super(
            attribute: attribute,
            signature: "min",
            description: "",
            textFieldMessage: "");

  @override
  bool handle(Map<String, dynamic> info) {
    RegExp regExp = RegExp(signature + r':([0-9]+)');
    String match = regExp.firstMatch(info['rule'])?.group(1) ?? "";
    int intMatch = int.parse(match);
    description =
        "The $attribute must have a minimum length of $intMatch characters.";
    textFieldMessage = "Must be a minimum of $intMatch characters.";
    super.handle(info);

    dynamic data = info['data'];
    if (data is String) {
      description =
          "$attribute must be a minimum length of $intMatch characters.";
      textFieldMessage = "Must be a minimum of $intMatch characters.";
      super.handle(info);
      return (data.length >= intMatch);
    }

    if (data is int) {
      description = "$attribute must be a minimum of $intMatch.";
      textFieldMessage = "Must be a minimum of $intMatch.";
      super.handle(info);
      return (data >= intMatch);
    }

    if (data is List) {
      description = "$attribute must be a minimum of $intMatch.";
      textFieldMessage = "Must be a minimum of $intMatch.";
      super.handle(info);
      return (data.length >= intMatch);
    }

    if (data is Map) {
      description = "$attribute must be a minimum of $intMatch.";
      textFieldMessage = "Must be a minimum of $intMatch.";
      super.handle(info);
      return (data.length >= intMatch);
    }

    if (data is double) {
      description = "$attribute must be a minimum of $intMatch.";
      textFieldMessage = "Must be a minimum of $intMatch.";
      super.handle(info);
      return (data >= intMatch);
    }
    return false;
  }
}

/// UK NUMBER RULE
class PhoneNumberUkRule extends ValidationRule {
  PhoneNumberUkRule(String attribute)
      : super(
            attribute: attribute,
            signature: "phone_number_uk",
            description: "The $attribute field is not a valid phone number",
            textFieldMessage: "Enter a valid UK phone number");

  @override
  bool handle(Map<String, dynamic> info) {
    RegExp regExp = RegExp(
        r'^(((\+44\s?\d{4}|\(?0\d{4}\)?)\s?\d{3}\s?\d{3})|((\+44\s?\d{3}|\(?0\d{3}\)?)\s?\d{3}\s?\d{4})|((\+44\s?\d{2}|\(?0\d{2}\)?)\s?\d{4}\s?\d{4}))(\s?\#(\d{4}|\d{3}))?$');
    super.handle(info);
    return regExp.hasMatch(info['data'].toString());
  }
}

/// US NUMBER RULE
class PhoneNumberUsRule extends ValidationRule {
  PhoneNumberUsRule(String attribute)
      : super(
            attribute: attribute,
            signature: "phone_number_us",
            description: "The $attribute field is not a valid phone number",
            textFieldMessage: "Enter a valid US phone number");

  @override
  bool handle(Map<String, dynamic> info) {
    RegExp regExp =
        RegExp(r'^\(?(\d{3})\)?[-\. ]?(\d{3})[-\. ]?(\d{4})( x\d{4})?$');
    super.handle(info);
    return regExp.hasMatch(info['data'].toString());
  }
}

/// POSTCODE UK RULE
class PostCodeUkRule extends ValidationRule {
  PostCodeUkRule(String attribute)
      : super(
            attribute: attribute,
            signature: "postcode_uk",
            description: "The $attribute field is not a valid post code",
            textFieldMessage: "Enter a valid post code");

  @override
  bool handle(Map<String, dynamic> info) {
    RegExp regExp = RegExp(r'^([a-zA-Z]{1,2}\d{1,2})\s*?(\d[a-zA-Z]{2})$');
    super.handle(info);
    return regExp.hasMatch(info['data'].toString());
  }
}

/// PasswordV1 RULE
/// This rule is used to validate a password with the following requirements:
/// - At least one uppercase letter
/// - At least one digit
/// - Minimum of 8 characters
class PasswordV1Rule extends ValidationRule {
  PasswordV1Rule(String attribute)
      : super(
            attribute: attribute,
            signature: "password_v1",
            description: "The $attribute field is not a valid password",
            textFieldMessage: "1 uppercased letter, 1 digit, 8 characters");

  @override
  bool handle(Map<String, dynamic> info) {
    RegExp regExp = RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$');
    super.handle(info);
    return regExp.hasMatch(info['data'].toString());
  }
}

/// PasswordV2 RULE
/// This rule is used to validate a password with the following requirements:
/// - At least one uppercase letter
/// - At least one digit
/// - Minimum of 8 characters
/// - At least one special character
class PasswordV2Rule extends ValidationRule {
  PasswordV2Rule(String attribute)
      : super(
            attribute: attribute,
            signature: "password_v2",
            description: "The $attribute field is not a valid password",
            textFieldMessage:
                "1 uppercased letter, 1 digit, 1 special character, 8 characters");

  @override
  bool handle(Map<String, dynamic> info) {
    RegExp regExp =
        RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$');
    super.handle(info);
    return regExp.hasMatch(info['data'].toString());
  }
}

/// ZIPCODE US RULE
class ZipCodeUsRule extends ValidationRule {
  ZipCodeUsRule(String attribute)
      : super(
            attribute: attribute,
            signature: "zipcode_us",
            description: "The $attribute field is not a valid zip code",
            textFieldMessage: "Enter a valid zip code");

  @override
  bool handle(Map<String, dynamic> info) {
    RegExp regExp = RegExp(r'(^[0-9]{4}?[0-9]$|^[0-9]{4}?[0-9]-[0-9]{4}$)');
    super.handle(info);
    return regExp.hasMatch(info['data'].toString());
  }
}
