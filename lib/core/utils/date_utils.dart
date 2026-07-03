String formatDateOnly(String value) {
  if (value.isEmpty) {
    return '-';
  }

  return value.split('T').first;
}