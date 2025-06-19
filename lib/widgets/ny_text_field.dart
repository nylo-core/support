import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '/metro/metro_service.dart';
import '/nylo.dart';
import '/widgets/ny_form.dart';
import '/widgets/spacing.dart';
import '/localization/app_localization.dart';
import '/validation/ny_validator.dart';
import '/widgets/ny_state.dart';

/// Nylo's Text Field Widget
class NyTextField extends StatefulWidget {
  final String? labelText;
  final TextStyle? labelStyle;
  final TextEditingController controller;
  final bool obscureText;
  final int? maxLines, minLines;
  final TextInputType keyboardType;
  final bool autoFocus;
  final TextAlign? textAlign;
  final bool enableSuggestions;
  final FocusNode? focusNode;
  final String? hintText;
  final TextStyle? hintStyle;
  final String? validationRules;
  final String? dummyData;
  final Function(String value)? onChanged;
  final TextInputAction? textInputAction;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlignVertical? textAlignVertical;
  final TextDirection? textDirection;
  final String obscuringCharacter;
  final bool autocorrect;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool expands;
  final bool readOnly;
  final bool? showCursor;
  final int? maxLength;
  final MouseCursor? mouseCursor;
  final String? validationErrorMessage;
  final TextCapitalization textCapitalization;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final AppPrivateCommandCallback? onAppPrivateCommand;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final TextSelectionControls? selectionControls;
  final DragStartBehavior dragStartBehavior;
  final GestureTapCallback? onTap;
  final TapRegionCallback? onTapOutside;
  final InputDecoration? decoration;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;
  final Iterable<String>? autofillHints;
  final Clip clipBehavior;
  final Function(String handleError)? handleValidationError;
  final bool? passwordVisible;
  final String? type;
  final Widget? prefixIcon;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final InputBorder? border;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final EdgeInsetsGeometry? contentPadding;
  final bool? passwordViewable;
  final bool? validateOnFocusChange;
  final bool Function(dynamic value)? customValidationRule;
  final Widget? header;
  final Widget? footer;
  final bool? clearable;
  final Widget? clearIcon;
  final String? mask;
  final String? maskMatch;
  final bool? maskedReturnValue;
  final DecoratorTextField? decorator;

  /// Default Text Field
  const NyTextField(
      {super.key,
      required this.controller,
      this.labelText,
      this.obscureText = false,
      this.autoFocus = false,
      this.keyboardType = TextInputType.text,
      this.textAlign,
      this.maxLines = 1,
      this.validateOnFocusChange = true,
      this.handleValidationError,
      this.minLines,
      this.enableSuggestions = true,
      this.hintText,
      this.hintStyle,
      this.focusNode,
      this.validationRules,
      this.dummyData,
      this.onChanged,
      this.style,
      this.strutStyle,
      this.textInputAction,
      this.readOnly = false,
      this.showCursor,
      this.maxLength,
      this.enabled,
      this.dragStartBehavior = DragStartBehavior.start,
      this.cursorHeight,
      this.cursorRadius,
      this.cursorColor,
      this.onTap,
      this.onTapOutside,
      this.validationErrorMessage,
      this.mouseCursor,
      this.textCapitalization = TextCapitalization.none,
      this.maxLengthEnforcement,
      this.cursorWidth = 2.0,
      this.onAppPrivateCommand,
      this.inputFormatters,
      this.expands = false,
      this.textAlignVertical,
      this.textDirection,
      this.obscuringCharacter = '•',
      this.autocorrect = true,
      this.smartDashesType,
      this.smartQuotesType,
      this.decoration,
      this.onEditingComplete,
      this.keyboardAppearance,
      this.scrollPadding = const EdgeInsets.all(20.0),
      this.selectionControls,
      this.onSubmitted,
      this.scrollController,
      this.scrollPhysics,
      this.autofillHints = const <String>[],
      this.clipBehavior = Clip.hardEdge,
      this.passwordVisible,
      this.passwordViewable,
      this.prefixIcon,
      this.backgroundColor,
      this.borderRadius,
      this.border,
      this.focusedBorder,
      this.enabledBorder,
      this.contentPadding,
      this.labelStyle,
      this.customValidationRule,
      this.header,
      this.footer,
      this.clearable,
      this.clearIcon,
      this.mask,
      this.maskMatch,
      this.maskedReturnValue,
      this.decorator,
      this.type});

