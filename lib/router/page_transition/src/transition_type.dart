import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/router/models/ny_page_transition_settings.dart';
import 'enum.dart';

/// A utility class that simplifies the creation of page transitions by encapsulating
/// transition types and their associated settings.
///
/// This class provides named constructors for all supported transition types,
/// making it easier to specify the desired animation when navigating between screens.
///
/// Example usage:
/// ```dart
/// Navigator.push(
///   context,
///   PageTransition(
///     type: TransitionType.fade().pageTransitionType!,
///     duration: TransitionType.fade().pageTransitionSettings!.duration,
///     child: SecondScreen(),
///   ),
/// );
/// ```
///
/// Or with custom settings:
/// ```dart
/// Navigator.push(
///   context,
///   PageTransition(
///     type: TransitionType.rightToLeft(
///       duration: Duration(milliseconds: 300),
///       curve: Curves.easeInOut,
///     ).pageTransitionType!,
///     child: SecondScreen(),
///   ),
/// );
/// ```
class TransitionType {
  /// The type of page transition to be applied
  PageTransitionType? _pageTransitionType;

  /// The settings to be used for the transition animation
  PageTransitionSettings? _pageTransitionSettings;

  /// The default duration for the transition animation
  Duration _getDefaultDuration() {
    if (kIsWeb) {
      return const Duration(milliseconds: 270);
    }
    return Platform.isIOS
        ? const Duration(milliseconds: 330)
        : const Duration(milliseconds: 270);
  }

  /// The default curve for the transition animation
  Curve _getDefaultCurve() {
    if (kIsWeb) {
      return Curves.easeInOut;
    }
    return Platform.isIOS ? Curves.easeInOut : Curves.fastOutSlowIn;
  }

  /// Creates a fade transition.
  ///
  /// This transition fades the new page in while fading the old page out.
  ///
  /// Parameters:
  /// - [curve]: The curve to use for the transition animation (defaults to [Curves.linear])
  /// - [duration]: The duration of the transition animation (defaults to 200ms)
  /// - [reverseDuration]: The duration for the reverse animation (defaults to [duration])
  /// - [fullscreenDialog]: Whether the route is a fullscreen dialog
  /// - [opaque]: Whether the route is opaque
  TransitionType.fade({
    Curve? curve,
    Duration? duration,
    Duration? reverseDuration,
    bool? fullscreenDialog = false,
    bool? opaque = false,
  }) {
    _pageTransitionType = PageTransitionType.fade;
    _pageTransitionSettings = PageTransitionSettings.base(
      curve: curve ?? _getDefaultCurve(),
      duration: duration ?? _getDefaultDuration(),
      reverseDuration: reverseDuration ?? _getDefaultDuration(),
      fullscreenDialog: fullscreenDialog,
      opaque: opaque,
    );
  }

  /// Creates a right-to-left slide transition.
  ///
  /// This transition slides the new page in from the right edge of the screen.
  ///
  /// Parameters:
  /// - [matchingBuilder]: The platform-specific page transitions builder
  /// - [curve]: The curve to use for the transition animation (defaults to [Curves.linear])
  /// - [duration]: The duration of the transition animation (defaults to 200ms)
  /// - [reverseDuration]: The duration for the reverse animation (defaults to [duration])
  /// - [fullscreenDialog]: Whether the route is a fullscreen dialog
  /// - [opaque]: Whether the route is opaque
  TransitionType.rightToLeft({
    PageTransitionsBuilder? matchingBuilder,
    Curve? curve,
    Duration? duration,
    Duration? reverseDuration,
    bool? fullscreenDialog = false,
    bool? opaque = false,
  }) {
    _pageTransitionType = PageTransitionType.rightToLeft;
    _pageTransitionSettings = PageTransitionSettings(
      matchingBuilder:
          matchingBuilder ?? const CupertinoPageTransitionsBuilder(),
      curve: curve ?? _getDefaultCurve(),
      duration: duration ?? _getDefaultDuration(),
      reverseDuration: reverseDuration ?? _getDefaultDuration(),
      fullscreenDialog: fullscreenDialog,
      opaque: opaque,
    );
  }

