### data_connection_checker

[![Pub](https://img.shields.io/pub/v/data_connection_checker.svg)](https://pub.dev/packages/data_connection_checker)

A pure Dart utility library that checks for an internet connection by opening a socket to a list of specified addresses, each with individual port and timeout. Defaults are provided for convenience.

>*Note that this plugin is in beta and may still have
a few issues. [Feedback][issues_tracker] is welcome.*

### Table of contents

- [Description](#description)
- [Quick start](#quick-start)
- [Purpose](#purpose)
- [How it works](#how-it-works)
- [Defaults](#defaults)
    - [`DEFAULT_ADDRESSES`](#default_addresses)
    - [`DEFAULT_PORT`](#default_port)
    - [`DEFAULT_TIMEOUT`](#default_timeout)
    - [`DEFAULT_INTERVAL`](#default_interval)
- [Usage](#usage)
- [License](#license)
- [Features and bugs](#features-and-bugs)

## Description

Checks for an internet (data) connection, by opening a socket to a list of addresses.

The defaults of the plugin should be sufficient to reliably determine if
the device is currently connected to the global network, e.i. has access to the Internet.

>Note that you should not be using the current network status for deciding whether you can reliably make a network connection. Always guard your app code against timeouts and errors that might come from the network layer.

## Quick start

`DataConnectionChecker()` is actually a Singleton. Calling `DataConnectionChecker()`
is guaranteed to always return the same instance.

You can supply a new list to `DataConnectionChecker().addresses` if you
need to check different destinations, ports and timeouts.
Also, each address can have its own port and timeout.
See `InternetAddressCheckOptions` in the docs for more info.

***First you need to [install it][install] (this is the preferred way)***

Then you can start using the library:

```dart
bool result = await DataConnectionChecker().hasConnection;
if(result == true) {
  print('YAY! Free cute dog pics!');
} else {
  print('No internet :( Reason:');
  print(DataConnectionChecker().lastTryResults);
}
```

## Purpose

The reason this package exists is that `connectivity` package cannot reliably determine if a data connection is actually available. More info on its page here: <https://pub.dev/packages/connectivity>

More info on the issue in general:

- <https://stackoverflow.com/questions/1560788/how-to-check-internet-access-on-android-inetaddress-never-times-out/27312494#27312494> (this is the best approach so far IMO and it's what I'm using)

You can use this package in combination with `connectivity` in the following way:

```dart
var isDeviceConnected = false;

var subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
  if(result != ConnectivityResult.none) {
    isDeviceConnected = await DataConnectionChecker().hasConnection;
  }
});
```

*Note: remember to properly cancel the `subscription` when it's no longer needed. See `connectivity` package docs for more info.*

## How it works

All addresses are pinged simultaneously. On successful result (socket connection to address/port succeeds) a `true` boolean is pushed to a list, on failure (usually on timeout, default 10 sec) a `false` boolean is pushed to the same list.

When all the requests complete with either success or failure, a check is made to see if the list contains at least one `true` boolean. If it does, then an external address is available, so we have data connection. If all the values in this list are `false`, then we have no connection to the outside world of cute cat and dog pictures, so `hasConnection` also returns `false` too.

This all happens at the same time for all addresses, so the maximum waiting time is the address with the highest specified timeout, in case it's unreachable.

I believe this is a ***reliable*** and ***fast*** method to check if a data connection is available to a device, but I may be wrong. I suggest you open an issue on the Github repository page if you have a better way of.

## Defaults

The defaults are based on data collected from <https://perfops.net/>, <https://www.dnsperf.com/#!dns-resolvers>

Here's some more info about the defaults:

#### `DEFAULT_ADDRESSES`

... includes the top 3 globally available free DNS resolvers.

| Address        | Provider   | Info                                              |
| :------------- | :--------- | :------------------------------------------------ |
| 1.1.1.1        | CloudFlare | <https://1.1.1.1>                                 |
| 1.0.0.1        | CloudFlare | <https://1.1.1.1>                                 |
| 8.8.8.8        | Google     | <https://developers.google.com/speed/public-dns/> |
| 8.8.4.4        | Google     | <https://developers.google.com/speed/public-dns/> |
| 208.67.222.222 | OpenDNS    | <https://use.opendns.com/>                        |
| 208.67.220.220 | OpenDNS    | <https://use.opendns.com/>                        |

```dart
static final List<AddressCheckOptions> DEFAULT_ADDRESSES = List.unmodifiable([
  AddressCheckOptions(
    InternetAddress('1.1.1.1'),
    port: DEFAULT_PORT,
    timeout: DEFAULT_TIMEOUT,
  ),
  AddressCheckOptions(
    InternetAddress('8.8.4.4'),
    port: DEFAULT_PORT,
    timeout: DEFAULT_TIMEOUT,
  ),
  AddressCheckOptions(
    InternetAddress('208.67.222.222'),
    port: DEFAULT_PORT,
    timeout: DEFAULT_TIMEOUT,
  ),
]);
```

#### `DEFAULT_PORT`

... is 53.

>A DNS server listens for requests on port 53 (both UDP and TCP). So all DNS requests are sent to port 53 ...

More info:

- <https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers>
- <https://www.google.com/search?q=dns+server+port>

```dart
static const int DEFAULT_PORT = 53;
```

#### `DEFAULT_TIMEOUT`

... is 10 seconds.

```dart
static const Duration DEFAULT_TIMEOUT = Duration(seconds: 10);
```

#### `DEFAULT_INTERVAL`

... is 10 seconds. Interval is the time between automatic checks. Automatic
checks start if there's a listener attached to `onStatusChange`, thus remember
to cancel unneeded subscriptions.

`checkInterval` (which controls how often a check is made) defaults
to this value. You can change it if you need to perform checks more often
or otherwise.

```dart
static const Duration DEFAULT_INTERVAL = const Duration(seconds: 10);
...
Duration checkInterval = DEFAULT_INTERVAL;
```

## Usage

Example:

```dart
import 'package:data_connection_checker/data_connection_checker.dart';

main() async {
  // Simple check to see if we have internet
  print("The statement 'this machine is connected to the Internet' is: ");
  print(await DataConnectionChecker().hasConnection);
  // returns a bool

  // We can also get an enum value instead of a bool
  print("Current status: ${await DataConnectionChecker().connectionStatus}");
  // prints either DataConnectionStatus.connected
  // or DataConnectionStatus.disconnected

  // This returns the last results from the last call
  // to either hasConnection or connectionStatus
  print("Last results: ${DataConnectionChecker().lastTryResults}");

  // actively listen for status updates
  // this will cause DataConnectionChecker to check periodically
  // with the interval specified in DataConnectionChecker().checkInterval
  // until listener.cancel() is called
  var listener = DataConnectionChecker().onStatusChange.listen((status) {
    switch (status) {
      case DataConnectionStatus.connected:
        print('Data connection is available.');
        break;
      case DataConnectionStatus.disconnected:
        print('You are disconnected from the internet.');
        break;
    }
  });

  // close listener after 30 seconds, so the program doesn't run forever
  await Future.delayed(Duration(seconds: 30));
  await listener.cancel();
}
```

*Note: Remember to dispose of any listeners,
when they're not needed to prevent memory leaks,
e.g. in a* `StatefulWidget`'s *dispose() method*:
  
```dart
...
@override
void dispose() {
  listener.cancel();
  super.dispose();
}
...
```

See `example` folder for more examples.

## License

MIT

Copyright 2019 Kristiyan Mitev and [Spirit Navigator][spiritnavigator]

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][issues_tracker].

[issues_tracker]: https://github.com/komapeb/data_connection_checker/issues
[pull_requests]: https://github.com/komapeb/data_connection_checker/pulls
[install]: https://pub.dev/packages/data_connection_checker#-installing-tab-
[spiritnavigator]: https://spiritnavigator.com/