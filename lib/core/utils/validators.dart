/// Pure validation functions. Each returns `null` on success or an error
/// message on failure — matching Flutter's `FormFieldValidator<T>` contract.
class Validators {
  const Validators._();

  static String? required(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required.';
    }
    return null;
  }

  static String? minLength(
    String? value,
    int min, {
    String label = 'This field',
  }) {
    if (value == null || value.length < min) {
      return '$label must be at least $min characters.';
    }
    return null;
  }

  static String? maxLength(
    String? value,
    int max, {
    String label = 'This field',
  }) {
    if (value != null && value.length > max) {
      return '$label must be no more than $max characters.';
    }
    return null;
  }

  /// E.164-style phone validation tolerant of spaces, dashes, and a leading `+`.
  /// Accepts 10-15 digits after normalization. Intentionally permissive — the
  /// SMS provider is the source of truth.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Phone number is required.';
    final String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 10 || digits.length > 15) {
      return 'Enter a valid phone number.';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required.';
    final RegExp pattern = RegExp(r'^[\w\.\-+]+@[\w\-]+(\.[\w\-]+)+$');
    if (!pattern.hasMatch(value.trim())) return 'Enter a valid email address.';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 8) return 'Password must be at least 8 characters.';
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter.';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one digit.';
    }
    return null;
  }

  /// 6-digit OTP code.
  static String? otp(String? value) {
    if (value == null || value.isEmpty) return 'Enter the OTP code.';
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'OTP must be 6 digits.';
    }
    return null;
  }

  static String? age(String? value) {
    if (value == null || value.trim().isEmpty) return 'Age is required.';
    final int? age = int.tryParse(value.trim());
    if (age == null || age < 0 || age > 130)
      return 'Enter a valid age (0-130).';
    return null;
  }

  /// Compose multiple validators. Returns the first non-null error.
  static String? compose(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final String? Function(String?) v in validators) {
      final String? result = v(value);
      if (result != null) return result;
    }
    return null;
  }
}
