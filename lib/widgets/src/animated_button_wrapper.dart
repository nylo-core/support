import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/helpers/src/button_animation_style.dart';

/// A wrapper widget that applies animation effects to buttons.
/// Wraps the button output rather than modifying individual button implementations.
class AnimatedButtonWrapper extends StatefulWidget {
  final Widget child;
  final ButtonAnimationStyle animationStyle;
  final bool isLoading;
  final VoidCallback? onPressed;

  const AnimatedButtonWrapper({
    super.key,
    required this.child,
    required this.animationStyle,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  State<AnimatedButtonWrapper> createState() => AnimatedButtonWrapperState();
}

class AnimatedButtonWrapperState extends State<AnimatedButtonWrapper>
    with TickerProviderStateMixin {
  // Animation controllers for different effects
  late AnimationController _pressController;
  late AnimationController _pulseController;
  late AnimationController _shineController;
  late AnimationController _shakeController;
  late AnimationController _rippleController;

  // Animation values
  late Animation<double> _scaleAnimation;
  late Animation<double> _translateYAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shineAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _squeezeXAnimation;
  late Animation<double> _squeezeYAnimation;
  late Animation<double> _morphRadiusAnimation;

  Offset? _tapPosition;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
  }

  void _initializeControllers() {
    final style = widget.animationStyle;

    _pressController = AnimationController(
      vsync: this,
      duration: style.duration,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: style.duration,
    );

    _shineController = AnimationController(
      vsync: this,
      duration: style.duration,
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: style.duration,
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: style.duration,
    );
  }

  void _initializeAnimations() {
    final style = widget.animationStyle;

    // Scale animation for bounce effect
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: style.scaleMin ?? 0.92,
    ).animate(CurvedAnimation(parent: _pressController, curve: style.curve));

    // TranslateY animation for clickable effect
    _translateYAnimation = Tween<double>(
      begin: 0.0,
      end: style.translateY ?? 4.0,
    ).animate(CurvedAnimation(parent: _pressController, curve: style.curve));

    // Pulse animation
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: style.pulseScale ?? 1.05,
    ).animate(CurvedAnimation(parent: _pulseController, curve: style.curve));

