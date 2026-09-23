import 'live_exception.dart';
import 'live_output.dart';
import 'seed_recorder.dart';
import 'seeder.dart';

/// A command that runs inside your running app, triggered from Metro.
///
/// Live commands live in `lib/app/commands/` next to your Metro commands and
/// use the same [builder] and [handle] shape. The difference is where they
/// run: [handle] executes inside the app, so it can use `NyStorage`,
/// `routeTo`, `Auth` and your models.
///
/// ```dart
/// class SeedCartCommand extends LiveCommand {
///   @override
///   CommandBuilder builder(CommandBuilder command) {
///     command.addOption('count', abbr: 'c', defaultValue: '3');
///     command.addFlag('open', help: 'Open the cart afterwards');
///     return command;
///   }
///
///   @override
///   Future<void> handle(CommandResult result) async {
///     final int count = result.getInt('count') ?? 3;
///     await CartItem.seed(count: count);
///     success('Seeded $count cart items');
///   }
/// }
/// ```
///
/// Create one with `metro make:command seed_cart --live`, which also registers
/// it with your app, then run it from the terminal while the app runs in debug
/// mode: `metro app:seed_cart --count 5`.
abstract class LiveCommand with LiveOutput {
  /// A one-line description shown by `metro live:commands`.
  String? get description => null;

  /// Declare the options and flags this command accepts.
  ///
  /// Metro parses the terminal arguments against this schema before anything
  /// reaches the app, so typos fail in the terminal.
  CommandBuilder builder(CommandBuilder command) => command;

  /// Runs inside the app when the command is called from Metro.
  ///
  /// Anything returned is sent back to Metro as the command's result.
  Future<dynamic> handle(CommandResult result);

  /// Runs each seeder's `up()` in order, and shows what they changed.
  ///
  /// The runs are recorded the same way as `metro live:seed`, so
  /// `metro live:seed:rollback <name>` undoes them. Throws a [LiveException]
  /// when a seeder fails, after putting back what it had changed.
  Future<void> seed(List<Seeder> seeders) async {
    final List<SeedRun> runs = await SeedRecorder.upAll(seeders);
    for (final SeedRun run in runs) {
      run.log.forEach(writeOutput);
      if (run.failed) {
        throw LiveException('${run.name} failed: ${run.error}');
      }
      writeOutput({
        'level': 'success',
        'message': 'Seeded ${run.name} in ${run.ms}ms',
      });
    }
  }
}

/// Declares the options and flags of a [LiveCommand].
///
/// Mirrors the `CommandBuilder` used by Metro commands. It only records the
/// schema; Metro does the parsing on your machine.
class CommandBuilder {
  final List<Map<String, Object?>> _schema = [];

  /// The declared options and flags, in declaration order.
  List<Map<String, Object?>> get schema => List.unmodifiable(_schema);

  /// Add an option (`--option value` or `-o value`).
  CommandBuilder addOption(
    String name, {
    String? abbr,
    String? help,
    List<String>? allowed,
    String? defaultValue,
  }) {
    _schema.add({
      'kind': 'option',
      'name': name,
      'abbr': abbr,
      'help': help,
      'allowed': allowed,
      'defaultValue': defaultValue,
    });
    return this;
  }

  /// Add a flag (`--flag` or `-f`).
  CommandBuilder addFlag(
    String name, {
    String? abbr,
    String? help,
    bool defaultValue = false,
  }) {
    _schema.add({
      'kind': 'flag',
      'name': name,
      'abbr': abbr,
      'help': help,
      'defaultValue': defaultValue,
    });
    return this;
  }
}

/// The parsed arguments a [LiveCommand] receives.
///
/// Mirrors the `CommandResult` used by Metro commands. Values missing from
/// the call fall back to the defaults declared in [CommandBuilder].
class CommandResult {
  final Map<String, dynamic> _values;
  final Map<String, Object?> _defaults;

  /// Positional arguments that followed the command name.
  final List<String> rest;

  /// Creates a result from already-parsed [values].
  CommandResult(
    Map<String, dynamic> values, {
    List<Map<String, Object?>> schema = const [],
    this.rest = const [],
  }) : _values = Map<String, dynamic>.from(values),
       _defaults = {
         for (final Map<String, Object?> entry in schema)
           if (entry['defaultValue'] != null)
             entry['name'] as String: entry['defaultValue'],
       };

  /// Get a value, falling back to its declared default.
  T? get<T>(String name) {
    final dynamic value = _values.containsKey(name)
        ? _values[name]
        : _defaults[name];
    return value is T ? value : null;
  }

  /// Get a string value.
  String? getString(String name, {String? defaultValue}) =>
      _raw(name)?.toString() ?? defaultValue;

  /// Get a boolean value. Accepts `true`/`false` booleans or strings.
  bool? getBool(String name, {bool? defaultValue}) {
    final dynamic value = _raw(name);
    if (value is bool) return value;
    if (value is String) {
      if (value == 'true') return true;
      if (value == 'false') return false;
    }
    return defaultValue;
  }

  /// Get an integer value. Accepts integers or numeric strings.
  int? getInt(String name, {int? defaultValue}) {
    final dynamic value = _raw(name);
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('${value ?? ''}') ?? defaultValue;
  }

  /// Get a double value. Accepts numbers or numeric strings.
  double? getDouble(String name, {double? defaultValue}) {
    final dynamic value = _raw(name);
    if (value is num) return value.toDouble();
    return double.tryParse('${value ?? ''}') ?? defaultValue;
  }

  dynamic _raw(String name) =>
      _values.containsKey(name) ? _values[name] : _defaults[name];
}
