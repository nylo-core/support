/// Base class for all form validation rules.
///
/// Extend this class to create custom validation rules. Subclasses must
/// implement the [validate] method to define their validation logic.
abstract class FormRule {
  /// The rule identifier (e.g., "email", "min_length", "required").
  String? rule;

  /// The error message to display when validation fails.
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

  /// Returns the formatted error message for this rule.
  ///
  /// Replaces `{{attribute}}` placeholder with the provided attribute name.
  String? getMessage([String? attribute]) {
    return message?.replaceAll('{{attribute}}', attribute ?? 'data');
  }
}
