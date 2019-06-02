## data_connection_checker

Checks for an actual internet connection, by opening a socket connection to DNS Resolver addresses.

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

## Usage

Example:

```dart
import 'package:data_connection_checker/dart_data_connection_checker.dart';

main() async {
  var internetChecker = DataConnectionChecker();
  print("The statement 'this machine is connected to the Internet' is: ");
  print(await internetChecker.hasDataConnection);

  print('---------\nlog from the last check:');
  print(internetChecker.lastTryLog);
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme
