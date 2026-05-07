import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  // ===========================================================================
  // Position
  // ===========================================================================

  nyGroup('Str.after', () {
    nyTest('returns portion after first occurrence', () async {
      expect(Str.after('hello world hello', 'hello'), ' world hello');
    });
    nyTest('returns subject when search not found', () async {
      expect(Str.after('hello', 'xyz'), 'hello');
    });
    nyTest('returns subject when search is empty', () async {
      expect(Str.after('hello', ''), 'hello');
    });
  });

  nyGroup('Str.afterLast', () {
    nyTest('returns portion after last occurrence', () async {
      expect(Str.afterLast('app/Http/Controllers', '/'), 'Controllers');
    });
    nyTest('returns subject when search not found', () async {
      expect(Str.afterLast('hello', 'x'), 'hello');
    });
  });

  nyGroup('Str.before', () {
    nyTest('returns portion before first occurrence', () async {
      expect(Str.before('hello world hello', 'world'), 'hello ');
    });
    nyTest('returns subject when search not found', () async {
      expect(Str.before('hello', 'x'), 'hello');
    });
  });

  nyGroup('Str.beforeLast', () {
    nyTest('returns portion before last occurrence', () async {
      expect(Str.beforeLast('app/Http/Controllers', '/'), 'app/Http');
    });
  });

  nyGroup('Str.between', () {
    nyTest('returns portion between values (greedy)', () async {
      expect(Str.between('[a] foo [b] bar [c]', '[', ']'), 'a] foo [b] bar [c');
    });
    nyTest('returns subject when delimiters empty', () async {
      expect(Str.between('hello', '', ']'), 'hello');
    });
  });

  nyGroup('Str.betweenFirst', () {
    nyTest('returns smallest portion between values', () async {
      expect(Str.betweenFirst('[a] foo [b]', '[', ']'), 'a');
    });
  });

  // ===========================================================================
  // Search
  // ===========================================================================

  nyGroup('Str.contains', () {
    nyTest('returns true when haystack contains needle', () async {
      expect(Str.contains('hello world', 'world'), isTrue);
    });
    nyTest('returns false when haystack does not contain needle', () async {
      expect(Str.contains('hello world', 'xyz'), isFalse);
    });
    nyTest('accepts a list of needles', () async {
      expect(Str.contains('hello world', ['xyz', 'world']), isTrue);
    });
    nyTest('respects ignoreCase flag', () async {
      expect(Str.contains('Hello World', 'world', ignoreCase: true), isTrue);
      expect(Str.contains('Hello World', 'world'), isFalse);
    });
    nyTest('returns false for empty needle', () async {
      expect(Str.contains('hello', ''), isFalse);
    });
  });

  nyGroup('Str.containsAll', () {
    nyTest('returns true when haystack contains all needles', () async {
      expect(Str.containsAll('hello world', ['hello', 'world']), isTrue);
    });
    nyTest('returns false when one needle missing', () async {
      expect(Str.containsAll('hello world', ['hello', 'xyz']), isFalse);
    });
  });

  nyGroup('Str.startsWith', () {
    nyTest('returns true when haystack starts with needle', () async {
      expect(Str.startsWith('hello world', 'hello'), isTrue);
    });
    nyTest('accepts a list of needles', () async {
      expect(Str.startsWith('hello world', ['xyz', 'hello']), isTrue);
    });
    nyTest('returns false when no match', () async {
      expect(Str.startsWith('hello', ['xyz']), isFalse);
    });
  });

  nyGroup('Str.endsWith', () {
    nyTest('returns true when haystack ends with needle', () async {
      expect(Str.endsWith('hello world', 'world'), isTrue);
    });
    nyTest('accepts a list of needles', () async {
      expect(Str.endsWith('hello world', ['xyz', 'world']), isTrue);
    });
  });

  nyGroup('Str.is_', () {
    nyTest('matches exact pattern', () async {
      expect(Str.is_('foo', 'foo'), isTrue);
    });
    nyTest('matches wildcard pattern', () async {
      expect(Str.is_('foo.*', 'foo.bar'), isTrue);
      expect(Str.is_('admin/*', 'admin/users'), isTrue);
    });
    nyTest('returns false when pattern does not match', () async {
      expect(Str.is_('foo.*', 'bar.foo'), isFalse);
    });
    nyTest('accepts a list of patterns', () async {
      expect(Str.is_(['admin/*', 'user/*'], 'admin/profile'), isTrue);
    });
  });

  // ===========================================================================
  // Case conversions
  // ===========================================================================

  nyGroup('case conversions', () {
    nyTest('camel converts to camelCase', () async {
      expect(Str.camel('foo_bar'), 'fooBar');
      expect(Str.camel('foo bar baz'), 'fooBarBaz');
    });
    nyTest('snake converts to snake_case', () async {
      expect(Str.snake('fooBar'), 'foo_bar');
      expect(Str.snake('FooBarBaz'), 'foo_bar_baz');
    });
    nyTest('snake supports custom delimiter', () async {
      expect(Str.snake('fooBar', '-'), 'foo-bar');
    });
    nyTest('kebab converts to kebab-case', () async {
      expect(Str.kebab('fooBar'), 'foo-bar');
    });
    nyTest('studly converts to PascalCase', () async {
      expect(Str.studly('foo_bar'), 'FooBar');
    });
    nyTest('title converts to Title Case', () async {
      expect(Str.title('hello world'), 'Hello World');
    });
    nyTest('headline expands and title-cases', () async {
      expect(Str.headline('helloWorld_foo-bar'), 'Hello World Foo Bar');
    });
    nyTest('lower lowercases', () async {
      expect(Str.lower('HELLO'), 'hello');
    });
    nyTest('upper uppercases', () async {
      expect(Str.upper('hello'), 'HELLO');
    });
    nyTest('ucfirst uppercases first character', () async {
      expect(Str.ucfirst('hello world'), 'Hello world');
      expect(Str.ucfirst(''), '');
    });
    nyTest('lcfirst lowercases first character', () async {
      expect(Str.lcfirst('Hello World'), 'hello World');
      expect(Str.lcfirst(''), '');
    });
  });

  // ===========================================================================
  // Trimming / capping
  // ===========================================================================

  nyGroup('Str.limit', () {
    nyTest('truncates and appends end', () async {
      expect(Str.limit('The quick brown fox', 9), 'The quick...');
    });
    nyTest('returns value when shorter than limit', () async {
      expect(Str.limit('hi', 9), 'hi');
    });
    nyTest('uses custom end string', () async {
      expect(Str.limit('hello world', 5, '…'), 'hello…');
    });
  });

  nyGroup('Str.words', () {
    nyTest('limits to given number of words', () async {
      expect(Str.words('one two three four', 2), 'one two...');
    });
    nyTest('returns value when fewer words than limit', () async {
      expect(Str.words('one two', 5), 'one two');
    });
  });

  nyGroup('Str.finish', () {
    nyTest('appends cap when missing', () async {
      expect(Str.finish('path/to', '/'), 'path/to/');
    });
    nyTest('does not duplicate cap', () async {
      expect(Str.finish('path/to/', '/'), 'path/to/');
      expect(Str.finish('path/to///', '/'), 'path/to/');
    });
  });

  nyGroup('Str.start', () {
    nyTest('prepends prefix when missing', () async {
      expect(Str.start('path', '/'), '/path');
    });
    nyTest('does not duplicate prefix', () async {
      expect(Str.start('//path', '/'), '/path');
    });
  });

  nyGroup('Str.wrap', () {
    nyTest('wraps with single delimiter', () async {
      expect(Str.wrap('hello', '"'), '"hello"');
    });
    nyTest('wraps with separate before and after', () async {
      expect(Str.wrap('hello', '<', '>'), '<hello>');
    });
  });

  nyGroup('Str.squish', () {
    nyTest('collapses whitespace', () async {
      expect(Str.squish('  hello   world  '), 'hello world');
    });
    nyTest('handles tabs and newlines', () async {
      expect(Str.squish('hello\t\nworld'), 'hello world');
    });
  });

  // ===========================================================================
  // Replace / remove
  // ===========================================================================

  nyGroup('Str.replace', () {
    nyTest('replaces all occurrences of a string', () async {
      expect(Str.replace('foo', 'bar', 'foo baz foo'), 'bar baz bar');
    });
    nyTest('replaces using parallel lists', () async {
      expect(
        Str.replace(['foo', 'baz'], ['FOO', 'BAZ'], 'foo bar baz'),
        'FOO bar BAZ',
      );
    });
  });

  nyGroup('Str.replaceFirst', () {
    nyTest('replaces only first occurrence', () async {
      expect(Str.replaceFirst('foo', 'X', 'foo foo foo'), 'X foo foo');
    });
    nyTest('returns subject when search not found', () async {
      expect(Str.replaceFirst('xyz', 'X', 'foo'), 'foo');
    });
  });

  nyGroup('Str.replaceLast', () {
    nyTest('replaces only last occurrence', () async {
      expect(Str.replaceLast('foo', 'X', 'foo foo foo'), 'foo foo X');
    });
  });

  nyGroup('Str.remove', () {
    nyTest('removes a string from subject', () async {
      expect(Str.remove(' ', 'hello world'), 'helloworld');
    });
    nyTest('removes a list of strings', () async {
      expect(Str.remove(['a', 'e', 'i', 'o', 'u'], 'hello world'), 'hll wrld');
    });
    nyTest('respects caseSensitive flag', () async {
      expect(Str.remove('HELLO', 'hello world'), 'hello world');
      expect(
        Str.remove('HELLO', 'hello world', caseSensitive: false),
        ' world',
      );
    });
  });

  // ===========================================================================
  // Slug
  // ===========================================================================

  nyGroup('Str.slug', () {
    nyTest('converts a title to a slug', () async {
      expect(Str.slug('Hello World'), 'hello-world');
    });
    nyTest('strips special characters', () async {
      expect(Str.slug('Hello, World!'), 'hello-world');
    });
    nyTest('uses custom separator', () async {
      expect(Str.slug('Hello World', separator: '_'), 'hello_world');
    });
    nyTest('replaces @ with at by default', () async {
      expect(Str.slug('me@example'), 'me-at-example');
    });
    nyTest('respects custom dictionary', () async {
      expect(
        Str.slug('Cats & Dogs', dictionary: {'&': 'and'}),
        'cats-and-dogs',
      );
    });
    nyTest('preserves unicode letters', () async {
      expect(Str.slug('Über Café'), 'über-café');
    });
  });

  // ===========================================================================
  // Padding
  // ===========================================================================

  nyGroup('Str.padBoth', () {
    nyTest('pads both sides to given length', () async {
      expect(Str.padBoth('hi', 6, '-'), '--hi--');
    });
    nyTest('returns value when already at length', () async {
      expect(Str.padBoth('hello', 5), 'hello');
    });
    nyTest('handles uneven padding', () async {
      expect(Str.padBoth('hi', 5, '-'), '-hi--');
    });
  });

  nyGroup('Str.padLeft', () {
    nyTest('pads left side', () async {
      expect(Str.padLeft('hi', 5, '-'), '---hi');
    });
  });

  nyGroup('Str.padRight', () {
    nyTest('pads right side', () async {
      expect(Str.padRight('hi', 5, '-'), 'hi---');
    });
  });

  // ===========================================================================
  // Substring / chars
  // ===========================================================================

  nyGroup('Str.substr', () {
    nyTest('returns substring from start', () async {
      expect(Str.substr('hello world', 6), 'world');
    });
    nyTest('returns substring with length', () async {
      expect(Str.substr('hello world', 0, 5), 'hello');
    });
    nyTest('handles negative start', () async {
      expect(Str.substr('hello world', -5), 'world');
    });
  });

  nyGroup('Str.take', () {
    nyTest('takes first n characters', () async {
      expect(Str.take('hello world', 5), 'hello');
    });
    nyTest('takes last n characters when negative', () async {
      expect(Str.take('hello world', -5), 'world');
    });
    nyTest('returns full string when limit exceeds length', () async {
      expect(Str.take('hi', 10), 'hi');
    });
  });

  nyGroup('Str.charAt', () {
    nyTest('returns character at index', () async {
      expect(Str.charAt('hello', 1), 'e');
    });
    nyTest('returns character from end with negative index', () async {
      expect(Str.charAt('hello', -1), 'o');
    });
    nyTest('returns null when out of bounds', () async {
      expect(Str.charAt('hello', 99), isNull);
    });
  });

  nyGroup('Str.reverse', () {
    nyTest('reverses a string', () async {
      expect(Str.reverse('hello'), 'olleh');
    });
    nyTest('handles empty string', () async {
      expect(Str.reverse(''), '');
    });
  });

  nyGroup('Str.repeat', () {
    nyTest('repeats a string', () async {
      expect(Str.repeat('ab', 3), 'ababab');
    });
  });

  nyGroup('Str.length', () {
    nyTest('returns string length', () async {
      expect(Str.length('hello'), 5);
    });
  });

  nyGroup('Str.wordCount', () {
    nyTest('counts words', () async {
      expect(Str.wordCount('hello world foo'), 3);
    });
    nyTest('returns 0 for empty string', () async {
      expect(Str.wordCount('   '), 0);
    });
    nyTest('handles multiple spaces', () async {
      expect(Str.wordCount('hello   world'), 2);
    });
  });

  // ===========================================================================
  // Mask
  // ===========================================================================

  nyGroup('Str.mask', () {
    nyTest('masks from index to end', () async {
      expect(Str.mask('agordn52@gmail.com', '*', 3), 'ago***************');
    });
    nyTest('masks specific length', () async {
      expect(Str.mask('agordn52@gmail.com', '*', 3, 5), 'ago*****@gmail.com');
    });
    nyTest('returns string when index out of range', () async {
      expect(Str.mask('hello', '*', 99), 'hello');
    });
    nyTest('returns string when character is empty', () async {
      expect(Str.mask('hello', '', 1), 'hello');
    });
  });

  // ===========================================================================
  // Random / IDs
  // ===========================================================================

  nyGroup('Str.random', () {
    nyTest('generates string of given length', () async {
      expect(Str.random(16).length, 16);
      expect(Str.random(32).length, 32);
    });
    nyTest('only contains alphanumeric chars', () async {
      expect(RegExp(r'^[a-zA-Z0-9]+$').hasMatch(Str.random(50)), isTrue);
    });
    nyTest('produces different values each call', () async {
      expect(Str.random(20), isNot(equals(Str.random(20))));
    });
    nyTest('defaults to length 16', () async {
      expect(Str.random().length, 16);
    });
  });

  nyGroup('Str.uuid', () {
    nyTest('generates valid UUID v4', () async {
      final uuid = Str.uuid();
      expect(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-'
          r'[0-9a-f]{12}$',
        ).hasMatch(uuid),
        isTrue,
      );
    });
    nyTest('produces unique values', () async {
      expect(Str.uuid(), isNot(equals(Str.uuid())));
    });
  });

  nyGroup('Str.ulid', () {
    nyTest('generates 26-character ULID', () async {
      expect(Str.ulid().length, 26);
    });
    nyTest('only uses valid Crockford base32 alphabet', () async {
      expect(RegExp(r'^[0-9A-HJKMNP-TV-Z]{26}$').hasMatch(Str.ulid()), isTrue);
    });
    nyTest('produces unique values', () async {
      expect(Str.ulid(), isNot(equals(Str.ulid())));
    });
  });

  // ===========================================================================
  // Validation
  // ===========================================================================

  nyGroup('Str.isAscii', () {
    nyTest('returns true for ASCII string', () async {
      expect(Str.isAscii('hello world'), isTrue);
    });
    nyTest('returns false for non-ASCII string', () async {
      expect(Str.isAscii('héllo'), isFalse);
      expect(Str.isAscii('你好'), isFalse);
    });
  });

  nyGroup('Str.isJson', () {
    nyTest('returns true for valid JSON object', () async {
      expect(Str.isJson('{"a":1}'), isTrue);
    });
    nyTest('returns true for valid JSON array', () async {
      expect(Str.isJson('[1,2,3]'), isTrue);
    });
    nyTest('returns false for invalid JSON', () async {
      expect(Str.isJson('{a:1}'), isFalse);
      expect(Str.isJson('not json'), isFalse);
    });
  });

  nyGroup('Str.isUrl', () {
    nyTest('returns true for valid URL', () async {
      expect(Str.isUrl('https://example.com'), isTrue);
      expect(Str.isUrl('http://example.com/path?q=1'), isTrue);
    });
    nyTest('returns false for invalid URL', () async {
      expect(Str.isUrl('not a url'), isFalse);
      expect(Str.isUrl('example.com'), isFalse);
    });
  });

  nyGroup('Str.isUuid', () {
    nyTest('returns true for valid UUID', () async {
      expect(Str.isUuid(Str.uuid()), isTrue);
      expect(Str.isUuid('6ba7b810-9dad-11d1-80b4-00c04fd430c8'), isTrue);
    });
    nyTest('returns false for invalid UUID', () async {
      expect(Str.isUuid('not-a-uuid'), isFalse);
      expect(Str.isUuid('6ba7b810-9dad-11d1-80b4'), isFalse);
    });
  });

  nyGroup('Str.isUlid', () {
    nyTest('returns true for valid ULID', () async {
      expect(Str.isUlid(Str.ulid()), isTrue);
    });
    nyTest('returns false for invalid ULID', () async {
      expect(Str.isUlid('not-a-ulid'), isFalse);
      expect(Str.isUlid('TOO_SHORT'), isFalse);
    });
  });

  // ===========================================================================
  // New helpers
  // ===========================================================================

  nyGroup('Str.position', () {
    nyTest('returns index of first occurrence', () async {
      expect(Str.position('hello world', 'world'), 6);
    });
    nyTest('returns null when not found', () async {
      expect(Str.position('hello', 'xyz'), isNull);
    });
    nyTest('returns null for empty needle', () async {
      expect(Str.position('hello', ''), isNull);
    });
    nyTest('respects offset', () async {
      expect(Str.position('hello hello', 'hello', offset: 1), 6);
    });
  });

  nyGroup('Str.substrCount', () {
    nyTest('counts non-overlapping occurrences', () async {
      expect(Str.substrCount('hello hello hello', 'hello'), 3);
    });
    nyTest('returns 0 when not found', () async {
      expect(Str.substrCount('hello', 'xyz'), 0);
    });
    nyTest('returns 0 for empty needle', () async {
      expect(Str.substrCount('hello', ''), 0);
    });
    nyTest('does not double-count overlaps', () async {
      expect(Str.substrCount('aaaa', 'aa'), 2);
    });
  });

  nyGroup('Str.match', () {
    nyTest('returns first regex match', () async {
      expect(Str.match(RegExp(r'\d+'), 'a1b22c333'), '1');
    });
    nyTest('accepts string pattern', () async {
      expect(Str.match(r'\d+', 'a42b'), '42');
    });
    nyTest('returns null when no match', () async {
      expect(Str.match(RegExp(r'\d+'), 'abc'), isNull);
    });
  });

  nyGroup('Str.matchAll', () {
    nyTest('returns all matches', () async {
      expect(Str.matchAll(RegExp(r'\d+'), 'a1b22c333'), ['1', '22', '333']);
    });
    nyTest('returns empty list when no matches', () async {
      expect(Str.matchAll(RegExp(r'\d+'), 'abc'), isEmpty);
    });
  });

  nyGroup('Str.excerpt', () {
    nyTest('extracts snippet around phrase', () async {
      final text = 'The quick brown fox jumps over the lazy dog';
      expect(Str.excerpt(text, 'fox', radius: 4), '...own fox jum...');
    });
    nyTest('omits prefix when at start', () async {
      expect(Str.excerpt('hello world', 'hello', radius: 3), 'hello wo...');
    });
    nyTest('omits suffix when at end', () async {
      expect(Str.excerpt('hello world', 'world', radius: 3), '...lo world');
    });
    nyTest('returns null when phrase not found', () async {
      expect(Str.excerpt('hello world', 'xyz'), isNull);
    });
    nyTest('uses custom omission', () async {
      expect(
        Str.excerpt('hello world hello', 'world', radius: 2, omission: '…'),
        '…o world h…',
      );
    });
  });

  nyGroup('Str.unwrap', () {
    nyTest('strips matching wrapper', () async {
      expect(Str.unwrap('"hello"', '"'), 'hello');
    });
    nyTest('strips different before/after', () async {
      expect(Str.unwrap('<hello>', '<', '>'), 'hello');
    });
    nyTest('leaves value when wrappers absent', () async {
      expect(Str.unwrap('hello', '"'), 'hello');
    });
    nyTest('only strips one instance', () async {
      expect(Str.unwrap('""hello""', '"'), '"hello"');
    });
  });

  nyGroup('Str.deduplicate', () {
    nyTest('collapses consecutive spaces by default', () async {
      expect(Str.deduplicate('hello    world'), 'hello world');
    });
    nyTest('handles custom character', () async {
      expect(Str.deduplicate('a---b---c', '-'), 'a-b-c');
    });
    nyTest('returns value for empty character', () async {
      expect(Str.deduplicate('hello', ''), 'hello');
    });
  });

  nyGroup('Str.swap', () {
    nyTest('swaps multiple values', () async {
      expect(
        Str.swap({'foo': 'FOO', 'bar': 'BAR'}, 'foo and bar'),
        'FOO and BAR',
      );
    });
    nyTest('returns subject when map empty', () async {
      expect(Str.swap({}, 'hello'), 'hello');
    });
  });

  nyGroup('Str.ucsplit', () {
    nyTest('splits on uppercase boundaries', () async {
      expect(Str.ucsplit('fooBarBaz'), ['foo', 'Bar', 'Baz']);
    });
    nyTest('handles all lowercase', () async {
      expect(Str.ucsplit('hello'), ['hello']);
    });
    nyTest('handles all uppercase', () async {
      expect(Str.ucsplit('ABC'), ['A', 'B', 'C']);
    });
    nyTest('returns empty for empty string', () async {
      expect(Str.ucsplit(''), isEmpty);
    });
  });

  nyGroup('Str.padNumber', () {
    nyTest('pads with leading zeros', () async {
      expect(Str.padNumber('5', 3), '005');
    });
    nyTest('returns value when already at length', () async {
      expect(Str.padNumber('123', 3), '123');
    });
    nyTest('returns value when longer than length', () async {
      expect(Str.padNumber('1234', 3), '1234');
    });
  });

  nyGroup('Str.password', () {
    nyTest('produces string of given length', () async {
      expect(Str.password(20).length, 20);
    });
    nyTest('returns empty for length 0', () async {
      expect(Str.password(0), '');
    });
    nyTest('returns empty when all classes disabled', () async {
      expect(
        Str.password(
          10,
          letters: false,
          numbers: false,
          symbols: false,
          spaces: false,
        ),
        '',
      );
    });
    nyTest('letters-only contains only letters', () async {
      final pw = Str.password(40, numbers: false, symbols: false);
      expect(RegExp(r'^[a-zA-Z]+$').hasMatch(pw), isTrue);
    });
    nyTest('numbers-only contains only digits', () async {
      final pw = Str.password(40, letters: false, symbols: false);
      expect(RegExp(r'^[0-9]+$').hasMatch(pw), isTrue);
    });
    nyTest('produces different values each call', () async {
      expect(Str.password(20), isNot(equals(Str.password(20))));
    });
  });

  nyGroup('Str.uuid7', () {
    nyTest('matches UUID v7 format', () async {
      final id = Str.uuid7();
      expect(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-'
          r'[0-9a-f]{12}$',
        ).hasMatch(id),
        isTrue,
      );
    });
    nyTest('passes generic isUuid validation', () async {
      expect(Str.isUuid(Str.uuid7()), isTrue);
    });
    nyTest('produces unique values', () async {
      expect(Str.uuid7(), isNot(equals(Str.uuid7())));
    });
    nyTest('is time-ordered', () async {
      final a = Str.uuid7();
      await Future.delayed(const Duration(milliseconds: 5));
      final b = Str.uuid7();
      expect(a.compareTo(b) < 0, isTrue);
    });
  });
}
