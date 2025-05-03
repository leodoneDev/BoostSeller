// Validation Functions : made by Leo on 2025/05/04

bool isValidEmail(String email) {
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(email.trim());
}

bool isValidPassword(String password) {
  return password.trim().length >= 6;
}

bool isValidPhoneNumber(String input) {
  final regex = RegExp(r'^\+?[0-9]{7,15}$');
  return regex.hasMatch(input);
}
