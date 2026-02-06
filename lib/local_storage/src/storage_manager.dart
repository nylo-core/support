import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'storage_config.dart';

/// Storage manager for Nylo.
class StorageManager {
  /// Returns the storage instance.
  static FlutterSecureStorage storage() {
    StorageConfig storageConfig = StorageConfig.instance;
    return FlutterSecureStorage(
      iOptions: storageConfig.iosOptions,
      aOptions: storageConfig.androidOptions,
      lOptions: storageConfig.linuxOptions,
      wOptions: storageConfig.windowsOptions,
      webOptions: storageConfig.webOptions,
      mOptions: storageConfig.macOsOptions,
    );
  }
}
