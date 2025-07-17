import 'package:flutter/cupertino.dart';

/// NavigationTab is a class that holds the title, page, icon, activeIcon, backgroundColor, tooltip, and meta data of a bottom navigation tab.
class NavigationTab {
  String? title;
  Widget? page;
  Widget? icon;
  Widget? activeIcon;
  Color? backgroundColor;
  Color? alertColor;
  String? tooltip;
  final String? kind;
  final Map<String, dynamic> meta;

  /// NavigationTab is a class that holds the title, page, icon, activeIcon, backgroundColor, tooltip, and meta data of a bottom navigation tab.
  NavigationTab(
      {required this.title,
      required this.page,
      this.icon,
      this.activeIcon,
      this.tooltip,
      this.backgroundColor,
      this.meta = const {}})
      : kind = 'default';

  /// NavigationTab.badge is a class that holds the title, page, icon, activeIcon, backgroundColor, tooltip, and meta data of a bottom navigation tab with a badge.
  NavigationTab.badge(
      {required this.title,
      required this.page,
      this.icon,
      this.activeIcon,
      int? initialCount,
      bool? rememberCount = true,
      this.tooltip,
      this.backgroundColor,
      Map<String, dynamic>? meta})
      : meta = {},
        kind = "badge" {
    this.meta.addAll({
      "initialCount": initialCount,
      "rememberCount": rememberCount,
    });
  }

  /// NavigationTab.alert is a class that holds the title, page, icon, activeIcon, backgroundColor, tooltip, and meta data of a bottom navigation tab with an alert.
  NavigationTab.alert(
      {required this.title,
      required this.page,
      this.icon,
      this.activeIcon,
      this.tooltip,
      this.alertColor,
      bool? alertEnabled,
      bool? rememberAlert = true,
      Map<String, dynamic>? meta})
      : meta = {},
        kind = "alert" {
    this.meta.addAll({
      "alertEnabled": alertEnabled,
      "rememberAlert": rememberAlert,
    });
  }

  /// NavigationTab.journey is a class that holds the page of a journey navigation tab.
  NavigationTab.journey({required this.page})
      : title = null,
        kind = "journey",
        meta = {};

  /// Update the page of the NavigationTab
  void updatePage(Widget page) {
    this.page = page;
  }

  /// Update the title of the NavigationTab
  void updateTitle(String title) {
    this.title = title;
  }

  /// Update the icon of the NavigationTab
  void updateIcon(Widget icon) {
    this.icon = icon;
  }

  /// Update the active icon of the NavigationTab
  void updateActiveIcon(Widget activeIcon) {
    this.activeIcon = activeIcon;
  }

  /// Update the background color of the NavigationTab
  void updateBackgroundColor(Color backgroundColor) {
    this.backgroundColor = backgroundColor;
  }

  /// Update the tooltip of the NavigationTab
  void updateTooltip(String tooltip) {
    this.tooltip = tooltip;
  }
}
