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
