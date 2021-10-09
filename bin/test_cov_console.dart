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
  String lcovFile = args[ParserConstants.file] ?? 'coverage${slash}lcov.info';

  List<String> lines = await File(lcovFile).readAsLines();
  if (Platform.isWindows) {
    lines = lines.map((line) => line.replaceAll('\\', '/')).toList();
  }
  final files = await getFiles('lib', patterns);
  printCov(lines, files);
}
