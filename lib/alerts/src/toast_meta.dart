import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

/// Callback for the toast widget's [initState] lifecycle hook.
/// Receives the toast display [duration] and animation [animDuration].
typedef ToastOnInitStateCallback =
    Function(Duration toastDuration, Duration animDuration);

/// Animation type for toast notifications.
enum ToastAnimationType {
  fade,
  scale,
  slideFromTop,
  slideFromTopFade,
  slideFromBottom,
  slideFromBottomFade,
  slideFromLeft,
  slideFromLeftFade,
  slideFromRight,
  slideFromRightFade,
  fadeScale,
  rotate,
  fadeRotate,
  none,
}

/// [ToastAnimation] defines animation styles for toast notifications.
/// Use factory constructors to create different animation effects.
class ToastAnimation {
  final ToastAnimationType type;
  final Duration? duration;
  final Curve? curve;

  const ToastAnimation._({required this.type, this.duration, this.curve});

  /// No animation
  const ToastAnimation.none()
    : type = ToastAnimationType.none,
      duration = null,
      curve = null;

  /// Simple fade in/out animation.
  /// Best for subtle, non-intrusive notifications.
  factory ToastAnimation.fade({Duration? duration, Curve? curve}) {
    return ToastAnimation._(
      type: ToastAnimationType.fade,
      duration: duration,
      curve: curve,
    );
  }

  /// Scale animation that grows from center.
  /// Best for attention-grabbing notifications.
  factory ToastAnimation.scale({Duration? duration, Curve? curve}) {
    return ToastAnimation._(
      type: ToastAnimationType.scale,
      duration: duration,
      curve: curve,
    );
  }

  /// Slide from top of screen.
  /// Best for notifications positioned at top.
  factory ToastAnimation.slideFromTop({Duration? duration, Curve? curve}) {
    return ToastAnimation._(
      type: ToastAnimationType.slideFromTop,
      duration: duration,
      curve: curve,
    );
  }

  /// Slide from top with fade effect.
  /// Best for smooth top-positioned notifications.
  factory ToastAnimation.slideFromTopFade({Duration? duration, Curve? curve}) {
    return ToastAnimation._(
      type: ToastAnimationType.slideFromTopFade,
      duration: duration,
      curve: curve,
    );
  }

  /// Slide from bottom of screen.
  /// Best for notifications positioned at bottom.
  factory ToastAnimation.slideFromBottom({Duration? duration, Curve? curve}) {
    return ToastAnimation._(
      type: ToastAnimationType.slideFromBottom,
      duration: duration,
      curve: curve,
    );
  }

  /// Slide from bottom with fade effect.
  /// Best for smooth bottom-positioned notifications.
  factory ToastAnimation.slideFromBottomFade({
    Duration? duration,
    Curve? curve,
  }) {
    return ToastAnimation._(
      type: ToastAnimationType.slideFromBottomFade,
      duration: duration,
      curve: curve,
    );
  }

  /// Slide from left side of screen.
  /// Best for left-to-right reading flow.
  factory ToastAnimation.slideFromLeft({Duration? duration, Curve? curve}) {
    return ToastAnimation._(
      type: ToastAnimationType.slideFromLeft,
      duration: duration,
      curve: curve,
    );
  }

  /// Slide from left with fade effect.
  /// Best for smooth left-side entry.
  factory ToastAnimation.slideFromLeftFade({Duration? duration, Curve? curve}) {
    return ToastAnimation._(
      type: ToastAnimationType.slideFromLeftFade,
      duration: duration,
      curve: curve,
    );
  }

  /// Slide from right side of screen.
  /// Best for right-to-left reading flow.
  factory ToastAnimation.slideFromRight({Duration? duration, Curve? curve}) {
    return ToastAnimation._(
      type: ToastAnimationType.slideFromRight,
      duration: duration,
      curve: curve,
    );
  }

