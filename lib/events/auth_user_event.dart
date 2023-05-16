import 'package:nylo_support/events/events.dart';
import 'package:nylo_support/helpers/helper.dart';

/// Authentication Event for users.
class AuthUserEvent implements NyEvent {
  @override
  final listeners = {
    _DefaultListener: _DefaultListener(),
  };
}

class _DefaultListener extends NyListener {
  @override
  handle(dynamic event) async {
    String storageKey = getEnv('AUTH_USER_KEY', defaultValue: 'AUTH_USER');
    if (event['key'] != null) {
      storageKey = event['key'];
    }
    await NyStorage.store(
      storageKey,
      event['auth'],
      inBackpack: true,
    );
  }
}
