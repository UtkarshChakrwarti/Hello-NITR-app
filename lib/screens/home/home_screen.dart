import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/core/utils/utility_functions.dart';
import 'package:hello_nitr/models/user.dart';
import 'package:hello_nitr/providers/home_provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:logging/logging.dart';
import 'search_screen.dart';
import 'department_search_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  static const _pageSize = 10;
  final UtilityFunctions _utilityFunctions = UtilityFunctions();
  final PagingController<int, User> _pagingController =
      PagingController(firstPageKey: 0);
  final Duration animationDuration = Duration(milliseconds: 300);
  final Logger _logger = Logger('HomeScreen');

  static const Color _iconColor = AppColors.primaryColor;
  static const Color _selectedBackgroundColor = Color(0xFFFDEEE8);

  int? _expandedIndex;
  String _currentFilter = 'All Employee';
  bool _isAscending = true;
  int _contactCount = 0;
  final Map<String, Widget> _profileImagesCache = {};

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(_fetchPage);
    _setupLogging();
    _fetchContactCount();
  }

  void _setupLogging() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await HomeProvider.fetchContacts(
          pageKey, _pageSize, _currentFilter, _isAscending);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
      _cacheProfileImages(newItems);
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<void> _fetchContactCount() async {
    try {
      final count = await HomeProvider.fetchContactCount(_currentFilter);
      setState(() {
        _contactCount = count;
      });
    } catch (error) {
      _logger.severe('Failed to fetch contact count: $error');
    }
  }

  void _cacheProfileImages(List<User> users) {
    for (User user in users) {
      if (user.empCode != null &&
          !_profileImagesCache.containsKey(user.empCode)) {
        _profileImagesCache[user.empCode!] =
            _buildAvatar(user.photo, user.firstName);
        _logger.info('Image cached for user ${user.empCode}');
      }
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  void _handleContactTap(int index) {
    setState(() {
      _expandedIndex = (_expandedIndex == index) ? null : index;
    });
  }

  Widget _buildExpandedMenu(User contact) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: _selectedBackgroundColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          Divider(thickness: 1, color: _iconColor.withOpacity(0.5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIconButton(CupertinoIcons.phone_solid, () {
                // Handle call action
              }),
              _buildIconButton(FontAwesomeIcons.whatsapp, () {
                // Handle WhatsApp action
              }),
              _buildIconButton(Icons.chat, () {
                // Handle message action
              }),
              _buildIconButton(Icons.mail, () {
                // Handle mail action
              }),
              _buildIconButton(CupertinoIcons.person_crop_circle_fill, () {
                // Handle info action
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: _iconColor, size: 30.0),
      onPressed: onPressed,
    );
  }

  Widget _buildAvatar(String? photoUrl, String? firstName) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (_utilityFunctions.isValidBase64(photoUrl)) {
        _logger.info('Loading base64 image for $firstName');
        return _buildCircleAvatar(
          backgroundImage: MemoryImage(base64Decode(photoUrl)),
        );
      } else if (Uri.tryParse(photoUrl)?.hasAbsolutePath ?? false) {
        _logger.info('Loading network image for $firstName');
        return _buildCircleAvatar(
          backgroundImage: CachedNetworkImageProvider(photoUrl),
        );
      }
    }
    _logger.info('Loading initials for $firstName');
    return _buildCircleAvatar(
      child: Text(
        firstName?.isNotEmpty == true ? firstName![0] : '',
        style: TextStyle(color: AppColors.primaryColor, fontFamily: 'Roboto'),
      ),
    );
  }

  Widget _buildCircleAvatar({ImageProvider? backgroundImage, Widget? child}) {
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.secondaryColor,
        backgroundImage: backgroundImage,
        child: child,
      ),
    );
  }

  void _applyFilter(String filter) {
    setState(() {
      _currentFilter = filter;
      _pagingController.refresh();
      _fetchContactCount(); // Fetch contact count when changing the filter
    });
    // Close the drawer
    Navigator.of(context).pop();
  }

  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
      _pagingController.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hello NITR',
          style: TextStyle(color: AppColors.primaryColor),
        ),
        actions: [
          IconButton(
            icon:
                Icon(_isAscending ? Icons.arrow_downward : Icons.arrow_upward),
            onPressed: _toggleSortOrder,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
              ),
              child: Text(
                'Filter Contacts',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: FilterButton(
                label: 'All Employee',
                currentFilter: _currentFilter,
                onFilterSelected: _applyFilter,
              ),
            ),
            ListTile(
              title: FilterButton(
                label: 'Faculty',
                currentFilter: _currentFilter,
                onFilterSelected: _applyFilter,
              ),
            ),
            ListTile(
              title: FilterButton(
                label: 'Officer',
                currentFilter: _currentFilter,
                onFilterSelected: _applyFilter,
              ),
            ),
            ListTile(
              title: ElevatedButton(
                onPressed: () {
                  // Close the drawer
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DepartmentSearchScreen(),
                    ),
                  );
                  
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Search by Departments'),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$_currentFilter ($_contactCount)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
          Expanded(
            child: PagedListView<int, User>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<User>(
                itemBuilder: (context, item, index) {
                  return _buildContactItem(context, item, index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, User item, int index) {
    final bool isExpanded = _expandedIndex == index;
    final String fullName =
        "${item.firstName ?? ''}${item.middleName != null ? ' ${item.middleName}' : ''} ${item.lastName ?? ''}";

    return Dismissible(
      key: ValueKey(item.empCode),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          print('Call ${item.firstName}');
        } else if (direction == DismissDirection.endToStart) {
          print('Open profile of ${item.firstName}');
        }
        return false;
      },
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.33,
        DismissDirection.endToStart: 0.33,
      },
      background: _buildSwipeBackground(Icons.phone, 'Make Call'),
      secondaryBackground: _buildSwipeBackground(Icons.person, 'View Profile'),
      child: AnimatedContainer(
        duration: animationDuration,
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.0),
        padding: EdgeInsets.symmetric(
            horizontal: 16.0, vertical: isExpanded ? 12.0 : 6.0),
        decoration: BoxDecoration(
          color: isExpanded ? _selectedBackgroundColor : Colors.white,
          borderRadius: BorderRadius.circular(isExpanded ? 16.0 : 0.0),
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: _profileImagesCache[item.empCode] ??
                  _buildAvatar(item.photo, item.firstName),
              title: Text(
                fullName,
                style: const TextStyle(fontSize: 16, fontFamily: 'Roboto'),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                item.email ?? '',
                style: const TextStyle(fontSize: 14, fontFamily: 'Roboto'),
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _handleContactTap(index),
            ),
            AnimatedSize(
              duration: animationDuration,
              curve: Curves.easeInOut,
              child: isExpanded ? _buildExpandedMenu(item) : Container(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(IconData icon, String label) {
    return Container(
      color: AppColors.primaryColor,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8.0),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final String currentFilter;
  final Function(String) onFilterSelected;

  const FilterButton({
    required this.label,
    required this.currentFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => {
        onFilterSelected(label),
        //clear the expanded index when changing the filter
        (context as Element).markNeedsBuild()
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: currentFilter == label ? Colors.white : Colors.black,
        backgroundColor:
            currentFilter == label ? AppColors.primaryColor : Colors.grey[200],
      ),
      child: Text(label),
    );
  }
}
