import 'dart:math';

/// Laravel-style model factories for testing.
///
/// This class allows you to define factories for creating test data
/// with sensible defaults and overrideable attributes.
///
/// Example:
/// ```dart
/// // Define a factory
/// NyFactory.define<User>((faker) => User(
///   id: faker.randomInt(1, 1000),
///   name: faker.name(),
///   email: faker.email(),
/// ));
///
/// // Create instances
/// final user = NyFactory.make<User>();
/// final users = NyFactory.create<User>(count: 5);
///
/// // With overrides
/// final admin = NyFactory.make<User>(overrides: {'role': 'admin'});
/// ```
class NyFactory {
  static final Map<Type, FactoryDefinition> _definitions = {};
  static final Map<Type, List<String>> _states = {};
  static final Map<String, FactoryState> _stateDefinitions = {};

  /// Define a factory for a specific type.
  ///
  /// The [builder] function receives a [NyFaker] instance for generating
  /// random data and should return an instance of type [T].
  ///
  /// Example:
  /// ```dart
  /// NyFactory.define<User>((faker) => User(
  ///   name: faker.name(),
  ///   email: faker.email(),
  /// ));
  /// ```
  static void define<T>(T Function(NyFaker faker) builder) {
    _definitions[T] = FactoryDefinition<T>(builder);
  }

  /// Define a factory with a callback that receives overrides.
  static void defineWithOverrides<T>(
    T Function(NyFaker faker, Map<String, dynamic> attributes) builder,
  ) {
    _definitions[T] = FactoryDefinitionWithOverrides<T>(builder);
  }

  /// Define a state for a factory.
  ///
  /// States allow you to define variations of your factory.
  ///
  /// Example:
  /// ```dart
  /// NyFactory.state<User>('admin', (user, faker) {
  ///   return user.copyWith(role: 'admin');
  /// });
  ///
  /// final admin = NyFactory.make<User>(states: ['admin']);
  /// ```
  static void state<T>(
    String name,
    T Function(T instance, NyFaker faker) modifier,
  ) {
    final key = '${T}_$name';
    _stateDefinitions[key] = FactoryState<T>(modifier);
    _states[T] ??= [];
    if (!_states[T]!.contains(name)) {
      _states[T]!.add(name);
    }
  }

  /// Create a single instance of type [T].
  ///
  /// [overrides] can be used to override specific attributes.
  /// [states] can be used to apply predefined state modifications.
  ///
  /// Example:
  /// ```dart
  /// final user = NyFactory.make<User>();
  /// final admin = NyFactory.make<User>(
  ///   overrides: {'role': 'admin'},
  ///   states: ['verified'],
  /// );
  /// ```
  static T make<T>({Map<String, dynamic>? overrides, List<String>? states}) {
    assert(
      _definitions.containsKey(T),
      'No factory defined for type $T. Call NyFactory.define<$T>() first.',
    );

    final definition = _definitions[T]!;
    final faker = NyFaker();

    T instance;
    if (definition is FactoryDefinitionWithOverrides<T>) {
      instance = definition.builderWithOverrides(faker, overrides ?? {});
    } else if (definition is FactoryDefinition<T>) {
      instance = definition.builder(faker);
      if (overrides != null && instance is Map) {
        (instance as Map).addAll(overrides);
      }
    } else {
      throw Exception('Unknown factory definition type');
    }

    // Apply states
    if (states != null) {
      for (final stateName in states) {
        final key = '${T}_$stateName';
        if (_stateDefinitions.containsKey(key)) {
          final stateModifier = _stateDefinitions[key] as FactoryState<T>;
          instance = stateModifier.modifier(instance, faker);
        }
      }
    }

    return instance;
  }

  /// Create multiple instances of type [T].
  ///
  /// Example:
  /// ```dart
  /// final users = NyFactory.create<User>(count: 10);
  /// ```
  static List<T> create<T>({
    int count = 1,
    Map<String, dynamic>? overrides,
    List<String>? states,
  }) {
    return List.generate(
      count,
      (_) => make<T>(overrides: overrides, states: states),
    );
  }

  /// Create instances with sequential data.
  ///
  /// The [builder] receives the current index for sequential data.
  ///
  /// Example:
  /// ```dart
  /// final users = NyFactory.sequence<User>(10, (i, faker) => User(
  ///   id: i,
  ///   email: 'user$i@example.com',
  /// ));
  /// ```
  static List<T> sequence<T>(
    int count,
    T Function(int index, NyFaker faker) builder,
  ) {
    final faker = NyFaker();
    return List.generate(count, (i) => builder(i, faker));
  }

  /// Clear all factory definitions.
  static void clear() {
    _definitions.clear();
    _states.clear();
    _stateDefinitions.clear();
  }

