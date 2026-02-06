import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '/widgets/ny_widgets.dart';
import '/metro/ny_metro.dart';
import '/localization/ny_localization.dart';

/// Nylo's Text Field Widget
class InputField extends StatefulWidget {
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
  final FormValidator? formValidator;
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
  final Function(FormValidationResult handleError)? handleValidationError;
  final bool? passwordVisible;
  final Widget? prefixIcon;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final InputBorder? border;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final EdgeInsetsGeometry? contentPadding;
  final bool? passwordViewable;
  final bool? validateOnFocusChange;
  final Widget? header;
  final Widget? footer;
  final bool? clearable;
  final Widget? clearIcon;
  final String? mask;
  final String? maskMatch;
  final bool? maskedReturnValue;
  final DecoratorTextField? decorator;
  final Field? field;
  final String? stateName;

  /// Default Text Field
  const InputField({
    super.key,
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
    this.formValidator,
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
    this.header,
    this.footer,
    this.clearable,
    this.clearIcon,
    this.mask,
    this.maskMatch,
    this.maskedReturnValue,
    this.decorator,
    this.field,
    this.stateName,
  });

  /// CapitalizeWords Text Field - auto-capitalizes each word
  InputField.capitalizeWords({
    Key? key,
    required TextEditingController controller,
    String? labelText,
    FieldStyleTextField? style,
    bool obscureText = false,
    bool autoFocus = false,
    TextInputType keyboardType = TextInputType.text,
    TextAlign? textAlign,
    bool validateOnFocusChange = false,
    int maxLines = 1,
    Function(FormValidationResult handleError)? handleValidationError,
    int? minLines,
    bool enableSuggestions = true,
    String? hintText,
    TextStyle? hintStyle,
    FocusNode? focusNode,
    FormValidator? formValidator,
    String? dummyData,
    Function(String value)? onChanged,
    StrutStyle? strutStyle,
    TextInputAction? textInputAction,
    bool readOnly = false,
    bool? showCursor,
    int? maxLength,
    bool? enabled,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    double? cursorHeight,
    Radius? cursorRadius,
    Color? cursorColor,
    GestureTapCallback? onTap,
    TapRegionCallback? onTapOutside,
    MouseCursor? mouseCursor,
    MaxLengthEnforcement? maxLengthEnforcement,
    double cursorWidth = 2.0,
    AppPrivateCommandCallback? onAppPrivateCommand,
    List<TextInputFormatter>? inputFormatters,
    bool expands = false,
    TextAlignVertical? textAlignVertical,
    TextDirection? textDirection,
    String obscuringCharacter = '•',
    bool autocorrect = true,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    InputDecoration? decoration,
    VoidCallback? onEditingComplete,
    Brightness? keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    TextSelectionControls? selectionControls,
    ValueChanged<String>? onSubmitted,
    ScrollController? scrollController,
    ScrollPhysics? scrollPhysics,
    Iterable<String>? autofillHints = const <String>[],
    Clip clipBehavior = Clip.hardEdge,
    Widget? prefixIcon,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    InputBorder? border,
    InputBorder? focusedBorder,
    InputBorder? enabledBorder,
    EdgeInsetsGeometry? contentPadding,
    TextStyle? labelStyle,
    Widget? header,
    Widget? footer,
    bool? clearable,
    Widget? clearIcon,
    String? mask,
    String? maskMatch,
    bool? maskedReturnValue,
    DecoratorTextField? decorator,
    String? stateName,
    bool? passwordVisible,
    bool? passwordViewable,
  }) : this(
         key: key,
         controller: controller,
         labelText: labelText,
         style: style?.toTextStyle(),
         obscureText: obscureText,
         autoFocus: autoFocus,
         keyboardType: keyboardType,
         textAlign: textAlign,
         validateOnFocusChange: validateOnFocusChange,
         maxLines: maxLines,
         handleValidationError: handleValidationError,
         minLines: minLines,
         enableSuggestions: enableSuggestions,
         hintText: hintText,
         hintStyle: hintStyle,
         focusNode: focusNode,
         formValidator: formValidator,
         dummyData: dummyData,
         onChanged: onChanged,
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
         mouseCursor: mouseCursor,
         textCapitalization: TextCapitalization.words,
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
         decoration: decoration,
         onEditingComplete: onEditingComplete,
         keyboardAppearance: keyboardAppearance,
         scrollPadding: scrollPadding,
         selectionControls: selectionControls,
         onSubmitted: onSubmitted,
         scrollController: scrollController,
         scrollPhysics: scrollPhysics,
         autofillHints: autofillHints,
         clipBehavior: clipBehavior,
         prefixIcon: prefixIcon,
         backgroundColor: backgroundColor,
         borderRadius: borderRadius,
         border: border,
         focusedBorder: focusedBorder,
         enabledBorder: enabledBorder,
         contentPadding: contentPadding,
         labelStyle: labelStyle,
         header: header,
         footer: footer,
         clearable: clearable,
         clearIcon: clearIcon,
         mask: mask,
         maskMatch: maskMatch,
         maskedReturnValue: maskedReturnValue,
         decorator: decorator,
         stateName: stateName,
         passwordVisible: passwordVisible,
         passwordViewable: passwordViewable,
       );

