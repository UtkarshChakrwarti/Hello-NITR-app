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
  final Map<int, Widget> _profileImagesCache = {};

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(_fetchPage);
    _setupLogging();
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
      _cacheProfileImages(newItems, pageKey);
    } catch (error) {
      _pagingController.error = error;
    }
  }

  void _cacheProfileImages(List<User> users, int pageKey) {
    for (int i = 0; i < users.length; i++) {
      int index = pageKey + i;
      _profileImagesCache[index] =
          _buildAvatar(users[i].photo, users[i].firstName);
      _logger.info('Image cached for user at index $index');
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
      padding: EdgeInsets.all(1),
      decoration: BoxDecoration(
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
      _profileImagesCache.clear(); // Clear the cache when changing the filter
      _pagingController.refresh();
    });
  }

  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
      _profileImagesCache.clear(); // Clear the cache when changing the sorting order
      _pagingController.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello NITR'),
        actions: [
          IconButton(
            icon: Icon(_isAscending ? Icons.arrow_downward : Icons.arrow_upward),
            onPressed: _toggleSortOrder,
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Handle search action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterButton('All Employee'),
                _buildFilterButton('Faculty'),
                _buildFilterButton('Officer'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Showing: $_currentFilter',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: PagedListView<int, User>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<User>(
                itemBuilder: (context, item, index) {
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
                    dismissThresholds: {
                      DismissDirection.startToEnd: 0.33,
                      DismissDirection.endToStart: 0.33,
                    },
                    background: Container(
                      color: AppColors.primaryColor,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 20.0),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.phone_solid, color: Colors.white),
                          SizedBox(width: 8.0),
                          Text('Make Call',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    secondaryBackground: Container(
                      color: AppColors.primaryColor,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('View Profile',
                              style: TextStyle(color: Colors.white)),
                          SizedBox(width: 8.0),
                          Icon(CupertinoIcons.person_crop_circle_fill,
                              color: Colors.white),
                        ],
                      ),
                    ),
                    child: AnimatedContainer(
                      duration: animationDuration,
                      curve: Curves.easeInOut,
                      margin:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.0),
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: isExpanded ? 12.0 : 6.0),
                      decoration: BoxDecoration(
                        color: isExpanded
                            ? _selectedBackgroundColor
                            : Colors.white,
                        borderRadius:
                            BorderRadius.circular(isExpanded ? 16.0 : 0.0),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 0.0),
                            leading: _profileImagesCache[index] ??
                                _buildAvatar(item.photo, item.firstName),
                            title: Text(
                              fullName,
                              style:
                                  TextStyle(fontSize: 16, fontFamily: 'Roboto'),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              item.email ?? '',
                              style:
                                  TextStyle(fontSize: 14, fontFamily: 'Roboto'),
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _handleContactTap(index),
                          ),
                          AnimatedSize(
                            duration: animationDuration,
                            curve: Curves.easeInOut,
                            child: isExpanded
                                ? _buildExpandedMenu(item)
                                : Container(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label) {
    return ElevatedButton(
      onPressed: () => _applyFilter(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: _currentFilter == label ? Colors.white : Colors.black,
        backgroundColor:
            _currentFilter == label ? AppColors.primaryColor : Colors.grey[200],
      ),
      child: Text(label),
    );
  }
}
