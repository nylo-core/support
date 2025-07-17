import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/widgets/ny_future_builder.dart';
import '/helpers/extensions.dart';
import '/helpers/loading_style.dart';
import 'package:recase/recase.dart';
import '/forms/ny_login_form.dart';
import '/helpers/helper.dart';
import '/nylo.dart';
import '/widgets/ny_form.dart';
import '/widgets/ny_state.dart';
import '/widgets/ny_text_field.dart';
import 'form_item.dart';

/// NyForm is a class that helps in managing forms
/// To create a form, you need to extend the [NyFormData] class
/// Example:
/// ```dart
/// class RegisterForm extends NyFormData {
///  @override
///  fields() => [
///     Field.text("Name", validate: FormValidator().notEmpty()),
///     Field.email("Email", validate: FormValidator.email()),
///  ];
/// }
///
/// RegisterForm form = RegisterForm();
///
/// NyForm(
///  form: form,
/// );
/// ```
///
/// To submit the form, you can call the [submit] method
/// Example:
/// ```dart
/// form.submit(onSuccess: (data) {});
/// // or
/// NyForm.submit("RegisterForm", onSuccess: (data) {});
/// ```
///
/// To get the data from the form, you can call the [data] method
/// Example:
/// ```dart
/// form.data();
/// ```
/// Learn more: https://nylo.dev/docs/6.x/forms
class NyForm extends StatefulWidget {
  NyForm(
      {super.key,
      required NyFormData form,
      this.crossAxisSpacing = 10,
      this.mainAxisSpacing = 10,
      Map<String, dynamic>? initialData,
      this.onChanged,
      this.validateOnFocusChange = false,
      this.header,
      Widget? footer,
      this.headerSpacing = 10,
      this.footerSpacing = 10,
      @Deprecated('Use loadingStyle instead') this.loading,
      LoadingStyle? loadingStyle,
      this.locked = false})
      : form = form..setData(initialData ?? {}, refreshState: false),
        type = "form",
        footer = footer ?? form.submitButton,
        loadingStyle = loadingStyle ?? LoadingStyle.skeletonizer(),
        children = null;

  /// Create a form with children
  /// Example:
  /// ```dart
  /// NyForm(
  /// form: form,
  /// children: [
  ///  Button.primary("Submit", onPressed: () {}),
  /// ],
  /// );
  /// ```
  NyForm.list(
      {super.key,
      required NyFormData form,
      required this.children,
      this.crossAxisSpacing = 10,
      this.mainAxisSpacing = 10,
      Map<String, dynamic>? initialData,
      this.onChanged,
      this.validateOnFocusChange = false,
      this.header,
      Widget? footer,
      this.headerSpacing = 10,
      this.footerSpacing = 10,
      @Deprecated('Use loadingStyle instead') this.loading,
      LoadingStyle? loadingStyle,
      this.locked = false})
      : form = form..setData(initialData ?? {}, refreshState: false),
        footer = footer ?? form.submitButton,
        loadingStyle = loadingStyle ?? LoadingStyle.skeletonizer(),
        type = "list";

  /// The type of form
  final String type;

  /// The child widgets
  final List<Widget>? children;

  /// The header widget
  final Widget? header;

  /// The footer widget
  final Widget? footer;

  /// The header spacing
  final double headerSpacing;

  /// The footer spacing
  final double footerSpacing;

  /// The loading widget, defaults to skeleton
  final Widget? loading;

  /// The loading style
  final LoadingStyle loadingStyle;

  /// Get the state name
  static String state(String stateName) {
    return "form_$stateName";
  }

  /// Refresh the state of the form
  static void stateRefresh(String stateName) {
    updateState(state(stateName), data: {
      "action": "refresh",
    });
  }

  /// Set field in the form
  static void stateSetValue(String stateName, String key, dynamic value) {
    updateState(state(stateName),
        data: {"action": "setValue", "key": key, "value": value});
  }

  /// Set field in the form
  static void stateSetOptions(String stateName, String key, dynamic value) {
    updateState(state(stateName),
        data: {"action": "setOptions", "key": key, "value": value});
  }

  /// Refresh the state of the form
  static void stateClearData(String stateName) {
    updateState(state(stateName), data: {
      "action": "clear",
    });
  }

  /// Refresh the state of the form
  static void stateRefreshForm(String stateName) {
    updateState(state(stateName), data: {
      "action": "refresh-form",
    });
  }