  /// Check if a factory is defined for a type.
  static bool isDefined<T>() => _definitions.containsKey(T);

  /// Get list of available states for a type.
  static List<String> getStates<T>() => _states[T] ?? [];
}

/// Factory definition container.
class FactoryDefinition<T> {
  final T Function(NyFaker faker) builder;

  FactoryDefinition(this.builder);
}

/// Factory definition with overrides support.
class FactoryDefinitionWithOverrides<T> extends FactoryDefinition<T> {
  final T Function(NyFaker faker, Map<String, dynamic> attributes)
  builderWithOverrides;

  FactoryDefinitionWithOverrides(this.builderWithOverrides)
    : super((faker) => builderWithOverrides(faker, {}));
}

/// Factory state modifier container.
class FactoryState<T> {
  final T Function(T instance, NyFaker faker) modifier;

  FactoryState(this.modifier);
}

/// Faker class for generating random test data.
///
/// Provides methods for generating common types of test data.
///
/// Example:
/// ```dart
/// final faker = NyFaker();
/// print(faker.name()); // "John Smith"
/// print(faker.email()); // "john.smith@example.com"
/// print(faker.randomInt(1, 100)); // 42
/// ```
class NyFaker {
  final Random _random = Random();

  static const _firstNames = [
    'James',
    'John',
    'Robert',
    'Michael',
    'William',
    'David',
    'Richard',
    'Joseph',
    'Thomas',
    'Christopher',
    'Mary',
    'Patricia',
    'Jennifer',
    'Linda',
    'Elizabeth',
    'Barbara',
    'Susan',
    'Jessica',
    'Sarah',
    'Karen',
  ];

  static const _lastNames = [
    'Smith',
    'Johnson',
    'Williams',
    'Brown',
    'Jones',
    'Garcia',
    'Miller',
    'Davis',
    'Rodriguez',
    'Martinez',
    'Hernandez',
    'Lopez',
    'Gonzalez',
    'Wilson',
    'Anderson',
    'Thomas',
    'Taylor',
    'Moore',
    'Jackson',
    'Martin',
  ];

  static const _companies = [
    'Acme Corp',
    'Tech Solutions',
    'Global Industries',
    'Digital Ventures',
    'Innovation Labs',
    'Future Systems',
    'Prime Services',
    'Elite Group',
    'Smart Tech',
    'Blue Ocean',
    'Green Fields',
    'Red Mountain',
  ];

  static const _domains = [
    'example.com',
    'test.org',
    'sample.net',
    'demo.io',
    'mock.dev',
  ];

  static const _lorem = [
    'lorem',
    'ipsum',
    'dolor',
    'sit',
    'amet',
    'consectetur',
    'adipiscing',
    'elit',
    'sed',
    'do',
    'eiusmod',
    'tempor',
    'incididunt',
    'ut',
    'labore',
    'et',
    'dolore',
    'magna',
    'aliqua',
    'enim',
    'ad',
    'minim',
    'veniam',
  ];

  /// Generate a random first name.
  String firstName() => _randomElement(_firstNames);

  /// Generate a random last name.
  String lastName() => _randomElement(_lastNames);

  /// Generate a random full name.
  String name() => '${firstName()} ${lastName()}';

  /// Generate a random email address.
  String email() {
    final first = firstName().toLowerCase();
    final last = lastName().toLowerCase();
    final domain = _randomElement(_domains);
    return '$first.$last@$domain';
  }

  /// Generate a random username.
  String username() {
    final first = firstName().toLowerCase();
    final num = randomInt(1, 999);
    return '$first$num';
  }

  /// Generate a random company name.
  String company() => _randomElement(_companies);

  /// Generate a random phone number.
  String phone() {
    final area = randomInt(200, 999);
    final prefix = randomInt(200, 999);
    final line = randomInt(1000, 9999);
    return '($area) $prefix-$line';
  }

  /// Generate a random integer between [min] and [max] (inclusive).
  int randomInt(int min, int max) => min + _random.nextInt(max - min + 1);

  /// Generate a random double between [min] and [max].
  double randomDouble(double min, double max) =>
      min + _random.nextDouble() * (max - min);

  /// Generate a random boolean.
  bool randomBool() => _random.nextBool();

  /// Generate a random UUID.
  String uuid() {
    final chars = '0123456789abcdef';
    String generate(int length) =>
        List.generate(length, (_) => chars[_random.nextInt(16)]).join();
    return '${generate(8)}-${generate(4)}-${generate(4)}-${generate(4)}-${generate(12)}';
  }

  /// Generate a random date between [start] and [end].
  DateTime date({DateTime? start, DateTime? end}) {
    start ??= DateTime(2000);
    end ??= DateTime.now();
    final diff = end.difference(start).inMilliseconds;
    final randomMillis = _random.nextInt(diff);
    return start.add(Duration(milliseconds: randomMillis));
  }

