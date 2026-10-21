import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '/widgets/ny_widgets.dart';
import '/localization/ny_localization.dart';

/// Vertical position of an [InputField]'s prefix icon in a multi-line field.
///
/// [SuffixIconAlignment] places the suffix icon the same way.
enum PrefixIconAlignment {
  /// Centered on the field's height (Flutter's default).
  center,

  /// Lined up with the first line of text.
  top,
}

/// Vertical position of an [InputField]'s suffix icon in a multi-line field.
typedef SuffixIconAlignment = PrefixIconAlignment;

/// Nylo's Text Field Widget
class InputField extends StatefulWidget {
  /// Number of times any [InputField] has built, in debug mode only.
  ///
  /// Tests reset this and read it back to prove that typing does not rebuild
  /// the field unless the shown validation error changes.
  @visibleForTesting
  static int debugBuildCount = 0;

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

  /// Validates the field's current value. See [FormValidator] for the three
  /// supported patterns (named constructor, chainable API, or explicit rule
  /// list). The first failing rule's message renders as the field's error text.
  final FormValidator? formValidator;

  /// Closure-based validator. Receives a fresh [FormValidator] and the
  /// current field value; register rules via
  /// `validate.that(data, attribute).<rule>()`.
  ///
  /// Mutually exclusive with [formValidator] — set one or the other.
  ///
  /// ```dart
  /// InputField(
  ///   controller: _controller,
  ///   labelText: "Username",
  ///   validate: (validate, data) {
  ///     validate.that(data, "Username").minLength(3);
  ///   },
  /// )
  /// ```
  final FormValidatorCallback? validate;
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

  /// Where [prefixIcon] sits vertically in a multi-line field.
  ///
  /// Use [PrefixIconAlignment.top] to line the icon up with the first line
  /// of text in a text area, e.g.
  /// `InputField(maxLines: 5, prefixIcon: Icon(Icons.notes), prefixIconAlignment: PrefixIconAlignment.top)`
  final PrefixIconAlignment prefixIconAlignment;
  final Widget? suffixIcon;

