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

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  static const _pageSize = 10;
  final UtilityFunctions _utilityFunctions = UtilityFunctions();
  final PagingController<int, User> _pagingController =
      PagingController(firstPageKey: 0);
  final Duration animationDuration = Duration(milliseconds: 300);
  final Logger _logger = Logger('SearchScreen');

  static const Color _iconColor = AppColors.primaryColor;
  static const Color _selectedBackgroundColor = Color(0xFFFDEEE8);

  int? _expandedIndex;
  String _searchQuery = '';
  final Map<String, Widget> _profileImagesCache = {};
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(_fetchPage);
    _setupLogging();
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
      final newItems =
          await HomeProvider.searchUsers(pageKey, _pageSize, _searchQuery);
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
    _searchFocusNode.dispose();
    _searchController.dispose();
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

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _pagingController.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          focusNode: _searchFocusNode,
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey[400]),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear),
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
          style: TextStyle(color: AppColors.primaryColor, fontSize: 18.0),
          onChanged: _onSearchChanged,
        ),
      ),
      body: PagedListView<int, User>(
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
                    Text('Make Call', style: TextStyle(color: Colors.white)),
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
                    Text('View Profile', style: TextStyle(color: Colors.white)),
                    SizedBox(width: 8.0),
                    Icon(CupertinoIcons.person_crop_circle_fill,
                        color: Colors.white),
                  ],
                ),
              ),
              child: AnimatedContainer(
                duration: animationDuration,
                curve: Curves.easeInOut,
                margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.0),
                padding: EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: isExpanded ? 12.0 : 6.0),
                decoration: BoxDecoration(
                  color: isExpanded ? _selectedBackgroundColor : Colors.white,
                  borderRadius: BorderRadius.circular(isExpanded ? 16.0 : 0.0),
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
                      leading: _profileImagesCache[item.empCode] ??
                          _buildAvatar(item.photo, item.firstName),
                      title: Text(
                        fullName,
                        style: TextStyle(fontSize: 16, fontFamily: 'Roboto'),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        item.email ?? '',
                        style: TextStyle(fontSize: 14, fontFamily: 'Roboto'),
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _handleContactTap(index),
                    ),
                    AnimatedSize(
                      duration: animationDuration,
                      curve: Curves.easeInOut,
                      child:
                          isExpanded ? _buildExpandedMenu(item) : Container(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
