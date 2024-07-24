import 'dart:convert';

import 'package:hello_nitr/core/constants/app_constants.dart';

class EncryptionFunction {
  String encryptPassword(String password) {
    if (password.isNotEmpty) {
      String base64Encode = base64.encode(utf8.encode(password));
      String prependedPassword = AppConstants.securityKey + base64Encode;
      String encryptedPassword = prependedPassword;
      return encryptedPassword;
    }
    return password;
  }

  // Decrypts the given encrypted password.
  // The [encryptedPassword] parameter is the base64 encoded encrypted password to be decrypted.
  // This method decodes the base64 encoded encrypted password, removes the security key part,
  // and then decodes the base64 encoded original password to obtain the decrypted password.
  // Returns the decrypted password if the [encryptedPassword] is not empty, otherwise returns the [encryptedPassword] itself.
}
