import 'package:hello_nitr/core/constants/app_constants.dart';

class EncryptionFunction {
  String encryptPassword(String password) {
    if (password.isNotEmpty) {
      // Encrypt the password using the security key
      String encryptedPassword =  AppConstants.securityKey + password;
      return encryptedPassword;
    }

    return password;
  }

  // String decryptPassword(String encryptedPassword) {
  //   if (encryptedPassword.isNotEmpty) {
  //     // Decrypt the password using the security key
  //     String decryptedPassword = encryptedPassword.replaceAll(AppConstants.securityKey, '');
  //     return decryptedPassword;
  //   }

  //   return encryptedPassword;
  // }
}
