import 'dart:async';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:test/test.dart';

void main() async {
  group('data_connection_checker', () {
    StreamSubscription<DataConnectionStatus>? listener1;
    StreamSubscription<DataConnectionStatus>? listener2;

    tearDown(() {
      // destroy any active listener after each test
      listener1?.cancel();
      listener2?.cancel();
    });

    test('''Initial results List 'lastTryResults' should be empty''', () {
      expect(
        DataConnectionChecker().lastTryResults,
        isEmpty,
      );
    });

    test('''Shouldn't have any listeners attached''', () {
      expect(
        DataConnectionChecker().hasListeners,
        isFalse,
      );
    });

    test('''Unawaited call hasConnection should return a Future<bool>''', () {
      expect(
        DataConnectionChecker().hasConnection,
        isA<Future<bool>>(),
      );
    });

    test('''Awaited call to hasConnection should return a bool''', () async {
      expect(
        await DataConnectionChecker().hasConnection,
        isA<bool>(),
      );
    });

    test(
        '''DataConnectionChecker().lastTryResults should not be empty after '''
        '''an awaited call to either hasConnection or connectionStatus''', () {
      expect(
        DataConnectionChecker().lastTryResults,
        isNotEmpty,
      );
    });

    test(
        '''Unawaited call to connectionStatus '''
        '''should return a Future<DataConnectionStatus>''', () {
      expect(
        DataConnectionChecker().connectionStatus,
        isA<Future<DataConnectionStatus>>(),
      );
    });

    test(
        '''Awaited call to connectionStatus '''
        '''should return a Future<DataConnectionStatus>''', () async {
      expect(
        await DataConnectionChecker().connectionStatus,
        isA<DataConnectionStatus>(),
      );
    });

    test('''We shouldn't have any listeners 1''', () {
      expect(
        DataConnectionChecker().hasListeners,
        isFalse,
      );
    });

    test('''We should have listeners 1''', () {
      listener1 = DataConnectionChecker().onStatusChange.listen((_) {});
      expect(
        DataConnectionChecker().hasListeners,
        isTrue,
      );
    });

    test('''We should have listeners 2''', () {
      listener1 = DataConnectionChecker().onStatusChange.listen((_) {});
      listener2 = DataConnectionChecker().onStatusChange.listen((_) {});
      expect(
        DataConnectionChecker().hasListeners,
        isTrue,
      );
    });

    test('''We should have listeners 3''', () async {
      listener1 = DataConnectionChecker().onStatusChange.listen((_) {});
      await listener1!.cancel();
      listener2 = DataConnectionChecker().onStatusChange.listen((_) {});
      expect(
        DataConnectionChecker().hasListeners,
        isTrue,
      );
    });

    test('''We shouldn't have any listeners 2''', () async {
      listener1 = DataConnectionChecker().onStatusChange.listen((_) {});
      await listener1!.cancel();
      listener2 = DataConnectionChecker().onStatusChange.listen((_) {});
      await listener2!.cancel();
      expect(
        DataConnectionChecker().hasListeners,
        isFalse,
      );
    });
    
  });
}
