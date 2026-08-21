import 'package:flutter/material.dart';
import '/helpers/ny_helpers.dart';
import '/widgets/ny_widgets.dart';

/// A specialized state class for journey pages in NavigationHub journey layouts
///
/// This class extends [NyState] with journey-specific functionality to make it easier
/// to create onboarding flows and multi-step journeys.
abstract class JourneyState<T extends StatefulWidget> extends NyState<T> {
  JourneyState({super.name, super.path, required this.navigationHubState});

  /// The state name of the navigation hub
  final String navigationHubState;

  /// Actions for controlling the navigation hub
  late final NavigationHubStateActions _actions = NavigationHubStateActions(
    navigationHubState,
  );

  /// Callback when journey completes (override in last step for custom completion logic)
  void Function()? get onJourneyComplete => null;

  /// The current step index (0-based)
  int get currentStep {
    final data = Backpack.instance.read('${navigationHubState}_current_tab');
    return (data is int) ? data : 0;
  }

  /// The total number of steps
  int get totalSteps {
    final data = Backpack.instance.read('${navigationHubState}_total_pages');
    return (data is int) ? data : 0;
  }

  /// Whether this is the first step
  bool get isFirstStep => currentStep == 0;

  /// Whether this is the last step
  bool get isLastStep => totalSteps > 0 && currentStep >= totalSteps - 1;

  /// The completion percentage (0.0 to 1.0)
  double get completionPercentage =>
      totalSteps == 0 ? 0.0 : (currentStep + 1) / totalSteps;

  /// Navigate to the next step - returns true if successful
  /// For use when explicitly wanting to navigate, typically from a button press
  /// Set [force] to true to bypass validation and directly navigate
  Future<bool> nextStep({bool force = false}) async {
    if (force) {
      return await _actions.nextPage();
    }

    // Validation logic
    if (!await canContinue()) {
      return false;
    }

    await onBeforeNext();

    if (isLastStep) {
      await onComplete();
      return true;
    }

    bool success = await _actions.nextPage();
    if (success) {
      await onAfterNext();
    }

    return success;
  }

  /// Navigate to the previous step - returns true if successful
  /// For use when explicitly wanting to navigate, typically from a button press
  Future<bool> previousStep() async => await _actions.previousPage();

  /// Jump to a specific step by index
  void goToStep(int stepIndex) => _actions.currentTabIndex(stepIndex);

  /// Jump to the first step
  void goToFirstStep() => goToStep(0);

  /// Jump to the last step
  void goToLastStep() => goToStep(totalSteps - 1);

  /// Jump to the next step
  void goToNextStep() {
    if (isLastStep) {
      return;
    }
    goToStep(currentStep + 1);
  }

  /// Jump to the previous step
  void goToPreviousStep() {
    if (isFirstStep) {
      return;
    }
    goToStep(currentStep - 1);
  }

  void exitJourney() => Navigator.of(context, rootNavigator: true).pop();

  /// Reset the current step
  void resetCurrentStep() => _actions.resetTabIndex(currentStep);

  /// Check if the journey can continue to the next step
  /// Override this method to add validation logic
  Future<bool> canContinue() async => true;

  /// Called before navigating to the next step
  /// Override this method to perform actions before continuing
  Future<void> onBeforeNext() async {}

  /// Called after navigating to the next step
  /// Override this method to perform actions after continuing
  Future<void> onAfterNext() async {}

  /// Called when the journey is complete (at the last step)
  /// Override this method to perform completion actions
  Future<void> onComplete() async {}

  /// Attempt to continue to the next step with validation
  Future<bool> attemptContinue() async => await nextStep();

  /// Simple helper for navigating to the previous step
  Future<void> onBackPressed() async {
    await previousStep();
  }

  /// Build a content widget with optional navigation buttons
  Widget buildJourneyContent({
    required Widget content,
    Widget? nextButton,
    Widget? backButton,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.all(16.0),
    Widget? header,
    Widget? footer,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) {
    return JourneyContent(
      content: content,
      nextButton: nextButton,
      backButton: backButton,
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
    EdgeInsetsGeometry contentPadding = const EdgeInsets.all(16.0),
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

  /// Next button widget (optional)
  final Widget? nextButton;

  /// Back button widget (optional)
  final Widget? backButton;

  /// The padding around the content
  final EdgeInsetsGeometry contentPadding;

  /// Optional header widget
  final Widget? header;

  /// Optional footer widget
  final Widget? footer;

  /// The cross axis alignment of the content
  final CrossAxisAlignment crossAxisAlignment;

  const JourneyContent({
    super.key,
    required this.content,
    this.nextButton,
    this.backButton,
    this.contentPadding = const EdgeInsets.all(16.0),
    this.header,
    this.footer,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: contentPadding,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          // Header if provided
          if (header != null) header!,

          // Main content
          Expanded(child: content),

          // Footer if provided
          if (footer != null) footer!,

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
}