  /// Creates a left-to-right slide transition.
  ///
  /// This transition slides the new page in from the left edge of the screen.
  ///
  /// Parameters:
  /// - [curve]: The curve to use for the transition animation (defaults to [Curves.linear])
  /// - [duration]: The duration of the transition animation (defaults to 200ms)
  /// - [reverseDuration]: The duration for the reverse animation (defaults to [duration])
  /// - [fullscreenDialog]: Whether the route is a fullscreen dialog
  /// - [opaque]: Whether the route is opaque
  TransitionType.leftToRight({
    Curve? curve,
    Duration? duration,
    Duration? reverseDuration,
    bool? fullscreenDialog,
    bool? opaque,
  }) {
    _pageTransitionType = PageTransitionType.leftToRight;
    _pageTransitionSettings = PageTransitionSettings.base(
      curve: curve ?? _getDefaultCurve(),
      duration: duration ?? _getDefaultDuration(),
      reverseDuration: reverseDuration ?? _getDefaultDuration(),
      fullscreenDialog: fullscreenDialog,
      opaque: opaque,
    );
  }

  /// Creates a top-to-bottom slide transition.
  ///
  /// This transition slides the new page in from the top edge of the screen.
  ///
  /// Parameters:
  /// - [curve]: The curve to use for the transition animation (defaults to [Curves.linear])
  /// - [duration]: The duration of the transition animation (defaults to 200ms)
  /// - [reverseDuration]: The duration for the reverse animation (defaults to [duration])
  /// - [fullscreenDialog]: Whether the route is a fullscreen dialog
  /// - [opaque]: Whether the route is opaque
  TransitionType.topToBottom({
    Curve? curve,
    Duration? duration,
    Duration? reverseDuration,
    bool? fullscreenDialog,
    bool? opaque,
  }) {
    _pageTransitionType = PageTransitionType.topToBottom;
    _pageTransitionSettings = PageTransitionSettings.base(
      curve: curve ?? _getDefaultCurve(),
      duration: duration ?? _getDefaultDuration(),
      reverseDuration: reverseDuration ?? _getDefaultDuration(),
      fullscreenDialog: fullscreenDialog,
      opaque: opaque,
    );
  }

  /// Creates a bottom-to-top slide transition.
  ///
  /// This transition slides the new page in from the bottom edge of the screen.
  ///
  /// Parameters:
  /// - [curve]: The curve to use for the transition animation (defaults to [Curves.linear])
  /// - [duration]: The duration of the transition animation (defaults to 200ms)
  /// - [reverseDuration]: The duration for the reverse animation (defaults to [duration])
  /// - [fullscreenDialog]: Whether the route is a fullscreen dialog
  /// - [opaque]: Whether the route is opaque
  TransitionType.bottomToTop({
    Curve? curve,
    Duration? duration,
    Duration? reverseDuration,
    bool? fullscreenDialog,
    bool? opaque,
  }) {
    _pageTransitionType = PageTransitionType.bottomToTop;
    _pageTransitionSettings = PageTransitionSettings.base(
      curve: curve ?? _getDefaultCurve(),
      duration: duration ?? _getDefaultDuration(),
      reverseDuration: reverseDuration ?? _getDefaultDuration(),
      fullscreenDialog: fullscreenDialog,
      opaque: opaque,
    );
  }

  /// Creates a scale transition.
  ///
  /// This transition scales the new page from the specified alignment point.
  ///
  /// Parameters:
  /// - [alignment]: The alignment point from which the scale animation originates (required)
  /// - [curve]: The curve to use for the transition animation (defaults to [Curves.linear])
  /// - [duration]: The duration of the transition animation (defaults to 200ms)
  /// - [reverseDuration]: The duration for the reverse animation (defaults to [duration])
  /// - [fullscreenDialog]: Whether the route is a fullscreen dialog
  /// - [opaque]: Whether the route is opaque
  TransitionType.scale({
    required Alignment alignment,
    Curve? curve,
    Duration? duration,
    Duration? reverseDuration,
    bool? fullscreenDialog,
    bool? opaque,
  }) {
    _pageTransitionType = PageTransitionType.scale;
    _pageTransitionSettings = PageTransitionSettings.base(
      alignment: alignment,
      curve: curve ?? _getDefaultCurve(),
      duration: duration ?? _getDefaultDuration(),
      reverseDuration: reverseDuration ?? _getDefaultDuration(),
      fullscreenDialog: fullscreenDialog,
      opaque: opaque,
    );
  }

