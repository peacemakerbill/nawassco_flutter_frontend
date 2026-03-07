class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Phone number validation (Kenyan format)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove any non-digit characters
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');

    // Check if it's a valid Kenyan phone number
    final phoneRegex = RegExp(r'^(?:254|\+254|0)?(7\d{8})$');

    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Please enter a valid Kenyan phone number';
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Minimum length validation
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  // Maximum length validation
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }
    return null;
  }

  // Numeric validation
  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) return null;

    if (double.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }

    return null;
  }

  // Positive number validation
  static String? validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName must be a valid number';
    }

    if (number <= 0) {
      return '$fieldName must be greater than 0';
    }

    return null;
  }

  // Amount validation
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid amount';
    }

    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }

    if (amount > 1000000) { // 1 million limit
      return 'Amount cannot exceed KES 1,000,000';
    }

    return null;
  }

  // Account number validation
  static String? validateAccountNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Account number is required';
    }

    // Remove any non-alphanumeric characters
    final cleaned = value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    if (cleaned.length < 6) {
      return 'Account number must be at least 6 characters';
    }

    if (cleaned.length > 20) {
      return 'Account number cannot exceed 20 characters';
    }

    return null;
  }

  // Meter number validation
  static String? validateMeterNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Meter number is required';
    }

    // Remove any non-alphanumeric characters
    final cleaned = value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    if (cleaned.length < 6) {
      return 'Meter number must be at least 6 characters';
    }

    if (cleaned.length > 15) {
      return 'Meter number cannot exceed 15 characters';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Date validation
  static String? validateDate(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    // Simple date format validation (DD/MM/YYYY)
    final dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!dateRegex.hasMatch(value)) {
      return 'Please enter date in DD/MM/YYYY format';
    }

    try {
      final parts = value.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      DateTime(year, month, day);
    } catch (e) {
      return 'Please enter a valid date';
    }

    return null;
  }

  // Future date validation
  static String? validateFutureDate(String? value, String fieldName) {
    final dateError = validateDate(value, fieldName);
    if (dateError != null) return dateError;

    try {
      final parts = value!.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final inputDate = DateTime(year, month, day);
      final today = DateTime.now();

      if (inputDate.isBefore(today)) {
        return '$fieldName cannot be in the past';
      }
    } catch (e) {
      return 'Please enter a valid date';
    }

    return null;
  }

  // Past date validation
  static String? validatePastDate(String? value, String fieldName) {
    final dateError = validateDate(value, fieldName);
    if (dateError != null) return dateError;

    try {
      final parts = value!.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final inputDate = DateTime(year, month, day);
      final today = DateTime.now();

      if (inputDate.isAfter(today)) {
        return '$fieldName cannot be in the future';
      }
    } catch (e) {
      return 'Please enter a valid date';
    }

    return null;
  }

  // ID number validation (Kenyan)
  static String? validateIdNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'ID number is required';
    }

    // Remove any non-digit characters
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.length != 8) {
      return 'ID number must be 8 digits';
    }

    return null;
  }

  // KRA PIN validation
  static String? validateKRAPin(String? value) {
    if (value == null || value.isEmpty) {
      return 'KRA PIN is required';
    }

    final cleaned = value.replaceAll(RegExp(r'[^\dA-Z]'), '');

    if (cleaned.length != 11) {
      return 'KRA PIN must be 11 characters';
    }

    // Basic format validation (AXXXXXXXXXA)
    final pinRegex = RegExp(r'^[A-Z]\d{9}[A-Z]$');
    if (!pinRegex.hasMatch(cleaned)) {
      return 'Please enter a valid KRA PIN format';
    }

    return null;
  }

  // File size validation
  static String? validateFileSize(int? size, int maxSizeInBytes) {
    if (size == null) {
      return 'File is required';
    }

    if (size > maxSizeInBytes) {
      final maxSizeMB = (maxSizeInBytes / (1024 * 1024)).toStringAsFixed(1);
      return 'File size cannot exceed $maxSizeMB MB';
    }

    return null;
  }

  // File type validation
  static String? validateFileType(String? fileName, List<String> allowedExtensions) {
    if (fileName == null || fileName.isEmpty) {
      return 'File is required';
    }

    final extension = fileName.toLowerCase().split('.').last;

    if (!allowedExtensions.contains(extension)) {
      final allowedList = allowedExtensions.join(', ').toUpperCase();
      return 'Only $allowedList files are allowed';
    }

    return null;
  }

  // Composite validator for multiple validations
  static String? validateMultiple(List<String? Function()> validators) {
    for (final validator in validators) {
      final error = validator();
      if (error != null) return error;
    }
    return null;
  }
}