import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '/localization/app_localization.dart';
import '/nylo.dart';
import '/widgets/ny_state.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// NyPullToRefresh is a widget that shows a list of items with a pull to refresh.
/// Example:
/// ```dart
/// NyPullToRefresh(
/// data: (int iteration) async => [1,2,3,4,5].paginate(itemsPerPage: 2, page: iteration).toList(),
///   child: (context, data) {
///     return Text(data.toString());
/// })
/// ```
class NyPullToRefresh<T> extends StatefulWidget {
  NyPullToRefresh(
      {Key? key,
      this.onRefresh,
      this.beforeRefresh,
      this.afterRefresh,
      required this.child,
      required this.data,
      this.empty,
      this.loading,
      this.stateName,
      this.transform,
      this.scrollDirection,
      this.reverse,
      this.controller,
      this.primary,
      this.physics,
      this.shrinkWrap,
      this.padding = EdgeInsets.zero,
      this.itemExtent,
      this.prototypeItem,
      this.findChildIndexCallback,
      this.addAutomaticKeepAlives = true,
      this.addRepaintBoundaries = true,
      this.addSemanticIndexes = true,
      this.cacheExtent,
      this.semanticChildCount,
      this.dragStartBehavior,
      this.keyboardDismissBehavior,
      this.restorationId,
      this.headerStyle,
      this.clipBehavior,
      this.useSkeletonizer,
      this.header,
      this.footerLoadingIcon,
      this.sort})
      : kind = "builder",
        crossAxisCount = null,
        mainAxisSpacing = null,
        crossAxisSpacing = null,
        separatorBuilder = null,
        super(key: key);

  NyPullToRefresh.separated(
      {Key? key,
      this.onRefresh,
      this.beforeRefresh,
      this.afterRefresh,
      required this.data,
      this.transform,
      required this.child,
      required this.separatorBuilder,
      this.empty,
      this.loading,
      this.stateName,
      this.scrollDirection,
      this.reverse,
      this.controller,
      this.primary,
      this.physics,
      this.shrinkWrap,
      this.padding = EdgeInsets.zero,
      this.itemExtent,
      this.prototypeItem,
      this.findChildIndexCallback,
      this.addAutomaticKeepAlives = true,
      this.addRepaintBoundaries = true,
      this.addSemanticIndexes = true,
      this.cacheExtent,
      this.semanticChildCount,
      this.dragStartBehavior,
      this.keyboardDismissBehavior,
      this.restorationId,
      this.headerStyle,
      this.clipBehavior,
      this.useSkeletonizer,
      this.header,
      this.footerLoadingIcon,
      this.sort})
      : kind = "separated",
        crossAxisCount = null,
        mainAxisSpacing = null,
        crossAxisSpacing = null,
        super(key: key);

  NyPullToRefresh.grid(
      {Key? key,
      this.crossAxisCount = 2,
      this.mainAxisSpacing = 0,
      this.crossAxisSpacing = 0,
      this.onRefresh,
      this.beforeRefresh,
      this.afterRefresh,
      required this.data,
      this.transform,
      required this.child,
      this.empty,
      this.loading,
      this.stateName,
      this.scrollDirection,
      this.reverse,
      this.controller,
      this.primary,
      this.physics,
      this.shrinkWrap,
      this.padding = EdgeInsets.zero,
      this.itemExtent,
      this.prototypeItem,
      this.findChildIndexCallback,
      this.addAutomaticKeepAlives = true,
      this.addRepaintBoundaries = true,
      this.addSemanticIndexes = true,
      this.cacheExtent,
      this.semanticChildCount,
      this.dragStartBehavior,
      this.keyboardDismissBehavior,
      this.restorationId,
      this.headerStyle,
      this.clipBehavior,
      this.useSkeletonizer,
      this.header,
      this.footerLoadingIcon,
      this.sort})
      : kind = "grid",
        separatorBuilder = null,
        super(key: key);

