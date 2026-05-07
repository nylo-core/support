import 'dart:convert';
import 'dart:math';

import 'package:recase/recase.dart';

/// Static utility methods for string manipulation.
///
/// ```dart
/// Str.slug('Hello World');         // 'hello-world'
/// Str.camel('foo_bar');             // 'fooBar'
/// Str.limit('A long sentence', 6);  // 'A long...'
/// Str.uuid();                       // '6ba7b810-9dad-4...'
/// ```
///
/// Available helpers:
///
/// Search / position:
///   - [after], [afterLast], [before], [beforeLast]
///   - [between], [betweenFirst]
///   - [contains], [containsAll], [startsWith], [endsWith]
///   - [is_], [position], [substrCount]
///   - [match], [matchAll], [excerpt]
///
/// Case conversions:
///   - [camel], [snake], [kebab], [studly], [title], [headline]
///   - [lower], [upper], [ucfirst], [lcfirst]
///
/// Trimming / capping:
///   - [limit], [words], [finish], [start], [wrap], [unwrap], [squish]
///
/// Replace / remove / transform:
///   - [replace], [replaceFirst], [replaceLast], [remove]
///   - [swap], [deduplicate], [ucsplit]
///
/// Slug:
///   - [slug]
///
/// Padding:
///   - [padBoth], [padLeft], [padRight], [padNumber]
///
/// Substring / chars:
///   - [substr], [take], [charAt], [reverse], [repeat]
///   - [length], [wordCount]
///
/// Mask:
///   - [mask]
///
/// Random / IDs:
///   - [random], [password], [uuid], [uuid7], [ulid]
///
/// Validation:
///   - [isAscii], [isJson], [isUrl], [isUuid], [isUlid]
class Str {
  Str._();

  static final Random _random = Random.secure();

  // ---------------------------------------------------------------------------
  // Search / position
  // ---------------------------------------------------------------------------

  /// Returns the portion of [subject] after the first occurrence of [search].
  /// Returns [subject] unchanged if [search] is empty or not found.
  static String after(String subject, String search) {
    if (search.isEmpty) return subject;
    final index = subject.indexOf(search);
    if (index == -1) return subject;
    return subject.substring(index + search.length);
  }

  /// Returns the portion of [subject] after the last occurrence of [search].
  static String afterLast(String subject, String search) {
    if (search.isEmpty) return subject;
    final index = subject.lastIndexOf(search);
    if (index == -1) return subject;
    return subject.substring(index + search.length);
  }

  /// Returns the portion of [subject] before the first occurrence of [search].
  static String before(String subject, String search) {
    if (search.isEmpty) return subject;
    final index = subject.indexOf(search);
    if (index == -1) return subject;
    return subject.substring(0, index);
  }

  /// Returns the portion of [subject] before the last occurrence of [search].
  static String beforeLast(String subject, String search) {
    if (search.isEmpty) return subject;
    final index = subject.lastIndexOf(search);
    if (index == -1) return subject;
    return subject.substring(0, index);
  }

  /// Returns the portion of [subject] between [from] and [to].
  static String between(String subject, String from, String to) {
    if (from.isEmpty || to.isEmpty) return subject;
    return beforeLast(after(subject, from), to);
  }

  /// Returns the smallest portion of [subject] between [from] and [to].
  static String betweenFirst(String subject, String from, String to) {
    if (from.isEmpty || to.isEmpty) return subject;
    return before(after(subject, from), to);
  }

  /// Determines if [haystack] contains any of the [needles].
  static bool contains(
    String haystack,
    dynamic needles, {
    bool ignoreCase = false,
  }) {
    final h = ignoreCase ? haystack.toLowerCase() : haystack;
    final list = needles is List ? needles : [needles];
    for (final n in list) {
      final s = ignoreCase ? n.toString().toLowerCase() : n.toString();
      if (s.isNotEmpty && h.contains(s)) return true;
    }
    return false;
  }

  /// Determines if [haystack] contains all the [needles].
  static bool containsAll(
    String haystack,
    List needles, {
    bool ignoreCase = false,
  }) {
    for (final n in needles) {
      if (!contains(haystack, n, ignoreCase: ignoreCase)) return false;
    }
    return true;
  }

  /// Determines if [haystack] starts with any of the [needles].
  static bool startsWith(String haystack, dynamic needles) {
    final list = needles is List ? needles : [needles];
    for (final n in list) {
      final s = n.toString();
      if (s.isNotEmpty && haystack.startsWith(s)) return true;
    }
    return false;
  }

