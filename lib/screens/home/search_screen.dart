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
  final Logger _logger = Logger('SearchScreen');
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  int? _expandedIndex;
  String _searchQuery = '';
  final Map<String, Widget> _profileImagesCache = {};

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(_fetchPage);
    _setupLogging();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
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
      _logger.severe('Failed to fetch page: $error');
      _pagingController.error = error;
    }
  }

  void _cacheProfileImages(List<User> users) {
    for (User user in users) {
      if (user.empCode != null &&
          !_profileImagesCache.containsKey(user.empCode)) {
        _profileImagesCache[user.empCode!] = Avatar(
          photoUrl: user.photo,
          firstName: user.firstName,
          utilityFunctions: _utilityFunctions,
        );
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

  Future<void> _initialize() async {
    await Future.delayed(
      const Duration(milliseconds: 300),
      () => _searchFocusNode.requestFocus(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          iconSize: 30,
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          focusNode: _searchFocusNode,
          controller: _searchController,
          decoration: InputDecoration(
            //remove default underline
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: 'Search users',
            hintStyle: TextStyle(
                fontSize: 18,
                color: Colors.grey[400],
                fontWeight: FontWeight.normal),
            border: InputBorder.none,
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    iconSize: 30,
                    color: AppColors.primaryColor,
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
      body: FutureBuilder(
        future: _initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return PagedListView<int, User>(
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
                          utilityFunctions: _utilityFunctions,
                        ),
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
            );
          }
        },
      ),
    );
  }
}
