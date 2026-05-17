import 'package:flutter_test/flutter_test.dart';
import 'package:medquiz_hci/core/utils/validators.dart';

void main() {
  group('Validators.phone', () {
    test('accepts a 10-digit number', () {
      expect(Validators.phone('9876543210'), isNull);
    });

    test('accepts a number with country code, spaces, and dashes', () {
      expect(Validators.phone('+91 98765-43210'), isNull);
    });

    test('rejects an empty string', () {
      expect(Validators.phone(''), isNotNull);
    });

    test('rejects a too-short number', () {
      expect(Validators.phone('12345'), isNotNull);
    });

    test('rejects a 16-digit number', () {
      expect(Validators.phone('1234567890123456'), isNotNull);
    });
  });

  group('Validators.email', () {
    test('accepts a typical email', () {
      expect(Validators.email('doctor@clinic.org'), isNull);
    });

    test('rejects an email without @', () {
      expect(Validators.email('notanemail'), isNotNull);
    });

    test('rejects an email without TLD', () {
      expect(Validators.email('a@b'), isNotNull);
    });
  });

  group('Validators.password', () {
    test('accepts a strong password', () {
      expect(Validators.password('Strong1Password'), isNull);
    });

    test('rejects a short password', () {
      expect(Validators.password('Short1'), isNotNull);
    });

    test('rejects a password with no uppercase', () {
      expect(Validators.password('all-lowercase-1'), isNotNull);
    });

    test('rejects a password with no digits', () {
      expect(Validators.password('Allletters!'), isNotNull);
    });
  });

  group('Validators.otp', () {
    test('accepts exactly 6 digits', () {
      expect(Validators.otp('123456'), isNull);
    });

    test('rejects 5 digits', () {
      expect(Validators.otp('12345'), isNotNull);
    });

    test('rejects letters', () {
      expect(Validators.otp('12a456'), isNotNull);
    });
  });

  group('Validators.age', () {
    test('accepts 0-130', () {
      expect(Validators.age('0'), isNull);
      expect(Validators.age('130'), isNull);
      expect(Validators.age('45'), isNull);
    });

    test('rejects negative or above 130', () {
      expect(Validators.age('-1'), isNotNull);
      expect(Validators.age('131'), isNotNull);
    });

    test('rejects non-numeric', () {
      expect(Validators.age('forty'), isNotNull);
    });
  });

  group('Validators.compose', () {
    test('returns first non-null error in order', () {
      final String? result = Validators.compose(
        '',
        <String? Function(String?)>[
          (String? v) => Validators.required(v, label: 'Name'),
          (String? v) => Validators.minLength(v, 2, label: 'Name'),
        ],
      );
      expect(result, contains('required'));
    });

    test('returns null when all pass', () {
      final String? result = Validators.compose(
        'Anjali',
        <String? Function(String?)>[
          (String? v) => Validators.required(v, label: 'Name'),
          (String? v) => Validators.minLength(v, 2, label: 'Name'),
        ],
      );
      expect(result, isNull);
    });
  });
}
