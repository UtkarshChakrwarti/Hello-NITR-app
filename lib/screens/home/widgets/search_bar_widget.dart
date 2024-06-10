import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final FocusNode departmentSearchFocusNode;
  final TextStyle hintTextStyle;
  final bool isDepartmentSearch;
  final VoidCallback onSearchToggle;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onSearchQueryChanged;
  final List<String> departments;
  final String? selectedDepartment;
  final ValueChanged<String?> onDepartmentChanged;

  const SearchBarWidget({
    required this.searchController,
    required this.searchFocusNode,
    required this.departmentSearchFocusNode,
    required this.hintTextStyle,
    required this.isDepartmentSearch,
    required this.onSearchToggle,
    required this.onClearSearch,
    required this.onSearchQueryChanged,
    required this.departments,
    required this.selectedDepartment,
    required this.onDepartmentChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 8.0, end: 8.0, bottom: 8.0),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                color: AppColors.primaryColor,
                onPressed: onSearchToggle,
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
                        hintStyle: hintTextStyle,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                      ),
                      onChanged: onSearchQueryChanged,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.clear),
                color: AppColors.primaryColor,
                onPressed: onClearSearch,
              ),
            ],
          ),
        ),
        if (isDepartmentSearch)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                value: selectedDepartment ?? 'Select Department',
                hint: Text("Select Department", style: hintTextStyle),
                isExpanded: true,
                underline: SizedBox(),
                items: departments.map((String department) {
                  return DropdownMenuItem<String>(
                    value: department,
                    child: Text(department),
                  );
                }).toList(),
                onChanged: onDepartmentChanged,
              ),
            ),
          ),
      ],
    );
  }
}
