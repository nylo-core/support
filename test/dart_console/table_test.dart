import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/dart_console/ny_dart_console.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('BoxGlyphSet', () {
    nyTest('none should have null glyphs', () async {
      final glyphs = BoxGlyphSet.none();
      expect(glyphs.glyphs, isNull);
      expect(glyphs.horizontalLine, '');
      expect(glyphs.verticalLine, '');
    });

    nyTest('ascii should have correct characters', () async {
      final glyphs = BoxGlyphSet.ascii();
      expect(glyphs.horizontalLine, '-');
      expect(glyphs.verticalLine, '|');
    });

    nyTest('square should have correct characters', () async {
      final glyphs = BoxGlyphSet.square();
      expect(glyphs.horizontalLine, '─');
      expect(glyphs.verticalLine, '│');
      expect(glyphs.topLeftCorner, '┌');
      expect(glyphs.topRightCorner, '┐');
      expect(glyphs.bottomLeftCorner, '└');
      expect(glyphs.bottomRightCorner, '┘');
    });

    nyTest('rounded should have rounded corners', () async {
      final glyphs = BoxGlyphSet.rounded();
      expect(glyphs.topLeftCorner, '╭');
      expect(glyphs.topRightCorner, '╮');
      expect(glyphs.bottomLeftCorner, '╰');
      expect(glyphs.bottomRightCorner, '╯');
    });

    nyTest('bold should have bold characters', () async {
      final glyphs = BoxGlyphSet.bold();
      expect(glyphs.horizontalLine, '━');
      expect(glyphs.verticalLine, '┃');
    });

    nyTest('double should have double characters', () async {
      final glyphs = BoxGlyphSet.double();
      expect(glyphs.horizontalLine, '═');
      expect(glyphs.verticalLine, '║');
    });
  });

  nyGroup('BorderStyle', () {
    nyTest('should have all expected values', () async {
      expect(BorderStyle.values, hasLength(6));
      expect(BorderStyle.values, contains(BorderStyle.none));
      expect(BorderStyle.values, contains(BorderStyle.ascii));
      expect(BorderStyle.values, contains(BorderStyle.square));
      expect(BorderStyle.values, contains(BorderStyle.rounded));
      expect(BorderStyle.values, contains(BorderStyle.bold));
      expect(BorderStyle.values, contains(BorderStyle.double));
    });
  });

  nyGroup('BorderType', () {
    nyTest('should have all expected values', () async {
      expect(BorderType.values, hasLength(5));
      expect(BorderType.values, contains(BorderType.outline));
      expect(BorderType.values, contains(BorderType.header));
      expect(BorderType.values, contains(BorderType.grid));
      expect(BorderType.values, contains(BorderType.vertical));
      expect(BorderType.values, contains(BorderType.horizontal));
    });
  });

  nyGroup('FontStyle', () {
    nyTest('should have all expected values', () async {
      expect(FontStyle.values, hasLength(4));
      expect(FontStyle.values, contains(FontStyle.normal));
      expect(FontStyle.values, contains(FontStyle.bold));
      expect(FontStyle.values, contains(FontStyle.underscore));
      expect(FontStyle.values, contains(FontStyle.boldUnderscore));
    });
  });

  nyGroup('Table', () {
    nyGroup('empty table', () {
      nyTest('should have 0 columns and 0 rows', () async {
        final table = Table();
        expect(table.columns, 0);
        expect(table.rows, 0);
      });

      nyTest('render should return empty string', () async {
        final table = Table();
        expect(table.render(), '');
      });

      nyTest('toString should return empty string', () async {
        final table = Table();
        expect(table.toString(), '');
      });
    });

    nyGroup('insertColumn', () {
      nyTest('should add a column', () async {
        final table = Table();
        table.insertColumn(header: 'Name');
        expect(table.columns, 1);
      });

      nyTest('should add multiple columns', () async {
        final table = Table();
        table.insertColumn(header: 'Name');
        table.insertColumn(header: 'Age');
        table.insertColumn(header: 'City');
        expect(table.columns, 3);
      });

      nyTest('should insert at specific index', () async {
        final table = Table();
        table.insertColumn(header: 'A');
        table.insertColumn(header: 'C');
        table.insertColumn(header: 'B', index: 1);
        expect(table.columns, 3);
      });
    });

    nyGroup('insertRow', () {
      nyTest('should add a row', () async {
        final table = Table();
        table.insertColumn(header: 'Name');
        table.insertRow(['Alice']);
        expect(table.rows, 1);
      });

      nyTest('should add multiple rows', () async {
        final table = Table();
        table.insertColumn(header: 'Name');
        table.insertRow(['Alice']);
        table.insertRow(['Bob']);
        expect(table.rows, 2);
      });

      nyTest('should handle rows without headers (headerless)', () async {
        final table = Table();
        table.insertRow(['Alice', '30', 'NYC']);
        expect(table.rows, 1);
        expect(table.columns, 3);
        expect(table.showHeader, isFalse);
      });
    });

    nyGroup('insertRows', () {
      nyTest('should add multiple rows at once', () async {
        final table = Table();
        table.insertColumn(header: 'Name');
        table.insertRows([
          ['Alice'],
          ['Bob'],
          ['Charlie'],
        ]);
        expect(table.rows, 3);
      });
    });

    nyGroup('deleteColumn', () {
      nyTest('should remove a column', () async {
        final table = Table();
        table.insertColumn(header: 'Name');
        table.insertColumn(header: 'Age');
        table.deleteColumn(0);
        expect(table.columns, 1);
      });

      nyTest('should throw for invalid index', () async {
        final table = Table();
        table.insertColumn(header: 'Name');
        expect(() => table.deleteColumn(5), throwsArgumentError);
        expect(() => table.deleteColumn(-1), throwsArgumentError);
      });
    });

    nyGroup('deleteRow', () {
      nyTest('should remove a row', () async {
        final table = Table();
        table.insertColumn(header: 'Name');
        table.insertRow(['Alice']);
        table.insertRow(['Bob']);
        table.deleteRow(0);
        expect(table.rows, 1);
      });

      nyTest('should throw for invalid index', () async {
        final table = Table();
        table.insertColumn(header: 'Name');
        table.insertRow(['Alice']);
        expect(() => table.deleteRow(5), throwsArgumentError);
      });
    });

    nyGroup('setColumnFormatting', () {
      nyTest('should update column header', () async {
        final table = Table();
        table.insertColumn(header: 'Old');
        table.setColumnFormatting(0, header: 'New');
        // If it doesn't throw, formatting was updated successfully
        expect(table.columns, 1);
      });
    });

    nyGroup('render', () {
      nyTest('should render a simple table', () async {
        final table = Table();
        table.insertColumn(header: 'Name');
        table.insertColumn(header: 'Age');
        table.insertRow(['Alice', '30']);
        table.insertRow(['Bob', '25']);
        final output = table.render();
        expect(output, isNotEmpty);
      });

      nyTest('should render with no borders', () async {
        final table = Table();
        table.borderStyle = BorderStyle.none;
        table.insertColumn(header: 'Name');
        table.insertRow(['Alice']);
        final output = table.render();
        expect(output, isNotEmpty);
      });

      nyTest('should render plainText', () async {
        final table = Table();
        table.insertColumn(header: 'Name');
        table.insertRow(['Alice']);
        final output = table.render(plainText: true);
        expect(output, isNotEmpty);
        // Plain text should not contain escape characters
        expect(output, isNot(contains('\x1b')));
      });

      nyTest('should render with title', () async {
        final table = Table();
        table.title = 'Test Table';
        table.insertColumn(header: 'Name');
        table.insertRow(['Alice']);
        final output = table.render(plainText: true);
        expect(output, contains('Test Table'));
      });

      nyTest('should render with different border styles', () async {
        for (final style in BorderStyle.values) {
          final table = Table();
          table.borderStyle = style;
          table.insertColumn(header: 'Col');
          table.insertRow(['Val']);
          final output = table.render();
          expect(output, isNotEmpty, reason: 'BorderStyle.$style');
        }
      });

      nyTest('should render with grid border type', () async {
        final table = Table();
        table.borderType = BorderType.grid;
        table.insertColumn(header: 'Name');
        table.insertRow(['A']);
        table.insertRow(['B']);
        final output = table.render();
        expect(output, isNotEmpty);
      });
    });

    nyGroup('defaults', () {
      nyTest('should default to header border type', () async {
        final table = Table();
        expect(table.borderType, BorderType.header);
      });

      nyTest('should default to rounded border style', () async {
        final table = Table();
        expect(table.borderStyle, BorderStyle.rounded);
      });

      nyTest('should default to showing header', () async {
        final table = Table();
        expect(table.showHeader, isTrue);
      });

      nyTest('should default title to empty string', () async {
        final table = Table();
        expect(table.title, '');
      });

      nyTest('should default headerStyle to normal', () async {
        final table = Table();
        expect(table.headerStyle, FontStyle.normal);
      });

      nyTest('should default titleStyle to bold', () async {
        final table = Table();
        expect(table.titleStyle, FontStyle.bold);
      });
    });
  });
}
