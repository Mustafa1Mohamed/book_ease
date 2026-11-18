abstract final class AuthValidators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required.';
    if (value.trim().length < 2) return 'Enter a valid full name.';
    return null;
  }

  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required.';
    final pattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!pattern.hasMatch(email)) return 'Enter a valid email address.';
    return null;
  }

  static String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Password is required.';
    if (password.length < 8) return 'Password must be at least 8 characters.';
    if (!RegExp(r'[A-Z]').hasMatch(password) ||
        !RegExp(r'[0-9]').hasMatch(password)) {
      return 'Use at least 1 uppercase letter and 1 number.';
    }
    return null;
  }

  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    return null;
  }
}
