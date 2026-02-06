/// Base class for environment configuration.
///
/// Users should not extend this class directly. Instead, use the
/// `metro make:env` command to generate an `Env` class that implements
/// the required functionality.
///
/// The generated class will be registered with Nylo during app initialization.
abstract class NyEnv {
  /// Gets an environment variable by key.
  ///
  /// Returns the value, or [defaultValue] if the key is not found.
  static dynamic get(String key, {dynamic defaultValue}) {
    throw UnimplementedError(
      'NyEnv.get() called but no Env class has been registered.\n'
      'Run "metro make:env" to generate your env.g.dart file, then\n'
      'register it in your app_provider.dart using:\n'
      '  nylo.addEnv(Env.get);',
    );
  }

  /// Checks if an environment variable exists.
  static bool containsKey(String key) {
    throw UnimplementedError(
      'NyEnv.containsKey() called but no Env class has been registered.',
    );
  }
}

/// Type definition for the env getter function.
typedef EnvGetter = dynamic Function(String key, {dynamic defaultValue});

/// Type definition for the env containsKey function.
typedef EnvContainsKey = bool Function(String key);

/// Registry for the user's generated Env class.
class NyEnvRegistry {
  NyEnvRegistry._();

  static EnvGetter? _getter;
  static EnvContainsKey? _containsKey;

  /// Registers the env getter function.
  static void register({
    required EnvGetter getter,
    EnvContainsKey? containsKey,
  }) {
    _getter = getter;
    _containsKey = containsKey;
  }

  /// Gets an environment variable by key.
  static dynamic get(String key, {dynamic defaultValue}) {
    if (_getter == null) {
      throw StateError(
        'Environment not initialized.\n'
        'Run "metro make:env" to generate your env.g.dart file, then\n'
        'register it in your app_provider.dart using:\n'
        '  nylo.addEnv(Env.get);',
      );
    }
    return _getter!(key, defaultValue: defaultValue);
  }

  /// Checks if an environment variable exists.
  static bool containsKey(String key) {
    if (_containsKey == null) {
      return false;
    }
    return _containsKey!(key);
  }

  /// Checks if the env registry has been initialized.
  static bool get isInitialized => _getter != null;
}