  InputField.fromFieldStyleText({
    required Field field,
    FieldStyleTextField? style,
    FormValidator? formValidator,
    Function(String value)? onChanged,
  }) : this(
         field: field,
         labelText: field.name,
         stateName: field.stateKey,
         controller: TextEditingController(
           text: field.value?.toString() ?? field.dummyData ?? '',
         ),
         obscureText: style?.obscureText ?? false,
         autoFocus: field.autofocus || (style?.autoFocus ?? false),
         keyboardType: style?.keyboardType ?? TextInputType.text,
         textAlign: style?.textAlign,
         validateOnFocusChange: style?.validateOnFocusChange ?? false,
         maxLines: style?.maxLines ?? 1,
         minLines: style?.minLines,
         handleValidationError: style?.handleValidationError,
         enableSuggestions: style?.enableSuggestions ?? true,
         hintText: style?.hintText,
         hintStyle: style?.hintStyle,
         focusNode: style?.focusNode,
         formValidator: formValidator,
         dummyData: style?.dummyData,
         onChanged: onChanged,
         strutStyle: style?.strutStyle,
         textInputAction: style?.textInputAction,
         readOnly: style?.readOnly ?? false,
         showCursor: style?.showCursor,
         maxLength: style?.maxLength,
         enabled: style?.enabled ?? true,
         dragStartBehavior: style?.dragStartBehavior ?? DragStartBehavior.start,
         cursorHeight: style?.cursorHeight,
         cursorRadius: style?.cursorRadius,
         cursorColor: style?.cursorColor,
         onTap: style?.onTap,
         onTapOutside: style?.onTapOutside,
         mouseCursor: style?.mouseCursor,
         textCapitalization:
             style?.textCapitalization ?? TextCapitalization.none,
         maxLengthEnforcement:
             style?.maxLengthEnforcement ?? MaxLengthEnforcement.enforced,
         cursorWidth: style?.cursorWidth ?? 2.0,
         onAppPrivateCommand: style?.onAppPrivateCommand,
         inputFormatters: style?.inputFormatters ?? const [],
         expands: style?.expands ?? false,
         textAlignVertical: style?.textAlignVertical,
         textDirection: style?.textDirection,
         obscuringCharacter: style?.obscuringCharacter ?? '•',
         autocorrect: style?.autocorrect ?? true,
         smartDashesType: style?.smartDashesType,
         smartQuotesType: style?.smartQuotesType,
         decoration: style?.decoration,
         onEditingComplete: style?.onEditingComplete,
         keyboardAppearance: style?.keyboardAppearance,
         scrollPadding: style?.scrollPadding ?? const EdgeInsets.all(20.0),
         selectionControls: style?.selectionControls,
         onSubmitted: style?.onSubmitted,
         scrollController: style?.scrollController,
         scrollPhysics: style?.scrollPhysics,
         autofillHints: style?.autofillHints ?? const <String>[],
         clipBehavior: style?.clipBehavior ?? Clip.hardEdge,
         passwordVisible: style?.passwordVisible,
         passwordViewable: style?.passwordViewable,
         prefixIcon: style?.prefixIcon,
         backgroundColor: style?.backgroundColor,
         borderRadius: style?.borderRadius,
         border: style?.border,
         focusedBorder: style?.focusedBorder,
         enabledBorder: style?.enabledBorder,
         contentPadding: style?.contentPadding,
         labelStyle: style?.labelStyle,
         header: style?.header,
         footer: style?.footer,
         clearable: style?.clearable,
         clearIcon: style?.clearIcon,
         mask: style?.mask,
         maskMatch: style?.maskMatch,
         maskedReturnValue: style?.maskedReturnValue,
         decorator: style?.decorator,
       );

