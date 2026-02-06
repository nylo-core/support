import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/networking/src/models/default_response.dart';
import 'package:nylo_support/testing/ny_testing.dart';

/// Test model for decoding
class TestUser {
  final int id;
  final String name;
  final String email;

  TestUser({required this.id, required this.name, required this.email});

  factory TestUser.fromJson(Map<String, dynamic> json) {
    return TestUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}

/// Test model for list decoding
class TestPost {
  final int id;
  final String title;

  TestPost({required this.id, required this.title});

  factory TestPost.fromJson(Map<String, dynamic> json) {
    return TestPost(id: json['id'] as int, title: json['title'] as String);
  }
}

void main() {
  NyTest.init();

  // Test decoders
  final Map<Type, dynamic> testDecoders = {
    TestUser: (data) => TestUser.fromJson(data),
    TestPost: (data) => TestPost.fromJson(data),
    List<TestPost>: (data) =>
        (data as List).map((e) => TestPost.fromJson(e)).toList(),
  };

  nyGroup('DefaultResponse', () {
    nyGroup('constructor', () {
      nyTest('creates with data parameter', () async {
        final response = DefaultResponse<String>(data: 'test data');

        expect(response.data, 'test data');
      });

      nyTest('creates with null data', () async {
        final response = DefaultResponse<String?>(data: null);

        expect(response.data, isNull);
      });

      nyTest('creates with complex data type', () async {
        final user = TestUser(id: 1, name: 'John', email: 'john@test.com');
        final response = DefaultResponse<TestUser>(data: user);

        expect(response.data, isA<TestUser>());
        expect(response.data?.id, 1);
        expect(response.data?.name, 'John');
      });

      nyTest('creates with list data type', () async {
        final posts = [
          TestPost(id: 1, title: 'Post 1'),
          TestPost(id: 2, title: 'Post 2'),
        ];
        final response = DefaultResponse<List<TestPost>>(data: posts);

        expect(response.data, isA<List<TestPost>>());
        expect(response.data?.length, 2);
      });
    });

    nyGroup('fromJson', () {
      nyTest('decodes JSON to model using decoder', () async {
        final json = {'id': 1, 'name': 'Jane', 'email': 'jane@test.com'};

        final response = DefaultResponse<TestUser>.fromJson(
          json,
          testDecoders,
          type: TestUser,
        );

        expect(response.data, isA<TestUser>());
        expect(response.data?.id, 1);
        expect(response.data?.name, 'Jane');
        expect(response.data?.email, 'jane@test.com');
      });

      nyTest('handles null decoder result', () async {
        final decoders = {TestUser: (data) => null};

        final response = DefaultResponse<TestUser>.fromJson(
          {'id': 1},
          decoders,
          type: TestUser,
        );

        expect(response.data, isNull);
      });

      nyTest('decodes list from JSON', () async {
        final json = [
          {'id': 1, 'title': 'First Post'},
          {'id': 2, 'title': 'Second Post'},
        ];

        final response = DefaultResponse<List<TestPost>>.fromJson(
          json,
          testDecoders,
          type: List<TestPost>,
        );

        expect(response.data, isA<List<TestPost>>());
        expect(response.data?.length, 2);
        expect(response.data?[0].title, 'First Post');
        expect(response.data?[1].title, 'Second Post');
      });

      nyTest('throws assertion error when decoder is missing', () async {
        final json = {'id': 1, 'name': 'Test'};

        expect(
          () => DefaultResponse<TestUser>.fromJson(
            json,
            {}, // empty decoders
            type: TestUser,
          ),
          throwsA(isA<StateError>()),
        );
      });
    });

    nyGroup('generic type support', () {
      nyTest('works with primitive types', () async {
        final stringResponse = DefaultResponse<String>(data: 'hello');
        final intResponse = DefaultResponse<int>(data: 42);
        final boolResponse = DefaultResponse<bool>(data: true);

        expect(stringResponse.data, 'hello');
        expect(intResponse.data, 42);
        expect(boolResponse.data, true);
      });

      nyTest('works with Map type', () async {
        final mapData = {'key': 'value', 'count': 5};
        final response = DefaultResponse<Map<String, dynamic>>(data: mapData);

        expect(response.data, isA<Map<String, dynamic>>());
        expect(response.data?['key'], 'value');
        expect(response.data?['count'], 5);
      });

      nyTest('works with dynamic type', () async {
        final response = DefaultResponse<dynamic>(data: [1, 'two', 3.0]);

        expect(response.data, isA<List>());
        expect(response.data.length, 3);
      });
    });
  });
}
