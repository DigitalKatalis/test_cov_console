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
    return '$directory$fileName';
  }
}

/// OutputFile.
///
/// Simple class to store the csv output to List
/// and save it to csv file
class OutputFile {
  static File? outputFile;
  static List<String> tmpFile = [];

  static Future<void> saveFile() async {
    await outputFile?.writeAsString(tmpFile.join());
  }
}

/// _Data.
///
/// Simple class to store the coverage information
class _Data {
  int functionFound = 0;
  int functionHit = 0;
  int linesFound = 0;
  int linesHit = 0;
  int branchFound = 0;
  int branchHit = 0;
  String uncoveredLines = PrintCovConstants.emptyString;
  String uncoveredBranch = PrintCovConstants.emptyString;
  FileEntity file = FileEntity('/');

  _Data(FileEntity file) {
    this.file = file;
  }

  String getFileName() => file.fileName;

  void total(_Data data) {
    functionFound += data.functionFound;
    functionHit += data.functionHit;
    linesFound += data.linesFound;
    linesHit += data.linesHit;
    branchFound += data.branchFound;
    branchHit += data.branchHit;
  }
}

void printJacocoCovCsv(List<String> lines, List<FileEntity> files, String module) {
  final dataList = _getCoverage(lines, files);

  for (final file in files) {
    if (!file.fileName.contains("All files")) {
      _Data? data = dataList[file.toString()];
      if (data == null) {
        data = _Data(file);
        data.linesFound = File(module + "/" + file.toString()).readAsLinesSync().length;
      }

      String csv = ""
          // group
          + "$module,"
          // package
          + "${data.file.directory},"
          // class
          + "${data.file.fileName},"
          // instruction missed
          + "${data.linesFound - data.linesHit},"
          // instruction covered
          + "${data.linesHit},"
          // branch missed
          + "${data.branchFound - data.branchHit},"
          // branch covered
          + "${data.branchHit},"
          // line missed
          + "${data.linesFound - data.linesHit},"
          // line covered
          + "${data.linesHit},"
          // complexity missed
          + "${data.branchFound - data.branchHit},"
          // complexity covered
          + "${data.branchHit},"
          // method missed
          + "${data.functionFound - data.functionHit},"
          // method covered
          + "${data.functionHit}";

      _printValue(csv);
    }
  }
}

void printJacocoHeader() {
  _printValue("GROUP,PACKAGE,CLASS,INSTRUCTION_MISSED,INSTRUCTION_COVERED,BRANCH_MISSED,BRANCH_COVERED,LINE_MISSED,LINE_COVERED,COMPLEXITY_MISSED,COMPLEXITY_COVERED,METHOD_MISSED,METHOD_COVERED");
}

/// printCoverage.
///
/// Generate coverage test report from lcov.info file to console.
/// [lines] is the list of string from lcov.info file
/// [files] is the list of file in string that already filter by exclude params.
/// [module] is the module name
/// [isCsv] is whether it will print to console or csv file
/// [isSummary] is whether it will print the total coverage only or not
/// [min] is it will print whether total coverage is passed/failed from this value
/// [isLineOnly] is it will print Lines & Uncovered Lines only
void printCov(List<String> lines, List<FileEntity> files, String module,
    bool isCsv, bool isSummary, int min, bool isLineOnly) {
  final dataList = _getCoverage(lines, files);

  final totalData = dataList[PrintCovConstants.allFiles]!;
  if (isSummary) {
    final mdl = module.isEmpty ? '' : '$module : ';
    if (min > 0) {
      final cov = 100 * totalData.linesHit / totalData.linesFound;
      if (cov >= min) {
        print('${mdl}PASSED');
      } else {
        print('${mdl}FAILED');
      }
    } else {
      final cov = _formatPercent(totalData.linesHit, totalData.linesFound);
      print('$mdl$cov');
    }
    return;
  }

  _printHeader(isCsv, isLineOnly, module);

  String lastDir = PrintCovConstants.emptyString;

  if (files.isEmpty) {
    for (final data in dataList.values) {
      if (data != totalData) {
        lastDir = _printDir(data, data.file, lastDir, isCsv, isLineOnly);
      }
    }
  } else {
    for (final file in files) {
      lastDir = _printDir(
          dataList[file.toString()], file, lastDir, isCsv, isLineOnly);
    }
  }

  _printTotal(isCsv, isLineOnly, totalData);
}

