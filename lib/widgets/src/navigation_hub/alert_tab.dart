import 'package:flutter/material.dart';
import '/helpers/ny_helpers.dart';
import '/local_storage/ny_local_storage.dart';
import '/widgets/ny_widgets.dart';

/// AlertTab is a class that holds the state, icon, initialCount, backgroundColor, textColor, smallSize, largeSize, textStyle, padding, alignment, offset, and isLabelVisible of an alert tab.
class AlertTab extends StatefulWidget {
  const AlertTab({
    super.key,
    required this.state,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.smallSize,
    this.largeSize,
    this.textStyle,
    this.padding,
    this.alignment,
    this.offset,
    this.isLabelVisible = true,
    this.alertEnabled,
    this.rememberAlert = true,
    this.alertColor,
  });

  /// Create a AlertTab from a NavigationTab
  AlertTab.fromNavigationTab(
    NavigationTab page, {
    super.key,
    required int index,
    this.icon,
    String? stateName,
  }) : state = (stateName ?? "${page.title}_navigation_tab_$index"),
       alertEnabled = page.meta['alertEnabled'],
       rememberAlert = page.meta['rememberAlert'],
       alertColor = page.alertColor,
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
  final bool? alertEnabled;
  final bool? rememberAlert;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? alertColor;
  final double? smallSize;
  final double? largeSize;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final Alignment? alignment;
  final Offset? offset;
  final bool? isLabelVisible;

  @override
  State<AlertTab> createState() => _AlertTabState();
}

class _AlertTabState extends NyState<AlertTab> {
  /// The current state of the alert
  bool? _alertEnabled;

  @override
  void initState() {
    stateName = widget.state.toLowerCase();
    super.initState();
  }

  @override
  get init => () async {
    if (stateData != null && stateData is bool) {
      _alertEnabled = stateData!;
    }

    if (stateName != null && widget.rememberAlert == true) {
      dynamic alertData = await NyStorage.read(stateName!);
      if (alertData is! bool) {
        alertData = null;
      }

      if (alertData == null) {
        if (widget.alertEnabled != null) {
          _alertEnabled = widget.alertEnabled!;
          await NyStorage.save(stateName!, _alertEnabled);
        }
        return;
      }

      _alertEnabled = alertData;
      await NyStorage.save(stateName!, _alertEnabled);
      return;
    } else {
      _alertEnabled = widget.alertEnabled;
    }

    _alertEnabled ??= false;
  };

  @override
  LoadingStyle get loadingStyle =>
      LoadingStyle.normal(child: widget.icon ?? SizedBox.shrink());

  @override
  stateUpdated(dynamic data) async {
    if (data is! Map) {
      return;
    }

    if (data.containsKey("action")) {
      String action = data["action"];
      if (action == "enable") {
        _alertEnabled = true;
      } else if (action == "disable") {
        _alertEnabled = false;
      }
    }

    if (widget.rememberAlert == true) {
      await NyStorage.save(stateName!, _alertEnabled);
    }
  }

  @override
  Widget view(BuildContext context) {
    if (_alertEnabled == false) {
      return widget.icon ?? SizedBox.shrink();
    }

    return Badge(
      backgroundColor: widget.alertColor,
      textColor: widget.textColor,
      smallSize: widget.smallSize,
      largeSize: widget.largeSize,
      textStyle: widget.textStyle,
      padding: widget.padding,
      alignment: widget.alignment,
      isLabelVisible: widget.isLabelVisible ?? true,
      child: widget.icon,
    );
  }
}
