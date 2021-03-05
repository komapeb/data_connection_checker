import 'package:data_connection_checker/data_connection_checker.dart';
import 'dart:async';

Future<void> main() async {
  // Simple check to see if we have Internet
  print('The statement \'this machine is connected to the Internet\' is: ');
  final bool isConnected = await DataConnectionChecker().hasConnection;
  print(isConnected.toString());
  // returns a bool

  // We can also get an enum instead of a bool
  print('Current status: ${await DataConnectionChecker().connectionStatus}');
  // Prints either DataConnectionStatus.connected
  // or DataConnectionStatus.disconnected

  // This returns the last results from the last call
  // to either hasConnection or connectionStatus
  print('Last results: ${DataConnectionChecker().lastTryResults}');

  // actively listen for status updates
  StreamSubscription<DataConnectionStatus> listener =
      DataConnectionChecker().onStatusChange.listen(
    (DataConnectionStatus status) {
      switch (status) {
        case DataConnectionStatus.connected:
          print('Data connection is available.');
          break;
        case DataConnectionStatus.disconnected:
          print('You are disconnected from the internet.');
          break;
      }
    },
  );

  // close listener after 30 seconds, so the program doesn't run forever
  await Future<void>.delayed(Duration(seconds: 30));
  await listener.cancel();
}
