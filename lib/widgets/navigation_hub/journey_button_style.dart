import 'package:flutter/material.dart';
import 'package:nylo_support/localization/app_localization.dart';

/// Base class for defining the style and parameters of journey buttons.
/// JourneyButtonStyles:
/// - [standard] Standard button style with customizable properties.
/// - [minimal] Minimal button style with icons only.
/// - [outlined] Outlined button style.
/// - [contained] Contained button style.
/// - [custom] Custom button style using builder functions.
abstract class JourneyButtonStyle {
  const JourneyButtonStyle();

  /// Builds the back button widget.
  Widget buildBackButton(BuildContext context, VoidCallback? onPressed);

  /// Builds the next button widget.
  Widget buildNextButton(
      BuildContext context, VoidCallback? onPressed, bool isLastStep);

  /// Creates a standard button style with customizable properties.
  const factory JourneyButtonStyle.standard({
    IconData backIcon,
    IconData nextIcon,
    IconData? completeIcon,
    String backText,
    String nextText,
    String completeText,
    TextStyle? backTextStyle,
    TextStyle? nextTextStyle,
    TextStyle? completeTextStyle,
    bool showText,
    double iconSize,
    EdgeInsetsGeometry padding,
  }) = _StandardButtonStyle;

  /// Creates a minimal button style with icons only.
  const factory JourneyButtonStyle.minimal({
    IconData backIcon,
    IconData nextIcon,
    IconData? completeIcon,
    double iconSize,
    Color? iconColor,
    Color? disabledIconColor,
  }) = _MinimalButtonStyle;

  /// Creates an outlined button style.
  const factory JourneyButtonStyle.outlined({
    IconData backIcon,
    IconData nextIcon,
    IconData? completeIcon,
    String backText,
    String nextText,
    String completeText,
    TextStyle? backTextStyle,
    TextStyle? nextTextStyle,
    TextStyle? completeTextStyle,
    Color borderColor,
    double borderWidth,
    BorderRadius borderRadius,
    EdgeInsetsGeometry padding,
  }) = _OutlinedButtonStyle;

  /// Creates a contained button style.
  const factory JourneyButtonStyle.contained({
    IconData backIcon,
    IconData nextIcon,
    IconData? completeIcon,
    String backText,
    String nextText,
    String completeText,
    TextStyle? backTextStyle,
    TextStyle? nextTextStyle,
    TextStyle? completeTextStyle,
    Color? backColor,
    Color? nextColor,
    Color? completeColor,
    BorderRadius borderRadius,
    EdgeInsetsGeometry padding,
  }) = _ContainedButtonStyle;

  /// Creates a custom button style using builder functions.
  const factory JourneyButtonStyle.custom({
    required Widget Function(BuildContext context, VoidCallback? onPressed)
        backButtonBuilder,
    required Widget Function(
            BuildContext context, VoidCallback? onPressed, bool isLastStep)
        nextButtonBuilder,
  }) = _CustomButtonStyle;
}

class _StandardButtonStyle extends JourneyButtonStyle {
  final IconData backIcon;
  final IconData nextIcon;
  final IconData? completeIcon;
  final String backText;
  final String nextText;
  final String completeText;
  final TextStyle? backTextStyle;
  final TextStyle? nextTextStyle;
  final TextStyle? completeTextStyle;
  final bool showText;
  final double iconSize;
  final EdgeInsetsGeometry padding;

  const _StandardButtonStyle({
    this.backIcon = Icons.arrow_back,
    this.nextIcon = Icons.arrow_forward,
    this.completeIcon,
    this.backText = 'Back',
    this.nextText = 'Next',
    this.completeText = 'Finish',
    this.backTextStyle,
    this.nextTextStyle,
    this.completeTextStyle,
    this.showText = true,
    this.iconSize = 24.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  });

  @override
  Widget buildBackButton(BuildContext context, VoidCallback? onPressed) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(backIcon, size: iconSize),
      label: showText
          ? Text(backText.tr(), style: backTextStyle)
          : const SizedBox.shrink(),
      style: ButtonStyle(
        padding: WidgetStateProperty.all(padding),
      ),
    );
  }

  @override
  Widget buildNextButton(
      BuildContext context, VoidCallback? onPressed, bool isLastStep) {
    final IconData buttonIcon =
        isLastStep && completeIcon != null ? completeIcon! : nextIcon;
    final String buttonText = isLastStep ? completeText : nextText;
    final TextStyle? buttonTextStyle =
        isLastStep ? completeTextStyle : nextTextStyle;

    return TextButton.icon(
      onPressed: onPressed,
      iconAlignment: IconAlignment.end,
      icon: Icon(buttonIcon, size: iconSize),
      label: showText
          ? Text(buttonText.tr(), style: buttonTextStyle)
          : const SizedBox.shrink(),
      style: ButtonStyle(
        padding: WidgetStateProperty.all(padding),
      ),
    );
  }
}

class _MinimalButtonStyle extends JourneyButtonStyle {
  final IconData backIcon;
  final IconData nextIcon;
  final IconData? completeIcon;
  final double iconSize;
  final Color? iconColor;
  final Color? disabledIconColor;

