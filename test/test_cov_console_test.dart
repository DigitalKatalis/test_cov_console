import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';
import 'package:test_cov_console/test_cov_console.dart';

var log = <String>[];

final slash = Platform.isWindows ? '\\' : '/';

void main() {
  final lines = lcovFile.split('\n');
  final printout = output.split('\n');
  setUp(() {
    log = [];
    OutputFile.tmpFile = [];
  });

  group('printCoverage', () {
    test('should print out with correct format & values', overridePrint(() {
      printCov(lines, files, '', false, false, 0, false);
      expect(log, printout);
    }));

    test('should print out with correct format & values - csv',
        overridePrint(() {
      printCov(lines, files, '', true, false, 0, false);
      expect(log, []);
      expect(OutputFile.tmpFile, outFiles);
    }));

    test('should print out with correct format & values - total',
        overridePrint(() {
      printCov(lines, files, '', false, true, 0, false);
      expect(log, ['87.18 ']);
    }));

    test('should print out with correct format & values - pass',
        overridePrint(() {
      printCov(lines, files, '', false, true, 80, false);
      expect(log, ['PASSED']);
    }));

    test('should print out with correct format & values', overridePrint(() {
      printCov(lines, files, '', false, true, 90, false);
      expect(log, ['FAILED']);
    }));
  });

  group('getFiles', () {
    test('should return file list with some exclusion', () async {
      final dir = _getCurrentDir();
      final result = await getFiles('${dir}lib', ['constants'], [], '');
      expect(result[0].toString(), '$dir${files0[0].toString()}');
      expect(result[1].toString(), '$dir${files0[1].toString()}');
    });
    test('should return file list with some inclusion', () async {
      final dir = _getCurrentDir();
      final result = await getFiles('${dir}lib', [], ['parser'], '');
      expect(result[0].toString(), '$dir${files0[1].toString()}');
    });
    test('should return empty for the same value of inclusion & exclusion',
        () async {
      final dir = _getCurrentDir();
      final result = await getFiles('${dir}lib', ['parser'], ['parser'], '');
      expect(result.isEmpty, true);
    });
  });

  group('getLCov', () {
    test('should return file list', () async {
      final dir = _getCurrentDir();
      final lcov = 'coverage/lcov.info';
      final result = await getLCov('$dir', lcov);
      expect(result[0].toString(), lcov);
      expect(result[1].toString(), 'example/$lcov');
    });
  });
}

String _getCurrentDir() {
  final curDir = Directory.current.path.toString();
  if (curDir.split(slash).last == 'test') {
    return '../';
  }
  return '';
}

void Function() overridePrint(void testFn()) => () {
      final spec = ZoneSpecification(print: (_, __, ___, String msg) {
        // Add to log instead of printing to stdout
        log.add(msg);
      });
      return Zone.current.fork(specification: spec).run<void>(testFn);
    };

List<FileEntity> files0 = [
  FileEntity('lib/test_cov_console.dart'),
  FileEntity('lib/src/parser.dart'),
  FileEntity('lib/src/print_cov.dart'),
];

List<FileEntity> files = [
  FileEntity('lib/src/a_print_cov.dart'),
  FileEntity('lib/src/parser.dart'),
  FileEntity('lib/src/parser_constants.dart'),
  FileEntity('lib/src/print_cov.dart'),
  FileEntity('lib/test_cov_console.dart'),
];

const outFiles = [
  'File,% Branch,% Funcs,% Lines,Uncovered Line #s \n'
      '',
  'lib/src/,,,, \n'
      '',
  'a_print_cov.dart,0.00,0.00,0.00,no unit testing\n'
      '',
  'parser.dart,100.00,100.00,95.65,"10"\n'
      '',
  'parser_constants.dart,100.00,100.00,100.00,""\n'
      '',
  'print_cov.dart,100.00,100.00,85.27,"31,34,103,104,111,132,135,138,141,144,145,146,147,148,149,205,206,207,231"\n'
      '',
  'lib/,,,, \n'
      '',
  'test_cov_console.dart,0.00,0.00,0.00,no unit testing\n'
      '',
  'All files with unit testing,100.00,100.00,87.18,""\n'
      ''
];

