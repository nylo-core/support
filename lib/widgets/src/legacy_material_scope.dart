import 'package:material_ui/material_ui.dart';

/// Gives [child] the app's theme and Material localizations in the form
/// `package:flutter/material.dart` reads them.
///
/// Wraps widgets from dependencies that have not moved to
/// `package:material_ui` yet (pull_to_refresh_flutter3's headers and
/// footers). Without it they fall back to the default theme, and
/// `MaterialClassicHeader` throws looking up `MaterialLocalizations`.
class LegacyMaterialScope extends StatelessWidget {
  /// Creates a [LegacyMaterialScope] around [child].
  const LegacyMaterialScope({super.key, required this.child});

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return MaterialUiCompatibilityBridge(child: child);
  }
}
