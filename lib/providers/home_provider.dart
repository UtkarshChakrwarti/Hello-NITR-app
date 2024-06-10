import 'package:flutter/material.dart';
import 'package:hello_nitr/controllers/home_controller.dart';
import 'package:hello_nitr/controllers/login_controller.dart';
import 'package:hello_nitr/models/user.dart';

class HomeProvider extends ChangeNotifier {
  final HomeController _homeController = HomeController();
  final LoginController _loginController = LoginController();

  bool _isLoadingContacts = false;
  bool _isLoadingMoreContacts = false;
  bool _isLoadingSearchContacts = false;
  bool _isSearchActive = false;
  bool _isFilterActive = false;
  int? _selectedContactIndex;
  bool _isMenuVisible = false;

  List<User> get contacts => _homeController.contacts;
  List<User> get searchContacts => _homeController.searchContacts;
  List<String> get departments => _homeController.departments;
  String? get selectedDepartment => _homeController.selectedDepartment;
  String? get selectedEmployeeType => _homeController.selectedEmployeeType;
  bool get isLoadingContacts => _isLoadingContacts;
  bool get isLoadingMoreContacts => _isLoadingMoreContacts;
  bool get isLoadingSearchContacts => _isLoadingSearchContacts;
  bool get ascending => _homeController.ascending;
  bool get isSearchActive => _isSearchActive;
  bool get isFilterActive => _isFilterActive;
  int? get selectedContactIndex => _selectedContactIndex;
  bool get isMenuVisible => _isMenuVisible;

  // Constructor
  HomeProvider() {
    fetchContacts();
    fetchDepartments();
  }

  Future<void> fetchContacts() async {
    _isLoadingContacts = true;
    notifyListeners();
    await _homeController.fetchContacts();
    _isLoadingContacts = false;
    _resetExpandedState();
    notifyListeners();
  }

  Future<void> fetchDepartments() async {
    await _homeController.fetchDepartments();
    notifyListeners();
  }

  Future<void> loadMoreContacts() async {
    if (_isLoadingMoreContacts || _isLoadingSearchContacts) return;
    _isLoadingMoreContacts = true;
    notifyListeners();
    await _homeController.loadMoreContacts();
    _isLoadingMoreContacts = false;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _homeController.updateSearchQuery(query);
    _isSearchActive = query.isNotEmpty;
    _isFilterActive = false;
    fetchSearchResults();
  }

  void selectDepartment(String? department) {
    _homeController.selectDepartment(department);
    _isFilterActive = department != null && department != 'Select Department';
    _isSearchActive = _homeController.selectedDepartment != 'Select Department';
    fetchContactsOrSearchResults();
  }

  void selectEmployeeType(String? employeeType) {
    _homeController.selectEmployeeType(employeeType);
    _isFilterActive = employeeType != null && employeeType.isNotEmpty;
    _isSearchActive = false;
    fetchContactsOrSearchResults();
  }

  Future<void> fetchSearchResults() async {
    _isLoadingSearchContacts = true;
    notifyListeners();
    await _homeController.fetchSearchResults();
    _isLoadingSearchContacts = false;
    _resetExpandedState();
    notifyListeners();
  }

  Future<void> fetchContactsOrSearchResults() async {
    if (_isSearchActive) {
      fetchSearchResults();
    } else {
      fetchContacts();
    }
  }

  void sortContacts() {
    _homeController.sortContacts();
    fetchContacts();
  }

  void logout(BuildContext context) {
    _loginController.logout(context);
  }

  void setSelectedContactIndex(int? index) {
    _selectedContactIndex = index;
    notifyListeners();
  }

  void toggleMenuVisibility(bool isVisible) {
    _isMenuVisible = isVisible;
    notifyListeners();
  }

  void _resetExpandedState() {
    _selectedContactIndex = null;
    _isMenuVisible = false;
  }
}
