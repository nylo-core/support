import '/nylo.dart';
import 'playbook.dart';

/// The playbooks registered with Nylo, and the names they run by.
abstract final class PlaybookRegistry {
  /// The playbooks registered on the running Nylo instance.
  static Map<String, Playbook Function()> get playbooks =>
      Nylo.isInitialized() ? Nylo.instance.getPlaybooks() : const {};

  /// The name [playbook] runs by: its key in the registered playbooks,
  /// otherwise its own [Playbook.name], otherwise its class name in snake
  /// case without `Playbook` (`SignUpPlaybook` is `sign_up`).
  static String nameOf(Playbook playbook) {
    for (final MapEntry<String, Playbook Function()> entry
        in playbooks.entries) {
      if (entry.value().runtimeType == playbook.runtimeType) return entry.key;
    }
    final String? own = playbook.name?.trim();
    if (own != null && own.isNotEmpty) return own;
    return nameFromClass(playbook.runtimeType.toString());
  }

  /// `SignUpPlaybook`, `SignUp` and `sign-up` all become `sign_up`.
  static String nameFromClass(String className) {
    String base = className.trim().replaceFirst(RegExp(r'^_+'), '');
    if (base.endsWith('Playbook') && base.length > 'Playbook'.length) {
      base = base.substring(0, base.length - 'Playbook'.length);
    }
    return base
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (Match match) => '${match[1]}_${match[2]}',
        )
        .replaceAllMapped(
          RegExp(r'([A-Z]+)([A-Z][a-z])'),
          (Match match) => '${match[1]}_${match[2]}',
        )
        .replaceAll('-', '_')
        .toLowerCase();
  }

  /// The registered playbook called [name] (or its class name), or null.
  static Playbook? find(String name) {
    final Map<String, Playbook Function()> registered = playbooks;
    final Playbook Function()? exact = registered[name];
    if (exact != null) return exact();
    final String normalized = nameFromClass(name);
    return registered[normalized]?.call();
  }
}