  /// Slide from right with fade effect.
  /// Best for smooth right-side entry.
  factory ToastAnimation.slideFromRightFade({
    Duration? duration,
    Curve? curve,
  }) {
    return ToastAnimation._(
      type: ToastAnimationType.slideFromRightFade,
      duration: duration,
      curve: curve,
    );
  }

  /// Combined fade and scale animation.
  /// Best for prominent notifications.
  factory ToastAnimation.fadeScale({Duration? duration, Curve? curve}) {
    return ToastAnimation._(
      type: ToastAnimationType.fadeScale,
      duration: duration,
      curve: curve,
    );
  }

  /// Rotation animation.
  /// Best for playful/casual apps.
  factory ToastAnimation.rotate({Duration? duration, Curve? curve}) {
    return ToastAnimation._(
      type: ToastAnimationType.rotate,
      duration: duration,
      curve: curve,
    );
  }

  /// Combined fade and rotate animation.
  /// Best for creative/artistic interfaces.
  factory ToastAnimation.fadeRotate({Duration? duration, Curve? curve}) {
    return ToastAnimation._(
      type: ToastAnimationType.fadeRotate,
      duration: duration,
      curve: curve,
    );
  }

  /// Bounce in from top with elastic effect.
  /// Best for playful, attention-grabbing notifications.
  factory ToastAnimation.bounceInFromTop({Duration? duration}) {
    return ToastAnimation._(
      type: ToastAnimationType.slideFromTop,
      duration: duration ?? const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
    );
  }

  /// Bounce in from bottom with elastic effect.
  /// Best for playful bottom notifications.
  factory ToastAnimation.bounceInFromBottom({Duration? duration}) {
    return ToastAnimation._(
      type: ToastAnimationType.slideFromBottom,
      duration: duration ?? const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
    );
  }

  /// Bounce scale animation that pops in.
  /// Best for centered, attention-grabbing notifications.
  factory ToastAnimation.bounceIn({Duration? duration}) {
    return ToastAnimation._(
      type: ToastAnimationType.scale,
      duration: duration ?? const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
    );
  }

  /// Spring animation from top with overshoot.
  /// Best for smooth but noticeable entry.
  factory ToastAnimation.springFromTop({Duration? duration}) {
    return ToastAnimation._(
      type: ToastAnimationType.slideFromTopFade,
      duration: duration ?? const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
    );
  }

  /// Spring animation from bottom with overshoot.
  /// Best for smooth but noticeable entry.
  factory ToastAnimation.springFromBottom({Duration? duration}) {
    return ToastAnimation._(
      type: ToastAnimationType.slideFromBottomFade,
      duration: duration ?? const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
    );
  }

  // ── Reverse (exit) animations ──────────────────────────────────────

  /// Quick fade out.
  /// Pairs well with any entry animation.
  factory ToastAnimation.fadeOut({Duration? duration}) {
    return ToastAnimation._(
      type: ToastAnimationType.fade,
      duration: duration ?? const Duration(milliseconds: 250),
      curve: Curves.easeIn,
    );
  }

  /// Slide out to the top of the screen.
  /// Pairs with [springFromTop] / [slideFromTop] entries.
  factory ToastAnimation.slideOutTop({Duration? duration, Curve? curve}) {
    return ToastAnimation._(
      type: ToastAnimationType.slideFromTop,
      duration: duration ?? const Duration(milliseconds: 300),
      curve: curve ?? Curves.easeInBack,
    );
  }

  /// Slide out to the top with a fade.
  /// Pairs with [springFromTop] / [slideFromTopFade] entries.
  factory ToastAnimation.slideOutTopFade({Duration? duration, Curve? curve}) {
    return ToastAnimation._(
      type: ToastAnimationType.slideFromTopFade,
      duration: duration ?? const Duration(milliseconds: 300),
      curve: curve ?? Curves.easeInBack,
    );
  }

