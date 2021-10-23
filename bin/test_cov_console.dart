// Copyright (c) 2021, DKatalis. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:test_cov_console/test_cov_console.dart';

/// Generate coverage test report from lcov.info file to console.
///
/// If not given a FILE, 'coverage/lcov.info' will be used.
///
/// Usage:
/// ```text
/// -f, --file=<FILE>         the target lcov.info file to be reported
/// -e, --exclude=<STRING1,STRING2,...>
///                           a list of contains string for files without unit testing
///                           to be excluded from report
/// -m, --multi               report from multiple lcov.info files
/// -h, --help                show this help
/// ```
Future main(List<String> arguments) async {
  final args = Parser(arguments).parse();
  if (args[ParserConstants.help] != null) {
    print(args[ParserConstants.help]);
    exit(0);
  }

  final List<String> patterns = args[ParserConstants.exclude] ?? [];

  final slash = Platform.isWindows ? '\\' : '/';
  final lcovFile = args[ParserConstants.file] ?? 'coverage${slash}lcov.info';

  final isCsv = args[ParserConstants.csv] == ParserConstants.csv;
  final csvFile =
      args[ParserConstants.csvFile] ?? 'coverage${slash}test_cov_console.csv';

  if (isCsv) {
    OutputFile.outputFile = File(csvFile);
  }

  if (args[ParserConstants.multi] == ParserConstants.multi) {
    final files = await getLCov('.$slash', replaceSlash(lcovFile));
    for (final file in files) {
      final dir = file
          .toString()
          .replaceAll(replaceSlash(lcovFile), '')
          .replaceAll('/', '');
      final lCovFullPath = '${dir.isEmpty ? '' : '$dir$slash'}$lcovFile';
      final libFullPath = '${dir.isEmpty ? '' : '$dir$slash'}lib';
      final module = dir.isEmpty ? '' : ' - $dir -';
      await _printSingleLCov(
          lCovFullPath, patterns, libFullPath, module, isCsv, args);
    }
  } else {
    await _printSingleLCov(lcovFile, patterns, 'lib', '', isCsv, args);
  }

  if (isCsv) {
    OutputFile.saveFile();
  }
}

/// _print report for single module
Future<void> _printSingleLCov(String lcovFile, List<String> patterns,
    String lib, String module, bool isCsv, Map<String, dynamic> args) async {
  List<String> lines = await File(lcovFile).readAsLines();
  if (Platform.isWindows) {
    lines = lines.map((line) => replaceSlash(line)).toList();
  }
  List<FileEntity> files = [];
  final bool isSummary =
      args[ParserConstants.pass] != null || args[ParserConstants.total] != null;
  if (!isSummary && args[ParserConstants.ignore] == null) {
    files = await getFiles(lib, patterns);
  }
  final min = int.parse(args[ParserConstants.pass] ?? '0');
  printCov(lines, files, module, isCsv, isSummary, min);
}