  /// Password Text Field - obscured by default with visibility toggle
  InputField.password({
    Key? key,
    required TextEditingController controller,
    String labelText = "Password",
    bool passwordVisible = true,
    bool obscureText = true,
    bool autoFocus = false,
    TextInputType keyboardType = TextInputType.text,
    TextAlign? textAlign,
    int maxLines = 1,
    bool validateOnFocusChange = false,
    Function(FormValidationResult handleError)? handleValidationError,
    int? minLines,
    bool enableSuggestions = true,
    String? hintText,
    TextStyle? hintStyle,
    FocusNode? focusNode,
    FormValidator? formValidator,
    String? dummyData,
    Function(String value)? onChanged,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextInputAction? textInputAction,
    bool readOnly = false,
    bool? showCursor,
    int? maxLength,
    bool? enabled,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    double? cursorHeight,
    Radius? cursorRadius,
    Color? cursorColor,
    GestureTapCallback? onTap,
    TapRegionCallback? onTapOutside,
    MouseCursor? mouseCursor,
    TextCapitalization textCapitalization = TextCapitalization.none,
    MaxLengthEnforcement? maxLengthEnforcement,
    double cursorWidth = 2.0,
    AppPrivateCommandCallback? onAppPrivateCommand,
    List<TextInputFormatter>? inputFormatters,
    bool expands = false,
    TextAlignVertical? textAlignVertical,
    TextDirection? textDirection,
    String obscuringCharacter = '•',
    bool autocorrect = true,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    InputDecoration? decoration,
    VoidCallback? onEditingComplete,
    Brightness? keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    TextSelectionControls? selectionControls,
    ValueChanged<String>? onSubmitted,
    ScrollController? scrollController,
    ScrollPhysics? scrollPhysics,
    bool? passwordViewable,
    Iterable<String>? autofillHints = const <String>[],
    Clip clipBehavior = Clip.hardEdge,
    Widget? prefixIcon,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    InputBorder? border,
    InputBorder? focusedBorder,
    InputBorder? enabledBorder,
    EdgeInsetsGeometry? contentPadding,
    TextStyle? labelStyle,
    Widget? header,
    Widget? footer,
    bool? clearable,
    Widget? clearIcon,
    String? mask,
    String? maskMatch,
    bool? maskedReturnValue,
    DecoratorTextField? decorator,
    String? stateName,
  }) : this(
         key: key,
         controller: controller,
         labelText: labelText,
         passwordVisible: passwordVisible,
         obscureText: obscureText,
         autoFocus: autoFocus,
         keyboardType: keyboardType,
         textAlign: textAlign,
         maxLines: maxLines,
         validateOnFocusChange: validateOnFocusChange,
         handleValidationError: handleValidationError,
         minLines: minLines,
         enableSuggestions: enableSuggestions,
         hintText: hintText,
         hintStyle: hintStyle,
         focusNode: focusNode,
         formValidator: formValidator,
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
         decoration: decoration,
         onEditingComplete: onEditingComplete,
         keyboardAppearance: keyboardAppearance,
         scrollPadding: scrollPadding,
         selectionControls: selectionControls,
         onSubmitted: onSubmitted,
         scrollController: scrollController,
         scrollPhysics: scrollPhysics,
         passwordViewable: passwordViewable,
         autofillHints: autofillHints,
         clipBehavior: clipBehavior,
         prefixIcon: prefixIcon,
         backgroundColor: backgroundColor,
         borderRadius: borderRadius,
         border: border,
         focusedBorder: focusedBorder,
         enabledBorder: enabledBorder,
         contentPadding: contentPadding,
         labelStyle: labelStyle,
         header: header,
         footer: footer,
         clearable: clearable,
         clearIcon: clearIcon,
         mask: mask,
         maskMatch: maskMatch,
         maskedReturnValue: maskedReturnValue,
         decorator: decorator,
         stateName: stateName,
       );

