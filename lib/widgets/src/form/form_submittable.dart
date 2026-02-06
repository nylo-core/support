import 'package:flutter/widgets.dart';

/// Mixin for button widgets that can be wired to form submission.
///
/// Implement [withSubmitForm] to return a copy of the widget
/// with the given submitForm tuple set.
mixin FormSubmittable on Widget {
  Widget withSubmitForm(
    (dynamic, Function(dynamic data)) submitForm, {
    Function(dynamic error)? onFailure,
  });
}
