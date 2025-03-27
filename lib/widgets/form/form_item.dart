import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '/widgets/fields/form_radio.dart';
import '/widgets/fields/form_switch_box.dart';

import '/helpers/currency_input_matcher.dart';
import '/helpers/helper.dart';
import '/nylo.dart';
import '/widgets/fields/form_checkbox.dart';
import '/widgets/fields/form_chips.dart';
import '/widgets/fields/form_date_time_picker.dart';
import '/widgets/fields/form_picker.dart';
import '/widgets/ny_form.dart';
import '/widgets/ny_text_field.dart';

/// NyFormItem is a class that helps in managing form items
class NyFormItem extends StatelessWidget {
  NyFormItem(
      {super.key,
      required this.field,
      this.validationRules,
      this.validationMessage,
      this.dummyData,
      this.validateOnFocusChange = false,
      this.onChanged,
      this.fieldStyle,
      this.formStyle,
      this.customValidationRule,
      this.style,
      this.updated,
      this.autoFocusField});

  final Field field;
  final String? validationRules;
  final String? validationMessage;
  final bool Function(dynamic value)? customValidationRule;
  final String? dummyData;
  final String? fieldStyle;
  final NyFormStyle? formStyle;
  final String? autoFocusField;
  final TextEditingController controller = TextEditingController();
  final Function(dynamic value)? onChanged;
  final NyTextField Function(NyTextField nyTextField)? style;
  final bool validateOnFocusChange;
  final StreamController? updated;

