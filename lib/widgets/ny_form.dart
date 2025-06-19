import 'dart:math';

import 'package:date_field/date_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import '/localization/app_localization.dart';
import '/widgets/styles/bottom_modal_sheet_style.dart';
import '/widgets/styles/ny_radio_tile_style.dart';
import 'package:recase/recase.dart';

import '/widgets/form/validation.dart';
import '/widgets/ny_text_field.dart';
import 'form/casts.dart';

export 'form/casts.dart';
export 'form/form.dart';
export 'form/form_data.dart';
export 'form/validation.dart';

/// [FormSubmitCallback] is a typedef that helps in managing form submit callbacks
typedef FormSubmitCallback = (dynamic, Function(dynamic data))?;

/// FormStyleTextField is a typedef that helps in managing form style text fields
typedef FormStyleTextField = Map<String, NyTextField Function(NyTextField)>;

/// FormStyleCheckbox is a typedef that helps in managing form style checkboxes
typedef FormStyleCheckbox = Map<String, FormCast Function()>;

/// FormStyleSwitchBox is a typedef that helps in managing form style switch boxes
typedef FormStyleSwitchBox = Map<String, FormCast Function()>;

/// TextAreaSize is an enum that helps in managing textarea sizes
enum TextAreaSize { sm, md, lg }

/// NyFormStyle is a class that helps in managing form styles
class NyFormStyle {
  /// FormStyleTextField styles for the form
  FormStyleTextField textField(BuildContext context, Field field) => {};

  /// FormStyleCheckbox styles for the form
  FormStyleCheckbox checkbox(BuildContext context, Field field) => {};

  /// FormStyleSwitchBox styles for the form
  FormStyleSwitchBox switchBox(BuildContext context, Field field) => {};
}

/// DecoratorTextField is a class that helps in managing form text fields
class DecoratorTextField {
  final InputDecoration Function(dynamic data, InputDecoration inputDecoration)?
      decoration;
  final InputDecoration Function(dynamic data, InputDecoration inputDecoration)?
      successDecoration;
  final InputDecoration Function(dynamic data, InputDecoration inputDecoration)?
      errorDecoration;

  DecoratorTextField({
    this.decoration,
    this.successDecoration,
    this.errorDecoration,
  });
}

typedef FieldStyle = String;