    // Shine animation
    _shineAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _shineController, curve: style.curve));

    // Shake animation
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _shakeController, curve: style.curve));

    // Ripple animation
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: style.rippleScale ?? 2.0,
    ).animate(CurvedAnimation(parent: _rippleController, curve: style.curve));

    // Squeeze animations
    _squeezeXAnimation = Tween<double>(
      begin: 1.0,
      end: style.squeezeX ?? 0.95,
    ).animate(CurvedAnimation(parent: _pressController, curve: style.curve));

    _squeezeYAnimation = Tween<double>(
      begin: 1.0,
      end: style.squeezeY ?? 1.05,
    ).animate(CurvedAnimation(parent: _pressController, curve: style.curve));

    // Morph radius animation
    _morphRadiusAnimation = Tween<double>(
      begin: 8.0,
      end: style.morphRadius ?? 24.0,
    ).animate(CurvedAnimation(parent: _pressController, curve: style.curve));
  }

  @override
  void didUpdateWidget(AnimatedButtonWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationStyle.duration != widget.animationStyle.duration) {
      _pressController.duration = widget.animationStyle.duration;
      _pulseController.duration = widget.animationStyle.duration;
      _shineController.duration = widget.animationStyle.duration;
      _shakeController.duration = widget.animationStyle.duration;
      _rippleController.duration = widget.animationStyle.duration;
      _initializeAnimations();
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    _pulseController.dispose();
    _shineController.dispose();
    _shakeController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _triggerHapticFeedback() {
    if (widget.animationStyle.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.isLoading) return;
    setState(() {
      _tapPosition = details.localPosition;
    });
    _triggerHapticFeedback();
    _startPressAnimation();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.isLoading) return;
    _endPressAnimation();
  }

  void _onTapCancel() {
    if (widget.isLoading) return;
    _endPressAnimation();
  }

  void _startPressAnimation() {
    final type = widget.animationStyle.type;

    switch (type) {
      case ButtonAnimationType.clickable:
      case ButtonAnimationType.bounce:
      case ButtonAnimationType.squeeze:
      case ButtonAnimationType.jelly:
      case ButtonAnimationType.morph:
        _pressController.forward();
        break;
      case ButtonAnimationType.pulse:
        _pulseController.repeat(reverse: true);
        break;
      case ButtonAnimationType.shine:
        _shineController.forward(from: 0.0);
        break;
      case ButtonAnimationType.ripple:
        _rippleController.forward(from: 0.0);
        break;
      case ButtonAnimationType.shake:
      case ButtonAnimationType.none:
        break;
    }
  }

  void _endPressAnimation() {
    final type = widget.animationStyle.type;

    switch (type) {
      case ButtonAnimationType.clickable:
      case ButtonAnimationType.bounce:
      case ButtonAnimationType.squeeze:
      case ButtonAnimationType.jelly:
      case ButtonAnimationType.morph:
        _pressController.reverse();
        break;
      case ButtonAnimationType.pulse:
        _pulseController.stop();
        _pulseController.reset();
        break;
      case ButtonAnimationType.shine:
      case ButtonAnimationType.ripple:
        // Let these complete naturally
        break;
      case ButtonAnimationType.shake:
      case ButtonAnimationType.none:
        break;
    }
  }

  /// Programmatically trigger the shake animation (useful for error states)
  void shake() {
    if (widget.animationStyle.type == ButtonAnimationType.shake ||
        widget.animationStyle.type != ButtonAnimationType.none) {
      _triggerHapticFeedback();
      _shakeController.forward(from: 0.0).then((_) {
        _shakeController.reset();
      });
    }
  }

  void _onTap() {
    if (widget.isLoading) return;
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animationStyle.type == ButtonAnimationType.none ||
        widget.isLoading) {
      return widget.child;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _onTap,
      child: IgnorePointer(child: _buildAnimatedChild()),
    );
  }

  Widget _buildAnimatedChild() {
    switch (widget.animationStyle.type) {
      case ButtonAnimationType.clickable:
        return _buildClickableAnimation();
      case ButtonAnimationType.bounce:
        return _buildBounceAnimation();
      case ButtonAnimationType.pulse:
        return _buildPulseAnimation();
      case ButtonAnimationType.squeeze:
        return _buildSqueezeAnimation();
      case ButtonAnimationType.jelly:
        return _buildJellyAnimation();
      case ButtonAnimationType.shine:
        return _buildShineAnimation();
      case ButtonAnimationType.ripple:
        return _buildRippleAnimation();
      case ButtonAnimationType.morph:
        return _buildMorphAnimation();
      case ButtonAnimationType.shake:
        return _buildShakeAnimation();
      case ButtonAnimationType.none:
        return widget.child;
    }
  }

  Widget _buildClickableAnimation() {
    return AnimatedBuilder(
      animation: _pressController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _translateYAnimation.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }

  Widget _buildBounceAnimation() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: widget.child,
    );
  }

  Widget _buildPulseAnimation() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _pulseAnimation.value, child: child);
      },
      child: widget.child,
    );
  }

  Widget _buildSqueezeAnimation() {
    return AnimatedBuilder(
      animation: _pressController,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.diagonal3Values(
            _squeezeXAnimation.value,
            _squeezeYAnimation.value,
            1.0,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }

  Widget _buildJellyAnimation() {
    final style = widget.animationStyle;
    return AnimatedBuilder(
      animation: _pressController,
      builder: (context, child) {
        final jellyStrength = style.jellyStrength ?? 0.15;
        final t = _pressController.value;
        // Create a wobbly effect
        final scaleX = 1.0 - (jellyStrength * math.sin(t * math.pi));
        final scaleY = 1.0 + (jellyStrength * math.sin(t * math.pi));
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.diagonal3Values(scaleX, scaleY, 1.0),
          child: child,
        );
      },
      child: widget.child,
    );
  }

  Widget _buildShineAnimation() {
    final style = widget.animationStyle;
    return AnimatedBuilder(
      animation: _shineAnimation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              child!,
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _shineAnimation,
                    builder: (context, _) {
                      return ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.transparent,
                              (style.shineColor ?? Colors.white).withValues(
                                alpha: 0.3,
                              ),
                              Colors.transparent,
                            ],
                            stops: [
                              _shineAnimation.value - (style.shineWidth ?? 0.3),
                              _shineAnimation.value,
                              _shineAnimation.value + (style.shineWidth ?? 0.3),
                            ].map((s) => s.clamp(0.0, 1.0)).toList(),
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.srcIn,
                        child: Container(color: Colors.white),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
      child: widget.child,
    );
  }

  Widget _buildRippleAnimation() {
    return AnimatedBuilder(
      animation: _rippleAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            if (_tapPosition != null && _rippleController.isAnimating)
              Positioned.fill(
                child: IgnorePointer(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CustomPaint(
                      painter: _RipplePainter(
                        center: _tapPosition!,
                        radius: _rippleAnimation.value * 100,
                        opacity: 1.0 - _rippleController.value,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      child: widget.child,
    );
  }

  Widget _buildMorphAnimation() {
    return AnimatedBuilder(
      animation: _morphRadiusAnimation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(_morphRadiusAnimation.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }

  Widget _buildShakeAnimation() {
    final style = widget.animationStyle;
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final shakeOffset = style.shakeOffset ?? 8.0;
        final shakeCount = style.shakeCount ?? 3;
        final offsetX =
            math.sin(_shakeAnimation.value * shakeCount * 2 * math.pi) *
            shakeOffset *
            (1 - _shakeAnimation.value);
        return Transform.translate(offset: Offset(offsetX, 0), child: child);
      },
      child: widget.child,
    );
  }
}

/// Custom painter for the ripple effect
class _RipplePainter extends CustomPainter {
  final Offset center;
  final double radius;
  final double opacity;

  _RipplePainter({
    required this.center,
    required this.radius,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) {
    return oldDelegate.radius != radius || oldDelegate.opacity != opacity;
  }
}
