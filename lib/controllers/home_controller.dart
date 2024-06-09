import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
import 'package:hello_nitr/models/user.dart';

class HomeController {
  static const int _limit = 10;
  List<User> _contacts = [];
  List<User> _searchContacts = [];
  List<String> _departments = ['Select Department'];
  String _searchQuery = '';
  String? _selectedDepartment = 'Select Department';
  String? _selectedEmployeeType;
  bool _ascending = true;
  int _offset = 0;
  int _searchOffset = 0;

  List<User> get contacts => _contacts;
  List<User> get searchContacts => _searchContacts;
  List<String> get departments => _departments;
  String? get selectedDepartment => _selectedDepartment;
  String? get selectedEmployeeType => _selectedEmployeeType;
  bool get ascending => _ascending;

  Future<void> fetchContacts() async {
    _offset = 0;
    try {
      _contacts = await LocalStorageService.getPaginatedContacts(
        _offset, _limit,
        ascending: _ascending,
      );
      _offset = _contacts.length;
    } catch (e) {
      print("Error fetching contacts: $e");
    }
  }

  Future<void> fetchDepartments() async {
    try {
      List<String> fetchedDepartments =
          await LocalStorageService.getUniqueDepartments();
      _departments = ['Select Department', ...fetchedDepartments];
    } catch (e) {
      print("Error fetching departments: $e");
    }
  }

  Future<void> loadMoreContacts() async {
    try {
      List<User> moreContacts = await LocalStorageService.getPaginatedContacts(
        _offset, _limit,
        ascending: _ascending,
      );
      _contacts.addAll(moreContacts);
      _offset += moreContacts.length;
    } catch (e) {
      print("Error loading more contacts: $e");
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _searchOffset = 0;
  }

  void selectDepartment(String? department) {
    if (department == null || department == 'Select Department') {
      _selectedDepartment = 'Select Department';
    } else {
      _selectedDepartment = department;
      _selectedEmployeeType = null;
    }
    _searchOffset = 0;
  }

  void selectEmployeeType(String? employeeType) {
    if (employeeType == null || employeeType.isEmpty) {
      _selectedEmployeeType = null;
    } else {
      _selectedEmployeeType = employeeType;
      _selectedDepartment = 'Select Department';
    }
    _searchOffset = 0;
  }

  Future<void> fetchSearchResults() async {
    try {
      if (_selectedDepartment != null &&
          _selectedDepartment != 'Select Department') {
        _searchContacts = await LocalStorageService.searchContactsByDepartment(
          _searchQuery, _selectedDepartment!, _searchOffset, _limit,
          ascending: _ascending,
        );
      } else {
        _searchContacts = await LocalStorageService.searchContacts(
          _searchQuery, _searchOffset, _limit,
          ascending: _ascending,
        );
      }
      _searchOffset = _searchContacts.length;
    } catch (e) {
      print("Error fetching search results: $e");
    }
  }

  Future<void> fetchFilteredResults() async {
    _offset = 0;
    try {
      if (_selectedEmployeeType != null && _selectedEmployeeType!.isNotEmpty) {
        _contacts = await LocalStorageService.getPaginatedUsersByEmployeeType(
          _selectedEmployeeType!, _offset, _limit,
          ascending: _ascending,
        );
      } else if (_selectedDepartment != null &&
          _selectedDepartment != 'Select Department') {
        _contacts = await LocalStorageService.getPaginatedUsersByDepartment(
          _selectedDepartment!, _offset, _limit,
          ascending: _ascending,
        );
      } else {
        _contacts = await LocalStorageService.getPaginatedContacts(
          _offset, _limit,
          ascending: _ascending,
        );
      }
      _offset = _contacts.length;
    } catch (e) {
      print("Error fetching filtered results: $e");
    }
  }

  void sortContacts() {
    _ascending = !_ascending;
    _offset = 0;
    _contacts.clear();
  }
}
