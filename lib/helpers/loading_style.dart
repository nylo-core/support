import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '/nylo.dart';

/// The [LoadingStyleType] enum is used to determine the type of loading widget
enum LoadingStyleType { normal, skeletonizer, none }

enum SkeletonizerEffect { shimmer, leaf, pulse }

/// The [LoadingStyle] class is used to determine the type of loading widget
class LoadingStyle {
  final LoadingStyleType type;
  final Widget? child;
  final SkeletonizerEffect? skeletonizerEffect;

  /// Construct a [LoadingStyle.skeletonizer] widget
  /// Provide a [widget] to display a custom loading widget.
  /// By default, the [LoadingStyle.skeletonizer] widget will attempt to
  /// render your widget with a skeletonizer loader.
  LoadingStyle.skeletonizer({this.child, SkeletonizerEffect? effect})
      : type = LoadingStyleType.skeletonizer,
        skeletonizerEffect = effect;

  /// Construct a [LoadingStyle.normal] widget
  /// Provide a [widget] to display a custom loading widget.
  /// By default, the [LoadingStyle.normal] widget will display your Nylo loader.
  LoadingStyle.normal({this.child})
      : type = LoadingStyleType.normal,
        skeletonizerEffect = null;

  /// Construct a [LoadingStyle.none] widget
  /// This will not display any loading widget.
  LoadingStyle.none()
      : type = LoadingStyleType.none,
        skeletonizerEffect = null,
        child = null;

  LoadingStyle({this.child})
      : type = LoadingStyleType.normal,
        skeletonizerEffect = null;

  /// Render the loading widget
  Widget render({Widget? child}) {
    switch (type) {
      case LoadingStyleType.normal:
        if (child != null) return child;
        return this.child ?? Nylo.appLoader();
      case LoadingStyleType.skeletonizer:
        return Skeletonizer(
          enabled: true,
          child: child ?? (this.child ?? Nylo.appLoader()),
        );
      case LoadingStyleType.none:
        return SizedBox.shrink();
    }
  }
}