  /// Where [suffixIcon] sits vertically in a multi-line field.
  ///
  /// Use [SuffixIconAlignment.top] to line the icon up with the first line
  /// of text in a text area, e.g.
  /// `InputField(maxLines: 5, suffixIcon: Icon(Icons.send), suffixIconAlignment: SuffixIconAlignment.top)`
  final SuffixIconAlignment suffixIconAlignment;
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
  final bool enableInteractiveSelection;
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
    this.validate,
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
    this.prefixIconAlignment = PrefixIconAlignment.center,
    this.suffixIcon,
    this.suffixIconAlignment = SuffixIconAlignment.center,
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
    this.enableInteractiveSelection = true,
  }) : assert(
         formValidator == null || validate == null,
         'Provide either formValidator or validate, not both.',
       );

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
    FormValidatorCallback? validate,
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
    PrefixIconAlignment prefixIconAlignment = PrefixIconAlignment.center,
    Widget? suffixIcon,
    SuffixIconAlignment suffixIconAlignment = SuffixIconAlignment.center,
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
    bool enableInteractiveSelection = true,
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
         validate: validate,
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
         prefixIconAlignment: prefixIconAlignment,
         suffixIcon: suffixIcon,
         suffixIconAlignment: suffixIconAlignment,
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
         enableInteractiveSelection: enableInteractiveSelection,
       );

  InputField.fromFieldStyleText({
    Key? key,
    required Field field,
    FieldStyleTextField? style,
    FormValidator? formValidator,
    FormValidatorCallback? validate,
    Function(String value)? onChanged,
  }) : this(
         key: key,
         field: field,
         labelText: field.name,
         stateName: field.stateKey,
         controller: TextEditingController(
           text: _formatInitialText(
             field.value?.toString() ?? field.dummyData ?? '',
             style?.inputFormatters,
           ),
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
         validate: validate,
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
         prefixIconAlignment:
             style?.prefixIconAlignment ?? PrefixIconAlignment.center,
         suffixIcon: style?.suffixIcon,
         suffixIconAlignment:
             style?.suffixIconAlignment ?? SuffixIconAlignment.center,
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
         enableInteractiveSelection: style?.enableInteractiveSelection ?? true,
       );

  /// Password Text Field - obscured by default with visibility toggle
  const InputField.password({
    Key? key,
    required TextEditingController controller,
    String labelText = "nylo.input_field.password",
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
    FormValidatorCallback? validate,
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
    Widget? suffixIcon,
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
    bool enableInteractiveSelection = true,
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
         validate: validate,
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
         suffixIcon: suffixIcon,
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
         enableInteractiveSelection: enableInteractiveSelection,
       );

  /// Email Address Text Field - email keyboard with autofocus
  const InputField.emailAddress({
    Key? key,
    required TextEditingController controller,
    String labelText = "nylo.input_field.email_address",
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
    FormValidatorCallback? validate,
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
    Widget? suffixIcon,
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
    bool enableInteractiveSelection = true,
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
         validate: validate,
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
         suffixIcon: suffixIcon,
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
         enableInteractiveSelection: enableInteractiveSelection,
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
    FormValidatorCallback? validate,
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
    PrefixIconAlignment? prefixIconAlignment,
    Widget? suffixIcon,
    SuffixIconAlignment? suffixIconAlignment,
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
    bool? enableInteractiveSelection,
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
      validate: validate ?? this.validate,
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
      prefixIconAlignment: prefixIconAlignment ?? this.prefixIconAlignment,
      suffixIcon: suffixIcon ?? this.suffixIcon,
      suffixIconAlignment: suffixIconAlignment ?? this.suffixIconAlignment,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      focusedBorder: focusedBorder ?? this.focusedBorder,
      enabledBorder: enabledBorder ?? this.enabledBorder,
      contentPadding: contentPadding ?? this.contentPadding,
      header: header ?? header,
      footer: footer ?? footer,
      clearable: clearable ?? this.clearable,
      clearIcon: clearIcon ?? this.clearIcon,
      mask: mask ?? this.mask,
      maskMatch: maskMatch ?? this.maskMatch,
      maskedReturnValue: maskedReturnValue ?? this.maskedReturnValue,
      decorator: decorator ?? this.decorator,
      enableInteractiveSelection:
          enableInteractiveSelection ?? this.enableInteractiveSelection,
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
      validate: validate,
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
      prefixIconAlignment: prefixIconAlignment,
      suffixIcon: suffixIcon,
      suffixIconAlignment: suffixIconAlignment,
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
      enableInteractiveSelection: enableInteractiveSelection,
    );
  }

  @override
  // ignore: no_logic_in_create_state
  createState() => _InputFieldState(stateName);

  /// Applies input formatters to initial text so programmatic values
  /// (e.g. currency from [define]) display formatted, not raw.
  static String _formatInitialText(
    String text,
    List<TextInputFormatter>? formatters,
  ) {
    if (text.isEmpty || formatters == null || formatters.isEmpty) return text;
    for (final TextInputFormatter formatter in formatters) {
      text = formatter
          .formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(text: text),
          )
          .text;
    }
    return text;
  }

  /// StateActions for the text field
  static TextFieldStateActions stateActions(String stateName) =>
      TextFieldStateActions(stateName);
}

/// State actions for [InputField].
///
/// Example usage:
/// ```dart
/// InputField.stateActions("my_field").clear();
/// InputField.stateActions("my_field").setValue("Hello");
/// InputField.stateActions("my_field").focus();
/// InputField.stateActions("my_field").unfocus();
/// InputField.stateActions("my_field").toggleObscure();
/// ```
class TextFieldStateActions extends FormStateActions {
  TextFieldStateActions(super.state);

  /// Request focus on the text field.
  void focus() {
    action("focus");
  }

  /// Remove focus from the text field.
  void unfocus() {
    action("unfocus");
  }

  /// Toggle password visibility.
  void toggleObscure() {
    action("toggleObscure");
  }
}

class _InputFieldState extends NyState<InputField> {
  final FocusNode _focus = FocusNode();

