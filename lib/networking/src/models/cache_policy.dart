/// Cache policy for API requests.
///
/// Defines how the networking layer should handle caching for requests.
///
/// Example:
/// ```dart
/// await api.network<User>(
///   request: (r) => r.get('/user'),
///   cachePolicy: CachePolicy.cacheFirst,
///   cacheKey: 'user_profile',
///   cacheDuration: Duration(hours: 1),
/// );
/// ```
enum CachePolicy {
  /// Always fetch from network, ignore cache.
  /// This is the default behavior.
  networkOnly,

  /// Try cache first, fallback to network if cache is empty or expired.
  /// Best for data that doesn't change often.
  cacheFirst,

  /// Try network first, fallback to cache if network fails.
  /// Best for data that should be fresh when possible.
  networkFirst,

  /// Only use cache, never make network request.
  /// Throws error if cache is empty.
  cacheOnly,

  /// Return cached data immediately (if available), then fetch from network
  /// and update the cache in the background.
  /// The callback will only receive the initial cached data.
  /// Best for UI that needs immediate response but should stay updated.
  staleWhileRevalidate,
}

/// Extension methods for [CachePolicy].
extension CachePolicyExtension on CachePolicy {
  /// Whether this policy should try cache first.
  bool get shouldTryCacheFirst =>
      this == CachePolicy.cacheFirst ||
      this == CachePolicy.cacheOnly ||
      this == CachePolicy.staleWhileRevalidate;

  /// Whether this policy should try network.
  bool get shouldTryNetwork => this != CachePolicy.cacheOnly;

  /// Whether this policy should fallback to cache on network failure.
  bool get shouldFallbackToCache => this == CachePolicy.networkFirst;

  /// Whether this policy should fallback to network on cache miss.
  bool get shouldFallbackToNetwork => this == CachePolicy.cacheFirst;

  /// Whether this policy should revalidate in the background.
  bool get shouldRevalidateInBackground =>
      this == CachePolicy.staleWhileRevalidate;

  /// Human-readable description of the policy.
  String get description {
    switch (this) {
      case CachePolicy.networkOnly:
        return 'Always fetch from network';
      case CachePolicy.cacheFirst:
        return 'Try cache first, fallback to network';
      case CachePolicy.networkFirst:
        return 'Try network first, fallback to cache';
      case CachePolicy.cacheOnly:
        return 'Only use cache, no network';
      case CachePolicy.staleWhileRevalidate:
        return 'Return cache immediately, update in background';
    }
  }
}
