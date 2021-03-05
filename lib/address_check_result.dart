part of data_connection_checker;

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
  String toString() => 'AddressCheckResult($options, $isSuccess)';
}