  /// Compact Text Field
  const NyTextField.compact({
    super.key,
    this.passwordVisible,
    this.labelText,
    required this.controller,
    this.obscureText = false,
    this.autoFocus = false,
    this.keyboardType = TextInputType.text,
    this.textAlign,
    this.validateOnFocusChange = false,
    this.maxLines = 1,
    this.handleValidationError,
    this.minLines,
    this.enableSuggestions = true,
    this.hintText,
    this.hintStyle,
    this.focusNode,
    this.validationRules,
    this.dummyData,
    this.onChanged,
    this.style,
    this.strutStyle,
    this.textInputAction,
    this.readOnly = false,
    this.showCursor,
    this.maxLength,
    this.enabled,
    this.dragStartBehavior = DragStartBehavior.start,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.onTap,
    this.onTapOutside,
    this.validationErrorMessage,
    this.mouseCursor,
    this.textCapitalization = TextCapitalization.none,
    this.maxLengthEnforcement,
    this.cursorWidth = 2.0,
    this.onAppPrivateCommand,
    this.inputFormatters,
    this.expands = false,
    this.textAlignVertical,
    this.textDirection,
    this.obscuringCharacter = '•',
    this.autocorrect = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.decoration,
    this.onEditingComplete,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.selectionControls,
    this.onSubmitted,
    this.scrollController,
    this.scrollPhysics,
    this.autofillHints = const <String>[],
    this.clipBehavior = Clip.hardEdge,
    this.prefixIcon,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.focusedBorder,
    this.enabledBorder,
    this.contentPadding,
    this.labelStyle,
    this.customValidationRule,
    this.header,
    this.footer,
    this.clearable,
    this.clearIcon,
    this.mask,
    this.maskMatch,
    this.maskedReturnValue,
    this.decorator,
    this.type = 'compact',
  }) : passwordViewable = false;

  /// Password Text Field
  const NyTextField.password({
    super.key,
    this.passwordVisible,
    this.labelText = "Password",
    required this.controller,
    this.obscureText = true,
    this.autoFocus = false,
    this.keyboardType = TextInputType.text,
    this.textAlign,
    this.maxLines = 1,
    this.validateOnFocusChange = false,
    this.handleValidationError,
    this.minLines,
    this.enableSuggestions = true,
    this.hintText,
    this.hintStyle,
    this.focusNode,
    this.validationRules,
    this.dummyData,
    this.onChanged,
    this.style,
    this.strutStyle,
    this.textInputAction,
    this.readOnly = false,
    this.showCursor,
    this.maxLength,
    this.enabled,
    this.dragStartBehavior = DragStartBehavior.start,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.onTap,
    this.onTapOutside,
    this.validationErrorMessage,
    this.mouseCursor,
    this.textCapitalization = TextCapitalization.none,
    this.maxLengthEnforcement,
    this.cursorWidth = 2.0,
    this.onAppPrivateCommand,
    this.inputFormatters,
    this.expands = false,
    this.textAlignVertical,
    this.textDirection,
    this.obscuringCharacter = '•',
    this.autocorrect = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.decoration,
    this.onEditingComplete,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.selectionControls,
    this.onSubmitted,
    this.scrollController,
    this.scrollPhysics,
    this.passwordViewable,
    this.autofillHints = const <String>[],
    this.clipBehavior = Clip.hardEdge,
    this.prefixIcon,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.focusedBorder,
    this.enabledBorder,
    this.contentPadding,
    this.labelStyle,
    this.customValidationRule,
    this.header,
    this.footer,
    this.clearable,
    this.clearIcon,
    this.mask,
    this.maskMatch,
    this.maskedReturnValue,
    this.decorator,
    this.type = 'password',
  });

