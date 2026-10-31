/// Reusable form validation.
///
/// Validators return `null` when the value is acceptable, matching Flutter's
/// `FormFieldValidator` contract.
class Validators {
  const Validators._();

  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required.';
    return null;
  }

  static String? email(String? value) {
    final base = required(value);
    if (base != null) return base;
    if (!_email.hasMatch(value!.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? minLength(int length) {
    return (String? value) {
      if (value == null || value.length < length) {
        return 'Use at least $length characters.';
      }
      return null;
    };
  }

  static String? number(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (num.tryParse(value.trim()) == null) return 'Enter a number.';
    return null;
  }

  static String? positiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required.';
    final parsed = num.tryParse(value.trim());
    if (parsed == null) return 'Enter a number.';
    if (parsed < 0) return 'Enter zero or a positive number.';
    return null;
  }

  static String? positiveInteger(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required.';
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return 'Enter a whole number.';
    if (parsed < 1) return 'Enter at least 1.';
    return null;
  }

  static String? optionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return email(value);
  }
}
