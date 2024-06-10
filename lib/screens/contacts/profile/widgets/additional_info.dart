
import 'package:flutter/material.dart';

class AdditionalInfoTile extends StatelessWidget {
  final String label;
  final String info;

  const AdditionalInfoTile({
    required this.label,
    required this.info,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontFamily: 'Roboto',
              ),
            ),
          ),
          Expanded(
            child: Text(
              info,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
    );
  }
}