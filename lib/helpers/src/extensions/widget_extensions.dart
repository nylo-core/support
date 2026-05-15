import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '/widgets/ny_widgets.dart';
import '/router/ny_router.dart';
import '/helpers/src/loading_style.dart';
import '../helper.dart' show getImageAsset;
import 'context_extensions.dart' show RouteViewExt;

/// Extensions for [AssetImage]
extension NyAssetImageExt on AssetImage {
  /// Get an image from the local assets folder.
  AssetImage localAsset({String? path = '/images'}) {
    return AssetImage(getImageAsset(assetName, path: path), package: package);
  }
}

/// Extensions for [Column]
extension NyColumnExt on Column {
  /// Add padding to the column.
  Padding paddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: top,
        left: left,
        right: right,
        bottom: bottom,
      ),
      child: this,
    );
  }

  /// Add symmetric padding to the column.
  Padding paddingSymmetric({double horizontal = 0.0, double vertical = 0.0}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
      child: this,
    );
  }

  /// Adds a gap between each child.
  Column withGap(double space) {
    assert(space >= 0, 'Space should be a non-negative value.');

    List<Widget> newChildren = [];
    for (int i = 0; i < children.length; i++) {
      newChildren.add(children[i]);
      if (i < children.length - 1) {
        newChildren.add(SizedBox(height: space));
      }
    }

    return Column(
      key: key,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      children: newChildren,
    );
  }

  /// Make a Column [Flexible].
  Flexible flexible({Key? key, int flex = 1, FlexFit fit = FlexFit.loose}) {
    return Flexible(key: key, flex: flex, fit: fit, child: this);
  }

  /// Make a Column [Expanded].
  Expanded expanded({Key? key, int flex = 1}) {
    return Expanded(key: key, flex: flex, child: this);
  }

  /// Make a widget visible when a condition is true.
  Widget visibleWhen(bool condition) {
    return Visibility(visible: condition, child: this);
  }
}

/// Extensions for [Image]
extension NyImageExt on Image {
  /// Get an image from the local assets folder.
  Image localAsset({String? path = '/images'}) {
    assert(image is AssetImage, "Image must be an AssetImage");
    if (image is AssetImage) {
      AssetImage assetImage = (image as AssetImage);
      return Image.asset(
        getImageAsset(assetImage.assetName, path: path),
        fit: fit,
        width: width,
        height: height,
        alignment: alignment,
        centerSlice: centerSlice,
        color: color,
        colorBlendMode: colorBlendMode,
        excludeFromSemantics: excludeFromSemantics,
        filterQuality: filterQuality,
        frameBuilder: frameBuilder,
        gaplessPlayback: gaplessPlayback,
        matchTextDirection: matchTextDirection,
        repeat: repeat,
        semanticLabel: semanticLabel,
        errorBuilder: errorBuilder,
        isAntiAlias: isAntiAlias,
        package: assetImage.package,
      );
    }
    return this;
  }

  /// Create a circle avatar.
  CircleAvatar circleAvatar({
    Color? backgroundColor = Colors.transparent,
    double radius = 30.0,
    ImageErrorListener? onBackgroundImageError,
    ImageErrorListener? onForegroundImageError,
    Color? foregroundColor,
    double? minRadius,
    double? maxRadius,
  }) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: image,
      backgroundColor: Colors.transparent,
      onBackgroundImageError: onBackgroundImageError,
      onForegroundImageError: onForegroundImageError,
      foregroundColor: foregroundColor,
      minRadius: minRadius,
      maxRadius: maxRadius,
    );
  }
}

/// Extensions for [SingleChildRenderObjectWidget]
extension NySingleChildRenderObjectWidgetExt on SingleChildRenderObjectWidget {
  /// Route to a new page.
  InkWell onTapRoute(
    dynamic routeName, {
    dynamic data,
    NavigationType navigationType = NavigationType.push,
    dynamic result,
    bool Function(Route<dynamic> route)? removeUntilPredicate,
    TransitionType? transitionType,
    @Deprecated(
      'Use transitionType instead to specify the page transition type.\nE.g. TransitionType.fadeIn()',
    )
    PageTransitionType? pageTransitionType,
    @Deprecated(
      'Use transitionType instead to specify the page transition settings.\nE.g. TransitionType.fadeIn(curve: Curves.easeIn)',
    )
    PageTransitionSettings? pageTransitionSettings,
    Function(dynamic value)? onPop,
  }) {
    if (routeName is RouteView) {
      routeName = routeName.name;
    }
    return InkWell(
      onTap: () async {
        await routeTo(
          routeName,
          data: data,
          navigationType: navigationType,
          result: result,
          removeUntilPredicate: removeUntilPredicate,
          transitionType: transitionType,
          // ignore: deprecated_member_use_from_same_package
          pageTransitionSettings: pageTransitionSettings,
          // ignore: deprecated_member_use_from_same_package
          pageTransitionType: pageTransitionType,
          onPop: onPop,
        );
      },
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      child: this,
    );
  }

