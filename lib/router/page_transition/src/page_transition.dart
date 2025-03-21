import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'enum.dart';

/// Builder function type for creating the transition page
typedef TransitionPageBuilder = Widget Function(BuildContext context,
    Animation<double> animation, Animation<double> secondaryAnimation);

/// Builder function type for creating child widget
typedef ChildBuilder = Widget Function(BuildContext context);

/// A flexible page transition class that extends [PageRouteBuilder] to provide
/// a variety of customizable transition animations between screens.
///
/// This class simplifies the implementation of animated transitions when
/// navigating between pages in a Flutter application. It supports various
/// transition types including slides, fades, scales, rotations, and
/// combinations of these effects.
///
/// Example usage:
/// ```dart
/// Navigator.push(
///   context,
///   PageTransition(
///     type: PageTransitionType.rightToLeft,
///     child: SecondPage(),
///   ),
/// );
/// ```
class PageTransition<T> extends PageRouteBuilder<T> {
  /// The widget to display on the next page.
  /// Either [child] or [childBuilder] must be provided, but not both.
  final Widget? child;

  /// A builder function that creates the child widget with context.
  /// Use this when you need to build the child with a BuildContext.
  /// Either [child] or [childBuilder] must be provided, but not both.
  final ChildBuilder? childBuilder;

  /// The platform-specific page transitions builder.
  /// Used for iOS-specific transitions when on iOS platform.
  final PageTransitionsBuilder matchingBuilder;

  /// The widget representing the current page.
  /// Required for joined and pop transition types.
  final Widget? childCurrent;

  /// Specifies the animation type for the transition.
  /// See [PageTransitionType] for available options.
  final PageTransitionType type;

  /// The curve to use for the animation.
  /// Defaults to [Curves.linear].
  final Curve curve;

  /// Alignment reference for transitions that require it,
  /// such as [PageTransitionType.scale], [PageTransitionType.rotate],
  /// and [PageTransitionType.size].
  final Alignment? alignment;

  /// Duration of the forward transition animation.
  /// Defaults to 200 milliseconds.
  Duration? duration;

  /// Duration of the reverse transition animation.
  /// Defaults to the same value as [duration].
  Duration? reverseDuration;

  /// The BuildContext used when [inheritTheme] is true.
  /// Required when inheritTheme is set to true.
  final BuildContext? ctx;

  /// Whether to inherit the theme from the provided [ctx].
  /// When true, [ctx] must be provided.
  final bool inheritTheme;

  /// Whether the route should be a full-screen dialog.
  /// Defaults to false.
  @override
  // ignore: overridden_fields
  final bool fullscreenDialog;

  /// Whether the route is opaque.
  /// Set to false if the route is transparent.
  /// Defaults to false.
  @override
  // ignore: overridden_fields
  final bool opaque;

  /// Flag indicating if the current platform is iOS.
  /// Used internally to apply platform-specific behaviors.
  late bool isIos;

  /// Controls whether the route maintains its state when it's not visible.
  /// If null, defaults to true.
  final bool? maintainStateData;

  /// Creates a [PageTransition] with the specified configuration.
  ///
  /// Either [child] or [childBuilder] must be provided, but not both.
  /// When using certain transition types, additional parameters are required:
  /// - [alignment] is required for [PageTransitionType.scale],
  ///   [PageTransitionType.rotate], and [PageTransitionType.size]
  /// - [childCurrent] is required for joined and pop transition types
  ///   (e.g., [PageTransitionType.rightToLeftJoined])
  /// - [ctx] is required when [inheritTheme] is true
  PageTransition({
    Key? key,
    this.child,
    this.childBuilder,
    required this.type,
    this.childCurrent,
    this.ctx,
    this.inheritTheme = false,
    this.curve = Curves.linear,
    this.alignment,
    this.duration,
    this.reverseDuration,
    this.fullscreenDialog = false,
    this.opaque = false,
    this.matchingBuilder = const CupertinoPageTransitionsBuilder(),
    this.maintainStateData,
    super.settings,
  })  : assert(child != null || childBuilder != null,
            'Either child or childBuilder must be provided'),
        assert(!(child != null && childBuilder != null),
            'Cannot provide both child and childBuilder'),
        assert(inheritTheme ? ctx != null : true,
            "'ctx' cannot be null when 'inheritTheme' is true, set ctx: context"),
        super(
          pageBuilder: (context, animation, secondaryAnimation) {
            return childBuilder?.call(context) ?? child!;
          },
          maintainState: maintainStateData ?? true,
          opaque: opaque,
          fullscreenDialog: fullscreenDialog,
        ) {
    this.reverseDuration = reverseDuration ?? duration;
    if (kIsWeb) {
      isIos = false;
      return;
    }
    isIos = Platform.isIOS;
  }

