import 'package:flutter/material.dart';
import '/widgets/navigation_hub/custom_progress_indicators.dart';

/// Base class for defining the style and parameters of a journey progress indicator.
/// JourneyProgressStyles:
/// - [linear] Linear progress bar style.
/// - [dots] Dots-based progress indicator style.
/// - [numbered] Numbered step progress indicator style.
/// - [segments] Segmented progress bar style.
/// - [circular] Circular progress indicator style.
/// - [timeline] Timeline-style progress indicator.
/// - [custom] Custom progress indicator using a builder function.
abstract class JourneyProgressStyle {
  const JourneyProgressStyle();

  /// Builds the progress indicator widget.
  Widget build(BuildContext context, int currentStep, int totalSteps);

  /// Creates a standard linear progress bar style.
  const factory JourneyProgressStyle.linear({
    Color activeColor,
    Color inactiveColor,
    double? thickness,
  }) = _LinearProgressStyle;

  /// Creates a dots-based progress indicator style.
  const factory JourneyProgressStyle.dots({
    Color activeColor,
    Color inactiveColor,
    double? dotSize,
    double? spacing,
  }) = _DotsProgressStyle;

  /// Creates a numbered step progress indicator style.
  const factory JourneyProgressStyle.numbered({
    Color activeColor,
    Color inactiveColor,
    Color? textColor,
    double? circleSize,
    double? spacing,
  }) = _NumberedProgressStyle;

  /// Creates a segmented progress bar style.
  const factory JourneyProgressStyle.segments({
    Color activeColor,
    Color inactiveColor,
    double? height,
    double? spacing,
  }) = _SegmentProgressStyle;

  /// Creates a circular progress indicator style.
  const factory JourneyProgressStyle.circular({
    Color activeColor,
    Color inactiveColor,
    Color? textColor,
    double? size,
    double? thickness,
    bool showPercentage,
  }) = _CircularProgressStyle;

  /// Creates a timeline-style progress indicator.
  const factory JourneyProgressStyle.timeline({
    Color activeColor,
    Color inactiveColor,
    double? lineThickness,
    double? dotSize,
    bool showLabels,
  }) = _TimelineProgressStyle;

  /// Creates a custom progress indicator using a builder function.
  const factory JourneyProgressStyle.custom({
    required Widget Function(BuildContext context, int currentStep,
            int totalSteps, double percentage)
        builder,
  }) = _CustomProgressStyle;
}

// Private implementation classes for each style

class _LinearProgressStyle extends JourneyProgressStyle {
  final Color activeColor;
  final Color inactiveColor;
  final double? thickness;

  const _LinearProgressStyle(
      {this.activeColor = Colors.black87,
      this.inactiveColor = const Color(0xFFe0e0e0),
      this.thickness});

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

class _DotsProgressStyle extends JourneyProgressStyle {
  final Color activeColor;
  final Color inactiveColor;
  final double? dotSize;
  final double? spacing;

  const _DotsProgressStyle(
      {this.activeColor = Colors.black87,
      this.inactiveColor = const Color(0xFFe0e0e0),
      this.dotSize,
      this.spacing});

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

class _NumberedProgressStyle extends JourneyProgressStyle {
  final Color activeColor;
  final Color inactiveColor;
  final Color? textColor;
  final double? circleSize;
  final double? spacing;

  const _NumberedProgressStyle(
      {this.activeColor = Colors.black87,
      this.inactiveColor = const Color(0xFFe0e0e0),
      this.textColor,
      this.circleSize,
      this.spacing});

  @override
  Widget build(BuildContext context, int currentStep, int totalSteps) {
    final effectiveTextColor = textColor ??
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

class _SegmentProgressStyle extends JourneyProgressStyle {
  final Color activeColor;
  final Color inactiveColor;
  final double? height;
  final double? spacing;

  const _SegmentProgressStyle(
      {this.activeColor = Colors.black87,
      this.inactiveColor = const Color(0xFFe0e0e0),
      this.height,
      this.spacing});

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

class _CircularProgressStyle extends JourneyProgressStyle {
  final Color activeColor;
  final Color inactiveColor;
  final Color? textColor;
  final double? size;
  final double? thickness;
  final bool showPercentage;

  const _CircularProgressStyle(
      {this.activeColor = Colors.black87,
      this.inactiveColor = const Color(0xFFe0e0e0),
      this.textColor,
      this.size,
      this.thickness,
      this.showPercentage = true});

  @override
  Widget build(BuildContext context, int currentStep, int totalSteps) {
    final percentage = totalSteps == 0 ? 0.0 : (currentStep + 1) / totalSteps;
    final effectiveTextColor = textColor ??
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

class _TimelineProgressStyle extends JourneyProgressStyle {
  final Color activeColor;
  final Color inactiveColor;
  final double? lineThickness;
  final double? dotSize;
  final bool showLabels;

  const _TimelineProgressStyle(
      {this.activeColor = Colors.black87,
      this.inactiveColor = const Color(0xFFe0e0e0),
      this.lineThickness,
      this.dotSize,
      this.showLabels = true});

  @override
  Widget build(BuildContext context, int currentStep, int totalSteps) {
    return JourneyTimelineProgress(
      currentStep: currentStep,
      totalSteps: totalSteps,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      lineThickness: lineThickness ?? 2.0,
      dotSize: dotSize ?? 12.0,
      showLabels: showLabels &&
          totalSteps <= 5, // Example logic: only show labels if few steps
    );
  }
}

class _CustomProgressStyle extends JourneyProgressStyle {
  final Widget Function(BuildContext context, int currentStep, int totalSteps,
      double percentage) builder;

  const _CustomProgressStyle({required this.builder});

  @override
  Widget build(BuildContext context, int currentStep, int totalSteps) {
    final percentage = totalSteps == 0 ? 0.0 : (currentStep + 1) / totalSteps;
    return builder(context, currentStep, totalSteps, percentage);
  }
}
