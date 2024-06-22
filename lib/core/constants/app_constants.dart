class AppConstants {
  // Security key for encryption and otp generation )
  static const String securityKey = "wW6BOreU82Aab4V"; // Key for encryption

  // API URLs (example, update with real URLs)
  static const String baseUrl = 'https://arogyakavach.nitrkl.ac.in/WebApi';

  // For checking Update App using Play Store URL
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.example.hellonitr&hl=en&gl=US';

  //CAT (Centre for Automation Cell) URL
  static const String catUrl = 'https://www.nitrkl.ac.in/CAT#:~:text=The%20Centre%20for%20Automation%20Technology,%2C%20and%20non-academic%20processes.';

  // Use this flag to switch between mock and real API services
  static const bool useMockService = false;

  // Database constants
  static const String dbName = 'app.db';
  static const String userTable = 'users';

  // Session keys
  static const String pinKey = 'pin_key'; // Key for user PIN use any key for encryption
  static const String currentLoggedInUserKey ='current_user_key';// Key for current user data use any key for encryption

  static const int otpTimeOutSeconds = 60; // OTP timeout in seconds

  static int imageQuality = 50; // Set image quality for compression (0-100)

  //sentry dsn
  static const String sentryDsn = 'https://003feb3606c9ee01edbc85430f6eb498@o4507474330779648.ingest.de.sentry.io/4507474332418128';

}