  /// Creates a rotation transition.
  ///
  /// This transition rotates and scales the new page from the specified alignment point.
  ///
  /// Parameters:
  /// - [alignment]: The alignment point around which the rotation occurs (required)
  /// - [curve]: The curve to use for the transition animation (defaults to [Curves.linear])
  /// - [duration]: The duration of the transition animation (defaults to 200ms)
  /// - [reverseDuration]: The duration for the reverse animation (defaults to [duration])
  /// - [fullscreenDialog]: Whether the route is a fullscreen dialog
  /// - [opaque]: Whether the route is opaque
  TransitionType.rotate({
    required Alignment alignment,
    Curve? curve,
    Duration? duration,
    Duration? reverseDuration,
    bool? fullscreenDialog,
    bool? opaque,
  }) {
    _pageTransitionType = PageTransitionType.rotate;
    _pageTransitionSettings = PageTransitionSettings.base(
      alignment: alignment,
      curve: curve ?? _getDefaultCurve(),
      duration: duration ?? _getDefaultDuration(),
      reverseDuration: reverseDuration ?? _getDefaultDuration(),
      fullscreenDialog: fullscreenDialog,
      opaque: opaque,
    );
  }

  /// Creates a size transition.
  ///
  /// This transition grows the new page from the specified alignment point.
  ///
  /// Parameters:
  /// - [alignment]: The alignment point from which the size animation originates (required)
  /// - [curve]: The curve to use for the transition animation (defaults to [Curves.linear])
  /// - [duration]: The duration of the transition animation (defaults to 200ms)
  /// - [reverseDuration]: The duration for the reverse animation (defaults to [duration])
  /// - [fullscreenDialog]: Whether the route is a fullscreen dialog
  /// - [opaque]: Whether the route is opaque
  TransitionType.size({
    required Alignment alignment,
    Curve? curve,
    Duration? duration,
    Duration? reverseDuration,
    bool? fullscreenDialog,
    bool? opaque,
  }) {
    _pageTransitionType = PageTransitionType.size;
    _pageTransitionSettings = PageTransitionSettings.base(
      alignment: alignment,
      curve: curve ?? _getDefaultCurve(),
      duration: duration ?? _getDefaultDuration(),
      reverseDuration: reverseDuration ?? _getDefaultDuration(),
      fullscreenDialog: fullscreenDialog,
      opaque: opaque,
    );
  }

  /// Creates a right-to-left slide transition with a fade effect.
  ///
  /// This transition slides and fades the new page in from the right edge of the screen.
  ///
  /// Parameters:
  /// - [curve]: The curve to use for the transition animation (defaults to [Curves.linear])
  /// - [duration]: The duration of the transition animation (defaults to 200ms)
  /// - [reverseDuration]: The duration for the reverse animation (defaults to [duration])
  /// - [fullscreenDialog]: Whether the route is a fullscreen dialog
  /// - [opaque]: Whether the route is opaque
  TransitionType.rightToLeftWithFade({
    Curve? curve,
    Duration? duration,
    Duration? reverseDuration,
    bool? fullscreenDialog,
    bool? opaque,
  }) {
    _pageTransitionType = PageTransitionType.rightToLeftWithFade;
    _pageTransitionSettings = PageTransitionSettings.base(
      curve: curve ?? _getDefaultCurve(),
      duration: duration ?? _getDefaultDuration(),
      reverseDuration: reverseDuration ?? _getDefaultDuration(),
      fullscreenDialog: fullscreenDialog,
      opaque: opaque,
    );
  }

