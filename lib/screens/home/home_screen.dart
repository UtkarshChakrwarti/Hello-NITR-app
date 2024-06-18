import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/core/utils/link_launcher.dart';
import 'package:hello_nitr/models/user.dart';
import 'package:hello_nitr/providers/home_provider.dart';
import 'package:hello_nitr/screens/contacts/profile/contact_profile_screen.dart';
import 'package:hello_nitr/screens/home/widgets/avatar.dart';
import 'package:hello_nitr/screens/home/widgets/contact_list.dart';
import 'package:hello_nitr/screens/user/profile/user_profile_screen.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:logging/logging.dart';
import 'package:hello_nitr/core/utils/utility_functions.dart';
import 'search_screen.dart';

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

  int? _expandedIndex;
  String _currentFilter = 'All Employee';
  bool _isAscending = true;
  int _contactCount = 0;
  final Map<String, Widget> _profileImagesCache = {};

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
        _profileImagesCache[user.empCode!] = Avatar(
            photoUrl: user.photo,
            firstName: user.firstName,
            utilityFunctions: _utilityFunctions);
        _logger.info('Image cached for user ${user.empCode}');
      }
    }
  }

  //show custom filter names based on the current filter
  String get _filterName {
    switch (_currentFilter) {
      case 'All Employee':
        return 'All Employees';
      case 'Faculty':
        return 'Faculties';
      case 'Officer':
        return 'Officers';
      default:
        return _currentFilter;
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            iconSize: 30,
            onPressed: () {
              _scaffoldKey.currentState!.openDrawer();
            },
          ),
          title: const Text(
            'Hello NITR',
            style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 20,
                fontFamily: 'Sans-serif',
                fontWeight: FontWeight.w500),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              iconSize: 30,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(),
                  ),
                );
              },
            ),
            IconButton(
              iconSize: 30,
              icon: Icon(_isAscending
                  ? CupertinoIcons.sort_up
                  : CupertinoIcons.sort_down),
              onPressed: _toggleSortOrder,
            ),
          ],
        ),
        drawer: Drawer(
          child: UserProfileScreen(
            currentFilter: _currentFilter,
            onFilterSelected: _applyFilter,
          ),
        ),
        body: Column(
          children: [
            Padding(
              //padding top and left
              padding: const EdgeInsets.only(top: 4.0, left: 20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '$_filterName ($_contactCount)',
                  style:  TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Sans-serif',
                    color: AppColors.primaryColor.withOpacity(0.8),
                  ),
                ),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyFilter(String filter) {
    setState(() {
      _currentFilter = filter;
      _pagingController.refresh();
      _fetchContactCount();
    });
    Navigator.of(context).pop();
  }

  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
      _pagingController.refresh();
    });
  }
}
