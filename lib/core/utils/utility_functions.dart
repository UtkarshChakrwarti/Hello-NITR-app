class UtilityFunctions {

  bool isValidBase64(String base64String) {
    final base64Pattern = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
    return base64Pattern.hasMatch(base64String);
  }
}
