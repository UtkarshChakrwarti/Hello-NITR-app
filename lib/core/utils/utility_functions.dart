import 'dart:convert';
import 'dart:typed_data';

class UtilityFunctions {
  final base64Pattern = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');

  bool isValidBase64Image(String base64String) {
    try {
      if (!base64Pattern.hasMatch(base64String)) {
        return false;
      }

      Uint8List bytes = base64Decode(base64String);
      // Check for common image signatures (JPEG, PNG, GIF)
      return bytes.length >= 4 &&
          ((bytes[0] == 0xFF && bytes[1] == 0xD8) || // JPEG
              (bytes[0] == 0x89 &&
                  bytes[1] == 0x50 &&
                  bytes[2] == 0x4E &&
                  bytes[3] == 0x47) || // PNG
              (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) // GIF
          );
    } catch (e) {
      return false;
    }
  }
}
