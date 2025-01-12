import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '/helpers/loading_style.dart';
import '/helpers/helper.dart';
import '/widgets/ny_state.dart';
import '/localization/app_localization.dart';
import '/nylo.dart';

/// The NyListView widget is a wrapper for the ListView widget.
/// It provides a simple way to display a list of items.
/// Example:
/// ```dart
/// NyListView(
///  data: () async => [1,2,3,4,5],
///  child: (context, data) {
///   return Text(data.toString());
///  })
///  ```
///  The above example will display a list of numbers.
///  The [data] is fetched from the data function.
///  The [child] is the widget that will be displayed for each item in the list.
class NyListView<T> extends StatefulWidget {
  final Function() data;
  final dynamic Function(List<T> data)? transform;
  final Widget Function(BuildContext context, dynamic data) child;
  final Widget? header;
  final Widget? empty;
  final LoadingStyle? loadingStyle;
  final String kind;
  final IndexedWidgetBuilder? separatorBuilder;
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
  final Clip? clipBehavior;
  final String? stateName;
  final int? crossAxisCount;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final dynamic Function(List<T> items)? sort;

  @override
  // ignore: no_logic_in_create_state
  createState() => _NyListViewState<T>(stateName);

  const NyListView(
      {super.key,
      required this.child,
      required this.data,
      this.transform,
      this.empty,
      this.loadingStyle,
      this.stateName,
      this.scrollDirection,
      this.reverse,
      this.controller,
      this.primary,
      this.physics,
      this.shrinkWrap,
      this.padding,
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
      this.clipBehavior,
      this.header,
      this.sort})
      : kind = "builder",
        separatorBuilder = null,
        crossAxisCount = null,
        mainAxisSpacing = null,
        crossAxisSpacing = null;

  const NyListView.separated(
      {super.key,
      required this.data,
      this.transform,
      required this.child,
      required this.separatorBuilder,
      this.empty,
      this.loadingStyle,
      this.stateName,
      this.scrollDirection,
      this.reverse,
      this.controller,
      this.primary,
      this.physics,
      this.shrinkWrap,
      this.padding,
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
      this.clipBehavior,
      this.header,
      this.sort})
      : kind = "separated",
        crossAxisCount = null,
        mainAxisSpacing = null,
        crossAxisSpacing = null;

  const NyListView.grid({
    super.key,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 1.0,
    this.crossAxisSpacing = 1.0,
    required this.child,
    required this.data,
    this.transform,
    this.empty,
    this.loadingStyle,
    this.stateName,
    this.scrollDirection,
    this.reverse,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap,
    this.padding,
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
    this.clipBehavior,
    this.header,
    this.sort,
  })  : kind = "grid",
        separatorBuilder = null;

  /// Resets the state
  static stateReset(String stateName) {
    updateState(stateName, data: {"action": "reset", "data": {}});
  }
}

class _NyListViewState<T> extends NyState<NyListView> {
  _NyListViewState(String? stateName) {
    this.stateName = stateName;
  }

  List<T> _data = [];

  @override
  get init => () {
        if (widget.data is! Future Function()) {
          dynamic data = widget.data();
          if (data == null) {
            _data = [];
            return;
          }
          assert(data is List<T>, "Data must be a List");
          _data = data;
          return;
        }
        awaitData(perform: () async {
          dynamic data = await widget.data();
          if (data == null) {
            _data = [];
            return;
          }
          assert(data is List<T>, "Data must be a List");
          _data = data;
        });
      };

