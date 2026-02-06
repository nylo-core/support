import 'package:flutter/material.dart';
import '/widgets/ny_widgets.dart';

/// The position of the progress indicator in the journey layout
enum ProgressIndicatorPosition {
  /// Show the progress indicator at the top of the page
  top,

  /// Show the progress indicator at the bottom of the page
  bottom,
}

/// Comprehensive configuration for journey progress display.
///
/// Combines the indicator type, position, and padding into a single object.
///
/// Example:
/// ```dart
/// JourneyProgressStyle(
///   indicator: JourneyProgressIndicator.dots(),
///   position: ProgressIndicatorPosition.bottom,
///   padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
/// )
/// ```
class JourneyProgressStyle {
  /// The progress indicator to display.
  final JourneyProgressIndicator indicator;

  /// Where to place the progress indicator (top or bottom).
  final ProgressIndicatorPosition position;

  /// Padding around the progress indicator.
  /// Falls back to `EdgeInsets.symmetric(horizontal: 16, vertical: 8)` when null.
  final EdgeInsets? padding;

  const JourneyProgressStyle({
    this.indicator = const JourneyProgressIndicator.linear(),
    this.position = ProgressIndicatorPosition.top,
    this.padding,
  });
}

/// Base class for defining the style and parameters of a journey progress indicator.
/// JourneyProgressIndicators:
/// - [none] Renders nothing — useful for hiding the indicator on a specific tab.
/// - [linear] Linear progress bar style.
/// - [dots] Dots-based progress indicator style.
/// - [numbered] Numbered step progress indicator style.
/// - [segments] Segmented progress bar style.
/// - [circular] Circular progress indicator style.
/// - [timeline] Timeline-style progress indicator.
/// - [custom] Custom progress indicator using a builder function.
abstract class JourneyProgressIndicator {
  const JourneyProgressIndicator();

  /// Builds the progress indicator widget.
  Widget build(BuildContext context, int currentStep, int totalSteps);

  /// Creates an empty indicator that renders nothing.
  ///
  /// Useful when a layout defines a global [JourneyProgressStyle] but a
  /// specific tab needs to hide the progress indicator.
  const factory JourneyProgressIndicator.none() = _NoneProgressIndicator;

  /// Creates a standard linear progress bar style.
  const factory JourneyProgressIndicator.linear({
    Color activeColor,
    Color inactiveColor,
    double? thickness,
  }) = _LinearProgressIndicator;

  /// Creates a dots-based progress indicator style.
  const factory JourneyProgressIndicator.dots({
    Color activeColor,
    Color inactiveColor,
    double? dotSize,
    double? spacing,
  }) = _DotsProgressIndicator;

  /// Creates a numbered step progress indicator style.
  const factory JourneyProgressIndicator.numbered({
    Color activeColor,
    Color inactiveColor,
    Color? textColor,
    double? circleSize,
    double? spacing,
  }) = _NumberedProgressIndicator;

  /// Creates a segmented progress bar style.
  const factory JourneyProgressIndicator.segments({
    Color activeColor,
    Color inactiveColor,
    double? height,
    double? spacing,
  }) = _SegmentProgressIndicator;

  /// Creates a circular progress indicator style.
  const factory JourneyProgressIndicator.circular({
    Color activeColor,
    Color inactiveColor,
    Color? textColor,
    double? size,
    double? thickness,
    bool showPercentage,
  }) = _CircularProgressIndicator;

  /// Creates a timeline-style progress indicator.
  const factory JourneyProgressIndicator.timeline({
    Color activeColor,
    Color inactiveColor,
    double? lineThickness,
    double? dotSize,
    bool showLabels,
  }) = _TimelineProgressIndicator;

  /// Creates a custom progress indicator using a builder function.
  const factory JourneyProgressIndicator.custom({
    required Widget Function(
      BuildContext context,
      int currentStep,
      int totalSteps,
      double percentage,
    )
    builder,
  }) = _CustomProgressIndicator;
}

// Private implementation classes for each indicator

class _NoneProgressIndicator extends JourneyProgressIndicator {
  const _NoneProgressIndicator();

  @override
  Widget build(BuildContext context, int currentStep, int totalSteps) {
    return const SizedBox.shrink();
  }
}

class _LinearProgressIndicator extends JourneyProgressIndicator {
  final Color activeColor;
  final Color inactiveColor;
  final double? thickness;

  const _LinearProgressIndicator({
    this.activeColor = Colors.black87,
    this.inactiveColor = const Color(0xFFe0e0e0),
    this.thickness,
  });

