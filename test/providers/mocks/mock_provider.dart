import 'package:nylo_support/providers/ny_providers.dart';
import 'package:nylo_support/nylo.dart';

/// Simple mock provider that tracks calls for testing
class MockProvider extends NyProvider {
  bool setupCalled = false;
  bool bootCalled = false;
  Nylo? receivedNylo;
  bool shouldThrow = false;
  int setupDelayMs = 0;

  @override
  Future<Nylo?> setup(Nylo nylo) async {
    if (setupDelayMs > 0) {
      await Future.delayed(Duration(milliseconds: setupDelayMs));
    }
    if (shouldThrow) {
      throw Exception('Setup failed');
    }
    setupCalled = true;
    receivedNylo = nylo;
    return nylo;
  }

  @override
  Future<void> boot(Nylo nylo) async {
    if (shouldThrow) {
      throw Exception('Boot failed');
    }
    bootCalled = true;
    receivedNylo = nylo;
  }

  void reset() {
    setupCalled = false;
    bootCalled = false;
    receivedNylo = null;
    shouldThrow = false;
    setupDelayMs = 0;
  }
}

/// Provider that returns null from setup
class NullReturningProvider extends NyProvider {
  bool setupCalled = false;
  bool bootCalled = false;

  @override
  Future<Nylo?> setup(Nylo nylo) async {
    setupCalled = true;
    return null;
  }

  @override
  Future<void> boot(Nylo nylo) async {
    bootCalled = true;
  }
}

/// Provider that modifies Nylo instance
class ModifyingProvider extends NyProvider {
  bool setupCalled = false;
  bool bootCalled = false;

  @override
  Future<Nylo?> setup(Nylo nylo) async {
    setupCalled = true;
    nylo.addModelDecoders({});
    return nylo;
  }

  @override
  Future<void> boot(Nylo nylo) async {
    bootCalled = true;
  }
}

/// Provider that throws only in boot
class BootFailingProvider extends NyProvider {
  bool setupCalled = false;
  bool bootCalled = false;

  @override
  Future<Nylo?> setup(Nylo nylo) async {
    setupCalled = true;
    return nylo;
  }

  @override
  Future<void> boot(Nylo nylo) async {
    bootCalled = true;
    throw Exception('Boot failed');
  }
}
