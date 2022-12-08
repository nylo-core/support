import 'package:nylo_support/helpers/backpack.dart';
import 'package:nylo_support/nylo.dart';

/// Base class for Providers.
abstract class NyProvider {
  /// Boot method is used for initializing code in your application.
  Future<Nylo?> boot(Nylo nylo) async => null;
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

/// Called with init Nylo finishes.
Future<Nylo> bootFinished(Nylo nylo, {key = "nylo"}) async {
  Backpack.instance.set(key, nylo);
  return nylo;
}