/// _printTotal
///
/// It will print total coverage lines
void _printTotal(bool isCsv, bool isLineOnly, _Data totalData) {
  // _print(
  //   PrintCovConstants.dash,
  //   PrintCovConstants.dash,
  //   PrintCovConstants.dash,
  //   PrintCovConstants.dash,
  //   PrintCovConstants.dash,
  //   PrintCovConstants.dash,
  //   isCsv,
  //   isLineOnly,
  // );
  totalData.file = FileEntity(PrintCovConstants.allFiles);
  _printFile(totalData, isCsv, isLineOnly);
  _print(
    PrintCovConstants.dash,
    PrintCovConstants.dash,
    PrintCovConstants.dash,
    PrintCovConstants.dash,
    PrintCovConstants.dash,
    PrintCovConstants.dash,
    isCsv,
    isLineOnly,
  );
}

/// _printHeader
///
/// It will print header coverage lines
void _printHeader(bool isCsv, bool isLineOnly, String module) {
  // _print(
  //   PrintCovConstants.dash,
  //   PrintCovConstants.dash,
  //   PrintCovConstants.dash,
  //   PrintCovConstants.dash,
  //   PrintCovConstants.dash,
  //   PrintCovConstants.dash,
  //   isCsv,
  //   isLineOnly,
  // );
  _print(
      "**" + "${PrintCovConstants.file}$module" + "**",
      "**" + PrintCovConstants.branch + "**",
      "**" + PrintCovConstants.functions + "**",
      "**" + PrintCovConstants.lines + "**",
      "**" + PrintCovConstants.unCovered + "**",
      PrintCovConstants.space,
      isCsv,
      isLineOnly,
      isSave: true);
  _print(
    PrintCovConstants.dash,
    PrintCovConstants.dash,
    PrintCovConstants.dash,
    PrintCovConstants.dash,
    PrintCovConstants.dash,
    PrintCovConstants.dash,
    isCsv,
    isLineOnly,
  );
}

/// _getCoverage
///
/// Convert List of string [lines] in lcov format to list of [_Data]
/// It will proceed only all files on [files], and ignore the rest
Map<String, _Data> _getCoverage(List<String> lines, List<FileEntity> files) {
  Map<String, _Data> dataList = {};
  late _Data currentData;
  _Data totalData = _Data(FileEntity(PrintCovConstants.allFiles));
  final listFiles = files.map((e) => e.toString()).toList();
  bool isCalculate = true;

  for (final line in lines) {
    final values = line.split(PrintCovConstants.colon);
    switch (values[0]) {
      case PrintCovConstants.SF:
        isCalculate = files.isEmpty || listFiles.contains(values.last);
        if (isCalculate) {
          currentData = _Data(FileEntity(values.last
              .replaceAll(PrintCovConstants.bSlash, PrintCovConstants.slash)));
        }
        break;
      case PrintCovConstants.DA:
        if (isCalculate && line.endsWith(PrintCovConstants.zero)) {
          currentData.uncoveredLines =
              (currentData.uncoveredLines != PrintCovConstants.emptyString
                      ? '${currentData.uncoveredLines},'
                      : PrintCovConstants.emptyString) +
                  values[1].split(PrintCovConstants.comma)[0];
        }
        break;
      case PrintCovConstants.LF:
        if (isCalculate) {
          currentData.linesFound = int.parse(values[1]);
        }
        break;
      case PrintCovConstants.LH:
        if (isCalculate) {
          currentData.linesHit = int.parse(values[1]);
        }
        break;
      case PrintCovConstants.FNF:
        if (isCalculate) {
          currentData.functionFound = int.parse(values[1]);
        }
        break;
      case PrintCovConstants.FNH:
        if (isCalculate) {
          currentData.functionHit = int.parse(values[1]);
        }
        break;
      case PrintCovConstants.BRF:
        if (isCalculate) {
          currentData.branchFound = int.parse(values[1]);
        }
        break;
      case PrintCovConstants.BRH:
        if (isCalculate) {
          currentData.branchHit = int.parse(values[1]);
        }
        break;
      case PrintCovConstants.BRDA:
        if (isCalculate && line.endsWith(PrintCovConstants.zero)) {
          currentData.uncoveredBranch =
              (currentData.uncoveredBranch != PrintCovConstants.emptyString
                      ? '${currentData.uncoveredBranch},'
                      : PrintCovConstants.emptyString) +
                  values[1].split(PrintCovConstants.comma)[0];
        }
        break;
      case PrintCovConstants.endOfRecord:
        if (isCalculate) {
          dataList[currentData.file.toString()] = currentData;
          totalData.total(currentData);
        }
        break;
    }
  }
  dataList[PrintCovConstants.allFiles] = totalData;
  return dataList;
}

