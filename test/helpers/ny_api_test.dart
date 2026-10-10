import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/testing/ny_testing.dart';

import '../core/mocks/mock_api_service.dart';

class _SingletonApiService extends MockApiService {}

class _UnregisteredApiService extends MockApiService {}

void main() {
  NyTest.init();
  NyEnvRegistry.register(getter: (key, {defaultValue}) => defaultValue);

  setUp(() {
    final Nylo nylo = Nylo();
    nylo.addApiDecoders({
      MockApiService: () => MockApiService(),
      _SingletonApiService: _SingletonApiService(),
    });
    Backpack.instance.save('nylo', nylo);
  });

  nyGroup('Nylo.hasApiDecoder', () {
    nyTest('is true for a registered factory', () async {
      expect(Nylo.hasApiDecoder<MockApiService>(), isTrue);
    });

    nyTest('is true for a registered singleton', () async {
      expect(Nylo.hasApiDecoder<_SingletonApiService>(), isTrue);
    });

    nyTest('is false for a class that is not registered', () async {
      expect(Nylo.hasApiDecoder<_UnregisteredApiService>(), isFalse);
    });
  });

  nyGroup('nyApi', () {
    nyTest('calls the request with the registered service', () async {
      final dynamic result = await nyApi<MockApiService>(
        request: (service) => service.baseUrl,
      );
      expect(result, 'https://api.example.com');
    });

    nyTest('uses a service passed in apiDecoders', () async {
      final _UnregisteredApiService service = _UnregisteredApiService();
      final dynamic result = await nyApi<_UnregisteredApiService>(
        request: (s) => identical(s, service),
        apiDecoders: {_UnregisteredApiService: service},
      );
      expect(result, isTrue);
    });

    nyTest('asserts when the class is missing from apiDecoders', () async {
      expect(
        () => nyApi<_UnregisteredApiService>(request: (service) => null),
        throwsA(
          isA<AssertionError>().having(
            (e) => e.message,
            'message',
            contains(
              'missing this class _UnregisteredApiService in apiDecoders',
            ),
          ),
        ),
      );
    });
  });
}
