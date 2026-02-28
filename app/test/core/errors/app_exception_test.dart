import 'package:flutter_test/flutter_test.dart';
import 'package:lcarnet_b2b/core/errors/app_exception.dart';

void main() {
  group('AppException.network', () {
    test('creates network error type', () {
      final ex = AppException.network();
      expect(ex.type, ErrorType.network);
    });

    test('has French message', () {
      final ex = AppException.network();
      expect(ex.message(false), contains('connexion'));
    });

    test('has Darija message', () {
      final ex = AppException.network();
      expect(ex.message(true), contains('الإنترنيت'));
    });
  });

  group('AppException.unknown', () {
    test('creates unknown error type for generic errors', () {
      final ex = AppException.unknown(Exception('something went wrong'));
      expect(ex.type, ErrorType.unknown);
    });

    test('detects SocketException and returns network type', () {
      final ex = AppException.unknown(Exception('SocketException: OS Error'));
      expect(ex.type, ErrorType.network);
    });

    test('detects TimeoutException and returns network type', () {
      final ex = AppException.unknown(Exception('TimeoutException after 30s'));
      expect(ex.type, ErrorType.network);
    });

    test('detects HandshakeException and returns network type', () {
      final ex = AppException.unknown(
        Exception('HandshakeException: connection terminated'),
      );
      expect(ex.type, ErrorType.network);
    });

    test('detects Connection refused and returns network type', () {
      final ex = AppException.unknown(
        Exception('Connection refused to localhost:54321'),
      );
      expect(ex.type, ErrorType.network);
    });

    test('stores debug info', () {
      final ex = AppException.unknown(Exception('custom error'));
      expect(ex.debugInfo, contains('custom error'));
    });
  });

  group('AppException message locale switching', () {
    test('message(false) returns French', () {
      const ex = AppException(
        type: ErrorType.server,
        messageFr: 'French text',
        messageDarija: 'Darija text',
      );
      expect(ex.message(false), 'French text');
    });

    test('message(true) returns Darija', () {
      const ex = AppException(
        type: ErrorType.server,
        messageFr: 'French text',
        messageDarija: 'Darija text',
      );
      expect(ex.message(true), 'Darija text');
    });
  });

  group('AppException.toString', () {
    test('includes type and debug info', () {
      const ex = AppException(
        type: ErrorType.permission,
        messageFr: 'Access denied',
        messageDarija: 'ما عندكش الصلاحية',
        debugInfo: 'RLS violation',
      );
      expect(ex.toString(), contains('permission'));
      expect(ex.toString(), contains('RLS violation'));
    });
  });

  group('ErrorType enum', () {
    test('has all expected values', () {
      expect(ErrorType.values.length, 10);
      expect(ErrorType.values, contains(ErrorType.network));
      expect(ErrorType.values, contains(ErrorType.server));
      expect(ErrorType.values, contains(ErrorType.auth));
      expect(ErrorType.values, contains(ErrorType.permission));
      expect(ErrorType.values, contains(ErrorType.notFound));
      expect(ErrorType.values, contains(ErrorType.duplicate));
      expect(ErrorType.values, contains(ErrorType.validation));
      expect(ErrorType.values, contains(ErrorType.storage));
      expect(ErrorType.values, contains(ErrorType.rateLimit));
      expect(ErrorType.values, contains(ErrorType.unknown));
    });
  });
}
