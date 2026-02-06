import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'ny_logger.dart';

/// Connectivity helper for checking network status.
///
/// Provides static methods to check connectivity and listen for changes.
///
/// Example:
/// ```dart
/// // Check if online
/// if (await NyConnectivity.isOnline()) {
///   // Make network request
/// }
///
/// // Get current connection type
/// final status = await NyConnectivity.status();
/// if (status.contains(ConnectivityResult.wifi)) {
///   print('Connected via WiFi');
/// }
///
/// // Listen to connectivity changes
/// NyConnectivity.stream().listen((results) {
///   print('Connection changed: $results');
/// });
/// ```
class NyConnectivity {
  static final Connectivity _connectivity = Connectivity();

  /// Get the current connectivity status.
  ///
  /// Returns a list of [ConnectivityResult] as devices can have
  /// multiple active connections (e.g., WiFi + VPN).
  static Future<List<ConnectivityResult>> status() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      NyLogger.error('Failed to check connectivity: $e');
      return [ConnectivityResult.none];
    }
  }

  /// Check if the device has any network connection.
  static Future<bool> isOnline() async {
    final results = await status();
    return !results.contains(ConnectivityResult.none);
  }

  /// Check if the device is offline.
  static Future<bool> isOffline() async {
    return !(await isOnline());
  }

  /// Check if connected via WiFi.
  static Future<bool> isWifi() async {
    final results = await status();
    return results.contains(ConnectivityResult.wifi);
  }

  /// Check if connected via mobile data.
  static Future<bool> isMobile() async {
    final results = await status();
    return results.contains(ConnectivityResult.mobile);
  }

  /// Check if connected via Ethernet.
  static Future<bool> isEthernet() async {
    final results = await status();
    return results.contains(ConnectivityResult.ethernet);
  }

  /// Check if connected via VPN.
  static Future<bool> isVpn() async {
    final results = await status();
    return results.contains(ConnectivityResult.vpn);
  }

  /// Check if connected via Bluetooth.
  static Future<bool> isBluetooth() async {
    final results = await status();
    return results.contains(ConnectivityResult.bluetooth);
  }

  /// Get a stream of connectivity changes.
  ///
  /// Example:
  /// ```dart
  /// NyConnectivity.stream().listen((results) {
  ///   if (results.contains(ConnectivityResult.none)) {
  ///     showOfflineMessage();
  ///   }
  /// });
  /// ```
  static Stream<List<ConnectivityResult>> stream() {
    return _connectivity.onConnectivityChanged;
  }

  /// Execute a callback only when online.
  ///
  /// Returns null if offline.
  ///
  /// Example:
  /// ```dart
  /// final result = await NyConnectivity.whenOnline(() async {
  ///   return await api.fetchData();
  /// });
  /// ```
  static Future<T?> whenOnline<T>(Future<T> Function() callback) async {
    if (await isOnline()) {
      return await callback();
    }
    return null;
  }

  /// Execute different callbacks based on connectivity status.
  ///
  /// Example:
  /// ```dart
  /// await NyConnectivity.when(
  ///   online: () async => await api.fetchData(),
  ///   offline: () async => await cache.getData(),
  /// );
  /// ```
  static Future<T> when<T>({
    required Future<T> Function() online,
    required Future<T> Function() offline,
  }) async {
    if (await isOnline()) {
      return await online();
    }
    return await offline();
  }

  /// Get a human-readable connection type string.
  static Future<String> connectionTypeString() async {
    final results = await status();
    if (results.contains(ConnectivityResult.wifi)) return 'WiFi';
    if (results.contains(ConnectivityResult.mobile)) return 'Mobile';
    if (results.contains(ConnectivityResult.ethernet)) return 'Ethernet';
    if (results.contains(ConnectivityResult.vpn)) return 'VPN';
    if (results.contains(ConnectivityResult.bluetooth)) return 'Bluetooth';
    if (results.contains(ConnectivityResult.other)) return 'Other';
    return 'None';
  }
}

/// Connectivity state enum for NyConnective widget.
enum NyConnectivityState { wifi, mobile, ethernet, vpn, bluetooth, other, none }

/// Extension to convert ConnectivityResult to NyConnectivityState.
extension ConnectivityResultExtension on ConnectivityResult {
  NyConnectivityState toNyState() {
    switch (this) {
      case ConnectivityResult.wifi:
        return NyConnectivityState.wifi;
      case ConnectivityResult.mobile:
        return NyConnectivityState.mobile;
      case ConnectivityResult.ethernet:
        return NyConnectivityState.ethernet;
      case ConnectivityResult.vpn:
        return NyConnectivityState.vpn;
      case ConnectivityResult.bluetooth:
        return NyConnectivityState.bluetooth;
      case ConnectivityResult.other:
        return NyConnectivityState.other;
      case ConnectivityResult.none:
        return NyConnectivityState.none;
    }
  }
}
