import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/local_storage/ny_local_storage.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('StorageManager', () {
    nyGroup('storage', () {
      nyTest('should return FlutterSecureStorage instance', () async {
        final storage = StorageManager.storage();

        expect(storage, isA<FlutterSecureStorage>());
      });

      nyTest(
        'should return configured storage with StorageConfig options',
        () async {
          // Initialize StorageConfig with custom options
          final customIosOptions = IOSOptions(accountName: 'test_app_account');
          StorageConfig.init(iosOptions: customIosOptions);

          final storage = StorageManager.storage();

          expect(storage, isA<FlutterSecureStorage>());
        },
      );

      nyTest('should create new storage instances on each call', () async {
        final storage1 = StorageManager.storage();
        final storage2 = StorageManager.storage();

        // Each call creates a new instance
        expect(identical(storage1, storage2), isFalse);
      });

      nyTest('should use StorageConfig singleton for configuration', () async {
        // Modify the StorageConfig singleton
        final customAndroidOptions = AndroidOptions(
          encryptedSharedPreferences: true,
        );
        StorageConfig.init(androidOptions: customAndroidOptions);

        // Storage should be created with updated config
        final storage = StorageManager.storage();

        expect(storage, isA<FlutterSecureStorage>());
      });
    });
  });
}