const String lcovFile = '''
SF:lib/src/parser_constants.dart
DA:14,3
DA:15,1
DA:16,1
DA:25,1
LF:4
LH:4
end_of_record
SF:lib/src/parser.dart
DA:6,1
DA:8,1
DA:9,2
DA:10,0
DA:13,1
DA:15,4
DA:20,3
DA:21,3
DA:22,1
DA:25,2
DA:27,3
DA:29,3
DA:30,5
DA:34,3
DA:35,3
DA:36,4
DA:41,1
DA:47,1
DA:48,1
DA:50,1
DA:54,1
DA:56,2
DA:58,1
LF:23
LH:22
end_of_record
SF:lib/src/print_cov.dart
DA:16,1
DA:17,3
DA:18,3
DA:27,1
DA:28,4
DA:29,1
DA:31,0
DA:34,0
DA:37,1
DA:39,3
DA:54,1
DA:55,1
DA:58,3
DA:60,3
DA:62,1
DA:63,3
DA:64,3
DA:65,3
DA:66,3
DA:67,3
DA:68,3
DA:77,1
DA:79,1
DA:81,1
DA:88,1
DA:90,2
DA:91,2
DA:92,2
DA:93,1
DA:94,1
DA:95,1
DA:96,1
DA:97,1
DA:98,2
DA:99,1
DA:100,2
DA:102,3
DA:103,0
DA:104,0
DA:109,5
DA:110,3
DA:111,0
DA:113,2
DA:114,1
DA:116,1
DA:117,1
DA:118,1
DA:119,2
DA:120,1
DA:121,2
DA:122,3
DA:125,1
DA:126,3
DA:128,1
DA:129,3
DA:131,1
DA:132,0
DA:134,1
DA:135,0
DA:137,1
DA:138,0
DA:140,1
DA:141,0
DA:143,1
DA:144,0
DA:145,0
DA:146,0
DA:147,0
DA:148,0
DA:149,0
DA:152,1
DA:154,1
DA:155,2
DA:156,2
DA:161,2
DA:163,2
DA:164,3
DA:165,4
DA:168,1
DA:170,3
DA:171,2
DA:172,1
DA:176,1
DA:177,2
DA:178,1
DA:179,2
DA:188,1
DA:189,2
DA:199,1
DA:200,3
DA:201,3
DA:202,3
DA:203,2
DA:204,2
DA:205,0
DA:206,0
DA:207,0
DA:209,2
DA:210,1
DA:211,1
DA:212,1
DA:214,3
DA:216,1
DA:221,1
DA:222,1
DA:223,1
DA:225,4
DA:228,1
DA:229,2
DA:231,0
DA:234,1
DA:236,3
DA:237,1
DA:238,1
DA:239,1
DA:240,1
DA:248,1
DA:249,1
DA:250,3
DA:251,1
DA:252,2
DA:253,2
DA:254,3
DA:255,1
DA:256,3
DA:257,1
DA:263,1
DA:266,2
DA:267,1
LF:129
LH:110
end_of_record
''';

const output = '''
---------------------------------------------|---------|---------|---------|-------------------|
File                                         |% Branch | % Funcs | % Lines | Uncovered Line #s |
---------------------------------------------|---------|---------|---------|-------------------|
lib/src/                                     |         |         |         |                   |
 a_print_cov.dart                            |    0.00 |    0.00 |    0.00 |    no unit testing|
 parser.dart                                 |  100.00 |  100.00 |   95.65 |                 10|
 parser_constants.dart                       |  100.00 |  100.00 |  100.00 |                   |
 print_cov.dart                              |  100.00 |  100.00 |   85.27 |...,205,206,207,231|
lib/                                         |         |         |         |                   |
 test_cov_console.dart                       |    0.00 |    0.00 |    0.00 |    no unit testing|
---------------------------------------------|---------|---------|---------|-------------------|
 All files with unit testing                 |  100.00 |  100.00 |   87.18 |                   |
---------------------------------------------|---------|---------|---------|-------------------|''';
