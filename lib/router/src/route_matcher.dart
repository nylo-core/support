import 'models/nyrouter_route.dart';

/// The RouteMatcher class is used to match the route with the registered routes.
class RouteMatcher {
  final String path;

  RouteMatcher(this.path);

  /// Find matching route and extract parameters
  RouteMatch? findMatch(Map<String, NyRouterRoute> routeMappings) {
    // Normalize the input path but keep leading slash
    final normalizedPath = _normalizePath(path);
    final pathSegments = normalizedPath.split('/');

    // Try each registered route
    for (final entry in routeMappings.entries) {
      final routePattern = _normalizePath(entry.key);
      final route = entry.value;
      final patternSegments = routePattern.split('/');

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
          route: route,
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
  String _normalizePath(String input) {
    // Trim whitespace
    input = input.trim();

    // Ensure single leading slash
    input = '/${input.replaceFirst(RegExp(r'^/+'), '')}';

    // Remove trailing slash if present (unless it's just '/')
    if (input.length > 1) {
      input = input.replaceAll(RegExp(r'/+$'), '');
    }

    // Replace multiple slashes with single slash
    input = input.replaceAll(RegExp(r'/+'), '/');

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
