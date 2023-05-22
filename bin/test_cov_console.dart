// Copyright (c) 2021, DKatalis. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:test_cov_console/test_cov_console.dart';

/// Generate coverage test report from lcov.info file to console.
///
/// If not given a FILE, 'coverage/lcov.info' will be used.
///
Future main(List<String> arguments) async {
  final args = Parser(arguments).parse();
  if (args[ParserConstants.help] != null) {
    print(args[ParserConstants.help]);
    exit(0);
  }

  final List<String> exPatterns = args[ParserConstants.exclude] ?? [];
  final List<String> inPatterns = args[ParserConstants.include] ?? [];

  final slash = Platform.isWindows ? '\\' : '/';
  final lcovFile = args[ParserConstants.file] ?? 'coverage${slash}lcov.info';

  final isCsv = args[ParserConstants.csv] == ParserConstants.csv;
  final csvFile = args[ParserConstants.csvFile] ?? 'coverage${slash}test_cov_console.csv';

  final isJacocoCsv = args[ParserConstants.jacocoCsv] == ParserConstants.jacocoCsv;

  if (isCsv || isJacocoCsv) {
    OutputFile.outputFile = File(csvFile);
  }

  final isLineOnly = args[ParserConstants.line] == ParserConstants.line;

  if (isJacocoCsv) {
    printJacocoHeader();
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
      await _printSingleLCov(lCovFullPath, exPatterns, inPatterns, libFullPath,
          dir, isCsv, isJacocoCsv, isLineOnly, args);
    }
  } else {
    await _printSingleLCov(lcovFile, exPatterns, inPatterns, 'lib', '', isCsv, isJacocoCsv, isLineOnly, args);
  }

  if (isCsv || isJacocoCsv) {
    OutputFile.saveFile();
  }
}

/// _print report for single module
Future<void> _printSingleLCov(
    String lcovFile,
    List<String> exPatterns,
    List<String> inPatterns,
    String lib,
    String module,
    bool isCsv,
    bool isJacocoCsv,
    bool isLineOnly,
    Map<String, dynamic> args) async {
  List<String> lines = await File(lcovFile).readAsLines();
  if (Platform.isWindows) {
    lines = lines.map((line) => replaceSlash(line)).toList();
  }
  List<FileEntity> files = [];
  final bool isSummary =
      args[ParserConstants.pass] != null || args[ParserConstants.total] != null;
  if (!isSummary && args[ParserConstants.ignore] == null) {
    files = await getFiles(lib, exPatterns, inPatterns, module);
    if ((exPatterns.isNotEmpty || inPatterns.isNotEmpty) && files.isEmpty) {
      return;
    }
  }
  final min = int.parse(args[ParserConstants.pass] ?? '0');
  if (!isJacocoCsv) {
    printCov(lines, files, module.isEmpty ? '' : ' - $module -', isCsv, isSummary,
        min, isLineOnly);
  } else {
    printJacocoCovCsv(lines, files, module);
  }
}
