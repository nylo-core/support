import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/networking/ny_networking.dart';
import 'package:nylo_support/testing/ny_testing.dart';

class ApiError {
  ApiError.fromJson(dynamic json) : message = json['message'] as String?;

  final String? message;
}

sealed class LoginResult {}

final class LoginSuccess extends LoginResult {
  LoginSuccess.fromJson(dynamic json) : token = json['token'] as String;

  final String token;
}

final class TwoFactorRequired extends LoginResult {
  TwoFactorRequired.fromJson(dynamic json) : method = json['method'] as String;

  final String method;
}

final class ValidationError extends LoginResult {
  ValidationError.fromJson(dynamic json)
    : errors = Map<String, dynamic>.from(json['errors'] as Map);

  final Map<String, dynamic> errors;
}

final class LoginFailed extends LoginResult {
  LoginFailed(this.error);

  final ApiError error;
}

sealed class FeedItem {}

final class PostItem extends FeedItem {
  PostItem.fromJson(dynamic json) : id = json['id'] as int;

  final int id;
}

final class AdItem extends FeedItem {
  AdItem.fromJson(dynamic json) : id = json['id'] as int;

  final int id;
}

class User {
  User.fromJson(dynamic json) : name = json['name'] as String;

  final String name;
}

/// A response with [statusCode] and [headers], for calling `resolve` directly.
NyResponse<dynamic> responseWith(
  int statusCode, {
  Map<String, List<String>> headers = const {},
}) {
  return NyResponse<dynamic>(
    response: Response(
      requestOptions: RequestOptions(path: '/test'),
      statusCode: statusCode,
      headers: Headers.fromMap(headers),
    ),
    data: null,
    rawData: null,
  );
}

class OneOfApiService extends DioApiService {
  OneOfApiService() : super();

  @override
  String get baseUrl => 'https://api.example.com';

  @override
  Map<Type, dynamic>? get decoders => {
    LoginResult: OneOf<LoginResult>.byStatus({
      200: LoginSuccess.fromJson,
      202: TwoFactorRequired.fromJson,
      422: ValidationError.fromJson,
    }),
    FeedItem: OneOf<FeedItem>.byKey('type', {
      'post': PostItem.fromJson,
      'ad': AdItem.fromJson,
    }),
    User: (data) => User.fromJson(data),
  };

  /// Sends a request that the server answers with [statusCode] and [body].
  Future<NyResponse<T>> respond<T>(int statusCode, Object body) {
    return networkResponse<T>(
      request: (Dio dio) {
        dio.httpClientAdapter = _FakeAdapter(statusCode, body);
        return dio.get('/test');
      },
      shouldRetry: false,
    );
  }
}