  /// Determines if [haystack] ends with any of the [needles].
  static bool endsWith(String haystack, dynamic needles) {
    final list = needles is List ? needles : [needles];
    for (final n in list) {
      final s = n.toString();
      if (s.isNotEmpty && haystack.endsWith(s)) return true;
    }
    return false;
  }

  /// Determines if [value] matches the given [pattern]. Asterisks are wildcards.
  ///
  /// ```dart
  /// Str.is_('foo.*', 'foo.bar'); // true
  /// Str.is_(['admin/*', 'user/*'], 'admin/profile'); // true
  /// ```
  // ignore: non_constant_identifier_names
  static bool is_(dynamic pattern, String value) {
    final patterns = pattern is List ? pattern : [pattern];
    for (final p in patterns) {
      final s = p.toString();
      if (s == value) return true;
      final escaped = RegExp.escape(s).replaceAll(r'\*', '.*');
      if (RegExp('^$escaped\$').hasMatch(value)) return true;
    }
    return false;
  }

  // ---------------------------------------------------------------------------
  // Case conversions (via recase)
  // ---------------------------------------------------------------------------

  /// Converts [value] to camelCase.
  static String camel(String value) => value.camelCase;

  /// Converts [value] to snake_case (or with custom [delimiter]).
  static String snake(String value, [String delimiter = '_']) {
    final snake = value.snakeCase;
    return delimiter == '_' ? snake : snake.replaceAll('_', delimiter);
  }

  /// Converts [value] to kebab-case.
  static String kebab(String value) => value.paramCase;

  /// Converts [value] to StudlyCase / PascalCase.
  static String studly(String value) => value.pascalCase;

  /// Converts [value] to "Title Case".
  static String title(String value) => value.titleCase;

  /// Converts [value] to a "Headline" — words split, then title cased.
  static String headline(String value) {
    final parts = value.trim().split(RegExp(r'[\s_-]+'))
      ..removeWhere((p) => p.isEmpty);
    final expanded = parts
        .map(
          (p) => p.replaceAllMapped(
            RegExp(r'([a-z])([A-Z])'),
            (m) => '${m[1]} ${m[2]}',
          ),
        )
        .join(' ');
    return title(expanded);
  }

  /// Lowercases [value].
  static String lower(String value) => value.toLowerCase();

  /// Uppercases [value].
  static String upper(String value) => value.toUpperCase();

