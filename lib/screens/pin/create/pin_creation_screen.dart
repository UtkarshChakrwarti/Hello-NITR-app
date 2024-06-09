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
  bool _pinVisible = false;
  bool _confirmPinVisible = false;
  bool _pinsMatch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_pinFocusNode);
    });
  }

  Future<bool> _onWillPop() async {
    final shouldExit = await DialogsAndPrompts.showExitConfirmationDialog(context);
    if (shouldExit != null && shouldExit) {
      await _logoutAndNavigateToLogin();
    }
    return false;
  }

  void _onSubmit() {
    if (_pinController.text.length == 4 && _confirmPinController.text.length == 4) {
      setState(() {
        _pinsMatch = _pinController.text == _confirmPinController.text;
      });
      if (_pinsMatch) {
        try {
          _pinCreationController.savePin(_pinController.text).then((_) {
            Navigator.pushReplacementNamed(context, '/home');
          });
        } catch (e) {
          DialogsAndPrompts.showErrorDialog('Failed to save PIN.', context);
        }
      } else {
        DialogsAndPrompts.showErrorDialog('PINs do not match. Please try again.', context);
        setState(() {
          _pinController.clear();
          _confirmPinController.clear();
          FocusScope.of(context).requestFocus(_pinFocusNode);
        });
      }
    } else {
      DialogsAndPrompts.showErrorDialog('Please enter a 4-digit PIN in both fields.', context);
    }
  }

  Future<void> _logoutAndNavigateToLogin() async {
    try {
      await _loginProvider.logout(context);
    } catch (e) {
      DialogsAndPrompts.showErrorDialog('Failed to logout.', context);
    }
  }

  void _togglePinVisibility() {
    setState(() {
      _pinVisible = !_pinVisible;
    });
  }

  void _toggleConfirmPinVisibility() {
    setState(() {
      _confirmPinVisible = !_confirmPinVisible;
    });
  }

  void _onPinChanged(String pin) {
    setState(() {
      _pinsMatch = _pinController.text == _confirmPinController.text;
    });
  }

  void _onConfirmPinChanged(String pin) {
    setState(() {
      _pinsMatch = _pinController.text == _confirmPinController.text;
    });
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
                const SizedBox(height: 20),
                Text(
                  'To set up your PIN create a 4 digit code then confirm it below',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 50),
                PinInputField(
                  label: 'PIN CODE',
                  controller: _pinController,
                  focusNode: _pinFocusNode,
                  pinVisible: _pinVisible,
                  toggleVisibility: _togglePinVisibility,
                  onChanged: _onPinChanged,
                ),
                const SizedBox(height: 20),
                PinInputField(
                  label: 'CONFIRM YOUR PIN CODE',
                  controller: _confirmPinController,
                  focusNode: _confirmPinFocusNode,
                  pinVisible: _confirmPinVisible,
                  toggleVisibility: _toggleConfirmPinVisibility,
                  onChanged: _onConfirmPinChanged,
                ),
                if (_pinsMatch)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Your PIN codes are the same',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _onSubmit,
                    child: const Text(
                      'CONTINUE',
                      style: TextStyle(fontSize: 16, color: Colors.white),
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