extension NyFieldStyle on String {
  /// Extend the field style
  Map<String, NyTextField Function(NyTextField nyTextField)> extend({
    InputDecoration Function(dynamic data, InputDecoration inputDecoration)?
        decoration,
    InputDecoration Function(dynamic data, InputDecoration inputDecoration)?
        successDecoration,
    InputDecoration Function(dynamic data, InputDecoration inputDecoration)?
        errorDecoration,
    String? labelText,
    TextStyle? labelStyle,
    TextEditingController? controller,
    bool? obscureText,
    int? maxLines,
    int? minLines,
    TextInputType? keyboardType,
    bool? autoFocus,
    TextAlign? textAlign,
    bool? enableSuggestions,
    FocusNode? focusNode,
    String? hintText,
    TextStyle? hintStyle,
    String? validationRules,
    String? dummyData,
    Function(String value)? onChanged,
    TextInputAction? textInputAction,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextAlignVertical? textAlignVertical,
    TextDirection? textDirection,
    String? obscuringCharacter,
    bool? autocorrect,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    bool? expands,
    bool? readOnly,
    bool? showCursor,
    int? maxLength,
    bool? passwordViewable,
    bool? validateOnFocusChange,
    MouseCursor? mouseCursor,
    String? validationErrorMessage,
    TextCapitalization? textCapitalization,
    MaxLengthEnforcement? maxLengthEnforcement,
    AppPrivateCommandCallback? onAppPrivateCommand,
    List<TextInputFormatter>? inputFormatters,
    bool? enabled,
    double? cursorWidth,
    double? cursorHeight,
    Radius? cursorRadius,
    Color? cursorColor,
    Brightness? keyboardAppearance,
    EdgeInsets? scrollPadding,
    TextSelectionControls? selectionControls,
    DragStartBehavior? dragStartBehavior,
    GestureTapCallback? onTap,
    TapRegionCallback? onTapOutside,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onSubmitted,
    ScrollController? scrollController,
    ScrollPhysics? scrollPhysics,
    Iterable<String>? autofillHints,
    Clip? clipBehavior,
    Function(String handleError)? handleValidationError,
    bool? passwordVisible,
    String? type,
    Widget? prefixIcon,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    InputBorder? border,
    InputBorder? focusedBorder,
    InputBorder? enabledBorder,
    EdgeInsetsGeometry? contentPadding,
    bool Function(dynamic value)? customValidationRule,
    String? title,
    TextStyle? titleStyle,
    bool? clearable,
    Widget? clearIcon,
    String? mask,
    String? maskMatch,
    bool? maskedReturnValue,
  }) {
    return {
      this: (NyTextField textField) {
        return textField.copyWith(
          decorator: DecoratorTextField(
            decoration: (data, inputDecoration) {
              if (decoration == null) {
                if (textField.decorator?.decoration != null) {
                  return textField.decorator!.decoration!(
                      data, inputDecoration);
                }
                return const InputDecoration();
              }

              InputDecoration inputDecorationBase =
                  textField.decorator!.decoration!(data, inputDecoration);
              return decoration(data, inputDecorationBase);
            },
            successDecoration: (data, inputDecoration) {
              if (successDecoration == null) {
                if (textField.decorator?.successDecoration != null) {
                  return textField.decorator!.successDecoration!(
                      data, inputDecoration);
                }
                return const InputDecoration();
              }

              InputDecoration inputDecorationBase = textField
                  .decorator!.successDecoration!(data, inputDecoration);
              return successDecoration(data, inputDecorationBase);
            },
            errorDecoration: (data, inputDecoration) {
              if (errorDecoration == null) {
                if (textField.decorator?.errorDecoration != null) {
                  return textField.decorator!.errorDecoration!(
                      data, inputDecoration);
                }
                return const InputDecoration();
              }

              InputDecoration inputDecorationBase =
                  textField.decorator!.errorDecoration!(data, inputDecoration);
              return errorDecoration(data, inputDecorationBase);
            },
          ),
          labelText: labelText ?? textField.labelText,
          labelStyle: labelStyle ?? textField.labelStyle,
          controller: controller ?? textField.controller,
          obscureText: obscureText ?? textField.obscureText,
          maxLines: maxLines ?? textField.maxLines,
          minLines: minLines ?? textField.minLines,
          keyboardType: keyboardType ?? textField.keyboardType,
          autoFocus: autoFocus ?? textField.autoFocus,
          textAlign: textAlign ?? textField.textAlign,
          enableSuggestions: enableSuggestions ?? textField.enableSuggestions,
          focusNode: focusNode ?? textField.focusNode,
          hintText: hintText ?? textField.hintText,
          hintStyle: hintStyle ?? textField.hintStyle,
          validationRules: validationRules ?? textField.validationRules,
          dummyData: dummyData ?? textField.dummyData,
          onChanged: onChanged ?? textField.onChanged,
          textInputAction: textInputAction ?? textField.textInputAction,
          style: style ?? textField.style,
          strutStyle: strutStyle ?? textField.strutStyle,
          textAlignVertical: textAlignVertical ?? textField.textAlignVertical,
          textDirection: textDirection ?? textField.textDirection,
          obscuringCharacter:
              obscuringCharacter ?? textField.obscuringCharacter,
          autocorrect: autocorrect ?? textField.autocorrect,
          smartDashesType: smartDashesType ?? textField.smartDashesType,
          smartQuotesType: smartQuotesType ?? textField.smartQuotesType,
          expands: expands ?? textField.expands,
          readOnly: readOnly ?? textField.readOnly,
          showCursor: showCursor ?? textField.showCursor,
          maxLength: maxLength ?? textField.maxLength,
          passwordViewable: passwordViewable ?? textField.passwordViewable,
          validateOnFocusChange:
              validateOnFocusChange ?? textField.validateOnFocusChange,
          mouseCursor: mouseCursor ?? textField.mouseCursor,
          validationErrorMessage:
              validationErrorMessage ?? textField.validationErrorMessage,
          textCapitalization:
              textCapitalization ?? textField.textCapitalization,
          maxLengthEnforcement:
              maxLengthEnforcement ?? textField.maxLengthEnforcement,
          onAppPrivateCommand:
              onAppPrivateCommand ?? textField.onAppPrivateCommand,
          inputFormatters: inputFormatters ?? textField.inputFormatters,
          enabled: enabled ?? textField.enabled,
          cursorWidth: cursorWidth ?? textField.cursorWidth,
          cursorHeight: cursorHeight ?? textField.cursorHeight,
          cursorRadius: cursorRadius ?? textField.cursorRadius,
          cursorColor: cursorColor ?? textField.cursorColor,
          keyboardAppearance:
              keyboardAppearance ?? textField.keyboardAppearance,
          scrollPadding: scrollPadding ?? textField.scrollPadding,
          selectionControls: selectionControls ?? textField.selectionControls,
          dragStartBehavior: dragStartBehavior ?? textField.dragStartBehavior,
          onTap: onTap ?? textField.onTap,
          onTapOutside: onTapOutside ?? textField.onTapOutside,
          onEditingComplete: onEditingComplete ?? textField.onEditingComplete,
          onSubmitted: onSubmitted ?? textField.onSubmitted,
          scrollController: scrollController ?? textField.scrollController,
          scrollPhysics: scrollPhysics ?? textField.scrollPhysics,
          autofillHints: autofillHints ?? textField.autofillHints,
          clipBehavior: clipBehavior ?? textField.clipBehavior,
          handleValidationError:
              handleValidationError ?? textField.handleValidationError,
          passwordVisible: passwordVisible ?? textField.passwordVisible,
          type: type ?? textField.type,
          prefixIcon: prefixIcon ?? textField.prefixIcon,
          backgroundColor: backgroundColor ?? textField.backgroundColor,
          borderRadius: borderRadius ?? textField.borderRadius,
          border: border ?? textField.border,
          focusedBorder: focusedBorder ?? textField.focusedBorder,
          enabledBorder: enabledBorder ?? textField.enabledBorder,
          contentPadding: contentPadding ?? textField.contentPadding,
          customValidationRule:
              customValidationRule ?? textField.customValidationRule,
          clearable: clearable ?? textField.clearable,
          clearIcon: clearIcon ?? textField.clearIcon,
          mask: mask ?? textField.mask,
          maskMatch: maskMatch ?? textField.maskMatch,
          maskedReturnValue: maskedReturnValue ?? textField.maskedReturnValue,
        );
      }
    };
  }
}

