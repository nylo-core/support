/// Model class used for defining commands
class NyCommand {
  /// The command name, used after the category prefix.
  String? name;

  /// The command category, used as the prefix.
  String? category;

  /// Runs the command with the remaining arguments; may return an int exit code.
  Function? action;

  /// The package that provides this command, or null for project commands.
  String? package;

  /// An optional one-line description shown in the Metro menu.
  String? description;

  NyCommand({
    this.name,
    this.category,
    this.action,
    this.package,
    this.description,
  });

  /// The full `category:name` form used to run the command.
  String get fullName => '${category ?? ''}:${name ?? ''}';

  /// Whether this command was contributed by a dependency package.
  bool get isFromPackage => package != null;
}
