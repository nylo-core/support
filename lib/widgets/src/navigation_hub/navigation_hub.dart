import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '/helpers/ny_helpers.dart';
import '/widgets/ny_widgets.dart';
import '/local_storage/ny_local_storage.dart';

import '/router/ny_router.dart';

abstract class NavigationHub<T extends StatefulWidget> extends NyPage<T> {
  NavigationHub(this.pages);

  /// Generate the pages
  final dynamic Function() pages;

  /// The pages
  Map<int, NavigationTab> _pages = {};

  /// Whether to maintain the state of the page
  bool get maintainState => true;

  /// The layout of the navigation
  NavigationHubLayout? layout(BuildContext context) {
    return null;
  }

  /// The current index of the page
  int? currentIndex;

  /// The navigator keys
  Map<int, UniqueKey> navigatorKeys = {};

  /// The ordered pages
  Map<int, NavigationTab> get orderedPages => _sortMapByKey(_pages);

  /// The reset map
  Map<int, bool> reset = {};

  /// The initial tab index when the navigation hub first loads.
  ///
  /// Override this to start the hub on a specific tab.
  /// Unlike [getCurrentIndex], this is only read once during initialisation.
  int get initialIndex => 0;

  /// Get the current index
  int get getCurrentIndex => currentIndex ?? 0;

  @override
  bool get stateManaged => true;

  @override
  get init => () {
    final dynamic navData = data();
    int? activeTab;
    if (navData is Map && navData.containsKey('tab-index')) {
      activeTab = navData['tab-index'];
    }
    currentIndex ??= activeTab ?? initialIndex;

    // Store current tab index and total pages count for navigation helpers
    Backpack.instance.save('${stateName}_current_tab', currentIndex);

    if (pages is Future Function()) {
      awaitData(
        perform: () async {
          _pages = await pages();
          Backpack.instance.save('${stateName}_total_pages', _pages.length);
        },
      );
    } else {
      _pages = pages();
      Backpack.instance.save('${stateName}_total_pages', _pages.length);
    }
  };

  /// The navigator key
  UniqueKey? getNavigationKey(MapEntry<int, NavigationTab> page) {
    if (navigatorKeys.containsKey(page.key)) {
      return navigatorKeys[page.key];
    } else {
      navigatorKeys[page.key] = UniqueKey();
      return navigatorKeys[page.key];
    }
  }

