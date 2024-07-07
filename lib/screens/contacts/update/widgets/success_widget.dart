import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';

class SuccessWidget extends StatefulWidget {
  final Animation<double> animation;
  final int updatedContacts;
  final int totalContacts;
  final VoidCallback onPressed;

  const SuccessWidget({
    required this.animation,
    required this.updatedContacts,
    required this.totalContacts,
    required this.onPressed,
  });

  @override
  _SuccessWidgetState createState() => _SuccessWidgetState();
}

class _SuccessWidgetState extends State<SuccessWidget> {
  bool _isButtonClicked = false;

  void _handleButtonClick() {
    setState(() {
      _isButtonClicked = true;
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: widget.animation,
          child: const Icon(
            CupertinoIcons.check_mark_circled,
            color: AppColors.primaryColor,
            size: 100, // Larger icon
          ),
        ),
        const SizedBox(height: 40),
        Text(
          'Updated Contacts: ${widget.updatedContacts}/${widget.totalContacts}',
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 40),
        if (!_isButtonClicked)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.all(20),
            ),
            onPressed: _handleButtonClick,
            child: const Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 30,
            ),
          )
        else
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          ),
      ],
    );
  }
}
