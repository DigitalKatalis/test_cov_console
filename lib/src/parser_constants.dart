class ParserConstants {
  static const help = 'help';
  static const file = 'file';
  static const exclude = 'exclude';
  static const include = 'include';
  static const ignore = 'ignore';
  static const line = 'line';
  static const multi = 'multi';
  static const csv = 'csv';
  static const csvFile = 'output';
  static const jacocoCsv = 'jacoco';
  static const total = 'total';
  static const pass = 'pass';
  static const String invalid = 'Error invalid parameter!\n';
  static const String helpPrint =
      'Generate coverage test report from lcov.info file to console.\n'
      'If not given a FILE, "coverage/lcov.info" will be used.\n'
      '-f, --file=<FILE>                      The target lcov.info file to be reported\n'
      '-e, --exclude=<STRING1,STRING2,...>    A list of contains string for files without unit testing\n'
      '                                       to be excluded from report.\n'
      '-n, --include=<STRING1,STRING2,...>  A list of contains string for files to be include from\n'
      '                                       report.\n'
      '-l, --line                             It will print Lines & Uncovered Lines only\n'
      '                                       Branch & Functions coverage percentage will not be printed\n'
      '-i, --ignore                           It will not print any file without unit testing\n'
      '-m, --multi                            Report from multiple lcov.info files\n'
      '-c, --csv                              Output to CSV file\n'
      '-j, --jacocoCsv                        Output to jacoco-formatted CSV file\n'
      '-o, --output=<CSV-FILE>                Full path of output CSV file\n'
      '                                       If not given, "coverage/test_cov_console.csv" will be used\n'
      '-t, --total                            Print only the total coverage\n'
      '                                       Note: it will ignore all other option (if any), except -m\n'
      '-p, --pass=<MINIMUM>                   Print only the whether total coverage is passed MINIMUM value or not\n'
      '                                       If the value >= MINIMUM, it will print PASSED, otherwise FAILED\n'
      '                                       Note: it will ignore all other option (if any), except -m\n'
      '-h, --help                             Show this help';

  static List<Option> fieldMap = [
    Option('f', file, false, false),
    Option('e', exclude, true, false),
    Option('n', include, true, false),
    Option('i', ignore, false, true),
    Option('l', line, false, true),
    Option('m', multi, false, true),
    Option('c', csv, false, true),
    Option('j', jacocoCsv, false, true),
    Option('o', csvFile, false, false),
    Option('t', total, false, true),
    Option('p', pass, false, false),
  ];
}

class Option {
  final String opt1;
  final String opt2;
  final bool isList;
  final bool isNoValue;

  Option(this.opt1, this.opt2, this.isList, this.isNoValue);
}