/// Field is a class that helps in managing form fields
class Field {
  Field(
    this.key, {
    this.label,
    this.value,
    FormCast? cast,
    this.validate,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.style,
    this.metaData = const {},
    this.hidden = false,
    this.readOnly,
  }) : cast = cast ?? FormCast() {
    if (style == null) return;

    metaData = {};
    if (style is String) {
      style = style;
      return;
    }
    if (style is Map) {
      style as Map<String, dynamic>;
      metaData!["decoration_style"] =
          (style as Map<String, dynamic>).entries.first.value;
      style = (style as Map<String, dynamic>).entries.first.key;
    }
  }

  /// Field.text is a constructor that helps in managing text fields
  Field.text(
    this.key, {
    this.label,
    this.value,
    this.validate,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.style,
    this.metaData = const {},
    this.hidden = false,
    this.readOnly,
    Widget? prefixIcon,
    bool clearable = false,
    Widget? clearIcon,
  }) : cast = FormCast.text(
          prefixIcon: prefixIcon,
          clearable: clearable,
          clearIcon: clearIcon,
        ) {
    if (style == null) return;

    metaData = {};
    if (style is String) {
      style = style;
      return;
    }
    if (style is Map) {
      style as Map<String, dynamic>;
      metaData!["decoration_style"] =
          (style as Map<String, dynamic>).entries.first.value;
      style = (style as Map<String, dynamic>).entries.first.key;
    }
  }

  /// Field.currency is a constructor that helps in managing currency fields
  Field.currency(
    this.key, {
    this.label,
    required String currency,
    this.value,
    this.validate,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.style,
    this.metaData = const {},
    this.hidden = false,
    this.readOnly,
  }) : cast = FormCast.currency(currency.toLowerCase()) {
    if (style == null) return;

    metaData = {};
    if (style is String) {
      style = style;
      return;
    }
    if (style is Map) {
      style as Map<String, dynamic>;
      metaData!["decoration_style"] =
          (style as Map<String, dynamic>).entries.first.value;
      style = (style as Map<String, dynamic>).entries.first.key;
    }
  }