  /// Handle the tap event
  void onTap(int index) {
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
          // Store current tab index for navigation helpers
          Backpack.instance.save('${stateName}_current_tab', index);
          break;
        }
      case 'refresh-tab':
        {
          int index = data['tab-index'];
          navigatorKeys[index] = UniqueKey();
          break;
        }
      case 'refresh':
        {
          navigatorKeys.updateAll((key, value) => UniqueKey());
          break;
        }
      default:
        {}
    }
  }

  /// Build the bottom navigation bar item
  BottomNavigationBarItem _buildBottomNavigationBarItem(
    MapEntry<int, NavigationTab> page,
  ) {
    if (page.value.kind == "badge") {
      return BottomNavigationBarItem(
        icon: BadgeTab.fromNavigationTab(
          page.value,
          index: page.key,
          icon: page.value.icon,
          stateName: "${stateName}_navigation_tab_${page.key}",
        ),
        label: page.value.title,
        activeIcon: BadgeTab.fromNavigationTab(
          page.value,
          index: page.key,
          icon: page.value.activeIcon,
          stateName: "${stateName}_navigation_tab_${page.key}",
        ),
        backgroundColor: page.value.backgroundColor,
        tooltip: page.value.tooltip,
      );
    }

    if (page.value.kind == "alert") {
      return BottomNavigationBarItem(
        icon: AlertTab.fromNavigationTab(
          page.value,
          index: page.key,
          icon: page.value.icon,
          stateName: "${stateName}_navigation_tab_${page.key}",
        ),
        label: page.value.title,
        activeIcon: AlertTab.fromNavigationTab(
          page.value,
          index: page.key,
          icon: page.value.activeIcon,
          stateName: "${stateName}_navigation_tab_${page.key}",
        ),
        backgroundColor: page.value.backgroundColor,
        tooltip: page.value.tooltip,
      );
    }

    TextStyle textStyle = TextStyle();
    NavigationHubLayout? _layout = layout(context);
    if (currentIndex == page.key) {
      textStyle =
          _layout?.selectedLabelStyle?.copyWith() ?? textStyle.copyWith();
      if (_layout?.selectedItemColor != null) {
        textStyle = textStyle.copyWith(color: _layout?.selectedItemColor);
      }
    } else {
      textStyle =
          _layout?.unselectedLabelStyle?.copyWith() ?? textStyle.copyWith();
      if (_layout?.unselectedItemColor != null) {
        textStyle = textStyle.copyWith(color: _layout?.unselectedItemColor);
      }
    }
    Widget textWidget = Text(page.value.title ?? "", style: textStyle);

    return BottomNavigationBarItem(
      icon: page.value.icon ?? textWidget,
      label: page.value.icon == null ? "" : page.value.title,
      activeIcon: page.value.activeIcon ?? page.value.icon ?? textWidget,
      backgroundColor: page.value.backgroundColor,
      tooltip: page.value.tooltip,
    );
  }

  /// Helper to build the bottom nav widget
  Widget bottomNavBuilder(
    BuildContext context,
    Widget body,
    Widget? bottomNavigationBar,
  ) {
    throw UnimplementedError();
  }

  NavigationHubLayout? _layout;

  @override
  Widget view(BuildContext context) {
    Map<int, NavigationTab> pages = orderedPages;
    _layout = layout(context);

    if (_layout?.kind == "journey") {
      return _buildJourneyLayout(context, pages);
    }

    if (_layout?.kind == "bottomNav") {
      Widget body = maintainState
          ? IndexedStack(
              index: currentIndex,
              children: [
                for (var page in pages.entries)
                  Navigator(
                    key: getNavigationKey(page),
                    onGenerateRoute: (settings) => MaterialPageRoute(
                      builder: (context) =>
                          page.value.page ?? SizedBox.shrink(),
                      settings: settings,
                    ),
                  ),
              ],
            )
          : Navigator(
              key: getNavigationKey(pages.entries.elementAt(getCurrentIndex)),
              onGenerateRoute: (settings) => MaterialPageRoute(
                builder: (context) =>
                    (pages.entries.elementAt(getCurrentIndex).value.page ??
                    SizedBox.shrink()),
                settings: settings,
              ),
            );

      // Build the navigation bar items
      List<BottomNavigationBarItem> navItems = [
        for (MapEntry<int, NavigationTab> page in pages.entries)
          _buildBottomNavigationBarItem(page),
      ];

      // Check for custom builder first
      if (_layout?.navBarBuilder != null) {
        final data = NavBarData(
          items: navItems,
          currentIndex: getCurrentIndex,
          onTap: onTap,
        );

        Widget customNavBar = _layout!.navBarBuilder!(context, data);

        try {
          return bottomNavBuilder(context, body, customNavBar);
        } on UnimplementedError catch (_) {
          return Scaffold(body: body, bottomNavigationBar: customNavBar);
        }
      }

      // Build standard nav bar
      Widget bottomNavigationBar = BottomNavigationBar(
        currentIndex: getCurrentIndex,
        onTap: onTap,
        selectedLabelStyle:
            _layout?.selectedLabelStyle ??
            TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            _layout?.unselectedLabelStyle ??
            TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
        showSelectedLabels: _layout?.showSelectedLabels ?? true,
        showUnselectedLabels: _layout?.showUnselectedLabels ?? true,
        selectedItemColor: _layout?.selectedItemColor ?? Colors.black,
        unselectedItemColor: _layout?.unselectedItemColor ?? Colors.black,
        selectedFontSize: _layout?.selectedFontSize ?? 14.0,
        unselectedFontSize: _layout?.unselectedFontSize ?? 12.0,
        iconSize: _layout?.iconSize ?? 24.0,
        elevation: _layout?.elevation ?? 8.0,
        backgroundColor: _layout?.backgroundColor,
        type: _layout?.type ?? BottomNavigationBarType.fixed,
        items: navItems,
      );

      // Apply style if provided
      if (_layout?.style != null) {
        bottomNavigationBar = _layout!.style!.build(
          context,
          bottomNavigationBar,
        );
      }

      try {
        return bottomNavBuilder(context, body, bottomNavigationBar);
      } on UnimplementedError catch (_) {
        return Scaffold(body: body, bottomNavigationBar: bottomNavigationBar);
      }
    }

    if (_layout?.kind == "topNav") {
      return DefaultTabController(
        length: pages.length,
        initialIndex: getCurrentIndex,
        animationDuration: _layout?.animationDuration,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: _layout?.backgroundColor,
            title: pages[getCurrentIndex]?.title == null
                ? null
                : Text(pages[getCurrentIndex]?.title ?? ""),
            toolbarHeight: (_layout?.hideAppBarTitle ?? true) ? 0 : null,
            bottom: TabBar(
              isScrollable: _layout?.isScrollable ?? false,
              labelColor: _layout?.labelColor,
              labelStyle: _layout?.labelStyle,
              labelPadding: _layout?.labelPadding,
              unselectedLabelColor: _layout?.unselectedLabelColor,
              unselectedLabelStyle: _layout?.unselectedLabelStyle,
              indicatorColor: _layout?.indicatorColor,
              automaticIndicatorColorAdjustment:
                  _layout?.automaticIndicatorColorAdjustment ?? true,
              indicatorWeight: _layout?.indicatorWeight ?? 2.0,
              indicatorPadding: _layout?.indicatorPadding ?? EdgeInsets.zero,
              indicator: _layout?.indicator,
              indicatorSize: _layout?.indicatorSize,
              dividerColor: _layout?.dividerColor,
              dividerHeight: _layout?.dividerHeight,
              dragStartBehavior:
                  _layout?.dragStartBehavior ?? DragStartBehavior.start,
              overlayColor: _layout?.overlayColorState,
              mouseCursor: _layout?.mouseCursor,
              enableFeedback: _layout?.enableFeedback,
              physics: _layout?.physics,
              splashFactory: _layout?.splashFactory,
              splashBorderRadius: _layout?.splashBorderRadius,
              tabAlignment: _layout?.tabAlignment,
              textScaler: _layout?.textScaler,
              tabs: [
                for (MapEntry page in pages.entries)
                  _buildTab(page.value, page.key),
              ],
              onTap: onTap,
            ),
          ),
          body: maintainState
              ? IndexedStack(
                  index: getCurrentIndex,
                  children: [
                    for (var page in pages.entries)
                      Navigator(
                        key: getNavigationKey(page),
                        onGenerateRoute: (settings) => MaterialPageRoute(
                          builder: (context) =>
                              (page.value.page ?? SizedBox.shrink()),
                          settings: settings,
                        ),
                      ),
                  ],
                )
              : TabBarView(
                  physics: _layout?.physics,
                  children: [
                    for (var page in pages.entries)
                      Navigator(
                        key: getNavigationKey(page),
                        onGenerateRoute: (settings) => MaterialPageRoute(
                          builder: (context) =>
                              (page.value.page ?? SizedBox.shrink()),
                          settings: settings,
                        ),
                      ),
                  ],
                ),
        ),
      );
    }
    throw Exception("Invalid layout type");
  }

  /// Build journey layout
  Widget _buildJourneyLayout(
    BuildContext context,
    Map<int, NavigationTab> pages,
  ) {
    int totalPages = pages.length;
    int currentPage = getCurrentIndex;
    NavigationTab currentTab = pages[currentPage]!;

    // Per-tab override takes precedence over layout-level default
    final progressStyle = currentTab.progressStyle ?? _layout?.progressStyle;

    // Build progress indicator (only if progressStyle is not null)
    Widget? progressIndicator;
    ProgressIndicatorPosition position = ProgressIndicatorPosition.top;
    if (progressStyle != null) {
      position = progressStyle.position;
      final padding =
          progressStyle.padding ??
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
      progressIndicator = Padding(
        padding: padding,
        child: progressStyle.indicator.build(context, currentPage, totalPages),
      );
    }

    Widget content = Column(
      children: [
        // Progress indicator at top (if enabled)
        if (progressIndicator != null &&
            position == ProgressIndicatorPosition.top)
          progressIndicator,

        // Main content - full control to developer
        Expanded(
          child: Navigator(
            key: getNavigationKey(MapEntry(currentPage, currentTab)),
            onDidRemovePage: (page) {},
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (context) => currentTab.page ?? SizedBox.shrink(),
              settings: settings,
            ),
          ),
        ),

        // Progress indicator at bottom (if enabled)
        if (progressIndicator != null &&
            position == ProgressIndicatorPosition.bottom)
          progressIndicator,
      ],
    );

    Widget body = (_layout?.useSafeArea ?? true)
        ? SafeArea(child: content)
        : content;

    if (_layout?.backgroundGradient != null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: _layout?.backgroundGradient),
          child: body,
        ),
      );
    }

    return Scaffold(backgroundColor: _layout?.backgroundColor, body: body);
  }

  /// Build the tab icon
  Widget? _buildTabIcon(NavigationTab page, int pageKey) {
    String tabTitle = page.title ?? "";
    bool isCurrentIndex = getCurrentIndex == pageKey;
    Widget icon = page.icon ?? Text(tabTitle);

    if (isCurrentIndex) {
      icon = page.activeIcon ?? icon;
    }

    if (page.kind == "badge") {
      return BadgeTab.fromNavigationTab(
        page,
        index: pageKey,
        icon: icon,
        stateName: "${stateName}_navigation_tab_$pageKey",
      );
    }

    if (page.kind == "alert") {
      return AlertTab.fromNavigationTab(
        page,
        index: pageKey,
        icon: icon,
        stateName: "${stateName}_navigation_tab_$pageKey",
      );
    }

    if (getCurrentIndex == pageKey) {
      return page.activeIcon ?? page.icon;
    }
    return getCurrentIndex == pageKey ? page.activeIcon : page.icon;
  }

  /// Build the tab text
  String? _buildTabText(NavigationTab page) {
    if (_layout?.showSelectedLabels == false) {
      return null;
    }

    if (page.icon == null && ["badge", "alert"].contains(page.kind)) {
      return null;
    }

    return page.title;
  }

  /// Build the tab child
  Widget? _buildTabChild(NavigationTab page) {
    if (["badge", "alert"].contains(page.kind)) {
      return null;
    }

    if (page.icon == null && _layout?.showSelectedLabels == false) {
      return Text(page.title ?? "");
    }

    return null;
  }

  /// Build the tab
  Tab _buildTab(NavigationTab page, int pageKey) {
    return Tab(
      text: _buildTabText(page),
      icon: _buildTabIcon(page, pageKey),
      child: _buildTabChild(page),
    );
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

  /// The gradient background of the navigation layout.
  ///
  /// If set, this will take precedence over [backgroundColor].
  Gradient? backgroundGradient;

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

  /// Style preset for the bottom navigation bar.
  ///
  /// Use [BottomNavStyle.material] for the default Flutter style.
  BottomNavStyle? style;

  /// Progress style for journey layouts.
  ///
  /// When set on [NavigationHubLayout.journey], acts as the global default.
  /// Individual tabs can override this via [NavigationTab.journey(progressStyle: ...)].
  JourneyProgressStyle? progressStyle;

  /// Whether to wrap journey content in a [SafeArea].
  ///
  /// When `true` (default), content is inset from system UI (status bar,
  /// home indicator). Set to `false` for edge-to-edge journey pages where
  /// a background should extend under system UI.
  ///
  /// Only applies to [NavigationHubLayout.journey].
  bool? useSafeArea;

  /// Custom builder for complete control over the bottom navigation bar.
  ///
  /// When provided, this builder receives [NavBarData] containing the
  /// items, current index, and onTap callback. The [style] parameter
  /// is ignored when [navBarBuilder] is provided.
  ///
  /// Example:
  /// ```dart
  /// NavigationHubLayout.bottomNav(
  ///   navBarBuilder: (context, data) {
  ///     return MyCustomNavBar(
  ///       items: data.items,
  ///       currentIndex: data.currentIndex,
  ///       onTap: data.onTap,
  ///     );
  ///   },
  /// )
  /// ```
  Widget Function(BuildContext context, NavBarData data)? navBarBuilder;

  /// Create a bottom navigation layout
  NavigationHubLayout.bottomNav({
    this.elevation,
    this.type,
    Color? fixedColor,
    this.backgroundColor,
    this.backgroundGradient,
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
    this.style,
    this.navBarBuilder,
  }) : hideAppBarTitle = true {
    kind = "bottomNav";
  }

  /// Create a top navigation layout
  NavigationHubLayout.topNav({
    this.isScrollable = false,
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
    this.backgroundGradient,
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
    this.overlayColorState,
  }) {
    kind = "topNav";
  }

  /// Create a journey navigation layout
  NavigationHubLayout.journey({
    this.backgroundColor,
    this.backgroundGradient,
    this.progressStyle,
    this.useSafeArea = true,
  }) {
    kind = "journey";
  }
}