  /// Submit the form
  static void submit(String name,
      {required Function(dynamic value) onSuccess,
      Function(Exception exception)? onFailure,
      bool showToastError = true}) {
    /// Update the state
    updateState(state(name), data: {
      "onSuccess": onSuccess,
      "onFailure": onFailure,
      "showToastError": showToastError
    });
  }

  final bool locked;
  final NyFormData form;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final bool validateOnFocusChange;
  final Function(String field, Map<String, dynamic> data)? onChanged;

  @override
  // ignore: no_logic_in_create_state
  createState() => _NyFormState(form);
}

class _NyFormState extends NyState<NyForm> {
  List<NyFormItem> _children = [];
  dynamic initialFormData;
  StreamController? _updatedStream;

  _NyFormState(NyFormData form) {
    stateName = "form_${form.stateName}";
  }

  @override
  void dispose() {
    super.dispose();
    _updatedStream?.close();
  }

  @override
  get init => () {
        _updatedStream = widget.form.initializeStream();

        _updatedStream?.stream.listen((data) {
          String fieldSnakeCase = ReCase(data.$1).snakeCase;
          dynamic formData = widget.form.data(lowerCaseKeys: true);
          widget.form.onChange(fieldSnakeCase, formData);
          if (widget.onChanged != null) {
            widget.onChanged!(fieldSnakeCase, formData);
          }
        });

        _construct();
      };

  List<String> showableFields = [];

  /// Construct the form
  void _construct() {
    NyFormStyle? nyFormStyle = Nylo.instance.getFormStyle();

    Map<String, dynamic> fields = widget.form.data();

    _children = fields.entries.map((field) {
      dynamic value = field.value;

      bool autofocus = widget.form.getAutoFocusedField == field.key;

      String? fieldStyle;
      FormCast? fieldCast;

      // check what to cast the field to
      Map<String, dynamic> casts = widget.form.getCast;

      if (casts.containsKey(field.key)) {
        fieldCast = casts[field.key];
      }

      // check if there is a style for the field
      NyTextField Function(NyTextField nyTextField)? style;
      Map<String, dynamic> styles = widget.form.getStyle;
      if (styles.containsKey(field.key)) {
        dynamic styleItem = styles[field.key];
        if (styleItem is NyTextField Function(NyTextField nyTextField)) {
          style = styleItem;
        }

        if (styleItem is String) {
          fieldStyle = styleItem;
        }
      }

      if (fieldCast == null) {
        if (value is DateTime ||
            field.value.runtimeType.toString() == "DateTime") {
          fieldCast = FormCast.datetime();
        }

        if (value is String || field.value.runtimeType.toString() == "String") {
          fieldCast = FormCast();
        }

        if (value is int || field.value.runtimeType.toString() == "int") {
          fieldCast = FormCast.number();
        }

        if (value is double || field.value.runtimeType.toString() == "double") {
          fieldCast = FormCast.number(decimal: true);
        }
      }

      fieldCast ??= FormCast();

      if (value is double || value is int) {
        value = value.toString();
      }

      String? validationRules;
      String? validationMessage;
      bool Function(dynamic value)? customValidationRule;
      Map<String, dynamic> formRules = widget.form.getValidate;
      if (formRules.containsKey(field.key)) {
        dynamic rule = formRules[field.key];
        if (rule is String) {
          validationRules = rule;
        }

        if (rule is FormValidator) {
          customValidationRule = rule.customRule;
          if (rule.customRule == null) {
            validationRules = rule.rules;
          }
          if (rule.message != null) {
            validationMessage = rule.message;
          }
        }

        if ((rule is List) && rule.isNotEmpty) {
          validationRules = rule[0];
          if (rule.length == 2) {
            validationMessage = rule[1];
          }
        }
      }

      String? dummyDataValue;
      if (Nylo.isEnvDeveloping()) {
        Map<String, dynamic> dummyData = widget.form.getDummyData;
        if (dummyData.containsKey(field.key)) {
          dummyDataValue = dummyData[field.key];
          if (dummyDataValue != null && value == null) {
            widget.form
                .setFieldValue(field.key, dummyDataValue, refreshState: false);
          }
        }
      }

      String? label;
      Map<String, dynamic> labelData = widget.form.getLabels;
      if (labelData.containsKey(field.key)) {
        label = labelData[field.key];
      }

      Widget? headerValue;
      Map<String, dynamic> headerData = widget.form.getHeaderData;
      if (headerData.containsKey(field.key)) {
        headerValue = headerData[field.key];
      }

      Widget? footerValue;
      Map<String, dynamic> footerData = widget.form.getFooterData;
      if (footerData.containsKey(field.key)) {
        footerValue = footerData[field.key];
      }

      Map<String, NyTextField Function(NyTextField)>? metaDataValue;
      Map<String, dynamic> metaData = widget.form.getMetaData;
      if (metaData.containsKey(field.key)) {
        metaDataValue = metaData[field.key];
      }

      bool isHidden = false;
      Map<String, dynamic> isHiddenData = widget.form.getHiddenData;
      if (isHiddenData.containsKey(field.key)) {
        isHidden = isHiddenData[field.key];
      }

      bool readOnly = false;
      Map<String, dynamic> readOnlyData = widget.form.getReadOnlyData;
      if (readOnlyData.containsKey(field.key)) {
        readOnly = readOnlyData[field.key] ?? false;
      }

      Field nyField = Field(
        field.key,
        label: label,
        value: value,
        cast: fieldCast,
        autofocus: autofocus,
        header: headerValue,
        footer: footerValue,
        metaData: metaDataValue,
        hidden: isHidden,
        readOnly: readOnly,
      );

      return NyFormItem(
          field: nyField,
          validationRules: validationRules,
          validationMessage: validationMessage,
          validateOnFocusChange: widget.validateOnFocusChange,
          dummyData: dummyDataValue,
          customValidationRule: customValidationRule,
          fieldStyle: fieldStyle,
          formStyle: nyFormStyle,
          style: style,
          updated: _updatedStream,
          onChanged: (dynamic fieldValue) {
            if (fieldValue is DateTime) {
              widget.form
                  .setFieldValue(field.key, fieldValue, refreshState: false);
              return;
            }
            widget.form
                .setFieldValue(field.key, fieldValue, refreshState: false);
          });
    }).toList();
  }