  /// Field.password is a constructor that helps in managing password fields
  Field.password(
    this.key, {
    this.label,
    this.value,
    this.validate,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.style,
    this.metaData = const {},
    this.hidden = false,
    bool viewable = false,
    Widget? prefixIcon,
    this.readOnly,
  }) : cast = FormCast.password(viewable: viewable, prefixIcon: prefixIcon) {
    if (style == null) return;

    metaData = {};
    if (style is String) {
      style = style;
      return;
    }
    if (style is Map) {
      style as Map<String, dynamic>;
      metaData!["decoration_style"] =
          (style as Map<String, dynamic>).entries.first.value;
      style = (style as Map<String, dynamic>).entries.first.key;
    }
  }

  /// Field.email is a constructor that helps in managing password fields
  Field.email(
    this.key, {
    this.label,
    this.value,
    this.validate,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.style,
    this.metaData = const {},
    this.hidden = false,
    this.readOnly,
    Widget? prefixIcon,
    bool clearable = false,
    Widget? clearIcon,
  }) : cast = FormCast.email(
          prefixIcon: prefixIcon,
          clearable: clearable,
          clearIcon: clearIcon,
        ) {
    if (style == null) return;

    metaData = {};
    if (style is String) {
      style = style;
      return;
    }
    if (style is Map) {
      style as Map<String, dynamic>;
      metaData!["decoration_style"] =
          (style as Map<String, dynamic>).entries.first.value;
      style = (style as Map<String, dynamic>).entries.first.key;
    }
  }

  /// Field.capitalizeWords is a constructor that helps in managing capitalizeWords fields
  Field.capitalizeWords(
    this.key, {
    this.label,
    this.value,
    this.validate,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.style,
    this.metaData = const {},
    this.hidden = false,
    this.readOnly,
    Widget? prefixIcon,
    bool clearable = false,
    Widget? clearIcon,
  }) : cast = FormCast.capitalizeWords(
          prefixIcon: prefixIcon,
          clearable: clearable,
          clearIcon: clearIcon,
        ) {
    if (style == null) return;

    metaData = {};
    if (style is String) {
      style = style;
      return;
    }
    if (style is Map) {
      style as Map<String, dynamic>;
      metaData!["decoration_style"] =
          (style as Map<String, dynamic>).entries.first.value;
      style = (style as Map<String, dynamic>).entries.first.key;
    }
  }

  /// Field.capitalizeSentences is a constructor that helps in managing capitalizeSentences fields
  Field.capitalizeSentences(
    this.key, {
    this.label,
    this.value,
    this.validate,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.style,
    this.metaData = const {},
    this.hidden = false,
    this.readOnly,
    Widget? prefixIcon,
    bool clearable = false,
    Widget? clearIcon,
  }) : cast = FormCast.capitalizeSentences(
          prefixIcon: prefixIcon,
          clearable: clearable,
          clearIcon: clearIcon,
        ) {
    if (style == null) return;

    metaData = {};
    if (style is String) {
      style = style;
      return;
    }
    if (style is Map) {
      style as Map<String, dynamic>;
      metaData!["decoration_style"] =
          (style as Map<String, dynamic>).entries.first.value;
      style = (style as Map<String, dynamic>).entries.first.key;
    }
  }

  /// Field.picker is a constructor that helps in managing picker fields
  Field.picker(
    this.key, {
    this.label,
    this.value,
    this.validate,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.style,
    this.metaData = const {},
    this.hidden = false,
    this.readOnly,
    required List<String> options,
    BottomModalSheetStyle? bottomModalSheetStyle,
  }) : cast = FormCast.picker(
            options: options, bottomModalSheetStyle: bottomModalSheetStyle) {
    if (style == null) return;

    metaData = {};
    if (style is String) {
      style = style;
      return;
    }
    if (style is Map) {
      style as Map<String, dynamic>;
      metaData!["decoration_style"] =
          (style as Map<String, dynamic>).entries.first.value;
      style = (style as Map<String, dynamic>).entries.first.key;
    }
  }

  /// Field.widget is a constructor that helps in managing widget fields
  Field.widget({required Widget child})
      : cast = FormCast.widget(
          child: child,
        ),
        autofocus = false {
    key = _randomKey();
  }

  /// Generate a random key
  String _randomKey() {
    return Random().nextInt(100000).toString();
  }

