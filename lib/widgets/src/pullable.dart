import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

/// Header types for the Pullable widget
enum PullableHeaderType {
  classic,
  waterDrop,
  materialClassic,
  waterDropMaterial,
  bezier,
}

/// Configuration for the Pullable widget
class PullableConfig {
  const PullableConfig({
    this.enablePullDown = true,
    this.enablePullUp = false,
    this.physics,
    this.onRefresh,
    this.onLoading,
    this.headerType = PullableHeaderType.waterDrop,
    this.customHeader,
    this.customFooter,
    this.refreshCompleteDelay = Duration.zero,
    this.loadCompleteDelay = Duration.zero,
    this.enableOverScroll = true,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
  });

  final bool enablePullDown;
  final bool enablePullUp;
  final ScrollPhysics? physics;
  final Future<void> Function()? onRefresh;
  final Future<void> Function()? onLoading;
  final PullableHeaderType headerType;
  final Widget? customHeader;
  final Widget? customFooter;
  final Duration refreshCompleteDelay;
  final Duration loadCompleteDelay;
  final bool enableOverScroll;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;

  PullableConfig updateOnRefresh(Future<void> Function()? newOnRefresh) {
    return PullableConfig(
      enablePullDown: enablePullDown,
      enablePullUp: enablePullUp,
      physics: physics,
      onRefresh: newOnRefresh ?? onRefresh,
      onLoading: onLoading,
      headerType: headerType,
      customHeader: customHeader,
      customFooter: customFooter,
      refreshCompleteDelay: refreshCompleteDelay,
      loadCompleteDelay: loadCompleteDelay,
      enableOverScroll: enableOverScroll,
      cacheExtent: cacheExtent,
      semanticChildCount: semanticChildCount,
      dragStartBehavior: dragStartBehavior,
    );
  }
}

/// The Pullable widget helps you refresh and load more content with a flexible API.
class Pullable extends StatefulWidget {
  /// Default constructor with full configuration options
  const Pullable({
    super.key,
    required this.child,
    this.config = const PullableConfig(),
    this.controller,
    this.onRefresh,
    this.onLoading,
  });

  /// Classic Header constructor
  Pullable.classicHeader({
    super.key,
    required this.child,
    this.controller,
    this.onRefresh,
    this.onLoading,
  }) : config = const PullableConfig(headerType: PullableHeaderType.classic);

  /// WaterDrop Header constructor
  Pullable.waterDropHeader({
    super.key,
    required this.child,
    this.controller,
    this.onRefresh,
    this.onLoading,
  }) : config = const PullableConfig(headerType: PullableHeaderType.waterDrop);

  /// MaterialClassic Header constructor
  Pullable.materialClassicHeader({
    super.key,
    required this.child,
    this.controller,
    this.onRefresh,
    this.onLoading,
  }) : config = const PullableConfig(
         headerType: PullableHeaderType.materialClassic,
       );

  /// WaterDropMaterial Header constructor
  Pullable.waterDropMaterialHeader({
    super.key,
    required this.child,
    this.controller,
    this.onRefresh,
    this.onLoading,
  }) : config = const PullableConfig(
         headerType: PullableHeaderType.waterDropMaterial,
       );

  /// Bezier Header constructor
  Pullable.bezierHeader({
    super.key,
    required this.child,
    this.controller,
    this.onRefresh,
    this.onLoading,
  }) : config = const PullableConfig(headerType: PullableHeaderType.bezier);

  /// Builder constructor for custom configurations
  const Pullable.builder({
    super.key,
    required this.child,
    required this.config,
    this.controller,
    this.onRefresh,
    this.onLoading,
  });

  /// No bounce constructor for reduced bouncing
  Pullable.noBounce({
    super.key,
    required this.child,
    this.controller,
    this.onRefresh,
    this.onLoading,
    PullableHeaderType headerType = PullableHeaderType.waterDrop,
  }) : config = PullableConfig(
         physics: ClampingScrollPhysics(),
         headerType: headerType,
       );

  /// Custom header constructor
  Pullable.custom({
    super.key,
    required this.child,
    required Widget customHeader,
    this.controller,
    this.onRefresh,
    this.onLoading,
    Widget? customFooter,
    bool enablePullUp = false,
  }) : config = PullableConfig(
         customHeader: customHeader,
         customFooter: customFooter,
         enablePullUp: enablePullUp,
       );

