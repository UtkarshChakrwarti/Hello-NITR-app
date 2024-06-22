import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:logging/logging.dart';

final Logger _logger = Logger('ImageCompressor');

class ImageCompressor {
  // Compresses a base64 encoded image and returns compression details.
  static Map<String, dynamic> compressBase64Image(String base64Image, int quality) {
    try {
      final originalImageBytes = base64Decode(base64Image);
      final originalImage = img.decodeImage(originalImageBytes);

      if (originalImage == null) {
        return _emptyCompressionResult();
      }

      final compressedImageBytes = img.encodeJpg(originalImage, quality: quality);
      final compressedBase64Image = base64Encode(compressedImageBytes);

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
    } catch (e, stackTrace) {
      _logger.severe('Error compressing image: $e', e, stackTrace);
      return _emptyCompressionResult();
    }
  }

  // Logs compression details in a human-readable format.
  static void logCompressionDetails(Map<String, dynamic> compressionResult) {
    if (compressionResult.isEmpty) {
      _logger.warning('No compression details available.');
      return;
    }

    _logger.info('Compression Details:');
    _logger.info('---------------------');
    _logger.info('Original Size: ${compressionResult['originalSize']} bytes');
    _logger.info('Compressed Size: ${compressionResult['compressedSize']} bytes');
    _logger.info('Compression Ratio: ${compressionResult['compressionRatio'].toStringAsFixed(2)}%');
    _logger.info('Size Difference: ${compressionResult['sizeDifference']} bytes');
    _logger.info('---------------------');
  }

  // Returns an empty map for compression results.
  static Map<String, dynamic> _emptyCompressionResult() {
    return {
      'compressedBase64Image': '',
      'originalSize': 0,
      'compressedSize': 0,
      'compressionRatio': 0,
      'sizeDifference': 0,
    };
  }
}
