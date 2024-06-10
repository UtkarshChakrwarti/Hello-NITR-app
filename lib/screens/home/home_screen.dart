import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/core/utils/link_launcher.dart';
import 'package:hello_nitr/providers/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hello_nitr/models/user.dart';

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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    searchFocusNode.dispose();
    departmentSearchFocusNode.dispose();
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

  Uint8List? _getImageBytes(String base64Image) {
    if (imageCache.containsKey(base64Image)) {
      return imageCache[base64Image];
    } else {
      try {
        Uint8List imageBytes = base64Decode(base64Image);
        imageCache[base64Image] = imageBytes;
        return imageBytes;
      } catch (e) {
        imageCache[base64Image] = null;
        return null;
      }
    }
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
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                            start: 8.0, end: 8.0, bottom: 8.0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back),
                              color: AppColors.primaryColor,
                              iconSize: _iconSize,
                              onPressed: () {
                                _toggleSearch(homeProvider);
                              },
                            ),
                            Expanded(
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextField(
                                    controller: searchController,
                                    focusNode: searchFocusNode,
                                    decoration: InputDecoration(
                                      hintText: isDepartmentSearch
                                          ? "Search Contacts by Department"
                                          : "Search contacts",
                                      hintStyle: _hintTextStyle,
                                      border: InputBorder.none,
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 8.0),
                                    ),
                                    onChanged: (query) {
                                      homeProvider.updateSearchQuery(query);
                                    },
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.clear),
                              color: AppColors.primaryColor,
                              iconSize: _iconSize,
                              onPressed: () {
                                searchController.clear();
                                homeProvider.updateSearchQuery('');
                                homeProvider
                                    .selectDepartment('Select Department');
                              },
                            ),
                          ],
                        ),
                      ),
                      if (isDepartmentSearch)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 4.0,
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: DropdownButton<String>(
                              value: homeProvider.selectedDepartment ??
                                  'Select Department',
                              hint: Text("Select Department",
                                  style: _hintTextStyle),
                              isExpanded: true,
                              underline: SizedBox(),
                              items: homeProvider.departments
                                  .map((String department) {
                                return DropdownMenuItem<String>(
                                  value: department,
                                  child: Text(department),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                homeProvider.selectDepartment(newValue);
                              },
                            ),
                          ),
                        ),
                    ],
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
            iconTheme: IconThemeData(color: AppColors.primaryColor, size: _iconSize),
          ),
        ),
        // drawer: UserProfileScreen(
        //   onSearchCriteriaSelected: () => _enableDepartmentSearch(homeProvider),
        //   onLogout: () async => homeProvider.logout(context),
        //   onFilterByEmployeeType: (employeeType) {
        //     homeProvider.selectEmployeeType(employeeType);
        //     Navigator.of(context).pop();
        //   },
        // ),
        body: homeProvider.isLoadingContacts && homeProvider.contacts.isEmpty
            ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
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
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: ClampingScrollPhysics(),
                          itemCount: homeProvider.isSearchActive
                              ? homeProvider.searchContacts.length
                              : homeProvider.contacts.length +
                                  (homeProvider.isLoadingMoreContacts ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index ==
                                (homeProvider.isSearchActive
                                    ? homeProvider.searchContacts.length
                                    : homeProvider.contacts.length)) {
                              return Center(
                                  child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryColor,
                                ),
                              ));
                            }
                            var contact = homeProvider.isSearchActive
                                ? homeProvider.searchContacts[index]
                                : homeProvider.contacts[index];
                            String fullName = contact.firstName! +
                                (contact.middleName == ""
                                    ? ""
                                    : " ${contact.middleName}") +
                                (contact.lastName!.isEmpty
                                    ? ""
                                    : " ${contact.lastName}");

                            bool isExpanded =
                                homeProvider.selectedContactIndex == index && homeProvider.isMenuVisible;
                            return GestureDetector(
                              onHorizontalDragEnd: (details) {
                                if (details.primaryVelocity! > 0) {
                                  LinkLauncher.makeCall(contact.mobile ?? '');
                                }
                              },
                              child: Dismissible(
                                key: Key(contact.mobile ?? ''),
                                direction: DismissDirection.startToEnd,
                                confirmDismiss: (direction) async {
                                  LinkLauncher.makeCall(contact.mobile ?? '');
                                  return false;
                                },
                                background: Container(
                                  color: _revealBackgroundColor,
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.phone,
                                        color: AppColors.primaryColor,
                                        size: _iconSize,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Make Call",
                                        style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Roboto',
                                          fontSize: 14 * textScaleFactor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                child: AnimatedContainer(
                                  duration: animationDuration,
                                  curve: Curves.easeInOut,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 1.0),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: isExpanded ? 12.0 : 6.0),
                                  decoration: BoxDecoration(
                                    color: isExpanded
                                        ? _selectedBackgroundColor
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(
                                        isExpanded ? 16.0 : 0.0),
                                  ),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 0.0),
                                        leading: contact.photo != null
                                            ? _buildAvatar(contact.photo!,
                                                contact.firstName!)
                                            : CircleAvatar(
                                                backgroundColor:
                                                    AppColors.primaryColor,
                                                child: Text(
                                                  contact.firstName![0],
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: 'Roboto'),
                                                ),
                                              ),
                                        title: Text(
                                          fullName,
                                          style: TextStyle(
                                              fontSize: 16 * textScaleFactor,
                                              fontFamily: 'Roboto'),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Text(
                                          contact.email!,
                                          style: TextStyle(
                                              fontSize: 14 * textScaleFactor,
                                              fontFamily: 'Roboto'),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        onTap: () =>
                                            _handleContactTap(index, homeProvider),
                                      ),
                                      if (isExpanded)
                                        Divider(
                                            thickness: 1,
                                            color: AppColors.primaryColor.withOpacity(0.5)),
                                      AnimatedCrossFade(
                                        firstChild: SizedBox.shrink(),
                                        secondChild:
                                            _buildExpandedMenu(contact),
                                        crossFadeState: isExpanded
                                            ? CrossFadeState.showSecond
                                            : CrossFadeState.showFirst,
                                        duration: animationDuration,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAvatar(String base64Image, String firstName) {
    bool validBase64 = RegExp(r'^[a-zA-Z0-9/+]*={0,2}$').hasMatch(base64Image);

    if (!validBase64 || base64Image.isEmpty) {
      return Container(
        padding:
            EdgeInsets.all(1), // Add padding to create space for the border
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: AppColors.primaryColor,
              width: 1), // Set border color and width
        ),
        child: CircleAvatar(
          backgroundColor: AppColors.primaryColor, // Use theme color
          child: Text(
            firstName[0],
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
              fontSize: 14 * MediaQuery.of(context).textScaleFactor,
            ),
          ),
        ),
      );
    }

    Uint8List? imageBytes = _getImageBytes(base64Image);

    return Container(
      padding: EdgeInsets.all(1), // Add padding to create space for the border
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: AppColors.primaryColor,
            width: 1), // Set border color and width
      ),
      child: CircleAvatar(
        backgroundImage: MemoryImage(imageBytes!),
      ),
    );
  }

  Widget _buildExpandedMenu(User contact) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMenuButton(
            icon: CupertinoIcons.phone,
            onPressed: () => LinkLauncher.makeCall(contact.mobile ?? ""),
          ),
          _buildMenuButton(
            icon: FontAwesomeIcons.whatsapp,
            onPressed: () => LinkLauncher.sendWpMsg(contact.mobile ?? ""),
          ),
          _buildMenuButton(
            icon: CupertinoIcons.chat_bubble_text,
            onPressed: () => LinkLauncher.sendMsg(contact.mobile ?? ""),
          ),
          _buildMenuButton(
            icon: CupertinoIcons.mail,
            onPressed: () => LinkLauncher.sendEmail(contact.email ?? ""),
          ),
          _buildMenuButton(
            icon: CupertinoIcons.profile_circled,
            onPressed: () {
              //push to contact profile screen with contact details
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => ContactProfileScreen(contact),
              //   ),
              // );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: _iconSize),
          color: AppColors.primaryColor,
          onPressed: onPressed,
          padding: EdgeInsets.all(10.0),
        ),
      ],
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
