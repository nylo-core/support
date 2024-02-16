import '/events/events.dart';
import '/helpers/backpack.dart';
import '/helpers/helper.dart';

/// Sync Authenticated User to the Backpack
class SyncAuthToBackpackEvent<T> implements NyEvent {
  @override
  final listeners = {
    _DefaultListener: _DefaultListener<T>(),
  };
}

class _DefaultListener<T> extends NyListener {
  @override
  handle(dynamic event) async {
    String storageKey = getEnv('AUTH_USER_KEY', defaultValue: 'AUTH_USER');

    dynamic authUser;
    if (T.toString() == 'dynamic') {
      authUser = await NyStorage.read(storageKey);
    } else {
      authUser = await NyStorage.read<T>(storageKey);
    }
    if (authUser != null) {
      Backpack.instance.set(storageKey, authUser);
    }
  }
}
