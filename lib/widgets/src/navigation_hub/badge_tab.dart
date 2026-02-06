import 'package:flutter/material.dart';
import '/helpers/ny_helpers.dart';
import '/local_storage/ny_local_storage.dart';
import '/widgets/ny_widgets.dart';

/// BadgeTab is a class that holds the state, icon, initialCount, backgroundColor, textColor, smallSize, largeSize, textStyle, padding, alignment, offset, and isLabelVisible of a badge tab.
class BadgeTab extends StatefulWidget {
  const BadgeTab({
    super.key,
    required this.state,
    this.icon,
    this.initialCount,
    this.backgroundColor,
    this.textColor,
    this.smallSize,
    this.largeSize,
    this.textStyle,
    this.padding,
    this.alignment,
    this.offset,
    this.isLabelVisible = true,
  }) : rememberCount = false;

  /// Create a BadgeTab from a NavigationTab
  BadgeTab.fromNavigationTab(
    NavigationTab page, {
    super.key,
    required int index,
    this.icon,
    String? stateName,
  }) : state = (stateName ?? "${page.title}_navigation_tab_$index"),
       initialCount = page.meta['initialCount'],
       rememberCount = page.meta['rememberCount'],
       backgroundColor = page.backgroundColor,
       textColor = page.meta['textColor'],
       smallSize = page.meta['smallSize'],
       largeSize = page.meta['largeSize'],
       textStyle = page.meta['textStyle'],
       padding = page.meta['padding'],
       alignment = page.meta['alignment'],
       offset = page.meta['offset'],
       isLabelVisible = page.meta['isLabelVisible'];

  final String state;
  final int? initialCount;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? smallSize;
  final double? largeSize;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final Alignment? alignment;
  final Offset? offset;
  final bool? isLabelVisible;
  final bool? rememberCount;

  @override
  State<BadgeTab> createState() => _BadgeTabState();
}

class _BadgeTabState extends NyState<BadgeTab> {
  /// The current count of the badge
  int currentCount = 0;

  @override
  void initState() {
    stateName = widget.state.toLowerCase();
    super.initState();
  }

  @override
  get init => () async {
    currentCount = widget.initialCount ?? 0;
    if (stateName != null && widget.rememberCount == true) {
      dynamic badgeCountData = await NyStorage.read(stateName!);
      if (badgeCountData is! int) {
        badgeCountData = null;
      }
      if (badgeCountData != null) {
        currentCount = badgeCountData;
      } else {
        await NyStorage.save(stateName!, currentCount);
      }
    }
    if (stateData != null && stateData is int) {
      currentCount = stateData!;
    }
  };

  @override
  LoadingStyle get loadingStyle =>
      LoadingStyle.normal(child: widget.icon ?? SizedBox.shrink());

  @override
  stateUpdated(dynamic data) async {
    if (data is int) {
      currentCount = data;
      if (widget.rememberCount == true) {
        await NyStorage.save(stateName!, data);
      }
    }
  }

  @override
  Widget view(BuildContext context) {
    bool widgetIsText = widget.icon is Text;
    if (currentCount == 0) {
      return widget.icon ?? SizedBox.shrink();
    }
    return Badge.count(
      count: currentCount,
      backgroundColor: widget.backgroundColor,
      textColor: widget.textColor,
      smallSize: widget.smallSize,
      largeSize: widget.largeSize,
      textStyle: widget.textStyle,
      padding: widget.padding,
      alignment: widget.alignment,
      offset: widgetIsText == true && widget.offset == null
          ? Offset(20, -10)
          : widget.offset,
      isLabelVisible: widget.isLabelVisible ?? true,
      child: widget.icon,
    );
  }
}
