import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/metro/ny_metro.dart';
import 'package:nylo_support/testing/ny_testing.dart';

/// A throwaway project on disk (package config, commands.json, fake packages).
/// Its folders contain spaces so string-joined paths would be caught.
class _FakeProject {
  final Directory base;
  final Directory root;
  final Directory packages;

  _FakeProject._(this.base, this.root, this.packages);

  static Future<_FakeProject> create() async {
    final base = await Directory.systemTemp.createTemp('metro_pkg_test_');
    final root = await Directory('${base.path}/my app').create();
    final packages = await Directory('${base.path}/my packages').create();
    await File('${root.path}/pubspec.yaml').writeAsString(_pubspec());
    // Only resolvable through the project's package config, never through
    // the fake packages' own pubspecs.
    final marker = File('${root.path}/lib/marker.dart');
    await marker.create(recursive: true);
    await marker.writeAsString("const String marker = 'via my_app';\n");
    return _FakeProject._(base, root, packages);
  }

  static String _pubspec({String? dependency}) =>
      'name: my_app\n'
      'publish_to: none\n'
      'environment:\n'
      '  sdk: ^3.10.0\n'
      '${dependency == null ? '' : 'dependencies:\n  $dependency:\n    path: ../my packages/$dependency\n'}';

  /// Declares [packageName] as a dependency and resolves the project with pub,
  /// writing the real `.dart_tool/package_config.json`.
  Future<void> dependOnAndResolve(String packageName) async {
    await File(
      '${root.path}/pubspec.yaml',
    ).writeAsString(_pubspec(dependency: packageName));
    final result = await Process.run(
      'dart',
      ['pub', 'get', '--offline'],
      workingDirectory: root.path,
      runInShell: true,
    );
    if (result.exitCode != 0) {
      throw StateError('dart pub get failed: ${result.stdout}${result.stderr}');
    }
  }

  /// Creates a fake package; [manifest] is JSON-encoded (or [rawManifest] written
  /// verbatim) into metro_commands.json, and [scripts] are files to create.
  Future<Directory> addPackage(
    String name, {
    Object? manifest,
    String? rawManifest,
    Map<String, String> scripts = const {},
  }) async {
    final dir = await Directory('${packages.path}/$name').create();
    await File(
      '${dir.path}/pubspec.yaml',
    ).writeAsString('name: $name\nenvironment:\n  sdk: ^3.10.0\n');
    if (manifest != null) {
      await File(
        '${dir.path}/$packageCommandsManifest',
      ).writeAsString(jsonEncode(manifest));
    }
    if (rawManifest != null) {
      await File(
        '${dir.path}/$packageCommandsManifest',
      ).writeAsString(rawManifest);
    }
    for (final entry in scripts.entries) {
      final file = File('${dir.path}/${entry.key}');
      await file.create(recursive: true);
      await file.writeAsString(entry.value);
    }
    return dir;
  }

  /// A package_config entry using a `rootUri` relative to `.dart_tool/`.
  Map<String, dynamic> relativeEntry(String name) => {
    'name': name,
    // pub percent-encodes the path, so a space becomes %20.
    'rootUri': '../../my%20packages/$name',
    'packageUri': 'lib/',
    'languageVersion': '3.10',
  };

  /// A package_config entry using an absolute `file://` `rootUri`, without a
  /// trailing slash, the way pub writes hosted packages.
  Map<String, dynamic> absoluteEntry(String name) {
    final uri = Directory('${packages.path}/$name').uri.toString();
    return {
      'name': name,
      'rootUri': uri.endsWith('/') ? uri.substring(0, uri.length - 1) : uri,
      'packageUri': 'lib/',
      'languageVersion': '3.10',
    };
  }

  Future<void> writePackageConfig(List<Map<String, dynamic>> entries) async {
    final file = File('${root.path}/$packageConfigPath');
    await file.create(recursive: true);
    await file.writeAsString(
      jsonEncode({
        'configVersion': 2,
        'packages': [
          {
            'name': 'my_app',
            'rootUri': '../',
            'packageUri': 'lib/',
            'languageVersion': '3.10',
          },
          ...entries,
        ],
      }),
    );
  }

