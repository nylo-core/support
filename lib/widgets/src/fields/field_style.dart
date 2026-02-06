import 'package:date_field/date_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import '/widgets/ny_widgets.dart';

/// Base class for defining styling options for form fields.
///
/// Provides common spacing properties that can be inherited by specific field styles.
/// Use [headerSpacing] and [footerSpacing] to control the vertical spacing around fields.
class FieldStyle {
  FieldStyle({this.headerSpacing = 5.0, this.footerSpacing = 5.0});

  double? headerSpacing;
  double? footerSpacing;

  FieldStyle? copyWith({double? headerSpacing, double? footerSpacing}) {
    return FieldStyle(
      headerSpacing: headerSpacing ?? this.headerSpacing,
      footerSpacing: footerSpacing ?? this.footerSpacing,
    );
  }
}

/// Style configuration for date and time picker fields.
///
/// Extends [FieldStyle] with date/time specific styling options including
/// platform-specific picker configurations, date formatting, and picker modes.
/// Supports both Material and Cupertino design systems.
class FieldStyleDateTimePicker extends FieldStyle {
  FieldStyleDateTimePicker({
    this.style,
    this.onTap,
    this.focusNode,
    this.autofocus = false,
    this.enableFeedback,
    this.padding,
    this.hideDefaultSuffixIcon = false,
    this.initialPickerDateTime,
    this.cupertinoDatePickerOptions,
    this.materialDatePickerOptions,
    this.materialTimePickerOptions,
    this.decoration,
    this.dateFormat,
    this.firstDate,
    this.lastDate,
    this.mode = DateTimeFieldPickerMode.dateAndTime,
    this.pickerPlatform = DateTimeFieldPickerPlatform.adaptive,
  });

  TextStyle? style;
  VoidCallback? onTap;
  FocusNode? focusNode;
  bool autofocus;
  bool? enableFeedback;
  EdgeInsetsGeometry? padding;
  bool hideDefaultSuffixIcon;
  DateTime? initialPickerDateTime;
  CupertinoDatePickerOptions? cupertinoDatePickerOptions;
  MaterialDatePickerOptions? materialDatePickerOptions;
  MaterialTimePickerOptions? materialTimePickerOptions;
  InputDecoration? decoration;
  intl.DateFormat? dateFormat;
  DateTime? firstDate;
  DateTime? lastDate;
  DateTimeFieldPickerMode mode = DateTimeFieldPickerMode.dateAndTime;
  DateTimeFieldPickerPlatform pickerPlatform =
      DateTimeFieldPickerPlatform.adaptive;

  @override
  FieldStyleDateTimePicker copyWith({
    TextStyle? style,
    VoidCallback? onTap,
    FocusNode? focusNode,
    bool? autofocus,
    bool? enableFeedback,
    EdgeInsetsGeometry? padding,
    bool? hideDefaultSuffixIcon,
    DateTime? initialPickerDateTime,
    CupertinoDatePickerOptions? cupertinoDatePickerOptions,
    MaterialDatePickerOptions? materialDatePickerOptions,
    MaterialTimePickerOptions? materialTimePickerOptions,
    InputDecoration? decoration,
    intl.DateFormat? dateFormat,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTimeFieldPickerMode? mode,
    DateTimeFieldPickerPlatform? pickerPlatform,
    double? footerSpacing,
    double? headerSpacing,
  }) {
    return FieldStyleDateTimePicker(
      style: style ?? this.style,
      onTap: onTap ?? this.onTap,
      focusNode: focusNode ?? this.focusNode,
      autofocus: autofocus ?? this.autofocus,
      enableFeedback: enableFeedback ?? this.enableFeedback,
      padding: padding ?? this.padding,
      hideDefaultSuffixIcon:
          hideDefaultSuffixIcon ?? this.hideDefaultSuffixIcon,
      initialPickerDateTime:
          initialPickerDateTime ?? this.initialPickerDateTime,
      cupertinoDatePickerOptions:
          cupertinoDatePickerOptions ?? this.cupertinoDatePickerOptions,
      materialDatePickerOptions:
          materialDatePickerOptions ?? this.materialDatePickerOptions,
      materialTimePickerOptions:
          materialTimePickerOptions ?? this.materialTimePickerOptions,
      decoration: decoration ?? this.decoration,
      dateFormat: dateFormat ?? this.dateFormat,
      firstDate: firstDate ?? this.firstDate,
      lastDate: lastDate ?? this.lastDate,
      mode: mode ?? this.mode,
      pickerPlatform: pickerPlatform ?? this.pickerPlatform,
    );
  }
}

