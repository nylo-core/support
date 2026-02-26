import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import '/helpers/ny_helpers.dart';
import '/widgets/ny_widgets.dart';
import '/localization/ny_localization.dart';
import '/nylo.dart';

/// Wrapper class containing item data and position helpers.
///
/// Example usage:
/// ```dart
/// CollectionView<String>(
///   data: () => ['Item 1', 'Item 2', 'Item 3'],
///   builder: (context, item) {
///     return Container(
///       color: item.isEven ? Colors.grey : Colors.white,
///       child: Text('${item.data} at index ${item.index}'),
///     );
///   },
/// )
/// ```
class CollectionItem<T> {
  final T data;
  final int index;
  final int totalItems;

  const CollectionItem({
    required this.data,
    required this.index,
    required this.totalItems,
  });

  /// Whether this is the first item in the list.
  bool get isFirst => index == 0;

  /// Whether this is the last item in the list.
  bool get isLast => index == totalItems - 1;

  /// Whether this item is at an odd index.
  bool get isOdd => index % 2 == 1;

  /// Whether this item is at an even index.
  bool get isEven => index % 2 == 0;

  /// Whether this item is at the specified [position].
  bool isAt(int position) => index == position;

  /// Whether this item's index is within the specified range (inclusive).
  bool isInRange(int start, int end) => index >= start && index <= end;

  /// Whether this item's index is a multiple of [divisor].
  bool isMultipleOf(int divisor) => index % divisor == 0;

  /// Progress through the list (0.0 to 1.0).
  double get progress => totalItems > 1 ? index / (totalItems - 1) : 0.0;
}

/// Type-safe builder function signature.
typedef CollectionItemBuilder<T> =
    Widget Function(BuildContext context, CollectionItem<T> item);

/// The kind of collection view to build.
enum CollectionViewKind { builder, separated, grid }

/// The CollectionView widget is a wrapper for the ListView widget.
/// It provides a simple way to display a list of items with full type safety.
///
/// Example:
/// ```dart
/// CollectionView<String>(
///   data: () => ['Item 1', 'Item 2', 'Item 3'],
///   builder: (context, item) {
///     return Container(
///       color: item.isEven ? Colors.grey : Colors.white,
///       child: Text('${item.data} at ${item.index}'),
///     );
///   },
/// )
/// ```
///
/// With async data:
/// ```dart
/// CollectionView<User>(
///   data: () async => await api.fetchUsers(),
///   builder: (context, item) => UserTile(user: item.data),
///   empty: Text('No users found'),
/// )
/// ```
///
/// With pull-to-refresh and pagination:
/// ```dart
/// CollectionView<User>.pullable(
///   data: (iteration) async => api.getUsers(page: iteration),
///   builder: (context, item) => UserTile(user: item.data),
///   onRefresh: () => print('Refreshed!'),
/// )
/// ```
class CollectionView<T> extends StatefulWidget {
  // Data callback - either simple () => List<T> or paginated (int) => List<T>
  final Function()? data;
  final Function(int iteration)? paginatedData;

  final dynamic Function(List<T> data)? transform;
  final CollectionItemBuilder<T> builder;
  final Widget? header;
  final Widget? empty;
  final LoadingStyle? loadingStyle;
  final CollectionViewKind kind;
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
  final double? spacing;
  final int? crossAxisCount;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final dynamic Function(List<T> items)? sort;

  // Pullable-specific fields
  final bool isPullable;
  final Function()? onRefresh;
  final Function()? beforeRefresh;
  final Function(dynamic data)? afterRefresh;
  final String? headerStyle;
  final Widget? footerLoadingIcon;

  @override
  State<CollectionView<T>> createState() => _CollectionViewState<T>();

  const CollectionView({
    super.key,
    required this.builder,
    required Function() data,
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
    this.spacing,
  }) : kind = CollectionViewKind.builder,
       separatorBuilder = null,
       crossAxisCount = null,
       mainAxisSpacing = null,
       crossAxisSpacing = null,
       isPullable = false,
       paginatedData = null,
       onRefresh = null,
       beforeRefresh = null,
       afterRefresh = null,
       headerStyle = null,
       footerLoadingIcon = null,
       this.data = data;

  const CollectionView.separated({
    super.key,
    required Function() data,
    required this.builder,
    required this.separatorBuilder,
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
    this.spacing,
  }) : kind = CollectionViewKind.separated,
       crossAxisCount = null,
       mainAxisSpacing = null,
       crossAxisSpacing = null,
       isPullable = false,
       paginatedData = null,
       onRefresh = null,
       beforeRefresh = null,
       afterRefresh = null,
       headerStyle = null,
       footerLoadingIcon = null,
       this.data = data;