  /// On tap run a action.
  Widget onTap(Function() action, {LoadingStyle? loadingStyle}) {
    if (loadingStyle == null) {
      return InkWell(
        onTap: () async {
          await action();
        },
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        child: this,
      );
    }

    return _TapLoadingWrapper(
      child: this,
      action: action,
      loadingStyle: loadingStyle,
    );
  }

  /// Add padding to the widget.
  Padding paddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: top,
        left: left,
        right: right,
        bottom: bottom,
      ),
      child: this,
    );
  }

  /// Add symmetric padding to the widget.
  Padding paddingSymmetric({double horizontal = 0.0, double vertical = 0.0}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
      child: this,
    );
  }

  /// Make a widget visible when a condition is true.
  Widget visibleWhen(bool condition) {
    return Visibility(visible: condition, child: this);
  }
}

/// Extensions for [StatelessWidget]
extension NyStatelessWidgetExt on StatelessWidget {
  /// Route to a new page.
  InkWell onTapRoute(
    dynamic routeName, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    NavigationType navigationType = NavigationType.push,
    dynamic result,
    bool Function(Route<dynamic> route)? removeUntilPredicate,
    TransitionType? transitionType,
    @Deprecated(
      'Use transitionType instead to specify the page transition type.\nE.g. TransitionType.fadeIn()',
    )
    PageTransitionType? pageTransitionType,
    @Deprecated(
      'Use transitionType instead to specify the page transition settings.\nE.g. TransitionType.fadeIn(curve: Curves.easeIn)',
    )
    PageTransitionSettings? pageTransitionSettings,
    Function(dynamic value)? onPop,
  }) {
    if (routeName is RouteView) {
      routeName = routeName.name;
    }
    return InkWell(
      onTap: () async {
        await routeTo(
          routeName,
          data: data,
          queryParameters: queryParameters,
          navigationType: navigationType,
          result: result,
          removeUntilPredicate: removeUntilPredicate,
          transitionType: transitionType,
          // ignore: deprecated_member_use_from_same_package
          pageTransitionSettings: pageTransitionSettings,
          // ignore: deprecated_member_use_from_same_package
          pageTransitionType: pageTransitionType,
          onPop: onPop,
        );
      },
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      child: this,
    );
  }

  /// On tap run a action.
  Widget onTap(Function() action, {LoadingStyle? loadingStyle}) {
    if (loadingStyle == null) {
      return InkWell(
        onTap: () async {
          await action();
        },
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        child: this,
      );
    }

    return _TapLoadingWrapper(
      child: this,
      action: action,
      loadingStyle: loadingStyle,
    );
  }

  /// Add padding to the widget.
  Padding paddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: top,
        left: left,
        right: right,
        bottom: bottom,
      ),
      child: this,
    );
  }

  /// Add symmetric padding to the widget.
  Padding paddingSymmetric({double horizontal = 0.0, double vertical = 0.0}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
      child: this,
    );
  }

  /// Make a widget visible when a condition is true.
  Widget visibleWhen(bool condition) {
    return Visibility(visible: condition, child: this);
  }

  /// Add a shadow to the container.
  Container shadow(
    int strength, {
    Color? color,
    double? blurRadius,
    double? spreadRadius,
    Offset? offset,
    double? rounded,
  }) {
    assert(strength >= 1 && strength <= 4, 'strength must be between 1 and 4');

    switch (strength) {
      case 1:
        return _setShadow(
          color ?? Colors.grey.withAlpha((255.0 * 0.4).round()),
          1.5,
          0,
          offset ?? const Offset(0.0, 0.1),
          rounded ?? 0,
        );
      case 2:
        return _setShadow(
          color ?? Colors.grey.withAlpha((255.0 * 0.6).round()),
          2,
          0,
          offset ?? const Offset(0.0, 0.1),
          rounded ?? 0,
        );
      case 3:
        return _setShadow(
          color ?? Colors.black38.withAlpha((255.0 * 0.25).round()),
          5.5,
          0,
          offset ?? const Offset(0.0, 0.1),
          rounded ?? 0,
        );
      case 4:
        return _setShadow(
          color ?? Colors.black38.withAlpha((255.0 * 0.3).round()),
          10,
          1,
          offset ?? const Offset(0.0, 0.1),
          rounded ?? 0,
        );
      default:
        return _setShadow(
          color ?? Colors.grey.withAlpha((255.0 * 0.4).round()),
          1.5,
          0,
          offset ?? const Offset(0.0, 0.1),
          rounded ?? 0,
        );
    }
  }

  /// Create a shadow on the container.
  Container _setShadow(
    Color color,
    double blurRadius,
    double spreadRadius,
    Offset offset,
    double rounded,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(rounded),
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
            offset: offset,
          ),
        ],
      ),
      child: this,
    );
  }

  /// Make a StatelessWidget [Flexible].
  Flexible flexible({Key? key, int flex = 1, FlexFit fit = FlexFit.loose}) {
    return Flexible(key: key, flex: flex, fit: fit, child: this);
  }

  /// Make gradient fader from the bottom of the widget.
  /// [strength] ranges from 0.0 (subtle) to 1.0 (strong).
  FadeOverlay faderBottom({double strength = 0.2, Color color = Colors.black}) {
    return FadeOverlay.bottom(strength: strength, color: color, child: this);
  }

  /// Make gradient fader from the top of the widget.
  /// [strength] ranges from 0.0 (subtle) to 1.0 (strong).
  FadeOverlay faderTop({double strength = 0.2, Color color = Colors.black}) {
    return FadeOverlay.top(strength: strength, color: color, child: this);
  }

  /// Make gradient fader from the left of the widget.
  /// [strength] ranges from 0.0 (subtle) to 1.0 (strong).
  FadeOverlay faderLeft({double strength = 0.2, Color color = Colors.black}) {
    return FadeOverlay.left(strength: strength, color: color, child: this);
  }

  /// Make gradient fader from the right of the widget.
  /// [strength] ranges from 0.0 (subtle) to 1.0 (strong).
  FadeOverlay faderRight({double strength = 0.2, Color color = Colors.black}) {
    return FadeOverlay.right(strength: strength, color: color, child: this);
  }

  /// Make gradient fader with custom alignment.
  /// [strength] ranges from 0.0 (subtle) to 1.0 (strong).
  FadeOverlay faderFrom({
    double strength = 0.2,
    Color color = Colors.black,
    AlignmentGeometry begin = Alignment.topCenter,
    AlignmentGeometry end = Alignment.bottomCenter,
  }) {
    return FadeOverlay(
      strength: strength,
      color: color,
      begin: begin,
      end: end,
      child: this,
    );
  }
}

