import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '/helpers/loading_style.dart';
import '/helpers/helper.dart';
import '/widgets/ny_state.dart';
import '/localization/app_localization.dart';
import '/nylo.dart';

// Helper class for item position checks
class NyListViewItemHelper {
  final int index;
  final int totalItems;

  const NyListViewItemHelper({
    required this.index,
    required this.totalItems,
  });

  bool isFirst() => index == 0;
  bool isLast() => index == totalItems - 1;
  bool isOdd() => index % 2 == 1;
  bool isEven() => index % 2 == 0;
  bool isAt(int position) => index == position;
  bool isInRange(int start, int end) => index >= start && index <= end;
  bool isMultipleOf(int divisor) => index % divisor == 0;
  double get progress => totalItems > 1 ? index / (totalItems - 1) : 0.0;
}

// Type-safe function signatures
typedef NyChildBuilder<T> = Widget Function(BuildContext context, T data);
typedef NyChildBuilderWithIndex<T> = Widget Function(
    BuildContext context, T data, int index);
typedef NyChildBuilderWithHelper<T> = Widget Function(
    BuildContext context, T data, int index, NyListViewItemHelper helper);

/// The NyListView widget is a wrapper for the ListView widget.
/// It provides a simple way to display a list of items with full type safety.
///
/// **Basic Example (backwards compatible):**
/// ```dart
/// NyListView<String>(
///  data: () => ['Item 1', 'Item 2', 'Item 3'],
///  child: (context, data) => Text(data), // data is dynamic (backwards compatible)
/// )
/// ```
///
/// **Type-safe Examples:**
/// ```dart
/// NyListView<String>(
///  data: () => ['Item 1', 'Item 2', 'Item 3'],
///  childTyped: (context, String data) => Text(data), // data is String (type-safe)
/// )
///
/// NyListView<String>(
///  data: () => ['Item 1', 'Item 2', 'Item 3'],
///  childTypedWithIndex: (context, String data, int index) => Text('$data at $index'),
/// )
///
/// NyListView<String>(
///  data: () => ['Item 1', 'Item 2', 'Item 3'],
///  childTypedWithHelper: (context, String data, int index, NyListViewItemHelper helper) {
///    return Container(
///      color: helper.isEven() ? Colors.grey : Colors.white,
///      child: Text(data),
///    );
///  },
/// )
/// ```
class NyListView<T> extends StatefulWidget {
  final Function() data;
  final dynamic Function(List<T> data)? transform;

  // Backwards compatible (dynamic type)
  final Function? child;

  // Type-safe options
  final NyChildBuilder<T>? childTyped;
  final NyChildBuilderWithIndex<T>? childTypedWithIndex;
  final NyChildBuilderWithHelper<T>? childTypedWithHelper;

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

  // Basic constructor - backwards compatible
  const NyListView({
    super.key,
    this.child,
    this.childTyped,
    this.childTypedWithIndex,
    this.childTypedWithHelper,
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
  })  : assert(
            (child != null ? 1 : 0) +
                    (childTyped != null ? 1 : 0) +
                    (childTypedWithIndex != null ? 1 : 0) +
                    (childTypedWithHelper != null ? 1 : 0) ==
                1,
            'Exactly one child builder must be provided'),
        kind = "builder",
        separatorBuilder = null,
        crossAxisCount = null,
        mainAxisSpacing = null,
        crossAxisSpacing = null;

  // Separated constructor
  const NyListView.separated({
    super.key,
    required this.data,
    this.transform,
    this.child,
    this.childTyped,
    this.childTypedWithIndex,
    this.childTypedWithHelper,
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
    this.sort,
  })  : assert(
            (child != null ? 1 : 0) +
                    (childTyped != null ? 1 : 0) +
                    (childTypedWithIndex != null ? 1 : 0) +
                    (childTypedWithHelper != null ? 1 : 0) ==
                1,
            'Exactly one child builder must be provided'),
        kind = "separated",
        crossAxisCount = null,
        mainAxisSpacing = null,
        crossAxisSpacing = null;

