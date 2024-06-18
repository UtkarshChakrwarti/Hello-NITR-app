import 'package:flutter/material.dart';
import 'package:hello_nitr/screens/home/department_search_screen.dart';
import 'package:hello_nitr/screens/user/profile/widgets/icon_button.dart';

class FilterButtons extends StatelessWidget {
  final Function(String) onFilterSelected;

  const FilterButtons({
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButtonWidget(
                icon: Icons.people,
                label: "All Employees",
                iconSize: 22.0,
                fontSize: 11.0,
                onTap: () => onFilterSelected('All Employee'),
              ),
              IconButtonWidget(
                icon: Icons.school,
                label: "Faculties",
                iconSize: 22.0,
                fontSize: 11.0,
                onTap: () => onFilterSelected('Faculty'),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButtonWidget(
                icon: Icons.work,
                label: "Officers",
                iconSize: 22.0,
                fontSize: 11.0,
                onTap: () => onFilterSelected('Officer'),
              ),
              IconButtonWidget(
                icon: Icons.group,
                label: "Departments",
                iconSize: 22.0,
                fontSize: 11.0,
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DepartmentSearchScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
