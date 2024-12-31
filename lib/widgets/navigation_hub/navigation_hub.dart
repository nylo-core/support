import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '/helpers/extensions.dart';
import '/local_storage/local_storage.dart';
import '/widgets/navigation_hub/badge_tab.dart';

import '/helpers/helper.dart';
import '/router/router.dart';
import '/widgets/ny_state.dart';

import 'navigation_tab.dart';

abstract class NavigationHub<T extends StatefulWidget> extends NyState<T> {
  NavigationHub(this.pages);

  /// Generate the pages
  final dynamic Function() pages;

  /// The pages
  Map<int, NavigationTab> _pages = {};

  /// Whether to maintain the state of the page
  bool get maintainState => true;

  /// The layout of the navigation
  NavigationHubLayout? layout;

  /// The current index of the page
  int currentIndex = 0;

  /// The navigator keys
  Map<int, UniqueKey> navigatorKeys = {};

  /// The ordered pages
  Map<int, NavigationTab> get orderedPages => _sortMapByKey(_pages);

  /// The reset map
  Map<int, bool> reset = {};

  @override
  get init => () {
        int? activeTab = data(defaultValue: {"tab-index": 0})['tab-index'];
        currentIndex = activeTab ?? 0;

        if (pages is Future Function()) {
          awaitData(perform: () async {
            _pages = await pages();
          });
        } else {
          _pages = pages();
        }
      };

  /// The navigator key
  getNavigationKey(MapEntry<int, NavigationTab> page) {
    if (navigatorKeys.containsKey(page.key)) {
      return navigatorKeys[page.key];
    } else {
      navigatorKeys[page.key] = UniqueKey();
      return navigatorKeys[page.key];
    }
  }

  /// Handle the tap event
  onTap(int index) {
    if (reset.containsKey(index) && reset[index] == true) {
      if (navigatorKeys.containsKey(index)) {
        navigatorKeys[index] = UniqueKey();
      }
      reset[index] = false;
    }
    setState(() {
      currentIndex = index;
    });
  }

  @override
  stateUpdated(dynamic data) async {
    super.stateUpdated(data);
    if (data is! Map) return;
    if (!data.containsKey('action') || data['action'] == null) return;

    switch (data['action']) {
      case 'reset-tab':
        {
          int index = data['tab-index'];
          reset[index] = true;
          break;
        }
      case 'update-tab':
        {
          int index = data['tab-index'];
          currentIndex = index;
          break;
        }
      default:
        {}
    }
  }

  /// Get the bottom navigation bar item
  BottomNavigationBarItem _getBottomNavigationBarItem(
      MapEntry<int, NavigationTab> page) {
    if (page.value.kind == "badge") {
      return BottomNavigationBarItem(
        icon: BadgeTab.fromNavigationTab(page.value,
            index: page.key,
            icon: page.value.activeIcon ?? Icon(Icons.home),
            stateName: "${stateName}_navigation_tab_${page.key}"),
        label: page.value.title,
        activeIcon: BadgeTab.fromNavigationTab(page.value,
            index: page.key,
            icon: page.value.activeIcon ?? Icon(Icons.home),
            stateName: "${stateName}_navigation_tab_${page.key}"),
        backgroundColor: page.value.backgroundColor,
        tooltip: page.value.tooltip,
      );
    }

    return BottomNavigationBarItem(
      icon: page.value.icon ?? Icon(Icons.home),
      label: page.value.title,
      activeIcon: page.value.activeIcon ?? Icon(Icons.home),
      backgroundColor: page.value.backgroundColor,
      tooltip: page.value.tooltip,
    );
  }

