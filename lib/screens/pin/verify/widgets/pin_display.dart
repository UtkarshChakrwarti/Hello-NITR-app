import 'package:flutter/material.dart';

class PinDisplay extends StatelessWidget {
  final String pin;

  const PinDisplay({super.key, required this.pin});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            child: SizedBox(
              width: 40,
              height: 50,
              child: Center(
                child: Icon(
                  Icons.circle,
                  size: 25,
                  color: pin.length > index
                      ? theme.primaryColor
                      : theme.primaryColor.withOpacity(0.2),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
