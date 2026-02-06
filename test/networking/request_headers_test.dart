import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/networking/src/dio_api_service.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('NyRequestHeaders extension', () {
    nyGroup('addBearerToken', () {
      nyTest('adds Authorization header with Bearer prefix', () async {
        final headers = <String, dynamic>{};

        headers.addBearerToken('my-secret-token');

        expect(headers['Authorization'], 'Bearer my-secret-token');
      });

      nyTest('overwrites existing Authorization header', () async {
        final headers = <String, dynamic>{'Authorization': 'Bearer old-token'};

        headers.addBearerToken('new-token');

        expect(headers['Authorization'], 'Bearer new-token');
      });

      nyTest('returns the modified map', () async {
        final headers = <String, dynamic>{};

        final result = headers.addBearerToken('token');

        expect(result, same(headers));
        expect(result['Authorization'], 'Bearer token');
      });

      nyTest('preserves other headers', () async {
        final headers = <String, dynamic>{
          'Content-Type': 'application/json',
          'X-Custom': 'value',
        };

        headers.addBearerToken('token');

        expect(headers['Content-Type'], 'application/json');
        expect(headers['X-Custom'], 'value');
        expect(headers['Authorization'], 'Bearer token');
      });
    });

    nyGroup('getBearerToken', () {
      nyTest('returns token without Bearer prefix', () async {
        final headers = <String, dynamic>{
          'Authorization': 'Bearer my-token-123',
        };

        final token = headers.getBearerToken();

        expect(token, 'my-token-123');
      });

      nyTest('returns null when no Authorization header', () async {
        final headers = <String, dynamic>{'Content-Type': 'application/json'};

        final token = headers.getBearerToken();

        expect(token, isNull);
      });

      nyTest('returns null when Authorization is null', () async {
        final headers = <String, dynamic>{'Authorization': null};

        final token = headers.getBearerToken();

        expect(token, isNull);
      });

      nyTest('handles non-Bearer authorization', () async {
        final headers = <String, dynamic>{'Authorization': 'Basic abc123'};

        final token = headers.getBearerToken();

        // Removes "Bearer " prefix even if it's Basic auth
        expect(token, 'Basic abc123');
      });
    });

    nyGroup('addHeader', () {
      nyTest('adds a new header', () async {
        final headers = <String, dynamic>{};

        headers.addHeader('X-API-Key', 'secret-key');

        expect(headers['X-API-Key'], 'secret-key');
      });

      nyTest('adds multiple headers with chaining', () async {
        final headers = <String, dynamic>{};

        headers
            .addHeader('X-API-Key', 'key1')
            .addHeader('X-Request-ID', 'req-123')
            .addHeader('Accept-Language', 'en');

        expect(headers['X-API-Key'], 'key1');
        expect(headers['X-Request-ID'], 'req-123');
        expect(headers['Accept-Language'], 'en');
      });

      nyTest('overwrites existing header', () async {
        final headers = <String, dynamic>{'X-Custom': 'old-value'};

        headers.addHeader('X-Custom', 'new-value');

        expect(headers['X-Custom'], 'new-value');
      });

      nyTest('handles different value types', () async {
        final headers = <String, dynamic>{};

        headers.addHeader('String-Header', 'string value');
        headers.addHeader('Int-Header', 42);
        headers.addHeader('Bool-Header', true);
        headers.addHeader('List-Header', ['a', 'b']);

        expect(headers['String-Header'], 'string value');
        expect(headers['Int-Header'], 42);
        expect(headers['Bool-Header'], true);
        expect(headers['List-Header'], ['a', 'b']);
      });

      nyTest('returns the modified map', () async {
        final headers = <String, dynamic>{};

        final result = headers.addHeader('key', 'value');

        expect(result, same(headers));
      });
    });

    nyGroup('hasHeader', () {
      nyTest('returns true when header exists', () async {
        final headers = <String, dynamic>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer token',
        };

        expect(headers.hasHeader('Content-Type'), isTrue);
        expect(headers.hasHeader('Authorization'), isTrue);
      });

      nyTest('returns false when header does not exist', () async {
        final headers = <String, dynamic>{'Content-Type': 'application/json'};

        expect(headers.hasHeader('Authorization'), isFalse);
        expect(headers.hasHeader('X-Custom'), isFalse);
      });

      nyTest('is case-sensitive', () async {
        final headers = <String, dynamic>{'Content-Type': 'application/json'};

        expect(headers.hasHeader('Content-Type'), isTrue);
        expect(headers.hasHeader('content-type'), isFalse);
        expect(headers.hasHeader('CONTENT-TYPE'), isFalse);
      });

      nyTest('returns true even when value is null', () async {
        final headers = <String, dynamic>{'X-Nullable': null};

        expect(headers.hasHeader('X-Nullable'), isTrue);
      });
    });

    nyGroup('chaining operations', () {
      nyTest('can chain multiple operations', () async {
        final headers = <String, dynamic>{};

        headers
            .addBearerToken('my-token')
            .addHeader('Content-Type', 'application/json')
            .addHeader('Accept', 'application/json')
            .addHeader('X-Request-ID', 'req-001');

        expect(headers.hasHeader('Authorization'), isTrue);
        expect(headers.hasHeader('Content-Type'), isTrue);
        expect(headers.hasHeader('Accept'), isTrue);
        expect(headers.hasHeader('X-Request-ID'), isTrue);
        expect(headers.getBearerToken(), 'my-token');
      });
    });

    nyGroup('edge cases', () {
      nyTest('handles empty token', () async {
        final headers = <String, dynamic>{};

        headers.addBearerToken('');

        expect(headers['Authorization'], 'Bearer ');
        expect(headers.getBearerToken(), '');
      });

      nyTest('handles token with spaces', () async {
        final headers = <String, dynamic>{};

        headers.addBearerToken('token with spaces');

        expect(headers['Authorization'], 'Bearer token with spaces');
        expect(headers.getBearerToken(), 'token with spaces');
      });

      nyTest('handles special characters in token', () async {
        final headers = <String, dynamic>{};
        final specialToken = 'abc123!@#\$%^&*()_+-=[]{}|;:,.<>?';

        headers.addBearerToken(specialToken);

        expect(headers.getBearerToken(), specialToken);
      });

      nyTest('handles empty header key', () async {
        final headers = <String, dynamic>{};

        headers.addHeader('', 'value');

        expect(headers[''], 'value');
        expect(headers.hasHeader(''), isTrue);
      });
    });
  });
}