  /// Email Address Text Field
  const NyTextField.emailAddress({
    super.key,
    this.labelText = "Email Address",
    required this.controller,
    this.obscureText = false,
    this.autoFocus = true,
    this.keyboardType = TextInputType.emailAddress,
    this.textAlign,
    this.validateOnFocusChange = false,
    this.maxLines = 1,
    this.handleValidationError,
    this.minLines,
    this.enableSuggestions = true,
    this.hintText,
    this.hintStyle,
    this.focusNode,
    this.validationRules,
    this.dummyData,
    this.onChanged,
    this.style,
    this.strutStyle,
    this.textInputAction,
    this.readOnly = false,
    this.showCursor,
    this.maxLength,
    this.enabled,
    this.dragStartBehavior = DragStartBehavior.start,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.onTap,
    this.onTapOutside,
    this.validationErrorMessage,
    this.mouseCursor,
    this.textCapitalization = TextCapitalization.none,
    this.maxLengthEnforcement,
    this.cursorWidth = 2.0,
    this.onAppPrivateCommand,
    this.inputFormatters,
    this.expands = false,
    this.textAlignVertical,
    this.textDirection,
    this.obscuringCharacter = '•',
    this.autocorrect = true,
    this.smartDashesType,
    this.passwordViewable,
    this.smartQuotesType,
    this.decoration,
    this.onEditingComplete,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.selectionControls,
    this.onSubmitted,
    this.scrollController,
    this.scrollPhysics,
    this.autofillHints = const <String>[],
    this.clipBehavior = Clip.hardEdge,
    this.prefixIcon,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.focusedBorder,
    this.enabledBorder,
    this.contentPadding,
    this.labelStyle,
    this.passwordVisible,
    this.customValidationRule,
    this.header,
    this.footer,
    this.clearable,
    this.clearIcon,
    this.mask,
    this.maskMatch,
    this.maskedReturnValue,
    this.decorator,
    this.type = 'email-address',
  });

  /// Copy with method
  NyTextField copyWith({
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
    InputDecoration? decoration,
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
    DecoratorTextField? decorator,
  }) {
    return NyTextField(
      type: type ?? this.type,
      labelText: labelText ?? this.labelText,
      labelStyle: labelStyle ?? this.labelStyle,
      controller: controller ?? this.controller,
      obscureText: obscureText ?? this.obscureText,
      maxLines: maxLines ?? this.maxLines,
      minLines: minLines ?? this.minLines,
      keyboardType: keyboardType ?? this.keyboardType,
      autoFocus: autoFocus ?? this.autoFocus,
      validateOnFocusChange:
          validateOnFocusChange ?? this.validateOnFocusChange,
      textAlign: textAlign ?? this.textAlign,
      enableSuggestions: enableSuggestions ?? this.enableSuggestions,
      focusNode: focusNode ?? this.focusNode,
      hintText: hintText ?? this.hintText,
      passwordViewable: passwordViewable ?? this.passwordViewable,
      hintStyle: hintStyle ?? this.hintStyle,
      validationRules: validationRules ?? this.validationRules,
      dummyData: dummyData ?? this.dummyData,
      onChanged: onChanged ?? this.onChanged,
      textInputAction: textInputAction ?? this.textInputAction,
      style: style ?? this.style,
      strutStyle: strutStyle ?? this.strutStyle,
      textAlignVertical: textAlignVertical ?? this.textAlignVertical,
      textDirection: textDirection ?? this.textDirection,
      obscuringCharacter: obscuringCharacter ?? this.obscuringCharacter,
      autocorrect: autocorrect ?? this.autocorrect,
      smartDashesType: smartDashesType ?? this.smartDashesType,
      smartQuotesType: smartQuotesType ?? this.smartQuotesType,
      expands: expands ?? this.expands,
      readOnly: readOnly ?? this.readOnly,
      showCursor: showCursor ?? this.showCursor,
      maxLength: maxLength ?? this.maxLength,
      mouseCursor: mouseCursor ?? this.mouseCursor,
      validationErrorMessage:
          validationErrorMessage ?? this.validationErrorMessage,
      textCapitalization: textCapitalization ?? this.textCapitalization,
      maxLengthEnforcement: maxLengthEnforcement ?? this.maxLengthEnforcement,
      onAppPrivateCommand: onAppPrivateCommand ?? this.onAppPrivateCommand,
      inputFormatters: inputFormatters ?? this.inputFormatters,
      enabled: enabled ?? this.enabled,
      cursorWidth: cursorWidth ?? this.cursorWidth,
      cursorHeight: cursorHeight ?? this.cursorHeight,
      cursorRadius: cursorRadius ?? this.cursorRadius,
      cursorColor: cursorColor ?? this.cursorColor,
      keyboardAppearance: keyboardAppearance ?? this.keyboardAppearance,
      scrollPadding: scrollPadding ?? this.scrollPadding,
      selectionControls: selectionControls ?? this.selectionControls,
      dragStartBehavior: dragStartBehavior ?? this.dragStartBehavior,
      onTap: onTap ?? this.onTap,
      onTapOutside: onTapOutside ?? this.onTapOutside,
      decoration: decoration ?? this.decoration,
      onEditingComplete: onEditingComplete ?? this.onEditingComplete,
      onSubmitted: onSubmitted ?? this.onSubmitted,
      scrollController: scrollController ?? this.scrollController,
      scrollPhysics: scrollPhysics ?? this.scrollPhysics,
      autofillHints: autofillHints ?? this.autofillHints,
      clipBehavior: clipBehavior ?? this.clipBehavior,
      handleValidationError:
          handleValidationError ?? this.handleValidationError,
      passwordVisible: passwordVisible ?? this.passwordVisible,
      prefixIcon: prefixIcon ?? this.prefixIcon,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      focusedBorder: focusedBorder ?? this.focusedBorder,
      enabledBorder: enabledBorder ?? this.enabledBorder,
      contentPadding: contentPadding ?? this.contentPadding,
      customValidationRule: customValidationRule ?? this.customValidationRule,
      header: header ?? header,
      footer: footer ?? footer,
      clearable: clearable ?? this.clearable,
      clearIcon: clearIcon ?? this.clearIcon,
      mask: mask ?? this.mask,
      maskMatch: maskMatch ?? this.maskMatch,
      maskedReturnValue: maskedReturnValue ?? this.maskedReturnValue,
      decorator: decorator ?? this.decorator,
    );
  }

