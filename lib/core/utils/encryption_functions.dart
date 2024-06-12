import 'dart:convert';

import 'package:hello_nitr/core/constants/app_constants.dart';

class EncryptionFunction {
  String encryptPassword(String password) {
    if (password.isNotEmpty) {
      String base64Encode = base64.encode(utf8.encode(password));
      String prependedPassword =  AppConstants.securityKey + base64Encode;
      String encryptedPassword = base64.encode(utf8.encode(prependedPassword));
      return encryptedPassword;
    }

    return password;
  }

}
