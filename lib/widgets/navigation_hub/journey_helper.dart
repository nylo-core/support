import '/helpers/backpack.dart';
import '/widgets/navigation_hub/navigation_hub.dart';

/// A helper class for journey navigation
class JourneyHelper {
  final String navigationHubState;

  /// Create a new journey helper for the given navigation hub state
  JourneyHelper(this.navigationHubState);

  /// Get the current step index (0-based)
  int getCurrentStep() {
    final currentData =
        Backpack.instance.read('${navigationHubState}_current_tab');
    return (currentData is int) ? currentData : 0;
  }

  /// Get the total number of steps
  int getTotalSteps() {
    final totalPagesData =
        Backpack.instance.read('${navigationHubState}_total_pages');
    return (totalPagesData is int) ? totalPagesData : 0;
  }

  /// Check if this is the first step
  bool isFirstStep() {
    return getCurrentStep() == 0;
  }

  /// Check if this is the last step
  bool isLastStep() {
    final currentStep = getCurrentStep();
    final totalSteps = getTotalSteps();
    return currentStep >= totalSteps - 1;
  }

  /// Get the completion percentage (0.0 to 1.0)
  double getCompletionPercentage() {
    final currentStep = getCurrentStep();
    final totalSteps = getTotalSteps();

    if (totalSteps == 0) return 0.0;
    return (currentStep + 1) / totalSteps;
  }

  /// Navigate to the next step, returns false if already at the last step
  Future<bool> nextStep() async {
    final actions = NavigationHubStateActions(navigationHubState);
    return await actions.nextPage();
  }

  /// Navigate to the previous step, returns false if already at the first step
  Future<bool> previousStep() async {
    final actions = NavigationHubStateActions(navigationHubState);
    return await actions.previousPage();
  }

  /// Jump to a specific step by index
  void goToStep(int stepIndex) {
    final actions = NavigationHubStateActions(navigationHubState);
    actions.currentTabIndex(stepIndex);
  }

  /// Reset the current step
  void resetCurrentStep() {
    final actions = NavigationHubStateActions(navigationHubState);
    actions.resetTabIndex(getCurrentStep());
  }
}
