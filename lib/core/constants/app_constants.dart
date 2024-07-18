class AppConstants {
  //Current App version
  static const String currentAppVersion = '2.0.0';

  // Security key for encryption and OTP generation
  static const String securityKey = "wW6BOreU82Aab4V"; // Key for encryption

  // API URLs and other constants
  static const String baseUrl = 'https://arogyakavach.nitrkl.ac.in/WebApi';
  
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.nitrkl.hellonitr';

  static const String catUrl =  
      'https://www.nitrkl.ac.in/CAT#:~:text=The%20Centre%20for%20Automation%20Technology,%2C%20and%20non-academic%20processes.';

  // Database constants
  static const String dbName = 'app.db';
  static const String userTable = 'users';

  // Session keys
  static const String pinKey = 'pin_key'; // Key for user PIN encryption
  static const String currentLoggedInUserKey = 'current_user_key'; // Key for encryption

  // OTP timeout in seconds
  static const int otpTimeOutSeconds = 60;

  static const int pageSize = 30;
}