  /// Field.radio is a constructor that helps in managing radio fields
  Field.radio(
    this.key, {
    this.label,
    this.value,
    this.validate,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.style,
    this.metaData = const {},
    this.hidden = false,
    this.readOnly,
    required List<String> options,
    NyRadioTileStyle? nyRadioTileStyle,
  }) : cast = FormCast.radio(
            options: options, nyRadioTileStyle: nyRadioTileStyle) {
    if (style == null) return;

    metaData = {};
    if (style is String) {
      style = style;
      return;
    }
    if (style is Map) {
      style as Map<String, dynamic>;
      metaData!["decoration_style"] =
          (style as Map<String, dynamic>).entries.first.value;
      style = (style as Map<String, dynamic>).entries.first.key;
    }
  }

  /// Field.number is a constructor that helps in managing number fields
  Field.number(
    this.key, {
    this.label,
    this.value,
    this.validate,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.style,
    this.metaData = const {},
    this.hidden = false,
    this.readOnly,
    bool decimal = false,
  }) : cast = FormCast.number(decimal: decimal) {
    if (style == null) return;

    metaData = {};
    if (style is String) {
      style = style;
      return;
    }
    if (style is Map) {
      style as Map<String, dynamic>;
      metaData!["decoration_style"] =
          (style as Map<String, dynamic>).entries.first.value;
      style = (style as Map<String, dynamic>).entries.first.key;
    }
  }

  /// Field.mask is a constructor that helps in managing mask fields
  Field.mask(
    this.key, {
    this.label,
    this.value,
    this.validate,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.style,
    this.metaData = const {},
    this.hidden = false,
    this.readOnly,
    Widget? prefixIcon,
    bool clearable = false,
    Widget? clearIcon,
    required String? mask,
    String? match = r'[\w\d]',
    bool? maskReturnValue = false,
  }) : cast = FormCast.mask(
          prefixIcon: prefixIcon,
          clearable: clearable,
          clearIcon: clearIcon,
          mask: mask,
        ) {
    if (style == null) return;

    metaData = {};
    if (style is String) {
      style = style;
      return;
    }
    if (style is Map) {
      style as Map<String, dynamic>;
      metaData!["decoration_style"] =
          (style as Map<String, dynamic>).entries.first.value;
      style = (style as Map<String, dynamic>).entries.first.key;
    }
  }

  /// Field.url is a constructor that helps in managing url fields
  Field.url(
    this.key, {
    this.label,
    this.value,
    this.validate,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.style,
    this.metaData = const {},
    this.hidden = false,
    this.readOnly,
    Widget? prefixIcon,
    bool clearable = false,
    Widget? clearIcon,
  }) : cast = FormCast.url(
          prefixIcon: prefixIcon,
          clearable: clearable,
          clearIcon: clearIcon,
        ) {
    if (style == null) return;

    metaData = {};
    if (style is String) {
      style = style;
      return;
    }
    if (style is Map) {
      style as Map<String, dynamic>;
      metaData!["decoration_style"] =
          (style as Map<String, dynamic>).entries.first.value;
      style = (style as Map<String, dynamic>).entries.first.key;
    }
  }

  /// Field.textArea is a constructor that helps in managing textArea fields
  Field.textArea(this.key,
      {this.label,
      this.value,
      this.validate,
      this.autofocus = false,
      this.dummyData,
      this.header,
      this.footer,
      this.titleStyle,
      this.style,
      this.metaData = const {},
      this.hidden = false,
      this.readOnly,
      TextAreaSize textAreaSize = TextAreaSize.sm})
      : cast = FormCast.textArea(textAreaSize: textAreaSize) {
    if (style == null) return;

    metaData = {};
    if (style is String) {
      style = style;
      return;
    }
    if (style is Map) {
      style as Map<String, dynamic>;
      metaData!["decoration_style"] =
          (style as Map<String, dynamic>).entries.first.value;
      style = (style as Map<String, dynamic>).entries.first.key;
    }
  }

