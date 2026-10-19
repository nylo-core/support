import 'controller.dart';
import '/helpers/ny_helpers.dart';
import '/widgets/src/form/validation.dart';

/// Base NyController
class NyController extends BaseController {
  /// Set this to true if you want to use a singleton controller
  bool get singleton => false;

  NyController({super.context, super.request});

  /// Updates the page [state]
  /// Provide an [action] and [data] to call a method in the [NyState].
  void updatePageState(String action, dynamic data) {
    assert(state != null, "State cannot be null");
    if (state == null) return;
    updateState(state!, data: {"action": action, "data": data});
  }

  /// Refreshes the page
  void refreshPage() {
    if (state == null) return;
    StateAction.refreshPage(state!);
  }

  /// Set the state of the page
  void setState({required Function() setState}) {
    if (state == null) return;
    StateAction.setState(state!, setState);
  }

  /// Pop the page
  void pop({dynamic result, bool rootNavigator = false}) {
    if (state == null) return;
    StateAction.pop(state!, result: result, rootNavigator: rootNavigator);
  }

  /// Displays a Toast message containing "Sorry" for the title, you
  /// only need to provide a [description].
  void showToastSorry({String? title, required String description}) {
    if (state == null) return;
    StateAction.showToastSorry(state!, title: title, description: description);
  }

  /// Displays a Toast message containing "Warning" for the title, you
  /// only need to provide a [description].
  void showToastWarning({String? title, required String description}) {
    if (state == null) return;
    StateAction.showToastWarning(
      state!,
      title: title,
      description: description,
    );
  }

  /// Displays a Toast message containing "Info" for the title, you
  /// only need to provide a [description].
  void showToastInfo({String? title, required String description}) {
    if (state == null) return;
    StateAction.showToastInfo(state!, title: title, description: description);
  }

  /// Displays a Toast message containing "Error" for the title, you
  /// only need to provide a [description].
  void showToastDanger({String? title, required String description}) {
    if (state == null) return;
    StateAction.showToastDanger(state!, title: title, description: description);
  }

  /// Displays a Toast message containing "Oops" for the title, you
  /// only need to provide a [description].
  void showToastOops({String? title, required String description}) {
    if (state == null) return;
    StateAction.showToastOops(state!, title: title, description: description);
  }

  /// Displays a Toast message containing "Success" for the title, you
  /// only need to provide a [description].
  void showToastSuccess({String? title, required String description}) {
    if (state == null) return;
    StateAction.showToastSuccess(
      state!,
      title: title,
      description: description,
    );
  }

  /// Display a custom Toast message.
  /// Use [id] to specify a custom toast style registered via [Nylo.addToastNotifications].
  void showToastCustom({
    String? title,
    String? description,
    String? id,
    Map<String, dynamic>? data,
  }) {
    if (state == null) return;
    StateAction.showToastCustom(
      state!,
      title: title,
      description: description ?? '',
      id: id,
      data: data,
    );
  }

  /// Validate data from your widget.
  void validate({
    required Map<String, dynamic> rules,
    Map<String, dynamic>? data,
    Map<String, dynamic>? messages,
    bool showAlert = true,
    Duration? alertDuration,
    String alertStyle = 'warning',
    required Function()? onSuccess,
    Function(Exception exception)? onFailure,
    String? lockRelease,
  }) {
    updatePageState("validate", {
      "rules": rules,
      "data": data,
      "messages": messages,
      "showAlert": showAlert,
      "alertDuration": alertDuration,
      "alertStyle": alertStyle,
      "onSuccess": onSuccess,
      "onFailure": onFailure,
      "lockRelease": lockRelease,
    });
  }

  /// Check data against validation rules from the controller.
  ///
  /// Works the same as `check()` in a page: the callback receives a list
  /// of validators, `.that()` adds one for a value and returns it so rules
  /// can be chained, and every validator is checked once the callback
  /// returns. The results come back as a [FormValidationResponseBag].
  ///
  /// ```dart
  /// check((validate) {
  ///   validate.that(email.text, label: "Email").email();
  ///   validate.that(password.text, label: "Password").notEmpty();
  /// }, onSuccess: () {
  ///   submit();
  /// }, onValidationError: (bag) {
  ///   showToastDanger(description: bag.firstErrorMessage ?? '');
  /// });
  /// ```
  ///
  /// Unlike [validate], this runs here rather than in the page, so it
  /// works without a [state] and the controller keeps the result.
  FormValidationResponseBag check(
    Function(List<FormValidator>) validate, {
    Function()? onSuccess,
    Function(FormValidationResponseBag)? onValidationError,
  }) {
    List<FormValidator> allValidators = [];
    validate(allValidators);

    FormValidationResponseBag bag = [
      for (FormValidator validator in allValidators) validator.check(),
    ];

    if (onValidationError != null && !bag.isValid) {
      onValidationError(bag);
    }
    if (onSuccess != null && bag.isValid) {
      onSuccess();
    }
    return bag;
  }

  /// Update the language in the application
  void changeLanguage(String language, {bool restartState = true}) {
    if (state == null) return;
    StateAction.changeLanguage(
      state!,
      language: language,
      restartState: restartState,
    );
  }

  /// Perform a lock release. An [Exception] from [perform] goes to [onError]
  /// (see [NyBaseState.lockRelease]).
  void lockRelease(
    String name, {
    required Function perform,
    bool shouldSetState = true,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    if (state == null) return;
    StateAction.lockRelease(
      state!,
      name,
      perform: perform,
      shouldSetState: shouldSetState,
      onError: onError,
    );
  }

  /// Perform a confirm action
  void confirmAction(
    Function() action, {
    required String title,
    String dismissText = "nylo.confirm_action.cancel",
  }) {
    if (state == null) return;
    StateAction.confirmAction(
      state!,
      action: action,
      title: title,
      dismissText: dismissText,
    );
  }
}
