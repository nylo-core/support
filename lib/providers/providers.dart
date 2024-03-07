import '/helpers/backpack.dart';
import '/nylo.dart';

/// Base class for Providers.
abstract class NyProvider {
  /// Boot method is used for initializing code in your application.
  Future<Nylo?> boot(Nylo nylo) async => null;
  Future<void> afterBoot(Nylo nylo) async => null;
}

/// Boots application providers.
///
/// See "config/providers" to add/modify providers
Future<Nylo> bootApplication(Map<Type, NyProvider> providers) async {
  Nylo nylo = Nylo();
  for (var provider in providers.values) {
    Nylo? nyloObject = await provider.boot(nylo);
    if (nyloObject != null) {
      nylo = nyloObject;
    }
  }
  return nylo;
}

/// Called after Nylo finishes booting.
Future<Nylo> bootFinished(Nylo nylo, Map<Type, NyProvider> providers,
    {String key = "nylo"}) async {
  for (var provider in providers.values) {
    await provider.afterBoot(nylo);
  }
  Backpack.instance.set(key, nylo);
  try {
    Nylo.canMonitorAppUsage();
    await Nylo.appLaunched();
  } on Exception catch (_) {}

  return nylo;
}