  /// Field.phoneNumber is a constructor that helps in managing phoneNumber fields
  Field.phoneNumber(
    this.key, {
    this.label,
    this.value,
    this.validate,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.style,
    this.metaData = const {},
    this.hidden = false,
    this.readOnly,
    Widget? prefixIcon,
    bool clearable = false,
    Widget? clearIcon,
  }) : cast = FormCast.phoneNumber(
          prefixIcon: prefixIcon,
          clearable: clearable,
          clearIcon: clearIcon,
        ) {
    if (style == null) return;

    metaData = {};
    if (style is String) {
      style = style;
      return;
    }
    if (style is Map) {
      style as Map<String, dynamic>;
      metaData!["decoration_style"] =
          (style as Map<String, dynamic>).entries.first.value;
      style = (style as Map<String, dynamic>).entries.first.key;
    }
  }

  /// Field.checkbox is a constructor that helps in managing textArea fields
  Field.checkbox(
    this.key, {
    this.label,
    this.value,
    this.validate,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.style,
    this.metaData = const {},
    this.hidden = false,
    this.readOnly,
    MouseCursor? mouseCursor,
    Color? activeColor,
    Color? fillColor,
    Color? checkColor,
    Color? hoverColor,
    Color? overlayColor,
    double? splashRadius,
    MaterialTapTargetSize? materialTapTargetSize,
    VisualDensity? visualDensity,
    FocusNode? focusNode,
    ShapeBorder? shape,
    BorderSide? side,
    bool isError = false,
    bool? enabled,
    Color? tileColor,
    Widget? title,
    Widget? subtitle,
    bool isThreeLine = false,
    bool? dense,
    Widget? secondary,
    bool selected = false,
    ListTileControlAffinity controlAffinity = ListTileControlAffinity.platform,
    EdgeInsetsGeometry? contentPadding,
    bool tristate = false,
    ShapeBorder? checkboxShape,
    Color? selectedTileColor,
    ValueChanged<bool?>? onFocusChange,
    bool? enableFeedback,
    String? checkboxSemanticLabel,
  }) : cast = FormCast.checkbox(
            mouseCursor: mouseCursor,
            activeColor: activeColor,
            fillColor: fillColor,
            checkColor: checkColor,
            hoverColor: hoverColor,
            overlayColor: overlayColor,
            splashRadius: splashRadius,
            materialTapTargetSize: materialTapTargetSize,
            visualDensity: visualDensity,
            focusNode: focusNode,
            autofocus: autofocus,
            shape: shape,
            side: side,
            isError: isError,
            enabled: enabled,
            tileColor: tileColor,
            title: title,
            subtitle: subtitle,
            isThreeLine: isThreeLine,
            dense: dense,
            secondary: secondary,
            selected: selected,
            controlAffinity: controlAffinity,
            contentPadding: contentPadding,
            tristate: tristate,
            checkboxShape: checkboxShape,
            selectedTileColor: selectedTileColor,
            onFocusChange: onFocusChange,
            enableFeedback: enableFeedback,
            checkboxSemanticLabel: checkboxSemanticLabel) {
    if (style == null) return;

    metaData = {};
    if (style is String) {
      style = style;
      return;
    }
    if (style is Map) {
      style as Map<String, dynamic>;
      metaData!["decoration_style"] =
          (style as Map<String, dynamic>).entries.first.value;
      style = (style as Map<String, dynamic>).entries.first.key;
    }
  }

