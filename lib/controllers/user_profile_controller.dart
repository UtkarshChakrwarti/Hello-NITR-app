import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
import 'package:hello_nitr/core/services/api/remote/api_service.dart';
import 'package:hello_nitr/models/user.dart';
import 'package:logging/logging.dart';

class UserProfileController {
  final ApiService _apiService = ApiService();
  final Logger _logger = Logger('UserProfileController');

  Future<User?> getCurrentUser() async {
    try {
      _logger.info('Fetching current user');
      return await LocalStorageService.getCurrentUser();
    } catch (e, stackTrace) {
      _logger.severe('Error fetching current user', e, stackTrace);
      return null;
    }
  }

  Future<void> deRegisterDevice(String empCode) async {
    try {
      _logger.info('Deregistering device for empCode: $empCode');
      await _apiService.deRegisterDevice(empCode);
    } catch (e, stackTrace) {
      _logger.severe('Error deregistering device', e, stackTrace);
    }
  }
}