  /// Creates a left-to-right slide transition with a fade effect.
  ///
  /// This transition slides and fades the new page in from the left edge of the screen.
  ///
  /// Parameters:
  /// - [curve]: The curve to use for the transition animation (defaults to [Curves.linear])
  /// - [duration]: The duration of the transition animation (defaults to 200ms)
  /// - [reverseDuration]: The duration for the reverse animation (defaults to [duration])
  /// - [fullscreenDialog]: Whether the route is a fullscreen dialog
  /// - [opaque]: Whether the route is opaque
  TransitionType.leftToRightWithFade({
    Curve? curve,
    Duration? duration,
    Duration? reverseDuration,
    bool? fullscreenDialog,
    bool? opaque,
  }) {
    _pageTransitionType = PageTransitionType.leftToRightWithFade;
    _pageTransitionSettings = PageTransitionSettings.base(
      curve: curve ?? _getDefaultCurve(),
      duration: duration ?? _getDefaultDuration(),
      reverseDuration: reverseDuration ?? _getDefaultDuration(),
      fullscreenDialog: fullscreenDialog,
      opaque: opaque,
    );
  }

  /// Creates a left-to-right joined transition.
  ///
  /// This transition slides the current page out to the right while
  /// sliding the new page in from the left simultaneously.
  ///
  /// Parameters:
  /// - [childCurrent]: The current page widget (required)
  /// - [curve]: The curve to use for the transition animation (defaults to [Curves.linear])
  /// - [duration]: The duration of the transition animation (defaults to 200ms)
  /// - [reverseDuration]: The duration for the reverse animation (defaults to [duration])
  /// - [fullscreenDialog]: Whether the route is a fullscreen dialog
  /// - [opaque]: Whether the route is opaque
  TransitionType.leftToRightJoined({
    required Widget childCurrent,
    Curve? curve,
    Duration? duration,
    Duration? reverseDuration,
    bool? fullscreenDialog,
    bool? opaque,
  }) {
    _pageTransitionType = PageTransitionType.leftToRightJoined;
    _pageTransitionSettings = PageTransitionSettings.base(
      childCurrent: childCurrent,
      curve: curve ?? _getDefaultCurve(),
      duration: duration ?? _getDefaultDuration(),
      reverseDuration: reverseDuration ?? _getDefaultDuration(),
      fullscreenDialog: fullscreenDialog,
      opaque: opaque,
    );
  }

  /// Creates a right-to-left joined transition.
  ///
  /// This transition slides the current page out to the left while
  /// sliding the new page in from the right simultaneously.
  ///
  /// Parameters:
  /// - [childCurrent]: The current page widget (required)
  /// - [curve]: The curve to use for the transition animation (defaults to [Curves.linear])
  /// - [duration]: The duration of the transition animation (defaults to 200ms)
  /// - [reverseDuration]: The duration for the reverse animation (defaults to [duration])
  /// - [fullscreenDialog]: Whether the route is a fullscreen dialog
  /// - [opaque]: Whether the route is opaque
  TransitionType.rightToLeftJoined({
    required Widget childCurrent,
    Curve? curve,
    Duration? duration,
    Duration? reverseDuration,
    bool? fullscreenDialog,
    bool? opaque,
  }) {
    _pageTransitionType = PageTransitionType.rightToLeftJoined;
    _pageTransitionSettings = PageTransitionSettings.base(
      childCurrent: childCurrent,
      curve: curve ?? _getDefaultCurve(),
      duration: duration ?? _getDefaultDuration(),
      reverseDuration: reverseDuration ?? _getDefaultDuration(),
      fullscreenDialog: fullscreenDialog,
      opaque: opaque,
    );
  }