  /// Uppercases the first character of [value].
  static String ucfirst(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';

  /// Lowercases the first character of [value].
  static String lcfirst(String value) =>
      value.isEmpty ? value : '${value[0].toLowerCase()}${value.substring(1)}';

  // ---------------------------------------------------------------------------
  // Trimming / capping
  // ---------------------------------------------------------------------------

  /// Truncates [value] to [limit] characters and appends [end].
  static String limit(String value, [int limit = 100, String end = '...']) {
    if (value.length <= limit) return value;
    return '${value.substring(0, limit).trimRight()}$end';
  }

  /// Limits [value] to a number of [words].
  static String words(String value, [int words = 100, String end = '...']) {
    final match = RegExp(
      r'^\s*(?:\S+\s*){1,' + words.toString() + r'}',
    ).firstMatch(value);
    if (match == null || match.group(0)!.length >= value.length) return value;
    return '${match.group(0)!.trimRight()}$end';
  }

  /// Caps [value] with a single instance of [cap].
  static String finish(String value, String cap) {
    if (cap.isEmpty) return value;
    final stripped = value.replaceAll(RegExp(RegExp.escape(cap) + r'+$'), '');
    return '$stripped$cap';
  }

  /// Begins [value] with a single instance of [prefix].
  static String start(String value, String prefix) {
    if (prefix.isEmpty) return value;
    final stripped = value.replaceAll(
      RegExp('^(?:${RegExp.escape(prefix)})+'),
      '',
    );
    return '$prefix$stripped';
  }

  /// Wraps [value] with [before] and [after] (or just [before] if [after] is null).
  static String wrap(String value, String before, [String? after]) =>
      '$before$value${after ?? before}';

  /// Removes all whitespace and collapses internal whitespace into single spaces.
  static String squish(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ');

  // ---------------------------------------------------------------------------
  // Replace / remove
  // ---------------------------------------------------------------------------

  /// Replaces every occurrence of [search] with [replace] in [subject].
  static String replace(dynamic search, dynamic replace, String subject) {
    final searches = search is List ? search : [search];
    final replaces = replace is List ? replace : [replace];
    var result = subject;
    for (var i = 0; i < searches.length; i++) {
      final r = i < replaces.length
          ? replaces[i].toString()
          : (replaces.isNotEmpty ? replaces.last.toString() : '');
      result = result.replaceAll(searches[i].toString(), r);
    }
    return result;
  }

  /// Replaces the first occurrence of [search] with [replace] in [subject].
  static String replaceFirst(String search, String replace, String subject) {
    if (search.isEmpty) return subject;
    final index = subject.indexOf(search);
    if (index == -1) return subject;
    return subject.replaceFirst(search, replace, index);
  }

  /// Replaces the last occurrence of [search] with [replace] in [subject].
  static String replaceLast(String search, String replace, String subject) {
    if (search.isEmpty) return subject;
    final index = subject.lastIndexOf(search);
    if (index == -1) return subject;
    return subject.replaceFirst(search, replace, index);
  }

  /// Removes any of [search] from [subject].
  static String remove(
    dynamic search,
    String subject, {
    bool caseSensitive = true,
  }) {
    final list = search is List ? search : [search];
    var result = subject;
    for (final s in list) {
      final str = s.toString();
      if (str.isEmpty) continue;
      result = caseSensitive
          ? result.replaceAll(str, '')
          : result.replaceAll(
              RegExp(RegExp.escape(str), caseSensitive: false),
              '',
            );
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Slug
  // ---------------------------------------------------------------------------

  /// Generates a URL-friendly slug from [title].
  static String slug(
    String title, {
    String separator = '-',
    Map<String, String>? dictionary,
  }) {
    var t = title;
    final dict = {'@': 'at', ...?dictionary};
    dict.forEach((k, v) {
      t = t.replaceAll(k, ' $v ');
    });
    t = t.toLowerCase();
    t = t.replaceAll(RegExp(r'[^\p{L}\p{N}\s_-]+', unicode: true), '');
    final sep = RegExp.escape(separator);
    t = t.replaceAll(RegExp('[\\s${sep}_]+'), separator);
    t = t.replaceAll(RegExp('^$sep+|$sep+\$'), '');
    return t;
  }

  // ---------------------------------------------------------------------------
  // Padding
  // ---------------------------------------------------------------------------

  /// Pads both sides of [value] with [pad] until [length] is reached.
  static String padBoth(String value, int length, [String pad = ' ']) {
    if (value.length >= length || pad.isEmpty) return value;
    final short = length - value.length;
    final leftLen = (short / 2).floor();
    final rightLen = short - leftLen;
    return '${_repeatToLen(pad, leftLen)}$value${_repeatToLen(pad, rightLen)}';
  }

  /// Pads the left side of [value].
  static String padLeft(String value, int length, [String pad = ' ']) {
    if (value.length >= length || pad.isEmpty) return value;
    return '${_repeatToLen(pad, length - value.length)}$value';
  }

  /// Pads the right side of [value].
  static String padRight(String value, int length, [String pad = ' ']) {
    if (value.length >= length || pad.isEmpty) return value;
    return '$value${_repeatToLen(pad, length - value.length)}';
  }

  static String _repeatToLen(String pad, int len) {
    final buffer = StringBuffer();
    while (buffer.length < len) {
      buffer.write(pad);
    }
    return buffer.toString().substring(0, len);
  }

  // ---------------------------------------------------------------------------
  // Substring / chars
  // ---------------------------------------------------------------------------

  /// Returns a substring of [value] starting at [start] for [length] chars.
  static String substr(String value, int start, [int? length]) {
    var s = start < 0 ? value.length + start : start;
    if (s < 0) s = 0;
    if (s > value.length) return '';
    final end = length == null
        ? value.length
        : (s + length).clamp(s, value.length);
    return value.substring(s, end);
  }

  /// Returns the first [limit] characters of [value].
  static String take(String value, int limit) {
    if (limit < 0) {
      final start = value.length + limit;
      return start < 0 ? value : value.substring(start);
    }
    return value.length <= limit ? value : value.substring(0, limit);
  }

  /// Returns the character at [index] (negative indexes count from the end).
  static String? charAt(String subject, int index) {
    final i = index < 0 ? subject.length + index : index;
    if (i < 0 || i >= subject.length) return null;
    return subject[i];
  }

  /// Reverses [value].
  static String reverse(String value) =>
      String.fromCharCodes(value.runes.toList().reversed);

  /// Repeats [value] [times] times.
  static String repeat(String value, int times) => value * times;

  /// Returns the length of [value].
  static int length(String value) => value.length;

  /// Returns the word count of [value].
  static int wordCount(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  // ---------------------------------------------------------------------------
  // Mask
  // ---------------------------------------------------------------------------

  /// Masks a portion of [string] with [character], starting at [index] for [length].
  ///
  /// ```dart
  /// Str.mask('user@example.com', '*', 3);    // 'use*************'
  /// Str.mask('user@example.com', '*', 3, 5); // 'use*****mple.com'
  /// ```
  static String mask(
    String string,
    String character,
    int index, [
    int? length,
  ]) {
    if (character.isEmpty) return string;
    final start = index < 0 ? string.length + index : index;
    if (start >= string.length) return string;
    final end = length == null
        ? string.length
        : (start + length.abs()).clamp(start, string.length);
    final maskLen = end - start;
    return string.substring(0, start) +
        character[0] * maskLen +
        string.substring(end);
  }

  // ---------------------------------------------------------------------------
  // Random / IDs
  // ---------------------------------------------------------------------------

  static const String _alphaNum =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  /// Generates a cryptographically random alphanumeric string of [length].
  static String random([int length = 16]) {
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(_alphaNum[_random.nextInt(_alphaNum.length)]);
    }
    return buffer.toString();
  }

  /// Generates a random UUID v4.
  static String uuid() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant 10
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  /// Generates a ULID (Universally Unique Lexicographically Sortable Identifier).
  static String ulid() {
    const encoding = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
    var time = DateTime.now().millisecondsSinceEpoch;
    final timePart = StringBuffer();
    for (var i = 0; i < 10; i++) {
      timePart.write(encoding[time % 32]);
      time = time ~/ 32;
    }
    final randomPart = StringBuffer();
    for (var i = 0; i < 16; i++) {
      randomPart.write(encoding[_random.nextInt(32)]);
    }
    return '${String.fromCharCodes(timePart.toString().codeUnits.reversed)}'
        '$randomPart';
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  /// Returns true if [value] is 7-bit ASCII.
  static bool isAscii(String value) => !RegExp(r'[^\x00-\x7F]').hasMatch(value);

  /// Returns true if [value] is valid JSON.
  static bool isJson(String value) {
    try {
      jsonDecode(value);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Returns true if [value] is a valid URL.
  static bool isUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && uri.hasScheme && uri.hasAuthority;
  }

  /// Returns true if [value] is a valid UUID (any version).
  static bool isUuid(String value) => RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  ).hasMatch(value);

  /// Returns true if [value] is a ULID (26 chars, Crockford base32).
  static bool isUlid(String value) =>
      RegExp(r'^[0-9A-HJKMNP-TV-Z]{26}$').hasMatch(value);

  // ---------------------------------------------------------------------------
  // Additional position / search
  // ---------------------------------------------------------------------------

  /// Returns the index of the first occurrence of [needle] in [haystack],
  /// or `null` if not found. [offset] starts the search from a position.
  static int? position(String haystack, String needle, {int offset = 0}) {
    if (needle.isEmpty) return null;
    final index = haystack.indexOf(needle, offset);
    return index == -1 ? null : index;
  }

  /// Counts non-overlapping occurrences of [needle] in [haystack].
  static int substrCount(String haystack, String needle) {
    if (needle.isEmpty) return 0;
    var count = 0;
    var start = 0;
    while (true) {
      final i = haystack.indexOf(needle, start);
      if (i == -1) break;
      count++;
      start = i + needle.length;
    }
    return count;
  }

  /// Returns the first regex match of [pattern] in [subject], or `null`.
  ///
  /// Note: this is a regex match — distinct from the global `match()` value
  /// mapper defined in `helper.dart`.
  static String? match(Pattern pattern, String subject) {
    final regex = pattern is RegExp ? pattern : RegExp(pattern.toString());
    return regex.firstMatch(subject)?.group(0);
  }

  /// Returns all regex matches of [pattern] in [subject].
  static List<String> matchAll(Pattern pattern, String subject) {
    final regex = pattern is RegExp ? pattern : RegExp(pattern.toString());
    return regex.allMatches(subject).map((m) => m.group(0) ?? '').toList();
  }

  /// Extracts a snippet of [text] around the first occurrence of [phrase].
  ///
  /// [radius] is the number of characters to keep on either side. Returns
  /// `null` if [phrase] is not found.
  static String? excerpt(
    String text,
    String phrase, {
    int radius = 100,
    String omission = '...',
  }) {
    if (phrase.isEmpty) return null;
    final i = text.indexOf(phrase);
    if (i == -1) return null;
    final start = (i - radius).clamp(0, text.length);
    final end = (i + phrase.length + radius).clamp(0, text.length);
    final snippet = text.substring(start, end);
    final prefix = start > 0 ? omission : '';
    final suffix = end < text.length ? omission : '';
    return '$prefix$snippet$suffix';
  }

  // ---------------------------------------------------------------------------
  // Additional replace / transform
  // ---------------------------------------------------------------------------

  /// Strips a single instance of [before] from the start and [after]
  /// (or [before] if `after` is null) from the end of [value].
  static String unwrap(String value, String before, [String? after]) {
    final end = after ?? before;
    var result = value;
    if (before.isNotEmpty && result.startsWith(before)) {
      result = result.substring(before.length);
    }
    if (end.isNotEmpty && result.endsWith(end)) {
      result = result.substring(0, result.length - end.length);
    }
    return result;
  }

  /// Replaces consecutive runs of [character] with a single instance.
  static String deduplicate(String value, [String character = ' ']) {
    if (character.isEmpty) return value;
    return value.replaceAll(RegExp('${RegExp.escape(character)}+'), character);
  }

  /// Replaces multiple substrings in [subject] using a `Map` of search→replace.
  static String swap(Map<String, String> map, String subject) {
    var result = subject;
    map.forEach((k, v) {
      if (k.isNotEmpty) result = result.replaceAll(k, v);
    });
    return result;
  }

  /// Splits [value] into words on uppercase boundaries.
  ///
  /// ```dart
  /// Str.ucsplit('fooBarBaz'); // ['foo', 'Bar', 'Baz']
  /// ```
  static List<String> ucsplit(String value) {
    if (value.isEmpty) return [];
    return value
        .split(RegExp(r'(?=[A-Z])'))
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Pads [value] with leading zeros to reach [length] characters.
  ///
  /// ```dart
  /// Str.padNumber('5', 3); // '005'
  /// ```
  static String padNumber(String value, int length) =>
      padLeft(value, length, '0');

  // ---------------------------------------------------------------------------
  // Additional random / IDs
  // ---------------------------------------------------------------------------

  static const String _passwordSymbols = r'~!#$%^&*()-_.,<>?/\|{}[]:;';

  /// Generates a cryptographically random password.
  ///
  /// Toggle the character classes via [letters], [numbers], [symbols], and
  /// [spaces]. At least one class must be enabled.
  static String password(
    int length, {
    bool letters = true,
    bool numbers = true,
    bool symbols = true,
    bool spaces = false,
  }) {
    final pool = StringBuffer();
    if (letters) {
      pool.write('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ');
    }
    if (numbers) pool.write('0123456789');
    if (symbols) pool.write(_passwordSymbols);
    if (spaces) pool.write(' ');
    final chars = pool.toString();
    if (chars.isEmpty || length <= 0) return '';
    final out = StringBuffer();
    for (var i = 0; i < length; i++) {
      out.write(chars[_random.nextInt(chars.length)]);
    }
    return out.toString();
  }

  /// Generates a UUID v7 (time-ordered, RFC 9562).
  static String uuid7() {
    final ms = DateTime.now().millisecondsSinceEpoch;
    final bytes = List<int>.filled(16, 0);
    bytes[0] = (ms >> 40) & 0xff;
    bytes[1] = (ms >> 32) & 0xff;
    bytes[2] = (ms >> 24) & 0xff;
    bytes[3] = (ms >> 16) & 0xff;
    bytes[4] = (ms >> 8) & 0xff;
    bytes[5] = ms & 0xff;
    for (var i = 6; i < 16; i++) {
      bytes[i] = _random.nextInt(256);
    }
    bytes[6] = (bytes[6] & 0x0f) | 0x70; // version 7
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant 10
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