  /// Returns the textEditingController for the form item
  TextEditingController get textEditingController {
    if (field.value is List) {
      controller.text = field.value.join(", ");
      return controller;
    }
    controller.text = field.value ?? "";
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    String fieldKey = field.key;
    // ignore: prefer_function_declarations_over_variables
    Function(dynamic value)? onChanged = (dynamic value) {
      if (!(updated?.isClosed ?? true)) {
        updated?.add((fieldKey, value));
      }
      this.onChanged!(value);
    };

    if (!([
      "datetime",
      "text",
      "url",
      "email",
      "checkbox",
      "mask",
      "password",
      "password:viewable",
      "textarea",
      "textarea:sm",
      "textarea:md",
      "textarea:lg",
      "number",
      "number:decimal",
      "phone_number",
      ...[
        for (String currency in CurrencyInputMatcher.currencies)
          "currency:$currency"
      ],
      "capitalize-words",
      "capitalize-sentences",
      "uppercase",
      "lowercase",
    ].contains(field.cast.type))) {
      // check if field exists on Nylo instance
      Map<String, dynamic> nyloFormTypes = Nylo.instance.getFormCasts();
      if (nyloFormTypes.containsKey(field.cast.type)) {
        return nyloFormTypes[field.cast.type]!(field, onChanged);
      }
    }

    // check if the field is a datetime field
    if (field.cast.type == "datetime") {
      return IgnorePointer(
        ignoring: field.readOnly ?? false,
        child: NyFormDateTimePicker.fromField(
          field,
          onChanged,
        ),
      );
    }

    // check if the field is a picker field
    if (field.cast.type == "picker") {
      return IgnorePointer(
        ignoring: field.readOnly ?? false,
        child: NyFormPicker.fromField(
          field,
          onChanged,
        ),
      );
    }

    // check if the field is a picker field
    if (field.cast.type == "radio") {
      return IgnorePointer(
        ignoring: field.readOnly ?? false,
        child: NyFormRadio.fromField(
          field,
          onChanged,
        ),
      );
    }

    // check if the field is a widget field
    if (field.cast.type == "widget") {
      return IgnorePointer(
          ignoring: field.readOnly ?? false,
          child: field.cast.metaData!['child'] as Widget);
    }

    // check if the field is a chip field
    if (field.cast.type == "chip") {
      late Widget chipWidget;
      if (fieldStyle == "compact") {
        chipWidget = NyFormChip.compact(
          field,
          onChanged,
        );
      } else {
        chipWidget = NyFormChip.fromField(
          field,
          onChanged,
        );
      }

      return IgnorePointer(
        ignoring: field.readOnly ?? false,
        child: chipWidget,
      );
    }

    // check if the field is a checkbox field
    if (field.cast.type == "checkbox") {
      FormStyleCheckbox? checkboxStyles = formStyle?.checkbox(context, field);
      if ((checkboxStyles ?? {}).containsKey('default')) {
        FormCast formCast = checkboxStyles!['default']!();
        formCast.metaData.forEach((key, value) {
          if (key == 'title' && field.cast.metaData[key] is Text) {
            Text? title = field.cast.metaData[key];
            if (title?.data == null) {
              formCast.metaData[key] = Text(field.name);
            } else {
              formCast.metaData[key] = title;
            }
          } else {
            field.cast.metaData[key] = value;
          }
        });
        field.cast = formCast;
      } else if ((checkboxStyles ?? {}).containsKey(fieldStyle)) {
        FormCast formCast = checkboxStyles![fieldStyle]!();
        formCast.metaData
            .forEach((key, value) => field.cast.metaData[key] = value);
        field.cast = formCast;
      }

      return IgnorePointer(
        ignoring: field.readOnly ?? false,
        child: NyFormCheckbox.fromField(
          field,
          onChanged,
        ),
      );
    }

    // check if the field is a checkbox field
    if (field.cast.type == "switchBox") {
      FormStyleSwitchBox? styles = formStyle?.switchBox(context, field);
      if ((styles ?? {}).containsKey('default')) {
        FormCast formCast = styles!['default']!();
        formCast.metaData.forEach((key, value) {
          if (key == 'title' && field.cast.metaData[key] is Text) {
            Text? title = field.cast.metaData[key];
            if (title?.data == null) {
              formCast.metaData[key] = Text(field.name);
            } else {
              formCast.metaData[key] = title;
            }
          } else {
            field.cast.metaData[key] = value;
          }
        });
        field.cast = formCast;
      } else if ((styles ?? {}).containsKey(fieldStyle)) {
        FormCast formCast = styles![fieldStyle]!();
        formCast.metaData
            .forEach((key, value) => field.cast.metaData[key] = value);
        field.cast = formCast;
      }
      return IgnorePointer(
        ignoring: field.readOnly ?? false,
        child: NyFormSwitchBox.fromField(
          field,
          onChanged,
        ),
      );
    }

    FormStyleTextField? textFieldStyles = formStyle?.textField(context, field);

    TextCapitalization textCapitalization = TextCapitalization.none;
    switch (field.cast.type) {
      case "capitalize-words":
        textCapitalization = TextCapitalization.words;
        break;
      case "capitalize-sentences":
        textCapitalization = TextCapitalization.sentences;
        break;
      case "uppercase":
        textCapitalization = TextCapitalization.characters;
        break;
      case "lowercase":
        textCapitalization = TextCapitalization.none;
        break;
      default:
        textCapitalization = TextCapitalization.none;
        break;
    }

    NyTextField nyTextField;
    switch (fieldStyle) {
      case "compact":
        nyTextField = NyTextField.compact(
          readOnly: field.readOnly ?? false,
          controller: textEditingController,
          hintText: field.name,
          textCapitalization: textCapitalization,
          onChanged:
              ((field.cast.type ?? "").contains("currency")) ? null : onChanged,
          autoFocus: field.autofocus,
          validationRules: validationRules,
          customValidationRule: customValidationRule,
          validationErrorMessage: validationMessage,
          validateOnFocusChange: validateOnFocusChange,
          dummyData: dummyData,
          header: field.header,
          footer: field.footer,
          clearable: field.cast.getMetaData("clearable") ?? false,
          clearIcon:
              field.cast.getMetaData("clearIcon") ?? const Icon(Icons.close),
          prefixIcon: field.cast.getMetaData("prefixIcon"),
        );

        break;
      default:
        {
          nyTextField = NyTextField(
            readOnly: field.readOnly ?? false,
            controller: textEditingController,
            hintText: field.name,
            textCapitalization: textCapitalization,
            onChanged: ((field.cast.type ?? "").contains("currency"))
                ? null
                : onChanged,
            autoFocus: field.autofocus,
            validationRules: validationRules,
            validationErrorMessage: validationMessage,
            customValidationRule: customValidationRule,
            validateOnFocusChange: validateOnFocusChange,
            dummyData: dummyData,
            header: field.header,
            footer: field.footer,
            clearable: field.cast.getMetaData("clearable") ?? false,
            clearIcon:
                field.cast.getMetaData("clearIcon") ?? const Icon(Icons.close),
            prefixIcon: field.cast.getMetaData("prefixIcon"),
          );

          if ((textFieldStyles ?? {}).containsKey('default')) {
            nyTextField = textFieldStyles!['default']!(nyTextField);
          }
        }
    }

    if (fieldStyle != null && (textFieldStyles ?? {}).containsKey(fieldStyle)) {
      nyTextField = textFieldStyles![fieldStyle]!(nyTextField);
    }

    // check if the field has a style
    if (style != null &&
        (field.metaData ?? {}).containsKey('decoration_style') == false) {
      return style!(nyTextField);
    }

    if ((field.metaData ?? {}).containsKey('decoration_style')) {
      nyTextField = field.metaData!['decoration_style']!(nyTextField);
    }

    // check if the field is a mask field
    if (field.cast.type == "mask") {
      nyTextField = nyTextField.copyWith(
          maskedReturnValue: field.cast.getMetaData("maskedReturnValue"),
          inputFormatters: [
            MaskTextInputFormatter(
              mask: field.cast.getMetaData("mask"),
              filter: {"#": RegExp(field.cast.getMetaData("match"))},
              type: MaskAutoCompletionType.lazy,
            )
          ]);
    }

    // check if the field is an email field
    if (field.cast.type == "email") {
      nyTextField = nyTextField.copyWith(
          type: "email-address", keyboardType: TextInputType.emailAddress);
    }

    // check if the field is a password field
    if ((field.cast.type ?? "").contains("password")) {
      nyTextField = nyTextField.copyWith(
        type: "password",
        obscureText: true,
        keyboardType: (field.cast.type ?? "").contains("viewable")
            ? TextInputType.visiblePassword
            : TextInputType.text,
        passwordViewable: (field.cast.type ?? "").contains("viewable"),
      );
    }

    // check if the field is a textarea field
    if ((field.cast.type ?? "").contains("textarea")) {
      nyTextField = nyTextField.copyWith(
        minLines: match(
            field.cast.type,
            () => {
                  "textarea": 1,
                  "textarea:sm": 2,
                  "textarea:md": 3,
                  "textarea:lg": 5
                },
            defaultValue: 1),
        maxLines: match(
            field.cast.type,
            () => {
                  "textarea": 3,
                  "textarea:sm": 4,
                  "textarea:md": 5,
                  "textarea:lg": 7
                },
            defaultValue: 3),
        keyboardType: TextInputType.multiline,
      );
    }

    // Update the nyTextField onChanged function
    nyTextField = nyTextField.copyWith(
      onChanged: (String? value) {
        if (field.cast.type == "capitalize-words") {
          value = value?.split(" ").map((String word) {
            if (word.isEmpty) return word;
            return word[0].toUpperCase() + word.substring(1);
          }).join(" ");
        }

        if (field.cast.type == "capitalize-sentences") {
          value = value?.split(".").map((String word) {
            if (word.isEmpty) return word;
            return word[0].toUpperCase() + word.substring(1);
          }).join(".");
        }

        if (field.cast.type == "uppercase") {
          value = value?.toUpperCase();
        }

        if (field.cast.type == "lowercase") {
          value = value?.toLowerCase();
        }

        if (!((field.cast.type ?? "").contains("currency"))) {
          onChanged(value);
        }
      },
    );

    // check if the field is a currency field
    if (field.cast.type?.contains("currency") ?? false) {
      CurrencyMeta currencyMeta = CurrencyInputMatcher.getCurrencyMeta(
          field.cast.type!,
          value: field.value ?? "0",
          onChanged: onChanged);
      textEditingController.text = currencyMeta.initialValue;
      nyTextField = nyTextField.copyWith(
        onChanged: null,
        type: fieldStyle,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          currencyMeta.formatter,
        ],
      );
    }

    // check if the field is a phone number field
    if (field.cast.type == "phone_number") {
      nyTextField = nyTextField.copyWith(
        keyboardType: TextInputType.phone,
        inputFormatters: [PhoneInputFormatter()],
        onChanged: onChanged,
      );
    }

    // check if the field is a number field
    if (field.cast.type == "url") {
      nyTextField = nyTextField.copyWith(
          type: fieldStyle, keyboardType: TextInputType.url);
    }

    // check if the field is a number field
    if (field.cast.type == "number") {
      nyTextField = nyTextField.copyWith(
          type: fieldStyle, keyboardType: TextInputType.number);
    }

    // check if the field is a number field
    if (field.cast.type == "number:decimal") {
      nyTextField = nyTextField.copyWith(
          type: fieldStyle,
          keyboardType: const TextInputType.numberWithOptions(decimal: true));
    }

    return nyTextField;
  }
}
