import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Auto-mocking for common Flutter platform channels used in Nylo.
///
/// This class sets up mock handlers for:
/// - flutter_timezone
/// - flutter_local_notifications
/// - path_provider
/// - flutter_secure_storage
/// - sqflite
///
/// Example:
/// ```dart
/// NyMockChannels.setup();
/// // Now all platform channels are mocked
///
/// // Override specific behavior:
/// NyMockChannels.overridePathProvider('/custom/path');
/// ```
class NyMockChannels {
  static bool _isSetup = false;
  static String _documentsPath = '/tmp/test_documents';
  static String _temporaryPath = '/tmp/test_temp';
  static String _applicationSupportPath = '/tmp/test_support';
  static String _libraryPath = '/tmp/test_library';
  static String _cachePath = '/tmp/test_cache';
  static String _timezone = 'America/New_York';
  static final Map<String, String> _secureStorage = {};
  static final Map<String, dynamic> _sqfliteData = {};

  /// Setup all mock channels.
  static void setup() {
    if (_isSetup) return;

    TestWidgetsFlutterBinding.ensureInitialized();

    _setupFlutterTimezone();
    _setupPathProvider();
    _setupSecureStorage();
    _setupLocalNotifications();
    _setupSqflite();

    _isSetup = true;
  }

  /// Reset all mocks to default values.
  static void reset() {
    _documentsPath = '/tmp/test_documents';
    _temporaryPath = '/tmp/test_temp';
    _applicationSupportPath = '/tmp/test_support';
    _libraryPath = '/tmp/test_library';
    _cachePath = '/tmp/test_cache';
    _timezone = 'America/New_York';
    _secureStorage.clear();
    _sqfliteData.clear();
  }

  /// Teardown all mock channels.
  static void tearDown() {
    reset();
    _isSetup = false;
  }

  /// Override path provider paths.
  static void overridePathProvider({
    String? documentsPath,
    String? temporaryPath,
    String? applicationSupportPath,
    String? libraryPath,
    String? cachePath,
  }) {
    if (documentsPath != null) _documentsPath = documentsPath;
    if (temporaryPath != null) _temporaryPath = temporaryPath;
    if (applicationSupportPath != null)
      _applicationSupportPath = applicationSupportPath;
    if (libraryPath != null) _libraryPath = libraryPath;
    if (cachePath != null) _cachePath = cachePath;
  }

  /// Override timezone.
  static void overrideTimezone(String timezone) {
    _timezone = timezone;
  }

  /// Pre-populate secure storage.
  static void setSecureStorageValue(String key, String value) {
    _secureStorage[key] = value;
  }

  /// Get secure storage contents (for assertions).
  static Map<String, String> getSecureStorage() =>
      Map.unmodifiable(_secureStorage);

  /// Clear secure storage.
  static void clearSecureStorage() {
    _secureStorage.clear();
  }

  static void _setupFlutterTimezone() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_timezone'), (
          MethodCall methodCall,
        ) async {
          switch (methodCall.method) {
            case 'getLocalTimezone':
              return _timezone;
            case 'getAvailableTimezones':
              return [
                'America/New_York',
                'America/Los_Angeles',
                'Europe/London',
                'Asia/Tokyo',
                'UTC',
              ];
            default:
              return null;
          }
        });
  }

  static void _setupPathProvider() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            switch (methodCall.method) {
              case 'getApplicationDocumentsDirectory':
                return _documentsPath;
              case 'getTemporaryDirectory':
                return _temporaryPath;
              case 'getApplicationSupportDirectory':
                return _applicationSupportPath;
              case 'getLibraryDirectory':
                return _libraryPath;
              case 'getApplicationCacheDirectory':
                return _cachePath;
              default:
                return null;
            }
          },
        );

    // Also mock the macOS/iOS specific channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider_macos'),
          (MethodCall methodCall) async {
            switch (methodCall.method) {
              case 'getApplicationDocumentsDirectory':
                return _documentsPath;
              case 'getTemporaryDirectory':
                return _temporaryPath;
              case 'getApplicationSupportDirectory':
                return _applicationSupportPath;
              case 'getLibraryDirectory':
                return _libraryPath;
              default:
                return null;
            }
          },
        );
  }

  static void _setupSecureStorage() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (MethodCall methodCall) async {
            switch (methodCall.method) {
              case 'read':
                final key = methodCall.arguments['key'] as String;
                return _secureStorage[key];
              case 'write':
                final key = methodCall.arguments['key'] as String;
                final value = methodCall.arguments['value'] as String;
                _secureStorage[key] = value;
                return null;
              case 'delete':
                final key = methodCall.arguments['key'] as String;
                _secureStorage.remove(key);
                return null;
              case 'deleteAll':
                _secureStorage.clear();
                return null;
              case 'readAll':
                return _secureStorage;
              case 'containsKey':
                final key = methodCall.arguments['key'] as String;
                return _secureStorage.containsKey(key);
              default:
                return null;
            }
          },
        );
  }

  static void _setupLocalNotifications() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dexterous.com/flutter/local_notifications'),
          (MethodCall methodCall) async {
            switch (methodCall.method) {
              case 'initialize':
                return true;
              case 'show':
                return null;
              case 'cancel':
                return null;
              case 'cancelAll':
                return null;
              case 'pendingNotificationRequests':
                return <Map<String, dynamic>>[];
              case 'getActiveNotifications':
                return <Map<String, dynamic>>[];
              case 'getNotificationAppLaunchDetails':
                return <String, dynamic>{'didNotificationLaunchApp': false};
              default:
                return null;
            }
          },
        );
  }

  static void _setupSqflite() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('com.tekartik.sqflite'), (
          MethodCall methodCall,
        ) async {
          switch (methodCall.method) {
            case 'getDatabasesPath':
              return '$_documentsPath/databases';
            case 'openDatabase':
              return 1; // Database ID
            case 'closeDatabase':
              return null;
            case 'insert':
              return 1; // Row ID
            case 'query':
              return <Map<String, dynamic>>[];
            case 'update':
              return 0; // Affected rows
            case 'delete':
              return 0; // Affected rows
            case 'execute':
              return null;
            case 'batch':
              return <dynamic>[];
            default:
              return null;
          }
        });
  }

  /// Check if channels are set up.
  static bool get isSetup => _isSetup;

  /// Get current mocked timezone.
  static String get timezone => _timezone;

  /// Get current mocked documents path.
  static String get documentsPath => _documentsPath;

  /// Get current mocked temporary path.
  static String get temporaryPath => _temporaryPath;
}
