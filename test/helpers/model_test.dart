import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

class TestModel extends Model {
  String? name;
  String? email;

  TestModel({this.name, this.email, String? key}) : super(key: key);

  @override
  Map<String, dynamic> toJson() => {'name': name, 'email': email};
}

void main() {
  NyTest.init();

  nyGroup('Model', () {
    nyGroup('constructor', () {
      nyTest('should create with no key', () async {
        final model = TestModel();
        expect(model, isA<Model>());
      });

      nyTest('should create with a key', () async {
        final model = TestModel(key: 'test_key');
        expect(model, isA<Model>());
      });
    });

    nyGroup('toJson', () {
      nyTest('should return empty map for base Model', () async {
        final model = Model();
        expect(model.toJson(), isEmpty);
      });

      nyTest('should return populated map for subclass', () async {
        final model = TestModel(name: 'John', email: 'john@example.com');
        final json = model.toJson();
        expect(json['name'], 'John');
        expect(json['email'], 'john@example.com');
      });

      nyTest('should handle null values', () async {
        final model = TestModel();
        final json = model.toJson();
        expect(json['name'], isNull);
        expect(json['email'], isNull);
      });
    });

    nyGroup('runtimeType', () {
      nyTest('should return correct type for base Model', () async {
        final model = Model();
        expect(model.runtimeType.toString(), 'Model<dynamic>');
      });

      nyTest('should return correct type for subclass', () async {
        final model = TestModel();
        expect(model.runtimeType.toString(), 'TestModel');
      });
    });
  });
}
