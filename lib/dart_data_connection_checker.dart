/// A utility library to check for an actual internet connection
/// by opening a socket connection to a list of DNS Resolver addresses.
/// Defaults are provided for convenience.
///
/// More dart docs go here.
library data_connection_checker;

import 'dart:io';
import 'dart:async';

import 'dart:math' as math show Random;

math.Random _rnd = math.Random();

class DataConnectionChecker {
  /// Predefined reliable addresses. This is opinionated
  /// but should be enough for a starting point.
  /// 1.1.1.1           CloudFlare, info: https://one.one.one.one/ http://1.1.1.1
  /// 8.8.8.8           Google, info: https://developers.google.com/speed/public-dns/
  /// 8.8.4.4           Google
  /// 208.67.222.222    OpenDNS, info: https://use.opendns.com/
  /// 208.67.220.220    OpenDNS
  static const List<String> DEFAULT_ADDRESSES = [
    '1.1.1.1',
    '8.8.8.8',
    '8.8.4.4',
    '208.67.222.222',
    '208.67.222.222',
  ];

  /// Port should always be 53.
  /// More info here: https://www.google.com/search?q=dns+server+port
  static const int DEFAULT_PORT = 53;

  /// The addresses associated with this instance.
  List<InternetAddress> get addresses => _addresses;
  List<InternetAddress> _addresses;

  /// The port associated with this instance.
  int get port => _port;
  int _port;

  /// The port associated with this instance.
  Duration get timeout => _timeout;
  Duration _timeout;

  DataConnectionChecker({
    /// A (valid) list of DNS Resolvers to ping.
    /// These should be globally available ping destinations.
    /// Default is [DataConnectionChecker.DEFAULT_ADDRESSES]
    List<String> addresses = DEFAULT_ADDRESSES,

    /// Port should always be 53.
    /// More info here: https://www.google.com/search?q=dns+server+port
    int port = DEFAULT_PORT,

    /// The timeout we should wait before and address is deemed unreachable
    /// Default is 10 seconds.
    Duration timeout = const Duration(seconds: 10),
  })  : _addresses = addresses.map((e) => InternetAddress(e)).toList(),
        _port = port,
        _timeout = timeout;

  /// Makes a request to all of the addresses.
  /// If at least one of the addresses is reachable
  /// this means we have an internet connection
  Future<bool> get hasDataConnection async {
    // reset log message
    _lastTryLog = '';

    // Wait all futures to complete and return true
    // if there's at least one true boolean in the list
    return (await Future.wait(addresses
            .map((address) => _isHostReachable(address, port, timeout))
            .toList()))
        .contains(true);

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

  /// Returns the log from the last try
  String get lastTryLog => _lastTryLog;
  String _lastTryLog;

  //*
  Future<bool> _isHostReachable(
    InternetAddress address,
    int port,
    Duration timeout,
  ) async {
    _lastTryLog += 'Trying to ping $address, port: $port, '
        'with timeout: ${timeout.inSeconds} seconds \n';

    /*
    // dev stuff, remove in production
    // *** MOCKING A LONG-CALL, REMOVE IN PRODUCTION ***
    try {
      // Wait a minimum of [min] and a maximum of [max] seconds
      // but take specified timeout into consideration
      int minWait = 2;
      int maxWait = 30;
      await Future.delayed(
        Duration(seconds: minWait + _rnd.nextInt(maxWait - minWait)),
      ).timeout(
        timeout,
        onTimeout: () {
          final msg = 'Request to $address, port: $port timed out';
          throw TimeoutException(msg, timeout);
        },
      );
      __log('$address is reachable.');
      return true;
    } catch (e) {
      __log('$address is unreachable. Reason ${e}');
      return false;
    }
    // end dev stuff
    // */

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
      _lastTryLog += '$address is unreachable. \n';
      // end dev stuff

      return false;
    }
  }
}
