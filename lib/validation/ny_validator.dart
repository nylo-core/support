import 'package:flutter/cupertino.dart';
import 'package:nylo_support/helpers/backpack.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/validation/rules.dart';
import 'package:nylo_support/validation/validations.dart';

class NyValidator {
  /// This validator method provides an easy way to validate data.
  /// You can use this method like in the example below:
  /// try {
  ///   NyValidator.check(rules: {
  ///     "email": "email|max:20",
  ///     "name": "min:10"
  ///   }, data: {
  ///     "email": _textEditingEmailController.text,
  ///     "name": _textEditingNameController.text
  ///   });
  ///
  /// } on ValidationException catch (e) {
  ///   print(e.validationRule.description);
  ///   print(e.toString());
  /// }
  /// See more https://nylo.dev/docs/5.x/validation
  static check(
      {required Map<String, String> rules,
      required Map<String, dynamic> data,
      Map<String, dynamic> messages = const {},
      bool showAlert = true,
      Duration? alertDuration,
      ToastNotificationStyleType alertStyle =
          ToastNotificationStyleType.WARNING,
      BuildContext? context}) {
    Map<String, Map<String, dynamic>> map = data.map((key, value) {
      if (!rules.containsKey(key)) {
        throw new Exception('Missing rule: ' + key);
      }
      Map<String, dynamic> tmp = {"data": value, "rule": rules[key]};
      if (messages.containsKey(key)) {
        tmp.addAll({"message": messages[key]});
      }
      return MapEntry(key, tmp);
    });

    Nylo nylo = Backpack.instance.nylo();

    Map<Type, dynamic> allValidationRules = {};
    allValidationRules.addAll(nylo.getValidationRules());
    allValidationRules.addAll(nyDefaultValidations);

    List<ValidationRule?> validationRules = [];

    for (int i = 0; i < map.length; i++) {
      String attribute = map.keys.toList()[i];
      Map<String, dynamic> info = map[attribute]!;

      dynamic data = info['data'];

      String rule = info['rule'];
      List<String> rules = rule.split("|").toList();

      if (rule.contains("nullable") && (data == null || data == "")) {
        continue;
      }

      for (var validationRule in allValidationRules.entries) {
        validationRules.add(validationRule.value(attribute));
      }

      for (rule in rules) {
        ValidationRule? validationRule =
            validationRules.firstWhere((validationRule) {
          if (validationRule!.signature == rule) {
            return true;
          }
          if (rule.contains(":")) {
            String firstSection = rule.split(":").first;
            return validationRule.signature == firstSection;
          }
          return false;
        }, orElse: () => null);
        if (validationRule == null) {
          continue;
        }

        bool hasFailed = validationRule.handle(info);

        if (hasFailed == false) {
          if (showAlert == true && context != null) {
            validationRule.alert(context,
                style: alertStyle, duration: alertDuration);
          }
          throw new ValidationException(attribute, validationRule);
        }
      }
    }
  }
}
