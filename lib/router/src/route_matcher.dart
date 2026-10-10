import 'models/nyrouter_route.dart';

/// The RouteMatcher class is used to match the route with the registered routes.
class RouteMatcher {
  final String path;

  RouteMatcher(this.path);

  static final RegExp _leadingSlashes = RegExp(r'^/+');
  static final RegExp _trailingSlashes = RegExp(r'/+$');
  static final RegExp _repeatedSlashes = RegExp(r'/+');

  /// Compiled route patterns, keyed by the pattern exactly as registered.
  ///
  /// Normalising and splitting a pattern is a pure function of the pattern
  /// string, so each distinct pattern is compiled once and reused across
  /// every navigation.
  static final Map<String, List<String>> _compiledPatterns = {};

  /// Compile [pattern] ahead of time so the first navigation pays nothing.
  ///
  /// Called by [NyRouter] when a route is registered or updated.
  static void precompile(String pattern) {
    _segmentsFor(pattern);
  }

  /// Returns the normalised segments for [pattern], compiling on first use.
  static List<String> _segmentsFor(String pattern) {
    return _compiledPatterns.putIfAbsent(
      pattern,
      () => List<String>.unmodifiable(_normalizePath(pattern).split('/')),
    );
  }

  /// Find matching route and extract parameters
  RouteMatch? findMatch(Map<String, NyRouterRoute> routeMappings) {
    // Normalize the input path but keep leading slash
    final normalizedPath = _normalizePath(path);
    final pathSegments = normalizedPath.split('/');

    // Try each registered route
    for (final entry in routeMappings.entries) {
      final patternSegments = _segmentsFor(entry.key);

      // Quick check for segment count (including empty segments from leading slash)
      if (pathSegments.length != patternSegments.length) {
        continue;
      }

      final params = <String, String>{};
      var isMatch = true;

      // Check each segment
      for (var i = 0; i < patternSegments.length; i++) {
        final patternSegment = patternSegments[i];
        final pathSegment = pathSegments[i];

        // Skip empty segments from leading slash
        if (patternSegment.isEmpty && pathSegment.isEmpty) {
          continue;
        }

        if (patternSegment.startsWith('{') && patternSegment.endsWith('}')) {
          // Extract parameter
          final paramName = patternSegment.substring(
            1,
            patternSegment.length - 1,
          );
          params[paramName] = pathSegment;
        } else if (patternSegment != pathSegment) {
          // Static segment doesn't match
          isMatch = false;
          break;
        }
      }

      if (isMatch) {
        return RouteMatch(
          pattern: entry.key, // Keep original pattern
          route: entry.value,
          parameters: params,
        );
      }
    }

    return null;
  }

  /// Normalizes a path by:
  /// 1. Trimming whitespace
  /// 2. Ensuring single leading slash
  /// 3. Removing trailing slash
  /// 4. Replacing multiple slashes with single slash
  static String _normalizePath(String input) {
    // Trim whitespace
    input = input.trim();

    // Ensure single leading slash
    input = '/${input.replaceFirst(_leadingSlashes, '')}';

    // Remove trailing slash if present (unless it's just '/')
    if (input.length > 1) {
      input = input.replaceAll(_trailingSlashes, '');
    }

    // Replace multiple slashes with single slash
    input = input.replaceAll(_repeatedSlashes, '/');

    return input;
  }
}

/// Represents a matched route with its parameters.
class RouteMatch {
  final String pattern;
  final NyRouterRoute route;
  final Map<String, String> parameters;

  RouteMatch({
    required this.pattern,
    required this.route,
    required this.parameters,
  });

  @override
  String toString() => 'RouteMatch(pattern: $pattern, parameters: $parameters)';
}
