# Flutter Console Coverage Test

This small dart tools is used to generate Flutter Coverage Test report to console

## How to install
Add a line like this to your package's pubspec.yaml (and run an implicit flutter pub get):
```
dev_dependencies:
  test_cov_console: ^0.2.2
```

## How to run
### run the following command to make sure all flutter library is up-to-date
```
flutter pub get
Running "flutter pub get" in coverage...                            0.5s
```
### run the following command to generate lcov.info on coverage directory
```
flutter test --coverage
00:02 +1: All tests passed!
```
### run the tool to generate report from lcov.info
```
flutter pub run test_cov_console
---------------------------------------------|---------|---------|---------|-------------------|
File                                         |% Branch | % Funcs | % Lines | Uncovered Line #s |
---------------------------------------------|---------|---------|---------|-------------------|
lib/src/                                     |         |         |         |                   |
 print_cov.dart                              |  100.00 |  100.00 |   88.37 |...,149,205,206,207|
 print_cov_constants.dart                    |    0.00 |    0.00 |    0.00 |    no unit testing|
lib/                                         |         |         |         |                   |
 test_cov_console.dart                       |    0.00 |    0.00 |    0.00 |    no unit testing|
---------------------------------------------|---------|---------|---------|-------------------|
 All files with unit testing                 |  100.00 |  100.00 |   88.37 |                   |
---------------------------------------------|---------|---------|---------|-------------------|
```
## Optional parameter
```
If not given a FILE, "coverage/lcov.info" will be used.
-f, --file=<FILE>                      The target lcov.info file to be reported
-e, --exclude=<STRING1,STRING2,...>    A list of contains string for files without unit testing
                                       to be excluded from report
-l, --line                             It will print Lines & Uncovered Lines only
                                       Branch & Functions coverage percentage will not be printed
-i, --ignore                           It will not print any file without unit testing
-m, --multi                            Report from multiple lcov.info files
-c, --csv                              Output to CSV file
-o, --output=<CSV-FILE>                Full path of output CSV file
                                       If not given, "coverage/test_cov_console.csv" will be used
-t, --total                            Print only the total coverage
                                       Note: it will ignore all other option (if any), except -m
-p, --pass=<MINIMUM>                   Print only the whether total coverage is passed MINIMUM value or not
                                       If the value >= MINIMUM, it will print PASSED, otherwise FAILED
                                       Note: it will ignore all other option (if any), except -m
-h, --help                             Show this help
```
### example run the tool with parameters
```
flutter pub run test_cov_console --file=coverage/lcov.info --exclude=_constants,_mock
---------------------------------------------|---------|---------|---------|-------------------|
File                                         |% Branch | % Funcs | % Lines | Uncovered Line #s |
---------------------------------------------|---------|---------|---------|-------------------|
lib/src/                                     |         |         |         |                   |
 print_cov.dart                              |  100.00 |  100.00 |   88.37 |...,149,205,206,207|
lib/                                         |         |         |         |                   |
 test_cov_console.dart                       |    0.00 |    0.00 |    0.00 |    no unit testing|
---------------------------------------------|---------|---------|---------|-------------------|
 All files with unit testing                 |  100.00 |  100.00 |   88.37 |                   |
---------------------------------------------|---------|---------|---------|-------------------|
```

### report for multiple lcov.info files (-m, --multi)
```
It support to run for multiple lcov.info files with the followings directory structures:
1. No root module
<root>/<module_a>
<root>/<module_a>/coverage/lcov.info
<root>/<module_a>/lib/src
<root>/<module_b>
<root>/<module_b>/coverage/lcov.info
<root>/<module_b>/lib/src
...
2. With root module
<root>/coverage/lcov.info
<root>/lib/src
<root>/<module_a>
<root>/<module_a>/coverage/lcov.info
<root>/<module_a>/lib/src
<root>/<module_b>
<root>/<module_b>/coverage/lcov.info
<root>/<module_b>/lib/src
...
You must run test_cov_console on <root> dir, and the report would be grouped by module, here is
the sample output for directory structure 'with root module':
flutter pub run test_cov_console --file=coverage/lcov.info --exclude=_constants,_mock --multi
---------------------------------------------|---------|---------|---------|-------------------|
File                                         |% Branch | % Funcs | % Lines | Uncovered Line #s |
---------------------------------------------|---------|---------|---------|-------------------|
lib/src/                                     |         |         |         |                   |
 print_cov.dart                              |  100.00 |  100.00 |   88.37 |...,149,205,206,207|
lib/                                         |         |         |         |                   |
 test_cov_console.dart                       |    0.00 |    0.00 |    0.00 |    no unit testing|
---------------------------------------------|---------|---------|---------|-------------------|
 All files with unit testing                 |  100.00 |  100.00 |   88.37 |                   |
---------------------------------------------|---------|---------|---------|-------------------|
---------------------------------------------|---------|---------|---------|-------------------|
File - module_a -                            |% Branch | % Funcs | % Lines | Uncovered Line #s |
---------------------------------------------|---------|---------|---------|-------------------|
lib/src/                                     |         |         |         |                   |
 print_cov.dart                              |  100.00 |  100.00 |   88.37 |...,149,205,206,207|
lib/                                         |         |         |         |                   |
 test_cov_console.dart                       |    0.00 |    0.00 |    0.00 |    no unit testing|
---------------------------------------------|---------|---------|---------|-------------------|
 All files with unit testing                 |  100.00 |  100.00 |   88.37 |                   |
---------------------------------------------|---------|---------|---------|-------------------|
---------------------------------------------|---------|---------|---------|-------------------|
File - module_b -                            |% Branch | % Funcs | % Lines | Uncovered Line #s |
---------------------------------------------|---------|---------|---------|-------------------|
lib/src/                                     |         |         |         |                   |
 print_cov.dart                              |  100.00 |  100.00 |   88.37 |...,149,205,206,207|
lib/                                         |         |         |         |                   |
 test_cov_console.dart                       |    0.00 |    0.00 |    0.00 |    no unit testing|
---------------------------------------------|---------|---------|---------|-------------------|
 All files with unit testing                 |  100.00 |  100.00 |   88.37 |                   |
---------------------------------------------|---------|---------|---------|-------------------|
```

### Output to CSV file (-c, --csv, -o, --output)
```
flutter pub run test_cov_console -c --output=coverage/test_coverage.csv

#### sample CSV output file:
File,% Branch,% Funcs,% Lines,Uncovered Line #s
lib/,,,,
test_cov_console.dart,0.00,0.00,0.00,no unit testing
lib/src/,,,,
parser.dart,100.00,100.00,97.22,"97"
parser_constants.dart,100.00,100.00,100.00,""
print_cov.dart,100.00,100.00,82.91,"29,49,51,52,171,174,177,180,183,184,185,186,187,188,279,324,325,387,388,389,390,391,392,393,394,395,398"
print_cov_constants.dart,0.00,0.00,0.00,no unit testing
All files with unit testing,100.00,100.00,86.07,""
```