  /// Creates a top-to-bottom joined transition.
  ///
  /// This transition slides the current page down while
  /// sliding the new page in from the top simultaneously.
  ///
  /// Parameters:
  /// - [childCurrent]: The current page widget (required)
  /// - [curve]: The curve to use for the transition animation (defaults to [Curves.linear])
  /// - [duration]: The duration of the transition animation (defaults to 200ms)
  /// - [reverseDuration]: The duration for the reverse animation (defaults to [duration])
  /// - [fullscreenDialog]: Whether the route is a fullscreen dialog
  /// - [opaque]: Whether the route is opaque
  TransitionType.topToBottomJoined({
    required Widget childCurrent,
    Curve? curve,
    Duration? duration,
    Duration? reverseDuration,
    bool? fullscreenDialog,
    bool? opaque,
  }) {
    _pageTransitionType = PageTransitionType.topToBottomJoined;
    _pageTransitionSettings = PageTransitionSettings.base(
      childCurrent: childCurrent,
      curve: curve ?? _getDefaultCurve(),
      duration: duration ?? _getDefaultDuration(),
      reverseDuration: reverseDuration ?? _getDefaultDuration(),
      fullscreenDialog: fullscreenDialog,
      opaque: opaque,
    );
  }

  /// Creates a bottom-to-top joined transition.
  ///
  /// This transition slides the current page up while
  /// sliding the new page in from the bottom simultaneously.
  ///
  /// Parameters:
  /// - [childCurrent]: The current page widget (required)
  /// - [curve]: The curve to use for the transition animation (defaults to [Curves.linear])
  /// - [duration]: The duration of the transition animation (defaults to 200ms)
  /// - [reverseDuration]: The duration for the reverse animation (defaults to [duration])
  /// - [fullscreenDialog]: Whether the route is a fullscreen dialog
  /// - [opaque]: Whether the route is opaque
  TransitionType.bottomToTopJoined({
    required Widget childCurrent,
    Curve? curve,
    Duration? duration,
    Duration? reverseDuration,
    bool? fullscreenDialog,
    bool? opaque,
  }) {
    _pageTransitionType = PageTransitionType.bottomToTopJoined;
    _pageTransitionSettings = PageTransitionSettings.base(
      childCurrent: childCurrent,
      curve: curve ?? _getDefaultCurve(),
      duration: duration ?? _getDefaultDuration(),
      reverseDuration: reverseDuration ?? _getDefaultDuration(),
      fullscreenDialog: fullscreenDialog,
      opaque: opaque,
    );
  }

  /// Creates a left-to-right pop transition.
  ///
  /// This transition keeps the new page in place while
  /// sliding the current page out to the right.
  ///
  /// Parameters:
  /// - [childCurrent]: The current page widget (required)
  /// - [curve]: The curve to use for the transition animation (defaults to [Curves.linear])
  /// - [duration]: The duration of the transition animation (defaults to 200ms)
  /// - [reverseDuration]: The duration for the reverse animation (defaults to [duration])
  /// - [fullscreenDialog]: Whether the route is a fullscreen dialog
  /// - [opaque]: Whether the route is opaque
  TransitionType.leftToRightPop({
    required Widget childCurrent,
    Curve? curve,
    Duration? duration,
    Duration? reverseDuration,
    bool? fullscreenDialog,
    bool? opaque,
  }) {
    _pageTransitionType = PageTransitionType.leftToRightPop;
    _pageTransitionSettings = PageTransitionSettings.base(
      childCurrent: childCurrent,
      curve: curve ?? _getDefaultCurve(),
      duration: duration ?? _getDefaultDuration(),
      reverseDuration: reverseDuration ?? _getDefaultDuration(),
      fullscreenDialog: fullscreenDialog,
      opaque: opaque,
    );
  }