/// Answers every request with [statusCode] and a JSON [body].
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.statusCode, this.body);

  final int statusCode;
  final Object body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  NyTest.init();

  late OneOfApiService api;

  nySetUp(() {
    api = OneOfApiService();
    // NyLogger reads APP_DEBUG when a failed request is logged
    NyEnvRegistry.register(
      getter: (String key, {dynamic defaultValue}) =>
          {'APP_DEBUG': false}[key] ?? defaultValue,
    );
  });

  nyGroup('OneOf.byKey', () {
    final OneOf<LoginResult> login = OneOf<LoginResult>.byKey('status', {
      'success': LoginSuccess.fromJson,
      'two_factor': TwoFactorRequired.fromJson,
    }, otherwise: (json) => LoginFailed(ApiError.fromJson(json)));

    nyTest('builds the shape for the field value', () async {
      final LoginResult? result = login.resolve({
        'status': 'two_factor',
        'method': 'authenticator',
      }, responseWith(200));

      expect(result, isA<TwoFactorRequired>());
      if (result is TwoFactorRequired) {
        expect(result.method, 'authenticator');
      }
    });

    nyTest('uses otherwise for an unknown value', () async {
      final LoginResult? result = login.resolve({
        'status': 'locked',
        'message': 'Too many attempts',
      }, responseWith(200));

      expect(result, isA<LoginFailed>());
      if (result is LoginFailed) {
        expect(result.error.message, 'Too many attempts');
      }
    });

    nyTest('returns null for an unknown value without otherwise', () async {
      final OneOf<FeedItem> feed = OneOf<FeedItem>.byKey('type', {
        'post': PostItem.fromJson,
      });

      expect(
        feed.resolve({'type': 'video', 'id': 1}, responseWith(200)),
        isNull,
      );
      expect(feed.resolve('not a map', responseWith(200)), isNull);
    });

    nyTest('reads a nested field with a dotted key', () async {
      final OneOf<FeedItem> feed = OneOf<FeedItem>.byKey('data.type', {
        'post': (json) => PostItem.fromJson(json['data']),
        'ad': (json) => AdItem.fromJson(json['data']),
      });

      final FeedItem? item = feed.resolve({
        'data': {'type': 'ad', 'id': 7},
      }, responseWith(200));

      expect(item, isA<AdItem>());
      expect(feed.resolve({'data': 'post'}, responseWith(200)), isNull);
    });

    nyTest('prefers a field named exactly like the dotted key', () async {
      final OneOf<FeedItem> feed = OneOf<FeedItem>.byKey('data.type', {
        'post': (json) => PostItem.fromJson({'id': 1}),
        'ad': (json) => AdItem.fromJson({'id': 2}),
      });

      final FeedItem? item = feed.resolve({
        'data.type': 'post',
        'data': {'type': 'ad'},
      }, responseWith(200));

      expect(item, isA<PostItem>());
    });
  });

  nyGroup('OneOf.byStatus', () {
    final OneOf<LoginResult> login = OneOf<LoginResult>.byStatus({
      200: LoginSuccess.fromJson,
      422: ValidationError.fromJson,
      '40x': (json) => LoginFailed(ApiError.fromJson({'message': '40x'})),
      '4xx': (json) => LoginFailed(ApiError.fromJson({'message': '4xx'})),
    });

    nyTest('builds the shape for an exact status code', () async {
      expect(
        login.resolve({'token': 'abc'}, responseWith(200)),
        isA<LoginSuccess>(),
      );
      expect(
        login.resolve({'errors': {}}, responseWith(422)),
        isA<ValidationError>(),
      );
    });

    nyTest('matches a pattern, preferring the most specific', () async {
      final LoginResult? notFound = login.resolve({}, responseWith(404));
      final LoginResult? conflict = login.resolve({}, responseWith(409));
      final LoginResult? teapot = login.resolve({}, responseWith(418));

      expect((notFound as LoginFailed).error.message, '40x');
      expect((conflict as LoginFailed).error.message, '40x');
      expect((teapot as LoginFailed).error.message, '4xx');
    });

    nyTest('returns null for an unmatched status', () async {
      expect(login.resolve({}, responseWith(500)), isNull);
    });

    nyTest('uses otherwise for an unmatched status', () async {
      final OneOf<LoginResult> withFallback = OneOf<LoginResult>.byStatus({
        200: LoginSuccess.fromJson,
      }, otherwise: (json) => LoginFailed(ApiError.fromJson(json)));

      expect(
        withFallback.resolve({'message': 'Down'}, responseWith(503)),
        isA<LoginFailed>(),
      );
    });

    nyTest('rejects a key that is not a status code or pattern', () async {
      expect(
        () => OneOf<LoginResult>.byStatus({'4??': LoginSuccess.fromJson}),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  nyGroup('OneOf.byJson', () {
    nyTest('uses the first condition that matches', () async {
      final OneOf<LoginResult> login = OneOf<LoginResult>.byJson({
        (json, response) => json['token'] != null: LoginSuccess.fromJson,
        (json, response) => response.statusCode == 200:
            TwoFactorRequired.fromJson,
      });

      expect(
        login.resolve({'token': 'abc', 'method': 'sms'}, responseWith(200)),
        isA<LoginSuccess>(),
      );
      expect(
        login.resolve({'method': 'sms'}, responseWith(200)),
        isA<TwoFactorRequired>(),
      );
      expect(login.resolve({'method': 'sms'}, responseWith(500)), isNull);
    });

    nyTest('can read the response headers', () async {
      final OneOf<LoginResult> login = OneOf<LoginResult>.byJson({
        (json, response) => response.getHeader('x-two-factor') == 'true':
            TwoFactorRequired.fromJson,
      }, otherwise: LoginSuccess.fromJson);

      expect(
        login.resolve(
          {'method': 'email', 'token': 'abc'},
          responseWith(
            200,
            headers: {
              'x-two-factor': ['true'],
            },
          ),
        ),
        isA<TwoFactorRequired>(),
      );
      expect(
        login.resolve({'token': 'abc'}, responseWith(200)),
        isA<LoginSuccess>(),
      );
    });
  });

  nyGroup('OneOf', () {
    nyTest('builds the value its function returns', () async {
      final OneOf<LoginResult> login = OneOf<LoginResult>(
        (json, response) => switch ((response.statusCode, json)) {
          (200, {'token': String _}) => LoginSuccess.fromJson(json),
          (422, _) => ValidationError.fromJson(json),
          _ => null,
        },
      );

      expect(
        login.resolve({'token': 'abc'}, responseWith(200)),
        isA<LoginSuccess>(),
      );
      expect(
        login.resolve({'errors': {}}, responseWith(422)),
        isA<ValidationError>(),
      );
      expect(login.resolve({}, responseWith(200)), isNull);
    });

    nyTest('decodes with DefaultResponse when no response is given', () async {
      final DefaultResponse<FeedItem> decoded =
          DefaultResponse<FeedItem>.fromJson(
            {'type': 'post', 'id': 3},
            api.decoders!,
            type: FeedItem,
          );

      expect(decoded.data, isA<PostItem>());
    });
  });

  nyGroup('OneOf in a request', () {
    nyTest('decodes a 2xx body', () async {
      final NyResponse<LoginResult> response = await api.respond<LoginResult>(
        200,
        {'token': 'abc'},
      );

      expect(response.dataAs<LoginSuccess>()?.token, 'abc');
    });

    nyTest('decodes a 4xx body', () async {
      final NyResponse<LoginResult> response = await api.respond<LoginResult>(
        422,
        {
          'errors': {
            'email': ['taken'],
          },
        },
      );

      expect(response.statusCode, 422);
      expect(response.dataAs<ValidationError>()?.errors, {
        'email': ['taken'],
      });
    });

    nyTest('returns null data for a status it does not know', () async {
      final NyResponse<LoginResult> response = await api.respond<LoginResult>(
        500,
        {'message': 'Server error'},
      );

      expect(response.statusCode, 500);
      expect(response.data, isNull);
    });

    nyTest('passes the decoded error body to handleFailure', () async {
      NyResponse<LoginResult>? failed;

      await api.networkResponse<LoginResult>(
        request: (Dio dio) {
          dio.httpClientAdapter = _FakeAdapter(422, {'errors': {}});
          return dio.get('/test');
        },
        shouldRetry: false,
        handleFailure: (response) {
          failed = response;
        },
      );

      expect(failed?.data, isA<ValidationError>());
    });

    nyTest('decodes a List<T> item by item without a list entry', () async {
      final NyResponse<List<FeedItem>> response = await api
          .respond<List<FeedItem>>(200, [
            {'type': 'post', 'id': 1},
            {'type': 'ad', 'id': 2},
            {'type': 'unknown', 'id': 3},
          ]);

      final List<FeedItem>? feed = response.data;
      expect(feed, hasLength(2));
      expect(feed?[0], isA<PostItem>());
      expect(feed?[1], isA<AdItem>());
    });
  });

  nyGroup('closure decoders', () {
    nyTest('still get no data on a 4xx response', () async {
      final NyResponse<User> response = await api.respond<User>(422, {
        'name': 'not a user',
      });

      expect(response.statusCode, 422);
      expect(response.data, isNull);
    });

    nyTest('still decode a 200 response', () async {
      final NyResponse<User> response = await api.respond<User>(200, {
        'name': 'Ada',
      });

      expect(response.data?.name, 'Ada');
    });
  });

  nyGroup('NyResponse.dataAs / dataIs', () {
    nyTest('return the data only when it is the asked-for type', () async {
      final NyResponse<LoginResult> response = await api.respond<LoginResult>(
        202,
        {'method': 'email'},
      );

      expect(response.dataIs<TwoFactorRequired>(), isTrue);
      expect(response.dataIs<LoginSuccess>(), isFalse);
      expect(response.dataAs<TwoFactorRequired>()?.method, 'email');
      expect(response.dataAs<LoginSuccess>(), isNull);
    });
  });
}
