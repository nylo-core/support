import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/metro/ny_metro.dart';

void main() {
  group('MetroService.addToModelDecoders', () {
    test('adds entries after the existing ones', () {
      const String file = '''
final Map<Type, dynamic> modelDecoders = {
  User: (data) => User.fromJson(data),
};

final Map<Type, dynamic> apiDecoders = {};
''';

      final String? result = MetroService.addToModelDecoders(
        file,
        '  Post: (data) => Post.fromJson(data),\n',
      );

      expect(result, '''
final Map<Type, dynamic> modelDecoders = {
  User: (data) => User.fromJson(data),

  Post: (data) => Post.fromJson(data),
};

final Map<Type, dynamic> apiDecoders = {};
''');
    });

    test('skips braces inside entries, strings and comments', () {
      const String file = '''
final Map<Type, dynamic> modelDecoders = {
  // a } in a comment
  FeedItem: OneOf<FeedItem>.byKey('type', {
    'post': PostItem.fromJson,
    '}': AdItem.fromJson,
  }),
};
''';

      final String? result = MetroService.addToModelDecoders(
        file,
        '  User: (data) => User.fromJson(data),\n',
      );

      expect(result, '''
final Map<Type, dynamic> modelDecoders = {
  // a } in a comment
  FeedItem: OneOf<FeedItem>.byKey('type', {
    'post': PostItem.fromJson,
    '}': AdItem.fromJson,
  }),

  User: (data) => User.fromJson(data),
};
''');
    });

    test('returns null when there is no modelDecoders map', () {
      expect(
        MetroService.addToModelDecoders('final x = {};', '  A: a,\n'),
        isNull,
      );
    });
  });

  group('MetroService.addToDecodersList', () {
    test('detects the list form', () {
      expect(
        MetroService.usesDecodersList(
          'final Map<Type, dynamic> modelDecoders = decoders([\n]);',
        ),
        isTrue,
      );
      expect(
        MetroService.usesDecodersList(
          'final Map<Type, dynamic> modelDecoders = {\n};',
        ),
        isFalse,
      );
    });

    test('adds a Decode line after the existing entries', () {
      const String file = '''
final Map<Type, dynamic> modelDecoders = decoders([
  Decode(User.fromJson),
  OneOf<LoginResult>.byKey('type', {
    'success': LoginSuccess.fromJson,
  }),
]);

final Map<Type, dynamic> apiDecoders = {};
''';

      expect(
        MetroService.addToDecodersList(file, '  Decode(Post.fromJson),\n'),
        '''
final Map<Type, dynamic> modelDecoders = decoders([
  Decode(User.fromJson),
  OneOf<LoginResult>.byKey('type', {
    'success': LoginSuccess.fromJson,
  }),
  Decode(Post.fromJson),
]);

final Map<Type, dynamic> apiDecoders = {};
''',
      );
    });

    test('adds to an empty list', () {
      expect(
        MetroService.addToDecodersList(
          'final Map<Type, dynamic> modelDecoders = decoders([]);',
          '  Decode(Post.fromJson),\n',
        ),
        'final Map<Type, dynamic> modelDecoders = decoders([\n  Decode(Post.fromJson),\n]);',
      );
    });

    test('adds a comma after the last entry, above a comment line', () {
      const String file = '''
final Map<Type, dynamic> modelDecoders = decoders([
  Decode(User.fromJson)
  // more to come
]);''';

      expect(
        MetroService.addToDecodersList(file, '  Decode(Post.fromJson),\n'),
        '''
final Map<Type, dynamic> modelDecoders = decoders([
  Decode(User.fromJson),
  // more to come
  Decode(Post.fromJson),
]);''',
      );
    });

    test('adds a comma on its own line after an inline comment', () {
      const String file = '''
final Map<Type, dynamic> modelDecoders = decoders([
  Decode(User.fromJson) // the signed-in user
]);''';

      expect(
        MetroService.addToDecodersList(file, '  Decode(Post.fromJson),\n'),
        '''
final Map<Type, dynamic> modelDecoders = decoders([
  Decode(User.fromJson) // the signed-in user
,
  Decode(Post.fromJson),
]);''',
      );
    });
  });
}
