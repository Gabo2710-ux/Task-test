class Validators {
  static String? requiredField(String? value, {String message = 'This field is required'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? maxLength(String? value, int max, {String? message}) {
    if (value != null && value.length > max) {
      return message ?? 'Must be $max characters or less';
    }
    return null;
  }
}
