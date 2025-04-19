import 'package:flutter/material.dart';
import '/widgets/navigation_hub/journey_progress_style.dart';
import '/widgets/ny_state.dart';
import '/widgets/navigation_hub/journey_helper.dart';
import '/widgets/navigation_hub/navigation_hub.dart';

/// A specialized state class for journey pages in NavigationHub journey layouts
///
/// This class extends [NyState] with journey-specific functionality to make it easier
/// to create onboarding flows and multi-step journeys.
abstract class JourneyState<T extends StatefulWidget> extends NyState<T> {
  JourneyState({super.path, required this.navigationHubState});

  /// The state name of the navigation hub
  final String navigationHubState;

  /// Journey helper for navigation control and status information
  late final JourneyHelper _journeyHelper = JourneyHelper(navigationHubState);

  /// Get the journey helper instance
  JourneyHelper get journeyHelper => _journeyHelper;

  /// The current step index (0-based)
  int get currentStep => _journeyHelper.getCurrentStep();

  /// The total number of steps
  int get totalSteps => _journeyHelper.getTotalSteps();

  /// Whether this is the first step
  bool get isFirstStep => _journeyHelper.isFirstStep();

  /// Whether this is the last step
  bool get isLastStep => _journeyHelper.isLastStep();

  /// The completion percentage (0.0 to 1.0)
  double get completionPercentage => _journeyHelper.getCompletionPercentage();

  /// Navigate to the next step - returns true if successful
  /// For use when explicitly wanting to navigate, typically from a button press
  Future<bool> nextStep() async => await _journeyHelper.nextStep();

  /// Navigate to the previous step - returns true if successful
  /// For use when explicitly wanting to navigate, typically from a button press
  Future<bool> previousStep() async => await _journeyHelper.previousStep();

  /// Jump to a specific step by index
  void goToStep(int stepIndex) => _journeyHelper.goToStep(stepIndex);

  /// Jump to the first step
  void goToFirstStep() => _journeyHelper.goToStep(0);

  /// Jump to the last step
  void goToLastStep() => _journeyHelper.goToStep(totalSteps - 1);

  /// Jump to the next step
  void goToNextStep() {
    if (isLastStep) {
      return;
    }
    _journeyHelper.goToStep(currentStep + 1);
  }

  /// Jump to the previous step
  void goToPreviousStep() {
    if (isFirstStep) {
      return;
    }
    _journeyHelper.goToStep(currentStep - 1);
  }

  /// Reset the current step
  void resetCurrentStep() => _journeyHelper.resetCurrentStep();

  /// Check if the journey can continue to the next step
  /// Override this method to add validation logic
  Future<bool> canContinue() async => true;

  /// Called before navigating to the next step
  /// Override this method to perform actions before continuing
  Future<void> onBeforeNext() async {}

  /// Called after navigating to the next step
  /// Override this method to perform actions after continuing
  Future<void> onAfterNext() async {}

  /// Called when unable to continue (canContinue returns false)
  /// Override this method to handle validation failures
  Future<void> onCannotContinue() async {}

  /// Called when the journey is complete (at the last step)
  /// Override this method to perform completion actions
  Future<void> onComplete() async {}

  /// Attempt to continue to the next step with validation
  Future<bool> attemptContinue() async {
    if (!await canContinue()) {
      await onCannotContinue();
      return false;
    }

    await onBeforeNext();

    if (isLastStep) {
      await onComplete();
      return true;
    }

    bool success = await nextStep();
    if (success) {
      await onAfterNext();
    }

    return success;
  }

  /// Simple helper for navigating to the next step
  /// This combines validation logic with navigation
  Future<void> onNextPressed() async {
    await attemptContinue();
  }

  /// Simple helper for navigating to the previous step
  Future<void> onBackPressed() async {
    await previousStep();
  }