  NyTextField merge(InputDecoration decoration) {
    return NyTextField(
      labelText: decoration.labelText ?? labelText,
      labelStyle: decoration.labelStyle ?? labelStyle,
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      autoFocus: autoFocus,
      validateOnFocusChange: validateOnFocusChange,
      handleValidationError: handleValidationError,
      textAlign: textAlign,
      enableSuggestions: enableSuggestions,
      focusNode: focusNode,
      hintText: hintText,
      hintStyle: hintStyle,
      validationRules: validationRules,
      dummyData: dummyData,
      onChanged: onChanged,
      style: style,
      strutStyle: strutStyle,
      textInputAction: textInputAction,
      readOnly: readOnly,
      showCursor: showCursor,
      maxLength: maxLength,
      enabled: enabled,
      dragStartBehavior: dragStartBehavior,
      cursorHeight: cursorHeight,
      cursorRadius: cursorRadius,
      cursorColor: cursorColor,
      onTap: onTap,
      onTapOutside: onTapOutside,
      validationErrorMessage: validationErrorMessage,
      mouseCursor: mouseCursor,
      textCapitalization: textCapitalization,
      maxLengthEnforcement: maxLengthEnforcement,
      cursorWidth: cursorWidth,
      onAppPrivateCommand: onAppPrivateCommand,
      inputFormatters: inputFormatters,
      expands: expands,
      textAlignVertical: textAlignVertical,
      textDirection: textDirection,
      obscuringCharacter: obscuringCharacter,
      autocorrect: autocorrect,
      smartDashesType: smartDashesType,
      smartQuotesType: smartQuotesType,
      decoration: this.decoration?.copyWith(
            fillColor: decoration.fillColor ?? this.decoration?.fillColor,
            filled: decoration.filled ?? this.decoration?.filled,
            focusedBorder:
                decoration.focusedBorder ?? this.decoration?.focusedBorder,
            enabledBorder:
                decoration.enabledBorder ?? this.decoration?.enabledBorder,
            contentPadding:
                decoration.contentPadding ?? this.decoration?.contentPadding,
            border: decoration.border ?? this.decoration?.border,
            errorText: decoration.errorText ?? this.decoration?.errorText,
            errorStyle: decoration.errorStyle ?? this.decoration?.errorStyle,
            errorMaxLines:
                decoration.errorMaxLines ?? this.decoration?.errorMaxLines,
            suffixIcon: decoration.suffixIcon ?? this.decoration?.suffixIcon,
            prefixIcon: decoration.prefixIcon ?? this.decoration?.prefixIcon,
            suffix: decoration.suffix ?? this.decoration?.suffix,
            prefix: decoration.prefix ?? this.decoration?.prefix,
            suffixText: decoration.suffixText ?? this.decoration?.suffixText,
            prefixText: decoration.prefixText ?? this.decoration?.prefixText,
            suffixStyle: decoration.suffixStyle ?? this.decoration?.suffixStyle,
            prefixStyle: decoration.prefixStyle ?? this.decoration?.prefixStyle,
            suffixIconColor:
                decoration.suffixIconColor ?? this.decoration?.suffixIconColor,
            prefixIconColor:
                decoration.prefixIconColor ?? this.decoration?.prefixIconColor,
            suffixIconConstraints: decoration.suffixIconConstraints ??
                this.decoration?.suffixIconConstraints,
            prefixIconConstraints: decoration.prefixIconConstraints ??
                this.decoration?.prefixIconConstraints,
            counter: decoration.counter ?? this.decoration?.counter,
            counterText: decoration.counterText ?? this.decoration?.counterText,
            counterStyle:
                decoration.counterStyle ?? this.decoration?.counterStyle,
            focusColor: decoration.focusColor ?? this.decoration?.focusColor,
            hoverColor: decoration.hoverColor ?? this.decoration?.hoverColor,
            errorBorder: decoration.errorBorder ?? this.decoration?.errorBorder,
            focusedErrorBorder: decoration.focusedErrorBorder ??
                this.decoration?.focusedErrorBorder,
            disabledBorder:
                decoration.disabledBorder ?? this.decoration?.disabledBorder,
            enabled: enabled ?? enabled,
            semanticCounterText: decoration.semanticCounterText ??
                this.decoration?.semanticCounterText,
            alignLabelWithHint: decoration.alignLabelWithHint ??
                this.decoration?.alignLabelWithHint,
            constraints: decoration.constraints ?? this.decoration?.constraints,
          ),
      onEditingComplete: onEditingComplete,
      onSubmitted: onSubmitted,
      scrollController: scrollController,
      scrollPhysics: scrollPhysics,
      autofillHints: autofillHints,
      clipBehavior: clipBehavior,
      passwordVisible: passwordVisible,
      type: type,
      prefixIcon: prefixIcon,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      border: border,
      focusedBorder: focusedBorder,
      enabledBorder: enabledBorder,
      contentPadding: contentPadding,
      customValidationRule: customValidationRule,
      header: header,
      footer: footer,
      clearable: clearable,
      clearIcon: clearIcon,
      mask: mask,
      maskMatch: maskMatch,
      maskedReturnValue: maskedReturnValue,
      decorator: decorator,
    );
  }

