import 'dart:async';

import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
import 'package:hello_nitr/models/user.dart';

class HomeProvider {
  static Future<List<User>> fetchContacts(int offset, int limit) async {
    try {
      // Fetch contacts from the API
      final users = await LocalStorageService.getUsers(offset, limit);
      return users;
    } catch (error) {
      throw error;
    }
  }
}
