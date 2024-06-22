import 'dart:async';
import 'dart:convert';
import 'package:hello_nitr/models/login.dart';
import 'package:http/http.dart' as http;
import 'package:hello_nitr/models/user.dart';
import 'package:hello_nitr/core/constants/app_constants.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ApiService {
  final String baseUrl = AppConstants.baseUrl;
  final http.Client client = http.Client();
  final Logger _logger = Logger('ApiService');

  Future<LoginResponse> login(String userId, String password) async {
    final Uri url =
        Uri.parse('$baseUrl/login?userid=$userId&password=$password');
    return await _postRequest(url);
  }

  // Validate the user's that they are still valid or not api will return true if user is valid else false
  Future<bool> validateUser(String? empCode) async {
    final Uri url = Uri.parse('$baseUrl/MyStatus?userid=$empCode');
    final response = await _sendRequest('POST', url);

    if (response.statusCode == 200) {
      return jsonDecode(await response.stream.bytesToString());
    } else {
      _logger.severe('Failed to validate user: ${response.reasonPhrase}');
      Sentry.captureException(Exception('Failed to validate user'));
      throw Exception('Failed to validate user');
    }
  }

  Future<List<User>> fetchContacts() async {
    final Uri url = Uri.parse('$baseUrl/getallemployee');
    var headers = {'Content-Type': 'application/json'};
    final response = await _sendRequest('POST', url, headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> jsonData =
          jsonDecode(await response.stream.bytesToString());
      return jsonData.map((item) => User.fromJson(item)).toList();
    } else {
      _logger.severe('Failed to load contacts: ${response.reasonPhrase}');
      Sentry.captureException(Exception('Failed to load contacts'));
      throw Exception('Failed to load contacts');
    }
  }

  Future<bool?> updateDeviceId(String? empCode, String udid) async {
    // Implement the updateDeviceIMEI API here
    final Uri url =
        Uri.parse('$baseUrl/updatelogin?userid=$empCode&deviceid=$udid');
    final response = await _sendRequest('POST', url);

    if (response.statusCode == 200) {
      _logger.info(await response.stream.bytesToString());
      return true;
    } else {
      _logger.severe(response.reasonPhrase);
      Sentry.captureException(Exception('Failed to update device ID'));
      return false;
    }
  }

  // De-Register the device from the server
  Future<void> deRegisterDevice(String empCode) async {
    final Uri url = Uri.parse('$baseUrl/resetlogin?userid=$empCode');
    final response = await _sendRequest('POST', url);

    if (response.statusCode == 200) {
      _logger.info(await response.stream.bytesToString());
    } else {
      _logger.severe('Failed to deregister device: ${response.reasonPhrase}');
      Sentry.captureException(Exception('Failed to deregister device'));
    }
  }

  Future<bool> checkForUpdate() async {
    try {
      // Get the current app version from the platform package info
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentAppVersion = packageInfo.version;

      // Make an HTTP GET request to the Play Store URL
      final Uri playStoreUri = Uri.parse(AppConstants.playStoreUrl);
      final response = await http.get(playStoreUri);

      // If the response status code is 200 (OK), parse the response body
      if (response.statusCode == 200) {
        String responseBody = response.body;

        // Use a regular expression to find the current version on the Play Store page
        RegExp versionRegExp = RegExp(r'Current Version.+?>([\d.]+)<');
        String? playStoreVersion =
            versionRegExp.firstMatch(responseBody)?.group(1);

        // If the Play Store version is found, compare it with the current app version
        if (playStoreVersion != null) {
          return _isUpdateAvailable(currentAppVersion, playStoreVersion);
        }
      }
    } catch (error) {
      // Log any errors that occur during the update check
      _logger.severe('Error checking for update');
    }
    // Return false if an update is not available or an error occurred
    _logger.info('No update available or connection issues');
    return false;
  }

  bool _isUpdateAvailable(String currentVersion, String playStoreVersion) {
    // Split the version strings into parts for comparison
    List<String> currentVersionParts = currentVersion.split('.');
    List<String> playStoreVersionParts = playStoreVersion.split('.');

    // Compare each part of the version strings
    for (int i = 0; i < currentVersionParts.length; i++) {
      int currentVersionPart = int.parse(currentVersionParts[i]);
      int playStoreVersionPart = int.parse(playStoreVersionParts[i]);

      // If the Play Store version part is greater, an update is available
      if (playStoreVersionPart > currentVersionPart) {
        return true;
        // If the current version part is greater, no update is available
      } else if (playStoreVersionPart < currentVersionPart) {
        return false;
      }
    }
    // If all parts are equal, no update is available
    return false;
  }

  Future<http.StreamedResponse> _sendRequest(String method, Uri url,
      {Map<String, String>? headers, dynamic body}) async {
    var request = http.Request(method, url);
    if (headers != null) request.headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);

    try {
      return await client.send(request);
    } on TimeoutException catch (_) {
      _logger.severe('Request to $url timed out.');
      Sentry.captureException(Exception('Request timed out'));
      throw Exception('Request timed out');
    }
  }

  Future<LoginResponse> _postRequest(Uri url,
      {Map<String, String>? headers, dynamic body}) async {
    final response =
        await _sendRequest('POST', url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(
          jsonDecode(await response.stream.bytesToString()));
    } else {
      _logger.severe('Failed to login: ${response.reasonPhrase}');
      Sentry.captureException(Exception('Failed to login'));
      throw Exception('Failed to login');
    }
  }

  // Send OTP to the user's mobile number
  Future<void> sendOtp(String mobileNumber, String otp) async {
    final Uri url = Uri.parse('$baseUrl/otp?otp=$otp&mobileno=$mobileNumber');
    final response = await _sendRequest('POST', url);

    if (response.statusCode == 200) {
      _logger.info(await response.stream.bytesToString());
    } else {
      Sentry.captureException(Exception('Failed to send OTP'));
      _logger.severe('Failed to send OTP: ${response.reasonPhrase}');
    }
  }
}
