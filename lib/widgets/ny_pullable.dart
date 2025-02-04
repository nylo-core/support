import 'package:flutter/material.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

/// The Pullable widget helps you refresh the content.
class Pullable extends StatefulWidget {
  const Pullable(
      {super.key, required this.child, this.onRefresh, this.headerStyle});

  /// Classic Header
  const Pullable.classicHeader({super.key, required this.child, this.onRefresh})
      : headerStyle = "ClassicHeader";

  /// WaterDrop Header
  const Pullable.waterDropHeader(
      {super.key, required this.child, this.onRefresh})
      : headerStyle = "WaterDropHeader";

  /// MaterialClassic Header
  const Pullable.materialClassicHeader(
      {super.key, required this.child, this.onRefresh})
      : headerStyle = "MaterialClassicHeader";

  /// WaterDropMaterial Header
  const Pullable.waterDropMaterialHeader(
      {super.key, required this.child, this.onRefresh})
      : headerStyle = "WaterDropMaterialHeader";

  /// Bezier Header
  const Pullable.bezierHeader({super.key, required this.child, this.onRefresh})
      : headerStyle = "BezierHeader";

  final Widget child;
  final Function()? onRefresh;
  final String? headerStyle;

  @override
  State<Pullable> createState() => _PullableState();
}

class _PullableState extends State<Pullable> {
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: false,
      header: headerType(),
      controller: refreshController,
      onRefresh: () async {
        if (widget.onRefresh == null) {
          refreshController.refreshCompleted(resetFooterState: true);
          setState(() {});
          return;
        }
        if (widget.onRefresh is Future Function()) {
          await widget.onRefresh!();
        } else {
          widget.onRefresh!();
        }
        refreshController.refreshCompleted(resetFooterState: true);
        setState(() {});
      },
      child: widget.child,
    );
  }

  /// Returns the header type
  Widget headerType() {
    switch (widget.headerStyle) {
      case "ClassicHeader":
        {
          return const ClassicHeader();
        }
      case "WaterDropHeader":
        {
          return const WaterDropHeader();
        }
      case "MaterialClassicHeader":
        {
          return const MaterialClassicHeader();
        }
      case "WaterDropMaterialHeader":
        {
          return const WaterDropMaterialHeader();
        }
      case "BezierHeader":
        {
          return BezierHeader();
        }
      default:
        {
          return const WaterDropHeader();
        }
    }
  }
}
