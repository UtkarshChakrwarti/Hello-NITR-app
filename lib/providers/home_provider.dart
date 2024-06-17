import 'package:flutter/material.dart';
import 'package:hello_nitr/controllers/login_controller.dart';
import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
import 'package:hello_nitr/models/user.dart';

class HomeProvider extends ChangeNotifier {
  final LoginController _loginController = LoginController();
  List<User> _contacts = [];
  List<User> _filteredContacts = [];
  List<User> _searchContacts = [];
  List<User> _recentContacts = [];
  List<String> _departments = ['Select Department'];
  String searchQuery = '';
  String? _selectedDepartment = 'Select Department';
  String? _selectedEmployeeType;
  bool _isLoadingContacts = false;
  bool _isLoadingMoreContacts = false;
  bool _isLoadingSearchContacts = false;
  bool _ascending = true;
  bool _isSearchActive = false;
  bool _isFilterActive = false;
  int _offset = 0;
  int _searchOffset = 0;
  static const int _limit = 10;
  double _scrollPosition = 0.0;
  int? _expandedContactIndex;

  List<User> get contacts => _contacts;
  List<User> get filteredContacts => _filteredContacts;
  List<User> get searchContacts => _searchContacts;
  List<User> get recentContacts => _recentContacts;
  List<String> get departments => _departments;
  String? get selectedDepartment => _selectedDepartment;
  String? get selectedEmployeeType => _selectedEmployeeType;
  bool get isLoadingContacts => _isLoadingContacts;
  bool get isLoadingMoreContacts => _isLoadingMoreContacts;
  bool get isLoadingSearchContacts => _isLoadingSearchContacts;
  bool get ascending => _ascending;
  bool get isSearchActive => _isSearchActive;
  bool get isFilterActive => _isFilterActive;

  double get scrollPosition => _scrollPosition;
  int? get expandedContactIndex => _expandedContactIndex;

  HomeProvider() {
    fetchContacts();
    fetchDepartments();
    loadRecentContacts();
  }

  Future<void> fetchContacts() async {
    _isLoadingContacts = true;
    _offset = 0;
    notifyListeners();
    try {
      _contacts = await LocalStorageService.getPaginatedContacts(_offset, _limit, ascending: _ascending);
      _filteredContacts = List.from(_contacts);
      _offset = _contacts.length;
    } catch (e) {
      print("Error fetching contacts: $e");
    } finally {
      _isLoadingContacts = false;
      notifyListeners();
    }
  }

  Future<void> fetchDepartments() async {
    try {
      List<String> fetchedDepartments = await LocalStorageService.getUniqueDepartments();
      _departments = ['Select Department', ...fetchedDepartments];
      notifyListeners();
    } catch (e) {
      print("Error fetching departments: $e");
    }
  }

