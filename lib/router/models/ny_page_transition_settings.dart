import 'package:flutter/material.dart';

/// This class contains all page transition settings.
class PageTransitionSettings {
  final Widget? childCurrent;
  final BuildContext? context;
  final bool? inheritTheme;
  final Curve? curve;
  final Alignment? alignment;
  final Duration? duration;
  final Duration? reverseDuration;
  final bool? fullscreenDialog;
  final bool? opaque;
  final bool? isIos;
  final PageTransitionsBuilder? matchingBuilder;

  const PageTransitionSettings(
      {this.childCurrent,
      this.context,
      this.inheritTheme,
      this.curve,
      this.alignment,
      this.duration,
      this.reverseDuration,
      this.fullscreenDialog,
      this.opaque,
      this.isIos,
      this.matchingBuilder});

  const PageTransitionSettings.base(
      {this.childCurrent,
      this.context,
      this.inheritTheme = false,
      this.curve = Curves.linear,
      this.alignment,
      this.duration = const Duration(milliseconds: 200),
      this.reverseDuration = const Duration(milliseconds: 200),
      this.fullscreenDialog = false,
      this.opaque = false,
      this.isIos = false,
      this.matchingBuilder = const CupertinoPageTransitionsBuilder()});

  @override
  String toString() {
    return 'PageTransitionSettings{childCurrent: $childCurrent, '
        'context: $context, '
        'inheritTheme: $inheritTheme, '
        'curve: $curve, '
        'alignment: $alignment, '
        'duration: $duration, '
        'reverseDuration: $reverseDuration, '
        'fullscreenDialog: $fullscreenDialog, '
        'opaque: $opaque, '
        'isIos: $isIos, '
        'matchingBuilder: $matchingBuilder}';
  }
}
