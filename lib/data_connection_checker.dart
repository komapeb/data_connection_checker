/// A pure Dart utility library that checks for an internet connection
/// by opening a socket to a list of specified addresses, each with individual
/// port and timeout. Defaults are provided for convenience.
library data_connection_checker;

/// TODO list for 0.3.0:
/// add ability to check periodically
/// update changelog
/// document it
/// provide examples

import 'dart:io';
import 'dart:async';

/// Represents the status of the data connection.
/// Returned by [DataConnectionChecker.connectionStatus]
enum DataConnectionStatus {
  disconnected,
  connected,
}

/// This is a singleton that can be accessed like a regular constructor
/// i.e. DataConnectionChecker() always returns the same instance.
class DataConnectionChecker {
  /// More info on why default port is 53
  /// here:
  /// - https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
  /// - https://www.google.com/search?q=dns+server+port
  static const int DEFAULT_PORT = 53;

  /// Default timeout is 10 seconds.
  ///
  /// Timeout is the number of seconds before a request is dropped
  /// and an address is considered unreachable
  static const Duration DEFAULT_TIMEOUT = const Duration(seconds: 10);

  /// Default interval is 10 seconds
  ///
  /// Interval us the time between automatic checks
  // TODO Change this to 10 sec
  static const Duration DEFAULT_INTERVAL = const Duration(seconds: 1);

  /// Predefined reliable addresses. This is opinionated
  /// but should be enough. See https://www.dnsperf.com/#!dns-resolvers
  ///
  /// Addresses info:
  ///
  /// <!-- kinda hackish ^_^ -->
  /// <style>
  /// table {
  ///   width: 100%;
  ///   border-collapse: collapse;
  /// }
  /// th, td { padding: 5px; border: 1px solid lightgrey; }
  /// thead { border-bottom: 2px solid lightgrey; }
  /// </style>
  ///
  /// | Address        | Provider   | Info                                            |
  /// |:---------------|:-----------|:------------------------------------------------|
  /// | 1.1.1.1        | CloudFlare | https://1.1.1.1                                 |
  /// | 1.0.0.1        | CloudFlare | https://1.1.1.1                                 |
  /// | 8.8.8.8        | Google     | https://developers.google.com/speed/public-dns/ |
  /// | 8.8.4.4        | Google     | https://developers.google.com/speed/public-dns/ |
  /// | 208.67.222.222 | OpenDNS    | https://use.opendns.com/                        |
  /// | 208.67.220.220 | OpenDNS    | https://use.opendns.com/                        |
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

  /// A list of internet addresses (with port and timeout) to ping.
  /// These should be globally available destinations.
  /// Default is [DEFAULT_ADDRESSES]
  /// When [hasConnection] is called,
  /// this utility class tries to ping every address in this list.
  /// The provided addresses should be good enough to test for data connection
  /// but you can, of course, you can supply your own
  /// See [AddressCheckOptions] for more info.
  List<AddressCheckOptions> addresses = DEFAULT_ADDRESSES;

  /// This is a singleton that can be accessed like a regular constructor
  /// i.e. DataConnectionChecker() always returns the same instance.
  factory DataConnectionChecker() => _instance;
  DataConnectionChecker._() {
    // immediately perform a check so we know the last status
    connectionStatus.then((status) => _lastStatus = status);

    // start sending status updates to onStatusChange when there are listeners
    _statusController.onListen = () {
      _maybeCheckAndEmitStatusUpdate();
    };
    // stop sending status updates when no one is listening
    _statusController.onCancel = () {
      _timerHandle?.cancel();
    };
  }
  static final DataConnectionChecker _instance = DataConnectionChecker._();

  /// Ping a single address.
  Future<AddressCheckResult> isHostReachable(
    AddressCheckOptions options,
  ) async {
    Socket sock;
    try {
      sock = await Socket.connect(
        options.address,
        options.port,
        timeout: options.timeout,
      );
      sock?.destroy();
      return AddressCheckResult(options, true);
    } catch (e) {
      sock?.destroy();
      return AddressCheckResult(options, false);
    }
  }

  /// Returns the results from the last check
  /// The list is populated only when [hasConnection] (or [connectionStatus]) is called
  List<AddressCheckResult> get lastTryResults => _lastTryResults;
  List<AddressCheckResult> _lastTryResults;

  /// Initiates a request to each address in [addresses]
  /// If at least one of the addresses is reachable
  /// this means we have an internet connection and this returns true.
  /// Otherwise - false.
  Future<bool> get hasConnection async {
    // Wait all futures to complete and return true
    // if there's at least one address with isSuccess = true

    List<Future<AddressCheckResult>> requests = [];

    for (var addressOptions in addresses) {
      requests.add(isHostReachable(addressOptions));
    }
    _lastTryResults = List.unmodifiable(await Future.wait(requests));

    return _lastTryResults.map((result) => result.isSuccess).contains(true);
  }

  /// Initiates a request to each address in [addresses]
  /// If at least one of the addresses is reachable
  /// this means we have an internet connection and this returns
  /// [DataConnectionStatus.connected].
  /// [DataConnectionStatus.disconnected] otherwise.
  Future<DataConnectionStatus> get connectionStatus async {
    return await hasConnection
        ? DataConnectionStatus.connected
        : DataConnectionStatus.disconnected;
  }

  // TODO Test and document this new code
  // <new code>

  DataConnectionStatus _lastStatus;

  Duration checkInterval = DEFAULT_INTERVAL;

  Timer _timerHandle;

  _maybeCheckAndEmitStatusUpdate([Timer timer]) async {
    // just in case
    _timerHandle?.cancel();
    timer?.cancel();

    var currentStatus = await connectionStatus;

    // only send status update if last status differs from current
    // and if someone is actually listening
    if (_lastStatus != currentStatus && _statusController.hasListener) {
      _statusController.add(currentStatus);
    }

    // update last status
    _lastStatus = currentStatus;

    // start new timer only if there are listeners
    if (!_statusController.hasListener) return;
    _timerHandle = Timer(checkInterval, _maybeCheckAndEmitStatusUpdate);
  }

  StreamController<DataConnectionStatus> _statusController =
      StreamController.broadcast();

  Stream<DataConnectionStatus> get onStatusChange => _statusController.stream;

  // </new code>
}

/// This class should be pretty self-explanatory.
/// If [AddressCheckOptions.port]
/// or [AddressCheckOptions.timeout] are not specified, they both
/// default to [DataConnectionChecker.DEFAULT_PORT]
/// and [DataConnectionChecker.DEFAULT_TIMEOUT]
/// Also... yeah, I'm not great at naming things.
class AddressCheckOptions {
  final InternetAddress address;
  final int port;
  final Duration timeout;

  AddressCheckOptions(
    this.address, {
    this.port = DataConnectionChecker.DEFAULT_PORT,
    this.timeout = DataConnectionChecker.DEFAULT_TIMEOUT,
  });

  @override
  String toString() => "AddressCheckOptions($address, $port, $timeout)";
}

/// Helper class that contains the address options and indicates whether
/// opening a socket to it succeeded.
class AddressCheckResult {
  final AddressCheckOptions options;
  final bool isSuccess;

  AddressCheckResult(
    this.options,
    this.isSuccess,
  );

  @override
  String toString() => "AddressCheckResult($options, $isSuccess)";
}
