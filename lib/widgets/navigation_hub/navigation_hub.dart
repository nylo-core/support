import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '/helpers/backpack.dart';
import '/widgets/ny_widgets.dart';
import '/widgets/navigation_hub/alert_tab.dart';
import '/helpers/extensions.dart';
import '/local_storage/local_storage.dart';
import '/widgets/navigation_hub/badge_tab.dart';

import '/helpers/helper.dart';
import '/router/router.dart';

abstract class NavigationHub<T extends StatefulWidget> extends NyPage<T> {
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
  int? currentIndex;

  /// The navigator keys
  Map<int, UniqueKey> navigatorKeys = {};

  /// The ordered pages
  Map<int, NavigationTab> get orderedPages => _sortMapByKey(_pages);

  /// The reset map
  Map<int, bool> reset = {};

  /// Get the current index
  int get getCurrentIndex => currentIndex ?? 0;

  @override
  bool get stateManaged => true;

  @override
  get init => () {
        int? activeTab = data(defaultValue: {"tab-index": 0})['tab-index'];
        currentIndex ??= activeTab ?? 0;

        // Store current tab index and total pages count for navigation helpers
        Backpack.instance.save('${stateName}_current_tab', currentIndex);

        if (pages is Future Function()) {
          awaitData(perform: () async {
            _pages = await pages();
            Backpack.instance.save('${stateName}_total_pages', _pages.length);
          });
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
      default:
        {}
    }
  }

  /// Build the bottom navigation bar item
  BottomNavigationBarItem _buildBottomNavigationBarItem(
      MapEntry<int, NavigationTab> page) {
    if (page.value.kind == "badge") {
      return BottomNavigationBarItem(
        icon: BadgeTab.fromNavigationTab(page.value,
            index: page.key,
            icon: page.value.icon,
            stateName: "${stateName}_navigation_tab_${page.key}"),
        label: page.value.title,
        activeIcon: BadgeTab.fromNavigationTab(page.value,
            index: page.key,
            icon: page.value.activeIcon,
            stateName: "${stateName}_navigation_tab_${page.key}"),
        backgroundColor: page.value.backgroundColor,
        tooltip: page.value.tooltip,
      );
    }

    if (page.value.kind == "alert") {
      return BottomNavigationBarItem(
        icon: AlertTab.fromNavigationTab(page.value,
            index: page.key,
            icon: page.value.icon,
            stateName: "${stateName}_navigation_tab_${page.key}"),
        label: page.value.title,
        activeIcon: AlertTab.fromNavigationTab(page.value,
            index: page.key,
            icon: page.value.activeIcon,
            stateName: "${stateName}_navigation_tab_${page.key}"),
        backgroundColor: page.value.backgroundColor,
        tooltip: page.value.tooltip,
      );
    }

    TextStyle textStyle = TextStyle();
    if (currentIndex == page.key) {
      textStyle =
          layout?.selectedLabelStyle?.copyWith() ?? textStyle.copyWith();
      if (layout?.selectedItemColor != null) {
        textStyle = textStyle.copyWith(color: layout?.selectedItemColor);
      }
    }
    Widget textWidget = Text(page.value.title ?? "", style: textStyle);

    return BottomNavigationBarItem(
      icon: page.value.icon ?? textWidget,
      label: page.value.icon == null ? "" : page.value.title,
      activeIcon: page.value.activeIcon ?? textWidget,
      backgroundColor: page.value.backgroundColor,
      tooltip: page.value.tooltip,
    );
  }

  /// Helper to build the bottom nav widget
  Widget bottomNavBuilder(
      BuildContext context, Widget body, Widget? bottomNavigationBar) {
    throw UnimplementedError();
  }

  @override
  Widget view(BuildContext context) {
    Map<int, NavigationTab> pages = orderedPages;

    if (layout?.kind == "journey") {
      return _buildJourneyLayout(context, pages);
    }

    if (layout?.kind == "bottomNav") {
      Widget body = maintainState
          ? IndexedStack(index: currentIndex, children: [
              for (var page in pages.entries)
                Navigator(
                  key: getNavigationKey(page),
                  onGenerateRoute: (settings) => MaterialPageRoute(
                    builder: (context) => page.value.page ?? SizedBox.shrink(),
                    settings: settings,
                  ),
                )
            ])
          : Navigator(
              key: getNavigationKey(pages.entries.elementAt(getCurrentIndex)),
              onGenerateRoute: (settings) => MaterialPageRoute(
                builder: (context) =>
                    (pages.entries.elementAt(getCurrentIndex).value.page ??
                        SizedBox.shrink()),
                settings: settings,
              ),
            );

      Widget? bottomNavigationBar = BottomNavigationBar(
        currentIndex: getCurrentIndex,
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
            _buildBottomNavigationBarItem(page),
        ],
      );
      try {
        return bottomNavBuilder(context, body, bottomNavigationBar);
      } on UnimplementedError catch (_) {
        return Scaffold(
          body: body,
          bottomNavigationBar: bottomNavigationBar,
        );
      }
    }

