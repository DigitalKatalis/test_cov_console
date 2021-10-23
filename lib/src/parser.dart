import 'package:test_cov_console/src/parser_constants.dart';

/// Parser.
///
/// class to parse the command line arguments to Map
class Parser {
  final List<String> arguments;

  Parser(this.arguments);

  /// parse.
  ///
  /// Parse [arguments] in GNU (--help, --file, --exclude, --multi)
  /// and POSIX (-h, -f, -e, -m) style options
  /// to Map<String, dynamic>, for instance
  /// {
  ///   'file': '/dir1/file1.dart',
  ///   'exclude': ['string1', 'string2' ],
  ///   'multi': 'multi',
  ///   'csv': 'csv',
  ///   'csvFile': '/dir2/file2'
  /// }
  Map<String, dynamic> parse() {
    if (arguments.isEmpty) {
      return {};
    }

    /// Return for help option
    if (arguments.contains('-h') ||
        arguments.contains('--${ParserConstants.help}')) {
      return _returnHelp();
    }

    /// Replace all option 1 format (-f value) with option 2 format (--file=value)
    String strArg = arguments.join(' ');
    for (final opt in ParserConstants.fieldMap) {
      if (opt.isNoValue) {
        final opt1 = '-${opt.opt1}';
        final opt2 = '--${opt.opt2}';
        strArg = strArg.replaceAll('$opt1 ', '$opt2 ');
        strArg = replaceLast(strArg, opt1, opt2);
      } else {
        strArg = strArg.replaceAll('-${opt.opt1} ', '--${opt.opt2}=');
      }
    }

    final args = strArg.split(' ');
    final Map<String, dynamic> result = {};

    /// For total & pass, it will ignore any other option, except 'multi'
    final total = contains(args, '--${ParserConstants.total}');
    final pass = contains(args, '--${ParserConstants.pass}');
    final multi = contains(args, '--${ParserConstants.multi}');
    if (total.isNotEmpty || pass.isNotEmpty) {
      if (total.isNotEmpty) {
        result[ParserConstants.total] = ParserConstants.total;
      } else {
        result[ParserConstants.pass] =
            _getValues(pass, '--${ParserConstants.pass}=', false);
      }
      if (multi.isNotEmpty) {
        result[ParserConstants.multi] = ParserConstants.multi;
      }
      return result;
    }

    for (final item in args) {
      final arg = item.toLowerCase();
      for (final opt in ParserConstants.fieldMap) {
        if (arg.startsWith('--${opt.opt2}')) {
          if (opt.isNoValue) {
            result[opt.opt2] = opt.opt2;
          } else {
            result[opt.opt2] = _getValues(arg, '--${opt.opt2}=', opt.isList);
          }
          break;
        }
      }
    }

    //Return error, if there is no result, while some args was passing.
    if (result.isEmpty && args.isNotEmpty) {
      return _returnHelp(error: true);
    }

    return result;
  }

  /// _returnHelp
  /// Return help text in Map<String, dynamic> with [error] message
  dynamic _returnHelp({bool error = false}) {
    return {
      ParserConstants.help:
          (error ? ParserConstants.invalid : '') + ParserConstants.helpPrint
    };
  }

  /// _getValues
  /// Return string of value
  dynamic _getValues(String value, String replace, bool isList) {
    if (isList) {
      return value.replaceFirst(replace, '').split(',');
    }
    return value.replaceFirst(replace, '');
  }
}

/// contains.
///
/// return firs element of [list] that start with [pattern]
String contains(List<String> list, String pattern) {
  final List<String> result =
      list.where((element) => element.startsWith(pattern)).toList();
  return result.isEmpty ? '' : result.first;
}

/// replaceLast.
///
/// replace [oldVal] with [newVal] if [input] is ended with [oldVal]
String replaceLast(String input, String oldVal, String newVal) {
  String result = input;
  if (input.endsWith(oldVal)) {
    result = '${input.substring(0, input.length - oldVal.length)}$newVal';
  }
  return result;
}
