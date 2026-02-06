import 'package:service_runner/service_runner.dart';

/// Mock service for testing the service lifecycle
class MockService extends Runnable {
  bool onInitCalled = false;
  bool onReadyCalled = false;
  bool onAppReadyCalled = false;
  bool shouldThrowOnInit = false;
  bool shouldThrowOnReady = false;
  bool shouldThrowOnAppReady = false;
  int initDelayMs = 0;

  @override
  Future<void> onInit() async {
    if (initDelayMs > 0) {
      await Future.delayed(Duration(milliseconds: initDelayMs));
    }
    if (shouldThrowOnInit) {
      throw Exception('onInit failed');
    }
    onInitCalled = true;
  }

  @override
  Future<void> onReady() async {
    if (shouldThrowOnReady) {
      throw Exception('onReady failed');
    }
    onReadyCalled = true;
  }

  @override
  Future<void> onAppReady() async {
    if (shouldThrowOnAppReady) {
      throw Exception('onAppReady failed');
    }
    onAppReadyCalled = true;
  }

  void reset() {
    onInitCalled = false;
    onReadyCalled = false;
    onAppReadyCalled = false;
    shouldThrowOnInit = false;
    shouldThrowOnReady = false;
    shouldThrowOnAppReady = false;
    initDelayMs = 0;
  }
}