  Future<void> writeProjectCommands(List<Map<String, dynamic>> commands) async {
    final file = File('${root.path}/$commandsFolder/commands.json');
    await file.create(recursive: true);
    await file.writeAsString(jsonEncode(commands));
  }

  Future<void> dispose() => base.delete(recursive: true);
}

Map<String, dynamic> _command(
  String name, {
  String? category,
  String script = 'script.dart',
  String? description,
}) => {
  'name': name,
  if (category != null) 'category': category,
  'script': script,
  if (description != null) 'description': description,
};

/// Writes the project marker and args[2..] to the file args[0], exits with args[1].
/// Its import only resolves through the project's package config.
const String _echoScript = '''
import 'dart:io';

import 'package:my_app/marker.dart';

void main(List<String> args) {
  File(args[0]).writeAsStringSync([marker, ...args.skip(2)].join('|'));
  exit(int.parse(args[1]));
}
''';

void main() {
  NyTest.init();

  nyGroup('MetroService.discoverPackageCommands', () {
    nyTest('returns nothing when the project has no package config', () async {
      final project = await _FakeProject.create();
      try {
        final commands = await MetroService.discoverPackageCommands(
          projectDirectory: project.root,
        );
        expect(commands, isEmpty);
      } finally {
        await project.dispose();
      }
    });

    nyTest('discovers a manifest through a relative rootUri', () async {
      final project = await _FakeProject.create();
      try {
        await project.addPackage(
          'demo_package',
          manifest: [
            _command(
              'create',
              category: 'demo',
              script: 'demo_create.dart',
              description: 'Create a new record',
            ),
          ],
        );
        await project.writePackageConfig([
          project.relativeEntry('demo_package'),
        ]);

        final commands = await MetroService.discoverPackageCommands(
          projectDirectory: project.root,
        );

        expect(commands, hasLength(1));
        final command = commands.single;
        expect(command.name, 'create');
        expect(command.category, 'demo');
        expect(command.fullName, 'demo:create');
        expect(command.package, 'demo_package');
        expect(command.isFromPackage, isTrue);
        expect(command.description, 'Create a new record');
        expect(command.action, isNotNull);
      } finally {
        await project.dispose();
      }
    });

    nyTest(
      'discovers a manifest through an absolute, percent-encoded rootUri',
      () async {
        final project = await _FakeProject.create();
        try {
          // The project lives under a folder with a space, so the absolute
          // rootUri pub would write contains "%20".
          await project.addPackage(
            'demo_package',
            manifest: [_command('create', category: 'demo')],
          );
          final entry = project.absoluteEntry('demo_package');
          expect(entry['rootUri'], startsWith('file://'));
          expect(entry['rootUri'], contains('%20'));
          await project.writePackageConfig([entry]);

          final commands = await MetroService.discoverPackageCommands(
            projectDirectory: project.root,
          );

          expect(commands.map((c) => c.fullName), ['demo:create']);
        } finally {
          await project.dispose();
        }
      },
    );

    nyTest('defaults the category to the package name', () async {
      final project = await _FakeProject.create();
      try {
        await project.addPackage('demo_package', manifest: [_command('sync')]);
        await project.writePackageConfig([
          project.relativeEntry('demo_package'),
        ]);

        final commands = await MetroService.discoverPackageCommands(
          projectDirectory: project.root,
        );

        expect(commands.single.fullName, 'demo_package:sync');
      } finally {
        await project.dispose();
      }
    });

    nyTest(
      'skips packages without a manifest and the project itself',
      () async {
        final project = await _FakeProject.create();
        try {
          await project.addPackage('plain_package');
          await project.addPackage(
            'demo_package',
            manifest: [_command('create', category: 'demo')],
          );
          // A manifest at the project root must not be picked up as a package.
          await File(
            '${project.root.path}/$packageCommandsManifest',
          ).writeAsString(jsonEncode([_command('rogue', category: 'app')]));
          await project.writePackageConfig([
            project.relativeEntry('plain_package'),
            project.relativeEntry('demo_package'),
          ]);

          final commands = await MetroService.discoverPackageCommands(
            projectDirectory: project.root,
          );

          expect(commands.map((c) => c.fullName), ['demo:create']);
        } finally {
          await project.dispose();
        }
      },
    );

    nyTest(
      'reports a malformed manifest and keeps the other packages',
      () async {
        final project = await _FakeProject.create();
        try {
          await project.addPackage('broken', rawManifest: '{ not json');
          await project.addPackage('not_a_list', manifest: {'commands': []});
          await project.addPackage(
            'demo_package',
            manifest: [_command('create', category: 'demo')],
          );
          await project.writePackageConfig([
            project.relativeEntry('broken'),
            project.relativeEntry('not_a_list'),
            project.relativeEntry('demo_package'),
          ]);

          final warnings = <String>[];
          final commands = await MetroService.discoverPackageCommands(
            projectDirectory: project.root,
            onWarning: warnings.add,
          );

          expect(commands.map((c) => c.fullName), ['demo:create']);
          expect(warnings, hasLength(2));
          expect(warnings[0], contains('package "broken"'));
          expect(warnings[1], contains('package "not_a_list"'));
          expect(warnings[1], contains('Expected a JSON array'));
        } finally {
          await project.dispose();
        }
      },
    );

    nyTest('ignores invalid entries and keeps the valid ones', () async {
      final project = await _FakeProject.create();
      try {
        await project.addPackage(
          'demo_package',
          manifest: [
            {'name': 'no_script', 'category': 'demo'},
            {'script': 'lib/no_name.dart'},
            'not an object',
            _command('create', category: 'demo'),
          ],
        );
        await project.writePackageConfig([
          project.relativeEntry('demo_package'),
        ]);

        final warnings = <String>[];
        final commands = await MetroService.discoverPackageCommands(
          projectDirectory: project.root,
          onWarning: warnings.add,
        );

        expect(commands.map((c) => c.fullName), ['demo:create']);
        expect(warnings, hasLength(3));
        expect(warnings.first, contains('"name" and "script" are required'));
      } finally {
        await project.dispose();
      }
    });

    nyTest(
      'rejects scripts that are not a Dart file directly in bin/',
      () async {
        final project = await _FakeProject.create();
        try {
          await project.addPackage(
            'demo_package',
            manifest: [
              _command('nested', category: 'demo', script: 'sub/nested.dart'),
              _command('windows', category: 'demo', script: 'sub\\x.dart'),
              _command('no_ext', category: 'demo', script: 'no_ext'),
              _command('create', category: 'demo', script: 'demo_create.dart'),
            ],
          );
          await project.writePackageConfig([
            project.relativeEntry('demo_package'),
          ]);

          final warnings = <String>[];
          final commands = await MetroService.discoverPackageCommands(
            projectDirectory: project.root,
            onWarning: warnings.add,
          );

          expect(commands.map((c) => c.fullName), ['demo:create']);
          expect(warnings, hasLength(3));
          expect(warnings[0], contains('"demo:nested"'));
          expect(warnings[0], contains('bin/'));
          expect(warnings[1], contains('"demo:windows"'));
          expect(warnings[2], contains('"demo:no_ext"'));
        } finally {
          await project.dispose();
        }
      },
    );

    nyTest('sorts by package name, then category:name', () async {
      final project = await _FakeProject.create();
      try {
        await project.addPackage(
          'zeta',
          manifest: [
            _command('b', category: 'z'),
            _command('a', category: 'z'),
          ],
        );
        await project.addPackage(
          'alpha',
          manifest: [
            _command('one', category: 'y'),
            _command('two', category: 'x'),
          ],
        );
        await project.writePackageConfig([
          project.relativeEntry('zeta'),
          project.relativeEntry('alpha'),
        ]);

        final commands = await MetroService.discoverPackageCommands(
          projectDirectory: project.root,
        );

        expect(commands.map((c) => '${c.package} ${c.fullName}'), [
          'alpha x:two',
          'alpha y:one',
          'zeta z:a',
          'zeta z:b',
        ]);
      } finally {
        await project.dispose();
      }
    });

    nyTest('ignores a package config that is not valid JSON', () async {
      final project = await _FakeProject.create();
      try {
        final file = File('${project.root.path}/$packageConfigPath');
        await file.create(recursive: true);
        await file.writeAsString('nope');

        final warnings = <String>[];
        final commands = await MetroService.discoverPackageCommands(
          projectDirectory: project.root,
          onWarning: warnings.add,
        );

        expect(commands, isEmpty);
        expect(warnings.single, contains(packageConfigPath));
      } finally {
        await project.dispose();
      }
    });
  });

  nyGroup('MetroService.mergeCommands', () {
    NyCommand project(String category, String name) =>
        NyCommand(name: name, category: category);
    NyCommand package(String pkg, String category, String name) =>
        NyCommand(name: name, category: category, package: pkg);

    nyTest('keeps project commands first, then package commands', () async {
      final merged = MetroService.mergeCommands(
        projectCommands: [project('app', 'deploy')],
        packageCommands: [package('demo_package', 'demo', 'create')],
      );

      expect(merged.map((c) => c.fullName), ['app:deploy', 'demo:create']);
    });

    nyTest('a project command shadows a package command', () async {
      final warnings = <String>[];
      final merged = MetroService.mergeCommands(
        projectCommands: [project('demo', 'create')],
        packageCommands: [package('demo_package', 'demo', 'create')],
        onWarning: warnings.add,
      );

      expect(merged, hasLength(1));
      expect(merged.single.package, isNull);
      expect(warnings.single, contains('"demo:create"'));
      expect(warnings.single, contains('package "demo_package"'));
      expect(warnings.single, contains('your project'));
    });

    nyTest('the first package to define a command wins', () async {
      final warnings = <String>[];
      final merged = MetroService.mergeCommands(
        projectCommands: [],
        packageCommands: [
          package('alpha', 'demo', 'create'),
          package('beta', 'demo', 'create'),
        ],
        onWarning: warnings.add,
      );

      expect(merged.single.package, 'alpha');
      expect(warnings.single, contains('package "beta"'));
      expect(warnings.single, contains('package "alpha"'));
    });

    nyTest('reserved (built-in) commands shadow everything', () async {
      final warnings = <String>[];
      final merged = MetroService.mergeCommands(
        projectCommands: [project('make', 'page'), project('app', 'deploy')],
        packageCommands: [package('demo_package', 'make', 'model')],
        reservedCommands: ['make:page', 'make:model'],
        onWarning: warnings.add,
      );

      expect(merged.map((c) => c.fullName), ['app:deploy']);
      expect(warnings, hasLength(2));
      expect(warnings[0], contains('"make:page"'));
      expect(warnings[0], contains('commands.json'));
      expect(warnings[1], contains('"make:model"'));
      expect(warnings[1], contains('package "demo_package"'));
    });

    nyTest('does not warn when there is nothing to shadow', () async {
      final warnings = <String>[];
      MetroService.mergeCommands(
        projectCommands: [project('app', 'deploy')],
        packageCommands: [package('demo_package', 'demo', 'create')],
        reservedCommands: ['make:page'],
        onWarning: warnings.add,
      );

      expect(warnings, isEmpty);
    });
  });

  nyGroup('MetroService.discoverCustomCommands', () {
    nyTest('combines project and package commands with precedence', () async {
      final project = await _FakeProject.create();
      try {
        await project.writeProjectCommands([
          {'name': 'current_time', 'category': 'app', 'script': 'ct.dart'},
          {'name': 'create', 'category': 'demo', 'script': 'tc.dart'},
          {'name': 'page', 'category': 'make', 'script': 'mp.dart'},
        ]);
        await project.addPackage(
          'demo_package',
          manifest: [
            _command('create', category: 'demo'),
            _command('delete', category: 'demo'),
          ],
        );
        await project.writePackageConfig([
          project.relativeEntry('demo_package'),
        ]);

        final warnings = <String>[];
        final commands = await MetroService.discoverCustomCommands(
          projectDirectory: project.root,
          reservedCommands: ['make:page'],
          onWarning: warnings.add,
        );

        expect(commands.map((c) => '${c.package} ${c.fullName}'), [
          'null app:current_time',
          'null demo:create',
          'demo_package demo:delete',
        ]);
        expect(warnings, hasLength(2));
        expect(warnings[0], contains('"make:page"'));
        expect(warnings[1], contains('"demo:create"'));
      } finally {
        await project.dispose();
      }
    });

    nyTest('works with only package commands', () async {
      final project = await _FakeProject.create();
      try {
        await project.addPackage(
          'demo_package',
          manifest: [_command('create', category: 'demo')],
        );
        await project.writePackageConfig([
          project.relativeEntry('demo_package'),
        ]);

        final commands = await MetroService.discoverCustomCommands(
          projectDirectory: project.root,
        );

        expect(commands.map((c) => c.fullName), ['demo:create']);
      } finally {
        await project.dispose();
      }
    });
  });

  nyGroup('MetroService.customCommandsMenu', () {
    nyTest('is empty when there are no commands', () async {
      expect(MetroService.customCommandsMenu([]), '');
    });

    nyTest('lists project commands under Custom Commands', () async {
      final menu = MetroService.customCommandsMenu([
        NyCommand(name: 'current_time', category: 'app'),
        NyCommand(name: 'quote', category: 'motivational'),
      ]);

      expect(
        menu,
        '[Custom Commands]\n  app:current_time\n  motivational:quote\n',
      );
    });

    nyTest('groups package commands per package with descriptions', () async {
      final menu = MetroService.customCommandsMenu([
        NyCommand(name: 'current_time', category: 'app'),
        NyCommand(
          name: 'create',
          category: 'demo',
          package: 'demo_package',
          description: 'Create a new record',
        ),
        NyCommand(
          name: 'sync_all',
          category: 'demo',
          package: 'demo_package',
          description: 'Sync every record',
        ),
        NyCommand(name: 'push', category: 'notify', package: 'nylo_push'),
      ]);

      expect(
        menu,
        '[Custom Commands]\n'
        '  app:current_time\n'
        '\n'
        '[demo_package Commands]\n'
        '  demo:create      Create a new record\n'
        '  demo:sync_all    Sync every record\n'
        '\n'
        '[nylo_push Commands]\n'
        '  notify:push\n',
      );
    });
  });

  nyGroup('MetroService.runCommand', () {
    nyTest('returns the exit code an action returns', () async {
      final exitCode = await MetroService.runCommand(
        ['app:fail'],
        allCommands: [
          NyCommand(name: 'fail', category: 'app', action: (args) async => 4),
        ],
        menu: '',
      );

      expect(exitCode, 4);
    });

    nyTest('treats an action without an int result as success', () async {
      List<String>? received;
      final exitCode = await MetroService.runCommand(
        ['app:ok', '--name', 'x'],
        allCommands: [
          NyCommand(
            name: 'ok',
            category: 'app',
            action: (args) async => received = args,
          ),
        ],
        menu: '',
      );

      expect(exitCode, 0);
      expect(received, ['--name', 'x']);
    });

    nyTest('returns 1 when a command script is missing', () async {
      final project = await _FakeProject.create();
      try {
        await project.addPackage(
          'demo_package',
          manifest: [
            _command('create', category: 'demo', script: 'missing.dart'),
          ],
        );
        await project.writePackageConfig([
          project.relativeEntry('demo_package'),
        ]);
        final commands = await MetroService.discoverCustomCommands(
          projectDirectory: project.root,
        );

        final exitCode = await MetroService.runCommand(
          ['demo:create'],
          allCommands: commands,
          menu: '',
        );

        expect(exitCode, 1);
      } finally {
        await project.dispose();
      }
    });

    nyTest(
      'runs a package command as dart run <package>:<executable> in the '
      'project, keeping spaces in the arguments, and propagates its exit code',
      () async {
        final project = await _FakeProject.create();
        try {
          final package = await project.addPackage(
            'demo_package',
            manifest: [
              _command('create', category: 'demo', script: 'demo_create.dart'),
            ],
            scripts: {'bin/demo_create.dart': _echoScript},
          );
          await project.dependOnAndResolve('demo_package');
          final commands = await MetroService.discoverCustomCommands(
            projectDirectory: project.root,
          );
          final output = File('${project.root.path}/out put.txt');

          final exitCode = await MetroService.runCommand(
            ['demo:create', output.path, '7', 'two words', '--flag'],
            allCommands: commands,
            menu: '',
          );

          expect(exitCode, 7);
          expect(await output.readAsString(), 'via my_app|two words|--flag');
          // pub must not resolve the package on its own (it would for
          // `dart run <path>`).
          expect(Directory('${package.path}/.dart_tool').existsSync(), isFalse);
          expect(File('${package.path}/pubspec.lock').existsSync(), isFalse);
        } finally {
          await project.dispose();
        }
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );
  });
}
