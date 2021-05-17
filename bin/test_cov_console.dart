// Copyright (c) 2021, I Made Mudita. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart' as a;
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
  final parser = a.ArgParser()
    ..addSeparator(
        'Generate coverage test report from lcov.info file to console.\n'
        'If not given a FILE, "coverage/lcov.info" will be used.')
    ..addOption('file',
        abbr: 'f',
        help: 'the target lcov.info file to be reported',
        valueHelp: 'FILE')
    ..addMultiOption('exclude',
        abbr: 'e',
        splitCommas: true,
        help: 'a list of contains string for files without unit testing\n'
            'to be excluded from report',
        valueHelp: 'STRING1,STRING2,...')
    ..addFlag('help',
        abbr: 'h', negatable: false, defaultsTo: false, help: 'show this help');

  final args = parser.parse(arguments);

  if (args['help']) {
    print(parser.usage);
    exit(0);
  }

  final patterns =
      (args['exclude'] as List<String>).map((s) => s).toList(growable: false);

  final slash = Platform.isWindows ? '\\' : '/';
  String lcovFile = args['file'] ?? 'coverage${slash}lcov.info';

  final lines = await File(lcovFile).readAsLines();
  final files = await getFiles('lib', patterns);

  printCoverage(lines, files);
}
