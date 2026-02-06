import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/networking/src/models/cache_policy.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('CachePolicy', () {
    nyGroup('enum values', () {
      nyTest('has all expected values', () async {
        expect(CachePolicy.values.length, 5);
        expect(CachePolicy.values, contains(CachePolicy.networkOnly));
        expect(CachePolicy.values, contains(CachePolicy.cacheFirst));
        expect(CachePolicy.values, contains(CachePolicy.networkFirst));
        expect(CachePolicy.values, contains(CachePolicy.cacheOnly));
        expect(CachePolicy.values, contains(CachePolicy.staleWhileRevalidate));
      });

      nyTest('networkOnly is the default/first policy', () async {
        expect(CachePolicy.networkOnly.index, 0);
      });
    });

    nyGroup('shouldTryCacheFirst', () {
      nyTest('returns true for cacheFirst', () async {
        expect(CachePolicy.cacheFirst.shouldTryCacheFirst, isTrue);
      });

      nyTest('returns true for cacheOnly', () async {
        expect(CachePolicy.cacheOnly.shouldTryCacheFirst, isTrue);
      });

      nyTest('returns true for staleWhileRevalidate', () async {
        expect(CachePolicy.staleWhileRevalidate.shouldTryCacheFirst, isTrue);
      });

      nyTest('returns false for networkOnly', () async {
        expect(CachePolicy.networkOnly.shouldTryCacheFirst, isFalse);
      });

      nyTest('returns false for networkFirst', () async {
        expect(CachePolicy.networkFirst.shouldTryCacheFirst, isFalse);
      });
    });

    nyGroup('shouldTryNetwork', () {
      nyTest('returns true for networkOnly', () async {
        expect(CachePolicy.networkOnly.shouldTryNetwork, isTrue);
      });

      nyTest('returns true for cacheFirst', () async {
        expect(CachePolicy.cacheFirst.shouldTryNetwork, isTrue);
      });

      nyTest('returns true for networkFirst', () async {
        expect(CachePolicy.networkFirst.shouldTryNetwork, isTrue);
      });

      nyTest('returns true for staleWhileRevalidate', () async {
        expect(CachePolicy.staleWhileRevalidate.shouldTryNetwork, isTrue);
      });

      nyTest('returns false for cacheOnly', () async {
        expect(CachePolicy.cacheOnly.shouldTryNetwork, isFalse);
      });
    });

    nyGroup('shouldFallbackToCache', () {
      nyTest('returns true for networkFirst', () async {
        expect(CachePolicy.networkFirst.shouldFallbackToCache, isTrue);
      });

      nyTest('returns false for networkOnly', () async {
        expect(CachePolicy.networkOnly.shouldFallbackToCache, isFalse);
      });

      nyTest('returns false for cacheFirst', () async {
        expect(CachePolicy.cacheFirst.shouldFallbackToCache, isFalse);
      });

      nyTest('returns false for cacheOnly', () async {
        expect(CachePolicy.cacheOnly.shouldFallbackToCache, isFalse);
      });

      nyTest('returns false for staleWhileRevalidate', () async {
        expect(CachePolicy.staleWhileRevalidate.shouldFallbackToCache, isFalse);
      });
    });

    nyGroup('shouldFallbackToNetwork', () {
      nyTest('returns true for cacheFirst', () async {
        expect(CachePolicy.cacheFirst.shouldFallbackToNetwork, isTrue);
      });

      nyTest('returns false for networkOnly', () async {
        expect(CachePolicy.networkOnly.shouldFallbackToNetwork, isFalse);
      });

      nyTest('returns false for networkFirst', () async {
        expect(CachePolicy.networkFirst.shouldFallbackToNetwork, isFalse);
      });

      nyTest('returns false for cacheOnly', () async {
        expect(CachePolicy.cacheOnly.shouldFallbackToNetwork, isFalse);
      });

      nyTest('returns false for staleWhileRevalidate', () async {
        expect(
          CachePolicy.staleWhileRevalidate.shouldFallbackToNetwork,
          isFalse,
        );
      });
    });

    nyGroup('shouldRevalidateInBackground', () {
      nyTest('returns true for staleWhileRevalidate', () async {
        expect(
          CachePolicy.staleWhileRevalidate.shouldRevalidateInBackground,
          isTrue,
        );
      });

      nyTest('returns false for networkOnly', () async {
        expect(CachePolicy.networkOnly.shouldRevalidateInBackground, isFalse);
      });

      nyTest('returns false for cacheFirst', () async {
        expect(CachePolicy.cacheFirst.shouldRevalidateInBackground, isFalse);
      });

      nyTest('returns false for networkFirst', () async {
        expect(CachePolicy.networkFirst.shouldRevalidateInBackground, isFalse);
      });

      nyTest('returns false for cacheOnly', () async {
        expect(CachePolicy.cacheOnly.shouldRevalidateInBackground, isFalse);
      });
    });

    nyGroup('description', () {
      nyTest('networkOnly has correct description', () async {
        expect(
          CachePolicy.networkOnly.description,
          'Always fetch from network',
        );
      });

      nyTest('cacheFirst has correct description', () async {
        expect(
          CachePolicy.cacheFirst.description,
          'Try cache first, fallback to network',
        );
      });

      nyTest('networkFirst has correct description', () async {
        expect(
          CachePolicy.networkFirst.description,
          'Try network first, fallback to cache',
        );
      });

      nyTest('cacheOnly has correct description', () async {
        expect(CachePolicy.cacheOnly.description, 'Only use cache, no network');
      });

      nyTest('staleWhileRevalidate has correct description', () async {
        expect(
          CachePolicy.staleWhileRevalidate.description,
          'Return cache immediately, update in background',
        );
      });
    });

    nyGroup('policy behavior combinations', () {
      nyTest('networkOnly: network only, no cache', () async {
        final policy = CachePolicy.networkOnly;

        expect(policy.shouldTryCacheFirst, isFalse);
        expect(policy.shouldTryNetwork, isTrue);
        expect(policy.shouldFallbackToCache, isFalse);
        expect(policy.shouldFallbackToNetwork, isFalse);
        expect(policy.shouldRevalidateInBackground, isFalse);
      });

      nyTest('cacheFirst: cache first, fallback to network', () async {
        final policy = CachePolicy.cacheFirst;

        expect(policy.shouldTryCacheFirst, isTrue);
        expect(policy.shouldTryNetwork, isTrue);
        expect(policy.shouldFallbackToCache, isFalse);
        expect(policy.shouldFallbackToNetwork, isTrue);
        expect(policy.shouldRevalidateInBackground, isFalse);
      });

      nyTest('networkFirst: network first, fallback to cache', () async {
        final policy = CachePolicy.networkFirst;

        expect(policy.shouldTryCacheFirst, isFalse);
        expect(policy.shouldTryNetwork, isTrue);
        expect(policy.shouldFallbackToCache, isTrue);
        expect(policy.shouldFallbackToNetwork, isFalse);
        expect(policy.shouldRevalidateInBackground, isFalse);
      });

      nyTest('cacheOnly: cache only, no network', () async {
        final policy = CachePolicy.cacheOnly;

        expect(policy.shouldTryCacheFirst, isTrue);
        expect(policy.shouldTryNetwork, isFalse);
        expect(policy.shouldFallbackToCache, isFalse);
        expect(policy.shouldFallbackToNetwork, isFalse);
        expect(policy.shouldRevalidateInBackground, isFalse);
      });

      nyTest(
        'staleWhileRevalidate: cache first with background refresh',
        () async {
          final policy = CachePolicy.staleWhileRevalidate;

          expect(policy.shouldTryCacheFirst, isTrue);
          expect(policy.shouldTryNetwork, isTrue);
          expect(policy.shouldFallbackToCache, isFalse);
          expect(policy.shouldFallbackToNetwork, isFalse);
          expect(policy.shouldRevalidateInBackground, isTrue);
        },
      );
    });
  });
}