  @override
  Widget view(BuildContext context) {
    Map<int, NavigationTab> pages = orderedPages;
    if (layout?.kind == "bottomNav") {
      return Scaffold(
        body: maintainState
            ? IndexedStack(index: currentIndex, children: [
                for (var page in pages.entries)
                  Navigator(
                    key: getNavigationKey(page),
                    onGenerateRoute: (settings) => MaterialPageRoute(
                      builder: (context) => page.value.page,
                      settings: settings,
                    ),
                  )
              ])
            : Navigator(
                key: getNavigationKey(pages.entries.elementAt(currentIndex)),
                onGenerateRoute: (settings) => MaterialPageRoute(
                  builder: (context) =>
                      (pages.entries.elementAt(currentIndex).value.page),
                  settings: settings,
                ),
              ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          selectedLabelStyle: layout?.selectedLabelStyle ??
              TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
          unselectedLabelStyle: layout?.unselectedLabelStyle ??
              TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
          showSelectedLabels: layout?.showSelectedLabels ?? true,
          showUnselectedLabels: layout?.showUnselectedLabels ?? true,
          selectedItemColor: layout?.selectedItemColor ?? Colors.black,
          unselectedItemColor: layout?.unselectedItemColor ?? Colors.black,
          selectedFontSize: layout?.selectedFontSize ?? 14.0,
          unselectedFontSize: layout?.unselectedFontSize ?? 12.0,
          iconSize: layout?.iconSize ?? 24.0,
          elevation: layout?.elevation ?? 8.0,
          backgroundColor: layout?.backgroundColor,
          type: layout?.type ?? BottomNavigationBarType.fixed,
          items: [
            for (MapEntry<int, NavigationTab> page in pages.entries)
              _getBottomNavigationBarItem(page),
          ],
        ),
      );
    }
    if (layout?.kind == "topNav") {
      return DefaultTabController(
        length: pages.length,
        initialIndex: currentIndex,
        animationDuration: layout?.animationDuration,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: layout?.backgroundColor,
            title: pages[currentIndex]?.title == null
                ? null
                : Text(pages[currentIndex]?.title ?? ""),
            toolbarHeight: (layout?.hideAppBarTitle ?? true) ? 0 : null,
            bottom: TabBar(
              isScrollable: layout?.isScrollable ?? false,
              labelColor: layout?.labelColor,
              labelStyle: layout?.labelStyle,
              labelPadding: layout?.labelPadding,
              unselectedLabelColor: layout?.unselectedLabelColor,
              unselectedLabelStyle: layout?.unselectedLabelStyle,
              indicatorColor: layout?.indicatorColor,
              automaticIndicatorColorAdjustment:
                  layout?.automaticIndicatorColorAdjustment ?? true,
              indicatorWeight: layout?.indicatorWeight ?? 2.0,
              indicatorPadding: layout?.indicatorPadding ?? EdgeInsets.zero,
              indicator: layout?.indicator,
              indicatorSize: layout?.indicatorSize,
              dividerColor: layout?.dividerColor,
              dividerHeight: layout?.dividerHeight,
              dragStartBehavior:
                  layout?.dragStartBehavior ?? DragStartBehavior.start,
              overlayColor: layout?.overlayColorState,
              mouseCursor: layout?.mouseCursor,
              enableFeedback: layout?.enableFeedback,
              physics: layout?.physics,
              splashFactory: layout?.splashFactory,
              splashBorderRadius: layout?.splashBorderRadius,
              tabAlignment: layout?.tabAlignment,
              textScaler: layout?.textScaler,
              tabs: [
                for (MapEntry page in pages.entries)
                  Tab(
                    text: layout?.showSelectedLabels == false
                        ? null
                        : page.value.title,
                    icon: page.value.kind == "badge"
                        ? BadgeTab.fromNavigationTab(page.value,
                            index: page.key,
                            icon: currentIndex == page.key
                                ? page.value.activeIcon ?? Icon(Icons.home)
                                : page.value.icon ?? Icon(Icons.home),
                            stateName:
                                "${stateName}_navigation_tab_${page.key}")
                        : currentIndex == page.key
                            ? page.value.activeIcon ?? Icon(Icons.home)
                            : page.value.icon ?? Icon(Icons.home),
                  )
              ],
              onTap: onTap,
            ),
          ),
          body: maintainState
              ? IndexedStack(index: currentIndex, children: [
                  for (var page in pages.entries)
                    Navigator(
                      key: getNavigationKey(page),
                      onGenerateRoute: (settings) => MaterialPageRoute(
                        builder: (context) => (page.value.page),
                        settings: settings,
                      ),
                    )
                ])
              : TabBarView(
                  physics: layout?.physics,
                  children: [
                    for (var page in pages.entries)
                      Navigator(
                        key: getNavigationKey(page),
                        onGenerateRoute: (settings) => MaterialPageRoute(
                          builder: (context) => (page.value.page),
                          settings: settings,
                        ),
                      )
                  ],
                ),
        ),
      );
    }
    throw Exception("Invalid layout type");
  }
}

class NavigationHubLayout {
  /// The kind of navigation layout
  String? kind;

  /// Defines the layout and behavior of a [BottomNavigationBar].
  ///
  /// See documentation for [BottomNavigationBarType] for information on the
  /// meaning of different types.
  BottomNavigationBarType? type;

  /// The z-coordinate of this [BottomNavigationBar].
  ///
  /// If null, defaults to `8.0`.
  ///
  /// {@macro flutter.material.material.elevation}
  double? elevation;

  /// The color of the [BottomNavigationBar] itself.
  ///
  /// If [type] is [BottomNavigationBarType.shifting] and the
  /// [items] have [BottomNavigationBarItem.backgroundColor] set, the [items]'
  /// backgroundColor will splash and overwrite this color.
  Color? backgroundColor;