  const _MinimalButtonStyle({
    this.backIcon = Icons.arrow_back,
    this.nextIcon = Icons.arrow_forward,
    this.completeIcon,
    this.iconSize = 24.0,
    this.iconColor,
    this.disabledIconColor,
  });

  @override
  Widget buildBackButton(BuildContext context, VoidCallback? onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        backIcon,
        size: iconSize,
        color: onPressed == null ? disabledIconColor : iconColor,
      ),
    );
  }

  @override
  Widget buildNextButton(
      BuildContext context, VoidCallback? onPressed, bool isLastStep) {
    final IconData buttonIcon =
        isLastStep && completeIcon != null ? completeIcon! : nextIcon;

    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        buttonIcon,
        size: iconSize,
        color: onPressed == null ? disabledIconColor : iconColor,
      ),
    );
  }
}

class _OutlinedButtonStyle extends JourneyButtonStyle {
  final IconData backIcon;
  final IconData nextIcon;
  final IconData? completeIcon;
  final String backText;
  final String nextText;
  final String completeText;
  final TextStyle? backTextStyle;
  final TextStyle? nextTextStyle;
  final TextStyle? completeTextStyle;
  final Color borderColor;
  final double borderWidth;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  const _OutlinedButtonStyle({
    this.backIcon = Icons.arrow_back,
    this.nextIcon = Icons.arrow_forward,
    this.completeIcon,
    this.backText = 'Back',
    this.nextText = 'Next',
    this.completeText = 'Finish',
    this.backTextStyle,
    this.nextTextStyle,
    this.completeTextStyle,
    this.borderColor = Colors.black,
    this.borderWidth = 1.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(4.0)),
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  });

  @override
  Widget buildBackButton(BuildContext context, VoidCallback? onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(backIcon),
      label: Text(backText.tr(), style: backTextStyle),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: borderColor, width: borderWidth),
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        padding: padding,
      ),
    );
  }

  @override
  Widget buildNextButton(
      BuildContext context, VoidCallback? onPressed, bool isLastStep) {
    final IconData buttonIcon =
        isLastStep && completeIcon != null ? completeIcon! : nextIcon;
    final String buttonText = isLastStep ? completeText : nextText;
    final TextStyle? buttonTextStyle =
        isLastStep ? completeTextStyle : nextTextStyle;

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(buttonIcon),
      label: Text(buttonText.tr(), style: buttonTextStyle),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: borderColor, width: borderWidth),
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        padding: padding,
      ),
    );
  }
}

class _ContainedButtonStyle extends JourneyButtonStyle {
  final IconData backIcon;
  final IconData nextIcon;
  final IconData? completeIcon;
  final String backText;
  final String nextText;
  final String completeText;
  final TextStyle? backTextStyle;
  final TextStyle? nextTextStyle;
  final TextStyle? completeTextStyle;
  final Color? backColor;
  final Color? nextColor;
  final Color? completeColor;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  const _ContainedButtonStyle({
    this.backIcon = Icons.arrow_back,
    this.nextIcon = Icons.arrow_forward,
    this.completeIcon,
    this.backText = 'Back',
    this.nextText = 'Next',
    this.completeText = 'Finish',
    this.backTextStyle,
    this.nextTextStyle,
    this.completeTextStyle,
    this.backColor,
    this.nextColor,
    this.completeColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(4.0)),
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  });

  @override
  Widget buildBackButton(BuildContext context, VoidCallback? onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(backIcon),
      label: Text(backText.tr(), style: backTextStyle),
      style: ElevatedButton.styleFrom(
        backgroundColor: backColor,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        padding: padding,
      ),
    );
  }

  @override
  Widget buildNextButton(
      BuildContext context, VoidCallback? onPressed, bool isLastStep) {
    final IconData buttonIcon =
        isLastStep && completeIcon != null ? completeIcon! : nextIcon;
    final String buttonText = isLastStep ? completeText : nextText;
    final TextStyle? buttonTextStyle =
        isLastStep ? completeTextStyle : nextTextStyle;
    final Color? buttonColor = isLastStep ? completeColor : nextColor;

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(buttonIcon),
      label: Text(buttonText.tr(), style: buttonTextStyle),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        padding: padding,
      ),
    );
  }
}

class _CustomButtonStyle extends JourneyButtonStyle {
  final Widget Function(BuildContext context, VoidCallback? onPressed)
      backButtonBuilder;
  final Widget Function(
          BuildContext context, VoidCallback? onPressed, bool isLastStep)
      nextButtonBuilder;

  const _CustomButtonStyle({
    required this.backButtonBuilder,
    required this.nextButtonBuilder,
  });

  @override
  Widget buildBackButton(BuildContext context, VoidCallback? onPressed) {
    return backButtonBuilder(context, onPressed);
  }

  @override
  Widget buildNextButton(
      BuildContext context, VoidCallback? onPressed, bool isLastStep) {
    return nextButtonBuilder(context, onPressed, isLastStep);
  }
}
