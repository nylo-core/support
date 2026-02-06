import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '/nylo.dart';

/// The [LoadingStyleType] enum is used to determine the type of loading widget
enum LoadingStyleType { normal, skeletonizer, none }

/// The effect to use for the skeletonizer loading style
enum SkeletonizerEffect { shimmer, pulse, solid }

/// The [LoadingStyle] class is used to determine the type of loading widget
class LoadingStyle {
  final LoadingStyleType type;
  final Widget? child;
  final SkeletonizerEffect? skeletonizerEffect;

  /// Construct a [LoadingStyle.skeletonizer] widget.
  /// Provide a [child] to display a custom loading widget.
  /// Optionally provide an [effect] to customize the skeleton animation.
  /// By default, the skeletonizer will use a shimmer effect.
  LoadingStyle.skeletonizer({this.child, SkeletonizerEffect? effect})
    : type = LoadingStyleType.skeletonizer,
      skeletonizerEffect = effect;

  /// Construct a [LoadingStyle.normal] widget.
  /// Provide a [child] to display a custom loading widget.
  /// By default, the Nylo app loader will be displayed.
  LoadingStyle.normal({this.child})
    : type = LoadingStyleType.normal,
      skeletonizerEffect = null;

  /// Construct a [LoadingStyle.none] widget.
  /// This will not display any loading widget.
  const LoadingStyle.none()
    : type = LoadingStyleType.none,
      skeletonizerEffect = null,
      child = null;

  LoadingStyle({this.child, this.type = LoadingStyleType.normal})
    : skeletonizerEffect = null;

  /// Get the skeletonizer effect based on the [skeletonizerEffect] field
  PaintingEffect _getEffect() {
    switch (skeletonizerEffect) {
      case SkeletonizerEffect.shimmer:
        return const ShimmerEffect();
      case SkeletonizerEffect.pulse:
        return const PulseEffect();
      case SkeletonizerEffect.solid:
        return const SolidColorEffect();
      default:
        return const ShimmerEffect();
    }
  }

  /// Render the loading widget.
  /// For [LoadingStyleType.skeletonizer], pass [child] to wrap a specific widget.
  Widget render({Widget? child}) {
    switch (type) {
      case LoadingStyleType.normal:
        return this.child ?? Nylo.appLoader();
      case LoadingStyleType.skeletonizer:
        return Skeletonizer(
          enabled: true,
          effect: _getEffect(),
          child: child ?? this.child ?? Nylo.appLoader(),
        );
      case LoadingStyleType.none:
        return const SizedBox.shrink();
    }
  }
}
