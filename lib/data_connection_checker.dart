/// A utility library to check for an actual internet connection
/// by opening a socket connection to a list of addresses and/or ports.
/// Defaults are provided for convenience.

library data_connection_checker;

import 'dart:io';
import 'dart:async';

import 'package:meta/meta.dart';

class DataConnectionChecker {
  /// More info  on why default port is 53
  /// here: https://www.google.com/search?q=dns+server+port
  static final int DEFAULT_PORT = 53;

  /// Default timeout is 10 seconds
  /// Timeout is the number of seconds before a request is dropped
  /// and an address is considered unreachable
  static final Duration DEFAULT_TIMEOUT = Duration(seconds: 10);

  /// Predefined reliable addresses. This is opinionated
  /// but should be enough for a starting point.
  ///
  /// 1.1.1.1           CloudFlare, info: https://one.one.one.one/ http://1.1.1.1
  ///
  /// 8.8.8.8           Google, info: https://developers.google.com/speed/public-dns/
  ///
  /// 8.8.4.4           Google
  ///
  /// 208.67.222.222    OpenDNS, info: https://use.opendns.com/
  ///
  /// 208.67.220.220    OpenDNS
  static final List<InternetAddressCheckOptions> DEFAULT_ADDRESSES = [
    InternetAddressCheckOptions(
      InternetAddress('1.1.1.1'),
      port: DEFAULT_PORT,
      timeout: DEFAULT_TIMEOUT,
    ),
    InternetAddressCheckOptions(
      InternetAddress('8.8.4.4'),
      port: DEFAULT_PORT,
      timeout: DEFAULT_TIMEOUT,
    ),
    InternetAddressCheckOptions(
      InternetAddress('208.67.222.222'),
      port: DEFAULT_PORT,
      timeout: DEFAULT_TIMEOUT,
    ),
  ];

  /// This is a singleton that can be accessed like a regular constructor
  /// i.e. DataConnectionChecker() always returns the same instance.
  factory DataConnectionChecker() => _instance;
  DataConnectionChecker._();
  static final DataConnectionChecker _instance = DataConnectionChecker._();

  /// See [InternetAddressCheckOptions] for more info.
  ///
  ///
  /// [DataConnectionChecker.addresses]
  /// A list of internet addresses (with port and timeout) DNS Resolvers to ping.
  /// These should be globally available destinations.
  /// Default is [DataConnectionChecker.DEFAULT_ADDRESSES]
  ///
  /// When [DataConnectionChecker.hasDataConnection] is called,
  /// this utility class tries to ping every address in this list.
  ///
  /// The provided addresses should be good enough to test for data connection
  /// but you can, of course, you can supply your own
  List<InternetAddressCheckOptions> addresses;

  String _lastTryLog = '';

  /// Returns the log message from the last try
  String get lastTryLog => _lastTryLog;

  /// Initiates a request to each address in [DataConnectionChecker.addresses]
  /// If at least one of the addresses is reachable
  /// this means we have an internet connection and this returns true.
  /// Otherwise - false.
  Future<bool> get hasDataConnection async {
    // reset log message
    _lastTryLog = '';

    // Wait all futures to complete and return true
    // if there's at least one true boolean in the list
    // return (await Future.wait(addresses
    //         .map((address) => _isHostReachable(address, port, timeout))
    //         .toList()))
    //     .contains(true);

    // The one-liner above is equivalent to:
    //
    // List<Future<bool>> requests = [];
    // List<bool> results = [];
    //
    // for (var address in addresses) {
    //   requests.add(_isHostReachable(address, port, timeout));
    // }
    //
    // results = await Future.wait(requests);
    // return results.contains(true);
  }
}

/// This class should be pretty self-explanatory.
/// If [InternetAddressCheckOptions.port]
/// or [InternetAddressCheckOptions.timeout] are not specified, they both
/// default to [DataConnectionChecker.DEFAULT_PORT]
/// and [DataConnectionChecker.DEFAULT_TIMEOUT]
/// Also... yeah, I'm not great at naming things.
@immutable
class InternetAddressCheckOptions {
  final InternetAddress address;
  final int port;
  final Duration timeout;

  const InternetAddressCheckOptions(
    this.address, {
    this.port,
    this.timeout,
  });

  @override
  String toString() => "$address, port: $port, timeout: $timeout";
}

/*


  Future<bool> _isHostReachable(
    InternetAddress address,
    int port,
    Duration timeout,
  ) async {
    _lastTryLog += 'Trying to ping $address, port: $port, '
        'with timeout: ${timeout.inSeconds} seconds \n';


    Socket sock;
    try {
      sock = await Socket.connect(address, port, timeout: timeout);
      sock.destroy();

      // dev stuff, remove in production
      _lastTryLog += '$address is reachable. \n';
      // end dev stuff

      return true;
    } catch (e) {
      if (sock != null) sock.destroy();

      // dev stuff, remove in production
      _lastTryLog += '$address is unreachable. Reason: $e \n';
      // end dev stuff

      return false;
    }
  }
}
// */
