abstract final class Validators {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');

  static const minPasswordLength = 8;
  static const maxNameLength = 60;
  static const maxCategoryNameLength = 40;

  static bool isEmail(String value) => _email.hasMatch(value.trim());

  static bool isStrongEnough(String password) =>
      password.length >= minPasswordLength;
}