/// Style configuration for chip-based selection fields.
///
/// Provides styling options for chip widgets including colors, borders, text styles,
/// and spacing. Supports both selected and unselected states with customizable
/// visual appearance for each state.
class FieldStyleChip extends FieldStyle {
  FieldStyleChip({
    this.backgroundColor,
    this.selectedColor,
    super.headerSpacing = 5.0,
    super.footerSpacing = 5.0,
    this.shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    this.unselectedSide = const BorderSide(color: Color(0xffbfbbc5), width: 1),
    this.selectedSide = const BorderSide(color: Color(0xffbfbbc5), width: 1),
    this.labelStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    this.unselectedTextStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    this.selectedTextStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    this.padding = const EdgeInsets.all(8.0),
    this.runSpacing = 8.0,
    this.spacing = 8.0,
    this.checkmarkColor = Colors.white,
    this.materialTapTargetSize = MaterialTapTargetSize.shrinkWrap,
    this.shadowColor = Colors.transparent,
    this.surfaceTintColor = Colors.transparent,
  });

  Color? backgroundColor;
  Color? selectedColor;
  OutlinedBorder shape;
  BorderSide unselectedSide;
  BorderSide selectedSide;
  TextStyle labelStyle;
  TextStyle unselectedTextStyle;
  TextStyle selectedTextStyle;
  EdgeInsets padding;
  double runSpacing;
  double spacing;
  Color checkmarkColor = Colors.white;
  MaterialTapTargetSize materialTapTargetSize;
  Color shadowColor;
  Color surfaceTintColor;
}

/// Style configuration for radio button fields.
///
/// Provides styling options for radio button groups including title styles,
/// list tile appearance, colors, and interaction states. Supports customization
/// of radio button appearance and behavior within form contexts.
class FieldStyleRadio extends FieldStyle {
  FieldStyleRadio({
    this.titleStyle,
    this.listTileStyle,
    this.hideTitle,
    this.selectedColor,
    this.tileColor,
    this.shape,
    this.contentPadding,
    this.activeColor,
    this.fillColor,
    this.hoverColor,
    this.overlayColor,
    this.splashRadius,
    this.mouseCursor,
    this.titleSpacing = 10.0,
    super.headerSpacing,
    super.footerSpacing,
  });

  TextStyle? titleStyle;
  TextStyle? listTileStyle;
  bool? hideTitle;
  NyColor? selectedColor;
  NyColor? tileColor;
  ShapeBorder? shape;
  EdgeInsetsGeometry? contentPadding;
  NyColor? activeColor;
  NyColor? fillColor;
  NyColor? hoverColor;
  NyColor? overlayColor;
  double? splashRadius;
  MouseCursor? mouseCursor;
  double titleSpacing;
}

/// Comprehensive style configuration for text input fields.
///
/// Provides extensive customization options for text fields including appearance,
/// behavior, validation, formatting, and interaction handling. Supports features
/// like masking, password visibility, custom validation rules, and various
/// text input configurations. Includes factory methods for common styling patterns.
class FieldStyleTextField extends FieldStyle {
  FieldStyleTextField({
    this.onEditingComplete,
    this.onSubmitted,
    this.scrollController,
    this.scrollPhysics,
    this.autofillHints,
    this.handleValidationError,
    this.passwordVisible,
    this.prefixIcon,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.focusedBorder,
    this.enabledBorder,
    this.contentPadding,
    this.passwordViewable,
    this.validateOnFocusChange,
    this.customValidationRule,
    this.header,
    this.footer,
    this.clearable,
    this.clearIcon,
    this.mask,
    this.maskMatch,
    this.maskedReturnValue,
    this.decorator,
    this.labelText,
    this.labelStyle,
    this.controller,
    this.obscureText = false,
    this.maxLines,
    this.minLines,
    this.keyboardType = TextInputType.text,
    this.autoFocus = false,
    this.textAlign,
    this.enableSuggestions = true,
    this.focusNode,
    this.hintText,
    this.hintStyle,
    this.dummyData,
    this.onChanged,
    this.textInputAction,
    this.style,
    this.strutStyle,
    this.textAlignVertical,
    this.textDirection,
    this.obscuringCharacter = '•',
    this.autocorrect = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.expands = false,
    this.readOnly = false,
    this.showCursor = true,
    this.maxLength,
    this.mouseCursor,
    this.validationErrorMessage,
    this.textCapitalization = TextCapitalization.none,
    this.maxLengthEnforcement = MaxLengthEnforcement.enforced,
    this.onAppPrivateCommand,
    this.inputFormatters = const [],
    this.enabled = true,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius = const Radius.circular(2.0),
    this.cursorColor = Colors.black87,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.selectionControls = null,
    this.dragStartBehavior = DragStartBehavior.start,
    this.onTap,
    this.onTapOutside,
    InputDecoration? decoration,
    this.clipBehavior = Clip.hardEdge,
    this.fillColor,
    this.filled = false,
    this.isDense = false,
    this.suffixIcon,
  }) : decoration = decoration;

