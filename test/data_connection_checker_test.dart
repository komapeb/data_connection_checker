import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:test/test.dart';

void main() {
  // These tests are fairly stupid and not needed
  group('Testing data_connection_checker.', () {
    test('Checking if initial results List is empty', () {
      expect(DataConnectionChecker().lastTryResults, isNull);
    });
  });
}
