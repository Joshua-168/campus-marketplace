/// Production Form Validation Utilities for Authentication & User Profile
class AuthValidators {
  AuthValidators._();

  static final RegExp _emailRegExp = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  static final RegExp _phoneRegExp = RegExp(
    r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$',
  );

  /// Validates email address format
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final trimmed = value.trim();
    if (!_emailRegExp.hasMatch(trimmed)) {
      return 'Enter a valid campus email address';
    }
    return null;
  }

  /// Validates password strength (min 8 chars, 1 uppercase, 1 lowercase, 1 number, 1 special char)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter (A-Z)';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter (a-z)';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number (0-9)';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character (!@#\$%^&*)';
    }
    return null;
  }

  /// Validates user full name
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Student full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    return null;
  }

  /// Validates phone number
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!_phoneRegExp.hasMatch(value.trim()) || value.trim().length < 10) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  /// Validates department selection
  static String? validateDepartment(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select your academic department';
    }
    return null;
  }

  /// Validates academic year selection
  static String? validateYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select your academic year';
    }
    return null;
  }
}
