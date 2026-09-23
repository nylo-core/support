import 'package:nylo_support/ny_core.dart';

/// Actions for a page, addressed by the state name its [NyPage] listens on.
///
/// Build one from the page's `path` and keep it on the page class, so every
/// call site reads the page it reaches:
///
/// ```dart
/// class HomePage extends NyStatefulWidget<HomeController> {
///   static RouteView path = ("/home", (_) => HomePage());
///   static final actions = path.actions;
///
///   HomePage({super.key}) : super(child: () => _HomePageState());
/// }
///
/// HomePage.actions.showToast("hello");
/// HomePage.actions.call("shake_the_logo", {"times": 3});
/// ```
///
/// Every built-in method here is handled by [NyBaseState.stateUpdated], so the
/// same object drives a `NyState` widget when built from its state name:
/// `PageStateActions(Cart.state)`. A named action sent with [call] runs the
/// handler registered under that name in the target's `stateActions`.
///
/// ## Typed actions
///
/// Subclass this and declare methods **without a body**. Each one is sent to
/// the target as a typed action - the method's name as a [Symbol], with the
/// arguments it was called with - and the target registers its handler under
/// that symbol:
///
/// ```dart
/// class HomePageActions extends PageStateActions {
///   HomePageActions(super.state);
///
///   void shakeTheLogo({int times = 1}); // no body: sent by noSuchMethod
///   void setStars(int stars);
/// }
///
/// class HomePage extends NyStatefulWidget<HomeController> {
///   static RouteView path = ("/home", (_) => HomePage());
///   static final actions = HomePageActions(path);
///   ...
/// }
///
/// class _HomePageState extends NyPage<HomePage> {
///   @override
///   Map<Object, Function> get stateActions => {
///     #shakeTheLogo: shakeTheLogo,
///     #setStars: setStars,
///   };
///
///   void shakeTheLogo({int times = 1}) { ... }
///   void setStars(int stars) { ... }
/// }
///
/// HomePage.actions.shakeTheLogo(times: 3);
/// ```
///
/// Register the handlers with symbol literals (`#shakeTheLogo`), never with
/// `Symbol("shakeTheLogo")`: under `flutter build --obfuscate` a literal is
/// renamed together with the method it names, a symbol built from a string
/// is not. A bodiless action returns `void`; its handler runs on the target
/// once the event bus delivers it.
class PageStateActions extends StateActions {
  /// [state] is a page's `path` (a [RouteView]) or a state name. Pass [id] to
  /// reach one instance of a `NyStateManaged` widget, as [stateAction] does.
  PageStateActions(dynamic state, {String? id})
    : super(_resolveStateName(state, id: id));

  static String _resolveStateName(dynamic state, {String? id}) {
    final String name;
    if (state is RouteView) {
      name = state.stateName();
    } else if (state is String) {
      name = state;
    } else {
      throw ArgumentError.value(
        state,
        'state',
        "Pass the page's path (a RouteView) or its state name",
      );
    }
    return id == null ? name : "${name}_$id";
  }

  /// Sends a method a subclass declared without a body as a typed action.
  ///
  /// Dart routes a call to such a method here, as an [Invocation]. A getter or
  /// setter is not an action, so it falls through and throws as usual.
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (!invocation.isMethod) return super.noSuchMethod(invocation);
    updateState(
      state,
      data: {
        "action": invocation.memberName,
        "args": invocation.positionalArguments,
        "named": invocation.namedArguments,
      },
    );
    return null;
  }

  /// Show a toast with [description].
  ///
  /// [id] picks the style, `success` unless given; a style registered via
  /// [Nylo.addToastNotifications] works too.
  void showToast(
    String description, {
    String? title,
    String id = 'success',
    Duration? duration,
    Map<String, dynamic>? data,
  }) {
    action(
      "toast-custom",
      data: {
        "title": title,
        "description": description,
        "id": id,
        "duration": duration,
        "data": data,
      },
    );
  }

  /// Refresh the page, re-running its `init`. Pass [setState] to change the
  /// page's fields and rebuild it instead.
  void refreshPage({Function()? setState}) {
    StateAction.refreshPage(state, setState: setState);
  }

  /// Run [setState] on the page, then rebuild it.
  void setState(Function() setState) {
    StateAction.setState(state, setState);
  }

  /// Pop the page.
  void pop({dynamic result, bool rootNavigator = false}) {
    StateAction.pop(state, result: result, rootNavigator: rootNavigator);
  }

  /// Displays a Toast message containing "Sorry" for the title, you
  /// only need to provide a [description].
  void showToastSorry({String? title, required String description}) {
    StateAction.showToastSorry(state, title: title, description: description);
  }

  /// Displays a Toast message containing "Warning" for the title, you
  /// only need to provide a [description].
  void showToastWarning({String? title, required String description}) {
    StateAction.showToastWarning(state, title: title, description: description);
  }

  /// Displays a Toast message containing "Info" for the title, you
  /// only need to provide a [description].
  void showToastInfo({String? title, required String description}) {
    StateAction.showToastInfo(state, title: title, description: description);
  }

  /// Displays a Toast message containing "Error" for the title, you
  /// only need to provide a [description].
  void showToastDanger({String? title, required String description}) {
    StateAction.showToastDanger(state, title: title, description: description);
  }

  /// Displays a Toast message containing "Oops" for the title, you
  /// only need to provide a [description].
  void showToastOops({String? title, required String description}) {
    StateAction.showToastOops(state, title: title, description: description);
  }

  /// Displays a Toast message containing "Success" for the title, you
  /// only need to provide a [description].
  void showToastSuccess({String? title, required String description}) {
    StateAction.showToastSuccess(state, title: title, description: description);
  }

  /// Display a custom Toast message.
  /// Use [id] to specify a custom toast style registered via [Nylo.addToastNotifications].
  void showToastCustom({
    String? title,
    String? description,
    String? id,
    Map<String, dynamic>? data,
  }) {
    StateAction.showToastCustom(
      state,
      title: title,
      description: description ?? '',
      id: id,
      data: data,
    );
  }

  /// Update the language in the application
  void changeLanguage(String language, {bool restartState = true}) {
    StateAction.changeLanguage(
      state,
      language: language,
      restartState: restartState,
    );
  }

  /// Ask the user to confirm [action] before it runs.
  void confirmAction(
    Function() action, {
    required String title,
    String dismissText = "nylo.confirm_action.cancel",
  }) {
    StateAction.confirmAction(
      state,
      action: action,
      title: title,
      dismissText: dismissText,
    );
  }

  /// Run [perform] and block it from running again until it has finished.
  void lockRelease(
    String name, {
    required Function perform,
    bool shouldSetState = true,
  }) {
    StateAction.lockRelease(
      state,
      name,
      perform: perform,
      shouldSetState: shouldSetState,
    );
  }

  /// Validate [data] against [rules] on the page.
  void validate({
    required Map<String, dynamic> rules,
    Map<String, dynamic>? data,
    Map<String, dynamic>? messages,
    bool showAlert = true,
    Duration? alertDuration,
    String alertStyle = 'warning',
    Function()? onSuccess,
    Function(Exception exception)? onFailure,
    String? lockRelease,
  }) {
    action(
      "validate",
      data: {
        "rules": rules,
        "data": data,
        "messages": messages,
        "showAlert": showAlert,
        "alertDuration": alertDuration,
        "alertStyle": alertStyle,
        "onSuccess": onSuccess,
        "onFailure": onFailure,
        "lockRelease": lockRelease,
      },
    );
  }
}
