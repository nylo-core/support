import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/live/ny_live.dart';
import 'package:nylo_support/testing/ny_testing.dart';

class _GreetCommand extends LiveCommand {
  @override
  String? get description => 'Say hello';

  @override
  CommandBuilder builder(CommandBuilder command) {
    command.addOption(
      'name',
      abbr: 'n',
      help: 'Who to greet',
      defaultValue: 'Jane',
    );
    command.addOption('tone', allowed: ['warm', 'formal']);
    command.addFlag('loud', abbr: 'l', help: 'Shout it');
    return command;
  }

  @override
  Future<void> handle(CommandResult result) async {
    info('Greeting ${result.getString('name')}');
    success('Hello');
    warning('Careful');
    error('Oops');
    line('Plain');
  }
}

void main() {
  NyTest.init();

  nyGroup('CommandBuilder', () {
    nyTest('records options and flags in declaration order', () async {
      final List<Map<String, Object?>> schema = _GreetCommand()
          .builder(CommandBuilder())
          .schema;

      expect(schema.map((entry) => entry['name']), ['name', 'tone', 'loud']);
      expect(schema[0], {
        'kind': 'option',
        'name': 'name',
        'abbr': 'n',
        'help': 'Who to greet',
        'allowed': null,
        'defaultValue': 'Jane',
      });
      expect(schema[1]['allowed'], ['warm', 'formal']);
      expect(schema[2], {
        'kind': 'flag',
        'name': 'loud',
        'abbr': 'l',
        'help': 'Shout it',
        'defaultValue': false,
      });
    });

    nyTest('returns an unmodifiable schema', () async {
      final CommandBuilder builder = CommandBuilder()..addFlag('x');

      expect(() => builder.schema.add({}), throwsUnsupportedError);
    });
  });

  nyGroup('CommandResult', () {
    final List<Map<String, Object?>> schema = _GreetCommand()
        .builder(CommandBuilder())
        .schema;

    nyTest('reads parsed values', () async {
      final CommandResult result = CommandResult({
        'name': 'Sam',
        'loud': true,
      }, schema: schema);

      expect(result.getString('name'), 'Sam');
      expect(result.getBool('loud'), isTrue);
    });

    nyTest('falls back to declared defaults', () async {
      final CommandResult result = CommandResult({}, schema: schema);

      expect(result.getString('name'), 'Jane');
      expect(result.getBool('loud'), isFalse);
      expect(result.getString('tone'), isNull);
      expect(result.getString('tone', defaultValue: 'warm'), 'warm');
    });

    nyTest('coerces numeric and boolean strings', () async {
      final CommandResult result = CommandResult({
        'count': '5',
        'ratio': '0.5',
        'enabled': 'true',
        'disabled': 'false',
        'exact': 7,
      });

      expect(result.getInt('count'), 5);
      expect(result.getDouble('ratio'), 0.5);
      expect(result.getDouble('exact'), 7.0);
      expect(result.getBool('enabled'), isTrue);
      expect(result.getBool('disabled'), isFalse);
      expect(result.getInt('missing', defaultValue: 3), 3);
      expect(result.getInt('ratio'), isNull);
    });

    nyTest('get<T> only returns values of the requested type', () async {
      final CommandResult result = CommandResult({'count': 5});

      expect(result.get<int>('count'), 5);
      expect(result.get<String>('count'), isNull);
    });

    nyTest('exposes positional arguments', () async {
      final CommandResult result = CommandResult({}, rest: ['a', 'b']);

      expect(result.rest, ['a', 'b']);
    });
  });

  nyGroup('LiveCommand', () {
    nyTest('collects output lines with their level', () async {
      final _GreetCommand command = _GreetCommand();

      await command.handle(CommandResult({'name': 'Sam'}));

      expect(command.output, [
        {'level': 'info', 'message': 'Greeting Sam'},
        {'level': 'success', 'message': 'Hello'},
        {'level': 'warning', 'message': 'Careful'},
        {'level': 'error', 'message': 'Oops'},
        {'level': 'line', 'message': 'Plain'},
      ]);
      expect(command.description, 'Say hello');
    });
  });
}