/// _printDir.
///
/// print directory [directory] & test coverage result [data]
String _printDir(_Data? data, FileEntity file, String directory, bool isCsv,
    bool isLineOnly) {
  String dir = directory;
  if (file.directory != dir) {
    dir = file.directory;
    _print(
        isCsv
            ? file.directory
            : _formatString(
                file.directory,
                PrintCovConstants.fileLen +
                    (isLineOnly ? (2 * PrintCovConstants.percentLen) : 0),
                PrintCovConstants.emptyString),
        PrintCovConstants.space,
        PrintCovConstants.space,
        PrintCovConstants.space,
        PrintCovConstants.space,
        PrintCovConstants.space,
        isCsv,
        isLineOnly,
        isSave: true);
  }
  if (data == null) {
    _print(
        ' ${file.fileName}',
        PrintCovConstants.zeroDotZeros,
        PrintCovConstants.zeroDotZeros,
        PrintCovConstants.zeroDotZeros,
        PrintCovConstants.noUnitTesting,
        PrintCovConstants.space,
        isCsv,
        isLineOnly,
        isSave: true);
  } else {
    _printFile(data, isCsv, isLineOnly);
  }
  return dir;
}

/// _printFile.
///
/// print test coverage result [data] to console with some formatting
_Data _printFile(_Data data, bool isCsv, bool isLineOnly) {
  final functions = _formatPercent(data.functionHit, data.functionFound);
  final lines = _formatPercent(data.linesHit, data.linesFound);
  final branch = _formatPercent(data.branchHit, data.branchFound);
  if (functions.trim() == PrintCovConstants.hundred &&
      lines.trim() == PrintCovConstants.hundred &&
      branch.trim() == PrintCovConstants.hundred) {
    data.uncoveredLines = PrintCovConstants.emptyString;
    data.uncoveredBranch = PrintCovConstants.emptyString;
  }
  var uncovered =
      data.uncoveredLines.isEmpty ? data.uncoveredBranch : data.uncoveredLines;
  if (isCsv) {
    uncovered = '"$uncovered"';
  } else {
    uncovered = _formatString(
        uncovered, PrintCovConstants.uncoverLen, PrintCovConstants.dot3);
  }
  final file = isCsv
      ? ' ${data.getFileName()}'
      : _formatString(' ${data.getFileName()}', PrintCovConstants.fileLen,
          PrintCovConstants.emptyString);
  _print(file, branch, functions, lines, uncovered, PrintCovConstants.space,
      isCsv, isLineOnly,
      isSave: true);

  return data;
}

/// _formatPercent.
///
/// return the percentage of [hit] / [found] with 2 digit decimal
/// return 100.00 if [found] == 0
String _formatPercent(int hit, int found) {
  if (found == 0) {
    return '${PrintCovConstants.hundred} ';
  }
  return '${(hit / found * 100).toStringAsFixed(2)} ';
}

