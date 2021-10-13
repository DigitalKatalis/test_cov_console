import 'package:flutter_test/flutter_test.dart';
import 'package:test_cov_console/test_cov_console.dart';

var log = <String>[];

void main() {
  group('Parser', () {
    const result = '{file: test/test.dart, exclude: [string1, string2]}';
    const singleValue = '{csv: csv, multi: multi}';
    test('should return {} for no input', () async {
      final args = Parser([]).parse();
      expect(args.toString(), '{}');
    });

    test('should return options list for -<option> <value> format', () async {
      final input = '-f test/test.dart -e string1,string2'.split(' ');
      final args = Parser(input).parse();
      expect(args.toString(), result);
    });

    test('should return options list for --<option>=<value> format', () async {
      final input =
          '--file=test/test.dart --exclude=string1,string2'.split(' ');
      final args = Parser(input).parse();
      expect(args.toString(), result);
    });

    test('should return options list for mixed format', () async {
      final input = '-f test/test.dart --exclude=string1,string2'.split(' ');
      final args = Parser(input).parse();
      expect(args.toString(), result);
    });

    test('should return options list for single value format', () async {
      final input = '-c --multi'.split(' ');
      final args = Parser(input).parse();
      expect(args.toString(), singleValue);
    });

    test('should return help and ignore other options if there is help option',
        () async {
      final input = '-f test/test.dart --exclude=string1,string2 -h'.split(' ');
      final args = Parser(input).parse();
      expect(args.toString().startsWith('{help: Generate coverage'), true);
    });

    test('should return help for any error/invalid option', () async {
      final input = '-f'.split(' ');
      final args = Parser(input).parse();
      expect(
          args.toString().startsWith('{help: Error invalid parameter!'), true);
    });
  });
}