  /// The size of all of the [BottomNavigationBarItem] icons.
  ///
  /// See [BottomNavigationBarItem.icon] for more information.
  double? iconSize;

  /// The color of the selected [BottomNavigationBarItem.icon] and
  /// [BottomNavigationBarItem.label].
  ///
  /// If null then the [ThemeData.primaryColor] is used.
  Color? selectedItemColor;

  /// The color of the unselected [BottomNavigationBarItem.icon] and
  /// [BottomNavigationBarItem.label]s.
  ///
  /// If null then the [ThemeData.unselectedWidgetColor]'s color is used.
  Color? unselectedItemColor;

  /// The size, opacity, and color of the icon in the currently selected
  /// [BottomNavigationBarItem.icon].
  ///
  /// If this is not provided, the size will default to [iconSize], the color
  /// will default to [selectedItemColor].
  ///
  /// It this field is provided, it must contain non-null [IconThemeData.size]
  /// and [IconThemeData.color] properties. Also, if this field is supplied,
  /// [unselectedIconTheme] must be provided.
  IconThemeData? selectedIconTheme;

  /// The size, opacity, and color of the icon in the currently unselected
  /// [BottomNavigationBarItem.icon]s.
  ///
  /// If this is not provided, the size will default to [iconSize], the color
  /// will default to [unselectedItemColor].
  ///
  /// It this field is provided, it must contain non-null [IconThemeData.size]
  /// and [IconThemeData.color] properties. Also, if this field is supplied,
  /// [selectedIconTheme] must be provided.
  IconThemeData? unselectedIconTheme;

  /// The [TextStyle] of the [BottomNavigationBarItem] labels when they are
  /// selected.
  TextStyle? selectedLabelStyle;

  /// The [TextStyle] of the [BottomNavigationBarItem] labels when they are not
  /// selected.
  TextStyle? unselectedLabelStyle;

  /// The font size of the [BottomNavigationBarItem] labels when they are selected.
  ///
  /// If [TextStyle.fontSize] of [selectedLabelStyle] is non-null, it will be
  /// used instead of this.
  ///
  /// Defaults to `14.0`.
  double? selectedFontSize;

  /// The font size of the [BottomNavigationBarItem] labels when they are not
  /// selected.
  ///
  /// If [TextStyle.fontSize] of [unselectedLabelStyle] is non-null, it will be
  /// used instead of this.
  ///
  /// Defaults to `12.0`.
  double? unselectedFontSize;

  /// Whether the labels are shown for the unselected [BottomNavigationBarItem]s.
  bool? showUnselectedLabels;

  /// Whether the labels are shown for the selected [BottomNavigationBarItem].
  bool? showSelectedLabels;

  /// The mouse cursor for the [BottomNavigationBarItem]s.
  MouseCursor? mouseCursor;

  /// Whether detected gestures should provide acoustic and/or haptic feedback.
  ///
  /// For example, on Android a tap will produce a clicking sound and a
  /// long-press will produce a short vibration, when feedback is enabled.
  ///
  /// See also:
  ///
  ///  * [Feedback] for providing platform-specific feedback to certain actions.
  bool? enableFeedback;

  /// Whether the BottomNavigationBar should use the legacy color scheme.
  bool? landscapeLayout;

  /// Whether the BottomNavigationBar should use the legacy color scheme.
  bool? useLegacyColorScheme;

  /// Hide the app bar title
  bool? hideAppBarTitle;

  /// Whether the [TabBar] is scrollable.
  bool? isScrollable;

  /// The padding added to each of the [TabBar]'s tabs.
  EdgeInsetsGeometry? padding;

  /// The color of the line that appears below the selected tab.
  Color? indicatorColor;

  /// Whether the [indicatorColor] should be automatically adjusted.
  bool? automaticIndicatorColorAdjustment;

  /// The thickness of the line that appears below the selected tab.
  double? indicatorWeight;

  /// The padding added to each of the [TabBar]'s tabs.
  EdgeInsetsGeometry? indicatorPadding;

  /// The decoration applied to the selected tab indicator.
  Decoration? indicator;

  /// Defines the size of the selected tab indicator.
  TabBarIndicatorSize? indicatorSize;

  /// The color of the divider that appears between [TabBar] tabs.
  Color? dividerColor;

  /// The thickness of the divider that appears between [TabBar] tabs.
  double? dividerHeight;

  /// The color of the [TabBar]'s text and icons when they are selected.
  Color? labelColor;

  /// The text style of the [TabBar]'s selected tab labels.
  TextStyle? labelStyle;

  /// The padding added to the [TabBar]'s tabs.
  EdgeInsetsGeometry? labelPadding;

