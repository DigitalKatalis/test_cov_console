import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:test_cov_console/test_cov_console.dart';

var log = <String>[];

void main() {
  final lines = lcovFile.split('\n');
  final printout = output.split('\n');
  group('printCoverage', () {
    test('should print out with correct format & values', overridePrint(() {
      printCov(lines, files);
      expect(log, printout);
    }));
  });

  group('getFiles', () {
    test('should return file list with some exclusion', () async {
      final dir = _getCurrentDir();
      final result = await getFiles('${dir}lib', ['constants']);
      expect(result[0].toString(), '$dir${files0[0].toString()}');
      expect(result[1].toString(), '$dir${files0[1].toString()}');
    });
  });
}

String _getCurrentDir() {
  final slash = Platform.isWindows ? '\\' : '/';
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
  FileEntity('lib/src/parser.dart'),
  FileEntity('lib/src/print_cov.dart'),
  FileEntity('lib/test_cov_console.dart'),
];

List<FileEntity> files = [
  FileEntity('lib/src/a_print_cov.dart'),
  FileEntity('lib/src/parser.dart'),
  FileEntity('lib/src/parser_constants.dart'),
  FileEntity('lib/src/print_cov.dart'),
  FileEntity('lib/test_cov_console.dart'),
];

const String lcovFile = '''
SF:lib/src/print_cov.dart
DA:8,1
DA:9,1
DA:10,1
DA:12,1
DA:13,3
DA:14,1
DA:15,1
DA:16,1
DA:17,1
DA:18,1
DA:19,1
DA:20,1
DA:21,1
DA:22,1
DA:23,1
DA:24,1
DA:25,1
DA:26,1
DA:27,1
DA:28,3
DA:29,1
DA:30,1
DA:32,1
DA:33,1
DA:36,1
DA:37,1
DA:38,3
DA:39,3
DA:42,1
DA:43,2
DA:45,1
DA:46,2
DA:48,1
DA:49,0
DA:51,1
DA:52,0
DA:54,1
DA:55,0
DA:57,1
DA:58,0
DA:60,1
DA:61,0
DA:62,0
DA:63,0
DA:66,1
DA:68,1
DA:69,1
DA:70,1
DA:71,2
DA:72,2
DA:73,0
DA:78,1
DA:79,1
DA:80,2
DA:81,1
DA:94,1
DA:107,1
DA:110,1
DA:111,1
DA:114,4
DA:117,1
DA:118,2
DA:120,0
DA:123,1
DA:125,3
DA:126,1
DA:127,1
DA:128,1
DA:129,1
LF:69
LH:60
end_of_record
''';

const output = '''
---------------------------------------------|---------|---------|---------|-------------------|
File                                         |% Branch | % Funcs | % Lines | Uncovered Line #s |
---------------------------------------------|---------|---------|---------|-------------------|
lib/src/                                     |         |         |         |                   |
 a_print_cov.dart                            |    0.00 |    0.00 |    0.00 |    no unit testing|
 parser.dart                                 |    0.00 |    0.00 |    0.00 |    no unit testing|
 parser_constants.dart                       |    0.00 |    0.00 |    0.00 |    no unit testing|
 print_cov.dart                              |  100.00 |  100.00 |   86.96 |...,61,62,63,73,120|
lib/                                         |         |         |         |                   |
 test_cov_console.dart                       |    0.00 |    0.00 |    0.00 |    no unit testing|
---------------------------------------------|---------|---------|---------|-------------------|
 All files with unit testing                 |  100.00 |  100.00 |   86.96 |                   |
---------------------------------------------|---------|---------|---------|-------------------|''';