    if (layout?.kind == "topNav") {
      return DefaultTabController(
        length: pages.length,
        initialIndex: getCurrentIndex,
        animationDuration: layout?.animationDuration,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: layout?.backgroundColor,
            title: pages[getCurrentIndex]?.title == null
                ? null
                : Text(pages[getCurrentIndex]?.title ?? ""),
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
                  _buildTab(page.value, page.key),
              ],
              onTap: onTap,
            ),
          ),
          body: maintainState
              ? IndexedStack(index: getCurrentIndex, children: [
                  for (var page in pages.entries)
                    Navigator(
                      key: getNavigationKey(page),
                      onGenerateRoute: (settings) => MaterialPageRoute(
                        builder: (context) =>
                            (page.value.page ?? SizedBox.shrink()),
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
                          builder: (context) =>
                              (page.value.page ?? SizedBox.shrink()),
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

  /// Build journey layout
  Widget _buildJourneyLayout(
      BuildContext context, Map<int, NavigationTab> pages) {
    int totalPages = pages.length;
    int currentPage = getCurrentIndex;
    bool isFirstPage = currentPage == 0;
    bool isLastPage = currentPage == totalPages - 1;
    NavigationTab currentTab = pages[currentPage]!;

    // Progress indicator
    Widget? progressIndicator;
    if (layout?.showProgressIndicator == true) {
      progressIndicator = Padding(
        padding: layout?.progressIndicatorPadding ?? EdgeInsets.zero,
        child: _buildProgressIndicator(context, currentPage, totalPages),
      );
    }

    // Navigation buttons
    Widget navigationButtons = Padding(
      padding: layout?.buttonPadding ??
          EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: _buildJourneyButtons(
          context, isFirstPage, isLastPage, currentPage, totalPages),
    );

    Widget content = Column(
      children: [
        // Top progress indicator
        if (layout?.showProgressIndicator == true &&
            layout?.progressIndicatorPosition == ProgressIndicatorPosition.top)
          progressIndicator!,

        // Main content
        Expanded(
          child: Navigator(
            key: getNavigationKey(MapEntry(currentPage, currentTab)),
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (context) => currentTab.page ?? SizedBox.shrink(),
              settings: settings,
            ),
          ),
        ),

        // Bottom progress indicator
        if (layout?.showProgressIndicator == true &&
            layout?.progressIndicatorPosition ==
                ProgressIndicatorPosition.bottom)
          progressIndicator!,

        // Navigation buttons
        navigationButtons,
      ],
    );

    // Apply SafeArea if needed
    final bool useSafeArea = layout?.useSafeArea ?? true;

    if (layout?.backgroundGradient != null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: layout?.backgroundGradient),
          child: useSafeArea ? SafeArea(child: content) : content,
        ),
      );
    }

    return Scaffold(
      backgroundColor: layout?.backgroundColor,
      body: useSafeArea ? SafeArea(child: content) : content,
    );
  }

  /// Builds the appropriate progress indicator based on style
  Widget _buildProgressIndicator(
      BuildContext context, int currentStep, int totalSteps) {
    // Use the build method from JourneyProgressStyle
    if (layout?.progressStyle != null) {
      return layout!.progressStyle!.build(context, currentStep, totalSteps);
    } else {
      // Default fallback to linear progress indicator if no style is set
      return LinearProgressIndicator(
        value: (currentStep + 1) / totalSteps,
        minHeight: 4.0,
      );
    }
  }

  /// Build journey navigation buttons
  Widget _buildJourneyButtons(BuildContext context, bool isFirstPage,
      bool isLastPage, int currentPage, int totalPages) {
    if (layout?.buttonStyle != null) {
      return Row(
        mainAxisAlignment: _getButtonRowAlignment(),
        children: [
          // Back button
          layout?.showBackButton != false
              ? layout!.buttonStyle!.buildBackButton(
                  context,
                  isFirstPage
                      ? null
                      : () {
                          Backpack.instance.save(
                              '${stateName}_current_tab', currentPage - 1);
                          onTap(currentPage - 1);
                        })
              : const SizedBox.shrink(),

          // Spacing between buttons based on layout type
          if (layout?.buttonLayout == JourneyButtonLayout.center)
            const SizedBox(width: 16),
          if (layout?.buttonLayout == JourneyButtonLayout.nextRight)
            const SizedBox(width: 8),

          // Next/Complete button
          layout?.showNextButton != false
              ? layout!.buttonStyle!.buildNextButton(
                  context,
                  isLastPage && layout?.onComplete == null
                      ? null
                      : () {
                          Backpack.instance.save(
                              '${stateName}_current_tab', currentPage + 1);
                          if (isLastPage) {
                            layout?.onComplete?.call();
                          } else {
                            onTap(currentPage + 1);
                          }
                        },
                  isLastPage)
              : const SizedBox.shrink(),
        ],
      );
    }

    return SizedBox.shrink();
  }

  /// Helper method to get button row alignment based on buttonLayout
  MainAxisAlignment _getButtonRowAlignment() {
    switch (layout?.buttonLayout) {
      case JourneyButtonLayout.spaceBetween:
        return MainAxisAlignment.spaceBetween;
      case JourneyButtonLayout.nextRight:
        return MainAxisAlignment.end;
      case JourneyButtonLayout.center:
        return MainAxisAlignment.center;
      default:
        return MainAxisAlignment.spaceBetween;
    }
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
      return BadgeTab.fromNavigationTab(page,
          index: pageKey,
          icon: icon,
          stateName: "${stateName}_navigation_tab_$pageKey");
    }

    if (page.kind == "alert") {
      return AlertTab.fromNavigationTab(page,
          index: pageKey,
          icon: icon,
          stateName: "${stateName}_navigation_tab_$pageKey");
    }

    if (getCurrentIndex == pageKey) {
      return page.activeIcon ?? page.icon;
    }
    return getCurrentIndex == pageKey ? page.activeIcon : page.icon;
  }

  /// Build the tab text
  String? _buildTabText(NavigationTab page) {
    if (layout?.showSelectedLabels == false) {
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

    if (page.icon == null && layout?.showSelectedLabels == false) {
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

  /// Whether to show a progress indicator for journey
  bool? showProgressIndicator;

  /// The position of the progress indicator
  ProgressIndicatorPosition? progressIndicatorPosition;

  /// The padding of the progress indicator
  EdgeInsets? progressIndicatorPadding;

  /// The style of the progress indicator
  JourneyProgressStyle? progressStyle;

  /// Whether to show the back button
  bool? showBackButton;

  /// The back button icon
  IconData? backButtonIcon;

  /// The text for the back button
  String? backButtonText;

  /// The style of the back button text
  TextStyle? backButtonTextStyle;

  /// The text for the next button
  String? nextButtonText;

  /// The text for the complete button
  String? completeButtonText;

  /// The style of the complete button text
  TextStyle? completeButtonTextStyle;

  /// The complete button icon
  IconData? completeButtonIcon;

  /// The style of the next button text
  TextStyle? nextButtonTextStyle;

  /// The next button icon
  IconData? nextButtonIcon;

  /// Whether to show button text
  bool? showButtonText;

  /// Whether to show the next button
  bool? showNextButton;

  /// Button layout
  JourneyButtonLayout? buttonLayout;

  /// Use safe area
  bool? useSafeArea;

  /// The padding of the buttons
  EdgeInsets? buttonPadding;

  /// On complete callback
  Function()? onComplete;

  /// The style of journey buttons
  JourneyButtonStyle? buttonStyle;

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
      this.overlayColorState}) {
    kind = "topNav";
  }

  /// Create a journey navigation layout
  NavigationHubLayout.journey({
    this.backgroundColor,
    this.backgroundGradient,
    this.showProgressIndicator = true,
    this.progressIndicatorPosition = ProgressIndicatorPosition.top,
    this.progressIndicatorPadding =
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    this.buttonLayout = JourneyButtonLayout.spaceBetween,
    this.animationDuration = const Duration(milliseconds: 300),
    this.useSafeArea = true,
    this.buttonPadding =
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
    this.progressStyle = const JourneyProgressStyle.linear(),
    this.onComplete,
    this.buttonStyle,
  }) {
    kind = "journey";
  }
}