  @override
  createState() => _NyTextFieldState();
}

class _NyTextFieldState extends NyState<NyTextField> {
  final FocusNode _focus = FocusNode();
  bool? didChange = false;
  bool? _obscured;
  bool _passwordVisible = false;
  bool _passedValidation = false;
  TextInputFormatter? maskTextInputFormatter;

  @override
  void initState() {
    super.initState();

    _obscured = widget.obscureText;
    if (widget.passwordVisible == true) {
      _obscured = true;
    }
    _focus.addListener(_onFocusChange);
    // check if widget.inputFormatters has MaskTextInputFormatter
    maskTextInputFormatter = (widget.inputFormatters ?? []).firstWhereOrNull(
        (inputFormatter) => inputFormatter is MaskTextInputFormatter);

    if (widget.mask != null) {
      assert(widget.maskMatch != null,
          "maskMatch is required when mask is provided");
      maskTextInputFormatter = MaskTextInputFormatter(
        mask: widget.mask!,
        filter: {"#": RegExp(widget.maskMatch!)},
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
  }

  /// handle focus change
  void _onFocusChange() {
    if (_focus.hasFocus == true) {
      didChange = !(widget.validateOnFocusChange ?? false);
    } else {
      didChange = true;
      setState(() {});
    }
  }

  /// toggle obscured text
  void _toggleObscured() {
    if (_obscured == null) return;
    setState(() {
      _obscured = !_obscured!;
      if (_focus.hasPrimaryFocus) return;
      _focus.canRequestFocus = false;
    });
  }

  /// get the controller value
  String get controllerValue {
    if (maskTextInputFormatter != null) {
      if (widget.maskedReturnValue == true) {
        return (maskTextInputFormatter as MaskTextInputFormatter)
            .getMaskedText();
      }
      return (maskTextInputFormatter as MaskTextInputFormatter)
          .getUnmaskedText();
    }
    return widget.controller.text;
  }

  /// validate the users input
  String? _validate() {
    if (didChange == false) return null;

    if (widget.customValidationRule != null) {
      if (widget.customValidationRule!(widget.controller.text) == false) {
        return widget.validationErrorMessage ?? "Invalid data";
      }
    }

    if (widget.validationRules == null) {
      return null;
    }

    String attributeKey = (widget.labelText ?? "");
    try {
      NyValidator.check(
          rules: {attributeKey: widget.validationRules!},
          data: {attributeKey: controllerValue},
          messages: widget.validationErrorMessage != null
              ? {attributeKey: "$attributeKey|${widget.validationErrorMessage}"}
              : {});
      _passedValidation = true;
      return null;
    } on ValidationException catch (e) {
      String message = e.toTextFieldMessage();
      _passedValidation = false;
      if (widget.handleValidationError != null) {
        widget.handleValidationError!(message);
        return null;
      }
      return e.toTextFieldMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration decoration = widget.decoration ??
        InputDecoration(
          labelText: widget.labelText?.tr(),
          labelStyle: widget.labelStyle ??
              const TextStyle(fontSize: 16, color: Colors.black),
          hintText: widget.hintText,
          hintStyle: widget.hintStyle,
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black54),
          ),
          errorStyle: const TextStyle(fontSize: 12),
          errorMaxLines: 2,
        );

    if (widget.backgroundColor != null) {
      decoration = decoration.copyWith(
        filled: true,
        fillColor: widget.backgroundColor,
      );
    }

    if (widget.passwordVisible == true) {
      decoration = decoration.copyWith(
        suffixIcon: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
          child: GestureDetector(
            onTap: _toggleObscured,
            child: Icon(
              _obscured ?? false
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              size: 24,
            ),
          ),
        ),
      );
    }

    if (widget.prefixIcon != null) {
      decoration = decoration.copyWith(prefixIcon: widget.prefixIcon);
    }

    if (widget.labelText != null) {
      decoration = decoration.copyWith(
        labelText: widget.labelText,
      );
    }

    if (widget.clearable == true) {
      decoration = decoration.copyWith(
        suffixIcon: IconButton(
          icon: widget.clearIcon ?? const Icon(Icons.close),
          onPressed: () {
            widget.controller.clear();
            if (widget.onChanged != null) {
              widget.onChanged!("");
            }
          },
        ),
      );
    }

    String? validate = _validate();

    if (widget.decorator?.decoration != null) {
      InputDecoration? baseDecoration =
          widget.decorator?.decoration!(controllerValue, decoration);
      if (baseDecoration != null) {
        decoration = baseDecoration;
      }
    }

    if (_passedValidation == true &&
        widget.decorator?.successDecoration != null) {
      InputDecoration? successDecoration =
          widget.decorator?.successDecoration!(controllerValue, decoration);
      if (successDecoration != null) {
        decoration = successDecoration;
      }
    }

    if (_passedValidation == false &&
        widget.decorator?.errorDecoration != null) {
      InputDecoration? errorDecoration =
          widget.decorator?.errorDecoration!(controllerValue, decoration);
      if (errorDecoration != null) {
        decoration = errorDecoration;
      }
    }

    decoration = decoration.copyWith(
      errorText: validate,
    );

    switch (widget.type) {
      case 'compact':
        {
          decoration = decoration.copyWith(
              filled: true,
              fillColor: widget.backgroundColor ?? Colors.grey.shade100,
              isDense: true,
              focusedBorder: widget.focusedBorder ??
                  const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Colors.transparent)),
              enabledBorder: widget.enabledBorder ??
                  const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Colors.transparent)),
              contentPadding: widget.contentPadding ??
                  const EdgeInsetsDirectional.symmetric(
                      vertical: 13, horizontal: 13),
              border: widget.border ??
                  OutlineInputBorder(
                    borderRadius:
                        widget.borderRadius ?? BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ));
        }
      case 'email-address':
        {
          decoration = decoration.copyWith(
            prefixIcon: widget.prefixIcon ?? const Icon(Icons.email_outlined),
            filled: true,
            fillColor: widget.backgroundColor ?? Colors.grey.shade100,
            isDense: true,
            contentPadding: widget.contentPadding ??
                const EdgeInsetsDirectional.symmetric(
                    vertical: 14, horizontal: 14),
            focusedBorder: widget.focusedBorder ??
                const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Colors.transparent)),
            enabledBorder: widget.enabledBorder ??
                const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Colors.transparent)),
            border: widget.border ??
                OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius:
                      widget.borderRadius ?? BorderRadius.circular(12),
                ),
          );
        }
      case 'password':
        {
          decoration = decoration.copyWith(
            prefixIcon: widget.prefixIcon ?? const Icon(Icons.lock_rounded),
            filled: true,
            fillColor: widget.backgroundColor ?? Colors.grey.shade100,
            isDense: true,
            suffixIcon: widget.passwordViewable == true
                ? IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  )
                : null,
            contentPadding: widget.contentPadding ??
                const EdgeInsetsDirectional.symmetric(
                    vertical: 14, horizontal: 14),
            focusedBorder: widget.focusedBorder ??
                const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Colors.transparent)),
            enabledBorder: widget.enabledBorder ??
                const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Colors.transparent)),
            border: widget.border ??
                OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius:
                      widget.borderRadius ?? BorderRadius.circular(12),
                ),
          );
        }
    }

    Function(String value)? onChanged;
    if (widget.onChanged != null) {
      onChanged = widget.onChanged;
    }

    // TextField
    TextField textField = TextField(
      key: widget.key,
      decoration: decoration,
      controller: widget.controller,
      keyboardAppearance: widget.keyboardAppearance ?? Brightness.light,
      autofocus: widget.autoFocus,
      textAlign: widget.textAlign ?? TextAlign.left,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      keyboardType: widget.keyboardType,
      onTap: widget.onTap,
      textCapitalization: widget.textCapitalization,
      obscureText: widget.passwordViewable == true
          ? !_passwordVisible
          : _obscured ?? widget.obscureText,
      focusNode: widget.focusNode ?? _focus,
      enableSuggestions: widget.enableSuggestions,
      onChanged: onChanged != null
          ? (String value) {
              setState(() {});

              if (maskTextInputFormatter != null) {
                onChanged!(controllerValue);
                return;
              }

              onChanged!(value);
            }
          : null,
      textInputAction: widget.textInputAction,
      style: widget.style,
      strutStyle: widget.strutStyle,
      textAlignVertical: widget.textAlignVertical,
      textDirection: widget.textDirection,
      readOnly: widget.readOnly,
      showCursor: widget.showCursor,
      obscuringCharacter: widget.obscuringCharacter,
      smartDashesType: widget.smartDashesType,
      smartQuotesType: widget.smartQuotesType,
      expands: widget.expands,
      maxLength: widget.maxLength,
      mouseCursor: widget.mouseCursor,
      maxLengthEnforcement: widget.maxLengthEnforcement,
      onAppPrivateCommand: widget.onAppPrivateCommand,
      inputFormatters: maskTextInputFormatter != null
          ? [maskTextInputFormatter as MaskTextInputFormatter]
          : widget.inputFormatters,
      enabled: widget.enabled,
      cursorWidth: widget.cursorWidth,
      cursorHeight: widget.cursorHeight,
      onTapOutside: widget.onTapOutside,
      cursorRadius: widget.cursorRadius,
      cursorColor: widget.cursorColor,
      scrollPadding: widget.scrollPadding,
      dragStartBehavior: widget.dragStartBehavior,
      selectionControls: widget.selectionControls,
      onEditingComplete: widget.onEditingComplete,
      onSubmitted: widget.onSubmitted,
      scrollController: widget.scrollController,
      scrollPhysics: widget.scrollPhysics,
      autofillHints: widget.autofillHints,
      clipBehavior: widget.clipBehavior,
    );

    if (widget.header != null || widget.footer != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.header != null) ...[
            widget.header!,
            const Spacing.vertical(5)
          ],
          textField,
          if (widget.footer != null) ...[
            widget.footer!,
            const Spacing.vertical(5)
          ],
        ],
      );
    }
    return textField;
  }
}
