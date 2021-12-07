import 'package:nylo_support/alerts/toast_enums.dart';
import 'package:nylo_support/alerts/toast_notification.dart';
import 'package:validated/validated.dart' as validate;

/// BASE ValidationRule class
/// Define the required details in the constructor to extend and build your own
/// validation rule.
class ValidationRule {
  String signature;
  String attribute;
  String title;
  String description;

  ValidationRule(
      {required this.signature,
      this.attribute = "",
      this.title = "Invalid data",
      this.description = ""});

  /// Handle the validation, the [info] variable will contain the following:
  /// info['rule'] = Validation rule i.e "min".
  /// info['data'] = Data the user has passed into the validation.
  /// info['message'] = Overriding message to be displayed for validation (optional).
  bool handle(Map<String, dynamic> info) {
    if (info.containsKey("message")) {
      String message = info['message'];
      title = message.split("|").first;
      description = message.split("|").last;
    }
    return true;
  }

  /// The alert which will be displayed.
  alert(context,
      {ToastNotificationStyleType style = ToastNotificationStyleType.WARNING,
      Duration? duration}) {
    showToastNotification(context,
        style: style,
        title: title,
        description: description,
        duration: duration);
  }
}

/// EMAIL RULE
class EmailRule extends ValidationRule {
  EmailRule(String attribute)
      : super(
            attribute: attribute,
            signature: "email",
            description: "The $attribute field is not a valid");

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
            description: "The $attribute field is not a valid");

  @override
  bool handle(Map<String, dynamic> info) {
    super.handle(info);
    return validate.isBoolean(info['data']);
  }
}

/// CONTAINS RULE
class ContainsRule extends ValidationRule {
  ContainsRule(String attribute)
      : super(
            signature: "contains",
            description: "The $attribute field is not a valid");

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
            signature: "url", description: "The $attribute is not a valid URL");

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
            description: "The $attribute is not a valid URL");

  @override
  bool handle(Map<String, dynamic> info) {
    super.handle(info);
    return validate.isSameType("String", info['data']);
  }
}

/// MAX RULE
class MaxRule extends ValidationRule {
  MaxRule(String attribute)
      : super(attribute: attribute, signature: "max", description: "");

  @override
  bool handle(Map<String, dynamic> info) {
    RegExp regExp = RegExp("max:([0-9]+)");
    String match = regExp.firstMatch(info['rule'])!.group(1) ?? "";
    int intMatch = int.parse(match);
    this.description =
        "The $attribute must have a maximum length of $intMatch characters.";
    super.handle(info);

    return (info['data'].toString().length < intMatch);
  }
}

/// MIN RULE
class MinRule extends ValidationRule {
  MinRule(String attribute)
      : super(attribute: attribute, signature: "min", description: "");

  @override
  bool handle(Map<String, dynamic> info) {
    RegExp regExp = RegExp("min:([0-9]+)");
    String match = regExp.firstMatch(info['rule'])!.group(1) ?? "";
    int intMatch = int.parse(match);
    this.description =
        "The $attribute must have a minimum length of $intMatch characters.";
    super.handle(info);
    return (info['data'].toString().length > intMatch);
  }
}
