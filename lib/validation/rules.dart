import 'package:nylo_support/alerts/toast_enums.dart';
import 'package:nylo_support/alerts/toast_notification.dart';
import 'package:nylo_support/localization/app_localization.dart';
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
      assert(message.contains("|"),
          'The message is not formatted correctly. Create your validation message using the following format: "Oops|Something went wrong". The first section before the "|" will be used as the title, the second section will be the description.');
      title = message.split("|").first;
      description = message.split("|").last;
      textFieldMessage = message.split("|").last;
    }
    return true;
  }

  /// The alert which will be displayed.
  alert(context,
      {ToastNotificationStyleType style = ToastNotificationStyleType.WARNING,
      Duration? duration}) {
    showToastNotification(context,
        style: style,
        title: title.tr(),
        description: description.tr(),
        duration: duration);
  }
}

/// EMAIL RULE
class EmailRule extends ValidationRule {
  EmailRule(String attribute)
      : super(
            attribute: attribute,
            signature: "email",
            description: "The $attribute field is not a valid email",
            textFieldMessage: "Provide a valid email");

  @override
  handle(Map<String, dynamic> info) {
    super.handle(info);
    return validate.isEmail(info['data']);
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
    return info['data'] != "";
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
    RegExp regExp = RegExp("contains:([A-z0-9, ]+)");
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
            textFieldMessage: "Must be a valid URL");

  @override
  bool handle(Map<String, dynamic> info) {
    super.handle(info);
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
    return validate.isUpperCase(info['data']);
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
    RegExp _numeric = RegExp(r'^-?[0-9]+$');
    return _numeric.hasMatch(info['data']);
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
    RegExp regExp = RegExp(r"regex:(.+)");
    String match = regExp.firstMatch(info['rule'])!.group(1) ?? "";

    final check = RegExp(match);
    return check.hasMatch(info['data']);
  }
}

/// MAX RULE
class MaxRule extends ValidationRule {
  MaxRule(String attribute)
      : super(
            attribute: attribute,
            signature: "max",
            description: "",
            textFieldMessage: "");

  @override
  bool handle(Map<String, dynamic> info) {
    RegExp regExp = RegExp("max:([0-9]+)");
    String match = regExp.firstMatch(info['rule'])?.group(1) ?? "";
    int intMatch = int.parse(match);
    this.description =
        "The $attribute must have a maximum length of $intMatch characters.";
    this.textFieldMessage = "Must be a maximum of $intMatch characters.";
    super.handle(info);

    return (info['data'].toString().length < intMatch);
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
    RegExp regExp = RegExp("min:([0-9]+)");
    String match = regExp.firstMatch(info['rule'])?.group(1) ?? "";
    int intMatch = int.parse(match);
    this.description =
        "The $attribute must have a minimum length of $intMatch characters.";
    this.textFieldMessage = "Must be a minimum of $intMatch characters.";
    super.handle(info);
    return (info['data'].toString().length > intMatch);
  }
}

/// UK NUMBER RULE
class PhoneNumberUkRule extends ValidationRule {
  PhoneNumberUkRule(String attribute)
      : super(
            attribute: attribute,
            signature: "phone_number_uk",
            description: "The $attribute field is not a valid phone number",
            textFieldMessage: "This value must be a valid phone number");

  @override
  bool handle(Map<String, dynamic> info) {
    RegExp regExp = RegExp(
        r'^(((\+44\s?\d{4}|\(?0\d{4}\)?)\s?\d{3}\s?\d{3})|((\+44\s?\d{3}|\(?0\d{3}\)?)\s?\d{3}\s?\d{4})|((\+44\s?\d{2}|\(?0\d{2}\)?)\s?\d{4}\s?\d{4}))(\s?\#(\d{4}|\d{3}))?$');
    super.handle(info);
    return regExp.hasMatch(info['data'].toString());
  }
}

/// USA NUMBER RULE
class PhoneNumberUsaRule extends ValidationRule {
  PhoneNumberUsaRule(String attribute)
      : super(
            attribute: attribute,
            signature: "phone_number_us",
            description: "The $attribute field is not a valid phone number",
            textFieldMessage: "This value must be a valid phone number");

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
            textFieldMessage: "This value must be a valid post code");

  @override
  bool handle(Map<String, dynamic> info) {
    RegExp regExp = RegExp(r'^([a-zA-Z]{1,2}\d{1,2})\s*?(\d[a-zA-Z]{2})$');
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
            textFieldMessage: "This value must be a valid zip code");

  @override
  bool handle(Map<String, dynamic> info) {
    RegExp regExp = RegExp(r'(^[0-9]{4}?[0-9]$|^[0-9]{4}?[0-9]-[0-9]{4}$)');
    super.handle(info);
    return regExp.hasMatch(info['data'].toString());
  }
}
