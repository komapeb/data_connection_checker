## data_connection_checker

[This package is on pub.dev](https://pub.dev/packages/data_connection_checker) ![Pub](https://img.shields.io/pub/v/data_connection_checker.svg)

## Description

Checks for an internet (data) connection, by opening a socket connection to DNS Resolver addresses to port 53.

The defaults of the plugin should be sufficient to reliably determine if
the device is currently connected to the global network, e.i. has access to the Internet.

## Quick start:

```dart
// DataConnectionChecker accepts 3 named parameters,
// which can override the defaults.
// See the docs for more info.
var internetChecker = DataConnectionChecker();
bool result await internetChecker.hasDataConnection;
if(result == true) {
  print('YAY! Free cute dog pics!');
} else {
  print('No internet :( Reason:');
  print(internetChecker.lastTryLog);
}
```

Once the class is instantiated, there's no way to change the addresses/port/timeout. This is by design, but I'm open to discussion, just submit an issue on the official repository page.

## Purpose

The reason this package exists is that `connectivity` package cannot reliably determine if a data connection is actually available. More info on its page here: https://pub.dev/packages/connectivity and here: https://stackoverflow.com/questions/49648022/check-whether-there-is-an-internet-connection-available-on-flutter-app

You can use this package in combination with `connectivity` in the following way:

```dart
var isDeviceConnected = false;

var internetChecker = DataConnectionChecker();

var subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
  if(result != ConnectivityResult.none) {
    isDeviceConnected = await internetChecker.hasDataConnection;
  }
});
```

*Note: remember to properly cancel the `subscription` when it's no longer needed. See `connectivity` package docs for more info.*

## How it works

All addresses are pinged simultaneously. On successful result (socket connection to address/port succeeds) a `true` boolean is pushed to a list, on failure (usually on timeout, default 10 sec) a `false` boolean is pushed to the same list.

When all the requests complete with either success or failure, a check is made to see if the list contains at least one `true` boolean. If it does, then an external address is available, so we have data connection. If all the values in this list are `false`, then we have no connection to the outside world of cute cat and dog pictures, so `hasDataConnection()` returns `false` too.

This all happens at the same time for all addresses, so the maximum waiting time is the specified timeout.

I believe this a reliable method to check if a data connection is available to the device (running this code), but I may be wrong. I suggest you open an issue on the Github repository page if you have a better way.

## Defaults

The defaults are based on data collected from https://perfops.net/ (https://www.dnsperf.com/#!dns-resolvers)
Here's some more info about it:

#### `DEFAULT_ADDRESSES` includes the top 3 globally available DNS resolvers:

```plain
1.1.1.1           CloudFlare, info: https://one.one.one.one/ http://1.1.1.1
8.8.4.4           Google, info: https://developers.google.com/speed/public-dns/
208.67.220.220    OpenDNS, info: https://use.opendns.com/
```

```dart
static const List<String> DEFAULT_ADDRESSES = [
  '1.1.1.1',
  '8.8.4.4',
  '208.67.220.220',
];
```

#### `DEFAULT_PORT` should always be `53`

>A DNS server listens for requests on port 53 (both UDP and TCP). So all DNS requests are sent to port 53 ...

More info here: https://www.google.com/search?q=dns+server+port


```dart
static const int DEFAULT_PORT = 53;
```

#### `DEFAULT_TIMEOUT` is 10 seconds, which can easily be overridden when instantiating the class.

Overriding the default timeout:

```dart
var _internetChecker = DataConnectionChecker(timeout: Duration(CUSTOM_TIMEOUT));
```

## Usage

Example:

```dart
import 'package:data_connection_checker/data_connection_checker.dart';

main() async {
  var internetChecker = DataConnectionChecker();
  print("The statement 'this machine is connected to the Internet' is: ");
  print(await internetChecker.hasDataConnection);

  print('---------\nlog from the last check:');
  print(internetChecker.lastTryLog);
}
```

See `example` folder for more examples.

## License

MIT

Copyright 2019 Kristiyan Mitev

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/komapeb/data_connection_checker/issues