  /// Field.switchBox is a constructor that helps in managing switch fields
  Field.switchBox(
    this.key, {
    this.label,
    this.value,
    this.validate,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.style,
    this.metaData = const {},
    this.hidden = false,
    this.readOnly,
    MouseCursor? mouseCursor,
    Color? activeColor,
    Color? fillColor,
    Color? checkColor,
    Color? hoverColor,
    Color? overlayColor,
    double? splashRadius,
    MaterialTapTargetSize? materialTapTargetSize,
    VisualDensity? visualDensity,
    FocusNode? focusNode,
    ShapeBorder? shape,
    BorderSide? side,
    bool isError = false,
    bool? enabled,
    Color? tileColor,
    Widget? title,
    Widget? subtitle,
    bool isThreeLine = false,
    bool? dense,
    Widget? secondary,
    bool selected = false,
    ListTileControlAffinity controlAffinity = ListTileControlAffinity.platform,
    EdgeInsetsGeometry? contentPadding,
    bool tristate = false,
    ShapeBorder? checkboxShape,
    Color? selectedTileColor,
    ValueChanged<bool?>? onFocusChange,
    bool? enableFeedback,
    String? checkboxSemanticLabel,
  }) : cast = FormCast.switchBox(
            mouseCursor: mouseCursor,
            activeColor: activeColor,
            fillColor: fillColor,
            checkColor: checkColor,
            hoverColor: hoverColor,
            overlayColor: overlayColor,
            splashRadius: splashRadius,
            materialTapTargetSize: materialTapTargetSize,
            visualDensity: visualDensity,
            focusNode: focusNode,
            autofocus: autofocus,
            shape: shape,
            side: side,
            isError: isError,
            enabled: enabled,
            tileColor: tileColor,
            title: title,
            subtitle: subtitle,
            isThreeLine: isThreeLine,
            dense: dense,
            secondary: secondary,
            selected: selected,
            controlAffinity: controlAffinity,
            contentPadding: contentPadding,
            tristate: tristate,
            checkboxShape: checkboxShape,
            selectedTileColor: selectedTileColor,
            onFocusChange: onFocusChange,
            enableFeedback: enableFeedback,
            checkboxSemanticLabel: checkboxSemanticLabel) {
    if (style == null) return;

    metaData = {};
    if (style is String) {
      style = style;
      return;
    }
    if (style is Map) {
      style as Map<String, dynamic>;
      metaData!["decoration_style"] =
          (style as Map<String, dynamic>).entries.first.value;
      style = (style as Map<String, dynamic>).entries.first.key;
    }
  }

  /// Field.datetime is a constructor that helps in managing datetime fields
  Field.datetime(
    this.key, {
    this.label,
    this.value,
    this.validate,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.style,
    this.metaData = const {},
    this.hidden = false,
    this.readOnly,
    TextStyle? dateTextStyle,
    VoidCallback? onTap,
    FocusNode? focusNode,
    bool? enableFeedback,
    EdgeInsetsGeometry? padding,
    bool hideDefaultSuffixIcon = false,
    DateTime? initialPickerDateTime,
    CupertinoDatePickerOptions? cupertinoDatePickerOptions,
    MaterialDatePickerOptions? materialDatePickerOptions,
    MaterialTimePickerOptions? materialTimePickerOptions,
    InputDecoration? decoration,
    intl.DateFormat? dateFormat,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTimeFieldPickerMode mode = DateTimeFieldPickerMode.dateAndTime,
    DateTimeFieldPickerPlatform pickerPlatform =
        DateTimeFieldPickerPlatform.adaptive,
  }) : cast = FormCast.datetime(
            style: dateTextStyle,
            onTap: onTap,
            focusNode: focusNode,
            autofocus: autofocus,
            enableFeedback: enableFeedback,
            padding: padding,
            hideDefaultSuffixIcon: hideDefaultSuffixIcon,
            initialPickerDateTime: initialPickerDateTime,
            cupertinoDatePickerOptions: cupertinoDatePickerOptions,
            materialDatePickerOptions: materialDatePickerOptions,
            materialTimePickerOptions: materialTimePickerOptions,
            decoration: decoration,
            dateFormat: dateFormat,
            firstDate: firstDate,
            lastDate: lastDate,
            mode: mode,
            pickerPlatform: pickerPlatform) {
    if (style == null) return;

    metaData = {};
    if (style is String) {
      style = style;
      return;
    }
    if (style is Map) {
      style as Map<String, dynamic>;
      metaData!["decoration_style"] =
          (style as Map<String, dynamic>).entries.first.value;
      style = (style as Map<String, dynamic>).entries.first.key;
    }
  }

