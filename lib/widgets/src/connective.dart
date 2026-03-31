import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '/helpers/ny_helpers.dart';
import '/localization/ny_localization.dart';

/// A widget that rebuilds based on connectivity state.
///
/// Provides different builders for different connection types,
/// or a general builder that receives the connectivity state.
///
/// Example with specific builders:
/// ```dart
/// Connective(
///   onWifi: Text('Connected via WiFi'),
///   onMobile: Text('Connected via Mobile Data'),
///   onNone: Text('No connection'),
/// )
/// ```
///
/// Example with builder:
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
  /// Widget to show when connected via WiFi.
  final Widget? onWifi;

  /// Widget to show when connected via mobile data.
  final Widget? onMobile;

  /// Widget to show when connected via Ethernet.
  final Widget? onEthernet;

  /// Widget to show when connected via VPN.
  final Widget? onVpn;

  /// Widget to show when connected via Bluetooth.
  final Widget? onBluetooth;

  /// Widget to show when connected via Satellite.
  final Widget? onSatellite;

  /// Widget to show for other connection types.
  final Widget? onOther;

  /// Widget to show when offline.
  final Widget? onNone;

  /// Default widget to show if no specific handler is provided.
  final Widget? child;

  /// Builder function for custom handling.
  final Widget Function(
    BuildContext context,
    NyConnectivityState state,
    List<ConnectivityResult> results,
  )?
  builder;

  /// Whether to show a loading indicator while checking initial state.
  final bool showLoadingOnInit;

  /// Custom loading widget.
  final Widget? loadingWidget;

  /// Callback when connectivity changes.
  final void Function(
    NyConnectivityState state,
    List<ConnectivityResult> results,
  )?
  onConnectivityChanged;

  /// Creates a Connective widget with specific builders for each state.
  const Connective({
    super.key,
    this.onWifi,
    this.onMobile,
    this.onEthernet,
    this.onVpn,
    this.onBluetooth,
    this.onSatellite,
    this.onOther,
    this.onNone,
    this.child,
    this.showLoadingOnInit = false,
    this.loadingWidget,
    this.onConnectivityChanged,
  }) : builder = null;

  /// Creates a Connective widget with a custom builder.
  const Connective.builder({
    super.key,
    required this.builder,
    this.showLoadingOnInit = false,
    this.loadingWidget,
    this.onConnectivityChanged,
  }) : onWifi = null,
       onMobile = null,
       onEthernet = null,
       onVpn = null,
       onBluetooth = null,
       onSatellite = null,
       onOther = null,
       onNone = null,
       child = null;

  @override
  State<Connective> createState() => _ConnectiveState();
}

class _ConnectiveState extends State<Connective> {
  static const _defaultLoading = Center(child: CircularProgressIndicator());
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading && widget.showLoadingOnInit) {
      return widget.loadingWidget ?? _defaultLoading;
    }

    // Use custom builder if provided
    if (widget.builder != null) {
      return widget.builder!(context, _state, _results);
    }

    // Use specific state widgets
    final stateWidget = switch (_state) {
      NyConnectivityState.wifi => widget.onWifi,
      NyConnectivityState.mobile => widget.onMobile,
      NyConnectivityState.ethernet => widget.onEthernet,
      NyConnectivityState.vpn => widget.onVpn,
      NyConnectivityState.bluetooth => widget.onBluetooth,
      NyConnectivityState.satellite => widget.onSatellite,
      NyConnectivityState.other => widget.onOther,
      NyConnectivityState.none => widget.onNone,
    };

    return stateWidget ?? widget.child ?? _empty;
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
        final isOffline = state == NyConnectivityState.none;

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
    return Connective(onNone: offline, child: this);
  }

  /// Only shows the widget when online, otherwise shows nothing.
  Widget onlyOnline() {
    return Connective(onNone: const SizedBox.shrink(), child: this);
  }

  /// Only shows the widget when offline, otherwise shows nothing.
  Widget onlyOffline() {
    return Connective.builder(
      builder: (context, state, results) {
        return state == NyConnectivityState.none
            ? this
            : const SizedBox.shrink();
      },
    );
  }
}