  /// The color of the [TabBar]'s text and icons when they are not selected.
  Color? unselectedLabelColor;

  /// Determines the way that drag start behavior is handled.
  DragStartBehavior? dragStartBehavior;

  /// The color to use for the [Material] when the [TabBar] is tapped.
  Color? overlayColor;

  /// The physics of the [TabBar].
  ScrollPhysics? physics;

  /// The splash factory used for the ripple effect on the [TabBar].
  InteractiveInkFeatureFactory? splashFactory;

  /// The border radius of the splash.
  BorderRadius? splashBorderRadius;

  /// The alignment of the [TabBar]'s tabs.
  TabAlignment? tabAlignment;

  /// The text scaler
  TextScaler? textScaler;

  WidgetStateProperty<Color?>? overlayColorState;

  /// The duration of the animation when the selected tab changes.
  Duration? animationDuration;

  /// Create a bottom navigation layout
  NavigationHubLayout.bottomNav({
    this.elevation,
    this.type,
    Color? fixedColor,
    this.backgroundColor,
    this.iconSize = 24.0,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.selectedIconTheme,
    this.unselectedIconTheme,
    this.selectedFontSize = 14.0,
    this.unselectedFontSize = 12.0,
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
    this.showSelectedLabels,
    this.showUnselectedLabels,
    this.mouseCursor,
    this.enableFeedback,
    this.landscapeLayout,
    this.useLegacyColorScheme = true,
  }) : hideAppBarTitle = true {
    kind = "bottomNav";
  }

  /// Create a top navigation layout
  NavigationHubLayout.topNav(
      {this.isScrollable = false,
      this.padding,
      this.indicatorColor,
      this.automaticIndicatorColorAdjustment = true,
      this.indicatorWeight = 2.0,
      this.indicatorPadding = EdgeInsets.zero,
      this.indicator,
      this.indicatorSize,
      this.dividerColor = const Color(0xEEEEEEFF),
      this.dividerHeight,
      this.backgroundColor,
      this.labelColor,
      this.labelStyle,
      this.labelPadding,
      this.unselectedLabelColor,
      this.unselectedLabelStyle,
      this.showSelectedLabels,
      this.dragStartBehavior = DragStartBehavior.start,
      this.overlayColor,
      this.mouseCursor,
      this.enableFeedback,
      this.physics,
      this.splashFactory,
      this.splashBorderRadius,
      this.tabAlignment,
      this.textScaler,
      this.animationDuration,
      this.overlayColorState}) {
    kind = "topNav";
  }
}

/// Mixin for the page controls
mixin BottomNavPageControls {
  updateStateResetTab(int index, RouteView path) =>
      updateState(path.stateName(),
          data: {"action": "reset-tab", "tab-index": index});
}

/// Sort a map by key
Map<int, NavigationTab> _sortMapByKey(Map<int, NavigationTab> unsortedMap) {
  // Convert map entries to a list
  var sortedEntries = unsortedMap.entries.toList();

  // Sort the list based on the keys
  sortedEntries.sort((a, b) => a.key.compareTo(b.key));

  // Create a new map from the sorted entries
  return Map.fromEntries(sortedEntries);
}

/// State actions
abstract class StateActions {
  String state;

  StateActions(this.state);
}

/// Navigation hub state actions
class NavigationHubStateActions extends StateActions {
  NavigationHubStateActions(super.state);

  /// Returns the state name for the tab
  String _navigationTabStateName(int tab) {
    return ('${state}_navigation_tab_$tab').toLowerCase();
  }

  /// Reset the tab
  resetTabIndex(int tabIndex) {
    updateState(state, data: {"action": "reset-tab", "tab-index": tabIndex});
  }

  /// Update the badge count
  /// E.g. MyNavigationHub.updateBadgeCount(tab: 0, count: 2);
  updateBadgeCount({required int tab, required int count}) {
    updateState(_navigationTabStateName(tab), data: count);
  }

  /// Increment the badge count
  /// E.g. MyNavigationHub.incrementBadgeCount(tab: 0);
  incrementBadgeCount({required int tab}) async {
    int currentCount =
        (await NyStorage.read(_navigationTabStateName(tab)) ?? 0);
    updateState(_navigationTabStateName(tab), data: currentCount + 1);
  }

  /// Clear the badge count
  /// E.g. MyNavigationHub.clearBadgeCount(tab: 0);
  clearBadgeCount({required int tab}) async {
    await NyStorage.save(_navigationTabStateName(tab), 0);
    updateState(_navigationTabStateName(tab), data: 0);
  }

  /// Update the tab index
  currentTabIndex(int tabIndex) {
    updateState(state, data: {"action": "update-tab", "tab-index": tabIndex});
  }
}
