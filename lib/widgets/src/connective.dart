import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '/helpers/ny_helpers.dart';
import '/localization/ny_localization.dart';

/// A widget that rebuilds based on connectivity state.
///
/// Use [noInternet] to show a fallback widget when the device has no
/// internet connection (wifi, mobile, or ethernet).
///
/// Example:
/// ```dart
/// Connective(
///   noInternet: Center(child: Text('No internet connection')),
///   child: MyContent(),
/// )
/// ```
///
/// Example with builder for full control:
/// ```dart
/// Connective.builder(
///   builder: (context, state, results) {
///     if (state == NyConnectivityState.none) {
///       return OfflineBanner();
///     }
///     return child;
///   },
/// )
/// ```
class Connective extends StatefulWidget {
  /// Widget to show when internet is unavailable (wifi, mobile, ethernet all absent).
  final Widget? noInternet;

  /// Default widget to show when internet is available.
  final Widget? child;

  /// Builder function for custom handling.
  final Widget Function(
    BuildContext context,
    NyConnectivityState state,
    List<ConnectivityResult> results,
  )?
  builder;

  /// Callback when connectivity changes.
  final void Function(
    NyConnectivityState state,
    List<ConnectivityResult> results,
  )?
  onConnectivityChanged;

  /// Creates a Connective widget with connectivity requirements.
  const Connective({
    super.key,
    this.noInternet,
    this.child,
    this.onConnectivityChanged,
  }) : builder = null;

  /// Creates a Connective widget with a custom builder.
  const Connective.builder({
    super.key,
    required this.builder,
    this.onConnectivityChanged,
  }) : noInternet = null,
       child = null;

  @override
  State<Connective> createState() => _ConnectiveState();
}

class _ConnectiveState extends State<Connective> {
  static const _empty = SizedBox.shrink();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  List<ConnectivityResult> _results = const [];
  NyConnectivityState _state = NyConnectivityState.none;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _startListening();
  }

  Future<void> _initConnectivity() async {
    final results = await NyConnectivity.status();
    if (mounted) {
      setState(() {
        _results = results;
        _state = _getPrimaryState(results);
        _isLoading = false;
      });
    }
  }

  void _startListening() {
    _subscription = NyConnectivity.stream().listen((results) {
      if (mounted) {
        final newState = _getPrimaryState(results);
        setState(() {
          _results = results;
          _state = newState;
        });
        widget.onConnectivityChanged?.call(newState, results);
      }
    });
  }

  NyConnectivityState _getPrimaryState(List<ConnectivityResult> results) {
    // Priority order for determining primary state
    if (results.contains(ConnectivityResult.wifi)) {
      return NyConnectivityState.wifi;
    }
    if (results.contains(ConnectivityResult.mobile)) {
      return NyConnectivityState.mobile;
    }
    if (results.contains(ConnectivityResult.ethernet)) {
      return NyConnectivityState.ethernet;
    }
    if (results.contains(ConnectivityResult.vpn)) {
      return NyConnectivityState.vpn;
    }
    if (results.contains(ConnectivityResult.bluetooth)) {
      return NyConnectivityState.bluetooth;
    }
    if (results.contains(ConnectivityResult.satellite)) {
      return NyConnectivityState.satellite;
    }
    if (results.contains(ConnectivityResult.other)) {
      return NyConnectivityState.other;
    }
    return NyConnectivityState.none;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  bool _hasInternet() {
    return _results.contains(ConnectivityResult.wifi) ||
        _results.contains(ConnectivityResult.mobile) ||
        _results.contains(ConnectivityResult.ethernet);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && widget.builder == null) {
      return widget.child ?? _empty;
    }

    // Use custom builder if provided
    if (widget.builder != null) {
      return widget.builder!(context, _state, _results);
    }

    // Show fallback if no internet connection
    if (widget.noInternet != null && !_hasInternet()) {
      return widget.noInternet!;
    }

    return widget.child ?? _empty;
  }
}

/// Widget that shows an offline banner at the top of the screen.
///
/// Example:
/// ```dart
/// Scaffold(
///   body: Stack(
///     children: [
///       YourContent(),
///       OfflineBanner(),
///     ],
///   ),
/// )
/// ```
class OfflineBanner extends StatelessWidget {
  /// The message to display when offline.
  final String message;

  /// Background color of the banner.
  final Color? backgroundColor;

  /// Text color.
  final Color? textColor;

  /// Icon to display.
  final IconData? icon;

  /// Height of the banner.
  final double height;

  /// Whether to animate in/out.
  final bool animate;

  /// Animation duration.
  final Duration animationDuration;

  const OfflineBanner({
    super.key,
    this.message = 'nylo.offline_banner.message',
    this.backgroundColor,
    this.textColor,
    this.icon = Icons.wifi_off,
    this.height = 40,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.red.shade700;
    final txtColor = textColor ?? Colors.white;

    return Connective.builder(
      builder: (context, state, results) {
        final isOffline =
            !results.contains(ConnectivityResult.wifi) &&
            !results.contains(ConnectivityResult.mobile) &&
            !results.contains(ConnectivityResult.ethernet);

        if (animate) {
          return AnimatedPositioned(
            duration: animationDuration,
            top: isOffline ? 0 : -height,
            left: 0,
            right: 0,
            child: _buildBanner(bgColor, txtColor),
          );
        }

        if (!isOffline) return const SizedBox.shrink();
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildBanner(bgColor, txtColor),
        );
      },
    );
  }

  Widget _buildBanner(Color bgColor, Color txtColor) {
    return Container(
      height: height,
      color: bgColor,
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: txtColor, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              message.tr(),
              style: TextStyle(color: txtColor, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extension to add connectivity-aware functionality to widgets.
extension ConnectiveExtension on Widget {
  /// Wraps the widget in a Connective that shows an offline placeholder.
  Widget connectiveOr({required Widget offline}) {
    return Connective(noInternet: offline, child: this);
  }

  /// Only shows the widget when online, otherwise shows nothing.
  Widget onlyOnline() {
    return Connective(noInternet: const SizedBox.shrink(), child: this);
  }

  /// Only shows the widget when offline, otherwise shows nothing.
  Widget onlyOffline() {
    return Connective.builder(
      builder: (context, state, results) {
        final hasInternet =
            results.contains(ConnectivityResult.wifi) ||
            results.contains(ConnectivityResult.mobile) ||
            results.contains(ConnectivityResult.ethernet);
        return hasInternet ? const SizedBox.shrink() : this;
      },
    );
  }
}
