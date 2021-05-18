// Copyright (c) 2021, DKatalis. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:test_cov_console/src/print_cov_constants.dart';

/// FileEntity.
///
/// Simple File data structure with [directory] and [fileName] attributes.
class FileEntity {
  String fileName = PrintCovConstants.emptyString;
  String directory = PrintCovConstants.emptyString;

  /// The constructor will extracts [fullName] to [directory] and [fileName].
  FileEntity(String fullName) {
    fileName = fullName.split(PrintCovConstants.slash).last;
    directory = fullName.replaceAll(fileName, PrintCovConstants.emptyString);
  }

  /// Compares this FileEntity to [other].
  ///
  /// Returns a negative value if `this` is ordered before `other`,
  /// a positive value if `this` is ordered after `other`,
  /// or zero if `this` and `other` are equivalent.
  ///
  int compareTo(FileEntity other) {
    if (directory.compareTo(other.directory) < 0) {
      return -1;
    }
    if (directory.compareTo(other.directory) > 0) {
      return 1;
    }
    return fileName.compareTo(other.fileName);
  }

  @override
  String toString() {
    return '$directory/$fileName';
  }
}

class _Data {
  int functionFound = 0;
  int functionHit = 0;
  int linesFound = 0;
  int linesHit = 0;
  int branchFound = 0;
  int branchHit = 0;
  String uncoveredLines = PrintCovConstants.emptyString;
  String uncoveredBranch = PrintCovConstants.emptyString;
  FileEntity file;

  _Data(FileEntity file) {
    this.file = file;
  }

  String getFileName() => file.fileName;

  String getDirectory() => file.directory;

  void total(_Data data) {
    functionFound += data.functionFound;
    functionHit += data.functionHit;
    linesFound += data.linesFound;
    linesHit += data.linesHit;
    branchFound += data.branchFound;
    branchHit += data.branchHit;
  }
}

/// printCoverage.
///
/// Generate coverage test report from lcov.info file to console.
/// [lines] is the list of string from lcov.info file
/// [files] is the list of file in string that already filter by exclude params.
void printCov(List<String> lines, List<FileEntity> files) {
  var idx = 0;
  _print(PrintCovConstants.dash, PrintCovConstants.dash, PrintCovConstants.dash,
      PrintCovConstants.dash, PrintCovConstants.dash, PrintCovConstants.dash);
  _print(
      PrintCovConstants.file,
      PrintCovConstants.branch,
      PrintCovConstants.functions,
      PrintCovConstants.lines,
      PrintCovConstants.unCovered,
      PrintCovConstants.space);
  _print(PrintCovConstants.dash, PrintCovConstants.dash, PrintCovConstants.dash,
      PrintCovConstants.dash, PrintCovConstants.dash, PrintCovConstants.dash);
  final result = lines.fold(<_Data>[
    _Data(FileEntity(PrintCovConstants.emptyString)),
    _Data(FileEntity(PrintCovConstants.emptyString))
  ], (List<_Data> data, line) {
    var data0 = data[0];
    final values = line.split(PrintCovConstants.colon);
    switch (values[0]) {
      case PrintCovConstants.SF:
        final file = FileEntity(values.last
            .replaceAll(PrintCovConstants.bSlash, PrintCovConstants.slash));
        for (var i = idx; i < files.length; i++) {
          idx = i;
          if (file.compareTo(files[i]) > 0) {
            _printDir(files[i], data0.getDirectory(), true);
            data0.file.directory = files[i].directory;
          } else {
            break;
          }
        }
        if ((idx < files.length && file.compareTo(files[idx]) == 0) ||
            (idx == (files.length - 1) && file.compareTo(files[idx]) > 0)) {
          idx = idx + 1;
        }
        final result = _printDir(file, data0.getDirectory(), false);
        data0.file = result;
        break;
      case PrintCovConstants.DA:
        if (line.endsWith(PrintCovConstants.zero)) {
          data0.uncoveredLines =
              (data0.uncoveredLines != PrintCovConstants.emptyString
                      ? '${data0.uncoveredLines},'
                      : PrintCovConstants.emptyString) +
                  values[1].split(PrintCovConstants.comma)[0];
        }
        break;
      case PrintCovConstants.LF:
        data0.linesFound = int.parse(values[1]);
        break;
      case PrintCovConstants.LH:
        data0.linesHit = int.parse(values[1]);
        break;
      case PrintCovConstants.FNF:
        data0.functionFound = int.parse(values[1]);
        break;
      case PrintCovConstants.FNH:
        data0.functionHit = int.parse(values[1]);
        break;
      case PrintCovConstants.BRF:
        data0.branchFound = int.parse(values[1]);
        break;
      case PrintCovConstants.BRH:
        data0.branchHit = int.parse(values[1]);
        break;
      case PrintCovConstants.BRDA:
        if (line.endsWith(PrintCovConstants.zero)) {
          data0.uncoveredBranch =
              (data0.uncoveredBranch != PrintCovConstants.emptyString
                      ? '${data0.uncoveredBranch},'
                      : PrintCovConstants.emptyString) +
                  values[1].split(PrintCovConstants.comma)[0];
        }
        break;
      case PrintCovConstants.endOfRecord:
        {
          data0 = _printFile(data0);
          data[1].total(data0);
          data0 = _Data(data0.file);
        }
        break;
    }

    return [data0, data[1]];
  });
  if (idx < files.length) {
    for (var i = idx; i < files.length; i++) {
      _printDir(files[i], result[0].getDirectory(), true);
    }
  }
  _print(PrintCovConstants.dash, PrintCovConstants.dash, PrintCovConstants.dash,
      PrintCovConstants.dash, PrintCovConstants.dash, PrintCovConstants.dash);
  result[1].file = FileEntity(PrintCovConstants.allFiles);
  _printFile(result[1]);
  _print(PrintCovConstants.dash, PrintCovConstants.dash, PrintCovConstants.dash,
      PrintCovConstants.dash, PrintCovConstants.dash, PrintCovConstants.dash);
}