  /// The focus node [_onFocusChange] is currently attached to. This is
  /// [InputField.focusNode] when the caller supplied one, otherwise [_focus].
  FocusNode? _listenedFocusNode;

  /// The validation error currently shown under the field. It is recomputed
  /// on each keystroke and focus change (see [_revalidate]) rather than on
  /// every build, so [view] only reads it.
  String? _errorText;
  bool? didChange = false;
  bool _obscured = false;
  final bool _passedValidation = false;
  TextInputFormatter? maskTextInputFormatter;
  String? _lastErrorMessage;
  bool _hasReportedFirstResult = false;

  _InputFieldState(String? stateName) {
    if (stateName != null) {
      this.stateName = stateName;
    }
  }

  @override
  Map<String, Function> get stateActions => {
    "clear": () {
      widget.controller.clear();
      setState(() {
        _errorText = _validate();
      });
    },
    "setValue": (data) {
      final dynamic value = data["value"];
      String text = value?.toString() ?? "";
      for (final TextInputFormatter formatter
          in widget.inputFormatters ?? const <TextInputFormatter>[]) {
        text = formatter
            .formatEditUpdate(
              TextEditingValue.empty,
              TextEditingValue(text: text),
            )
            .text;
      }
      widget.controller.text = text;
      setState(() {
        _errorText = _validate();
      });
    },
    "focus": (_) {
      _effectiveFocusNode.requestFocus();
    },
    "unfocus": (_) {
      _effectiveFocusNode.unfocus();
    },
    "toggleObscure": (_) {
      _toggleObscured();
    },
  };

  @override
  void initState() {
    super.initState();

    // Initialize obscured state - true if password field or explicitly set
    _obscured = widget.obscureText || widget.passwordVisible == true;
    _attachFocusListener();
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
  void didUpdateWidget(covariant InputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_effectiveFocusNode != _listenedFocusNode) {
      _attachFocusListener();
    }
    _errorText = _validate();
  }

  @override
  void dispose() {
    _listenedFocusNode?.removeListener(_onFocusChange);
    _listenedFocusNode = null;

    _focus.dispose();
    super.dispose();
  }

  /// The focus node driving this field: the caller's, or our own.
  FocusNode get _effectiveFocusNode => widget.focusNode ?? _focus;

  /// (Re)attach [_onFocusChange] to [_effectiveFocusNode].
  void _attachFocusListener() {
    _listenedFocusNode?.removeListener(_onFocusChange);
    _listenedFocusNode = _effectiveFocusNode;
    _listenedFocusNode!.addListener(_onFocusChange);
  }

  /// handle focus change
  void _onFocusChange() {
    if (_effectiveFocusNode.hasFocus == true) {
      didChange = !(widget.validateOnFocusChange ?? false);
    } else {
      didChange = true;
      _revalidate();
    }
  }

  /// Recompute [_errorText] and rebuild only if the shown error changed.
  void _revalidate() {
    final String? next = _validate();
    if (next == _errorText && widget.decorator == null) return;
    if (!mounted) return;
    setState(() {
      _errorText = next;
    });
  }

  /// toggle obscured text
  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
      final FocusNode focus = _effectiveFocusNode;
      if (focus.hasPrimaryFocus) return;
      focus.canRequestFocus = false;
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

    FormValidator? validator;
    if (widget.validate != null) {
      validator = FormValidator(attribute: widget.labelText);
      widget.validate!(validator, controllerValue);
    } else if (widget.formValidator != null) {
      validator = widget.formValidator!;
      validator.setAttribute(widget.labelText);
    }

    if (validator == null) return null;

    final FormValidationResult result = validator.check(controllerValue);
    final String? errorMessage = result.isValid
        ? null
        : result.getFirstErrorMessage();

    _reportValidationResult(result, errorMessage);

