class InputValidators {
  InputValidators._();

  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Must contain an uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Must contain a lowercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Must contain a number';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-()]'), ''))) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) return '${fieldName ?? 'Field'} is required';
    if (value.length < min) return '${fieldName ?? 'Field'} must be at least $min characters';
    return null;
  }

  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value != null && value.length > max) {
      return '${fieldName ?? 'Field'} must not exceed $max characters';
    }
    return null;
  }

  static String? serialNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Serial number is required';
    if (value.length < 4) return 'Serial number must be at least 4 characters';
    return null;
  }

  static String? positiveNumber(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) return '${fieldName ?? 'Field'} is required';
    final num = double.tryParse(value);
    if (num == null) return 'Enter a valid number';
    if (num <= 0) return '${fieldName ?? 'Value'} must be greater than 0';
    return null;
  }

  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }
}
