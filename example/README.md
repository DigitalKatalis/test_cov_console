# example

Given here an example project that generated using Android Studio => File => New => new Flutter project.

## Project Explanation

There is no changes on this project since generated, 
the only change is adding test_cov_console lib to pubspec.yaml.
```
dev_dependencies:
  flutter_test:
    sdk: flutter
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
lib\                                         |         |         |         |                   |
 main.dart                                   |  100.00 |  100.00 |   92.59 |                3,4|
---------------------------------------------|---------|---------|---------|-------------------|