  /// Creates a right-to-left pop transition.
  ///
  /// This transition keeps the new page in place while
  /// sliding the current page out to the left.
  ///
  /// Parameters:
  /// - [childCurrent]: The current page widget (required)
  /// - [curve]: The curve to use for the transition animation (defaults to [Curves.linear])
  /// - [duration]: The duration of the transition animation (defaults to 200ms)
  /// - [reverseDuration]: The duration for the reverse animation (defaults to [duration])
  /// - [fullscreenDialog]: Whether the route is a fullscreen dialog
  /// - [opaque]: Whether the route is opaque
  TransitionType.rightToLeftPop({
    required Widget childCurrent,
    Curve? curve,
    Duration? duration,
    Duration? reverseDuration,
    bool? fullscreenDialog,
    bool? opaque,
  }) {
    _pageTransitionType = PageTransitionType.rightToLeftPop;
    _pageTransitionSettings = PageTransitionSettings.base(
      childCurrent: childCurrent,
      curve: curve ?? _getDefaultCurve(),
      duration: duration ?? _getDefaultDuration(),
      reverseDuration: reverseDuration ?? _getDefaultDuration(),
      fullscreenDialog: fullscreenDialog,
      opaque: opaque,
    );
  }

  /// Creates a top-to-bottom pop transition.
  ///
  /// This transition keeps the new page in place while
  /// sliding the current page down.
  ///
  /// Parameters:
  /// - [childCurrent]: The current page widget (required)
  /// - [curve]: The curve to use for the transition animation (defaults to [Curves.linear])
  /// - [duration]: The duration of the transition animation (defaults to 200ms)
  /// - [reverseDuration]: The duration for the reverse animation (defaults to [duration])
  /// - [fullscreenDialog]: Whether the route is a fullscreen dialog
  /// - [opaque]: Whether the route is opaque
  TransitionType.topToBottomPop({
    required Widget childCurrent,
    Curve? curve,
    Duration? duration,
    Duration? reverseDuration,
    bool? fullscreenDialog,
    bool? opaque,
  }) {
    _pageTransitionType = PageTransitionType.topToBottomPop;
    _pageTransitionSettings = PageTransitionSettings.base(
      childCurrent: childCurrent,
      curve: curve ?? _getDefaultCurve(),
      duration: duration ?? _getDefaultDuration(),
      reverseDuration: reverseDuration ?? _getDefaultDuration(),
      fullscreenDialog: fullscreenDialog,
      opaque: opaque,
    );
  }

  /// Creates a bottom-to-top pop transition.
  ///
  /// This transition keeps the new page in place while
  /// sliding the current page up.
  ///
  /// Parameters:
  /// - [childCurrent]: The current page widget (required)
  /// - [curve]: The curve to use for the transition animation (defaults to [Curves.linear])
  /// - [duration]: The duration of the transition animation (defaults to 200ms)
  /// - [reverseDuration]: The duration for the reverse animation (defaults to [duration])
  /// - [fullscreenDialog]: Whether the route is a fullscreen dialog
  /// - [opaque]: Whether the route is opaque
  TransitionType.bottomToTopPop({
    required Widget childCurrent,
    Curve? curve,
    Duration? duration,
    Duration? reverseDuration,
    bool? fullscreenDialog,
    bool? opaque,
  }) {
    _pageTransitionType = PageTransitionType.bottomToTopPop;
    _pageTransitionSettings = PageTransitionSettings.base(
      childCurrent: childCurrent,
      curve: curve ?? _getDefaultCurve(),
      duration: duration ?? _getDefaultDuration(),
      reverseDuration: reverseDuration ?? _getDefaultDuration(),
      fullscreenDialog: fullscreenDialog,
      opaque: opaque,
    );
  }

  /// Creates a shared axis horizontal transition.
  ///
  /// This transition slides and fades horizontally, similar to
  /// Material Design's shared axis pattern.
  ///
  /// Parameters:
  /// - [curve]: The curve to use for the transition animation (defaults to [Curves.linear])
  /// - [duration]: The duration of the transition animation (defaults to 200ms)
  /// - [reverseDuration]: The duration for the reverse animation (defaults to [duration])
  /// - [fullscreenDialog]: Whether the route is a fullscreen dialog
  /// - [opaque]: Whether the route is opaque
  TransitionType.sharedAxisHorizontal({
    Curve? curve,
    Duration? duration,
    Duration? reverseDuration,
    bool? fullscreenDialog,
    bool? opaque,
  }) {
    _pageTransitionType = PageTransitionType.sharedAxisHorizontal;
    _pageTransitionSettings = PageTransitionSettings.base(
      curve: curve ?? _getDefaultCurve(),
      duration: duration ?? _getDefaultDuration(),
      reverseDuration: reverseDuration ?? _getDefaultDuration(),
      fullscreenDialog: fullscreenDialog,
      opaque: opaque,
    );
  }