  final String? labelText;
  final TextStyle? labelStyle;
  final TextEditingController? controller;
  final bool obscureText;
  final int? maxLines, minLines;
  final TextInputType keyboardType;
  final bool autoFocus;
  final TextAlign? textAlign;
  final bool enableSuggestions;
  final FocusNode? focusNode;
  final String? hintText;
  final TextStyle? hintStyle;
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
  final bool Function(dynamic value)? customValidationRule;
  final Widget? header;
  final Widget? footer;
  final bool? clearable;
  final Widget? clearIcon;
  final String? mask;
  final String? maskMatch;
  final bool? maskedReturnValue;
  final DecoratorTextField? decorator;
  final bool? filled;
  final Color? fillColor;
  final bool? isDense;
  final Widget? suffixIcon;

  static FieldStyleTextField base() {
    return FieldStyleTextField(
      labelText: '',
      labelStyle: const TextStyle(fontSize: 16.0, color: Colors.black87),
      controller: TextEditingController(),
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      keyboardType: TextInputType.text,
      autoFocus: false,
      textAlign: TextAlign.start,
      enableSuggestions: true,
      focusNode: FocusNode(),
      hintText: '',
      hintStyle: const TextStyle(color: Colors.grey),
      dummyData: '',
      onChanged: null,
      textInputAction: TextInputAction.done,
      style: const TextStyle(fontSize: 16.0, color: Colors.black87),
      filled: true,
      fillColor: Colors.grey.shade100,
      isDense: true,
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.transparent),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.transparent),
      ),
      contentPadding: const EdgeInsetsDirectional.symmetric(
        vertical: 13,
        horizontal: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(width: 0, style: BorderStyle.none),
      ),
      decoration: InputDecoration(),
    );
  }

  static FieldStyleTextField password({bool passwordViewable = true}) {
    FieldStyleTextField _base = base();
    return _base.copyWith(
      prefixIcon: const Icon(Icons.lock_rounded),
      filled: true,
      fillColor: Colors.grey.shade100,
      isDense: true,
      suffixIcon: IconButton(
        icon: Icon(
          passwordViewable ? Icons.visibility : Icons.visibility_off,
          // color: Theme.of(context).primaryColorDark,
        ),
        onPressed: () {
          // setState(() {
          //   _passwordVisible = !_passwordVisible;
          // });
        },
      ),
      contentPadding: const EdgeInsetsDirectional.symmetric(
        vertical: 14,
        horizontal: 14,
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.transparent),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.transparent),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(12),
      ),
      obscureText: true,
      obscuringCharacter: '*',
    );
  }

  static emailAddress() {
    FieldStyleTextField _base = base();
    return _base.copyWith(
      keyboardType: TextInputType.emailAddress,
      prefixIcon: const Icon(Icons.email_outlined),
      filled: true,
      fillColor: Colors.grey.shade100,
      isDense: true,
      contentPadding: const EdgeInsetsDirectional.symmetric(
        vertical: 14,
        horizontal: 14,
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.transparent),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.transparent),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  static basic({FieldStyleTextField? field}) {
    FieldStyleTextField _base = base();
    return _base.copyWith(
      filled: true,
      fillColor: field?.fillColor ?? Colors.grey.shade100,
      backgroundColor: field?.backgroundColor ?? Colors.grey.shade100,
      isDense: true,
      focusedBorder:
          field?.focusedBorder ??
          const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Colors.transparent),
          ),
      enabledBorder:
          field?.enabledBorder ??
          const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Colors.transparent),
          ),
      contentPadding:
          field?.contentPadding ??
          const EdgeInsetsDirectional.symmetric(vertical: 13, horizontal: 13),
      border:
          field?.border ??
          OutlineInputBorder(
            borderRadius: field?.borderRadius ?? BorderRadius.circular(12),
            borderSide: const BorderSide(width: 0, style: BorderStyle.none),
          ),
    );
  }

  @override
  FieldStyleTextField copyWith({
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
    MouseCursor? mouseCursor,
    String? validationErrorMessage,
    TextCapitalization textCapitalization = TextCapitalization.none,
    MaxLengthEnforcement? maxLengthEnforcement,
    AppPrivateCommandCallback? onAppPrivateCommand,
    List<TextInputFormatter>? inputFormatters = const [],
    bool? enabled = true,
    double cursorWidth = 2.0,
    double? cursorHeight = 20.0, // Default height if not provided
    Radius? cursorRadius,
    Color? cursorColor,
    Brightness? keyboardAppearance = Brightness.light, // Default appearance
    EdgeInsets? scrollPadding,
    TextSelectionControls? selectionControls = null, // Default to null
    DragStartBehavior dragStartBehavior =
        DragStartBehavior.start, // Default behavior
    GestureTapCallback? onTap,
    TapRegionCallback? onTapOutside,
    InputDecoration? decoration,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onSubmitted,
    ScrollController? scrollController,
    ScrollPhysics? scrollPhysics,
    Iterable<String>? autofillHints,
    Clip? clipBehavior = Clip.hardEdge, // Default to hard edge clipping
    Function(FormValidationResponse handleError)? handleValidationError,
    bool? passwordVisible,
    String? type,
    Widget? prefixIcon,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    InputBorder? border,
    InputBorder? focusedBorder,
    InputBorder? enabledBorder,
    EdgeInsetsGeometry? contentPadding,
    bool? passwordViewable,
    bool? validateOnFocusChange,
    bool Function(dynamic value)? customValidationRule,
    Widget? header,
    Widget? footer,
    bool? clearable,
    Widget? clearIcon,
    String? mask,
    String? maskMatch,
    bool? maskedReturnValue,
    DecoratorTextField? decorator,
    double? headerSpacing,
    double? footerSpacing,
    bool? filled,
    Color? fillColor,
    bool? isDense,
    Widget? suffixIcon,
  }) {
    return FieldStyleTextField(
      labelText: labelText ?? this.labelText,
      labelStyle: labelStyle ?? this.labelStyle,
      controller: controller ?? this.controller,
      obscureText: obscureText ?? this.obscureText,
      maxLines: maxLines ?? this.maxLines,
      minLines: minLines ?? this.minLines,
      keyboardType: keyboardType ?? this.keyboardType,
      autoFocus: autoFocus ?? this.autoFocus,
      textAlign: textAlign ?? this.textAlign,
      enableSuggestions: enableSuggestions ?? this.enableSuggestions,
      focusNode: focusNode ?? this.focusNode,
      hintText: hintText ?? this.hintText,
      hintStyle: hintStyle ?? this.hintStyle,
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
      textCapitalization: textCapitalization,
      maxLengthEnforcement:
          maxLengthEnforcement ?? MaxLengthEnforcement.enforced,
      onAppPrivateCommand: onAppPrivateCommand,
      inputFormatters: inputFormatters,
      enabled: enabled ?? this.enabled,
      cursorWidth: cursorWidth,
      cursorHeight: cursorHeight ?? this.cursorHeight,
      cursorRadius: cursorRadius ?? this.cursorRadius,
      cursorColor: cursorColor ?? this.cursorColor,
      keyboardAppearance: keyboardAppearance ?? this.keyboardAppearance,
      scrollPadding: scrollPadding ?? this.scrollPadding,
      selectionControls: selectionControls ?? this.selectionControls,
      dragStartBehavior: dragStartBehavior,
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
      passwordViewable: passwordViewable ?? this.passwordViewable,
      validateOnFocusChange:
          validateOnFocusChange ?? this.validateOnFocusChange,
      customValidationRule: customValidationRule ?? this.customValidationRule,
      header: header ?? this.header,
      footer: footer ?? this.footer,
      clearable: clearable ?? this.clearable,
      clearIcon: clearIcon ?? this.clearIcon,
      mask: mask ?? this.mask,
      maskMatch: maskMatch ?? this.maskMatch,
      maskedReturnValue: maskedReturnValue ?? this.maskedReturnValue,
      decorator: decorator ?? this.decorator,
      fillColor: fillColor ?? this.fillColor,
      filled: filled ?? this.filled,
      isDense: isDense ?? this.isDense,
      suffixIcon: suffixIcon ?? this.suffixIcon,
    );
  }

  /// To TextStyle converts the style to a TextStyle.
  TextStyle toTextStyle() {
    return style ?? const TextStyle(fontSize: 16.0, color: Colors.black87);
  }
}

