import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/dart_console/ny_dart_console.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('ScrollbackBuffer', () {
    nyGroup('constructor', () {
      nyTest('should create with recordBlanks true', () async {
        final buffer = ScrollbackBuffer(recordBlanks: true);
        expect(buffer.recordBlanks, isTrue);
        expect(buffer.lineList, isEmpty);
        expect(buffer.lineIndex, isNull);
        expect(buffer.currentLineBuffer, isNull);
      });

      nyTest('should create with recordBlanks false', () async {
        final buffer = ScrollbackBuffer(recordBlanks: false);
        expect(buffer.recordBlanks, isFalse);
      });
    });

    nyGroup('add', () {
      nyTest('should add a line', () async {
        final buffer = ScrollbackBuffer(recordBlanks: true);
        buffer.add('hello');
        expect(buffer.lineList, ['hello']);
        expect(buffer.lineIndex, 1);
      });

      nyTest('should add multiple lines', () async {
        final buffer = ScrollbackBuffer(recordBlanks: true);
        buffer.add('first');
        buffer.add('second');
        expect(buffer.lineList, ['first', 'second']);
        expect(buffer.lineIndex, 2);
      });

      nyTest('should record blank lines when recordBlanks is true', () async {
        final buffer = ScrollbackBuffer(recordBlanks: true);
        buffer.add('');
        expect(buffer.lineList, hasLength(1));
      });

      nyTest('should skip blank lines when recordBlanks is false', () async {
        final buffer = ScrollbackBuffer(recordBlanks: false);
        buffer.add('');
        expect(buffer.lineList, isEmpty);
      });

      nyTest('should reset currentLineBuffer', () async {
        final buffer = ScrollbackBuffer(recordBlanks: true);
        buffer.add('hello');
        expect(buffer.currentLineBuffer, isNull);
      });
    });

    nyGroup('up', () {
      nyTest('should return current buffer when no history', () async {
        final buffer = ScrollbackBuffer(recordBlanks: true);
        expect(buffer.up('current'), 'current');
      });

      nyTest('should scroll up to previous line', () async {
        final buffer = ScrollbackBuffer(recordBlanks: true);
        buffer.add('first');
        buffer.add('second');
        final result = buffer.up('typing');
        expect(result, 'second');
      });

      nyTest('should scroll up multiple times', () async {
        final buffer = ScrollbackBuffer(recordBlanks: true);
        buffer.add('first');
        buffer.add('second');
        buffer.up('typing');
        final result = buffer.up('typing');
        expect(result, 'first');
      });

      nyTest('should stop at the beginning', () async {
        final buffer = ScrollbackBuffer(recordBlanks: true);
        buffer.add('only');
        buffer.up('typing');
        final result = buffer.up('typing');
        expect(result, 'only');
      });

      nyTest('should store current line buffer', () async {
        final buffer = ScrollbackBuffer(recordBlanks: true);
        buffer.add('old');
        buffer.up('new text');
        expect(buffer.currentLineBuffer, 'new text');
      });
    });

    nyGroup('down', () {
      nyTest('should return null when no history', () async {
        final buffer = ScrollbackBuffer(recordBlanks: true);
        expect(buffer.down(), isNull);
      });

      nyTest('should return to current line buffer at end', () async {
        final buffer = ScrollbackBuffer(recordBlanks: true);
        buffer.add('first');
        buffer.up('typing');
        final result = buffer.down();
        expect(result, 'typing');
      });

      nyTest('should scroll down through history', () async {
        final buffer = ScrollbackBuffer(recordBlanks: true);
        buffer.add('first');
        buffer.add('second');
        buffer.up('typing'); // now at 'second'
        buffer.up('typing'); // now at 'first'
        final result = buffer.down(); // back to 'second'
        expect(result, 'second');
      });

      nyTest('should reset currentLineBuffer when reaching end', () async {
        final buffer = ScrollbackBuffer(recordBlanks: true);
        buffer.add('first');
        buffer.up('typing');
        buffer.down();
        expect(buffer.currentLineBuffer, isNull);
      });
    });

    nyGroup('integration', () {
      nyTest('up and down navigation cycle', () async {
        final buffer = ScrollbackBuffer(recordBlanks: true);
        buffer.add('line1');
        buffer.add('line2');
        buffer.add('line3');

        // Scroll up through history
        expect(buffer.up('current'), 'line3');
        expect(buffer.up('current'), 'line2');
        expect(buffer.up('current'), 'line1');

        // Scroll back down
        expect(buffer.down(), 'line2');
        expect(buffer.down(), 'line3');
        expect(buffer.down(), 'current');
      });
    });
  });
}
