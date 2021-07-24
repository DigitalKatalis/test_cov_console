import 'package:test_cov_console/src/parser_constants.dart';

class Parser {
  final List<String> arguments;

  Parser(this.arguments);

  Map<String, dynamic> parse() {
    if (arguments.isEmpty) {
      return {};
    }

    final Map<String, dynamic> result = {};
    bool bContinue = false;
    for (var i = 0; i < arguments.length; ++i) {
      if (bContinue) {
        bContinue = false;
        continue;
      }
      final arg = arguments[i].toLowerCase();
      if (arg == '-h' || arg.startsWith('--${ParserConstants.help}')) {
        return _returnHelp();
      }
      try {
        for (final opt in ParserConstants.fieldMap) {
          if (arg == '-${opt.opt1}' || arg.startsWith('--${opt.opt2}')) {
            if (arg == '-${opt.opt1}') {
              bContinue = true;
              result['${opt.opt2}'] =
                  _getValues(arguments[i + 1], '', opt.isList);
            } else {
              result['${opt.opt2}'] =
                  _getValues(arg, '--${opt.opt2}=', opt.isList);
            }
            break;
          }
        }
      } catch (e) {
        return _returnHelp(error: true);
      }
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
