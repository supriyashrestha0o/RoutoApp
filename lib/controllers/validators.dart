String? collegeEmail(String? value) {
  if (!RegExp(
    r'^[^@\s]+@patancollege\.edu\.np$',
    caseSensitive: false,
  ).hasMatch(value?.trim() ?? '')) {
    return 'Enter your Patan College email address';
  }
  return null;
}

String? requiredField(String? value) =>
    value == null || value.trim().isEmpty ? 'Enter a value' : null;

String? validAge(String? value) {
  final number = int.tryParse(value?.trim() ?? '');
  return number == null || number < 15 || number > 100
      ? 'Enter a valid age (15-100)'
      : null;
}