  @override
  Widget build(BuildContext context, int currentStep, int totalSteps) {
    final percentage = totalSteps == 0 ? 0.0 : (currentStep + 1) / totalSteps;
    return LinearProgressIndicator(
      value: percentage,
      backgroundColor: inactiveColor,
      color: activeColor,
      minHeight: thickness ?? 4.0,
    );
  }
}

class _DotsProgressIndicator extends JourneyProgressIndicator {
  final Color activeColor;
  final Color inactiveColor;
  final double? dotSize;
  final double? spacing;

  const _DotsProgressIndicator({
    this.activeColor = Colors.black87,
    this.inactiveColor = const Color(0xFFe0e0e0),
    this.dotSize,
    this.spacing,
  });

  @override
  Widget build(BuildContext context, int currentStep, int totalSteps) {
    return JourneyDotProgress(
      currentStep: currentStep,
      totalSteps: totalSteps,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      dotSize: dotSize ?? 10.0,
      spacing: spacing ?? 8.0,
    );
  }
}

class _NumberedProgressIndicator extends JourneyProgressIndicator {
  final Color activeColor;
  final Color inactiveColor;
  final Color? textColor;
  final double? circleSize;
  final double? spacing;

  const _NumberedProgressIndicator({
    this.activeColor = Colors.black87,
    this.inactiveColor = const Color(0xFFe0e0e0),
    this.textColor,
    this.circleSize,
    this.spacing,
  });

  @override
  Widget build(BuildContext context, int currentStep, int totalSteps) {
    final effectiveTextColor =
        textColor ??
        Theme.of(context).textTheme.bodySmall?.color ??
        Colors.black87;
    return JourneyNumberedProgress(
      currentStep: currentStep,
      totalSteps: totalSteps,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      textColor: effectiveTextColor,
      circleSize: circleSize ?? 28.0,
      spacing: spacing ?? 4.0,
    );
  }
}

class _SegmentProgressIndicator extends JourneyProgressIndicator {
  final Color activeColor;
  final Color inactiveColor;
  final double? height;
  final double? spacing;

  const _SegmentProgressIndicator({
    this.activeColor = Colors.black87,
    this.inactiveColor = const Color(0xFFe0e0e0),
    this.height,
    this.spacing,
  });

  @override
  Widget build(BuildContext context, int currentStep, int totalSteps) {
    return JourneySegmentProgress(
      currentStep: currentStep,
      totalSteps: totalSteps,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      height: height ?? 4.0,
      spacing: spacing ?? 4.0,
    );
  }
}

class _CircularProgressIndicator extends JourneyProgressIndicator {
  final Color activeColor;
  final Color inactiveColor;
  final Color? textColor;
  final double? size;
  final double? thickness;
  final bool showPercentage;

  const _CircularProgressIndicator({
    this.activeColor = Colors.black87,
    this.inactiveColor = const Color(0xFFe0e0e0),
    this.textColor,
    this.size,
    this.thickness,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context, int currentStep, int totalSteps) {
    final percentage = totalSteps == 0 ? 0.0 : (currentStep + 1) / totalSteps;
    final effectiveTextColor =
        textColor ??
        Theme.of(context).textTheme.bodySmall?.color ??
        Colors.black87;
    return JourneyCircularProgress(
      percentage: percentage,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      textColor: effectiveTextColor,
      size: size ?? 40.0,
      thickness: thickness ?? 4.0,
      showPercentage: showPercentage,
    );
  }
}

class _TimelineProgressIndicator extends JourneyProgressIndicator {
  final Color activeColor;
  final Color inactiveColor;
  final double? lineThickness;
  final double? dotSize;
  final bool showLabels;

  const _TimelineProgressIndicator({
    this.activeColor = Colors.black87,
    this.inactiveColor = const Color(0xFFe0e0e0),
    this.lineThickness,
    this.dotSize,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context, int currentStep, int totalSteps) {
    return JourneyTimelineProgress(
      currentStep: currentStep,
      totalSteps: totalSteps,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      lineThickness: lineThickness ?? 2.0,
      dotSize: dotSize ?? 12.0,
      showLabels:
          showLabels &&
          totalSteps <= 5, // Example logic: only show labels if few steps
    );
  }
}

class _CustomProgressIndicator extends JourneyProgressIndicator {
  final Widget Function(
    BuildContext context,
    int currentStep,
    int totalSteps,
    double percentage,
  )
  builder;

  const _CustomProgressIndicator({required this.builder});

  @override
  Widget build(BuildContext context, int currentStep, int totalSteps) {
    final percentage = totalSteps == 0 ? 0.0 : (currentStep + 1) / totalSteps;
    return builder(context, currentStep, totalSteps, percentage);
  }
}