  /// Email Address Text Field - email keyboard with autofocus
  InputField.emailAddress({
    Key? key,
    required TextEditingController controller,
    String labelText = "Email Address",
    bool obscureText = false,
    bool autoFocus = true,
    TextInputType keyboardType = TextInputType.emailAddress,
    TextAlign? textAlign,
    bool validateOnFocusChange = false,
    int maxLines = 1,
    Function(FormValidationResult handleError)? handleValidationError,
    int? minLines,
    bool enableSuggestions = true,
    String? hintText,
    TextStyle? hintStyle,
    FocusNode? focusNode,
    FormValidator? formValidator,
    String? dummyData,
    Function(String value)? onChanged,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextInputAction? textInputAction,
    bool readOnly = false,
    bool? showCursor,
    int? maxLength,
    bool? enabled,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    double? cursorHeight,
    Radius? cursorRadius,
    Color? cursorColor,
    GestureTapCallback? onTap,
    TapRegionCallback? onTapOutside,
    MouseCursor? mouseCursor,
    TextCapitalization textCapitalization = TextCapitalization.none,
    MaxLengthEnforcement? maxLengthEnforcement,
    double cursorWidth = 2.0,
    AppPrivateCommandCallback? onAppPrivateCommand,
    List<TextInputFormatter>? inputFormatters,
    bool expands = false,
    TextAlignVertical? textAlignVertical,
    TextDirection? textDirection,
    String obscuringCharacter = '•',
    bool autocorrect = true,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    bool? passwordViewable,
    InputDecoration? decoration,
    VoidCallback? onEditingComplete,
    Brightness? keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    TextSelectionControls? selectionControls,
    ValueChanged<String>? onSubmitted,
    ScrollController? scrollController,
    ScrollPhysics? scrollPhysics,
    Iterable<String>? autofillHints = const <String>[],
    Clip clipBehavior = Clip.hardEdge,
    Widget? prefixIcon,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    InputBorder? border,
    InputBorder? focusedBorder,
    InputBorder? enabledBorder,
    EdgeInsetsGeometry? contentPadding,
    TextStyle? labelStyle,
    bool? passwordVisible,
    Widget? header,
    Widget? footer,
    bool? clearable,
    Widget? clearIcon,
    String? mask,
    String? maskMatch,
    bool? maskedReturnValue,
    DecoratorTextField? decorator,
    String? stateName,
  }) : this(
         key: key,
         controller: controller,
         labelText: labelText,
         obscureText: obscureText,
         autoFocus: autoFocus,
         keyboardType: keyboardType,
         textAlign: textAlign,
         validateOnFocusChange: validateOnFocusChange,
         maxLines: maxLines,
         handleValidationError: handleValidationError,
         minLines: minLines,
         enableSuggestions: enableSuggestions,
         hintText: hintText,
         hintStyle: hintStyle,
         focusNode: focusNode,
         formValidator: formValidator,
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
         passwordViewable: passwordViewable,
         decoration: decoration,
         onEditingComplete: onEditingComplete,
         keyboardAppearance: keyboardAppearance,
         scrollPadding: scrollPadding,
         selectionControls: selectionControls,
         onSubmitted: onSubmitted,
         scrollController: scrollController,
         scrollPhysics: scrollPhysics,
         autofillHints: autofillHints,
         clipBehavior: clipBehavior,
         prefixIcon: prefixIcon,
         backgroundColor: backgroundColor,
         borderRadius: borderRadius,
         border: border,
         focusedBorder: focusedBorder,
         enabledBorder: enabledBorder,
         contentPadding: contentPadding,
         labelStyle: labelStyle,
         passwordVisible: passwordVisible,
         header: header,
         footer: footer,
         clearable: clearable,
         clearIcon: clearIcon,
         mask: mask,
         maskMatch: maskMatch,
         maskedReturnValue: maskedReturnValue,
         decorator: decorator,
         stateName: stateName,
       );