  /// Generate a past date.
  DateTime pastDate({int yearsBack = 5}) {
    final now = DateTime.now();
    return date(
      start: now.subtract(Duration(days: yearsBack * 365)),
      end: now,
    );
  }

  /// Generate a future date.
  DateTime futureDate({int yearsAhead = 5}) {
    final now = DateTime.now();
    return date(
      start: now,
      end: now.add(Duration(days: yearsAhead * 365)),
    );
  }

  /// Generate lorem ipsum text.
  String lorem({int words = 10}) {
    return List.generate(words, (_) => _randomElement(_lorem)).join(' ');
  }

  /// Generate lorem ipsum sentences.
  String sentences({int count = 3}) {
    return List.generate(count, (_) {
      final wordCount = randomInt(5, 15);
      final sentence = lorem(words: wordCount);
      return '${sentence[0].toUpperCase()}${sentence.substring(1)}.';
    }).join(' ');
  }

  /// Generate lorem ipsum paragraphs.
  String paragraphs({int count = 3}) {
    return List.generate(
      count,
      (_) => sentences(count: randomInt(3, 6)),
    ).join('\n\n');
  }

  /// Generate a random URL.
  String url() {
    final domain = _randomElement(_domains);
    final path = List.generate(
      randomInt(1, 3),
      (_) => _randomElement(_lorem),
    ).join('/');
    return 'https://$domain/$path';
  }

  /// Generate a random image URL.
  String imageUrl({int width = 200, int height = 200}) {
    return 'https://picsum.photos/$width/$height?random=${randomInt(1, 10000)}';
  }

  /// Generate a random color hex code.
  String hexColor() {
    final color = _random.nextInt(0xFFFFFF);
    return '#${color.toRadixString(16).padLeft(6, '0')}';
  }

  /// Generate a random street address.
  String address() {
    final number = randomInt(1, 9999);
    final streets = ['Main', 'Oak', 'Maple', 'Cedar', 'Pine', 'Elm', 'Park'];
    final types = ['St', 'Ave', 'Blvd', 'Dr', 'Ln', 'Way'];
    return '$number ${_randomElement(streets)} ${_randomElement(types)}';
  }

  /// Generate a random city name.
  String city() {
    final cities = [
      'New York',
      'Los Angeles',
      'Chicago',
      'Houston',
      'Phoenix',
      'San Antonio',
      'San Diego',
      'Dallas',
      'San Jose',
      'Austin',
    ];
    return _randomElement(cities);
  }

  /// Generate a random state abbreviation.
  String state() {
    final states = [
      'AL',
      'AK',
      'AZ',
      'AR',
      'CA',
      'CO',
      'CT',
      'DE',
      'FL',
      'GA',
      'HI',
      'ID',
      'IL',
      'IN',
      'IA',
      'KS',
      'KY',
      'LA',
      'ME',
      'MD',
    ];
    return _randomElement(states);
  }

  /// Generate a random ZIP code.
  String zipCode() => randomInt(10000, 99999).toString();

  /// Generate a random country.
  String country() {
    final countries = [
      'United States',
      'Canada',
      'Mexico',
      'United Kingdom',
      'Germany',
      'France',
      'Italy',
      'Spain',
      'Australia',
      'Japan',
    ];
    return _randomElement(countries);
  }

  /// Pick a random element from a list.
  T _randomElement<T>(List<T> list) => list[_random.nextInt(list.length)];

  /// Pick a random element from the provided list.
  T randomElement<T>(List<T> list) => _randomElement(list);

  /// Pick multiple random elements from a list.
  List<T> randomElements<T>(List<T> list, int count) {
    final shuffled = List<T>.from(list)..shuffle(_random);
    return shuffled.take(count).toList();
  }

  /// Generate a credit card number (fake).
  String creditCardNumber() {
    final prefix = ['4', '5', '37', '6011'][_random.nextInt(4)];
    final length = prefix == '37' ? 15 : 16;
    final remaining = length - prefix.length;
    final number = List.generate(remaining, (_) => _random.nextInt(10)).join();
    return '$prefix$number';
  }

  /// Generate a random IP address.
  String ipAddress() {
    return List.generate(4, (_) => randomInt(0, 255)).join('.');
  }

  /// Generate a random MAC address.
  String macAddress() {
    final chars = '0123456789ABCDEF';
    return List.generate(
      6,
      (_) => List.generate(2, (_) => chars[_random.nextInt(16)]).join(),
    ).join(':');
  }

  /// Generate a slug from text.
  String slug({int words = 3}) {
    return List.generate(
      words,
      (_) => _randomElement(_lorem),
    ).join('-').toLowerCase();
  }
}