  // Grid constructor
  const NyListView.grid({
    super.key,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 1.0,
    this.crossAxisSpacing = 1.0,
    this.child,
    this.childTyped,
    this.childTypedWithIndex,
    this.childTypedWithHelper,
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
  })  : assert(
            (child != null ? 1 : 0) +
                    (childTyped != null ? 1 : 0) +
                    (childTypedWithIndex != null ? 1 : 0) +
                    (childTypedWithHelper != null ? 1 : 0) ==
                1,
            'Exactly one child builder must be provided'),
        kind = "grid",
        separatorBuilder = null;

  /// Resets the state
  static void stateReset(String stateName) {
    updateState(stateName, data: {"action": "reset", "data": {}});
  }
}

class _NyListViewState<T> extends NyState<NyListView<T>> {
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
          assert(data is List<T>, "Data must be a List<$T>");
          _data = data;
          return;
        }
        awaitData(perform: () async {
          dynamic data = await widget.data();
          if (data == null) {
            _data = [];
            return;
          }
          assert(data is List<T>, "Data must be a List<$T>");
          _data = data;
        });
      };

  @override
  stateUpdated(dynamic data) async {
    super.stateUpdated(data);

    if (data is! Map) return;
    if (!data.containsKey('action') || data['action'] == null) return;

    if (data["action"] == "reset") {
      _data = [];
      init();
      return;
    }
  }

  /// Builds the child widget with the appropriate builder (backwards compatible + type safe)
  Widget _buildChildWidget(BuildContext context, T model, int index) {
    final helper = NyListViewItemHelper(
      index: index,
      totalItems: _data.length,
    );

    // Type-safe options (preferred)
    if (widget.childTypedWithHelper != null) {
      return widget.childTypedWithHelper!(context, model, index, helper);
    } else if (widget.childTypedWithIndex != null) {
      return widget.childTypedWithIndex!(context, model, index);
    } else if (widget.childTyped != null) {
      return widget.childTyped!(context, model);
    }

    // Backwards compatible option (dynamic types)
    if (widget.child != null) {
      try {
        // Try to call with all 4 parameters first (new signature)
        return Function.apply(widget.child!, [context, model, index, helper]);
      } catch (e) {
        try {
          // Try with 3 parameters (context, data, index)
          return Function.apply(widget.child!, [context, model, index]);
        } catch (e) {
          try {
            // Fall back to original 2 parameters (context, data)
            return Function.apply(widget.child!, [context, model]);
          } catch (e) {
            // If all else fails, show an error widget
            return Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.red[100],
              child: Text(
                'Error: Child function signature not supported.\n'
                'Supported signatures:\n'
                '- (BuildContext context, T data)\n'
                '- (BuildContext context, T data, int index)\n'
                '- (BuildContext context, T data, int index, NyListViewItemHelper helper)\n'
                'Or use the type-safe alternatives: childTyped, childTypedWithIndex, childTypedWithHelper',
                style: TextStyle(color: Colors.red[900], fontSize: 12),
              ),
            );
          }
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.red[100],
      child: Text(
        'Error: No child builder provided',
        style: TextStyle(color: Colors.red[900]),
      ),
    );
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
                int actualIndex = widget.header != null ? index - 1 : index;
                T model = _data[actualIndex];
                return _buildChildWidget(context, model, actualIndex);
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
              int actualIndex = widget.header != null ? index - 1 : index;
              T model = _data[actualIndex];
              return _buildChildWidget(context, model, actualIndex);
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
                      ..._data
                          .asMap()
                          .entries
                          .map((entry) => StaggeredGridTile.fit(
                                crossAxisCellCount: 1,
                                child: _buildChildWidget(
                                    context, entry.value, entry.key),
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
                      .asMap()
                      .entries
                      .map((entry) => StaggeredGridTile.fit(
                            crossAxisCellCount: 1,
                            child: _buildChildWidget(
                                context, entry.value, entry.key),
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
