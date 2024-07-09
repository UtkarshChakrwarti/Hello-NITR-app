import 'package:flutter/material.dart';
import 'package:hello_nitr/screens/pin/verify/widgets/keypad_button.dart';

class Keypad extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onFingerprintPressed;

  const Keypad({super.key, 
    required this.onKeyPressed,
    required this.onDeletePressed,
    required this.onFingerprintPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = screenWidth * 0.22;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildKeypadRow(['1', '2', '3'], theme, buttonSize),
          _buildKeypadRow(['4', '5', '6'], theme, buttonSize),
          _buildKeypadRow(['7', '8', '9'], theme, buttonSize),
          _buildKeypadRow([Icons.fingerprint, '0', Icons.backspace], theme, buttonSize),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<dynamic> keys, ThemeData theme, double buttonSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((key) {
        return KeypadButton(
          key: ValueKey(key),
          value: key,
          onPressed: () {
            if (key == Icons.backspace) {
              onDeletePressed();
            } else if (key == Icons.fingerprint) {
              onFingerprintPressed();
            } else if (key is String) {
              onKeyPressed(key);
            }
          },
        );
      }).toList(),
    );
  }
}
