import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/core/utils/link_launcher.dart';
import 'package:hello_nitr/core/utils/utility_functions.dart';
import 'package:hello_nitr/models/user.dart';
import 'package:hello_nitr/providers/home_provider.dart';
import 'package:hello_nitr/screens/contacts/profile/contact_profile_screen.dart';
import 'package:hello_nitr/screens/home/widgets/avatar.dart';
import 'package:hello_nitr/screens/home/widgets/contact_list.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:logging/logging.dart';

class DepartmentSearchScreen extends StatefulWidget {
  @override
  _DepartmentSearchScreenState createState() => _DepartmentSearchScreenState();
}

class _DepartmentSearchScreenState extends State<DepartmentSearchScreen>
    with TickerProviderStateMixin {
  static const _pageSize = 10;
  final UtilityFunctions _utilityFunctions = UtilityFunctions();
  final PagingController<int, User> _pagingController =
      PagingController(firstPageKey: 0);
  final Duration animationDuration = Duration(milliseconds: 300);
  final Logger _logger = Logger('DepartmentSearchScreen');

  int? _expandedIndex;
  String _searchQuery = '';
  String _selectedDepartment = '';
  final Map<String, Widget> _profileImagesCache = {};
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  List<String> _departments = [];

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(_fetchPage);
    _setupLogging();
    _fetchDepartments();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
  }

  void _setupLogging() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      List<User> newItems;
      if (_selectedDepartment.isEmpty) {
        newItems =
            await HomeProvider.searchUsers(pageKey, _pageSize, _searchQuery);
      } else {
        newItems = await HomeProvider.searchUsersByDepartment(
            pageKey, _pageSize, _searchQuery, _selectedDepartment);
      }
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
      _cacheProfileImages(newItems);
    } catch (error) {
      _logger.severe('Failed to fetch page: $error');
      _pagingController.error = error;
    }
  }

  Future<void> _fetchDepartments() async {
    try {
      final departments = await HomeProvider.getDepartments();
      setState(() {
        _departments = departments;
      });
    } catch (error) {
      _logger.severe('Failed to fetch departments: $error');
    }
  }

  void _cacheProfileImages(List<User> users) {
    for (User user in users) {
      if (user.empCode != null &&
          !_profileImagesCache.containsKey(user.empCode)) {
        _profileImagesCache[user.empCode!] = Avatar(
            photoUrl: user.photo,
            firstName: user.firstName,
            utilityFunctions: _utilityFunctions);
        _logger.info('Image cached for user ${user.empCode}');
      }
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleContactTap(int index) {
    setState(() {
      _expandedIndex = (_expandedIndex == index) ? null : index;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _pagingController.refresh();
    });
  }

  void _onDepartmentChanged(String? department) {
    setState(() {
      _selectedDepartment = department ?? '';
      _pagingController.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          focusNode: _searchFocusNode,
          controller: _searchController,
          decoration: InputDecoration(
            //remove default underline
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: 'Search Contacts by Department',
            hintStyle: TextStyle(
                fontSize: 18,
                color: Colors.grey[500],
                fontWeight: FontWeight.normal),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear,
                        size: 30, color: AppColors.primaryColor),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _pagingController.refresh();
                        _searchController.clear();
                        FocusScope.of(context).requestFocus(_searchFocusNode);
                      });
                    },
                  )
                : null,
          ),
          style: const TextStyle(fontSize: 20.0),
          onChanged: _onSearchChanged,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedDepartment.isEmpty ? null : _selectedDepartment,
              hint: const Text("Select Department"),
              isExpanded: true,
              items: _departments.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: _onDepartmentChanged,
              dropdownColor: Colors.white,
              style:
                  const TextStyle(color: AppColors.primaryColor, fontSize: 16),
              underline: Container(
                height: 2,
                color: AppColors.primaryColor,
              ),
              icon: const Icon(Icons.arrow_drop_down,
                  color: AppColors.primaryColor),
            ),
          ),
          Expanded(
            child: PagedListView<int, User>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<User>(
                itemBuilder: (context, item, index) {
                  return ContactListItem(
                    contact: item,
                    isExpanded: _expandedIndex == index,
                    onTap: () => _handleContactTap(index),
                    onDismissed: () {},
                    onCall: () {
                      LinkLauncher.makeCall(item.mobile ?? '');
                    },
                    onViewProfile: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContactProfileScreen(item),
                        ),
                      );
                    },
                    avatar: _profileImagesCache[item.empCode] ??
                        Avatar(
                            photoUrl: item.photo,
                            firstName: item.firstName,
                            utilityFunctions: _utilityFunctions),
                  );
                },
                noItemsFoundIndicatorBuilder: (context) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off,
                          size: 64, color: AppColors.primaryColor),
                      const SizedBox(height: 8),
                      const Text('No results found'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
