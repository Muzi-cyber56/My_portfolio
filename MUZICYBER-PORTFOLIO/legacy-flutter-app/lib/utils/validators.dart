class Validators {
  static String? required(String? v) =>
      v == null || v.trim().isEmpty ? 'This field is required.' : null;
  static String? title(String? v) => v == null || v.trim().length < 3
      ? 'Use at least 3 characters.'
      : v.length > 160
      ? 'Use up to 160 characters.'
      : null;
  static String? password(String? v) => v == null || v.length < 12
      ? 'Use at least 12 characters.'
      : v.length > 128
      ? 'Use up to 128 characters.'
      : null;
}
