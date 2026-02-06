import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Storage configuration for Nylo.
/// You can set the storage options for each platform.
/// E.g. AndroidOptions, IOSOptions, LinuxOptions, WindowsOptions, WebOptions, MacOsOptions
class StorageConfig {
  IOSOptions iosOptions = IOSOptions.defaultOptions;
  AndroidOptions androidOptions = AndroidOptions.defaultOptions;
  LinuxOptions linuxOptions = LinuxOptions.defaultOptions;
  WindowsOptions windowsOptions = WindowsOptions.defaultOptions;
  WebOptions webOptions = WebOptions.defaultOptions;
  MacOsOptions macOsOptions = MacOsOptions.defaultOptions;

  StorageConfig({
    this.iosOptions = IOSOptions.defaultOptions,
    this.androidOptions = AndroidOptions.defaultOptions,
    this.linuxOptions = LinuxOptions.defaultOptions,
    this.windowsOptions = WindowsOptions.defaultOptions,
    this.webOptions = WebOptions.defaultOptions,
    this.macOsOptions = MacOsOptions.defaultOptions,
  });

  StorageConfig._privateConstructor();

  /// Initialize the storage configuration.
  static void init({
    IOSOptions? iosOptions,
    AndroidOptions? androidOptions,
    LinuxOptions? linuxOptions,
    WindowsOptions? windowsOptions,
    WebOptions? webOptions,
    MacOsOptions? macOsOptions,
  }) {
    StorageConfig storageConfig = StorageConfig.instance;
    storageConfig.iosOptions = iosOptions ?? IOSOptions.defaultOptions;
    storageConfig.androidOptions =
        androidOptions ?? AndroidOptions.defaultOptions;
    storageConfig.linuxOptions = linuxOptions ?? LinuxOptions.defaultOptions;
    storageConfig.windowsOptions =
        windowsOptions ?? WindowsOptions.defaultOptions;
    storageConfig.webOptions = webOptions ?? WebOptions.defaultOptions;
    storageConfig.macOsOptions = macOsOptions ?? MacOsOptions.defaultOptions;
  }

  /// Returns the instance.
  static final StorageConfig instance = StorageConfig._privateConstructor();
}
