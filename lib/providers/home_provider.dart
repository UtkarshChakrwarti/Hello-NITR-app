import 'dart:async';

import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
import 'package:hello_nitr/models/user.dart';


class HomeProvider {
  static Future<List<User>> fetchContacts(int offset, int limit, String filter, bool isAscending) async {
    try {
      // Fetch contacts from the API based on the filter and sorting order
      final users = await LocalStorageService.getUsers(offset, limit, filter, isAscending);
      return users;
    } catch (error) {
      throw error;
    }
  }
}
