import 'state.dart';
import 'extensions.dart';
import '/router/ny_router.dart';

/// [StateAction] class
class StateAction {
  /// Helper to find the state name
  static String _findStateName(dynamic state) {
    if (state is String) {
      return state;
    }
    if (state is RouteView) {
      return state.stateName();
    }
    return "";
  }

  /// Refresh the page
  static void refreshPage(dynamic state, {Function()? setState}) {
    _updateState(_findStateName(state), "refresh-page", {"setState": setState});
  }

  /// Set the state of the page
  static void setState(dynamic state, Function() setState) {
    _updateState(_findStateName(state), "set-state", {"setState": setState});
  }

  /// Pop the page
  static void pop(dynamic state, {dynamic result, bool rootNavigator = false}) {
    _updateState(_findStateName(state), "pop", {
      "result": result,
      "rootNavigator": rootNavigator,
    });
  }

  /// Displays a Toast message containing "Sorry" for the title, you
  /// only need to provide a [description].
  static void showToastSorry(
    dynamic state, {
    String? title,
    required String description,
  }) {
    _updateState(_findStateName(state), "toast-sorry", {
      "title": title ?? "Sorry",
      "description": description,
    });
  }

  /// Displays a Toast message containing "Warning" for the title, you
  /// only need to provide a [description].
  static void showToastWarning(
    dynamic state, {
    String? title,
    required String description,
  }) {
    _updateState(_findStateName(state), "toast-warning", {
      "title": title ?? "Warning",
      "description": description,
    });
  }

  /// Displays a Toast message containing "Info" for the title, you
  /// only need to provide a [description].
  static void showToastInfo(
    dynamic state, {
    String? title,
    required String description,
  }) {
    _updateState(_findStateName(state), "toast-info", {
      "title": title ?? "Info",
      "description": description,
    });
  }

  /// Displays a Toast message containing "Error" for the title, you
  /// only need to provide a [description].
  static void showToastDanger(
    dynamic state, {
    String? title,
    required String description,
  }) {
    _updateState(_findStateName(state), "toast-danger", {
      "title": title ?? "Error",
      "description": description,
    });
  }

  /// Displays a Toast message containing "Oops" for the title, you
  /// only need to provide a [description].
  static void showToastOops(
    dynamic state, {
    String? title,
    required String description,
  }) {
    _updateState(_findStateName(state), "toast-oops", {
      "title": title ?? "Oops",
      "description": description,
    });
  }

  /// Displays a Toast message containing "Success" for the title, you
  /// only need to provide a [description].
  static void showToastSuccess(
    dynamic state, {
    String? title,
    required String description,
  }) {
    _updateState(_findStateName(state), "toast-success", {
      "title": title ?? "Success",
      "description": description,
    });
  }

  /// Display a custom Toast message.
  /// Use [id] to specify a custom toast style registered via [Nylo.addToastNotifications].
  static void showToastCustom(
    dynamic state, {
    String? title,
    required String description,
    String? id,
    Map<String, dynamic>? data,
  }) {
    _updateState(_findStateName(state), "toast-custom", {
      "title": title ?? "",
      "description": description,
      "id": id,
      "data": data,
    });
  }

  /// Update the language in the application
  static void changeLanguage(
    dynamic state, {
    required String language,
    bool restartState = true,
  }) {
    _updateState(_findStateName(state), "change-language", {
      "language": language,
      "restartState": restartState,
    });
  }

  /// Perform a confirm action
  static Future<void> confirmAction(
    dynamic state, {
    required Function() action,
    required String title,
    String dismissText = "Cancel",
  }) async {
    _updateState(_findStateName(state), "confirm-action", {
      "action": action,
      "title": title,
      "dismissText": dismissText,
    });
  }

  /// Perform a lock release
  /// The [lockRelease] method will call the function provided in [perform]
  /// and then block the function from being called again until it has finished.
  static void lockRelease(
    dynamic state,
    String name, {
    required Function perform,
    bool shouldSetState = true,
  }) {
    _updateState(_findStateName(state), "lock-release", {
      "name": name,
      "perform": perform,
      "shouldSetState": shouldSetState,
    });
  }

  /// Updates the page [state]
  /// Provide an [action] and [data] to call a method in the [NyState].
  static void _updateState(dynamic state, String action, dynamic data) {
    updateState(state, data: {"action": action, "data": data});
  }
}
