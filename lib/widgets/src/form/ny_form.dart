import 'dart:async';

import 'package:flutter/material.dart';
import '/helpers/ny_helpers.dart';
import '/widgets/ny_widgets.dart';

export 'form_data.dart';
export 'form_submittable.dart';
export 'validation.dart';
export 'field.dart';
export 'form_collection.dart';

/// DecoratorTextField is a class that helps in managing form text fields
class DecoratorTextField {
  final InputDecoration Function(dynamic data, InputDecoration inputDecoration)?
  decoration;
  final InputDecoration Function(dynamic data, InputDecoration inputDecoration)?
  successDecoration;
  final InputDecoration Function(dynamic data, InputDecoration inputDecoration)?
  errorDecoration;

  DecoratorTextField({
    this.decoration,
    this.successDecoration,
    this.errorDecoration,
  });
}

/// NyFormWidget is an abstract StatefulWidget for building forms declaratively.
///
/// Extend this class and override [fields] to define your form structure.
/// The form class IS the widget — no separate NyFormData subclass or wrapper needed.
///
/// Example:
/// ```dart
/// class ProfileForm extends NyFormWidget {
///   ProfileForm({super.key, super.submitButton, super.onSubmit, super.onFailure});
///
///   @override
///   List<dynamic> fields() => [
///     Field.text("username"),
///     Field.text("bio"),
///   ];
///
///   static NyFormActions get actions => const NyFormActions('ProfileForm');
/// }
///
/// // Usage:
/// ProfileForm(
///   submitButton: Button.primary(text: "Submit"),
///   onSubmit: (data) { ... },
/// )
///
/// // Actions:
/// ProfileForm.actions.updateField('username', 'JohnDoe');
/// ProfileForm.actions.submit(onSuccess: (data) => print(data));
/// ```
///
/// Learn more: https://nylo.dev/docs/7.x/forms
abstract class NyFormWidget extends StatefulWidget {
  NyFormWidget({
    super.key,
    this.crossAxisSpacing = 10,
    this.mainAxisSpacing = 10,
    this.initialData,
    this.onChanged,
    this.header,
    this.submitButton,
    this.footer,
    this.headerSpacing = 10,
    this.submitButtonSpacing = 10,
    this.footerSpacing = 10,
    this.loadingStyle,
    this.locked = false,
    this.onSubmit,
    this.onFailure,
    String? name,
  }) : _name = name;

  /// The header widget
  final Widget? header;

  /// The submit button widget
  final Widget? submitButton;

  /// The footer widget
  final Widget? footer;

  /// The header spacing
  final double headerSpacing;

  /// The submit button spacing
  final double submitButtonSpacing;

  /// The footer spacing
  final double footerSpacing;

  /// The cross axis spacing for form fields
  final double crossAxisSpacing;

  /// The main axis spacing for form fields
  final double mainAxisSpacing;

  /// The loading style
  final LoadingStyle? loadingStyle;

  /// Callback invoked with the form data when validation passes.
  final Function(dynamic data)? onSubmit;

  /// Callback invoked with validation errors when validation fails.
  final Function(dynamic error)? onFailure;

  /// Lock the form to prevent interaction
  final bool locked;

  /// Initial data to populate form fields
  final Map<String, dynamic>? initialData;

  /// Callback invoked when any field value changes
  final Function(Field field, dynamic value)? onChanged;

  /// Optional explicit form name
  final String? _name;

  /// Override to define form fields
  List<dynamic> fields();

  /// Override for async initial data loading
  Function()? get init => null;

  /// Override for custom field change handling
  void onChange(String field, Map<String, dynamic> data) {}

  /// Form name — defaults to runtimeType.toString()
  String get formName => _name ?? runtimeType.toString();

  /// Get the state name
  static String state(String stateName) {
    return "form_$stateName";
  }

  /// Refresh the state of the form
  static void stateRefresh(String stateName) {
    updateState(state(stateName), data: {"action": "refresh"});
  }

  /// Set field in the form
  static void stateSetValue(String stateName, String key, dynamic value) {
    stateAction(
      "setValue",
      state: state(stateName),
      data: {"key": key, "value": value},
    );
  }

