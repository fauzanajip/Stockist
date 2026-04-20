class Validators {
  Validators._();

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    if (double.tryParse(value) == null) {
      return '$fieldName harus berupa angka';
    }
    return null;
  }

  static String? validatePositiveNumber(String? value, String fieldName) {
    final error = validateNumber(value, fieldName);
    if (error != null) return error;
    
    if (double.parse(value!) <= 0) {
      return '$fieldName harus lebih dari 0';
    }
    return null;
  }

  static String? validateNonNegativeNumber(String? value, String fieldName) {
    final error = validateNumber(value, fieldName);
    if (error != null) return error;
    
    if (double.parse(value!) < 0) {
      return '$fieldName tidak boleh negatif';
    }
    return null;
  }

  static String? validateMinLength(String? value, int minLength, String fieldName) {
    final error = validateRequired(value, fieldName);
    if (error != null) return error;
    
    if (value!.length < minLength) {
      return '$fieldName minimal $minLength karakter';
    }
    return null;
  }

  static String? validateMaxQty(int value, int maxQty, String fieldName) {
    if (value > maxQty) {
      return '$fieldName tidak boleh melebihi $maxQty';
    }
    return null;
  }
}