    return errorMessage;
  }

  /// Notify [InputField.handleValidationError] on result transitions, deferred
  /// to the next frame so callers can safely call `setState` from inside it.
  void _reportValidationResult(FormValidationResult result, String? message) {
    final Function(FormValidationResult handleError)? handler =
        widget.handleValidationError;
    if (handler == null) return;

    final bool changed =
        !_hasReportedFirstResult || message != _lastErrorMessage;
    if (!changed) return;

    _lastErrorMessage = message;
    _hasReportedFirstResult = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      handler(result);
    });
  }

  @override
  Widget view(BuildContext context) {
    assert(() {
      InputField.debugBuildCount++;
      return true;
    }());

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
      // Flutter only floats the label back over a prefix icon, in line with
      // other fields, when alignLabelWithHint is off.
      alignLabelWithHint:
          widget.decoration?.alignLabelWithHint ??
          ((widget.maxLines != null &&
                  widget.maxLines! > 1 &&
                  widget.prefixIcon == null)
              ? true
              : null),
    );

    if (widget.backgroundColor != null) {
      decoration = decoration.copyWith(
        filled: true,
        fillColor: widget.backgroundColor,
      );
    }

    if (widget.passwordVisible == true || widget.passwordViewable == true) {
      decoration = decoration.copyWith(
        suffixIcon: IconButton(
          onPressed: _toggleObscured,
          tooltip:
              (_obscured
                      ? "nylo.input_field.show_password"
                      : "nylo.input_field.hide_password")
                  .tr(),
          icon: Icon(
            _obscured ? Icons.visibility_rounded : Icons.visibility_off_rounded,
            size: 24,
          ),
        ),
      );
    }

    if (widget.prefixIcon != null) {
      decoration = decoration.copyWith(
        prefixIcon: widget.prefixIcon,
        prefixIconConstraints: widget.decoration?.prefixIconConstraints,
      );
    }

    if (widget.suffixIcon != null && widget.passwordViewable != true) {
      decoration = decoration.copyWith(
        suffixIcon: widget.suffixIcon,
        suffixIconConstraints: widget.decoration?.suffixIconConstraints,
      );
    }

    if (widget.labelText != null) {
      decoration = decoration.copyWith(labelText: widget.labelText!.tr());
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

    decoration = decoration.copyWith(errorText: _errorText);

    // Flutter always centers prefix and suffix icons on the field's height. To
    // pin one to the first line, the decorator gets an invisible copy, so
    // text, label and border gap lay out as usual, and the real icon is drawn
    // over the top.
    final bool multiLine = widget.maxLines != 1;
    final Widget? topPrefixIcon =
        widget.prefixIconAlignment == PrefixIconAlignment.top &&
            multiLine &&
            decoration.icon == null
        ? decoration.prefixIcon
        : null;
    final Widget? topSuffixIcon =
        widget.suffixIconAlignment == SuffixIconAlignment.top && multiLine
        ? decoration.suffixIcon
        : null;
    if (topPrefixIcon != null) {
      decoration = decoration.copyWith(prefixIcon: _hidden(topPrefixIcon));
    }
    if (topSuffixIcon != null) {
      decoration = decoration.copyWith(suffixIcon: _hidden(topSuffixIcon));
    }

    // A label beside a top-aligned prefix icon rests on the first line too.
    // Flutter only rests it there with alignLabelWithHint, which floats it out
    // of line with other fields, so a one-line copy of the decorator draws the
    // label. The field keeps its own label, transparent, for the border gap
    // and semantics.
    final Widget? topLabel =
        topPrefixIcon != null &&
            decoration.alignLabelWithHint != true &&
            (decoration.labelText != null || decoration.label != null)
        ? _topLabel(decoration)
        : null;
    if (topLabel != null) {
      decoration = decoration.copyWith(
        labelStyle: _transparent(decoration.labelStyle),
        floatingLabelStyle: _transparent(
          decoration.floatingLabelStyle ?? decoration.labelStyle,
        ),
      );
    }

    // TextField
    Widget textField = TextField(
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
      focusNode: _effectiveFocusNode,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      onChanged: (String value) {
        // Notify first so a bound [Field] holds the new value before the
        // validator reads [controllerValue].
        final Function(String value)? onChanged = widget.onChanged;
        if (onChanged != null) {
          onChanged(maskTextInputFormatter != null ? controllerValue : value);
        }
        _revalidate();
      },
      textInputAction: widget.textInputAction,
      style: widget.style,
      strutStyle: widget.strutStyle,
      textAlignVertical:
          widget.textAlignVertical ??
          ((widget.maxLines != null && widget.maxLines! > 1)
              ? TextAlignVertical.top
              : null),
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
      enableInteractiveSelection: widget.enableInteractiveSelection,
    );

    if (topPrefixIcon != null || topSuffixIcon != null) {
      textField = Stack(
        // An outlined field floats its label over its top edge.
        clipBehavior: Clip.none,
        children: [
          textField,
          if (topLabel != null)
            Positioned(top: 0, left: 0, right: 0, child: topLabel),
          if (topPrefixIcon != null)
            PositionedDirectional(
              start: 0,
              top: 0,
              child: _topIcon(decoration, prefixIcon: topPrefixIcon),
            ),
          if (topSuffixIcon != null)
            PositionedDirectional(
              end: 0,
              top: 0,
              child: _topIcon(decoration, suffixIcon: topSuffixIcon),
            ),
        ],
      );
    }

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

  /// [child] laid out at its size, but not shown or hit-testable.
  static Widget _hidden(Widget child) => Visibility(
    visible: false,
    maintainSize: true,
    maintainAnimation: true,
    maintainState: true,
    child: child,
  );

  /// [style] drawn transparent, keeping its size and its response to the
  /// field's state.
  static TextStyle _transparent(TextStyle? style) {
    return WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
      final TextStyle resolved =
          WidgetStateProperty.resolveAs<TextStyle?>(style, states) ??
          const TextStyle();
      return resolved.foreground == null
          ? resolved.copyWith(color: Colors.transparent)
          : resolved.copyWith(foreground: Paint()..color = Colors.transparent);
    });
  }

  /// The style [TextField] gives its text, which sets a line's height.
  TextStyle get _textStyle {
    final ThemeData theme = Theme.of(context);
    return (theme.useMaterial3
            ? theme.textTheme.bodyLarge
            : theme.textTheme.titleMedium)!
        .merge(widget.style);
  }

  bool _hasError(InputDecoration decoration) =>
      decoration.errorText != null || decoration.error != null;

  /// [prefixIcon] or [suffixIcon] for [PrefixIconAlignment.top], themed the
  /// way [InputDecorator] themes it by rendering it in an otherwise empty
  /// decorator.
  ///
  /// The decorator is one line of text tall, so the icon sits where it would
  /// in a single-line field. Tapping it focuses the field, as tapping a
  /// centered icon does.
  Widget _topIcon(
    InputDecoration decoration, {
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    final EdgeInsets padding =
        decoration.contentPadding?.resolve(Directionality.of(context)) ??
        EdgeInsets.zero;

    return GestureDetector(
      onTap: decoration.enabled ? _effectiveFocusNode.requestFocus : null,
      child: ListenableBuilder(
        listenable: _effectiveFocusNode,
        // A decorator needs a bounded width; size it to the icon alone.
        builder: (context, _) => IntrinsicWidth(
          child: InputDecorator(
            isFocused: _effectiveFocusNode.hasFocus,
            decoration: InputDecoration(
              prefixIcon: prefixIcon,
              prefixIconColor: decoration.prefixIconColor,
              prefixIconConstraints: decoration.prefixIconConstraints,
              suffixIcon: suffixIcon,
              suffixIconColor: decoration.suffixIconColor,
              suffixIconConstraints: decoration.suffixIconConstraints,
              isDense: decoration.isDense,
              enabled: decoration.enabled,
              // Themes the icon in the error colour, as the field does.
              error: _hasError(decoration) ? const SizedBox.shrink() : null,
              contentPadding: EdgeInsets.only(
                top: padding.top,
                bottom: padding.bottom,
              ),
              constraints: const BoxConstraints(),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
            ),
            child: Text('', style: _textStyle, strutStyle: widget.strutStyle),
          ),
        ),
      ),
    );
  }

  /// The label of a field with a top-aligned prefix icon, drawn by a
  /// one-line copy of the field's decorator.
  ///
  /// It rests on the first line, where a single-line field's label does, and
  /// floats to the same place as the field's own label, since the copy has
  /// the same width, icons, padding and kind of border.
  Widget _topLabel(InputDecoration decoration) {
    InputBorder? clear(InputBorder? border) => border?.copyWith(
      borderSide: border.borderSide.copyWith(color: Colors.transparent),
    );
    final InputDecorationThemeData theme = Theme.of(
      context,
    ).inputDecorationTheme;
    final InputBorder border =
        clear(decoration.border ?? theme.border) ??
        const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        );
    final TextAlign textAlign = widget.textAlign ?? TextAlign.left;

    return IgnorePointer(
      child: ExcludeSemantics(
        child: ListenableBuilder(
          listenable: Listenable.merge([
            _effectiveFocusNode,
            widget.controller,
          ]),
          builder: (context, _) => InputDecorator(
            isFocused: _effectiveFocusNode.hasFocus,
            isEmpty: widget.controller.text.isEmpty,
            baseStyle: _textStyle,
            textAlign: textAlign,
            decoration: InputDecoration(
              label:
                  decoration.label ??
                  _LabelText(decoration.labelText!, textAlign: textAlign),
              labelStyle: decoration.labelStyle,
              floatingLabelStyle: decoration.floatingLabelStyle,
              floatingLabelBehavior: decoration.floatingLabelBehavior,
              floatingLabelAlignment: decoration.floatingLabelAlignment,
              prefixIcon: decoration.prefixIcon,
              prefixIconConstraints: decoration.prefixIconConstraints,
              suffixIcon: decoration.suffixIcon == null
                  ? null
                  : _hidden(decoration.suffixIcon!),
              suffixIconConstraints: decoration.suffixIconConstraints,
              isDense: decoration.isDense,
              enabled: widget.enabled ?? decoration.enabled,
              // Colours the label for an error without repeating its text.
              error: _hasError(decoration) ? const SizedBox.shrink() : null,
              errorStyle: decoration.errorStyle,
              contentPadding: decoration.contentPadding,
              constraints: const BoxConstraints(),
              filled: false,
              border: border,
              enabledBorder:
                  clear(decoration.enabledBorder ?? theme.enabledBorder) ??
                  border,
              focusedBorder:
                  clear(decoration.focusedBorder ?? theme.focusedBorder) ??
                  border,
              disabledBorder:
                  clear(decoration.disabledBorder ?? theme.disabledBorder) ??
                  border,
              errorBorder:
                  clear(decoration.errorBorder ?? theme.errorBorder) ?? border,
              focusedErrorBorder:
                  clear(
                    decoration.focusedErrorBorder ?? theme.focusedErrorBorder,
                  ) ??
                  border,
            ),
            child: Text('', style: _textStyle, strutStyle: widget.strutStyle),
          ),
        ),
      ),
    );
  }
}

/// A label drawn the way [InputDecorator] draws [InputDecoration.labelText].
///
/// Built on [RichText] so `find.text` still finds the field's own label once.
class _LabelText extends StatelessWidget {
  const _LabelText(this.text, {required this.textAlign});

  final String text;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultStyle = DefaultTextStyle.of(context);
    TextStyle style = defaultStyle.style;
    if (MediaQuery.boldTextOf(context)) {
      style = style.merge(const TextStyle(fontWeight: FontWeight.bold));
    }
    return RichText(
      text: TextSpan(text: text, style: style),
      textAlign: textAlign,
      softWrap: defaultStyle.softWrap,
      overflow: TextOverflow.ellipsis,
      maxLines: defaultStyle.maxLines,
      textScaler: MediaQuery.textScalerOf(context),
      textWidthBasis: defaultStyle.textWidthBasis,
      textHeightBehavior:
          defaultStyle.textHeightBehavior ??
          DefaultTextHeightBehavior.maybeOf(context),
    );
  }
}
