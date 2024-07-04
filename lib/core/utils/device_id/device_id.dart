import 'package:flutter_udid/flutter_udid.dart';

class DeviceUtil {
  String _deviceID = 'Loading...';

  Future<String> getDeviceID() async {
    try {
      _deviceID = await FlutterUdid.udid;
    } catch (e) {
      return "Error getting device ID: $e";
      
    }
     return _deviceID;
  }
}