  /// Creates a shared axis vertical transition.
  ///
  /// This transition slides and fades vertically, similar to
  /// Material Design's shared axis pattern.
  ///
  /// Parameters:
  /// - [curve]: The curve to use for the transition animation (defaults to [Curves.linear])
  /// - [duration]: The duration of the transition animation (defaults to 200ms)
  /// - [reverseDuration]: The duration for the reverse animation (defaults to [duration])
  /// - [fullscreenDialog]: Whether the route is a fullscreen dialog
  /// - [opaque]: Whether the route is opaque
  TransitionType.sharedAxisVertical({
    Curve? curve,
    Duration? duration,
    Duration? reverseDuration,
    bool? fullscreenDialog,
    bool? opaque,
  }) {
    _pageTransitionType = PageTransitionType.sharedAxisVertical;
    _pageTransitionSettings = PageTransitionSettings.base(
      curve: curve ?? _getDefaultCurve(),
      duration: duration ?? _getDefaultDuration(),
      reverseDuration: reverseDuration ?? _getDefaultDuration(),
      fullscreenDialog: fullscreenDialog,
      opaque: opaque,
    );
  }

  /// Creates a shared axis scale transition.
  ///
  /// This transition scales and fades, similar to
  /// Material Design's shared axis pattern.
  ///
  /// Parameters:
  /// - [curve]: The curve to use for the transition animation (defaults to [Curves.linear])
  /// - [duration]: The duration of the transition animation (defaults to 200ms)
  /// - [reverseDuration]: The duration for the reverse animation (defaults to [duration])
  /// - [fullscreenDialog]: Whether the route is a fullscreen dialog
  /// - [opaque]: Whether the route is opaque
  TransitionType.sharedAxisScale({
    Curve? curve,
    Duration? duration,
    Duration? reverseDuration,
    bool? fullscreenDialog,
    bool? opaque,
  }) {
    _pageTransitionType = PageTransitionType.sharedAxisScale;
    _pageTransitionSettings = PageTransitionSettings.base(
      curve: curve ?? _getDefaultCurve(),
      duration: duration ?? _getDefaultDuration(),
      reverseDuration: reverseDuration ?? _getDefaultDuration(),
      fullscreenDialog: fullscreenDialog,
      opaque: opaque,
    );
  }

  /// Creates a theme-based transition.
  ///
  /// This transition uses the app theme's page transitions theme.
  ///
  /// Parameters:
  /// - [curve]: The curve to use for the transition animation (defaults to [Curves.linear])
  /// - [duration]: The duration of the transition animation (defaults to 200ms)
  /// - [reverseDuration]: The duration for the reverse animation (defaults to [duration])
  /// - [fullscreenDialog]: Whether the route is a fullscreen dialog
  /// - [opaque]: Whether the route is opaque
  TransitionType.theme({
    Curve? curve,
    Duration? duration,
    Duration? reverseDuration,
    bool? fullscreenDialog,
    bool? opaque,
  }) {
    _pageTransitionType = PageTransitionType.theme;
    _pageTransitionSettings = PageTransitionSettings.base(
      curve: curve ?? _getDefaultCurve(),
      duration: duration ?? _getDefaultDuration(),
      reverseDuration: reverseDuration ?? _getDefaultDuration(),
      fullscreenDialog: fullscreenDialog,
      opaque: opaque,
    );
  }

  /// Returns the configured page transition type.
  ///
  /// This method is used to retrieve the transition type that
  /// should be passed to the PageTransition constructor.
  PageTransitionType? get pageTransitionType => _pageTransitionType;

  /// Returns the configured page transition settings.
  ///
  /// This method is used to retrieve the settings object that contains
  /// all the configuration for the transition animation.
  PageTransitionSettings? get pageTransitionSettings => _pageTransitionSettings;
}