  final Widget child;
  final PullableConfig config;
  final RefreshController? controller;
  final Future<void> Function()? onRefresh;
  final Future<void> Function()? onLoading;

  @override
  State<Pullable> createState() => _PullableState();
}

class _PullableState extends State<Pullable> {
  late RefreshController _refreshController;
  bool _isControllerOwned = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _refreshController = widget.controller!;
      _isControllerOwned = false;
    } else {
      _refreshController = RefreshController(initialRefresh: false);
      _isControllerOwned = true;
    }
  }

  @override
  void dispose() {
    if (_isControllerOwned) {
      _refreshController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveConfig = _getEffectiveConfig();

    return SmartRefresher(
      enablePullDown: effectiveConfig.enablePullDown,
      enablePullUp: effectiveConfig.enablePullUp,
      header: _buildHeader(effectiveConfig),
      footer: _buildFooter(effectiveConfig),
      controller: _refreshController,
      physics: effectiveConfig.physics,
      onRefresh: effectiveConfig.onRefresh != null ? _handleRefresh : null,
      onLoading: effectiveConfig.onLoading != null ? _handleLoading : null,
      dragStartBehavior: effectiveConfig.dragStartBehavior,
      child: widget.child,
    );
  }

  /// Gets the effective configuration
  PullableConfig _getEffectiveConfig() {
    if (widget.onRefresh != null || widget.onLoading != null) {
      return PullableConfig(
        enablePullDown: widget.config.enablePullDown,
        enablePullUp: widget.config.enablePullUp || widget.onLoading != null,
        physics: widget.config.physics,
        onRefresh: widget.onRefresh ?? widget.config.onRefresh,
        onLoading: widget.onLoading ?? widget.config.onLoading,
        headerType: widget.config.headerType,
        customHeader: widget.config.customHeader,
        customFooter: widget.config.customFooter,
        refreshCompleteDelay: widget.config.refreshCompleteDelay,
        loadCompleteDelay: widget.config.loadCompleteDelay,
        enableOverScroll: widget.config.enableOverScroll,
        cacheExtent: widget.config.cacheExtent,
        semanticChildCount: widget.config.semanticChildCount,
        dragStartBehavior: widget.config.dragStartBehavior,
      );
    }
    return widget.config;
  }

  /// Builds the header widget
  Widget _buildHeader(PullableConfig config) {
    if (config.customHeader != null) {
      return config.customHeader!;
    }

    switch (config.headerType) {
      case PullableHeaderType.classic:
        return const ClassicHeader();
      case PullableHeaderType.waterDrop:
        return const WaterDropHeader();
      case PullableHeaderType.materialClassic:
        return const MaterialClassicHeader();
      case PullableHeaderType.waterDropMaterial:
        return const WaterDropMaterialHeader();
      case PullableHeaderType.bezier:
        return BezierHeader();
    }
  }

  /// Builds the footer widget
  Widget? _buildFooter(PullableConfig config) {
    if (config.customFooter != null) {
      return config.customFooter;
    }
    if (config.enablePullUp) {
      return const ClassicFooter();
    }
    return null;
  }

  /// Handles refresh action
  Future<void> _handleRefresh() async {
    try {
      final effectiveConfig = _getEffectiveConfig();
      await effectiveConfig.onRefresh?.call();
      await Future.delayed(effectiveConfig.refreshCompleteDelay);
      if (mounted) {
        _refreshController.refreshCompleted();
      }
    } catch (e) {
      if (mounted) {
        _refreshController.refreshFailed();
      }
    }
  }

  /// Handles loading more action
  Future<void> _handleLoading() async {
    try {
      final effectiveConfig = _getEffectiveConfig();
      await effectiveConfig.onLoading?.call();
      await Future.delayed(effectiveConfig.loadCompleteDelay);
      if (mounted) {
        _refreshController.loadComplete();
      }
    } catch (e) {
      if (mounted) {
        _refreshController.loadFailed();
      }
    }
  }
}

/// Extension to provide convenient methods for RefreshController
extension PullableControllerExtension on RefreshController {
  /// Manually trigger refresh
  void triggerRefresh() {
    requestRefresh();
  }

  /// Manually trigger loading
  void triggerLoading() {
    requestLoading();
  }

  /// Check if currently refreshing
  bool get isRefreshing => headerStatus == RefreshStatus.refreshing;

  /// Check if currently loading
  bool get isLoading => footerStatus == LoadStatus.loading;
}