/// Extensions for [Widget]
extension NyWidgetExt on Widget {
  /// Make a widget a skeleton using the [Skeletonizer] package.
  Skeletonizer toSkeleton({
    Key? key,
    bool? ignoreContainers,
    bool? justifyMultiLineText,
    Color? containersColor,
    bool ignorePointers = true,
    bool enabled = true,
    PaintingEffect? effect,
    TextBoneBorderRadius? textBoneBorderRadius,
  }) {
    return Skeletonizer(
      ignoreContainers: ignoreContainers,
      enabled: enabled,
      effect: effect,
      textBoneBorderRadius: textBoneBorderRadius,
      justifyMultiLineText: justifyMultiLineText,
      containersColor: containersColor,
      ignorePointers: ignorePointers,
      child: this,
    );
  }

  /// Make a widget pullable using the [Pullable] widget.
  Widget pullable({
    required Future<void> Function()? onRefresh,
    PullableConfig? pullableConfig,
  }) {
    if (pullableConfig == null) {
      pullableConfig = PullableConfig(onRefresh: onRefresh);
    } else {
      pullableConfig = pullableConfig.updateOnRefresh(onRefresh);
    }
    return Pullable(config: pullableConfig, child: this);
  }
}

extension NyStatefulExt on StatefulWidget {
  /// Make a StatefulWidget [Flexible].
  Flexible flexible({Key? key, int flex = 1, FlexFit fit = FlexFit.loose}) {
    return Flexible(key: key, flex: flex, fit: fit, child: this);
  }

