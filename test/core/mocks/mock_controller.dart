import 'package:nylo_support/controllers/ny_controllers.dart';

/// Mock controller for testing controller registration
class MockController extends NyController {
  static int instanceCount = 0;
  final int instanceId;

  MockController() : instanceId = ++instanceCount, super();

  static void resetCount() {
    instanceCount = 0;
  }
}