  final String kind;
  final Widget? header;
  final String? stateName;
  final IndexedWidgetBuilder? separatorBuilder;
  final Function()? onRefresh;
  final Function()? beforeRefresh;
  final Function(dynamic data)? afterRefresh;
  final Future Function(int iteration) data;
  final Widget Function(BuildContext context, dynamic data) child;
  final Widget? empty;
  final List<T> Function(List<T>)? transform;
  final Axis? scrollDirection;
  final bool? reverse;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool? shrinkWrap;
  final EdgeInsets? padding;
  final double? itemExtent;
  final Widget? prototypeItem;
  final ChildIndexGetter? findChildIndexCallback;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior? dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior;
  final String? restorationId;
  final String? headerStyle;
  final Clip? clipBehavior;
  final Widget? loading;
  final Widget? footerLoadingIcon;
  final bool? useSkeletonizer;
  final int? crossAxisCount;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final List<dynamic> Function(dynamic items)? sort;

  @override
  _NyPullToRefreshState<T> createState() => _NyPullToRefreshState<T>(stateName);
}

class _NyPullToRefreshState<T> extends NyState<NyPullToRefresh> {
  _NyPullToRefreshState(String? stateName) {
    this.stateName = stateName;
  }

  int _iteration = 1;
  List<dynamic> _data = [];

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  /// Refresh the list
  _onRefresh() async {
    _iteration = 1;
    _data = [];
    if (widget.beforeRefresh != null) {
      await widget.beforeRefresh!();
    }
    List<T>? newData = await widget.data(_iteration);
    if (newData == null) _refreshController.loadNoData();

    _data = newData!;

    if (widget.afterRefresh != null) {
      _data = widget.afterRefresh!(_data);
    }

    if (widget.onRefresh == null) {
      _refreshController.refreshCompleted(resetFooterState: true);
      setState(() {});
      return;
    }
    await widget.onRefresh!();

    _refreshController.refreshCompleted(resetFooterState: true);

    setState(() {});
  }

  _onLoading() async {
    _iteration++;

    List<T>? newData = await widget.data(_iteration);
    if (newData == null) _refreshController.loadNoData();
    if (newData!.isEmpty) {
      _refreshController.loadNoData();
      return;
    }

    _data.addAll(newData);

    if (mounted) {
      setState(() {});
    }
    _refreshController.loadComplete();
  }

  @override
  boot() async {
    _iteration = 1;
    _refreshController..refreshCompleted(resetFooterState: true);
    dynamic data = await widget.data(_iteration);
    _data = data;
  }