  /// Copy with method
  InputField copyWith({
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
    FormValidator? formValidator,
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
    return InputField(
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
      formValidator: formValidator ?? this.formValidator,
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
      passwordVisible: passwordVisible ?? this.passwordVisible,
      prefixIcon: prefixIcon ?? this.prefixIcon,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      focusedBorder: focusedBorder ?? this.focusedBorder,
      enabledBorder: enabledBorder ?? this.enabledBorder,
      contentPadding: contentPadding ?? this.contentPadding,
      header: header ?? this.header,
      footer: footer ?? this.footer,
      clearable: clearable ?? this.clearable,
      clearIcon: clearIcon ?? this.clearIcon,
      mask: mask ?? this.mask,
      maskMatch: maskMatch ?? this.maskMatch,
      maskedReturnValue: maskedReturnValue ?? this.maskedReturnValue,
      decorator: decorator ?? this.decorator,
    );
  }

  InputField merge(InputDecoration decoration) {
    return InputField(
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
      formValidator: formValidator,
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
        suffixIconConstraints:
            decoration.suffixIconConstraints ??
            this.decoration?.suffixIconConstraints,
        prefixIconConstraints:
            decoration.prefixIconConstraints ??
            this.decoration?.prefixIconConstraints,
        counter: decoration.counter ?? this.decoration?.counter,
        counterText: decoration.counterText ?? this.decoration?.counterText,
        counterStyle: decoration.counterStyle ?? this.decoration?.counterStyle,
        focusColor: decoration.focusColor ?? this.decoration?.focusColor,
        hoverColor: decoration.hoverColor ?? this.decoration?.hoverColor,
        errorBorder: decoration.errorBorder ?? this.decoration?.errorBorder,
        focusedErrorBorder:
            decoration.focusedErrorBorder ??
            this.decoration?.focusedErrorBorder,
        disabledBorder:
            decoration.disabledBorder ?? this.decoration?.disabledBorder,
        enabled: enabled ?? enabled,
        semanticCounterText:
            decoration.semanticCounterText ??
            this.decoration?.semanticCounterText,
        alignLabelWithHint:
            decoration.alignLabelWithHint ??
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
      prefixIcon: prefixIcon,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      border: border,
      focusedBorder: focusedBorder,
      enabledBorder: enabledBorder,
      contentPadding: contentPadding,
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
  createState() => _InputFieldState(stateName);

  /// StateActions for the text field
  static TextFieldStateActions stateActions(String stateName) =>
      TextFieldStateActions(stateName);
}

/// Provides state management actions for [InputField] widgets.
///
/// Extends [FormStateActions] to provide text field-specific operations.
class TextFieldStateActions extends FormStateActions {
  TextFieldStateActions(super.state);
}

class _InputFieldState extends NyState<InputField> {
  final FocusNode _focus = FocusNode();
  bool? didChange = false;
  bool _obscured = false;
  bool _passedValidation = false;
  TextInputFormatter? maskTextInputFormatter;

  _InputFieldState(String? stateName) {
    if (stateName != null) {
      this.stateName = stateName;
    }
  }

  @override
  Map<String, Function> get stateActions => {
    "clear": () {
      widget.controller.clear();
      setState(() {});
    },
    "setValue": (data) {
      final value = data["value"];
      widget.controller.text = value?.toString() ?? "";
      setState(() {});
    },
  };

  @override
  void initState() {
    super.initState();

    // Initialize obscured state - true if password field or explicitly set
    _obscured = widget.obscureText || widget.passwordVisible == true;
    _focus.addListener(_onFocusChange);
    // check if widget.inputFormatters has MaskTextInputFormatter
    maskTextInputFormatter = (widget.inputFormatters ?? []).firstWhereOrNull(
      (inputFormatter) => inputFormatter is MaskTextInputFormatter,
    );

    if (widget.mask != null) {
      assert(
        widget.maskMatch != null,
        "maskMatch is required when mask is provided",
      );
      maskTextInputFormatter = MaskTextInputFormatter(
        mask: widget.mask!,
        filter: {"#": RegExp(widget.maskMatch!)},
      );
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    super.dispose();
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
    setState(() {
      _obscured = !_obscured;
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
    if (widget.field != null) {
      return widget.field!.value?.toString() ?? "";
    }
    return widget.controller.text;
  }

  /// validate the users input
  String? _validate() {
    if (didChange == false) return null;

    if (widget.formValidator != null) {
      widget.formValidator?.setAttribute(widget.labelText);
      FormValidationResult? response = widget.formValidator?.check(
        controllerValue,
      );

      if (response?.isValid == false) {
        return response?.getFirstErrorMessage();
      }

      return null;
    }
    return null;
  }

  @override
  Widget view(BuildContext context) {
    InputDecoration decoration = InputDecoration(
      labelText: widget.decoration?.labelText ?? widget.labelText?.tr(),
      labelStyle:
          widget.decoration?.labelStyle ??
          widget.labelStyle ??
          const TextStyle(fontSize: 16, color: Colors.black),
      hintText: widget.decoration?.hintText ?? widget.hintText,
      hintStyle: widget.decoration?.hintStyle ?? widget.hintStyle,
      errorStyle:
          widget.decoration?.errorStyle ?? const TextStyle(fontSize: 12),
      errorMaxLines: widget.decoration?.errorMaxLines ?? 2,
      filled: widget.decoration?.filled ?? true,
      fillColor:
          widget.decoration?.fillColor ??
          widget.backgroundColor ??
          Colors.grey.shade100,
      isDense: widget.decoration?.isDense ?? true,
      focusedBorder:
          widget.decoration?.focusedBorder ??
          widget.focusedBorder ??
          OutlineInputBorder(
            borderRadius:
                widget.borderRadius ??
                const BorderRadius.all(Radius.circular(12)),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
      enabledBorder:
          widget.decoration?.enabledBorder ??
          widget.enabledBorder ??
          OutlineInputBorder(
            borderRadius:
                widget.borderRadius ??
                const BorderRadius.all(Radius.circular(12)),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
      contentPadding:
          widget.decoration?.contentPadding ??
          widget.contentPadding ??
          const EdgeInsetsDirectional.symmetric(vertical: 13, horizontal: 13),
      border:
          widget.decoration?.border ??
          widget.border ??
          OutlineInputBorder(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            borderSide: const BorderSide(width: 0, style: BorderStyle.none),
          ),
    );

    if (widget.backgroundColor != null) {
      decoration = decoration.copyWith(
        filled: true,
        fillColor: widget.backgroundColor,
      );
    }

    if (widget.passwordVisible == true || widget.passwordViewable == true) {
      decoration = decoration.copyWith(
        suffixIcon: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
          child: GestureDetector(
            onTap: _toggleObscured,
            child: Icon(
              _obscured
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
      decoration = decoration.copyWith(labelText: widget.labelText);
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
      InputDecoration? baseDecoration = widget.decorator?.decoration!(
        controllerValue,
        decoration,
      );
      if (baseDecoration != null) {
        decoration = baseDecoration;
      }
    }

    if (_passedValidation == true &&
        widget.decorator?.successDecoration != null) {
      InputDecoration? successDecoration = widget.decorator?.successDecoration!(
        controllerValue,
        decoration,
      );
      if (successDecoration != null) {
        decoration = successDecoration;
      }
    }

    if (_passedValidation == false &&
        widget.decorator?.errorDecoration != null) {
      InputDecoration? errorDecoration = widget.decorator?.errorDecoration!(
        controllerValue,
        decoration,
      );
      if (errorDecoration != null) {
        decoration = errorDecoration;
      }
    }

    decoration = decoration.copyWith(errorText: validate);

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
      obscureText: _obscured,
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
            const Spacing.vertical(5),
          ],
          textField,
          if (widget.footer != null) ...[
            widget.footer!,
            const Spacing.vertical(5),
          ],
        ],
      );
    }
    return textField;
  }
}