  @override
  Duration get transitionDuration => duration ?? Duration(seconds: 300);

  @override

  /// The duration for the reverse animation when popping the route.
  /// Falls back to [duration] if not specified.
  Duration get reverseTransitionDuration =>
      (reverseDuration ?? duration) ?? Duration(seconds: 300);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);
    final curvedSecondaryAnimation =
        CurvedAnimation(parent: secondaryAnimation, curve: curve);

    switch (type) {
      case PageTransitionType.theme:

        /// Uses the theme's default page transitions theme
        return Theme.of(context).pageTransitionsTheme.buildTransitions(
              this,
              context,
              curvedAnimation,
              curvedSecondaryAnimation,
              child,
            );

      case PageTransitionType.fade:

        /// Creates a fade transition that fades the new page in
        final fadeTransition = FadeTransition(
          opacity: curvedAnimation,
          child: child,
        );
        if (isIos) {
          return matchingBuilder.buildTransitions(
            this,
            context,
            curvedAnimation,
            curvedSecondaryAnimation,
            fadeTransition,
          );
        }
        return fadeTransition;

      case PageTransitionType.rightToLeft:

        /// Slides the page in from right to left
        var slideTransition = SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
        if (isIos) {
          return matchingBuilder.buildTransitions(
            this,
            context,
            curvedAnimation,
            curvedSecondaryAnimation,
            child,
          );
        }
        return slideTransition;

      case PageTransitionType.leftToRight:

        /// Slides the page in from left to right
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.topToBottom:

        /// Slides the page in from top to bottom
        var slideTransition = SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
        if (isIos) {
          return matchingBuilder.buildTransitions(
            this,
            context,
            curvedAnimation,
            curvedSecondaryAnimation,
            slideTransition,
          );
        }
        return slideTransition;

      case PageTransitionType.bottomToTop:

        /// Slides the page in from bottom to top
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.scale:

        /// Scales the new page in from [alignment] point
        /// Requires [alignment] parameter
        assert(alignment != null, """
                When using type "scale" you need argument: 'alignment'
                """);
        var scaleTransition = ScaleTransition(
          alignment: alignment!,
          scale: curvedAnimation,
          child: child,
        );
        if (isIos) {
          return matchingBuilder.buildTransitions(
            this,
            context,
            curvedAnimation,
            curvedSecondaryAnimation,
            scaleTransition,
          );
        }
        return scaleTransition;

      case PageTransitionType.rotate:

        /// Rotates and scales the new page from [alignment] point
        /// Requires [alignment] parameter
        assert(alignment != null, """
                When using type "RotationTransition" you need argument: 'alignment'
                """);
        return RotationTransition(
          alignment: alignment!,
          turns: curvedAnimation,
          child: ScaleTransition(
            alignment: alignment!,
            scale: curvedAnimation,
            child: FadeTransition(
              opacity: curvedAnimation,
              child: child,
            ),
          ),
        );

      case PageTransitionType.size:

        /// Creates a size transition that grows from [alignment] point
        /// Requires [alignment] parameter
        assert(alignment != null, """
                When using type "size" you need argument: 'alignment'
                """);
        return Align(
          alignment: alignment!,
          child: SizeTransition(
            sizeFactor: CurvedAnimation(
              parent: curvedAnimation,
              curve: curve,
            ),
            child: child,
          ),
        );

      case PageTransitionType.rightToLeftWithFade:

        /// Slides and fades the new page in from right to left
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
          ),
        );

      case PageTransitionType.leftToRightWithFade:

        /// Slides and fades the new page in from left to right
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1, 0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
          ),
        );

      case PageTransitionType.rightToLeftJoined:

        /// Slides the current page out to the left while sliding new page in from right
        /// Requires [childCurrent] parameter
        assert(childCurrent != null, """
                When using type "rightToLeftJoined" you need argument: 'childCurrent'

                example:
                  child: MyPage(),
                  childCurrent: this

                """);

        return Stack(
          children: <Widget>[
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.0),
                end: const Offset(-1.0, 0.0),
              ).animate(curvedAnimation),
              child: childCurrent,
            ),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            )
          ],
        );

      case PageTransitionType.leftToRightJoined:

        /// Slides the current page out to the right while sliding new page in from left
        /// Requires [childCurrent] parameter
        assert(childCurrent != null, """
                When using type "leftToRightJoined" you need argument: 'childCurrent'
                example:
                  child: MyPage(),
                  childCurrent: this

                """);
        return Stack(
          children: <Widget>[
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1.0, 0.0),
                end: const Offset(0.0, 0.0),
              ).animate(curvedAnimation),
              child: child,
            ),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.0),
                end: const Offset(1.0, 0.0),
              ).animate(curvedAnimation),
              child: childCurrent,
            )
          ],
        );

      case PageTransitionType.topToBottomJoined:

        /// Slides the current page down while sliding new page in from top
        /// Requires [childCurrent] parameter
        assert(childCurrent != null, """
                When using type "topToBottomJoined" you need argument: 'childCurrent'
                example:
                  child: MyPage(),
                  childCurrent: this

                """);
        return Stack(
          children: <Widget>[
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, -1.0),
                end: const Offset(0.0, 0.0),
              ).animate(curvedAnimation),
              child: child,
            ),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.0),
                end: const Offset(0.0, 1.0),
              ).animate(curvedAnimation),
              child: childCurrent,
            )
          ],
        );

      case PageTransitionType.bottomToTopJoined:

        /// Slides the current page up while sliding new page in from bottom
        /// Requires [childCurrent] parameter
        assert(childCurrent != null, """
                When using type "bottomToTopJoined" you need argument: 'childCurrent'
                example:
                  child: MyPage(),
                  childCurrent: this

                """);
        return Stack(
          children: <Widget>[
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: const Offset(0.0, 0.0),
              ).animate(curvedAnimation),
              child: child,
            ),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.0),
                end: const Offset(0.0, -1.0),
              ).animate(curvedAnimation),
              child: childCurrent,
            )
          ],
        );

      case PageTransitionType.rightToLeftPop:

        /// Keeps the new page in place while sliding the current page out to the left
        /// Requires [childCurrent] parameter
        assert(childCurrent != null, """
                When using type "rightToLeftPop" you need argument: 'childCurrent'

                example:
                  child: MyPage(),
                  childCurrent: this

                """);
        return Stack(
          children: <Widget>[
            child,
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.0),
                end: const Offset(-1.0, 0.0),
              ).animate(curvedAnimation),
              child: childCurrent,
            ),
          ],
        );

      case PageTransitionType.leftToRightPop:

        /// Keeps the new page in place while sliding the current page out to the right
        /// Requires [childCurrent] parameter
        assert(childCurrent != null, """
                When using type "leftToRightPop" you need argument: 'childCurrent'
                example:
                  child: MyPage(),
                  childCurrent: this

                """);
        return Stack(
          children: <Widget>[
            child,
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.0),
                end: const Offset(1.0, 0.0),
              ).animate(curvedAnimation),
              child: childCurrent,
            )
          ],
        );

      case PageTransitionType.topToBottomPop:

        /// Keeps the new page in place while sliding the current page down
        /// Requires [childCurrent] parameter
        assert(childCurrent != null, """
                When using type "topToBottomPop" you need argument: 'childCurrent'
                example:
                  child: MyPage(),
                  childCurrent: this

                """);
        return Stack(
          children: <Widget>[
            child,
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.0),
                end: const Offset(0.0, 1.0),
              ).animate(curvedAnimation),
              child: childCurrent,
            )
          ],
        );

      case PageTransitionType.bottomToTopPop:

        /// Keeps the new page in place while sliding the current page up
        /// Requires [childCurrent] parameter
        assert(childCurrent != null, """
                When using type "bottomToTopPop" you need argument: 'childCurrent'
                example:
                  child: MyPage(),
                  childCurrent: this

                """);
        return Stack(
          children: <Widget>[
            child,
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.0),
                end: const Offset(0.0, -1.0),
              ).animate(curvedAnimation),
              child: childCurrent,
            )
          ],
        );

      case PageTransitionType.sharedAxisHorizontal:

        /// Creates a shared axis transition that slides and fades
        /// horizontally, similar to Material Design shared axis pattern
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                (1 - curvedAnimation.value) * MediaQuery.of(context).size.width,
                0,
              ),
              child: Opacity(
                opacity: curvedAnimation.value,
                child: child,
              ),
            );
          },
          child: child,
        );

      case PageTransitionType.sharedAxisVertical:

        /// Creates a shared axis transition that slides and fades
        /// vertically, similar to Material Design shared axis pattern
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                0,
                (1 - curvedAnimation.value) *
                    MediaQuery.of(context).size.height,
              ),
              child: Opacity(
                opacity: curvedAnimation.value,
                child: child,
              ),
            );
          },
          child: child,
        );

      case PageTransitionType.sharedAxisScale:

        /// Creates a shared axis transition that scales and fades,
        /// similar to Material Design shared axis pattern
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
    }
  }
}
