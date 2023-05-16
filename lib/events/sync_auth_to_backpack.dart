import 'package:nylo_support/events/events.dart';
import 'package:nylo_support/helpers/backpack.dart';
import 'package:nylo_support/helpers/helper.dart';

/// Sync Authenticated User to the Backpack
class SyncAuthToBackpackEvent implements NyEvent {
  @override
  final listeners = {
    _DefaultListener: _DefaultListener(),
  };
}

class _DefaultListener extends NyListener {
  @override
  handle(dynamic event) async {
    String storageKey = getEnv('AUTH_USER_KEY', defaultValue: 'AUTH_USER');
    dynamic authUser = await NyStorage.read(storageKey);
    if (authUser != null) {
      Backpack.instance.set(storageKey, authUser);
    }
  }
}
