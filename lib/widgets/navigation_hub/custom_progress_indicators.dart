import 'package:flutter/material.dart';
import '/localization/app_localization.dart';

/// A dot-based progress indicator for journeys
class JourneyDotProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color activeColor;
  final Color inactiveColor;
  final double dotSize;
  final double spacing;

  const JourneyDotProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.activeColor,
    required this.inactiveColor,
    this.dotSize = 10.0,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing / 2),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isActive ? dotSize * 1.5 : dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(dotSize / 2),
            ),
          ),
        );
      }),
    );
  }
}

/// A numbered step progress indicator for journeys
class JourneyNumberedProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color activeColor;
  final Color inactiveColor;
  final Color textColor;
  final double circleSize;
  final double spacing;

  const JourneyNumberedProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.activeColor,
    required this.inactiveColor,
    required this.textColor,
    this.circleSize = 28.0,
    this.spacing = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    // Limit the number of circles to show to prevent overflow
    final maxCirclesToShow = 5;

    // If too many steps, show simplified version
    if (totalSteps > maxCirclesToShow) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNumberCircle(currentStep),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing),
            child: Text(
              'of'.tr(),
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildNumberCircle(totalSteps - 1, isTotal: true),
        ],
      );
    }

    // Standard display with all step numbers
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        // Add connecting line between circles except after the last one
        if (index < totalSteps - 1) {
          return Row(
            children: [
              _buildNumberCircle(index),
              Container(
                width: spacing * 3,
                height: 2,
                color: index < currentStep ? activeColor : inactiveColor,
              ),
            ],
          );
        } else {
          return _buildNumberCircle(index);
        }
      }),
    );
  }

  Widget _buildNumberCircle(int index, {bool isTotal = false}) {
    final isActive = index <= currentStep && !isTotal;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        color: isActive ? activeColor : inactiveColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? activeColor : inactiveColor,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: TextStyle(
            color: isActive ? Colors.white : textColor,
            fontWeight: FontWeight.bold,
            fontSize: circleSize * 0.4,
          ),
        ),
      ),
    );
  }
}

/// A segmented progress bar for journeys
class JourneySegmentProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color activeColor;
  final Color inactiveColor;
  final double height;
  final double spacing;

  const JourneySegmentProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.activeColor,
    required this.inactiveColor,
    this.height = 4.0,
    this.spacing = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: height,
              decoration: BoxDecoration(
                color: isActive ? activeColor : inactiveColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// A circular progress indicator for journeys
class JourneyCircularProgress extends StatelessWidget {
  final double percentage;
  final Color activeColor;
  final Color inactiveColor;
  final Color textColor;
  final double size;
  final double thickness;
  final bool showPercentage;

  const JourneyCircularProgress({
    super.key,
    required this.percentage,
    required this.activeColor,
    required this.inactiveColor,
    required this.textColor,
    this.size = 40.0,
    this.thickness = 4.0,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: percentage,
            backgroundColor: inactiveColor,
            valueColor: AlwaysStoppedAnimation<Color>(activeColor),
            strokeWidth: thickness,
          ),
          if (showPercentage)
            Text(
              '${(percentage * 100).round()}%',
              style: TextStyle(
                color: textColor,
                fontSize: size * 0.3,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}

/// A timeline-style progress indicator for journeys
class JourneyTimelineProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color activeColor;
  final Color inactiveColor;
  final double lineThickness;
  final double dotSize;
  final bool showLabels;

  const JourneyTimelineProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.activeColor,
    required this.inactiveColor,
    this.lineThickness = 2.0,
    this.dotSize = 12.0,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: showLabels ? 50.0 : 24.0,
      child: Row(
        children: List.generate(totalSteps * 2 - 1, (index) {
          // Even indices are dots, odd indices are connecting lines
          if (index % 2 == 0) {
            // This is a dot (step indicator)
            final stepIndex = index ~/ 2;
            final isActive = stepIndex <= currentStep;
            final isCurrent = stepIndex == currentStep;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: isActive ? activeColor : inactiveColor,
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(
                            color: activeColor,
                            width: 2,
                          )
                        : null,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color:
                                  activeColor.withAlpha((255.0 * 0.3).round()),
                              blurRadius: 4,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                ),
                if (showLabels)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Step ${stepIndex + 1}'.tr(),
                      style: TextStyle(
                        color: isActive ? activeColor : inactiveColor,
                        fontSize: 10,
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
              ],
            );
          } else {
            // This is a connecting line
            final beforeIndex = index ~/ 2;
            final isActive = beforeIndex <= currentStep - 1;

            return Expanded(
              child: Container(
                height: lineThickness,
                color: isActive ? activeColor : inactiveColor,
              ),
            );
          }
        }),
      ),
    );
  }
}