  /// Set field options in the form
  static void stateSetOptions(String stateName, String key, dynamic value) {
    stateAction(
      "setOptions",
      state: state(stateName),
      data: {"key": key, "value": value},
    );
  }

  /// Clear all data in the form
  static void stateClearData(String stateName) {
    updateState(state(stateName), data: {"action": "clear"});
  }

  /// Refresh the form fields
  static void stateRefreshForm(String stateName) {
    updateState(state(stateName), data: {"action": "refresh-form"});
  }

  /// Submit the form
  ///
  /// The returned [Future] completes once the form has validated and
  /// [onSuccess] or [onFailure] has finished, including any [Future] it
  /// returns, so a button whose `onPressed` returns it stays locked until
  /// then. It completes with the error if either callback throws.
  ///
  /// If no form named [name] is mounted, nothing is submitted and the
  /// [Future] completes straight away.
  static Future<void> submit(
    String name, {
    required Function(dynamic value) onSuccess,
    Function(List<FormValidationError>)? onFailure,
    bool showToastError = true,
  }) {
    final String formState = state(name);
    if (!_subscribedForms.containsKey(formState)) {
      _reportUnmountedForm(name);
      return Future.value();
    }

    final Completer<void> completer = Completer<void>();
    stateAction(
      "submit",
      state: formState,
      data: {
        "onSuccess": onSuccess,
        "onFailure": onFailure,
        "showToastError": showToastError,
        "completer": completer,
      },
    );
    return completer.future;
  }

  @override
  // ignore: no_logic_in_create_state
  createState() => _NyFormWidgetState(formName);
}

/// How many mounted form states are listening on each form state name.
///
/// [NyFormWidget.submit] reads it to tell whether a submit will be answered:
/// the event bus drops an update nobody listens for without a trace, which
/// would leave the [Future] it returns - and any button waiting on that
/// Future - pending for good.
final Map<String, int> _subscribedForms = {};

/// Form names already reported by [_reportUnmountedForm].
final Set<String> _reportedUnmountedForms = {};

/// Log, once per name, a submit sent to a form that is not mounted.
///
/// Reported once because a submit button calls this on every tap, and a name
/// that reaches no form on the first tap reaches none on the next.
void _reportUnmountedForm(String name) {
  if (!_reportedUnmountedForms.add(name)) return;

  try {
    NyLogger.error(
      'NyFormWidget.submit: no form named "$name" is mounted, so nothing was '
      'submitted. A form is named after its class unless it is given a name, '
      'so address it by the same name, e.g. '
      "static NyFormActions get actions => const NyFormActions('LoginForm');",
      alwaysPrint: true,
    );
  } catch (_) {
    /// Reporting cannot break submitting: the logger reads the env and
    /// [Nylo.instance], so it throws where neither is registered - a widget
    /// test that pumps a form without booting Nylo.
  }
}

/// Internal NyFormData subclass that delegates fields() and init to the widget.
class _InlineFormData extends NyFormData {
  final List<dynamic> Function() _fieldsBuilder;
  final Function()? _initFn;

  _InlineFormData(String name, this._fieldsBuilder, this._initFn) : super(name);

  @override
  List<dynamic> fields() => _fieldsBuilder();

  @override
  Function()? get init => _initFn;
}

class _NyFormWidgetState extends NyState<NyFormWidget> {
  Widget? _cachedSubmitButton;
  List<Widget>? _cachedFormWidgets;
  Future<List<Widget>>? _formDataFuture;
  late _InlineFormData _formData;

  /// The name this state is counted under in [_subscribedForms], if any.
  String? _subscribedName;

  _NyFormWidgetState(String formName) {
    stateName = 'form_$formName';
  }

