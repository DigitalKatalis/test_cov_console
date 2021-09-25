class ParserConstants {
  static const help = 'help';
  static const file = 'file';
  static const exclude = 'exclude';
  static const String invalid = 'Error invalid parameter!\n';
  static const String helpPrint =
      'Generate coverage test report from lcov.info file to console.\n'
      'If not given a FILE, "coverage/lcov.info" will be used.\n'
      '-f, --file=<FILE>                      the target lcov.info file to be reported\n'
      '-e, --exclude=<STRING1,STRING2,...>    a list of contains string for files without unit testing\n'
      '                                       to be excluded from report\n'
      '-h, --help                             show this help';

  static List<Option> fieldMap = [
    Option('f', file, false),
    Option('e', exclude, true),
  ];
}

class Option {
  final String opt1;
  final String opt2;
  final bool isList;

  Option(this.opt1, this.opt2, this.isList);
}