/// FieldStylePicker is used to define the style for a picker field.
///
/// Style configuration for picker fields that display selection options in a modal.
///
/// Extends [FieldStyle] with picker-specific styling options including
/// bottom modal sheet appearance and behavior. Used for fields that present
/// a list of options for user selection.
class FieldStylePicker extends FieldStyle {
  FieldStylePicker({
    this.bottomModalSheetStyle,
    this.containerHeight = 50.0,
    this.containerPadding = const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 4,
    ),
    this.containerBorderRadius = const BorderRadius.all(Radius.circular(8)),
    this.containerColor,
    this.selectedValueTextStyle,
    this.fieldNameTextStyle,
    this.placeholderTextStyle,
    this.placeholderPrefix,
    this.dropdownIcon = Icons.arrow_drop_down,
    this.dropdownIconColor,
    this.bottomSheetHeightFactor = 0.5,
    this.bottomSheetBorderRadius = const BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
    ),
    this.bottomSheetPadding = const EdgeInsets.symmetric(
      vertical: 20,
      horizontal: 20,
    ),
    this.bottomSheetDividerColor,
    this.placeholderGap = 10.0,
    this.widthBreakpoint = 200.0,
    super.headerSpacing,
    super.footerSpacing,
  });

  BottomModalSheetStyle? bottomModalSheetStyle;

  /// Height of the picker container
  final double containerHeight;

  /// Padding inside the picker container
  final EdgeInsets containerPadding;

  /// Border radius of the picker container
  final BorderRadius containerBorderRadius;

  /// Background color of the picker container (light/dark)
  final NyColor? containerColor;

  /// Text style for the selected value display
  final TextStyle? selectedValueTextStyle;

  /// Text style for the field name label
  final TextStyle? fieldNameTextStyle;

  /// Text style for the placeholder text
  final TextStyle? placeholderTextStyle;

  /// Prefix text for the placeholder (default "Select")
  final String? placeholderPrefix;

  /// Icon displayed in the dropdown
  final IconData dropdownIcon;

  /// Color of the dropdown icon (light/dark)
  final NyColor? dropdownIconColor;

  /// Height factor for the bottom sheet (fraction of screen height)
  final double bottomSheetHeightFactor;

  /// Border radius for the bottom sheet
  final BorderRadius bottomSheetBorderRadius;

  /// Padding inside the bottom sheet
  final EdgeInsets bottomSheetPadding;

  /// Divider color in the bottom sheet list (light/dark)
  final NyColor? bottomSheetDividerColor;

  /// Gap between placeholder text and dropdown icon
  final double placeholderGap;

  /// Width breakpoint for switching between compact and full layout
  final double widthBreakpoint;

  @override
  FieldStylePicker copyWith({
    BottomModalSheetStyle? bottomModalSheetStyle,
    double? containerHeight,
    EdgeInsets? containerPadding,
    BorderRadius? containerBorderRadius,
    NyColor? containerColor,
    TextStyle? selectedValueTextStyle,
    TextStyle? fieldNameTextStyle,
    TextStyle? placeholderTextStyle,
    String? placeholderPrefix,
    IconData? dropdownIcon,
    NyColor? dropdownIconColor,
    double? bottomSheetHeightFactor,
    BorderRadius? bottomSheetBorderRadius,
    EdgeInsets? bottomSheetPadding,
    NyColor? bottomSheetDividerColor,
    double? placeholderGap,
    double? widthBreakpoint,
    double? headerSpacing,
    double? footerSpacing,
  }) {
    return FieldStylePicker(
      bottomModalSheetStyle:
          bottomModalSheetStyle ?? this.bottomModalSheetStyle,
      containerHeight: containerHeight ?? this.containerHeight,
      containerPadding: containerPadding ?? this.containerPadding,
      containerBorderRadius:
          containerBorderRadius ?? this.containerBorderRadius,
      containerColor: containerColor ?? this.containerColor,
      selectedValueTextStyle:
          selectedValueTextStyle ?? this.selectedValueTextStyle,
      fieldNameTextStyle: fieldNameTextStyle ?? this.fieldNameTextStyle,
      placeholderTextStyle: placeholderTextStyle ?? this.placeholderTextStyle,
      placeholderPrefix: placeholderPrefix ?? this.placeholderPrefix,
      dropdownIcon: dropdownIcon ?? this.dropdownIcon,
      dropdownIconColor: dropdownIconColor ?? this.dropdownIconColor,
      bottomSheetHeightFactor:
          bottomSheetHeightFactor ?? this.bottomSheetHeightFactor,
      bottomSheetBorderRadius:
          bottomSheetBorderRadius ?? this.bottomSheetBorderRadius,
      bottomSheetPadding: bottomSheetPadding ?? this.bottomSheetPadding,
      bottomSheetDividerColor:
          bottomSheetDividerColor ?? this.bottomSheetDividerColor,
      placeholderGap: placeholderGap ?? this.placeholderGap,
      widthBreakpoint: widthBreakpoint ?? this.widthBreakpoint,
      headerSpacing: headerSpacing ?? this.headerSpacing,
      footerSpacing: footerSpacing ?? this.footerSpacing,
    );
  }
}