  @override
  stateUpdated(dynamic data) async {
    if (data is Map && data.containsKey('action')) {
      if (data['action'] == 'refresh') {
        _construct();
        return;
      }
      if (data['action'] == 'clear') {
        widget.form.clear(refreshState: false);
        _construct();
        return;
      }
      if (data['action'] == 'setValue') {
        _children = _children.update((child) => child.field.key == data['key'],
            (child) {
          child.field.value = data['value'];
          return child;
        });
        _construct();
        setState(() {});
        return;
      }

      if (data['action'] == 'setOptions') {
        _children = _children.update((child) => child.field.key == data['key'],
            (child) {
          if (child.field.cast.type == "picker") {
            child.field.cast.metaData!['options'] = data['value'];
          }
          return child;
        });
        _construct();
        setState(() {});
        return;
      }
      if (["hideField", "showField"].contains(data['action'])) {
        String field = data['field'];

        _children =
            _children.update((child) => child.field.key == field, (child) {
          if (data['action'] == 'hideField') {
            child.field.hide();
            showableFields.remove(field);
          } else if (data['action'] == 'showField') {
            showableFields.add(field);
            child.field.show();
          }
          return child;
        });
        setState(() {});
        return;
      }

      if (data['action'] == 'refresh-form') {
        _construct();
        initialFormData = null;
        setState(() {});
        return;
      }
      return;
    }
    data as Map<String, dynamic>;

    // Get the rules, onSuccess and onFailure functions
    Map<String, dynamic> rules =
        data.containsKey("rules") ? data["rules"] : widget.form.getValidate;
    Function(dynamic value) onSuccess = data["onSuccess"];
    Function(Exception error)? onFailure;
    bool showToastError = data["showToastError"];
    if (data.containsKey("onFailure")) {
      onFailure = data["onFailure"];
    }

    // Update the rules with the current form data
    Map<String, dynamic> formData = widget.form.data();
    for (var field in formData.entries) {
      if (rules.containsKey(field.key)) {
        if (rules[field.key] is FormValidator) {
          FormValidator formValidator = rules[field.key];

          if (field.value is List) {
            formValidator.setData((field.value as List).join(", ").toString());
          } else {
            formValidator.setData(field.value);
          }

          rules[field.key] = formValidator;
        }
      }
    }

    // Validate the form
    validate(
      rules: rules,
      onSuccess: () {
        Map<String, dynamic> currentData =
            widget.form.data(lowerCaseKeys: true);
        onSuccess(currentData);
      },
      onFailure: (Exception exception) {
        if (onFailure == null) return;
        onFailure(exception);
      },
      showAlert: showToastError,
    );
  }

