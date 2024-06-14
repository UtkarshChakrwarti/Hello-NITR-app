import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/providers/home_provider.dart';
import 'package:hello_nitr/screens/contacts/profile/contact_profile_screen.dart';
import 'package:hello_nitr/screens/user/profile/user_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hello_nitr/models/user.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _iconColor = AppColors.primaryColor;
  static const Color _selectedBackgroundColor = Color(0xFFFDEEE8);
  static const Color _revealBackgroundColor = Color(0xFFF2F2F2);
  static const TextStyle _hintTextStyle =
      TextStyle(color: Colors.grey, fontFamily: 'Roboto');
  static const double _iconSize = 30.0;

  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  FocusNode departmentSearchFocusNode = FocusNode();
  int? selectedContactIndex;
  int? selectedSearchContactIndex;
  bool isMenuVisible = false;
  Duration animationDuration = Duration(milliseconds: 300);
  bool isSearchVisible = false;
  bool isDepartmentSearch = false;
  ScrollController _mainScrollController = ScrollController();
  ScrollController _searchScrollController = ScrollController();

  Map<String, Uint8List?> imageCache = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      homeProvider.fetchContacts();
      homeProvider.fetchDepartments();
      homeProvider.loadSuggestedContacts();
    });

    _mainScrollController.addListener(() {
      if (_mainScrollController.hasClients &&
          _mainScrollController.position.pixels == _mainScrollController.position.maxScrollExtent &&
          !Provider.of<HomeProvider>(context, listen: false).isLoadingMoreContacts) {
        Provider.of<HomeProvider>(context, listen: false).loadMoreContacts();
      }
      if (_mainScrollController.hasClients) {
        Provider.of<HomeProvider>(context, listen: false).setScrollPosition(_mainScrollController.position.pixels);
      }
    });

    _searchScrollController.addListener(() {
      if (_searchScrollController.hasClients &&
          _searchScrollController.position.pixels == _searchScrollController.position.maxScrollExtent &&
          !Provider.of<HomeProvider>(context, listen: false).isLoadingSearchContacts) {
        Provider.of<HomeProvider>(context, listen: false).loadMoreSearchContacts();
      }
    });
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    _searchScrollController.dispose();
    searchFocusNode.dispose();
    departmentSearchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch(HomeProvider homeProvider) {
    setState(() {
      isSearchVisible = !isSearchVisible;
      if (isSearchVisible) {
        searchFocusNode.requestFocus();
        homeProvider.updateSearchQuery('');
      } else {
        searchController.clear();
        isDepartmentSearch = false;
        homeProvider.updateSearchQuery('');
        homeProvider.selectDepartment('Select Department');
        if (_mainScrollController.hasClients) {
          _mainScrollController.jumpTo(homeProvider.scrollPosition);
        }
      }
      selectedContactIndex = null;
      selectedSearchContactIndex = null;
      isMenuVisible = false;
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
          return true;
        }
        return false;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(isDepartmentSearch ? 140.0 : 56.0),
          child: AppBar(
            leading: isSearchVisible
                ? SizedBox(width: 10)
                : Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.menu),
                      color: _iconColor,
                      iconSize: _iconSize,
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
            title: isSearchVisible
                ? null
                : Text(
                    "Hello NITR",
                    style: TextStyle(
                        color: _iconColor,
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
                              color: _iconColor,
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
                              color: _iconColor,
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
                  color: _iconColor,
                  iconSize: _iconSize,
                  onPressed: () => _toggleSearch(homeProvider),
                ),
              if (!isSearchVisible)
                IconButton(
                  icon: Icon(homeProvider.ascending
                      ? CupertinoIcons.sort_up
                      : CupertinoIcons.sort_down),
                  color: _iconColor,
                  padding: EdgeInsets.all(10.0),
                  iconSize: _iconSize,
                  onPressed: homeProvider.sortContacts,
                  tooltip: homeProvider.ascending
                      ? "Sort Ascending"
                      : "Sort Descending",
                ),
            ],
            iconTheme: IconThemeData(color: _iconColor, size: _iconSize),
          ),
        ),
        drawer: UserProfileScreen(
          onSearchCriteriaSelected: () => _enableDepartmentSearch(homeProvider),
          onLogout: () async => homeProvider.logout(context),
          onFilterByEmployeeType: (employeeType) {
            homeProvider.selectEmployeeType(employeeType);
            Navigator.of(context).pop();
          },
        ),
        body: Column(
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
                    controller: isSearchVisible
                        ? _searchScrollController
                        : _mainScrollController,
                    physics: ClampingScrollPhysics(),
                    itemCount: isSearchVisible
                        ? homeProvider.searchQuery.isEmpty
                            ? homeProvider.suggestedContacts.length + 1 +
                                (homeProvider.isLoadingMoreContacts ? 1 : 0)
                            : homeProvider.searchContacts.length +
                                (homeProvider.isLoadingSearchContacts ? 1 : 0)
                        : homeProvider.contacts.length +
                            (homeProvider.isLoadingMoreContacts ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (isSearchVisible && homeProvider.searchQuery.isEmpty && index == 0) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Suggested',
                            style: TextStyle(
                              color: _iconColor.withOpacity(0.7),
                              fontWeight: FontWeight.bold,
                              fontSize: 18 * textScaleFactor,
                            ),
                          ),
                        );
                      }

                      int adjustedIndex = isSearchVisible && homeProvider.searchQuery.isEmpty ? index - 1 : index;

                      if (adjustedIndex ==
                          (isSearchVisible
                              ? homeProvider.searchQuery.isEmpty
                                  ? homeProvider.suggestedContacts.length
                                  : homeProvider.searchContacts.length
                              : homeProvider.contacts.length)) {
                        return Center(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            color: _iconColor,
                          ),
                        ));
                      }

                      var contact = isSearchVisible
                          ? homeProvider.searchQuery.isEmpty
                              ? homeProvider.suggestedContacts[adjustedIndex]
                              : homeProvider.searchContacts[adjustedIndex]
                          : homeProvider.contacts[adjustedIndex];
                      String fullName = contact.firstName! +
                          (contact.middleName == ""
                              ? ""
                              : " ${contact.middleName}") +
                          (contact.lastName!.isEmpty
                              ? ""
                              : " ${contact.lastName}");

                      bool isExpanded = !isSearchVisible
                          ? selectedContactIndex == index && isMenuVisible
                          : selectedSearchContactIndex == adjustedIndex && isMenuVisible;

                      return GestureDetector(
                        onHorizontalDragEnd: (details) {
                          if (details.primaryVelocity! > 0) {
                            _makeCall(contact.mobile ?? '');
                            homeProvider.addRecentContact(contact);
                          } else if (details.primaryVelocity! < 0) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ContactProfileScreen(contact),
                              ),
                            );
                          }
                        },
                        child: Dismissible(
                          key: Key(contact.empCode ?? ''),
                          direction: DismissDirection.horizontal,
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              _makeCall(contact.mobile ?? '');
                              homeProvider.addRecentContact(contact);
                            } else if (direction == DismissDirection.endToStart) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ContactProfileScreen(contact),
                                ),
                              );
                            }
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
                                  color: _iconColor,
                                  size: _iconSize,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Make Call",
                                  style: TextStyle(
                                    color: _iconColor,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                    fontSize: 14 * textScaleFactor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          secondaryBackground: Container(
                            color: _revealBackgroundColor,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Profile",
                                  style: TextStyle(
                                    color: _iconColor,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                    fontSize: 14 * textScaleFactor,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(
                                  Icons.person,
                                  color: _iconColor,
                                  size: _iconSize,
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
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 0.0),
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
                                    contact.email ?? '',
                                    style: TextStyle(
                                        fontSize: 14 * textScaleFactor,
                                        fontFamily: 'Roboto'),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () {
                                    if (!isSearchVisible) {
                                      _handleContactTap(index, homeProvider);
                                    } else {
                                      setState(() {
                                        if (selectedSearchContactIndex == adjustedIndex) {
                                          isMenuVisible = !isMenuVisible;
                                        } else {
                                          selectedSearchContactIndex = adjustedIndex;
                                          isMenuVisible = true;
                                        }
                                      });
                                    }
                                  },
                                ),
                                if (isExpanded)
                                  Divider(
                                      thickness: 1,
                                      color: _iconColor.withOpacity(0.5)),
                                AnimatedCrossFade(
                                  firstChild: SizedBox.shrink(),
                                  secondChild: _buildExpandedMenu(contact),
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
            icon: Icons.call,
            onPressed: () {
              _makeCall(contact.mobile ?? '');
              Provider.of<HomeProvider>(context, listen: false)
                  .addRecentContact(contact);
            },
          ),
          _buildMenuButton(
            icon: FontAwesomeIcons.whatsapp,
            onPressed: () {
              _sendWpMsg(contact.mobile ?? '');
              Provider.of<HomeProvider>(context, listen: false)
                  .addRecentContact(contact);
            },
          ),
          _buildMenuButton(
            icon: Icons.message,
            onPressed: () {
              _sendMsg(contact.mobile ?? '');
              Provider.of<HomeProvider>(context, listen: false)
                  .addRecentContact(contact);
            },
          ),
          _buildMenuButton(
            icon: Icons.email,
            onPressed: () {
              _sendEmail(contact.email ?? '');
              Provider.of<HomeProvider>(context, listen: false)
                  .addRecentContact(contact);
            },
          ),
          _buildMenuButton(
            icon: Icons.more_vert,
            onPressed: () {
              // //push to contact profile screen with contact details
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactProfileScreen(contact),
                ),
              );
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
          color: _iconColor,
          onPressed: onPressed,
          padding: EdgeInsets.all(10.0),
        ),
      ],
    );
  }

  void _makeCall(String phoneNumber) async {
    final url = "tel:$phoneNumber";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("Could not launch $url");
    }
  }

  void _sendWpMsg(String phoneNumber) async {
    final url = "https://wa.me/$phoneNumber";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("Could not launch $url");
    }
  }

  void _sendMsg(String phoneNumber) async {
    final url = "sms:$phoneNumber";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("Could not launch $url");
    }
  }

  void _sendEmail(String email) async {
    final url = "mailto:$email";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("Could not launch $url");
    }
  }

  void _handleContactTap(int index, HomeProvider homeProvider) {
    setState(() {
      if (!isSearchVisible) {
        if (selectedContactIndex == index) {
          isMenuVisible = !isMenuVisible;
        } else {
          selectedContactIndex = index;
          homeProvider.setExpandedContactIndex(index);
          isMenuVisible = true;
        }
      } else {
        if (selectedSearchContactIndex == index) {
          isMenuVisible = !isMenuVisible;
        } else {
          selectedSearchContactIndex = index;
          isMenuVisible = true;
        }
      }
    });
  }
}