/// Style configuration for checkbox fields.
///
/// Provides comprehensive styling options for checkbox widgets including colors,
/// shapes, interaction states, and list tile appearance. Supports customization
/// of checkbox behavior, visual feedback, and accessibility features.
class FieldStyleCheckbox extends FieldStyle {
  FieldStyleCheckbox({
    this.mouseCursor,
    this.activeColor,
    this.fillColor,
    this.checkColor,
    this.hoverColor,
    this.overlayColor,
    this.splashRadius,
    this.materialTapTargetSize,
    this.visualDensity,
    this.focusNode,
    this.autofocus = false,
    this.shape,
    this.side,
    this.isError = false,
    this.enabled,
    this.tileColor,
    this.title,
    this.titleTextStyle,
    this.subtitle,
    this.isThreeLine = false,
    this.dense,
    this.secondary,
    this.selected = false,
    this.controlAffinity = ListTileControlAffinity.platform,
    this.contentPadding,
    this.tristate = false,
    this.checkboxShape,
    this.selectedTileColor,
    this.onFocusChange,
    this.enableFeedback = true,
    this.bottomModalBackgroundColor,
  });

  NyColor? bottomModalBackgroundColor;
  MouseCursor? mouseCursor;
  Color? activeColor;
  Color? fillColor;
  Color? checkColor;
  Color? hoverColor;
  Color? overlayColor;
  double? splashRadius;
  MaterialTapTargetSize? materialTapTargetSize;
  VisualDensity? visualDensity;
  FocusNode? focusNode;
  bool autofocus = false;
  ShapeBorder? shape;
  BorderSide? side;
  bool isError = false;
  bool? enabled;
  Color? tileColor;
  Widget? title;
  TextStyle? titleTextStyle;
  Widget? subtitle;
  bool isThreeLine = false;
  bool? dense;
  Widget? secondary;
  bool selected = false;
  ListTileControlAffinity controlAffinity = ListTileControlAffinity.platform;
  EdgeInsetsGeometry? contentPadding;
  bool tristate = false;
  OutlinedBorder? checkboxShape;
  Color? selectedTileColor;
  ValueChanged<bool?>? onFocusChange;
  bool? enableFeedback;
  String? checkboxSemanticLabel;
}

