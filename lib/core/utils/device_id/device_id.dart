import 'package:flutter_udid/flutter_udid.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class DeviceUtil {
  String _deviceID = 'Loading...';

  Future<String> getDeviceID() async {
    try {
      _deviceID = await FlutterUdid.udid;
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      return "Error getting device ID: $e";
      
    }
     return _deviceID;
  }
}