  /// Build a content widget with optional journey progress indicators and navigation buttons
  Widget buildJourneyContent({
    required Widget content,
    Widget? nextButton,
    Widget? backButton,
    ProgressIndicatorPosition progressPosition = ProgressIndicatorPosition.top,
    JourneyProgressStyle? progressStyle,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.all(16.0),
    EdgeInsets? progressIndicatorPadding,
    Widget? header,
    Widget? footer,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) {
    return JourneyContent(
      content: content,
      currentStep: currentStep,
      totalSteps: totalSteps,
      isFirstStep: isFirstStep,
      isLastStep: isLastStep,
      nextButton: nextButton,
      backButton: backButton,
      showProgress: progressStyle != null ? true : false,
      progressIndicatorPosition: progressPosition,
      progressStyle: progressStyle ?? const JourneyProgressStyle.linear(),
      progressIndicatorPadding: progressIndicatorPadding,
      contentPadding: contentPadding,
      header: header,
      footer: footer,
      crossAxisAlignment: crossAxisAlignment,
    );
  }

  /// Build a full-screen journey page with customizable elements
  Widget buildJourneyPage({
    required Widget content,
    Widget? nextButton,
    Widget? backButton,
    ProgressIndicatorPosition progressPosition = ProgressIndicatorPosition.top,
    JourneyProgressStyle? progressStyle,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.all(16.0),
    EdgeInsets? progressIndicatorPadding,
    Widget? header,
    Widget? footer,
    Color? backgroundColor,
    Widget? appBar,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar is PreferredSizeWidget ? appBar : null,
      body: SafeArea(
        child: buildJourneyContent(
          content: content,
          nextButton: nextButton,
          backButton: backButton,
          progressPosition: progressPosition,
          progressStyle: progressStyle,
          progressIndicatorPadding: progressIndicatorPadding,
          contentPadding: contentPadding,
          header: header,
          footer: footer,
          crossAxisAlignment: crossAxisAlignment,
        ),
      ),
    );
  }
}

/// A reusable content widget for journey pages
class JourneyContent extends StatelessWidget {
  /// The main content of the journey step
  final Widget content;

  /// The current step index (0-based)
  final int currentStep;

  /// The total number of steps
  final int totalSteps;

  /// Whether this is the first step
  final bool isFirstStep;

  /// Whether this is the last step
  final bool isLastStep;

  /// Next button widget (optional)
  final Widget? nextButton;

  /// Back button widget (optional)
  final Widget? backButton;

  /// Whether to show the progress indicator
  final bool showProgress;

  /// The padding of the progress indicator
  final EdgeInsets? progressIndicatorPadding;

  /// The position of the progress indicator
  final ProgressIndicatorPosition progressIndicatorPosition;

  /// The padding around the content
  final EdgeInsetsGeometry contentPadding;

  /// Optional header widget
  final Widget? header;

  /// Optional footer widget
  final Widget? footer;

  /// The cross axis alignment of the content
  final CrossAxisAlignment crossAxisAlignment;

  /// The style of the progress indicator
  final JourneyProgressStyle progressStyle;

  const JourneyContent({
    super.key,
    required this.content,
    required this.currentStep,
    required this.totalSteps,
    required this.isFirstStep,
    required this.isLastStep,
    this.nextButton,
    this.backButton,
    this.showProgress = true,
    this.progressIndicatorPadding,
    this.progressStyle = const JourneyProgressStyle.linear(),
    this.progressIndicatorPosition = ProgressIndicatorPosition.top,
    this.contentPadding = const EdgeInsets.all(16.0),
    this.header,
    this.footer,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    // Build progress indicator
    Widget? progressIndicator;
    if (showProgress) {
      progressIndicator = Padding(
        padding: progressIndicatorPadding ??
            (const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)),
        child: _buildProgressIndicator(context),
      );
    }

    return Padding(
      padding: contentPadding,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          // Top progress indicator
          if (showProgress &&
              progressIndicatorPosition == ProgressIndicatorPosition.top)
            progressIndicator!,

          // Header if provided
          if (header != null) header!,

          // Main content - removed the Expanded+SingleScrollView combination
          Flexible(
            child: content,
          ),

          // Footer if provided
          if (footer != null) footer!,

          // Bottom progress indicator
          if (showProgress &&
              progressIndicatorPosition == ProgressIndicatorPosition.bottom)
            progressIndicator!,

          // Navigation buttons
          if (nextButton != null || backButton != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (backButton != null)
                    Flexible(child: backButton ?? const SizedBox.shrink()),
                  if (nextButton != null)
                    Flexible(child: nextButton ?? const SizedBox.shrink()),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the appropriate progress indicator based on style
  Widget _buildProgressIndicator(BuildContext context) {
    // Use the build method from the progressStyle object to handle different style types
    return progressStyle.build(context, currentStep, totalSteps);
  }
}