FileEntity _printDir(FileEntity file, String directory, bool printFile) {
  if (file.directory != directory) {
    _print(
        _formatString(file.directory, PrintCovConstants.fileLen,
            PrintCovConstants.emptyString),
        PrintCovConstants.space,
        PrintCovConstants.space,
        PrintCovConstants.space,
        PrintCovConstants.space,
        PrintCovConstants.space);
  }
  if (printFile) {
    _print(
        ' ${file.fileName}',
        PrintCovConstants.zeroDotZeros,
        PrintCovConstants.zeroDotZeros,
        PrintCovConstants.zeroDotZeros,
        PrintCovConstants.noUnitTesting,
        PrintCovConstants.space);
  }
  return file;
}

_Data _printFile(_Data data0) {
  final functions = _formatPercent(data0.functionHit, data0.functionFound);
  final lines = _formatPercent(data0.linesHit, data0.linesFound);
  final branch = _formatPercent(data0.branchHit, data0.branchFound);
  if (functions.trim() == PrintCovConstants.hundred &&
      lines.trim() == PrintCovConstants.hundred &&
      branch.trim() == PrintCovConstants.hundred) {
    data0.uncoveredLines = PrintCovConstants.emptyString;
    data0.uncoveredBranch = PrintCovConstants.emptyString;
  }
  var uncovered = data0.uncoveredLines.isEmpty
      ? data0.uncoveredBranch
      : data0.uncoveredLines;
  uncovered = _formatString(
      uncovered, PrintCovConstants.uncoverLen, PrintCovConstants.dot3);
  final file = _formatString(' ${data0.getFileName()}',
      PrintCovConstants.fileLen, PrintCovConstants.emptyString);
  _print(file, branch, functions, lines, uncovered, PrintCovConstants.space);

  return data0;
}

String _formatPercent(int hit, int found) {
  if (found == 0) {
    return '${PrintCovConstants.hundred} ';
  }
  return '${(hit / found * 100).toStringAsFixed(2)} ';
}

String _formatString(String input, int length, String more) {
  return input.length <= length
      ? input
      : '$more${input.substring(input.length - length + more.length)}';
}

void _print(String file, String branch, String function, String lines,
    String uncovered, String filler) {
  print('${file.padRight(PrintCovConstants.fileLen, filler)}|'
      '${branch.padLeft(PrintCovConstants.percentLen, filler)}|'
      '${function.padLeft(PrintCovConstants.percentLen, filler)}|'
      '${lines.padLeft(PrintCovConstants.percentLen, filler)}|'
      '${uncovered.padLeft(PrintCovConstants.uncoverLen, filler)}|');
}

/// getFiles.
///
/// Get all dart files on [path] directory (e.g. lib directory), recursive to all
/// sub-directories.
/// [exclude] is the list of string to filter/exclude any files (contain).
Future<List<FileEntity>> getFiles(String path, List<String> excludes) async {
  final dir = Directory(path);
  final files = await dir.list(recursive: true).toList();
  final List<FileEntity> list = [];
  files.forEach((element) {
    final String file = element.uri.toString();
    if (file.split(PrintCovConstants.dot).last == PrintCovConstants.dart &&
        !_isExcluded(excludes, file)) {
      final file = FileEntity(element.uri.toString());
      list.add(file);
    }
  });
  return list;
}

bool _isExcluded(List<String> excludes, String file) {
  bool result = false;

  for (var item in excludes) {
    if (file.contains(item)) {
      result = true;
      break;
    }
  }

  return result;
}
