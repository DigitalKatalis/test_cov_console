# Flutter Console Coverage Test

This small dart tools is used to generate Flutter Coverage Test report to console

## How to install
Add a line like this to your package's pubspec.yaml (and run an implicit flutter pub get):
```
dev_dependencies:
  test_cov_console: ^0.0.5
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
 print_cov.dart                              |  100.00 |  100.00 |   77.95 |...,252,258,261,262|
 print_cov_constants.dart                    |    0.00 |    0.00 |    0.00 |    no unit testing|
lib/                                         |         |         |         |                   |
 test_cov_console.dart                       |    0.00 |    0.00 |    0.00 |    no unit testing|
---------------------------------------------|---------|---------|---------|-------------------|
 All files with unit testing                 |  100.00 |  100.00 |   77.95 |                   |
---------------------------------------------|---------|---------|---------|-------------------|
```
## Optional parameter
If not given a FILE, "coverage/lcov.info" will be used.
-f, --file=<FILE>                      the target lcov.info file to be reported
-e, --exclude=<STRING1,STRING2,...>    a list of contains string for files without unit testing
                                       to be excluded from report
-h, --help                             show this help

### example run the tool with parameters
```
flutter pub run bin\test_cov_console.dart --file=coverage\lcov.info --exclude=_constants,_mock
---------------------------------------------|---------|---------|---------|-------------------|
File                                         |% Branch | % Funcs | % Lines | Uncovered Line #s |
---------------------------------------------|---------|---------|---------|-------------------|
lib/src/                                     |         |         |         |                   |
 print_cov.dart                              |  100.00 |  100.00 |   77.95 |...,252,258,261,262|
lib/                                         |         |         |         |                   |
 test_cov_console.dart                       |    0.00 |    0.00 |    0.00 |    no unit testing|
---------------------------------------------|---------|---------|---------|-------------------|
 All files with unit testing                 |  100.00 |  100.00 |   77.95 |                   |
---------------------------------------------|---------|---------|---------|-------------------|
```