/// FieldStyleSwitchBox is used to define the style for a switch box field.
///
/// Style configuration for switch toggle fields.
///
/// Extends [FieldStyle] with switch-specific styling options including track
/// and thumb colors, images, and interaction behavior. Provides comprehensive
/// customization for switch widgets in both active and inactive states.
class FieldStyleSwitchBox extends FieldStyle {
  FieldStyleSwitchBox({
    this.mouseCursor,
    this.activeThumbColor,
    this.hoverColor,
    this.overlayColor,
    this.splashRadius,
    this.materialTapTargetSize,
    this.visualDensity,
    this.focusNode,
    this.autofocus = false,
    this.shape,
    this.enabled,
    this.tileColor,
    this.title,
    this.titleTextStyle,
    this.subtitle,
    this.isThreeLine = false,
    this.dense,
    this.secondary,
    this.selected = false,
    this.controlAffinity = ListTileControlAffinity.platform,
    this.contentPadding,
    this.selectedTileColor,
    this.onFocusChange,
    this.enableFeedback,
    super.headerSpacing,
    super.footerSpacing,
  });

  MouseCursor? mouseCursor;
  Color? activeThumbColor;
  Color? hoverColor;
  Color? overlayColor;
  double? splashRadius;
  MaterialTapTargetSize? materialTapTargetSize;
  VisualDensity? visualDensity;
  FocusNode? focusNode;
  bool autofocus;
  ShapeBorder? shape;
  bool? enabled;
  Color? tileColor;
  Widget? title;
  TextStyle? titleTextStyle;
  Widget? subtitle;
  bool isThreeLine;
  bool? dense;
  Widget? secondary;
  bool selected;
  ListTileControlAffinity controlAffinity = ListTileControlAffinity.platform;
  EdgeInsetsGeometry? contentPadding;
  Color? selectedTileColor;
  ValueChanged<bool?>? onFocusChange;
  bool? enableFeedback;
  Color? activeTrackColor;
  Color? inactiveThumbColor;
  Color? inactiveTrackColor;
  ImageProvider? activeThumbImage;
  ImageErrorListener? onActiveThumbImageError;
  ImageProvider? inactiveThumbImage;
  ImageErrorListener? onInactiveThumbImageError;
  Color? thumbColor;
  Color? trackColor;
  Color? trackOutlineColor;
  Widget? thumbIcon;
  DragStartBehavior dragStartBehavior = DragStartBehavior.start;
}