  @override
  Widget build(BuildContext context) {
    Widget loadingWidget = widget.loading ?? Nylo.appLoader();
    if (widget.useSkeletonizer == true) {
      loadingWidget = Skeletonizer(child: loadingWidget);
    }

    return afterLoad(
        child: () {
          if (_data.isEmpty) {
            Widget emptyChild = Container(
              alignment: Alignment.center,
              child: Text("No results found".tr()),
            );
            if (widget.empty != null) {
              emptyChild = widget.empty!;
            }

            return SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              header: headerType(),
              footer: CustomFooter(
                builder: (BuildContext context, LoadStatus? mode) {
                  Widget body;
                  if (mode == LoadStatus.idle) {
                    body = Text("Pull up load".tr());
                  } else if (mode == LoadStatus.loading) {
                    body = widget.footerLoadingIcon ?? loadingWidget;
                  } else if (mode == LoadStatus.failed) {
                    body = Text("Failed to load more results".tr());
                  } else if (mode == LoadStatus.canLoading) {
                    body = Text("Release to load more".tr());
                  } else {
                    body = SizedBox.shrink();
                  }
                  return Container(
                    height: 55.0,
                    child: Center(child: body),
                  );
                },
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: null,
              child: emptyChild,
            );
          }

          // sort the data
          if (widget.sort != null) {
            _data = widget.sort!(_data);
          }

          Widget child = SizedBox.shrink();
          switch (widget.kind) {
            case "builder":
              {
                child = ListView.builder(
                    scrollDirection: widget.scrollDirection ?? Axis.vertical,
                    reverse: widget.reverse ?? false,
                    controller: widget.controller,
                    primary: widget.primary,
                    physics: widget.physics,
                    shrinkWrap: widget.shrinkWrap ?? false,
                    findChildIndexCallback: widget.findChildIndexCallback,
                    addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
                    addRepaintBoundaries: widget.addRepaintBoundaries,
                    addSemanticIndexes: widget.addSemanticIndexes,
                    cacheExtent: widget.cacheExtent,
                    dragStartBehavior:
                        widget.dragStartBehavior ?? DragStartBehavior.start,
                    keyboardDismissBehavior: widget.keyboardDismissBehavior ??
                        ScrollViewKeyboardDismissBehavior.manual,
                    restorationId: widget.restorationId,
                    clipBehavior: widget.clipBehavior ?? Clip.hardEdge,
                    padding: widget.padding,
                    itemCount: _data.length,
                    itemBuilder: (BuildContext context, int index) {
                      dynamic model = (_data[index] as T);
                      return widget.child(context, model);
                    });
                break;
              }
            case "separated":
              {
                child = ListView.separated(
                  scrollDirection: widget.scrollDirection ?? Axis.vertical,
                  reverse: widget.reverse ?? false,
                  controller: widget.controller,
                  primary: widget.primary,
                  physics: widget.physics,
                  shrinkWrap: widget.shrinkWrap ?? false,
                  findChildIndexCallback: widget.findChildIndexCallback,
                  addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
                  addRepaintBoundaries: widget.addRepaintBoundaries,
                  addSemanticIndexes: widget.addSemanticIndexes,
                  cacheExtent: widget.cacheExtent,
                  padding: widget.padding,
                  dragStartBehavior:
                      widget.dragStartBehavior ?? DragStartBehavior.start,
                  keyboardDismissBehavior: widget.keyboardDismissBehavior ??
                      ScrollViewKeyboardDismissBehavior.manual,
                  restorationId: widget.restorationId,
                  clipBehavior: widget.clipBehavior ?? Clip.hardEdge,
                  itemCount: _data.length,
                  itemBuilder: (BuildContext context, int index) {
                    dynamic model = (_data[index] as T);
                    return widget.child(context, model);
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    if (widget.separatorBuilder != null) {
                      return widget.separatorBuilder!(context, index);
                    }
                    return Divider();
                  },
                );
                break;
              }
            case "grid":
              {
                int crossAxisCount = widget.crossAxisCount ?? 1;
                if (widget.header != null) {
                  child = StaggeredGrid.count(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: widget.mainAxisSpacing ?? 0,
                      crossAxisSpacing: widget.crossAxisSpacing ?? 0,
                      children: [
                        StaggeredGridTile.fit(
                            crossAxisCellCount: crossAxisCount,
                            child: widget.header!),
                        ..._data
                            .map((item) => StaggeredGridTile.fit(
                                  crossAxisCellCount: 1,
                                  child: widget.child(context, item),
                                ))
                            .toList(),
                      ]);
                } else {
                  child = StaggeredGrid.count(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: widget.mainAxisSpacing ?? 0,
                    crossAxisSpacing: widget.crossAxisSpacing ?? 0,
                    children: _data
                        .map((item) => StaggeredGridTile.fit(
                              crossAxisCellCount: 1,
                              child: widget.child(context, item),
                            ))
                        .toList(),
                  );
                }
                break;
              }
          }
          return SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            header: headerType(),
            footer: CustomFooter(
              builder: (BuildContext context, LoadStatus? mode) {
                Widget body;
                if (mode == LoadStatus.idle) {
                  body = Text("Pull up load".tr());
                } else if (mode == LoadStatus.loading) {
                  body = widget.footerLoadingIcon ?? loadingWidget;
                } else if (mode == LoadStatus.failed) {
                  body = Text("Failed to load more results".tr());
                } else if (mode == LoadStatus.canLoading) {
                  body = Text("Release to load more".tr());
                } else {
                  body = SizedBox.shrink();
                }
                return Container(
                  height: 55.0,
                  child: Center(child: body),
                );
              },
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: child,
          );
        },
        loading: loadingWidget);
  }

  /// Returns the header type
  Widget headerType() {
    switch (widget.headerStyle) {
      case "ClassicHeader":
        {
          return ClassicHeader();
        }
      case "WaterDropHeader":
        {
          return WaterDropHeader();
        }
      case "MaterialClassicHeader":
        {
          return MaterialClassicHeader();
        }
      case "WaterDropMaterialHeader":
        {
          return WaterDropMaterialHeader();
        }
      case "BezierHeader":
        {
          return BezierHeader();
        }
      default:
        {
          return WaterDropHeader();
        }
    }
  }
}
