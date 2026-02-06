import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/router/ny_router.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('NyArgument', () {
    nyGroup('constructor', () {
      nyTest('should create with null data', () async {
        final argument = NyArgument(null);

        expect(argument.data, isNull);
      });

      nyTest('should create with string data', () async {
        final argument = NyArgument('test string');

        expect(argument.data, 'test string');
      });

      nyTest('should create with int data', () async {
        final argument = NyArgument(42);

        expect(argument.data, 42);
      });

      nyTest('should create with Map data', () async {
        final data = {'id': 1, 'name': 'Test'};
        final argument = NyArgument(data);

        expect(argument.data, data);
        expect(argument.data['id'], 1);
        expect(argument.data['name'], 'Test');
      });

      nyTest('should create with List data', () async {
        final data = [1, 2, 3];
        final argument = NyArgument(data);

        expect(argument.data, data);
        expect(argument.data.length, 3);
      });

      nyTest('should create with custom object data', () async {
        final data = _TestModel(id: 1, name: 'Test');
        final argument = NyArgument(data);

        expect(argument.data, isA<_TestModel>());
        expect(argument.data.id, 1);
        expect(argument.data.name, 'Test');
      });
    });

    nyGroup('setData()', () {
      nyTest('should update data to new value', () async {
        final argument = NyArgument('initial');

        argument.setData('updated');

        expect(argument.data, 'updated');
      });

      nyTest('should update data to different type', () async {
        final argument = NyArgument('string');

        argument.setData(42);

        expect(argument.data, 42);
        expect(argument.data, isA<int>());
      });

      nyTest('should update data to null', () async {
        final argument = NyArgument('value');

        argument.setData(null);

        expect(argument.data, isNull);
      });

      nyTest('should update from null to value', () async {
        final argument = NyArgument(null);

        argument.setData({'key': 'value'});

        expect(argument.data, {'key': 'value'});
      });
    });

    nyGroup('data property', () {
      nyTest('should be readable', () async {
        final argument = NyArgument('test');

        expect(argument.data, 'test');
      });

      nyTest('should be writable', () async {
        final argument = NyArgument('initial');

        argument.data = 'modified';

        expect(argument.data, 'modified');
      });
    });
  });
}

class _TestModel {
  final int id;
  final String name;

  _TestModel({required this.id, required this.name});
}