/// _formatString.
///
/// return the substring [input] with prefix [more]
/// if the string length is more than [length]
String _formatString(String input, int length, String more) {
  return input.length <= length
      ? input
      : '$more${input.substring(input.length - length + more.length)}';
}

void _printValue(String value) {
  OutputFile.tmpFile.add("$value\n");
}

/// _print.
///
/// print to console one line of test coverage result
/// [file]  | [branch]  |  [function] | [lines] |
/// when [isCsv] is true it will save to file if [isSave] is true
void _print(String file, String branch, String function, String lines,
    String uncovered, String filler, bool isCsv, bool isLineOnly,
    {bool isSave = false}) {
  String output;
  if (isCsv) {
    if (isSave) {
      output = '${file.trim()},${branch.trim()},'
          '${function.trim()},${lines.trim()},$uncovered\n';
      if (isLineOnly) {
        output = '${file.trim()},${lines.trim()},$uncovered\n';
      }
      OutputFile.tmpFile.add(output);
    }
  } else {
    output = '| ${file.padRight(PrintCovConstants.fileLen, filler)} | '
        '${branch.padLeft(PrintCovConstants.percentLen, filler)} | '
        '${function.padLeft(PrintCovConstants.percentLen, filler)} | '
        '${lines.padLeft(PrintCovConstants.percentLen, filler)} | '
        '${uncovered.padLeft(PrintCovConstants.uncoverLen, filler)} | ';
    if (isLineOnly) {
      output =
          '${file.padRight(PrintCovConstants.fileLen + 2 * PrintCovConstants.percentLen, filler)}|'
          '${lines.padLeft(PrintCovConstants.percentLen, filler)}|'
          '${uncovered.padLeft(PrintCovConstants.uncoverLen, filler)}|';
    }
    print(output);
  }
}

/// getFiles.
///
/// Get all dart files on [path] directory (e.g. lib directory), recursive to all
/// sub-directories.
/// [exclude] is the list of string to filter/exclude any files (contain).
/// [includes] is the list of string to filter/include any files (contain).
Future<List<FileEntity>> getFiles(String path, List<String> excludes,
    List<String> includes, String module) async {
  final dir = Directory(path);
  final files = await dir.list(recursive: true).toList();
  final List<FileEntity> list = [];
  files.forEach((element) {
    final String file = element.uri.toString();
    if (file.split(PrintCovConstants.dot).last == PrintCovConstants.dart &&
        (excludes.isEmpty || !_isContain(excludes, file)) &&
        (includes.isEmpty || _isContain(includes, file))) {
      String strFile = replaceSlash(element.uri.toString());
      if (module.isNotEmpty) {
        strFile = strFile.replaceFirst('$module/', '');
      }
      final file = FileEntity(strFile);
      list.add(file);
    }
  });
  list.sort((a, b) => a.compareTo(b));
  return list;
}

/// replaceSlash.
///
/// replace '\\' with '/' on Windows platform.
String replaceSlash(String input) {
  String result = input;
  if (Platform.isWindows) {
    result = result.replaceAll('\\', '/');
  }
  return result;
}

/// _isContain.
///
/// return true if [file] is in [list] list.
bool _isContain(List<String> list, String file) {
  bool result = false;

  for (var item in list) {
    if (file.contains(item)) {
      result = true;
      break;
    }
  }

  return result;
}

/// getLCov.
///
/// Get all [lcov] files on [path] directory, recursive to all sub-directories.
Future<List<FileEntity>> getLCov(String path, String lcov) async {
  final dir = Directory(path);
  final files = await dir.list(recursive: true).toList();
  final List<FileEntity> list = [];
  files.forEach((element) {
    final String fileName = element.uri.toString();
    if (fileName.endsWith(lcov)) {
      if (FileSystemEntity.typeSync(fileName) == FileSystemEntityType.file && !fileName.contains(".symlinks")) {
        //print("Adding $fileName to list");
        final file = FileEntity(replaceSlash(element.uri.toString()));
        list.add(file);
      }// else {
        //print("$fileName is not a file...");
      //}
    }
  });
  list.sort((a, b) => a.compareTo(b));
  return list;
}
