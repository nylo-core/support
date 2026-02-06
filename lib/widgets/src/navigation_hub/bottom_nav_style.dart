import 'package:flutter/material.dart';

/// Data passed to custom nav bar builders
class NavBarData {
  /// The navigation bar items
  final List<BottomNavigationBarItem> items;

  /// The current selected index
  final int currentIndex;

  /// Callback when a tab is tapped
  final ValueChanged<int> onTap;

  const NavBarData({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });
}

/// Style configuration for bottom navigation bar
///
/// Use factory constructors to create preset styles:
/// - [BottomNavStyle.material] - Default Flutter material style
class BottomNavStyle {
  /// The kind of style
  final String kind;

  const BottomNavStyle._({required this.kind});

  /// Default material style (current behavior)
  ///
  /// This returns the standard Flutter [BottomNavigationBar] without
  /// any additional styling applied.
  factory BottomNavStyle.material() => const BottomNavStyle._(kind: 'material');

  /// Builds the styled nav bar widget
  ///
  /// Wraps the provided [navBar] with the appropriate styling
  /// based on the style [kind].
  Widget build(BuildContext context, Widget navBar) {
    return navBar;
  }
}