/// Mixin for the page controls
mixin BottomNavPageControls {
  void updateStateResetTab(int index, RouteView path) => updateState(
    path.stateName(),
    data: {"action": "reset-tab", "tab-index": index},
  );
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

/// Navigation hub state actions
class NavigationHubStateActions extends StateActions {
  NavigationHubStateActions(super.state);

  /// Returns the state name for the tab
  String _navigationTabStateName(int tab) {
    return ('${state}_navigation_tab_$tab').toLowerCase();
  }

  /// Reset the tab
  void resetTabIndex(int tabIndex) {
    updateState(state, data: {"action": "reset-tab", "tab-index": tabIndex});
  }

  /// Update the badge count
  /// E.g. MyNavigationHub.updateBadgeCount(tab: 0, count: 2);
  void updateBadgeCount({required int tab, required int count}) {
    updateState(_navigationTabStateName(tab), data: count);
  }

  /// Increment the badge count
  /// E.g. MyNavigationHub.incrementBadgeCount(tab: 0);
  Future<void> incrementBadgeCount({required int tab}) async {
    int currentCount =
        (await NyStorage.read(_navigationTabStateName(tab)) ?? 0);
    updateState(_navigationTabStateName(tab), data: currentCount + 1);
  }

  /// Clear the badge count
  /// E.g. MyNavigationHub.clearBadgeCount(tab: 0);
  Future<void> clearBadgeCount({required int tab}) async {
    await NyStorage.save(_navigationTabStateName(tab), 0);
    updateState(_navigationTabStateName(tab), data: 0);
  }

  /// Update the tab index
  void currentTabIndex(int tabIndex) {
    updateState(state, data: {"action": "update-tab", "tab-index": tabIndex});
  }

  /// Enable the alert for the [tab]
  void alertEnableTab({required int tab}) {
    updateState(_navigationTabStateName(tab), data: {"action": "enable"});
  }

  /// Disable the alert for the [tab]
  void alertDisableTab({required int tab}) {
    updateState(_navigationTabStateName(tab), data: {"action": "disable"});
  }

  /// Refresh a specific tab, forcing it to rebuild
  /// E.g. MyNavigationHub.refreshTab(0);
  void refreshTab(int tabIndex) {
    updateState(state, data: {"action": "refresh-tab", "tab-index": tabIndex});
  }

  /// Refresh all tabs, forcing them to rebuild
  /// E.g. MyNavigationHub.refresh();
  void refresh() {
    updateState(state, data: {"action": "refresh"});
  }

  /// Navigate to the next page in a journey layout
  /// Returns true if navigation was successful, false if already at last page
  Future<bool> nextPage() async {
    // Get current page index
    dynamic currentData = Backpack.instance.read('${state}_current_tab');
    int currentIndex = (currentData is int) ? currentData : 0;

    // Get total pages count (requires storing this value)
    dynamic totalPagesData = await Backpack.instance.read(
      '${state}_total_pages',
    );
    int? totalPages = totalPagesData is int ? totalPagesData : null;

    // If we don't know total pages, we can't validate if we're at the end
    // So we'll just try to navigate to the next page
    if (totalPages == null || currentIndex < totalPages - 1) {
      updateState(
        state,
        data: {"action": "update-tab", "tab-index": currentIndex + 1},
      );
      return true;
    }

    return false; // Already at last page
  }

  /// Navigate to the previous page in a journey layout
  /// Returns true if navigation was successful, false if already at first page
  Future<bool> previousPage() async {
    // Get current page index
    dynamic currentData = await Backpack.instance.read('${state}_current_tab');
    int currentIndex = (currentData is int) ? currentData : 0;

    if (currentIndex > 0) {
      updateState(
        state,
        data: {"action": "update-tab", "tab-index": currentIndex - 1},
      );
      return true;
    }

    return false; // Already at first page
  }
}
