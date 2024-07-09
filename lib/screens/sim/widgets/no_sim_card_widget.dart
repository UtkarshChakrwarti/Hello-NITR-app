import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';

class NoSimCardWidget extends StatefulWidget {
  final Function(String) onPhoneNumberChanged;

  const NoSimCardWidget({super.key, required this.onPhoneNumberChanged});

  @override
  _NoSimCardWidgetState createState() => _NoSimCardWidgetState();
}

class _NoSimCardWidgetState extends State<NoSimCardWidget> {
  final FocusNode _phoneNumberFocusNode = FocusNode();
  final TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _phoneNumberFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _phoneNumberFocusNode.dispose();
    _textFieldController.dispose();
    super.dispose();
  }

  void _onPhoneNumberChanged(String value) {
    String filteredValue = value.replaceAll(
        RegExp(r'\D'), ''); // Remove all non-numeric characters
    if (filteredValue.length <= 10) {
      _textFieldController.value = TextEditingValue(
        text: filteredValue,
        selection: TextSelection.collapsed(offset: filteredValue.length),
      );
      widget.onPhoneNumberChanged(filteredValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.transparent),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/ind.png',
                      height: 24,
                      width: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '+91',
                      style: TextStyle(
                          color: AppColors.primaryColor, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _textFieldController,
                  focusNode: _phoneNumberFocusNode,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primaryColor),
                    ),
                    labelText: 'Phone Number',
                    hintText: 'Enter your phone number',
                    labelStyle: const TextStyle(color: AppColors.primaryColor),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primaryColor),
                    ),
                    counterText: '', // Suppress the character counter
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  onChanged: _onPhoneNumberChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Please enter your registered mobile number to proceed',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