  @override
  void initState() {
    super.initState();

    /// Only a state subscribed to the event bus can answer a submit.
    if (eventSubscription != null) {
      _subscribedName = stateName;
      _subscribedForms.update(
        stateName!,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
  }

  @override
  void dispose() {
    final String? subscribedName = _subscribedName;
    if (subscribedName != null) {
      final int remaining = (_subscribedForms[subscribedName] ?? 1) - 1;
      if (remaining > 0) {
        _subscribedForms[subscribedName] = remaining;
      } else {
        _subscribedForms.remove(subscribedName);
      }
    }
    _formData.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    try {
      if (widget.onChanged != null) {
        _formData.onChanged = (Field field, dynamic value) {
          widget.onChanged!(field, value);
        };
      } else {
        _formData.onChanged = null;
      }
      _formData.refreshFields();
      _cachedFormWidgets = null;
      _cachedSubmitButton = _resolveSubmitButton();
      if (_formData.getLoadData is Future Function()) {
        _formDataFuture = Future(() => _createForm());
      }
      setState(() {});
    } catch (e) {
      // Hot reload should never crash the app — rebuild with fresh state
      _cachedFormWidgets = null;
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(NyFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.submitButton != widget.submitButton ||
        oldWidget.onSubmit != widget.onSubmit ||
        oldWidget.onFailure != widget.onFailure) {
      _cachedSubmitButton = _resolveSubmitButton();
    }
  }

  @override
  get init => () {
    _formData = _InlineFormData(
      widget.formName,
      () => widget.fields(),
      widget.init,
    );

    if (widget.initialData != null && widget.initialData!.isNotEmpty) {
      _formData.setData(widget.initialData!, refreshState: false);
    }

    if (widget.onChanged != null) {
      _formData.onChanged = (Field field, dynamic value) {
        widget.onChanged!(field, value);
      };
    }

    _formData.initFields();
    _formData.setDataFromInit();
    _cachedSubmitButton = _resolveSubmitButton();
    if (_formData.getLoadData is Future Function()) {
      _formDataFuture = Future(() => _createForm());
    }
  };

  @override
  Map<String, Function> get stateActions => {
    "refresh": (_) {
      _cachedFormWidgets = null;
      setState(() {});
    },
    "clear": (_) {
      _cachedFormWidgets = null;
      _formData.clear();
    },
    "setValue": (data) {
      _formData.setFieldValue(data['key'], data['value']);
    },
    "setOptions": (data) {
      _formData.setFieldOptions(data['key'], data['value']);
    },
    "clearField": (data) {
      _formData.clearField(data['key']);
    },
    "showToast": (data) {
      showToastDanger(description: data['message']);
    },
    "submit": (data) async {
      final onSuccess = data['onSuccess'] as Function(dynamic);
      final onFailure =
          data['onFailure'] as Function(List<FormValidationError>)?;
      final showToastError = data['showToastError'] as bool? ?? true;
      final completer = data['completer'] as Completer<void>?;

      try {
        await _formData.submit(
          onSuccess: onSuccess,
          onFailure: onFailure,
          showToastError: showToastError,
        );
      } catch (error, stackTrace) {
        /// The error belongs to whoever awaits [NyFormWidget.submit]. With no
        /// completer to carry it, or once another form of the same name has
        /// answered, it is thrown on as before.
        if (completer == null || completer.isCompleted) rethrow;
        completer.completeError(error, stackTrace);
        return;
      }
      if (completer != null && !completer.isCompleted) completer.complete();
    },
    "refresh-form": (_) {
      _formData.refreshFields();
      _cachedFormWidgets = null;
      if (_formData.getLoadData is Future Function()) {
        _formDataFuture = Future(() => _createForm());
      }
      setState(() {});
    },
  };

  @override
  Widget view(BuildContext context) {
    if (_formData.getLoadData is Future Function()) {
      return _createWidget(
        IgnorePointer(
          ignoring: widget.locked,
          child: FutureWidget<List<Widget>>(
            future: _formDataFuture!,
            child: (context, data) {
              _formData.formReady();
              return ListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [if (data != null) ...data],
              );
            },
            loadingStyle: LoadingStyle.normal(child: loadingWidget()),
          ),
        ),
      );
    }

    return _createWidget(
      IgnorePointer(
        ignoring: widget.locked,
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: _getFormWidgets(),
        ),
      ),
    );
  }

  /// Resolve the submit button, wiring it to form submission if needed.
  Widget? _resolveSubmitButton() {
    if (widget.submitButton == null) return null;
    if (widget.onSubmit != null && widget.submitButton is FormSubmittable) {
      return (widget.submitButton as FormSubmittable).withSubmitForm((
        _formData,
        widget.onSubmit!,
      ), onFailure: widget.onFailure);
    }
    return widget.submitButton;
  }

  /// Create the widget
  Widget _createWidget(Widget widgetForm) {
    if (widget.header != null ||
        _cachedSubmitButton != null ||
        widget.footer != null) {
      return Column(
        children: [
          if (widget.headerSpacing > 0) SizedBox(height: widget.headerSpacing),
          if (widget.header != null) widget.header!,
          widgetForm,
          if (widget.submitButtonSpacing > 0)
            SizedBox(height: widget.submitButtonSpacing),
          if (_cachedSubmitButton != null) _cachedSubmitButton!,
          if (widget.footerSpacing > 0) SizedBox(height: widget.footerSpacing),
          if (widget.footer != null) widget.footer!,
        ],
      );
    }

    return widgetForm;
  }

  /// Loading widget
  Widget loadingWidget() {
    return (widget.loadingStyle ?? LoadingStyle.skeletonizer()).render(
      child: Column(children: _createForm()),
    );
  }

  /// Get cached form widgets, creating them if needed
  List<Widget> _getFormWidgets() {
    _cachedFormWidgets ??= _createForm();
    return _cachedFormWidgets!;
  }

  /// Create the form widgets
  List<Widget> _createForm() {
    List<Widget> items = [];

    for (var child in _formData.widgets) {
      if (child is Field && child.field != null) {
        items.add(
          KeyedSubtree(key: ValueKey(child.stateKey), child: child.field!),
        );
      } else if (child is List) {
        final List<Field> rowFields = child.cast<Field>();
        final String rowKey = rowFields.map((f) => f.stateKey).join('_');
        items.add(
          KeyedSubtree(
            key: ValueKey('row_$rowKey'),
            child: Row(
              children: [
                for (Field field in rowFields)
                  Expanded(
                    key: ValueKey(field.stateKey),
                    child: field.field ?? const SizedBox.shrink(),
                  ),
              ],
            ).withGap(widget.crossAxisSpacing),
          ),
        );
      }
    }

    return items.withGap(widget.crossAxisSpacing);
  }
}

/// Helper class for dispatching form actions by name.
///
/// Use this in your form class to provide a static actions accessor:
/// ```dart
/// class ProfileForm extends NyFormWidget {
///   // ...
///   static NyFormActions get actions => const NyFormActions('ProfileForm');
/// }
///
/// // Then use:
/// ProfileForm.actions.updateField('username', 'JohnDoe');
/// ProfileForm.actions.submit(onSuccess: (data) => print(data));
/// ```
class NyFormActions {
  final String formName;
  const NyFormActions(this.formName);

  /// Update a field value in the form
  void updateField(String key, dynamic value) =>
      NyFormWidget.stateSetValue(formName, key, value);

  /// Clear a specific field in the form
  void clearField(String key) => stateAction(
    "clearField",
    state: NyFormWidget.state(formName),
    data: {"key": key},
  );

  /// Clear all form data
  void clear() => NyFormWidget.stateClearData(formName);

  /// Refresh the form state
  void refresh() => NyFormWidget.stateRefresh(formName);

  /// Refresh the form fields
  void refreshForm() => NyFormWidget.stateRefreshForm(formName);

  /// Set options for a picker/chip/radio field
  void setOptions(String key, dynamic value) =>
      NyFormWidget.stateSetOptions(formName, key, value);

  /// Submit the form
  ///
  /// The returned [Future] completes once [onSuccess] or [onFailure] has
  /// finished. Return it from a button's `onPressed` to keep the button
  /// loading until then. See [NyFormWidget.submit].
  Future<void> submit({
    required Function(dynamic) onSuccess,
    Function(List<FormValidationError>)? onFailure,
    bool showToastError = true,
  }) => NyFormWidget.submit(
    formName,
    onSuccess: onSuccess,
    onFailure: onFailure,
    showToastError: showToastError,
  );
}
