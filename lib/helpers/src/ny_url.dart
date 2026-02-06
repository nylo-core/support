import 'package:url_launcher/url_launcher.dart';
import 'ny_logger.dart';

/// Launch mode for opening URLs.
enum UrlLaunchModeType {
  /// Open in external browser app.
  externalApplication,

  /// Open in-app WebView (Safari VC on iOS, Chrome Custom Tabs on Android).
  inAppWebView,

  /// Open in-app browser view.
  inAppBrowserView,

  /// Let the platform decide how to open.
  platformDefault,
}

/// Opens a URL in the browser.
///
/// [url] - The URL to open.
/// [mode] - How to open the URL (default: external browser).
/// [webOnly] - If true, only http/https URLs are allowed.
/// [headers] - Custom headers for in-app WebView requests.
///
/// Returns `true` if the URL was successfully launched, `false` otherwise.
///
/// Example:
/// ```dart
/// // Open URL in external browser (default)
/// await openUrl('https://example.com');
///
/// // Open URL in-app WebView
/// await openUrl(
///   'https://example.com',
///   mode: UrlLaunchModeType.inAppWebView,
/// );
///
/// // Open with custom headers (in-app only)
/// await openUrl(
///   'https://example.com',
///   mode: UrlLaunchModeType.inAppWebView,
///   headers: {'Authorization': 'Bearer token'},
/// );
/// ```
Future<bool> openUrl(
  String url, {
  UrlLaunchModeType mode = UrlLaunchModeType.externalApplication,
  bool webOnly = false,
  Map<String, String>? headers,
}) async {
  try {
    final uri = Uri.parse(url);

    // Validate web-only URLs
    if (webOnly && !['http', 'https'].contains(uri.scheme)) {
      NyLogger.error(
        'openUrl: Only http/https URLs are allowed when webOnly is true',
      );
      return false;
    }

    // Map UrlLaunchModeType to url_launcher's LaunchMode
    final launchMode = _mapLaunchMode(mode);

    // Configure WebView settings if using in-app mode
    final webViewConfig = WebViewConfiguration(headers: headers ?? {});

    final result = await launchUrl(
      uri,
      mode: launchMode,
      webViewConfiguration: webViewConfig,
    );

    if (!result) {
      NyLogger.error('openUrl: Failed to launch URL: $url');
    }

    return result;
  } catch (e) {
    NyLogger.error('openUrl: Error launching URL: $e');
    return false;
  }
}

/// Check if a URL can be opened.
///
/// [url] - The URL to check.
///
/// Returns `true` if the URL can be launched, `false` otherwise.
///
/// Example:
/// ```dart
/// if (await canOpenUrl('https://example.com')) {
///   await openUrl('https://example.com');
/// }
/// ```
Future<bool> canOpenUrl(String url) async {
  try {
    final uri = Uri.parse(url);
    return await canLaunchUrl(uri);
  } catch (e) {
    NyLogger.error('canOpenUrl: Error checking URL: $e');
    return false;
  }
}

/// Maps [UrlLaunchModeType] to url_launcher's [LaunchMode].
LaunchMode _mapLaunchMode(UrlLaunchModeType mode) {
  switch (mode) {
    case UrlLaunchModeType.externalApplication:
      return LaunchMode.externalApplication;
    case UrlLaunchModeType.inAppWebView:
      return LaunchMode.inAppWebView;
    case UrlLaunchModeType.inAppBrowserView:
      return LaunchMode.inAppBrowserView;
    case UrlLaunchModeType.platformDefault:
      return LaunchMode.platformDefault;
  }
}
