import 'dart:async';

import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
import 'package:hello_nitr/core/services/api/remote/api_service.dart';
import 'package:hello_nitr/models/user.dart';
import 'package:logging/logging.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ContactsUpdateController {
  final Logger _logger = Logger('ContactsUpdateController');
  final StreamController<double> _progressController = StreamController<double>.broadcast();
  final StreamController<String> _statusController = StreamController<String>.broadcast();
  final _apiService = ApiService();
  int totalContacts = 0;

  Stream<double> get progressStream => _progressController.stream;
  Stream<String> get statusStream => _statusController.stream;

  ContactsUpdateController() {
    _logger.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
      Sentry.captureMessage('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  void startUpdatingContacts() async {
    try {
      _statusController.add('Updating Contacts List...');
      _logger.info('Started updating contacts');

      // Step 1: Fetch contacts from the server
      List<User> serverUsers = await fetchContactsFromServer();

      // Step 2: Get the total number of contacts
      totalContacts = serverUsers.length;

      // Step 3: Update the contacts in the local database with progress updates
      for (int i = 0; i < totalContacts; i++) {
        await LocalStorageService.saveUser(serverUsers[i]);
        _logger.info('Updated contact: ${serverUsers[i].firstName} ${serverUsers[i].lastName}');
        _progressController.add((i + 1) / totalContacts);
      }

      _logger.info('Contacts updated successfully');
      _statusController.add('Contacts updated successfully');
    } catch (e, stackTrace) {
      _logger.severe('Error updating contacts: $e');
      _statusController.addError('An error occurred while updating contacts. Please try again.');
      Sentry.captureException(e, stackTrace: stackTrace);
    } finally {
      await _progressController.close();
      await _statusController.close();
    }
  }

  Future<List<User>> fetchContactsFromServer() async {
    try {
      _logger.info('Fetching contacts from server');
      return await _apiService.fetchContacts();
    } catch (e, stackTrace) {
      _logger.severe('Error fetching contacts: $e');
      Sentry.captureException(e, stackTrace: stackTrace);
      throw e;
    }
  }

  void dispose() {
    _progressController.close();
    _statusController.close();
  }
}
