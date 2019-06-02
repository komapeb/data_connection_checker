import 'package:data_connection_checker/data_connection_checker.dart';

main() async {
  // cspell:disable
  // init an instance with default config and check
  // if we have the interwebz
  var internetChecker = DataConnectionChecker();
  print("The statement 'this machine is connected to the Internet' is: ");
  print(await internetChecker.hasDataConnection);

  print('---------\nlog from the last check:');
  print(internetChecker.lastTryLog);
}