  /// Field.date is a constructor that helps in managing date fields
  Field.date(
    this.key, {
    this.label,
    this.value,
    this.validate,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.style,
    this.metaData = const {},
    this.hidden = false,
    this.readOnly,
    TextStyle? dateTextStyle,
    VoidCallback? onTap,
    FocusNode? focusNode,
    bool? enableFeedback,
    EdgeInsetsGeometry? padding,
    bool hideDefaultSuffixIcon = false,
    DateTime? initialPickerDateTime,
    CupertinoDatePickerOptions? cupertinoDatePickerOptions,
    MaterialDatePickerOptions? materialDatePickerOptions,
    MaterialTimePickerOptions? materialTimePickerOptions,
    InputDecoration? decoration,
    intl.DateFormat? dateFormat,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTimeFieldPickerMode mode = DateTimeFieldPickerMode.date,
    DateTimeFieldPickerPlatform pickerPlatform =
        DateTimeFieldPickerPlatform.adaptive,
  }) : cast = FormCast.date(
            style: dateTextStyle,
            onTap: onTap,
            focusNode: focusNode,
            autofocus: autofocus,
            enableFeedback: enableFeedback,
            padding: padding,
            hideDefaultSuffixIcon: hideDefaultSuffixIcon,
            initialPickerDateTime: initialPickerDateTime,
            cupertinoDatePickerOptions: cupertinoDatePickerOptions,
            materialDatePickerOptions: materialDatePickerOptions,
            materialTimePickerOptions: materialTimePickerOptions,
            decoration: decoration,
            dateFormat: dateFormat,
            firstDate: firstDate,
            lastDate: lastDate,
            mode: mode,
            pickerPlatform: pickerPlatform) {
    if (style == null) return;

    metaData = {};
    if (style is String) {
      style = style;
      return;
    }
    if (style is Map) {
      style as Map<String, dynamic>;
      metaData!["decoration_style"] =
          (style as Map<String, dynamic>).entries.first.value;
      style = (style as Map<String, dynamic>).entries.first.key;
    }
  }

  /// Field.chips is a constructor that helps in managing chips fields
  Field.chips(
    this.key, {
    this.label,
    this.value,
    this.validate,
    this.autofocus = false,
    this.dummyData,
    this.header,
    this.footer,
    this.titleStyle,
    this.style,
    this.metaData = const {},
    this.hidden = false,
    this.readOnly,
    required List<dynamic> options,
    Color? backgroundColor,
    Color? selectedColor,
    double headerSpacing = 5,
    double footerSpacing = 5,
    OutlinedBorder shape = const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8))),
    BorderSide unselectedSide = const BorderSide(color: Colors.grey, width: 1),
    BorderSide selectedSide = const BorderSide(color: Colors.grey, width: 1),
    TextStyle labelStyle =
        const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
    TextStyle unselectedTextStyle =
        const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
    TextStyle selectedTextStyle =
        const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
    EdgeInsets padding = const EdgeInsets.all(8.0),
    double runSpacing = 8.0,
    double spacing = 8.0,
    Color checkmarkColor = Colors.white,
  }) : cast = FormCast.chips(
            options: options,
            backgroundColor: backgroundColor,
            selectedColor: selectedColor,
            headerSpacing: headerSpacing,
            footerSpacing: footerSpacing,
            shape: shape,
            unselectedSide: unselectedSide,
            selectedSide: selectedSide,
            labelStyle: labelStyle,
            unselectedTextStyle: unselectedTextStyle,
            selectedTextStyle: selectedTextStyle,
            padding: padding,
            runSpacing: runSpacing,
            spacing: spacing,
            checkmarkColor: checkmarkColor) {
    if (style == null) return;

    metaData = {};
    if (style is String) {
      style = style;
      return;
    }
    if (style is Map) {
      style as Map<String, dynamic>;
      metaData!["decoration_style"] =
          (style as Map<String, dynamic>).entries.first.value;
      style = (style as Map<String, dynamic>).entries.first.key;
    }
  }

  /// The key of the field
  late String key;

  /// The label of the field
  /// If the label is not provided, the key will be used as the label
  String? label;

  /// The value of the field
  dynamic value;

  /// The cast for the field
  FormCast cast;

  /// The validator for the field
  FormValidator? validate;

  /// The autofocus for the field
  bool autofocus;

  /// The dummy data for the field
  String? dummyData;

  /// The style for the field
  dynamic style;

  /// Get the name of the field
  String get name => label?.tr() ?? key.titleCase.tr();

  /// Get the header of the field
  Widget? header;

  /// Get the footer of the field
  Widget? footer;

  /// Get the title style of the field
  TextStyle? titleStyle;

  /// Get the metadata of the field
  Map<String, NyTextField Function(NyTextField nyTextField)>? metaData;

  /// Hidden field
  bool? hidden = false;

  /// Readonly field
  bool? readOnly;

  /// Hide the field
  void hide() {
    hidden = true;
  }

  /// Show the field
  void show() {
    hidden = false;
  }

  /// Convert the [Field] to a Map
  Map<String, dynamic> toJson() {
    return {
      "key": key,
      "value": value,
    };
  }
}
