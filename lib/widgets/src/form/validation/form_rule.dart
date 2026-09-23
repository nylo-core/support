import '/localization/ny_localization.dart';

/// Base class for all form validation rules.
///
/// Extend this class to create custom validation rules. Subclasses must
/// implement the [validate] method to define their validation logic.
abstract class FormRule {
  /// The rule identifier (e.g., "email", "min_length", "required").
  String? rule;

  /// The error message to display when validation fails, or a translation
  /// key for it (the built-in rules default to `nylo.validation.*` keys).
  /// Use `{{attribute}}` as a placeholder for the field name.
  String? message;

  /// Optional data associated with this rule.
  dynamic data;

  /// Creates a new form rule with optional rule identifier and message.
  FormRule({this.rule, this.message});

  /// Validates the provided [data] against this rule.
  ///
  /// Returns `true` if the data is valid, `false` otherwise.
  /// Subclasses must implement this method.
  bool validate(dynamic data);

  /// Values for the rule-specific placeholders in a translated [message],
  /// e.g. `{"minLength": "8"}` for `{{minLength}}`.
  Map<String, String> get messageArguments => const {};

  /// Returns the formatted error message for this rule.
  ///
  /// Translates [message], then replaces the `{{attribute}}` placeholder with
  /// the translated attribute name.
  String? getMessage([String? attribute]) {
    final String name = (attribute ?? "nylo.validation.default_attribute").tr();
    return message
        ?.tr(arguments: {...messageArguments, "attribute": name})
        .replaceAll('{{attribute}}', name);
  }
}
