import 'dart:async';

import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
import 'package:hello_nitr/models/user.dart';
import 'package:logging/logging.dart';

class HomeProvider {
  static final _logger = Logger('HomeProvider');
  static Future<List<User>> fetchContacts(
      int offset, int limit, String filter, bool isAscending) async {
    try {
      // Fetch contacts from the API based on the filter and sorting order
      final users = await LocalStorageService.getUsers(
          offset, limit, filter, isAscending);
      return users;
    } catch (error) {
      throw error;
    }
  }

  static Future<int> fetchContactCount(String filter) async {
    try {
      // Fetch the contact count from the API based on the filter
      final count = await LocalStorageService.getUserCount(filter);
      return count;
    } catch (error) {
      throw error;
    }
  }

  static Future<List<User>> searchUsers(
      int offset, int limit, String query) async {
    try {
      // Search contacts from the API based on the query
      final users = await LocalStorageService.searchUsers(offset, limit, query);
      return users;
    } catch (error) {
      throw error;
    }
  }
 static Future<List<User>> searchUsersByDepartment(
      int offset, int limit, String query, String department) async {
    try {
      final users = await LocalStorageService.searchUsersByDepartment(
           query, department,offset, limit);
      return users;
    } catch (error) {
      _logger.severe('Failed to search users by department: $error');
      throw error;
    }
  }

  static Future<List<String>> getDepartments() async {
    try {
      final departments = await LocalStorageService.getDepartments();
      return departments;
    } catch (error) {
      _logger.severe('Failed to fetch departments: $error');
      throw error;
    }
  }
}