  Future<void> loadMoreContacts() async {
    if (_isLoadingMoreContacts || _isLoadingSearchContacts) return;
    _isLoadingMoreContacts = true;
    notifyListeners();
    try {
      List<User> moreContacts = await LocalStorageService.getPaginatedContacts(_offset, _limit, ascending: _ascending);
      _contacts.addAll(moreContacts);
      _filteredContacts.addAll(moreContacts);
      _offset += moreContacts.length;
    } catch (e) {
      print("Error loading more contacts: $e");
    } finally {
      _isLoadingMoreContacts = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreSearchContacts() async {
    if (_isLoadingMoreContacts || _isLoadingSearchContacts) return;
    _isLoadingSearchContacts = true;
    notifyListeners();
    try {
      List<User> moreSearchContacts = await LocalStorageService.searchContacts(
          searchQuery, _searchOffset, _limit, _selectedEmployeeType, ascending: _ascending);
      _searchContacts.addAll(moreSearchContacts);
      _searchOffset += moreSearchContacts.length;
    } catch (e) {
      print("Error loading more search contacts: $e");
    } finally {
      _isLoadingSearchContacts = false;
      notifyListeners();
    }
  }

  void updateSearchQuery(String query, {bool filterCurrentList = false}) {
    searchQuery = query;
    _searchOffset = 0;
    _isSearchActive = query.isNotEmpty;
    _isFilterActive = false;
    fetchSearchResults(filterCurrentList: filterCurrentList);
  }

  void selectDepartment(String? department) {
    if (department == null || department == 'Select Department') {
      _selectedDepartment = 'Select Department';
      _isFilterActive = false;
    } else {
      _selectedDepartment = department;
      _isFilterActive = true;
      _selectedEmployeeType = null;
    }
    _searchOffset = 0;
    _isSearchActive = searchQuery.isNotEmpty;
    if (_isSearchActive) {
      fetchSearchResults();
    } else {
      updateSearchResultsForDepartment(department!);
    }
  }

  void selectEmployeeType(String? employeeType) {
    if (employeeType == null || employeeType.isEmpty) {
      _selectedEmployeeType = null;
      _isFilterActive = false;
    } else {
      _selectedEmployeeType = employeeType;
      _isFilterActive = true;
      _selectedDepartment = 'Select Department';
    }
    _searchOffset = 0;
    _isSearchActive = false;
    fetchFilteredResults();
  }

  Future<void> fetchSearchResults({bool filterCurrentList = false}) async {
    _isLoadingSearchContacts = true;
    notifyListeners();
    try {
      if (searchQuery.isNotEmpty) {
        if (filterCurrentList && _filteredContacts.isNotEmpty) {
          _searchContacts = await LocalStorageService.searchContacts(
              searchQuery, _searchOffset, _limit, _selectedEmployeeType, ascending: _ascending);
        } else if (_selectedDepartment != null && _selectedDepartment != 'Select Department') {
          _searchContacts = await LocalStorageService.searchContactsByDepartment(
              searchQuery, _selectedDepartment!, _searchOffset, _limit, ascending: _ascending);
        } else {
          _searchContacts = await LocalStorageService.searchContacts(
              searchQuery, _searchOffset, _limit, _selectedEmployeeType, ascending: _ascending);
        }
        _searchOffset = _searchContacts.length;
      } else {
        if (_selectedDepartment != null && _selectedDepartment != 'Select Department') {
          _searchContacts = await LocalStorageService.getPaginatedUsersByDepartment(
              _selectedDepartment!, _searchOffset, _limit, ascending: _ascending);
        } else {
          _searchContacts.clear();
        }
      }
    } catch (e) {
      print("Error fetching search results: $e");
    } finally {
      _isLoadingSearchContacts = false;
      notifyListeners();
    }
  }

  Future<void> fetchFilteredResults() async {
    _isLoadingContacts = true;
    _offset = 0;
    notifyListeners();
    try {
      if (_selectedEmployeeType != null && _selectedEmployeeType!.isNotEmpty) {
        _contacts = await LocalStorageService.getPaginatedUsersByEmployeeType(_selectedEmployeeType!, _offset, _limit, ascending: _ascending);
      } else if (_selectedDepartment != null && _selectedDepartment != 'Select Department') {
        _contacts = await LocalStorageService.getPaginatedUsersByDepartment(_selectedDepartment!, _offset, _limit, ascending: _ascending);
      } else {
        _contacts = await LocalStorageService.getPaginatedContacts(_offset, _limit, ascending: _ascending);
      }
      _filteredContacts = List.from(_contacts);
      _offset = _contacts.length;
    } catch (e) {
      print("Error fetching filtered results: $e");
    } finally {
      _isLoadingContacts = false;
      notifyListeners();
    }
  }

  void sortContacts() {
    _ascending = !_ascending;
    _offset = 0;
    _contacts.clear();
    _filteredContacts.clear();
    fetchFilteredResults();
  }

  void addRecentContact(User contact) async {
    if (_recentContacts.any((c) => c.empCode == contact.empCode)) {
      _recentContacts.removeWhere((c) => c.empCode == contact.empCode);
    }
    if (_recentContacts.length == 10) {
      _recentContacts.removeAt(0);
    }
    _recentContacts.insert(0, contact);
    await LocalStorageService.saveRecentContacts(_recentContacts);
    notifyListeners();
  }

  Future<void> loadRecentContacts() async {
    try {
      _recentContacts = await LocalStorageService.loadRecentContacts();
      notifyListeners();
    } catch (e) {
      print("Error loading recent contacts: $e");
    }
  }

  void logout(BuildContext context) {
    _loginController.logout(context);
  }

  void setScrollPosition(double position) {
    _scrollPosition = position;
  }

  void setExpandedContactIndex(int index) {
    _expandedContactIndex = index;
  }

  void resetExpandedContactIndex() {
    _expandedContactIndex = null;
  }

  Future<void> updateSearchResultsForDepartment(String department) async {
    _isLoadingSearchContacts = true;
    notifyListeners();
    try {
      if (department != 'Select Department') {
        _searchContacts = await LocalStorageService.getPaginatedUsersByDepartment(department, _searchOffset, _limit, ascending: _ascending);
      } else {
        _searchContacts = List.from(_recentContacts);
      }
      notifyListeners();
    } catch (e) {
      print("Error updating search results for department: $e");
    } finally {
      _isLoadingSearchContacts = false;
      notifyListeners();
    }
  }
}