  const CollectionView.grid({
    super.key,
    required Function() data,
    required this.builder,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 1.0,
    this.crossAxisSpacing = 1.0,
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
    this.spacing,
  }) : kind = CollectionViewKind.grid,
       separatorBuilder = null,
       isPullable = false,
       paginatedData = null,
       onRefresh = null,
       beforeRefresh = null,
       afterRefresh = null,
       headerStyle = null,
       footerLoadingIcon = null,
       this.data = data;

  /// Creates a pullable list view with pull-to-refresh and pagination support.
  ///
  /// Example:
  /// ```dart
  /// CollectionView<User>.pullable(
  ///   data: (iteration) async => api.getUsers(page: iteration),
  ///   builder: (context, item) => UserTile(user: item.data),
  ///   onRefresh: () => print('Refreshed!'),
  ///   headerStyle: 'WaterDropHeader',
  /// )
  /// ```
  const CollectionView.pullable({
    super.key,
    required this.builder,
    required Function(int iteration) data,
    this.onRefresh,
    this.beforeRefresh,
    this.afterRefresh,
    this.headerStyle,
    this.footerLoadingIcon,
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
    this.spacing,
  }) : kind = CollectionViewKind.builder,
       separatorBuilder = null,
       crossAxisCount = null,
       mainAxisSpacing = null,
       crossAxisSpacing = null,
       isPullable = true,
       paginatedData = data,
       this.data = null;

  /// Creates a pullable separated list view with pull-to-refresh and pagination support.
  ///
  /// Example:
  /// ```dart
  /// CollectionView<User>.pullableSeparated(
  ///   data: (iteration) async => api.getUsers(page: iteration),
  ///   builder: (context, item) => UserTile(user: item.data),
  ///   separatorBuilder: (context, index) => Divider(),
  /// )
  /// ```
  const CollectionView.pullableSeparated({
    super.key,
    required this.builder,
    required Function(int iteration) data,
    required this.separatorBuilder,
    this.onRefresh,
    this.beforeRefresh,
    this.afterRefresh,
    this.headerStyle,
    this.footerLoadingIcon,
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
    this.spacing,
  }) : kind = CollectionViewKind.separated,
       crossAxisCount = null,
       mainAxisSpacing = null,
       crossAxisSpacing = null,
       isPullable = true,
       paginatedData = data,
       this.data = null;

  /// Creates a pullable grid view with pull-to-refresh and pagination support.
  ///
  /// Example:
  /// ```dart
  /// CollectionView<Product>.pullableGrid(
  ///   data: (iteration) async => api.getProducts(page: iteration),
  ///   builder: (context, item) => ProductCard(product: item.data),
  ///   crossAxisCount: 2,
  /// )
  /// ```
  const CollectionView.pullableGrid({
    super.key,
    required this.builder,
    required Function(int iteration) data,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.onRefresh,
    this.beforeRefresh,
    this.afterRefresh,
    this.headerStyle,
    this.footerLoadingIcon,
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
    this.spacing,
  }) : kind = CollectionViewKind.grid,
       separatorBuilder = null,
       isPullable = true,
       paginatedData = data,
       this.data = null;

  /// Resets the state.
  static void stateReset(String stateName) {
    updateState(stateName, data: {"action": "reset", "data": {}});
  }

  /// Removes an item from the list at the given index.
  static void removeFromIndex(String stateName, int index) {
    updateState(
      stateName,
      data: {
        "action": "removeFromIndex",
        "data": {"index": index},
      },
    );
  }
}

class _CollectionViewState<T> extends NyState<CollectionView<T>> {
  List<T> _data = [];
  int _iteration = 1;
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    stateName = widget.stateName;
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  get init => () {
    _iteration = 1;

    if (widget.isPullable) {
      // Pullable mode - use paginatedData
      _refreshController.refreshCompleted(resetFooterState: true);
      if (widget.paginatedData is! Future Function(int)) {
        final data = widget.paginatedData!(_iteration);
        if (data == null) {
          _data = [];
          return;
        }
        assert(data is List<T>, "Data must be a List<$T>");
        _data = data;
      } else {
        awaitData(
          perform: () async {
            final data = await widget.paginatedData!(_iteration);
            if (data == null) {
              _data = [];
              return;
            }
            assert(data is List<T>, "Data must be a List<$T>");
            _data = data;
          },
        );
      }
    } else {
      // Regular mode - use data
      if (widget.data is! Future Function()) {
        final data = widget.data!();
        if (data == null) {
          _data = [];
          return;
        }
        assert(data is List<T>, "Data must be a List<$T>");
        _data = data;
        return;
      }
      awaitData(
        perform: () async {
          final data = await widget.data!();
          if (data == null) {
            _data = [];
            return;
          }
          assert(data is List<T>, "Data must be a List<$T>");
          _data = data;
        },
      );
    }
  };

