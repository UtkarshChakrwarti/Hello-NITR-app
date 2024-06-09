import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hello_nitr/controllers/pin_unlock_screen_controller.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';

class PinUnlockScreen extends StatefulWidget {
  @override
  _PinUnlockScreenState createState() => _PinUnlockScreenState();
}

class _PinUnlockScreenState extends State<PinUnlockScreen> {
  final PinUnlockScreenController _pinUnlockScreenController = PinUnlockScreenController();
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
      _showErrorDialog('Failed to load user information.');
    }
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheckBiometrics = await _pinUnlockScreenController.canCheckBiometrics();
      if (canCheckBiometrics) {
        _authenticateWithBiometrics();
      }
    } catch (e) {
      _showErrorDialog('Failed to check biometric support.');
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      setState(() {
        _isAuthenticating = true;
      });

      final authenticated = await _pinUnlockScreenController.authenticateWithBiometrics();

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
      _showErrorDialog('Biometric authentication failed.');
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
        _showErrorDialog('Invalid PIN. Please try again.');
        setState(() {
          _pin = "";
        });
      }
    } catch (e) {
      _showErrorDialog('PIN validation failed.');
      setState(() {
        _pin = "";
      });
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: AppColors.primaryColor),
              SizedBox(width: 10),
              Text(
                'Logout',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Logout',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                PinUnlockScreenController().logout(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Row(
            children: [
              Icon(Icons.error, color: AppColors.primaryColor),
              SizedBox(width: 10),
              Text(
                'Error',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hello NITR',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: _logout,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.primaryColor.withOpacity(0.1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.logout,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Enter Your Hello NITR PIN',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        Text(
                          'Welcome, $_loggedInUserFirstName',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.primaryColor,
                          ),
                        ),
                        SizedBox(height: 40),
                        _buildPinDisplay(theme),
                      ],
                    ),
                  ),
                ),
                _buildKeypad(theme),
              ],
            ),
            if (_isAuthenticating)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinDisplay(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              width: 40,
              height: 50,
              child: Center(
                child: Icon(
                  Icons.circle,
                  size: 12,
                  color: _pin.length > index
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

  Widget _buildKeypad(ThemeData theme) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildKeypadRow(['1', '2', '3'], theme),
          _buildKeypadRow(['4', '5', '6'], theme),
          _buildKeypadRow(['7', '8', '9'], theme),
          _buildKeypadRow([Icons.backspace, '0', 'fingerprint'], theme),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<dynamic> keys, ThemeData theme) {
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (key == Icons.backspace) {
                  _onDeletePressed();
                } else if (key == 'fingerprint') {
                  _authenticateWithBiometrics();
                } else if (key is String) {
                  _onKeyPressed(key);
                }
              },
              splashColor: theme.primaryColor.withOpacity(0.2),
              highlightColor: theme.primaryColor.withOpacity(0.2),
              child: Container(
                height: 80,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border:
                      Border.all(color: theme.primaryColor.withOpacity(0.2)),
                ),
                child: key == 'fingerprint'
                    ? _buildFingerprintButton(theme)
                    : key == Icons.backspace
                        ? Icon(
                            key,
                            size: 30,
                            color: theme.primaryColor,
                          )
                        : Text(
                            key,
                            style: TextStyle(
                                fontSize: 24, color: theme.primaryColor),
                          ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFingerprintButton(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.primaryColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Icon(
          Icons.fingerprint,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }
}