  @override
  stateUpdated(dynamic data) {
    super.stateUpdated(data);

    if (data is! Map) return;
    if (!data.containsKey('action') || data['action'] == null) return;

    if (data["action"] == "reset") {
      _data = [];
      init();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget loadingWidget = Nylo.appLoader();
    if (widget.loadingStyle != null) {
      loadingWidget = widget.loadingStyle!.render();
    }

    if (widget.data is! Future Function()) {
      _data = widget.data();
      if (_data.isEmpty) {
        if (widget.empty != null) {
          return widget.empty!;
        }
        return Container(
          alignment: Alignment.center,
          child: Text("No results found".tr()),
        );
      }

      if (widget.transform != null) {
        _data = widget.transform!(_data);
      }

      // sort the data
      if (widget.sort != null) {
        _data = widget.sort!(_data);
      }

      return buildWidgetForKind();
    }

    return afterLoad(
        child: () {
          if (_data.isEmpty) {
            if (widget.empty != null) {
              return widget.empty;
            }
            return Container(
              alignment: Alignment.center,
              child: Text("No results found".tr()),
            );
          }

          if (widget.transform != null) {
            _data = widget.transform!(_data);
          }

          // sort the data
          if (widget.sort != null) {
            _data = widget.sort!(_data);
          }

          return buildWidgetForKind();
        },
        loading: loadingWidget);
  }

  /// Builds the widget based on the kind of list view
  Widget buildWidgetForKind() {
    switch (widget.kind) {
      case "builder":
        {
          return ListView.builder(
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
              padding: widget.padding ?? EdgeInsets.zero,
              itemCount: _data.length + (widget.header != null ? 1 : 0),
              itemBuilder: (BuildContext context, int index) {
                if (index == 0 && widget.header != null) {
                  return widget.header!;
                }
                index = widget.header != null ? index - 1 : index;
                dynamic model = (_data[index]);
                return widget.child(context, model);
              });
        }
      case "separated":
        {
          return ListView.separated(
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
            padding: EdgeInsets.zero,
            itemCount: _data.length + (widget.header != null ? 1 : 0),
            itemBuilder: (BuildContext context, int index) {
              if (index == 0 && widget.header != null) {
                return widget.header!;
              }
              index = widget.header != null ? index - 1 : index;
              dynamic model = (_data[index]);
              return widget.child(context, model);
            },
            separatorBuilder: (context, index) {
              if (widget.separatorBuilder != null) {
                return widget.separatorBuilder!(context, index);
              }
              return const Divider();
            },
          );
        }
      case "grid":
        {
          int crossAxisCount = widget.crossAxisCount ?? 1;
          if (widget.header != null) {
            return ListView(
              scrollDirection: widget.scrollDirection ?? Axis.vertical,
              reverse: widget.reverse ?? false,
              controller: widget.controller,
              primary: widget.primary,
              physics: widget.physics,
              shrinkWrap: widget.shrinkWrap ?? false,
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
              children: [
                StaggeredGrid.count(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: widget.mainAxisSpacing ?? 0,
                    crossAxisSpacing: widget.crossAxisSpacing ?? 0,
                    children: [
                      StaggeredGridTile.fit(
                          crossAxisCellCount: crossAxisCount,
                          child: widget.header!),
                      ..._data.map((item) => StaggeredGridTile.fit(
                            crossAxisCellCount: 1,
                            child: widget.child(context, item),
                          )),
                    ]),
              ],
            );
          } else {
            return ListView(
              scrollDirection: widget.scrollDirection ?? Axis.vertical,
              reverse: widget.reverse ?? false,
              controller: widget.controller,
              primary: widget.primary,
              physics: widget.physics,
              shrinkWrap: widget.shrinkWrap ?? false,
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
              children: [
                StaggeredGrid.count(
                  crossAxisCount: widget.crossAxisCount ?? 1,
                  mainAxisSpacing: widget.mainAxisSpacing ?? 0,
                  crossAxisSpacing: widget.crossAxisSpacing ?? 0,
                  children: _data
                      .map((item) => StaggeredGridTile.fit(
                            crossAxisCellCount: 1,
                            child: widget.child(context, item),
                          ))
                      .toList(),
                ),
              ],
            );
          }
        }
      default:
        {
          return const SizedBox.shrink();
        }
    }
  }
}
