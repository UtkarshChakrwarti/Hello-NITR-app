import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hello_nitr/controllers/pin_unlock_screen_controller.dart';
import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
import 'package:hello_nitr/screens/pin/verify/widgets/dialogs.dart';
import 'package:hello_nitr/screens/pin/verify/widgets/keypad.dart';
import 'package:hello_nitr/screens/pin/verify/widgets/pin_display.dart';

class PinUnlockScreen extends StatefulWidget {
  @override
  _PinUnlockScreenState createState() => _PinUnlockScreenState();
}

class _PinUnlockScreenState extends State<PinUnlockScreen> {
  final PinUnlockScreenController _pinUnlockScreenController =
      PinUnlockScreenController();
  String _pin = "";
  bool _isAuthenticating = false;
  String _loggedInUserFirstName = "";

  @override
  void initState() {
    super.initState();
    _loadLoggedInUserFirstName();
    _checkBiometrics();
  }

  Future<void> _loadLoggedInUserFirstName() async {
    try {
      final loggedUser = await LocalStorageService.getCurrentUserName();
      setState(() {
        _loggedInUserFirstName = loggedUser?.split(' ')[0] ?? "";
      });
    } catch (e) {
      showErrorDialog(context, 'Failed to load user information.');
    }
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheckBiometrics =
          await _pinUnlockScreenController.canCheckBiometrics();
      if (canCheckBiometrics) {
        _authenticateWithBiometrics();
      }
    } catch (e) {
      showErrorDialog(context, 'Failed to check biometric support.');
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      setState(() {
        _isAuthenticating = true;
      });

      final authenticated =
          await _pinUnlockScreenController.authenticateWithBiometrics();

      setState(() {
        _isAuthenticating = false;
      });

      if (authenticated) {
        _navigateToHome();
      } else {
        // Fallback to PIN unlock
      }
    } catch (e) {
      setState(() {
        _isAuthenticating = false;
      });
      showErrorDialog(context, 'Biometric authentication failed.');
    }
  }

  void _onKeyPressed(String value) {
    setState(() {
      if (_pin.length < 4) {
        _pin += value;
      }
      if (_pin.length == 4) {
        _validatePin();
      }
    });
  }

  void _onDeletePressed() {
    setState(() {
      if (_pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  void _validatePin() async {
    try {
      final isValid = await _pinUnlockScreenController.validatePin(_pin);
      if (isValid) {
        _navigateToHome();
      } else {
        showErrorDialog(context, 'Invalid PIN. Please try again.');
        setState(() {
          _pin = "";
        });
      }
    } catch (e) {
      showErrorDialog(context, 'PIN validation failed.');
      setState(() {
        _pin = "";
      });
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Enter Your Hello NITR PIN',
                    style: TextStyle(
                      fontSize: 18, // Smaller font size
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Welcome, $_loggedInUserFirstName',
                    style: TextStyle(
                      fontSize: 14, // Smaller font size
                      color: theme.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  PinDisplay(pin: _pin),
                  SizedBox(height: screenHeight * 0.05),
                  Keypad(
                    onKeyPressed: _onKeyPressed,
                    onDeletePressed: _onDeletePressed,
                    onFingerprintPressed: _authenticateWithBiometrics,
                  ),
                  OutlinedButton.icon(
                    onPressed: () => showLogoutDialog(context, () {
                      PinUnlockScreenController().logout(context);
                    }),
                    style: OutlinedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.0, vertical: 7.0),
                      backgroundColor: Colors.transparent,
                      side: BorderSide(color: theme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                    icon:
                        Icon(Icons.logout, color: theme.primaryColor, size: 12),
                    label: Text(
                      'Logout',
                      style: TextStyle(color: theme.primaryColor, fontSize: 12),
                    ),
                  ),
                  if (_isAuthenticating)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
