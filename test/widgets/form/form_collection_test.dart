import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';

void main() {
  NyTest.init();

  nyGroup('FormOption', () {
    nyGroup('constructor', () {
      nyTest('creates with value and label', () async {
        const option = FormOption(value: 'us', label: 'United States');

        expect(option.value, 'us');
        expect(option.label, 'United States');
      });
    });

    nyGroup('fromJson', () {
      nyTest('creates from value/label keys', () async {
        final option = FormOption.fromJson({'value': 'ca', 'label': 'Canada'});

        expect(option.value, 'ca');
        expect(option.label, 'Canada');
      });

      nyTest('falls back to id/name keys', () async {
        final option = FormOption.fromJson({'id': 'mx', 'name': 'Mexico'});

        expect(option.value, 'mx');
        expect(option.label, 'Mexico');
      });
    });

    nyGroup('toJson', () {
      nyTest('converts to map', () async {
        const option = FormOption(value: 'uk', label: 'United Kingdom');

        final json = option.toJson();

        expect(json, {'value': 'uk', 'label': 'United Kingdom'});
      });
    });

    nyGroup('equality', () {
      nyTest('equals same value and label', () async {
        const option1 = FormOption(value: 'a', label: 'A');
        const option2 = FormOption(value: 'a', label: 'A');

        expect(option1 == option2, true);
        expect(option1.hashCode, option2.hashCode);
      });

      nyTest('not equal with different value', () async {
        const option1 = FormOption(value: 'a', label: 'A');
        const option2 = FormOption(value: 'b', label: 'A');

        expect(option1 == option2, false);
      });

      nyTest('not equal with different label', () async {
        const option1 = FormOption(value: 'a', label: 'A');
        const option2 = FormOption(value: 'a', label: 'B');

        expect(option1 == option2, false);
      });
    });

    nyGroup('toString', () {
      nyTest('formats correctly', () async {
        const option = FormOption(value: 'test', label: 'Test');

        expect(option.toString(), 'FormOption(value: test, label: Test)');
      });
    });
  });

  nyGroup('FormCollection', () {
    nyGroup('fromArray', () {
      nyTest('creates from string list', () async {
        final collection = FormCollection.fromArray(['Red', 'Green', 'Blue']);

        expect(collection.length, 3);
        expect(collection[0]?.value, 'Red');
        expect(collection[0]?.label, 'Red');
        expect(collection.isArrayStructure, true);
      });
    });

    nyGroup('fromMap', () {
      nyTest('creates from key-value map', () async {
        final collection = FormCollection.fromMap({
          'small': 'Small Size',
          'large': 'Large Size',
        });

        expect(collection.length, 2);
        expect(collection.isKeyValueStructure, true);
      });
    });

    nyGroup('fromKeyValue', () {
      nyTest('creates from list of maps', () async {
        final collection = FormCollection.fromKeyValue([
          {'value': 'en', 'label': 'English'},
          {'value': 'es', 'label': 'Spanish'},
        ]);

        expect(collection.length, 2);
        expect(collection[0]?.value, 'en');
        expect(collection[0]?.label, 'English');
      });
    });

    nyGroup('from', () {
      nyTest('auto-detects string array', () async {
        final collection = FormCollection.from(['A', 'B', 'C']);

        expect(collection.length, 3);
        expect(collection.isArrayStructure, true);
      });

      nyTest('auto-detects map', () async {
        final collection = FormCollection.from({'key': 'value'});

        expect(collection.length, 1);
        expect(collection.isKeyValueStructure, true);
      });

      nyTest('auto-detects key-value list', () async {
        final collection = FormCollection.from([
          {'value': 'a', 'label': 'A'},
        ]);

        expect(collection.length, 1);
        expect(collection.isKeyValueStructure, true);
      });

      nyTest('handles empty list', () async {
        final collection = FormCollection.from([]);

        expect(collection.isEmpty, true);
      });

      nyTest('throws for unsupported format', () async {
        expect(() => FormCollection.from(42), throwsA(isA<ArgumentError>()));
      });
    });

    nyGroup('options getter', () {
      nyTest('returns immutable list', () async {
        final collection = FormCollection.from(['A', 'B']);

        expect(collection.options, hasLength(2));
      });
    });

    nyGroup('length and isEmpty', () {
      nyTest('returns correct length', () async {
        final collection = FormCollection.from(['A', 'B', 'C']);

        expect(collection.length, 3);
        expect(collection.isEmpty, false);
        expect(collection.isNotEmpty, true);
      });

      nyTest('handles empty collection', () async {
        final collection = FormCollection.from([]);

        expect(collection.length, 0);
        expect(collection.isEmpty, true);
        expect(collection.isNotEmpty, false);
      });
    });

    nyGroup('operator []', () {
      nyTest('returns option at valid index', () async {
        final collection = FormCollection.from(['A', 'B', 'C']);

        expect(collection[0]?.label, 'A');
        expect(collection[2]?.label, 'C');
      });

      nyTest('returns null for invalid index', () async {
        final collection = FormCollection.from(['A', 'B']);

        expect(collection[-1], isNull);
        expect(collection[5], isNull);
      });
    });

    nyGroup('first and last', () {
      nyTest('returns first and last options', () async {
        final collection = FormCollection.from(['First', 'Middle', 'Last']);

        expect(collection.first.label, 'First');
        expect(collection.last.label, 'Last');
      });
    });

    nyGroup('getByValue', () {
      nyTest('finds option by value', () async {
        final collection = FormCollection.fromMap({'a': 'Alpha', 'b': 'Beta'});

        expect(collection.getByValue('a')?.label, 'Alpha');
        expect(collection.getByValue('x'), isNull);
      });
    });

    nyGroup('getByLabel', () {
      nyTest('finds option by label', () async {
        final collection = FormCollection.from(['Alpha', 'Beta']);

        expect(collection.getByLabel('Beta')?.value, 'Beta');
        expect(collection.getByLabel('Gamma'), isNull);
      });
    });

    nyGroup('getLabelByValue', () {
      nyTest('returns label for value', () async {
        final collection = FormCollection.fromMap({'us': 'United States'});

        expect(collection.getLabelByValue('us'), 'United States');
        expect(collection.getLabelByValue('unknown'), isNull);
      });
    });

    nyGroup('getValueByLabel', () {
      nyTest('returns value for label', () async {
        final collection = FormCollection.fromMap({'us': 'United States'});

        expect(collection.getValueByLabel('United States'), 'us');
        expect(collection.getValueByLabel('Unknown'), isNull);
      });
    });

    nyGroup('searchByLabel', () {
      nyTest('finds options matching query', () async {
        final collection = FormCollection.from(['Apple', 'Apricot', 'Banana']);

        final results = collection.searchByLabel('ap');

        expect(results, hasLength(2));
        expect(results[0].label, 'Apple');
        expect(results[1].label, 'Apricot');
      });

      nyTest('returns empty for no matches', () async {
        final collection = FormCollection.from(['Apple', 'Banana']);

        expect(collection.searchByLabel('xyz'), isEmpty);
      });
    });

    nyGroup('indexOfValue', () {
      nyTest('returns index of value', () async {
        final collection = FormCollection.from(['A', 'B', 'C']);

        expect(collection.indexOfValue('B'), 1);
        expect(collection.indexOfValue('X'), -1);
      });
    });

    nyGroup('indexOfLabel', () {
      nyTest('returns index of label', () async {
        final collection = FormCollection.from(['Alpha', 'Beta', 'Gamma']);

        expect(collection.indexOfLabel('Gamma'), 2);
        expect(collection.indexOfLabel('Delta'), -1);
      });
    });

    nyGroup('containsValue', () {
      nyTest('checks if value exists', () async {
        final collection = FormCollection.fromMap({'a': 'Alpha'});

        expect(collection.containsValue('a'), true);
        expect(collection.containsValue('b'), false);
      });
    });

    nyGroup('containsLabel', () {
      nyTest('checks if label exists', () async {
        final collection = FormCollection.from(['Alpha', 'Beta']);

        expect(collection.containsLabel('Alpha'), true);
        expect(collection.containsLabel('Gamma'), false);
      });
    });

    nyGroup('values and labels', () {
      nyTest('returns list of values', () async {
        final collection = FormCollection.fromMap({'a': 'Alpha', 'b': 'Beta'});

        expect(collection.values, containsAll(['a', 'b']));
      });

      nyTest('returns list of labels', () async {
        final collection = FormCollection.from(['X', 'Y', 'Z']);

        expect(collection.labels, ['X', 'Y', 'Z']);
      });
    });

    nyGroup('isValidValue', () {
      nyTest('validates value exists', () async {
        final collection = FormCollection.fromMap({'valid': 'Valid'});

        expect(collection.isValidValue('valid'), true);
        expect(collection.isValidValue('invalid'), false);
        expect(collection.isValidValue(null), false);
      });
    });

    nyGroup('validateValue', () {
      nyTest('returns null for valid value', () async {
        final collection = FormCollection.fromMap({'valid': 'Valid'});

        expect(collection.validateValue('valid'), isNull);
      });

      nyTest('returns error for empty value', () async {
        final collection = FormCollection.from(['A']);

        expect(collection.validateValue(''), isNotNull);
        expect(collection.validateValue(null), isNotNull);
      });

      nyTest('returns error for invalid value', () async {
        final collection = FormCollection.from(['A']);

        expect(collection.validateValue('B'), isNotNull);
      });

      nyTest('uses custom error message', () async {
        final collection = FormCollection.from(['A']);

        expect(
          collection.validateValue('B', errorMessage: 'Custom error'),
          'Custom error',
        );
      });
    });

    nyGroup('conversion methods', () {
      nyTest('toKeyValueList converts to list of maps', () async {
        final collection = FormCollection.fromMap({'a': 'Alpha'});

        final list = collection.toKeyValueList();

        expect(list, [
          {'value': 'a', 'label': 'Alpha'},
        ]);
      });

      nyTest('toMap returns value-label map', () async {
        final collection = FormCollection.fromKeyValue([
          {'value': 'k', 'label': 'Key'},
        ]);

        expect(collection.toMap(), {'k': 'Key'});
      });
    });

    nyGroup('filter', () {
      nyTest('filters options by predicate', () async {
        final collection = FormCollection.from(['Apple', 'Banana', 'Apricot']);

        final filtered = collection.filter((o) => o.label.startsWith('A'));

        expect(filtered.length, 2);
        expect(filtered.labels, ['Apple', 'Apricot']);
      });
    });

    nyGroup('sort', () {
      nyTest('sorts by label alphabetically by default', () async {
        final collection = FormCollection.from(['Banana', 'Apple', 'Cherry']);

        final sorted = collection.sort();

        expect(sorted.labels, ['Apple', 'Banana', 'Cherry']);
      });

      nyTest('sorts by custom comparator', () async {
        final collection = FormCollection.from(['AA', 'BBB', 'C']);

        final sorted = collection.sort(
          (a, b) => a.label.length.compareTo(b.label.length),
        );

        expect(sorted.labels, ['C', 'AA', 'BBB']);
      });
    });

    nyGroup('equality', () {
      nyTest('equals same options and structure', () async {
        final collection1 = FormCollection.from(['A', 'B']);
        final collection2 = FormCollection.from(['A', 'B']);

        expect(collection1 == collection2, true);
      });

      nyTest('not equal with different options', () async {
        final collection1 = FormCollection.from(['A', 'B']);
        final collection2 = FormCollection.from(['A', 'C']);

        expect(collection1 == collection2, false);
      });
    });

    nyGroup('toString', () {
      nyTest('formats correctly', () async {
        final collection = FormCollection.from(['A', 'B']);

        expect(collection.toString(), contains('2 options'));
      });
    });
  });
}
