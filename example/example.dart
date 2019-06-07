import 'dart:async';

import 'package:data_connection_checker/data_connection_checker.dart';

// This of code will continue on running forever if not interrupted.
const Duration INTERVAL = Duration(seconds: 5);

main() async {
  // cspell:disable
  // check if we have the interwebz
  print("The statement 'this machine is connected to the Internet' is: ");
  print(await DataConnectionChecker().hasConnection);

  // We can also get an enum instead of a bool
  print(await DataConnectionChecker().connectionStatus);
  // prints either DataConnectionStatus.connected
  // or DataConnectionStatus.disconnected

  print('Results from the last check:');
  // this returns the results from the last call to either hasConnection or connectionStatus
  print(DataConnectionChecker().lastTryResults);

  // Check periodically, every 5 seconds, until the process is stopped
  _checkPeriodically();
}

void _checkPeriodically([Timer timer]) async {
  // we don't want other calls, until this one is done, so we cancel the timer
  // until this check completes
  print("Stopping the timer while we make a request.");
  timer?.cancel();

  print("Trying to ping: ${DataConnectionChecker().addresses}");

  bool result = await DataConnectionChecker().hasConnection;
  if (result) {
    print("We're part of the World. Hello, World! YAY!");
  } else {
    print('No cat pictures for the time being. So sad :(');
  }

  print("Starting the timer again...");
  Timer(INTERVAL, _checkPeriodically);
}
