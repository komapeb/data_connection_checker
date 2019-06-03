import 'dart:async';
import 'dart:io';

import 'package:data_connection_checker/data_connection_checker.dart';


main() {
  //
}


/*

// Note that this isn't the way to write code
// You usually don't want to pollute your global scope like this
// This code is written like this for the sake of demonstration and simplicity

// init an instance with default config
var _internetChecker = DataConnectionChecker();

// global reference to the timer, so we can manipulate it everywhere
Timer _timerHandle;

main() async {
  // cspell:disable
  // check if we have the interwebz
  print("The statement 'this machine is connected to the Internet' is: ");
  print(await _internetChecker.hasDataConnection);

  print('---------\nlog from the last check:');
  print(_internetChecker.lastTryLog);

  // Check periodically, every 5 seconds, until the process is stopped
  _startCheckingPeriodically();
}

void _checkPeriodically(_) async {
  // we don't want other calls, until this one is done, so we cancel the timer
  // until this check completes
  _stopCheckingPeriodically();

  bool result = await _internetChecker.hasDataConnection;
  if (result) {
    print("We're part of the World. Hello, World! YAY!");
  } else {
    print('No cat pictures for the time being. So sad :(');
  }

  _startCheckingPeriodically();
}

void _startCheckingPeriodically() {
  _timerHandle = Timer.periodic(Duration(seconds: 5), _checkPeriodically);
}

void _stopCheckingPeriodically() {
  if (_timerHandle != null) _timerHandle.cancel();
}
// */