/// The position of the progress indicator in the journey layout
enum ProgressIndicatorPosition {
  /// Show the progress indicator at the top of the page
  top,

  /// Show the progress indicator at the bottom of the page
  bottom
}

/// The layout of the journey buttons
enum JourneyButtonLayout {
  /// Show the back and next buttons at the bottom with space between
  spaceBetween,

  /// Show the back and next buttons at the bottom with the next button on the right
  nextRight,

  /// Show the back and next buttons at the bottom centered
  center
}

/// Mixin for the page controls
mixin BottomNavPageControls {
  void updateStateResetTab(int index, RouteView path) =>
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
    updateState(_navigationTabStateName(tab), data: {
      "action": "enable",
    });
  }

  /// Disable the alert for the [tab]
  void alertDisableTab({required int tab}) {
    updateState(_navigationTabStateName(tab), data: {
      "action": "disable",
    });
  }

  /// Navigate to the next page in a journey layout
  /// Returns true if navigation was successful, false if already at last page
  Future<bool> nextPage() async {
    // Get current page index
    dynamic currentData = Backpack.instance.read('${state}_current_tab');
    int currentIndex = (currentData is int) ? currentData : 0;

    // Get total pages count (requires storing this value)
    dynamic totalPagesData =
        await Backpack.instance.read('${state}_total_pages');
    int? totalPages = totalPagesData is int ? totalPagesData : null;

    // If we don't know total pages, we can't validate if we're at the end
    // So we'll just try to navigate to the next page
    if (totalPages == null || currentIndex < totalPages - 1) {
      updateState(state,
          data: {"action": "update-tab", "tab-index": currentIndex + 1});
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
      updateState(state,
          data: {"action": "update-tab", "tab-index": currentIndex - 1});
      return true;
    }

    return false; // Already at first page
  }
}
