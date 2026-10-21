import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/networking/ny_networking.dart';
import 'package:nylo_support/testing/ny_testing.dart';

/// A model with the `fromJson(dynamic)` style Nylo generates.
class User {
  User.fromJson(dynamic json) : name = json['name'] as String;

  final String name;
}

/// A model with the `fromJson(Map<String, dynamic>)` style that
/// json_serializable and freezed generate.
class Product {
  Product.fromJson(Map<String, dynamic> json) : title = json['title'] as String;

  final String title;
}

class Order {
  Order.fromJson(dynamic json) : id = json['id'] as int;

  final int id;
}

class Tag {
  Tag.fromJson(dynamic json) : label = json['label'] as String;

  final String label;
}

final Map<Type, dynamic> appDecoders = {
  ...decoders([
    Decode(User.fromJson),
    Decode(Product.fromJson),
    Decode(Order.fromJson, from: 'data'),
  ]),
  // An old-style entry next to the new ones
  Tag: (data) => Tag.fromJson(data),
};

class DecodeApiService extends DioApiService {
  DecodeApiService() : super();

  @override
  String get baseUrl => 'https://api.example.com';

  @override
  Map<Type, dynamic>? get decoders => appDecoders;

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

  late DecodeApiService api;

  nySetUp(() {
    api = DecodeApiService();
    // NyLogger reads APP_DEBUG when a failed request is logged
    NyEnvRegistry.register(
      getter: (String key, {dynamic defaultValue}) =>
          {'APP_DEBUG': false}[key] ?? defaultValue,
    );
  });

  nyGroup('Decode', () {
    nyTest('takes its type from the constructor', () async {
      expect(Decode(User.fromJson).type, User);
      expect(Decode(Product.fromJson).type, Product);
      expect(Decode(User.fromJson).listType, List<User>);
    });

    nyTest('takes a closure with a typed parameter', () async {
      final Decode<User> decode = Decode((dynamic json) => User.fromJson(json));

      expect(decode.type, User);
    });
  });

  nyGroup('decoders()', () {
    nyTest('keys each entry by the type it builds', () async {
      final Map<Type, dynamic> map = decoders([
        Decode(User.fromJson),
        OneOf<Object>.byKey('type', {}),
      ]);

      expect(map.keys, [User, Object]);
    });

    nyTest('rejects an entry that is not a decoder', () async {
      expect(
        () => decoders([(dynamic data) => User.fromJson(data)]),
        throwsArgumentError,
      );
    });
  });

  nyGroup('Decode in a request', () {
    nyTest('decodes a model', () async {
      final NyResponse<User> response = await api.respond<User>(200, {
        'name': 'Ada',
      });

      expect(response.data?.name, 'Ada');
    });

    nyTest('decodes a fromJson(Map<String, dynamic>) model', () async {
      final NyResponse<Product> response = await api.respond<Product>(200, {
        'title': 'Lamp',
      });

      expect(response.data?.title, 'Lamp');
    });

    nyTest('decodes a List<T> with no list entry', () async {
      final NyResponse<List<User>> response = await api.respond<List<User>>(
        200,
        [
          {'name': 'Ada'},
          {'name': 'Lin'},
        ],
      );

      final List<User>? users = response.data;
      expect(users?.map((user) => user.name), ['Ada', 'Lin']);
    });

    nyTest('reads the model from inside the body with from:', () async {
      final NyResponse<Order> response = await api.respond<Order>(200, {
        'data': {'id': 42},
      });

      expect(response.data?.id, 42);
    });

    nyTest('reads a list from inside the body with from:', () async {
      final NyResponse<List<Order>> response = await api.respond<List<Order>>(
        200,
        {
          'data': [
            {'id': 1},
            {'id': 2},
          ],
          'meta': {'page': 1},
        },
      );

      expect(response.data?.map((order) => order.id), [1, 2]);
    });

    nyTest('reads a nested key with from:', () async {
      final DefaultResponse<User> decoded = DefaultResponse<User>.fromJson(
        {
          'data': {
            'user': {'name': 'Ada'},
          },
        },
        decoders([Decode(User.fromJson, from: 'data.user')]),
        type: User,
      );

      expect(decoded.data?.name, 'Ada');
    });

    nyTest('does not decode a 4xx body', () async {
      final NyResponse<User> response = await api.respond<User>(422, {
        'message': 'Invalid',
      });

      expect(response.statusCode, 422);
      expect(response.data, isNull);
    });

    nyTest('works next to an old-style closure entry', () async {
      final NyResponse<Tag> response = await api.respond<Tag>(200, {
        'label': 'new',
      });

      expect(response.data?.label, 'new');
    });
  });

  nyGroup('built-in JSON decoders', () {
    nyTest('decode Map<String, dynamic> with no entry', () async {
      final NyResponse<Map<String, dynamic>> response = await api
          .respond<Map<String, dynamic>>(200, {'ok': true});

      expect(response.data, {'ok': true});
    });

    nyTest('decode List<Map<String, dynamic>> with no entry', () async {
      final NyResponse<List<Map<String, dynamic>>> response = await api
          .respond<List<Map<String, dynamic>>>(200, [
            {'a': 1},
          ]);

      expect(response.data, [
        {'a': 1},
      ]);
    });

    nyTest('decode primitives', () async {
      final Map<Type, dynamic> none = {};

      expect(DefaultResponse<double>.fromJson(3, none, type: double).data, 3.0);
      expect(DefaultResponse<int>.fromJson(3, none, type: int).data, 3);
      expect(
        DefaultResponse<bool>.fromJson(true, none, type: bool).data,
        isTrue,
      );
      expect(
        DefaultResponse<String>.fromJson('hi', none, type: String).data,
        'hi',
      );
    });

    nyTest('give way to an app entry for the same type', () async {
      final DefaultResponse<Map<String, dynamic>> decoded =
          DefaultResponse<Map<String, dynamic>>.fromJson(
            {'a': 1},
            {
              Map<String, dynamic>: (data) => <String, dynamic>{'custom': true},
            },
            type: Map<String, dynamic>,
          );

      expect(decoded.data, {'custom': true});
    });
  });

  nyGroup('dataToModel', () {
    nyTest('decodes a Decode list from storage-style data', () async {
      final List<User> users = dataToModel<List<User>>(
        data: [
          {'name': 'Ada'},
        ],
        modelDecoders: appDecoders,
      );

      expect(users.single.name, 'Ada');
    });
  });
}