  /// Slide out to the bottom of the screen.
  /// Pairs with [springFromBottom] / [slideFromBottom] entries.
  factory ToastAnimation.slideOutBottom({Duration? duration, Curve? curve}) {
    return ToastAnimation._(
      type: ToastAnimationType.slideFromBottom,
      duration: duration ?? const Duration(milliseconds: 300),
      curve: curve ?? Curves.easeInBack,
    );
  }

  /// Slide out to the bottom with a fade.
  /// Pairs with [springFromBottom] / [slideFromBottomFade] entries.
  factory ToastAnimation.slideOutBottomFade({
    Duration? duration,
    Curve? curve,
  }) {
    return ToastAnimation._(
      type: ToastAnimationType.slideFromBottomFade,
      duration: duration ?? const Duration(milliseconds: 300),
      curve: curve ?? Curves.easeInBack,
    );
  }

  /// Shrink down and disappear.
  /// Pairs with [bounceIn] / [scale] entries.
  factory ToastAnimation.shrinkOut({Duration? duration}) {
    return ToastAnimation._(
      type: ToastAnimationType.scale,
      duration: duration ?? const Duration(milliseconds: 250),
      curve: Curves.easeInBack,
    );
  }

  /// Fade and shrink simultaneously.
  /// Smooth, polished exit for any toast.
  factory ToastAnimation.fadeShrinkOut({Duration? duration}) {
    return ToastAnimation._(
      type: ToastAnimationType.fadeScale,
      duration: duration ?? const Duration(milliseconds: 250),
      curve: Curves.easeIn,
    );
  }

  /// Slide out to the left.
  /// Pairs with [slideFromLeft] entries or for a swipe-away feel.
  factory ToastAnimation.slideOutLeft({Duration? duration, Curve? curve}) {
    return ToastAnimation._(
      type: ToastAnimationType.slideFromLeft,
      duration: duration ?? const Duration(milliseconds: 300),
      curve: curve ?? Curves.easeInCubic,
    );
  }

  /// Slide out to the right.
  /// Pairs with [slideFromRight] entries or for a swipe-away feel.
  factory ToastAnimation.slideOutRight({Duration? duration, Curve? curve}) {
    return ToastAnimation._(
      type: ToastAnimationType.slideFromRight,
      duration: duration ?? const Duration(milliseconds: 300),
      curve: curve ?? Curves.easeInCubic,
    );
  }

  /// Snap out instantly with a brief scale-down.
  /// Best for urgent dismissals or quick transitions.
  factory ToastAnimation.snapOut({Duration? duration}) {
    return ToastAnimation._(
      type: ToastAnimationType.fadeScale,
      duration: duration ?? const Duration(milliseconds: 150),
      curve: Curves.easeInExpo,
    );
  }

  /// Create a copy of this animation with overridden properties.
  ToastAnimation copyWith({
    ToastAnimationType? type,
    Duration? duration,
    Curve? curve,
  }) {
    return ToastAnimation._(
      type: type ?? this.type,
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
    );
  }
}

/// Position where the toast notification appears.
enum ToastNotificationPosition { top, bottom, center }

/// Typedef for toast style factory function.
/// The factory receives the [ToastMeta] and an [updateMeta] callback
/// to allow the widget to update position, duration, etc.
typedef ToastStyleFactory =
    Widget Function(ToastMeta meta, void Function(ToastMeta) updateMeta);

/// Typedef for a data-aware toast style factory.
/// Receives a [data] map and returns a [ToastStyleFactory].
/// This allows toast styles to use dynamic data passed at call time.
typedef ToastStyleDataFactory =
    ToastStyleFactory Function(Map<String, dynamic> data);

/// Toast Meta makes it easy to use pre-defined styles in the toast alert.
class ToastMeta {
  /// Icon widget displayed in the toast notification.
  final Widget? icon;

  /// Title text displayed in the toast notification.
  final String title;

  /// Style identifier for the toast notification.
  final String style;

  /// Description text displayed below the title.
  final String description;

