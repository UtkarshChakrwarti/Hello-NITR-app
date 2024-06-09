import 'package:flutter/material.dart';
import 'package:hello_nitr/core/utils/dialogs_and_prompts.dart';
import 'package:hello_nitr/controllers/pin_creation_controller.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/providers/login_provider.dart';
import 'package:hello_nitr/screens/pin/create/widgets/pin_input_field.dart';

class PinCreationScreen extends StatefulWidget {
  @override
  _PinCreationScreenState createState() => _PinCreationScreenState();
}

class _PinCreationScreenState extends State<PinCreationScreen> {
  final PinCreationController _pinCreationController = PinCreationController();
  final LoginProvider _loginProvider = LoginProvider();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  final FocusNode _confirmPinFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_pinFocusNode);
    });
  }

  Future<bool> _onWillPop() async {
    final shouldExit =
        await DialogsAndPrompts.showExitConfirmationDialog(context);
    if (shouldExit != null && shouldExit) {
      await _logoutAndNavigateToLogin();
    }
    return false;
  }

  void _onSubmit() {
    if (_pinController.text.length == 4 &&
        _confirmPinController.text.length == 4) {
      if (_pinController.text == _confirmPinController.text) {
        try {
          _pinCreationController.savePin(_pinController.text).then((_) {
            Navigator.pushReplacementNamed(context, '/home');
          });
        } catch (e) {
          DialogsAndPrompts.showErrorDialog('Failed to save PIN.', context);
        }
      } else {
        DialogsAndPrompts.showErrorDialog(
            'PINs do not match. Please try again.', context);
        setState(() {
          _pinController.clear();
          _confirmPinController.clear();
          FocusScope.of(context).requestFocus(_pinFocusNode);
        });
      }
    } else {
      DialogsAndPrompts.showErrorDialog(
          'Please enter a 4-digit PIN in both fields.', context);
    }
  }

  Future<void> _logoutAndNavigateToLogin() async {
    try {
      await _loginProvider.logout(context);
    } catch (e) {
      DialogsAndPrompts.showErrorDialog('Failed to logout.', context);
    }
  }

  void _onPinChanged(String pin) {
    if (pin.length == 4) {
      FocusScope.of(context).requestFocus(_confirmPinFocusNode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: topPadding + 20, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Create Your\nHello NITR PIN',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                PinInputField(
                  label: 'Create PIN',
                  controller: _pinController,
                  focusNode: _pinFocusNode,
                  onChanged: _onPinChanged,
                ),
                const SizedBox(height: 40),
                PinInputField(
                  label: 'Re-Enter PIN',
                  controller: _confirmPinController,
                  focusNode: _confirmPinFocusNode,
                ),
                const SizedBox(height: 60),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: _onSubmit,
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
