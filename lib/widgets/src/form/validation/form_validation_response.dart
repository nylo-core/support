import 'package:nylo_support/widgets/ny_widgets.dart';

/// Represents the response of a form validation process.
/// This class is used to encapsulate the result of a validation check,
/// indicating whether the form is valid or not, along with an optional message.
class FormValidationResponse {
  dynamic data;
  FormRule rule;

  /// The name of the field that was validated, e.g. "Email".
  String? attribute;

  /// Create a new FormValidationResponse
  FormValidationResponse(this.rule, {this.data, this.attribute});

  /// The rule's message, with `{{attribute}}` replaced by the field name.
  String? get message => rule.getMessage(attribute);

  @override
  String toString() {
    return 'FormValidationResponse{rule: $rule, data: $data}';
  }
}

/// Represents a validation failure response.
class FormValidationError extends FormValidationResponse {
  FormValidationError(super.rule, {super.attribute});

  @override
  String toString() {
    return 'FormValidationError{rule: $rule, data: $data}';
  }
}

/// Represents a successful validation response
class FormValidationSuccess extends FormValidationResponse {
  FormValidationSuccess(super.rule, {super.attribute});

  @override
  String toString() {
    return 'FormValidationSuccess{rule: $rule, data: $data}';
  }
}
