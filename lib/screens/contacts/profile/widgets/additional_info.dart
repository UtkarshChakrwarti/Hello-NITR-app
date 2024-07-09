
import 'package:flutter/material.dart';

class AdditionalInfoTile extends StatelessWidget {
  final String label;
  final String info;

  const AdditionalInfoTile({
    required this.label,
    required this.info,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontFamily: 'Roboto',
              ),
            ),
          ),
          Expanded(
            child: Text(
              info,
              style: const TextStyle(
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