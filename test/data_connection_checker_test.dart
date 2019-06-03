import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:test/test.dart';

void main() {
  // These tests are fairly stupid and not needed
  group('Testing data_connection_checker.', () {
    DataConnectionChecker internetChecker;

    setUp(() {
      internetChecker = DataConnectionChecker();
    });

    test('Checking if initial log string is empty', () {
      expect(internetChecker.lastTryLog, isEmpty);
    });

    test(
        'Checking for data connection, without waiting for the result of the completed Future should return Future<bool>',
        () {
      expectLater(internetChecker.hasDataConnection, isA<Future<bool>>());
    });

    test(
        "Checking for data connection and waiting for the result of the completed Future should return a boolean",
        () {
      expect(internetChecker.hasDataConnection, completion(isA<bool>()));
    });
  });
}