  /// Background color for the icon section.
  final Color? color;

  /// Callback invoked when the toast notification is tapped.
  final VoidCallback? action;

  /// Callback invoked when the dismiss button is pressed.
  final VoidCallback? dismiss;

  /// Callback invoked when the toast is auto-dismissed or removed.
  final VoidCallback? onDismiss;

  /// Callback invoked when the toast becomes visible.
  final VoidCallback? onShow;

  /// Duration the toast notification is displayed.
  final Duration duration;

  /// Position where the toast notification appears on screen.
  final ToastNotificationPosition position;

  /// Additional metadata that can be passed to custom toast widgets.
  final Map<String, dynamic>? metaData;

  /// Animation style for the toast notification.
  /// If null, defaults to position-based animation.
  final ToastAnimation? animation;

  /// Reverse (exit) animation style for the toast notification.
  final ToastAnimation? reverseAnimation;

  /// Whether to dismiss other toasts when this one is shown.
  final bool? dismissOtherToast;

  /// Text direction for the toast notification.
  final TextDirection? textDirection;

  /// Alignment of the toast notification.
  final Alignment? alignment;

  /// Axis for the toast animation.
  final Axis? axis;

  /// Start offset for custom animation.
  final Offset? startOffset;

  /// End offset for custom animation.
  final Offset? endOffset;

  /// Start offset for reverse animation.
  final Offset? reverseStartOffset;

  /// End offset for reverse animation.
  final Offset? reverseEndOffset;

  /// Whether to hide the keyboard when the toast is shown.
  final bool? isHideKeyboard;

  /// Whether the toast ignores pointer events.
  final bool? isIgnoring;

  /// Custom animation builder for the toast.
  final CustomAnimationBuilder? animationBuilder;

  /// Custom reverse animation builder for the toast.
  final CustomAnimationBuilder? reverseAnimBuilder;

  /// Callback invoked when the toast animation controller is initialized.
  final ToastOnInitStateCallback? onInitState;

  ToastMeta({
    this.icon,
    this.title = '',
    this.style = '',
    this.description = '',
    this.color,
    this.action,
    this.dismiss,
    this.onDismiss,
    this.onShow,
    this.duration = const Duration(seconds: 5),
    this.position = ToastNotificationPosition.top,
    this.metaData,
    this.animation,
    this.reverseAnimation,
    this.dismissOtherToast,
    this.textDirection,
    this.alignment,
    this.axis,
    this.startOffset,
    this.endOffset,
    this.reverseStartOffset,
    this.reverseEndOffset,
    this.isHideKeyboard,
    this.isIgnoring,
    this.animationBuilder,
    this.reverseAnimBuilder,
    this.onInitState,
  });

  /// ToastMeta.copyWith() is used to copy the current toast alert and
  /// override the values.
  ToastMeta copyWith({
    Widget? icon,
    String? title,
    String? style,
    String? description,
    Color? color,
    VoidCallback? action,
    VoidCallback? dismiss,
    VoidCallback? onDismiss,
    VoidCallback? onShow,
    Duration? duration,
    ToastNotificationPosition? position,
    Map<String, dynamic>? metaData,
    ToastAnimation? animation,
    ToastAnimation? reverseAnimation,
    bool? dismissOtherToast,
    TextDirection? textDirection,
    Alignment? alignment,
    Axis? axis,
    Offset? startOffset,
    Offset? endOffset,
    Offset? reverseStartOffset,
    Offset? reverseEndOffset,
    bool? isHideKeyboard,
    bool? isIgnoring,
    CustomAnimationBuilder? animationBuilder,
    CustomAnimationBuilder? reverseAnimBuilder,
    ToastOnInitStateCallback? onInitState,
  }) {
    return ToastMeta(
      icon: icon ?? this.icon,
      title: title ?? this.title,
      style: style ?? this.style,
      description: description ?? this.description,
      color: color ?? this.color,
      action: action ?? this.action,
      dismiss: dismiss ?? this.dismiss,
      onDismiss: onDismiss ?? this.onDismiss,
      onShow: onShow ?? this.onShow,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      metaData: metaData ?? this.metaData,
      animation: animation ?? this.animation,
      reverseAnimation: reverseAnimation ?? this.reverseAnimation,
      dismissOtherToast: dismissOtherToast ?? this.dismissOtherToast,
      textDirection: textDirection ?? this.textDirection,
      alignment: alignment ?? this.alignment,
      axis: axis ?? this.axis,
      startOffset: startOffset ?? this.startOffset,
      endOffset: endOffset ?? this.endOffset,
      reverseStartOffset: reverseStartOffset ?? this.reverseStartOffset,
      reverseEndOffset: reverseEndOffset ?? this.reverseEndOffset,
      isHideKeyboard: isHideKeyboard ?? this.isHideKeyboard,
      isIgnoring: isIgnoring ?? this.isIgnoring,
      animationBuilder: animationBuilder ?? this.animationBuilder,
      reverseAnimBuilder: reverseAnimBuilder ?? this.reverseAnimBuilder,
      onInitState: onInitState ?? this.onInitState,
    );
  }
}

