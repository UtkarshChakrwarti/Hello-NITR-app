import 'dart:convert';
import 'package:hello_nitr/models/login.dart';
import 'package:http/http.dart' as http;
import 'package:hello_nitr/models/user.dart';
import 'package:hello_nitr/core/constants/app_constants.dart';
import 'package:logging/logging.dart';

// Uncomment the following line after uploading the app to the Play Store
// import 'package:package_info_plus/package_info_plus.dart';

class ApiService {
  final String baseUrl = AppConstants.baseUrl;
  final http.Client client = http.Client();
  final Logger _logger = Logger('ApiService');

  Future<LoginResponse> login(String userId, String password) async {
    final Uri url = Uri.parse('$baseUrl/login?userid=$userId&password=$password');
    return await _postRequest(url);
  }

  Future<List<User>> fetchContacts() async {
    final Uri url = Uri.parse('$baseUrl/getallemployee');
    var headers = {'Content-Type': 'application/json'};
    final response = await _sendRequest('POST', url, headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(await response.stream.bytesToString());
      return jsonData.map((item) => User.fromJson(item)).toList();
    } else {
      _logger.severe('Failed to load contacts: ${response.reasonPhrase}');
      throw Exception('Failed to load contacts');
    }
  }

  Future<bool> checkForUpdate() async {

    return true; // Remove this line and uncomment after uploading the app to the Play Store

    // try {
    //   PackageInfo packageInfo = await PackageInfo.fromPlatform();
    //   String currentVersion = packageInfo.version;
    //   final response = await http.get(Uri.parse(AppConstants.playStoreUrl));

    //   if (response.statusCode == 200) {
    //     String pageContent = response.body;
    //     RegExp versionExp = RegExp(r'Current Version.+?>([\d.]+)<');
    //     String? playStoreVersion = versionExp.firstMatch(pageContent)?.group(1);

    //     if (playStoreVersion != null) {
    //       return _compareVersions(currentVersion, playStoreVersion);
    //     }
    //   }
    // } catch (e) {
    //   _logger.severe('Error checking for update: $e');
    // }
    // return false;
  }

  Future<http.StreamedResponse> _sendRequest(String method, Uri url, {Map<String, String>? headers, dynamic body}) async {
    var request = http.Request(method, url);
    if (headers != null) request.headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);

    return await client.send(request);
  }

  Future<LoginResponse> _postRequest(Uri url, {Map<String, String>? headers, dynamic body}) async {
    final response = await _sendRequest('POST', url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(await response.stream.bytesToString()));
    } else {
      _logger.severe('Failed to login: ${response.reasonPhrase}');
      throw Exception('Failed to login');
    }
  }

  bool _compareVersions(String currentVersion, String playStoreVersion) {
    List<String> currentVersionParts = currentVersion.split('.');
    List<String> playStoreVersionParts = playStoreVersion.split('.');

    for (int i = 0; i < currentVersionParts.length; i++) {
      int current = int.parse(currentVersionParts[i]);
      int playStore = int.parse(playStoreVersionParts[i]);

      if (playStore > current) {
        return true;
      } else if (playStore < current) {
        return false;
      }
    }
    return false;
  }

  Future<bool?> updateDeviceId(String? empCode, String udid) async {
      // Implement the updateDeviceIMEI API here
        final Uri url = Uri.parse('$baseUrl/updatelogin?userid=$empCode&deviceid=$udid');
        final response = await _sendRequest('POST', url);
  
        if (response.statusCode == 200) {
          _logger.info(await response.stream.bytesToString());
          return true;
        } else {
          _logger.severe(response.reasonPhrase);
          return false;
        }
    }
}