  @override
  Widget view(BuildContext context) {
    /// If the form has initial data, construct the form
    if (initialFormData != null) {
      _construct();
      return _createWidget(IgnorePointer(
        ignoring: widget.locked,
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: _createForm(),
        ),
      ));
    }

    if (widget.form.getLoadData is! Future Function() &&
        widget.form.getLoadData != null &&
        initialFormData == null) {
      initialFormData = widget.form.getLoadData!();
      widget.form.setData(initialFormData, refreshState: false);
    }

    if (widget.form.getLoadData is Future Function()) {
      // ignore: prefer_function_declarations_over_variables
      dynamic formData = () async {
        if (initialFormData == null) {
          dynamic data = await widget.form.getLoadData!();
          initialFormData = data;
          widget.form.setData(data, refreshState: false);
        }
        _construct();
        return _createForm();
      };

      return _createWidget(IgnorePointer(
        ignoring: widget.locked,
        child: NyFutureBuilder<List<Widget>>(
            future: formData(),
            child: (context, data) {
              widget.form.formReady();
              return ListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [if (data != null) ...data],
              );
            },
            loadingStyle: LoadingStyle.normal(child: loadingWidget())),
      ));
    }

    _construct();

    return _createWidget(IgnorePointer(
      ignoring: widget.locked,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: _createForm(),
      ),
    ));
  }

  /// Create the widget
  Widget _createWidget(Widget widgetForm) {
    if (widget.type == "list") {
      return Column(
        children: [
          if (widget.header != null) widget.header!,
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [widgetForm, ...widget.children!],
            ),
          ),
          if (widget.footer != null) widget.footer!,
        ],
      );
    }

    if (widget.header != null || widget.footer != null) {
      return Column(
        children: [
          if (widget.headerSpacing > 0) SizedBox(height: widget.headerSpacing),
          if (widget.header != null) widget.header!,
          widgetForm,
          if (widget.footerSpacing > 0) SizedBox(height: widget.footerSpacing),
          if (widget.footer != null) widget.footer!,
        ],
      );
    }

    return widgetForm;
  }

  /// Loading widget
  Widget loadingWidget() {
    if (widget.loading != null) {
      return widget.loading!;
    }

    return widget.loadingStyle.render(
        child: Column(
      children: _createForm(),
    ));
  }

  List<Widget> _createForm() {
    List<Widget> items = [];
    List<List<dynamic>> groupedItems = widget.form.groupedItems;
    List<NyFormItem> childrenNotHidden = _children.where((test) {
      if (test.field.hidden == false) {
        return true;
      }
      if (showableFields.contains(test.field.key)) {
        return true;
      }
      return false;
    }).toList();

    for (List<dynamic> listItems in groupedItems) {
      if (listItems.length == 1) {
        List<NyFormItem> allItems = childrenNotHidden
            .where((test) => test.field.key == listItems[0])
            .toList();
        if (allItems.isNotEmpty) {
          items.add(allItems.first);
        }
        continue;
      }

      List<Widget> childrenRowWidgets = [
        for (String action in listItems)
          (childrenNotHidden
                  .where((test) => test.field.key == action)
                  .isNotEmpty)
              ? Flexible(
                  child: childrenNotHidden
                          .where((test) => test.field.key == action)
                          .isNotEmpty
                      ? childrenNotHidden
                          .where((test) => test.field.key == action)
                          .first
                      : const SizedBox.shrink())
              : const SizedBox.shrink()
      ];

      Row row = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: childrenRowWidgets,
      ).withGap(childrenRowWidgets
              .where((element) => element.runtimeType == SizedBox)
              .isNotEmpty
          ? 0
          : widget.mainAxisSpacing);

      items.add(row);
    }

    return items.withGap(widget.crossAxisSpacing);
  }
}

/// Forms class
class Forms {
  /// Create a login form
  /// This Form contains the following fields:
  /// - Email (email)
  /// - Password (password)
  static NyLoginForm login(
      {String? name,
      String? emailValidationRule = "email",
      String? emailValidationMessage,
      String? passwordValidationRule = "password_v1",
      String? passwordValidationMessage,
      bool? passwordViewable,
      String? style,
      Map<String, dynamic> dummyData = const {},
      Map<String, dynamic> initialData = const {}}) {
    return NyLoginForm(
      name: name,
      passwordValidationRule: passwordValidationRule,
      passwordValidationMessage: passwordValidationMessage,
      emailValidationRule: emailValidationRule,
      emailValidationMessage: emailValidationMessage,
      passwordViewable: passwordViewable ?? true,
      style: style ?? "compact",
    );
  }
}
