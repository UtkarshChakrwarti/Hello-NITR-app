import 'package:flutter/material.dart';
import 'package:hello_nitr/controllers/login_controller.dart';
import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
import 'package:hello_nitr/models/user.dart';

class HomeProvider extends ChangeNotifier {
  final LoginController _loginController = LoginController();
  List<User> _contacts = [];
  List<User> _searchContacts = [];
  List<User> _suggestedContacts = [];
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
  List<User> get searchContacts => _searchContacts;
  List<User> get suggestedContacts => _suggestedContacts;
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
    loadSuggestedContacts();
  }

  Future<void> fetchContacts() async {
    _isLoadingContacts = true;
    _offset = 0;
    notifyListeners();
    try {
      _contacts = await LocalStorageService.getPaginatedContacts(_offset, _limit, ascending: _ascending);
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
          searchQuery, _searchOffset, _limit, ascending: _ascending);
      _searchContacts.addAll(moreSearchContacts);
      _searchOffset += moreSearchContacts.length;
    } catch (e) {
      print("Error loading more search contacts: $e");
    } finally {
      _isLoadingSearchContacts = false;
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) {
    searchQuery = query;
    _searchOffset = 0;
    _isSearchActive = query.isNotEmpty;
    _isFilterActive = false;
    fetchSearchResults();
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
      fetchFilteredResults();
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

  Future<void> fetchSearchResults() async {
    _isLoadingSearchContacts = true;
    notifyListeners();
    try {
      if (searchQuery.isNotEmpty) {
        if (_selectedDepartment != null && _selectedDepartment != 'Select Department') {
          _searchContacts = await LocalStorageService.searchContactsByDepartment(
              searchQuery, _selectedDepartment!, _searchOffset, _limit, ascending: _ascending);
        } else {
          _searchContacts = await LocalStorageService.searchContacts(
              searchQuery, _searchOffset, _limit, ascending: _ascending);
        }
        _searchOffset = _searchContacts.length;
      } else {
        _searchContacts.clear();
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
    fetchContacts();
  }

  void addRecentContact(User contact) async {
    if (_suggestedContacts.any((c) => c.empCode == contact.empCode)) {
      _suggestedContacts.removeWhere((c) => c.empCode == contact.empCode);
    }
    if (_suggestedContacts.length == 10) {
      _suggestedContacts.removeAt(0);
    }
    _suggestedContacts.insert(0, contact);
    await LocalStorageService.saveSuggestedContacts(_suggestedContacts);
    notifyListeners();
  }

  Future<void> loadSuggestedContacts() async {
    try {
      _suggestedContacts = await LocalStorageService.loadSuggestedContacts();
      notifyListeners();
    } catch (e) {
      print("Error loading suggested contacts: $e");
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
}
