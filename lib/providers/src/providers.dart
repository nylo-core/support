import '/helpers/ny_helpers.dart';
import '/nylo.dart';

/// Configuration for bootstrapping a Nylo application.
///
/// Contains the setup and boot functions that are called during [Nylo.init()].
/// The [setup] function initializes the application and returns a [Nylo] instance.
/// The [boot] function is called after setup completes to finalize initialization.
///
/// Example:
/// ```dart
/// class Boot {
///   static BootConfig nylo() {
///     return BootConfig(
///       setup: () async {
///         WidgetsFlutterBinding.ensureInitialized();
///         return await setupApplication(providers);
///       },
///       boot: (Nylo nylo) async {
///         await bootFinished(nylo, providers);
///         runApp(Main(nylo));
///       },
///     );
///   }
/// }
/// ```
class BootConfig {
  /// Function that initializes the application and returns a [Nylo] instance.
  final Future<Nylo> Function() setup;

  /// Function called after setup completes to finalize initialization.
  final Future<void> Function(Nylo nylo) boot;

  /// Creates a new [BootConfig] with the given [setup] and [boot] functions.
  const BootConfig({required this.setup, required this.boot});
}

/// Base class for Providers.
///
/// Providers are used to bootstrap and configure your application.
/// They are booted in the order they are defined in the providers map.
///
/// Lifecycle:
/// 1. [setup] - Initialize your provider (runs during app startup)
/// 2. [boot] - Called after all providers have finished setup
/// 3. [dispose] - Called when the app is shutting down (optional cleanup)
abstract class NyProvider {
  /// Setup method is used for initializing code in your application.
  /// Return the [Nylo] instance to pass it to the next provider.
  Future<Nylo?> setup(Nylo nylo) async => null;

  /// Called after all providers have finished setup.
  /// Use this for initialization that depends on other providers being ready.
  Future<void> boot(Nylo nylo) async {}
}

/// Sets up application providers.
///
/// See "bootstrap/providers" to add/modify providers.
///
/// [providers] - Map of provider types to provider instances.
/// [enableDebugLogging] - When true, logs setup timing for each provider.
///                        Defaults to the value of APP_DEBUG environment variable.
Future<Nylo> setupApplication(
  Map<Type, NyProvider> providers, {
  bool? enableDebugLogging,
}) async {
  Nylo nylo = Nylo();
  final bool shouldLog =
      enableDebugLogging ?? getEnv('APP_DEBUG', defaultValue: false);

  for (final entry in providers.entries) {
    final providerName = entry.key.toString();
    final provider = entry.value;

    final Stopwatch? stopwatch = shouldLog ? (Stopwatch()..start()) : null;

    try {
      Nylo? nyloObject = await provider.setup(nylo);
      if (nyloObject != null) {
        nylo = nyloObject;
      }

      if (shouldLog && stopwatch != null) {
        stopwatch.stop();
        NyLogger.debug(
          '[$providerName] setup in ${stopwatch.elapsedMilliseconds}ms',
        );
      }
    } catch (e, stackTrace) {
      if (shouldLog) {
        NyLogger.error('[$providerName] failed to setup: $e');
        NyLogger.error(stackTrace.toString());
      }
      rethrow;
    }
  }
  return nylo;
}

/// Called after Nylo finishes setup.
///
/// [nylo] - The Nylo instance.
/// [providers] - Map of provider types to provider instances.
/// [key] - The key to save the Nylo instance in the Backpack.
/// [enableDebugLogging] - When true, logs boot timing for each provider.
///                        Defaults to the value of APP_DEBUG environment variable.
/// [throwOnError] - When true, rethrows errors instead of silently catching them.
///                  Defaults to false for backwards compatibility.
Future<Nylo> bootFinished(
  Nylo nylo,
  Map<Type, NyProvider> providers, {
  String key = "nylo",
  bool? enableDebugLogging,
  bool throwOnError = false,
}) async {
  final bool shouldLog =
      enableDebugLogging ?? getEnv('APP_DEBUG', defaultValue: false);

  for (final entry in providers.entries) {
    final providerName = entry.key.toString();
    final provider = entry.value;

    final Stopwatch? stopwatch = shouldLog ? (Stopwatch()..start()) : null;

    try {
      await provider.boot(nylo);

      if (shouldLog && stopwatch != null) {
        stopwatch.stop();
        NyLogger.debug(
          '[$providerName] boot completed in ${stopwatch.elapsedMilliseconds}ms',
        );
      }
    } catch (e, stackTrace) {
      if (shouldLog) {
        NyLogger.error('[$providerName] boot failed: $e');
        NyLogger.error(stackTrace.toString());
      }
      if (throwOnError) rethrow;
    }
  }

  Backpack.instance.save(key, nylo);

  if (nylo.shouldMonitorAppUsage()) {
    await Nylo.appLaunched();
  }

  return nylo;
}
