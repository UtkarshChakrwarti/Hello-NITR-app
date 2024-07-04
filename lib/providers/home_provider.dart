import 'dart:async';
import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
import 'package:hello_nitr/models/user.dart';
import 'package:logging/logging.dart';

class HomeProvider {
  static final _logger = Logger('HomeProvider');

  static Future<List<User>> fetchContacts(
      int offset, int limit, String filter, bool isAscending) async {
    try {
      _logger.info('Fetching contacts with offset: $offset, limit: $limit, filter: $filter, isAscending: $isAscending');
      final users = await LocalStorageService.getUsers(offset, limit, filter, isAscending);
      _logger.info('Fetched ${users.length} contacts.');
      return users;
    } catch (error) {
      _logger.severe('Failed to fetch contacts: $error');
      rethrow;
    }
  }

  static Future<int> fetchContactCount(String filter) async {
    try {
      _logger.info('Fetching contact count for filter: $filter');
      final count = await LocalStorageService.getUserCount(filter);
      _logger.info('Fetched contact count: $count');
      return count;
    } catch (error) {
      _logger.severe('Failed to fetch contact count: $error');
      rethrow;
    }
  }

  static Future<List<User>> searchUsers(int offset, int limit, String query) async {
    try {
      _logger.info('Searching users with offset: $offset, limit: $limit, query: $query');
      final users = await LocalStorageService.searchUsers(offset, limit, query);
      _logger.info('Found ${users.length} users.');
      return users;
    } catch (error) {
      _logger.severe('Failed to search users: $error');
      rethrow;
    }
  }

  static Future<List<User>> searchUsersFiltered(int offset, int limit, String query, String filter) async {
    try {
      _logger.info('Searching users with offset: $offset, limit: $limit, query: $query, filter: $filter');
      final users = await LocalStorageService.searchUsersFiltered(offset, limit, query, filter);
      _logger.info('Found ${users.length} users.');
      return users;
    } catch (error) {
      _logger.severe('Failed to search users: $error');
      rethrow;
    }
  }

  static Future<List<User>> searchUsersByDepartment(int offset, int limit, String query, String department) async {
    try {
      _logger.info('Searching users by department with offset: $offset, limit: $limit, query: $query, department: $department');
      final users = await LocalStorageService.searchUsersByDepartment(query, department, offset, limit);
      _logger.info('Found ${users.length} users in department $department.');
      return users;
    } catch (error) {
      _logger.severe('Failed to search users by department: $error');
      rethrow;
    }
  }

  static Future<List<String>> getDepartments() async {
    try {
      _logger.info('Fetching departments');
      final departments = await LocalStorageService.getDepartments();
      _logger.info('Fetched ${departments.length} departments.');
      return departments;
    } catch (error) {
      _logger.severe('Failed to fetch departments: $error');
      rethrow;
    }
  }
}