  /// Add padding to the widget.
  Padding paddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: top,
        left: left,
        right: right,
        bottom: bottom,
      ),
      child: this,
    );
  }

  /// Add symmetric padding to the widget.
  Padding paddingSymmetric({double horizontal = 0.0, double vertical = 0.0}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
      child: this,
    );
  }

  /// Make a widget visible when a condition is true.
  Widget visibleWhen(bool condition) {
    return Visibility(visible: condition, child: this);
  }

  /// Make gradient fader from the bottom of the widget.
  /// [strength] ranges from 0.0 (subtle) to 1.0 (strong).
  FadeOverlay faderBottom({double strength = 0.2, Color color = Colors.black}) {
    return FadeOverlay.bottom(strength: strength, color: color, child: this);
  }

  /// Make gradient fader from the top of the widget.
  /// [strength] ranges from 0.0 (subtle) to 1.0 (strong).
  FadeOverlay faderTop({double strength = 0.2, Color color = Colors.black}) {
    return FadeOverlay.top(strength: strength, color: color, child: this);
  }

  /// Make gradient fader from the left of the widget.
  /// [strength] ranges from 0.0 (subtle) to 1.0 (strong).
  FadeOverlay faderLeft({double strength = 0.2, Color color = Colors.black}) {
    return FadeOverlay.left(strength: strength, color: color, child: this);
  }

  /// Make gradient fader from the right of the widget.
  /// [strength] ranges from 0.0 (subtle) to 1.0 (strong).
  FadeOverlay faderRight({double strength = 0.2, Color color = Colors.black}) {
    return FadeOverlay.right(strength: strength, color: color, child: this);
  }

  /// Make gradient fader with custom alignment.
  /// [strength] ranges from 0.0 (subtle) to 1.0 (strong).
  FadeOverlay faderFrom({
    double strength = 0.2,
    Color color = Colors.black,
    AlignmentGeometry begin = Alignment.topCenter,
    AlignmentGeometry end = Alignment.bottomCenter,
  }) {
    return FadeOverlay(
      strength: strength,
      color: color,
      begin: begin,
      end: end,
      child: this,
    );
  }
}

class _TapLoadingWrapper extends StatefulWidget {
  const _TapLoadingWrapper({
    required this.child,
    required this.action,
    required this.loadingStyle,
  });

  final Widget child;
  final Function() action;
  final LoadingStyle loadingStyle;

  @override
  State<_TapLoadingWrapper> createState() => _TapLoadingWrapperState();
}

class _TapLoadingWrapperState extends State<_TapLoadingWrapper> {
  bool _isLoading = false;

  Future<void> _handleTap() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final result = widget.action();
      if (result is Future) {
        await result;
      }
    } catch (_) {
      // swallow errors per request
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = _isLoading
        ? widget.loadingStyle.render(child: widget.child)
        : widget.child;

    return InkWell(
      onTap: _handleTap,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      child: child,
    );
  }
}

/// Extensions for [ListView]
extension NyBoxScrollViewExt on BoxScrollView {
  /// expand the list view.
  Column expanded() {
    return Column(children: [Expanded(child: this)]);
  }

  /// Add padding to the list view.
  Padding paddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: top,
        left: left,
        right: right,
        bottom: bottom,
      ),
      child: this,
    );
  }

  /// Add symmetric padding to the list view.
  Padding paddingSymmetric({double horizontal = 0.0, double vertical = 0.0}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
      child: this,
    );
  }

  /// Make a widget visible when a condition is true.
  Widget visibleWhen(bool condition) {
    return Visibility(visible: condition, child: this);
  }
}

/// Extensions for [Row]
extension NyRowExt on Row {
  /// Add padding to the row.
  Padding paddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: top,
        left: left,
        right: right,
        bottom: bottom,
      ),
      child: this,
    );
  }

  /// Add symmetric padding to the row.
  Padding paddingSymmetric({double horizontal = 0.0, double vertical = 0.0}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
      child: this,
    );
  }

  /// Adds a gap between each child.
  Row withGap(double space) {
    assert(space >= 0, 'Space should be a non-negative value.');

    List<Widget> newChildren = [];
    for (int i = 0; i < children.length; i++) {
      newChildren.add(children[i]);
      if (i < children.length - 1) {
        newChildren.add(SizedBox(width: space));
      }
    }

    return Row(
      key: key,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      children: newChildren,
    );
  }

  /// Add a divider between each child.
  IntrinsicHeight withDivider({
    double width = 1,
    Color? color,
    double thickness = 1,
    double indent = 0,
    double endIndent = 0,
  }) {
    List<Widget> newChildren = [];
    for (int i = 0; i < children.length; i++) {
      newChildren.add(children[i]);
      if (i < children.length - 1) {
        newChildren.add(
          VerticalDivider(
            width: width,
            color: color ?? Colors.grey.shade300,
            thickness: thickness,
            indent: indent,
            endIndent: endIndent,
          ),
        );
      }
    }

    return IntrinsicHeight(
      child: Row(
        key: key,
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: mainAxisSize,
        crossAxisAlignment: crossAxisAlignment,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        textBaseline: textBaseline,
        children: newChildren,
      ),
    );
  }

  /// Make a widget visible when a condition is true.
  Widget visibleWhen(bool condition) {
    return Visibility(visible: condition, child: this);
  }
}
