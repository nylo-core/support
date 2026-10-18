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
    this.canClear = true,
    this.clearIconData = Icons.clear,
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
  bool canClear;
  IconData clearIconData;

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
    bool? canClear,
    IconData? clearIconData,
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
      canClear: canClear ?? this.canClear,
      clearIconData: clearIconData ?? this.clearIconData,
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
    this.prefixIconAlignment,
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
    this.selectionControls,
    this.dragStartBehavior = DragStartBehavior.start,
    this.onTap,
    this.onTapOutside,
    this.decoration,
    this.clipBehavior = Clip.hardEdge,
    this.fillColor,
    this.filled = false,
    this.isDense = false,
    this.suffixIcon,
    this.enableInteractiveSelection = true,
  });

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

  /// Where [prefixIcon] sits vertically in a multi-line field.
  ///
  /// e.g. `FieldStyleTextField(maxLines: 5, prefixIconAlignment: PrefixIconAlignment.top)`
  final PrefixIconAlignment? prefixIconAlignment;
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
  final bool enableInteractiveSelection;

  static FieldStyleTextField base() {
    return FieldStyleTextField(
      labelText: '',
      labelStyle: const TextStyle(fontSize: 16.0, color: Colors.black87),
      // No controller or focusNode: [InputField] creates and disposes its own,
      // and its focus listener (inline validation) must see the node in use.
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      keyboardType: TextInputType.text,
      autoFocus: false,
      textAlign: TextAlign.start,
      enableSuggestions: true,
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
    FieldStyleTextField baseStyle = base();
    return baseStyle.copyWith(
      prefixIcon: const Icon(Icons.lock_rounded),
      filled: true,
      fillColor: Colors.grey.shade100,
      isDense: true,
      suffixIcon: passwordViewable
          ? IconButton(
              icon: Icon(
                passwordViewable ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {},
            )
          : null,
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

  static FieldStyleTextField emailAddress() {
    FieldStyleTextField baseStyle = base();
    return baseStyle.copyWith(
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

  static FieldStyleTextField basic({FieldStyleTextField? field}) {
    FieldStyleTextField baseStyle = base();
    return baseStyle.copyWith(
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
    bool? enableInteractiveSelection,
    Function(FormValidationResponse handleError)? handleValidationError,
    bool? passwordVisible,
    String? type,
    Widget? prefixIcon,
    PrefixIconAlignment? prefixIconAlignment,
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
      enableInteractiveSelection:
          enableInteractiveSelection ?? this.enableInteractiveSelection,
      passwordVisible: passwordVisible ?? this.passwordVisible,
      prefixIcon: prefixIcon ?? this.prefixIcon,
      prefixIconAlignment: prefixIconAlignment ?? this.prefixIconAlignment,
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

/// Indicator type for picker list tiles.
enum PickerListTileIndicator {
  /// No indicator (default behavior).
  none,

  /// Radio button indicator (leading).
  radio,

  /// Checkmark indicator (trailing).
  checkmark,
}

/// Style configuration for individual list tiles in a picker bottom sheet.
///
/// Use the named factories for common patterns:
/// - [PickerListTileStyle.radio] — radio button indicator
/// - [PickerListTileStyle.checkmark] — checkmark indicator
/// - [PickerListTileStyle.custom] — fully custom builder
class PickerListTileStyle {
  const PickerListTileStyle({
    this.builder,
    this.indicator = PickerListTileIndicator.none,
    this.activeColor,
    this.textStyle,
    this.selectedTextStyle,
    this.contentPadding,
    this.tileColor,
    this.selectedTileColor,
  });

  /// Radio button style — shows a radio icon as the leading widget.
  factory PickerListTileStyle.radio({
    Color? activeColor,
    TextStyle? textStyle,
    TextStyle? selectedTextStyle,
    EdgeInsetsGeometry? contentPadding,
    Color? tileColor,
    Color? selectedTileColor,
  }) {
    return PickerListTileStyle(
      indicator: PickerListTileIndicator.radio,
      activeColor: activeColor,
      textStyle: textStyle,
      selectedTextStyle: selectedTextStyle,
      contentPadding: contentPadding,
      tileColor: tileColor,
      selectedTileColor: selectedTileColor,
    );
  }

  /// Checkmark style — shows a check icon as the trailing widget when selected.
  factory PickerListTileStyle.checkmark({
    Color? activeColor,
    TextStyle? textStyle,
    TextStyle? selectedTextStyle,
    EdgeInsetsGeometry? contentPadding,
    Color? tileColor,
    Color? selectedTileColor,
  }) {
    return PickerListTileStyle(
      indicator: PickerListTileIndicator.checkmark,
      activeColor: activeColor,
      textStyle: textStyle,
      selectedTextStyle: selectedTextStyle,
      contentPadding: contentPadding,
      tileColor: tileColor,
      selectedTileColor: selectedTileColor,
    );
  }

  /// Fully custom builder for complete control over the tile widget.
  factory PickerListTileStyle.custom({
    required Widget Function(
      FormOption option,
      bool isSelected,
      VoidCallback onTap,
    )
    builder,
  }) {
    return PickerListTileStyle(builder: builder);
  }

  /// Custom builder that overrides the default list tile rendering.
  final Widget Function(FormOption option, bool isSelected, VoidCallback onTap)?
  builder;

  /// Which indicator preset to use.
  final PickerListTileIndicator indicator;

  /// Color for active indicator icons (radio / checkmark).
  final Color? activeColor;

  /// Text style for unselected items.
  final TextStyle? textStyle;

  /// Text style for the currently selected item.
  final TextStyle? selectedTextStyle;

  /// Content padding for each list tile.
  final EdgeInsetsGeometry? contentPadding;

  /// Background color for unselected tiles.
  final Color? tileColor;

  /// Background color for the selected tile.
  final Color? selectedTileColor;
}

const String _pickerLayoutDeprecation =
    'The picker lays out like a text field, so this no longer applies. '
    'Will be removed in 8.0.';

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
    this.listTileStyle,
    this.decoration,
    this.prefixIcon,
    this.containerHeight = 50.0,
    this.containerPadding = const EdgeInsets.symmetric(
      horizontal: 13,
      vertical: 13,
    ),
    this.containerBorderRadius = const BorderRadius.all(Radius.circular(12)),
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
    @Deprecated(_pickerLayoutDeprecation) this.placeholderGap = 10.0,
    @Deprecated(_pickerLayoutDeprecation) this.widthBreakpoint = 200.0,
    @Deprecated(_pickerLayoutDeprecation) this.placeholderAlignment,
    this.selectedValueAlignment = Alignment.centerLeft,
    @Deprecated(_pickerLayoutDeprecation)
    this.selectedValuePadding = const EdgeInsets.only(top: 10),
    super.headerSpacing,
    super.footerSpacing,
  });

  BottomModalSheetStyle? bottomModalSheetStyle;

  /// Style for individual list tiles in the picker bottom sheet.
  final PickerListTileStyle? listTileStyle;

  /// Replaces the picker's [InputDecoration], the same way
  /// `FieldStyleDateTimePicker.decoration` does for a date field.
  ///
  /// It keeps the field's label when it gives none (no label, no hint), the
  /// [dropdownIcon] when it has no suffix icon, and [prefixIcon] when it has
  /// no prefix icon.
  final InputDecoration? decoration;

  /// Widget shown before the label, like a text field's `prefixIcon`.
  ///
  /// e.g. `FieldStylePicker(prefixIcon: Icon(Icons.category_outlined))`
  final Widget? prefixIcon;

  /// Minimum height of the picker; it grows to fit its label and choice
  final double containerHeight;

  /// Padding inside the picker, used as its `contentPadding`
  final EdgeInsets containerPadding;

  /// Border radius of the picker
  final BorderRadius containerBorderRadius;

  /// Background color of the picker (light/dark)
  final NyColor? containerColor;

  /// Text style for the chosen option
  final TextStyle? selectedValueTextStyle;

  /// Text style for the field name once it floats above a chosen option
  final TextStyle? fieldNameTextStyle;

  /// Text style for the label, "Select" and the field name, before an option
  /// is chosen
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
  @Deprecated(_pickerLayoutDeprecation)
  final double placeholderGap;

  /// Width breakpoint for switching between compact and full layout
  @Deprecated(_pickerLayoutDeprecation)
  final double widthBreakpoint;

  /// Alignment of the placeholder/selected-value row
  @Deprecated(_pickerLayoutDeprecation)
  final MainAxisAlignment? placeholderAlignment;

  /// Horizontal alignment of the chosen option's text.
  ///
  /// Use values like [Alignment.centerLeft], [Alignment.center], or
  /// [Alignment.centerRight].
  final Alignment? selectedValueAlignment;

  /// Padding around the selected value text.
  @Deprecated(_pickerLayoutDeprecation)
  final EdgeInsets? selectedValuePadding;

  @override
  FieldStylePicker copyWith({
    BottomModalSheetStyle? bottomModalSheetStyle,
    PickerListTileStyle? listTileStyle,
    InputDecoration? decoration,
    Widget? prefixIcon,
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
    @Deprecated(_pickerLayoutDeprecation) double? placeholderGap,
    @Deprecated(_pickerLayoutDeprecation) double? widthBreakpoint,
    @Deprecated(_pickerLayoutDeprecation)
    MainAxisAlignment? placeholderAlignment,
    Alignment? selectedValueAlignment,
    @Deprecated(_pickerLayoutDeprecation) EdgeInsets? selectedValuePadding,
    double? headerSpacing,
    double? footerSpacing,
  }) {
    return FieldStylePicker(
      bottomModalSheetStyle:
          bottomModalSheetStyle ?? this.bottomModalSheetStyle,
      listTileStyle: listTileStyle ?? this.listTileStyle,
      decoration: decoration ?? this.decoration,
      prefixIcon: prefixIcon ?? this.prefixIcon,
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
      placeholderAlignment: placeholderAlignment ?? this.placeholderAlignment,
      selectedValueAlignment:
          selectedValueAlignment ?? this.selectedValueAlignment,
      selectedValuePadding: selectedValuePadding ?? this.selectedValuePadding,
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
    this.activeTrackColor,
    this.inactiveThumbColor,
    this.inactiveTrackColor,
    this.activeThumbImage,
    this.onActiveThumbImageError,
    this.inactiveThumbImage,
    this.onInactiveThumbImageError,
    this.thumbColor,
    this.trackColor,
    this.trackOutlineColor,
    this.thumbIcon,
    this.dragStartBehavior = DragStartBehavior.start,
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

  @override
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

  @override
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