/// Style configuration for slider fields.
///
/// Extends [FieldStyle] with slider-specific styling options including
/// track colors, thumb appearance, value display, and interaction behavior.
/// Provides comprehensive customization for Material Design sliders.
class FieldStyleSlider extends FieldStyle {
  FieldStyleSlider({
    this.min = 0.0,
    this.max = 100.0,
    this.divisions,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.overlayColor,
    this.mouseCursor,
    this.semanticFormatterCallback,
    this.focusNode,
    this.autofocus = false,
    this.allowedInteraction,
    this.showTitle = true,
    this.title,
    this.titleSpacing = 8.0,
    this.showLabel = false,
    this.labelFormatter = _defaultLabelFormatter,
    this.showValue = true,
    this.valueFormatter = _defaultValueFormatter,
    this.valueTextStyle,
    this.valueSpacing = 8.0,
    this.enabled = true,
    super.headerSpacing,
    super.footerSpacing,
  });

  /// The minimum value of the slider
  final double min;

  /// The maximum value of the slider
  final double max;

  /// The number of discrete divisions on the slider track
  final int? divisions;

  /// The color of the active portion of the slider track
  final Color? activeColor;

  /// The color of the inactive portion of the slider track
  final Color? inactiveColor;

  /// The color of the slider thumb
  final Color? thumbColor;

  /// The color of the overlay that appears when the slider is pressed
  final Color? overlayColor;

  /// The mouse cursor to use when hovering over the slider
  final MouseCursor? mouseCursor;

  /// A function that formats the semantic label for accessibility
  final SemanticFormatterCallback? semanticFormatterCallback;

  /// The focus node for the slider
  final FocusNode? focusNode;

  /// Whether the slider should autofocus when first displayed
  final bool autofocus;

  /// The allowed interaction for the slider
  final SliderInteraction? allowedInteraction;

  /// Whether to show the title above the slider
  final bool showTitle;

  /// Custom title widget to display above the slider
  final Widget? title;

  /// Spacing between the title and slider
  final double titleSpacing;

  /// Whether to show labels on the slider track
  final bool showLabel;

  /// Function to format the label text
  final String Function(double value) labelFormatter;

  /// Whether to show the current value below the slider
  final bool showValue;

  /// Function to format the value text
  final String Function(double value) valueFormatter;

  /// Text style for the value display
  final TextStyle? valueTextStyle;

  /// Spacing between the slider and value text
  final double valueSpacing;

  /// Whether the slider is enabled for interaction
  final bool enabled;

  /// Default label formatter
  static String _defaultLabelFormatter(double value) {
    return value.toStringAsFixed(0);
  }

  /// Default value formatter
  static String _defaultValueFormatter(double value) {
    return value.toStringAsFixed(1);
  }

  FieldStyleSlider copyWith({
    double? min,
    double? max,
    int? divisions,
    Color? activeColor,
    Color? inactiveColor,
    Color? thumbColor,
    Color? overlayColor,
    MouseCursor? mouseCursor,
    SemanticFormatterCallback? semanticFormatterCallback,
    FocusNode? focusNode,
    bool? autofocus,
    SliderInteraction? allowedInteraction,
    bool? showTitle,
    Widget? title,
    double? titleSpacing,
    bool? showLabel,
    String Function(double value)? labelFormatter,
    bool? showValue,
    String Function(double value)? valueFormatter,
    TextStyle? valueTextStyle,
    double? valueSpacing,
    bool? enabled,
    double? headerSpacing,
    double? footerSpacing,
  }) {
    return FieldStyleSlider(
      min: min ?? this.min,
      max: max ?? this.max,
      divisions: divisions ?? this.divisions,
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      thumbColor: thumbColor ?? this.thumbColor,
      overlayColor: overlayColor ?? this.overlayColor,
      mouseCursor: mouseCursor ?? this.mouseCursor,
      semanticFormatterCallback:
          semanticFormatterCallback ?? this.semanticFormatterCallback,
      focusNode: focusNode ?? this.focusNode,
      autofocus: autofocus ?? this.autofocus,
      allowedInteraction: allowedInteraction ?? this.allowedInteraction,
      showTitle: showTitle ?? this.showTitle,
      title: title ?? this.title,
      titleSpacing: titleSpacing ?? this.titleSpacing,
      showLabel: showLabel ?? this.showLabel,
      labelFormatter: labelFormatter ?? this.labelFormatter,
      showValue: showValue ?? this.showValue,
      valueFormatter: valueFormatter ?? this.valueFormatter,
      valueTextStyle: valueTextStyle ?? this.valueTextStyle,
      valueSpacing: valueSpacing ?? this.valueSpacing,
      enabled: enabled ?? this.enabled,
      headerSpacing: headerSpacing ?? this.headerSpacing,
      footerSpacing: footerSpacing ?? this.footerSpacing,
    );
  }
}