  @override
  stateUpdated(dynamic data) async {
    super.stateUpdated(data);

    if (data is! Map) return;
    if (!data.containsKey('action') || data['action'] == null) return;

    if (data["action"] == "reset") {
      setLoading(true);
      _data = [];
      reboot();
      return;
    }
  }

  @override
  Map<String, Function> get stateActions => {
    'removeFromIndex': (data) {
      if (data is! Map || !data.containsKey('index')) return;
      int index = data['index'];
      if (index < 0 || index >= _data.length) return;
      _data.removeAt(index);
      setState(() {});
    },
  };

  /// Refresh the list (for pullable mode)
  Future<void> _onRefresh() async {
    _iteration = 1;
    _data = [];

    if (widget.beforeRefresh != null) {
      await widget.beforeRefresh!();
    }

    List<T>? newData = [];
    if (widget.paginatedData is! Future Function(int)) {
      newData = widget.paginatedData!(_iteration);
    } else {
      newData = await widget.paginatedData!(_iteration);
    }
    if (newData == null) {
      _refreshController.loadNoData();
      return;
    }

    _data = newData;

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

  /// Load more data (for pullable mode)
  Future<void> _onLoading() async {
    _iteration++;

    List<T>? newData = [];
    if (widget.paginatedData is! Future Function(int)) {
      newData = widget.paginatedData!(_iteration);
    } else {
      newData = await widget.paginatedData!(_iteration);
    }
    if (newData == null) {
      _refreshController.loadNoData();
      return;
    }
    if (newData.isEmpty) {
      _refreshController.loadNoData();
      return;
    }

    _data.addAll(newData);

    if (mounted) {
      setState(() {});
    }
    _refreshController.loadComplete();
  }

  Widget _buildChildWidget(BuildContext context, T model, int index) {
    final item = CollectionItem<T>(
      data: model,
      index: index,
      totalItems: _data.length,
    );
    Widget child = widget.builder(context, item);

    // Apply spacing between items (not after the last item)
    if (widget.spacing != null && widget.spacing! > 0 && !item.isLast) {
      final isVertical =
          (widget.scrollDirection ?? Axis.vertical) == Axis.vertical;
      child = Padding(
        padding: EdgeInsets.only(
          bottom: isVertical ? widget.spacing! : 0,
          right: isVertical ? 0 : widget.spacing!,
        ),
        child: child,
      );
    }

    return child;
  }

  Widget _buildEmptyWidget() {
    if (widget.empty != null) {
      return widget.empty!;
    }
    return Container(
      alignment: Alignment.center,
      child: Text("nylo.collection_view.no_results".tr()),
    );
  }

  List<T> _applyTransformAndSort(List<T> data) {
    var result = data;
    if (widget.transform != null) {
      result = widget.transform!(result);
    }
    if (widget.sort != null) {
      result = widget.sort!(result);
    }
    return result;
  }

  /// Returns the header widget based on headerStyle
  Widget _headerType() {
    return switch (widget.headerStyle) {
      'ClassicHeader' => const ClassicHeader(),
      'MaterialClassicHeader' => const MaterialClassicHeader(),
      'WaterDropMaterialHeader' => const WaterDropMaterialHeader(),
      'BezierHeader' => BezierHeader(),
      _ => const WaterDropHeader(),
    };
  }

  /// Build footer for pullable list
  Widget _buildFooter(Widget loadingWidget) {
    return CustomFooter(
      builder: (BuildContext context, LoadStatus? mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          body = Text("nylo.collection_view.pull_up".tr());
        } else if (mode == LoadStatus.loading) {
          body = widget.footerLoadingIcon ?? loadingWidget;
        } else if (mode == LoadStatus.failed) {
          body = Text("nylo.collection_view.failed".tr());
        } else if (mode == LoadStatus.canLoading) {
          body = Text("nylo.collection_view.release".tr());
        } else {
          body = const SizedBox.shrink();
        }
        return SizedBox(height: 55.0, child: Center(child: body));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loadingWidget = widget.loadingStyle?.render() ?? Nylo.appLoader();

    if (widget.isPullable) {
      return _buildPullableView(loadingWidget);
    }

    return _buildRegularView(loadingWidget);
  }

  /// Build regular (non-pullable) view
  Widget _buildRegularView(Widget loadingWidget) {
    if (widget.data is! Future Function()) {
      _data = widget.data!() ?? [];
      if (_data.isEmpty) {
        return _buildEmptyWidget();
      }
      _data = _applyTransformAndSort(_data);
      return _buildListView();
    }

    return afterLoad(
      child: () {
        if (_data.isEmpty) {
          return _buildEmptyWidget();
        }
        _data = _applyTransformAndSort(_data);
        return _buildListView();
      },
      loading: loadingWidget,
    );
  }

  /// Build pullable view with SmartRefresher
  Widget _buildPullableView(Widget loadingWidget) {
    if (widget.paginatedData is! Future Function(int)) {
      return _displayPullableChild(loadingWidget);
    }

    return afterLoad(
      child: () => _displayPullableChild(loadingWidget),
      loading: loadingWidget,
    );
  }

  /// Display the pullable child wrapped in SmartRefresher
  Widget _displayPullableChild(Widget loadingWidget) {
    // Apply sort if provided
    if (widget.sort != null && _data.isNotEmpty) {
      _data = widget.sort!(_data);
    }

    if (_data.isEmpty) {
      Widget emptyChild = _buildEmptyWidget();

      if (widget.header != null) {
        emptyChild = Column(children: [widget.header!, emptyChild]);
      }

      return SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: _headerType(),
        footer: _buildFooter(loadingWidget),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: null,
        child: emptyChild,
      );
    }

    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: _headerType(),
      footer: _buildFooter(loadingWidget),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: _buildListView(),
    );
  }

