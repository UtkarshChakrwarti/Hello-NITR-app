import 'dart:convert';
import 'package:image/image.dart' as img;

/// A utility class for image compression and analysis.
class ImageCompressor {
  /// Compresses a base64 encoded image.
  ///
  /// [base64Image] is the base64 encoded string of the original image.
  /// [quality] is the quality of the compression (1-100), with 100 being the highest quality.
  ///
  /// Returns a map containing the compressed base64 image, original size, compressed size,
  /// compression ratio, and size difference.
  ///
  /// Returns an empty map if an error occurs, such as an invalid base64 string.
  static Map<String, dynamic> compressBase64Image(
      String base64Image, int quality) {
    try {
      // Decode the base64 image to get the original image bytes
      final originalImageBytes = base64Decode(base64Image);

      // Decode the image bytes to get the original image
      final originalImage = img.decodeImage(originalImageBytes);

      // If image decoding fails, return an empty map
      if (originalImage == null) {
        return {
          'compressedBase64Image': '',
          'originalSize': 0,
          'compressedSize': 0,
          'compressionRatio': 0,
          'sizeDifference': 0,
        };
      }

      // Compress the image
      final compressedImageBytes =
          img.encodeJpg(originalImage, quality: quality);

      // Encode the compressed image bytes back to base64
      final compressedBase64Image = base64Encode(compressedImageBytes);

      // Calculate compression metrics
      final originalSize = originalImageBytes.length;
      final compressedSize = compressedImageBytes.length;
      final compressionRatio = (compressedSize / originalSize) * 100;

      return {
        'compressedBase64Image': compressedBase64Image,
        'originalSize': originalSize,
        'compressedSize': compressedSize,
        'compressionRatio': compressionRatio,
        'sizeDifference': originalSize - compressedSize,
      };
    } catch (e) {
      // Return an empty map if any error occurs
      return {
        'compressedBase64Image': '',
        'originalSize': 0,
        'compressedSize': 0,
        'compressionRatio': 0,
        'sizeDifference': 0,
      };
    }
  }

  /// A helper method to log compression details in a human-readable format.
  static void logCompressionDetails(Map<String, dynamic> compressionResult) {
    if (compressionResult.isEmpty) {
      return;
    }
  }
}