/// Style configuration for range slider fields.
///
/// Extends [FieldStyle] with range slider-specific styling options including
/// track colors, thumb appearance, value display, and interaction behavior.
/// Provides comprehensive customization for Material Design range sliders.
class FieldStyleRangeSlider extends FieldStyle {
  FieldStyleRangeSlider({
    this.min = 0.0,
    this.max = 100.0,
    this.divisions,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.overlayColor,
    this.mouseCursor,
    this.semanticFormatterCallback,
    this.showTitle = true,
    this.title,
    this.titleSpacing = 8.0,
    this.showLabels = false,
    this.labelFormatter = _defaultLabelFormatter,
    this.showValues = true,
    this.valueFormatter = _defaultValueFormatter,
    this.valueTextStyle,
    this.valueSpacing = 8.0,
    this.enabled = true,
    super.headerSpacing,
    super.footerSpacing,
  });

  /// The minimum value of the range slider
  final double min;

  /// The maximum value of the range slider
  final double max;

  /// The number of discrete divisions on the slider track
  final int? divisions;

  /// The color of the active portion of the slider track
  final Color? activeColor;

  /// The color of the inactive portion of the slider track
  final Color? inactiveColor;

  /// The color of the slider thumbs
  final Color? thumbColor;

  /// The color of the overlay that appears when the slider is pressed
  final Color? overlayColor;

  /// The mouse cursor to use when hovering over the slider
  final MouseCursor? mouseCursor;

  /// A function that formats the semantic label for accessibility
  final SemanticFormatterCallback? semanticFormatterCallback;

  /// Whether to show the title above the slider
  final bool showTitle;

  /// Custom title widget to display above the slider
  final Widget? title;

  /// Spacing between the title and slider
  final double titleSpacing;

  /// Whether to show labels on the slider track
  final bool showLabels;

  /// Function to format the label text
  final String Function(double value) labelFormatter;

  /// Whether to show the current values below the slider
  final bool showValues;

  /// Function to format the value text
  final String Function(double start, double end) valueFormatter;

  /// Text style for the value display
  final TextStyle? valueTextStyle;

  /// Spacing between the slider and value text
  final double valueSpacing;

  /// Whether the slider is enabled for interaction
  final bool enabled;

  /// Default label formatter
  static String _defaultLabelFormatter(double value) {
    return value.toStringAsFixed(0);
  }

  /// Default value formatter
  static String _defaultValueFormatter(double start, double end) {
    return '${start.toStringAsFixed(1)} - ${end.toStringAsFixed(1)}';
  }

  FieldStyleRangeSlider copyWith({
    double? min,
    double? max,
    int? divisions,
    Color? activeColor,
    Color? inactiveColor,
    Color? thumbColor,
    Color? overlayColor,
    MouseCursor? mouseCursor,
    SemanticFormatterCallback? semanticFormatterCallback,
    bool? showTitle,
    Widget? title,
    double? titleSpacing,
    bool? showLabels,
    String Function(double value)? labelFormatter,
    bool? showValues,
    String Function(double start, double end)? valueFormatter,
    TextStyle? valueTextStyle,
    double? valueSpacing,
    bool? enabled,
    double? headerSpacing,
    double? footerSpacing,
  }) {
    return FieldStyleRangeSlider(
      min: min ?? this.min,
      max: max ?? this.max,
      divisions: divisions ?? this.divisions,
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      thumbColor: thumbColor ?? this.thumbColor,
      overlayColor: overlayColor ?? this.overlayColor,
      mouseCursor: mouseCursor ?? this.mouseCursor,
      semanticFormatterCallback:
          semanticFormatterCallback ?? this.semanticFormatterCallback,
      showTitle: showTitle ?? this.showTitle,
      title: title ?? this.title,
      titleSpacing: titleSpacing ?? this.titleSpacing,
      showLabels: showLabels ?? this.showLabels,
      labelFormatter: labelFormatter ?? this.labelFormatter,
      showValues: showValues ?? this.showValues,
      valueFormatter: valueFormatter ?? this.valueFormatter,
      valueTextStyle: valueTextStyle ?? this.valueTextStyle,
      valueSpacing: valueSpacing ?? this.valueSpacing,
      enabled: enabled ?? this.enabled,
      headerSpacing: headerSpacing ?? this.headerSpacing,
      footerSpacing: footerSpacing ?? this.footerSpacing,
    );
  }
}