/// Registry for toast notification styles.
/// Stores widget factories keyed by string IDs (e.g., "success", "warning").
/// Use [ToastNotificationRegistry.register] to add custom toast styles.
///
/// Supports both static [ToastStyleFactory] styles and data-aware
/// [ToastStyleDataFactory] styles that receive data at call time.
class ToastNotificationRegistry {
  ToastNotificationRegistry._();

  static final ToastNotificationRegistry instance =
      ToastNotificationRegistry._();

  final Map<String, ToastStyleDataFactory> _styles = {};

  /// Register a single toast style with the given [id].
  /// The factory is wrapped to ignore data (backward compatible).
  void register(String id, ToastStyleFactory factory) {
    _styles[id] = (_) => factory;
  }

  /// Register a data-aware toast style with the given [id].
  /// The factory receives a [Map<String, dynamic>] data map at call time.
  void registerWithData(String id, ToastStyleDataFactory factory) {
    _styles[id] = factory;
  }

  /// Register multiple toast styles at once.
  /// Accepts both [ToastStyleFactory] and [ToastStyleDataFactory] values.
  void registerAll(Map<String, dynamic> styles) {
    for (final entry in styles.entries) {
      final value = entry.value;
      if (value is ToastStyleDataFactory) {
        _styles[entry.key] = value;
      } else if (value is ToastStyleFactory) {
        _styles[entry.key] = (_) => value;
      }
    }
  }

  /// Resolve a toast style by [id], passing [data] to data-aware factories.
  /// Returns the [ToastStyleFactory] ready to build the widget,
  /// or the "success" factory with a debug warning if [id] is not found.
  ToastStyleFactory? resolve(String id, Map<String, dynamic> data) {
    final dataFactory = _get(id);
    if (dataFactory == null) return null;
    return dataFactory(data);
  }

  /// Internal lookup by [id] with fallback to "success".
  ToastStyleDataFactory? _get(String id) {
    if (_styles.containsKey(id)) {
      return _styles[id];
    }

    if (kDebugMode) {
      debugPrint(
        'ToastNotificationRegistry: Style "$id" not found. Falling back to "success".',
      );
    }

    return _styles['success'];
  }

  /// Get a toast widget factory by [id].
  /// Returns the "success" factory with a debug warning if [id] is not found.
  /// Prefer [resolve] for data-aware factory support.
  ToastStyleFactory? get(String id) {
    return resolve(id, {});
  }

  /// Check if a toast style with [id] exists.
  bool has(String id) => _styles.containsKey(id);

  /// Get all registered toast style IDs.
  Set<String> get styleIds => _styles.keys.toSet();

  /// Clear all registered styles (useful for testing).
  void clear() => _styles.clear();
}
