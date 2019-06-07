# data_connection_checker

[![Pub](https://img.shields.io/pub/v/data_connection_checker.svg)](https://pub.dev/packages/data_connection_checker)

## Description

Checks for an internet (data) connection, by opening a socket to a list addresses

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

The defaults are based on data collected from <https://perfops.net/> (<https://www.dnsperf.com/#!dns-resolvers)>
Here's some more info about it:

### `DEFAULT_ADDRESSES` includes the top 3 globally available DNS resolvers

| Address        | Provider   | Info                                            |
|:---------------|:-----------|:------------------------------------------------|
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

#### `DEFAULT_PORT` is `53`

>A DNS server listens for requests on port 53 (both UDP and TCP). So all DNS requests are sent to port 53 ...

More info:

- <https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers>
- <https://www.google.com/search?q=dns+server+port>

```dart
static const int DEFAULT_PORT = 53;
```

#### `DEFAULT_TIMEOUT` is 10 seconds

```dart
static const Duration DEFAULT_TIMEOUT = Duration(seconds: 10);
```

## Usage

Example:

```dart
import 'package:data_connection_checker/data_connection_checker.dart';

main() async {
  print("The statement 'this machine is connected to the Internet' is: ");
  print(await DataConnectionChecker().hasConnection);

  // We can also get an enum instead of a bool
  print(await DataConnectionChecker().connectionStatus);
  // prints either DataConnectionStatus.connected
  // or DataConnectionStatus.disconnected

  print('Results from the last check:');
  print(DataConnectionChecker().lastTryResults);
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
[install]: https://pub.dev/packages/data_connection_checker#-installing-tab-
