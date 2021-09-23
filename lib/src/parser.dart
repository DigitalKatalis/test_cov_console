import 'package:test_cov_console/src/parser_constants.dart';

class Parser {
  final List<String> arguments;

  Parser(this.arguments);

  Map<String, dynamic> parse() {
    if (arguments.isEmpty) {
      return {};
    }

    //Return for help option
    if (arguments.contains('-h') ||
        arguments.contains('--${ParserConstants.help}')) {
      return _returnHelp();
    }

    //Replace all option 1 format (-f value) with option 2 format (--file=value)
    String strArg = arguments.join(' ');
    for (final opt in ParserConstants.fieldMap) {
      strArg = strArg.replaceAll('-${opt.opt1} ', '--${opt.opt2}=');
    }

    final args = strArg.split(' ');
    final Map<String, dynamic> result = {};
    for (final item in args) {
      final arg = item.toLowerCase();
      for (final opt in ParserConstants.fieldMap) {
        if (arg.startsWith('--${opt.opt2}')) {
          result['${opt.opt2}'] = _getValues(arg, '--${opt.opt2}=', opt.isList);
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

  dynamic _returnHelp({bool error = false}) {
    return {
      ParserConstants.help:
          (error ? ParserConstants.invalid : '') + ParserConstants.helpPrint
    };
  }

  dynamic _getValues(String value, String replace, bool isList) {
    if (isList) {
      return value.replaceFirst(replace, '').split(',');
    }
    return value.replaceFirst(replace, '');
  }
}
