import 'package:flutter/cupertino.dart';
import 'package:nylo_support/helpers/backpack.dart';
import 'package:nylo_support/helpers/helper.dart';
import 'package:nylo_support/metro/metro_service.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/validation/rules.dart';
import 'package:nylo_support/validation/validations.dart';

class NyValidator {
  /// NyValidator provides an easy way to validate data.
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

    Map<String, dynamic> allValidationRules = {};
    allValidationRules.addAll(nylo.getValidationRules());
    allValidationRules.addAll(nyDefaultValidations);

    for (int i = 0; i < map.length; i++) {
      String attribute = map.keys.toList()[i];
      Map<String, dynamic> info = map[attribute]!;

      dynamic data = info['data'];

      String rule = info['rule'];
      List<String> rules = rule.split("|").toList();

      if (rule.contains("nullable") && (data == null || data == "")) {
        continue;
      }

      for (rule in rules) {
        String ruleQuery = rule;
        if (ruleQuery.contains(":")) {
          String firstSection = ruleQuery.split(":").first;
          ruleQuery = firstSection;
        }

        MapEntry<String, dynamic>? validationRuleMapEntry =
            allValidationRules.entries.firstWhereOrNull(
                (nyDefaultValidation) => nyDefaultValidation.key == ruleQuery);
        if (validationRuleMapEntry == null) continue;

        ValidationRule? validationRule =
            validationRuleMapEntry.value(attribute);
        if (validationRule == null) continue;

        bool didNotFail = validationRule.handle(info);

        if (didNotFail == true) continue;

        if (showAlert == true && context != null) {
          validationRule.alert(
            context,
            style: alertStyle,
            duration: alertDuration,
          );
        }
        throw new ValidationException(attribute, validationRule);
      }
    }
  }

  /// Check if validation is successful.
  static bool isSuccessful({
    required Map<String, dynamic> rules,
    Map<String, dynamic>? data,
  }) {
    Map<String, String> finalRules = {};
    Map<String, dynamic> finalData = {};

    rules.forEach((key, value) {
      if (value is List) {
        assert(value.length < 3,
            'Validation rules can contain a maximum of 2 items. E.g. "email": [emailData, "add|validation|rules"]');
        finalRules[key] = value[1];
        finalData[key] = value[0];
      } else {
        finalRules[key] = value;
      }
    });

    if (data != null) {
      data.forEach((key, value) {
        finalData.addAll({key: value});
      });
    }

    try {
      check(
        rules: finalRules,
        data: finalData,
      );

      return true;
    } on Exception catch (exception) {
      return false;
    }
  }
}
