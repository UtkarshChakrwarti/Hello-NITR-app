import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/providers/home_provider.dart';
import 'package:hello_nitr/screens/home/widgets/contact_list_widget.dart';
import 'package:hello_nitr/screens/home/widgets/search_bar_widget.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _selectedBackgroundColor = Color(0xFFFDEEE8);
  static const Color _revealBackgroundColor = Color(0xFFF2F2F2);
  static const TextStyle _hintTextStyle =
      TextStyle(color: Colors.grey, fontFamily: 'Roboto');
  static const double _iconSize = 30.0;

  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  FocusNode departmentSearchFocusNode = FocusNode();
  Duration animationDuration = Duration(milliseconds: 300);
  bool isSearchVisible = false;
  bool isDepartmentSearch = false;
  ScrollController _scrollController = ScrollController();

  Map<String, Uint8List?> imageCache = {};
  Timer? cacheTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      homeProvider.fetchContacts();
      homeProvider.fetchDepartments();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !Provider.of<HomeProvider>(context, listen: false)
              .isLoadingMoreContacts) {
        Provider.of<HomeProvider>(context, listen: false).loadMoreContacts();
      }
    });

    // Set up cache refresh timer
    cacheTimer = Timer.periodic(Duration(hours: 1), (timer) {
      setState(() {
        imageCache.clear();
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    searchFocusNode.dispose();
    departmentSearchFocusNode.dispose();
    cacheTimer?.cancel();
    super.dispose();
  }

  void _toggleSearch(HomeProvider homeProvider) {
    setState(() {
      isSearchVisible = !isSearchVisible;
      if (isSearchVisible) {
        searchFocusNode.requestFocus();
      } else {
        searchController.clear();
        isDepartmentSearch = false;
        homeProvider.updateSearchQuery('');
        homeProvider.selectDepartment('Select Department');
      }
    });
  }

  void _enableDepartmentSearch(HomeProvider homeProvider) {
    setState(() {
      isDepartmentSearch = true;
      isSearchVisible = true;
      homeProvider.updateSearchQuery('');
      departmentSearchFocusNode.requestFocus();
      Navigator.of(context).pop();
      if (!isSearchVisible) {
        searchController.clear();
        homeProvider.updateSearchQuery('');
        homeProvider.selectDepartment('Select Department');
      }
    });
  }

  Uint8List? _getImageBytes(String base64Image, String key) {
    if (imageCache.containsKey(key)) {
      return imageCache[key];
    } else if (_isValidBase64(base64Image)) {
      try {
        Uint8List imageBytes = base64Decode(base64Image);
        imageCache[key] = imageBytes;
        return imageBytes;
      } catch (e) {
        imageCache[key] = null;
        return null;
      }
    } else {
      imageCache[key] = null;
      return null;
    }
  }

  bool _isValidBase64(String base64Image) {
    final base64Pattern = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
    return base64Pattern.hasMatch(base64Image);
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);
    final mediaQuery = MediaQuery.of(context);
    final textScaleFactor = mediaQuery.textScaleFactor;

    return WillPopScope(
      onWillPop: () async {
        if (isSearchVisible) {
          _toggleSearch(homeProvider);
          return false;
        }
        if (!Navigator.of(context).canPop()) {
          SystemNavigator.pop();
          return true;
        }
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(isDepartmentSearch ? 140.0 : 56.0),
          child: AppBar(
            automaticallyImplyLeading: false,
            leading: isSearchVisible
                ? SizedBox(width: 10)
                : Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.menu),
                      color: AppColors.primaryColor,
                      iconSize: _iconSize,
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
            title: isSearchVisible
                ? null
                : Text(
                    "Hello NITR",
                    style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 20 * textScaleFactor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto'),
                  ),
            flexibleSpace: isSearchVisible
                ? SearchBarWidget(
                    searchController: searchController,
                    searchFocusNode: searchFocusNode,
                    departmentSearchFocusNode: departmentSearchFocusNode,
                    hintTextStyle: _hintTextStyle,
                    isDepartmentSearch: isDepartmentSearch,
                    onSearchToggle: () => _toggleSearch(homeProvider),
                    onClearSearch: () {
                      searchController.clear();
                      homeProvider.updateSearchQuery('');
                      homeProvider.selectDepartment('Select Department');
                    },
                    onSearchQueryChanged: (query) {
                      homeProvider.updateSearchQuery(query);
                    },
                    departments: homeProvider.departments,
                    selectedDepartment: homeProvider.selectedDepartment,
                    onDepartmentChanged: (String? newValue) {
                      homeProvider.selectDepartment(newValue);
                    },
                  )
                : null,
            actions: [
              if (!isSearchVisible)
                IconButton(
                  icon: Icon(Icons.search),
                  color: AppColors.primaryColor,
                  iconSize: _iconSize,
                  onPressed: () => _toggleSearch(homeProvider),
                ),
              if (!isSearchVisible)
                IconButton(
                  icon: Icon(homeProvider.ascending
                      ? CupertinoIcons.sort_up
                      : CupertinoIcons.sort_down),
                  color: AppColors.primaryColor,
                  padding: EdgeInsets.all(10.0),
                  iconSize: _iconSize,
                  onPressed: homeProvider.sortContacts,
                  tooltip: homeProvider.ascending
                      ? "Sort Ascending"
                      : "Sort Descending",
                ),
            ],
            iconTheme:
                IconThemeData(color: AppColors.primaryColor, size: _iconSize),
          ),
        ),
        body: homeProvider.isLoadingContacts && homeProvider.contacts.isEmpty
            ? Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor))
            : Column(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (scrollInfo.metrics.pixels ==
                                  scrollInfo.metrics.maxScrollExtent &&
                              !homeProvider.isLoadingMoreContacts) {
                            homeProvider.loadMoreContacts();
                          }
                          return true;
                        },
                        child: ContactListWidget(
                          scrollController: _scrollController,
                          contacts: homeProvider.isSearchActive
                              ? homeProvider.searchContacts
                              : homeProvider.contacts,
                          isSearchActive: homeProvider.isSearchActive,
                          isLoadingMoreContacts:
                              homeProvider.isLoadingMoreContacts,
                          onContactTap: (index) {
                            _handleContactTap(index, homeProvider);
                          },
                          selectedContactIndex:
                              homeProvider.selectedContactIndex,
                          isMenuVisible: homeProvider.isMenuVisible,
                          animationDuration: animationDuration,
                          getImageBytes: _getImageBytes,
                          revealBackgroundColor: _revealBackgroundColor,
                          selectedBackgroundColor: _selectedBackgroundColor,
                          textScaleFactor: textScaleFactor,
                          iconSize: _iconSize,
                          imageCache: imageCache,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _handleContactTap(int index, HomeProvider homeProvider) {
    setState(() {
      if (homeProvider.selectedContactIndex == index) {
        homeProvider.toggleMenuVisibility(!homeProvider.isMenuVisible);
      } else {
        homeProvider.setSelectedContactIndex(index);
        homeProvider.toggleMenuVisibility(true);
      }
    });
  }
}