  Widget _buildListView() {
    return switch (widget.kind) {
      CollectionViewKind.builder => _buildListViewBuilder(),
      CollectionViewKind.separated => _buildListViewSeparated(),
      CollectionViewKind.grid => _buildGridView(),
    };
  }

  Widget _buildListViewBuilder() {
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
      dragStartBehavior: widget.dragStartBehavior ?? DragStartBehavior.start,
      keyboardDismissBehavior:
          widget.keyboardDismissBehavior ??
          ScrollViewKeyboardDismissBehavior.manual,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior ?? Clip.hardEdge,
      padding: widget.padding ?? EdgeInsets.zero,
      itemCount: _data.length + (widget.header != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == 0 && widget.header != null) {
          return widget.header!;
        }
        final actualIndex = widget.header != null ? index - 1 : index;
        return _buildChildWidget(context, _data[actualIndex], actualIndex);
      },
    );
  }

  Widget _buildListViewSeparated() {
    return ListView.separated(
      scrollDirection: widget.scrollDirection ?? Axis.vertical,
      reverse: widget.reverse ?? false,
      controller: widget.controller,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap ?? false,
      findItemIndexCallback: widget.findChildIndexCallback,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addSemanticIndexes: widget.addSemanticIndexes,
      cacheExtent: widget.cacheExtent,
      dragStartBehavior: widget.dragStartBehavior ?? DragStartBehavior.start,
      keyboardDismissBehavior:
          widget.keyboardDismissBehavior ??
          ScrollViewKeyboardDismissBehavior.manual,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior ?? Clip.hardEdge,
      padding: widget.padding ?? EdgeInsets.zero,
      itemCount: _data.length + (widget.header != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == 0 && widget.header != null) {
          return widget.header!;
        }
        final actualIndex = widget.header != null ? index - 1 : index;
        return _buildChildWidget(context, _data[actualIndex], actualIndex);
      },
      separatorBuilder: (context, index) {
        if (widget.header != null && index == 0) {
          return const SizedBox.shrink();
        }
        if (widget.separatorBuilder != null) {
          return widget.separatorBuilder!(context, index);
        }
        return const Divider();
      },
    );
  }

  Widget _buildGridView() {
    final crossAxisCount = widget.crossAxisCount ?? 2;

    final gridChildren = _data.asMap().entries.map((entry) {
      return StaggeredGridTile.fit(
        crossAxisCellCount: 1,
        child: _buildChildWidget(context, entry.value, entry.key),
      );
    }).toList();

    final grid = StaggeredGrid.count(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: widget.mainAxisSpacing ?? 0,
      crossAxisSpacing: widget.crossAxisSpacing ?? 0,
      children: [
        if (widget.header != null)
          StaggeredGridTile.fit(
            crossAxisCellCount: crossAxisCount,
            child: widget.header!,
          ),
        ...gridChildren,
      ],
    );

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
      dragStartBehavior: widget.dragStartBehavior ?? DragStartBehavior.start,
      keyboardDismissBehavior:
          widget.keyboardDismissBehavior ??
          ScrollViewKeyboardDismissBehavior.manual,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior ?? Clip.hardEdge,
      padding: widget.padding,
      children: [grid],
    );
  }
}
