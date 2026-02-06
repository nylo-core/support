import 'package:nylo_support/networking/ny_networking.dart';

/// Mock API service for testing API decoder registration
class MockApiService extends NyApiService {
  static bool wasCalled = false;

  MockApiService() : super();

  @override
  String get baseUrl => 'https://api.example.com';

  static MockApiService create() {
    wasCalled = true;
    return MockApiService();
  }

  static void reset() {
    wasCalled = false;
  }
}
