import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/local_storage/ny_local_storage.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('StorageConfig', () {
    nyGroup('singleton instance', () {
      nyTest('should return the same instance', () async {
        final instance1 = StorageConfig.instance;
        final instance2 = StorageConfig.instance;

        expect(identical(instance1, instance2), isTrue);
      });
    });

    nyGroup('default values', () {
      nyTest('should have default iOS options', () async {
        final config = StorageConfig.instance;

        expect(config.iosOptions, isA<IOSOptions>());
      });

      nyTest('should have default Android options', () async {
        final config = StorageConfig.instance;

        expect(config.androidOptions, isA<AndroidOptions>());
      });

      nyTest('should have default Linux options', () async {
        final config = StorageConfig.instance;

        expect(config.linuxOptions, isA<LinuxOptions>());
      });

      nyTest('should have default Windows options', () async {
        final config = StorageConfig.instance;

        expect(config.windowsOptions, isA<WindowsOptions>());
      });

      nyTest('should have default Web options', () async {
        final config = StorageConfig.instance;

        expect(config.webOptions, isA<WebOptions>());
      });

      nyTest('should have default macOS options', () async {
        final config = StorageConfig.instance;

        expect(config.macOsOptions, isA<MacOsOptions>());
      });
    });

    nyGroup('constructor with parameters', () {
      nyTest('should create with custom iOS options', () async {
        final customIosOptions = IOSOptions(accountName: 'custom_account');

        final config = StorageConfig(iosOptions: customIosOptions);

        expect(config.iosOptions, customIosOptions);
      });

      nyTest('should create with custom Android options', () async {
        final customAndroidOptions = AndroidOptions(
          encryptedSharedPreferences: true,
        );

        final config = StorageConfig(androidOptions: customAndroidOptions);

        expect(config.androidOptions, customAndroidOptions);
      });
    });

    nyGroup('init', () {
      nyTest('should initialize with custom iOS options', () async {
        final customIosOptions = IOSOptions(accountName: 'test_account');

        StorageConfig.init(iosOptions: customIosOptions);

        expect(
          StorageConfig.instance.iosOptions.params['accountName'],
          'test_account',
        );
      });

      nyTest('should initialize with custom Android options', () async {
        final customAndroidOptions = AndroidOptions(
          encryptedSharedPreferences: true,
        );

        StorageConfig.init(androidOptions: customAndroidOptions);

        expect(StorageConfig.instance.androidOptions, isNotNull);
      });

      nyTest('should use default options when not specified', () async {
        StorageConfig.init();

        expect(StorageConfig.instance.iosOptions, isA<IOSOptions>());
        expect(StorageConfig.instance.androidOptions, isA<AndroidOptions>());
        expect(StorageConfig.instance.linuxOptions, isA<LinuxOptions>());
        expect(StorageConfig.instance.windowsOptions, isA<WindowsOptions>());
        expect(StorageConfig.instance.webOptions, isA<WebOptions>());
        expect(StorageConfig.instance.macOsOptions, isA<MacOsOptions>());
      });

      nyTest('should allow partial initialization', () async {
        final customWebOptions = WebOptions.defaultOptions;

        StorageConfig.init(webOptions: customWebOptions);

        expect(StorageConfig.instance.webOptions, customWebOptions);
        // Other options should remain as defaults
        expect(StorageConfig.instance.iosOptions, isA<IOSOptions>());
      });
    });

    nyGroup('property setters', () {
      nyTest('should allow setting iOS options', () async {
        final config = StorageConfig();
        final newIosOptions = IOSOptions(accountName: 'new_account');

        config.iosOptions = newIosOptions;

        expect(config.iosOptions, newIosOptions);
      });

      nyTest('should allow setting Android options', () async {
        final config = StorageConfig();
        final newAndroidOptions = AndroidOptions(
          encryptedSharedPreferences: true,
        );

        config.androidOptions = newAndroidOptions;

        expect(config.androidOptions, newAndroidOptions);
      });

      nyTest('should allow setting Linux options', () async {
        final config = StorageConfig();
        final newLinuxOptions = LinuxOptions.defaultOptions;

        config.linuxOptions = newLinuxOptions;

        expect(config.linuxOptions, newLinuxOptions);
      });

      nyTest('should allow setting Windows options', () async {
        final config = StorageConfig();
        final newWindowsOptions = WindowsOptions.defaultOptions;

        config.windowsOptions = newWindowsOptions;

        expect(config.windowsOptions, newWindowsOptions);
      });

      nyTest('should allow setting Web options', () async {
        final config = StorageConfig();
        final newWebOptions = WebOptions.defaultOptions;

        config.webOptions = newWebOptions;

        expect(config.webOptions, newWebOptions);
      });

      nyTest('should allow setting macOS options', () async {
        final config = StorageConfig();
        final newMacOsOptions = MacOsOptions.defaultOptions;

        config.macOsOptions = newMacOsOptions;

        expect(config.macOsOptions, newMacOsOptions);
      });
    });
  });
}
