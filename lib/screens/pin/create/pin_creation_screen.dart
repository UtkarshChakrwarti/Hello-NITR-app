import 'package:flutter/material.dart';
import 'package:hello_nitr/controllers/pin_creation_controller.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/providers/login_provider.dart';

class PinCreationScreen extends StatefulWidget {
  @override
  _PinCreationScreenState createState() => _PinCreationScreenState();
}

class _PinCreationScreenState extends State<PinCreationScreen> {
  final PinCreationController _pinCreationController = PinCreationController();
  final LoginProvider _loginProvider = LoginProvider();
  String _pin = "";
  String _confirmPin = "";
  bool _isConfirming = false;

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              title: Row(
                children: [
                  Icon(Icons.info, color: AppColors.primaryColor),
                  const SizedBox(width: 10),
                  Text(
                    'Confirmation',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Text(
                'Are you sure you want to start again?',
                style: const TextStyle(fontSize: 16),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'No',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text(
                    'Yes',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                    await _logoutAndNavigateToLogin();
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _onKeyPressed(String value) {
    setState(() {
      if (_isConfirming) {
        if (_confirmPin.length < 4) {
          _confirmPin += value;
        }
      } else {
        if (_pin.length < 4) {
          _pin += value;
        }
      }
    });
  }

  void _onDeletePressed() {
    setState(() {
      if (_isConfirming) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      } else {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      }
    });
  }

  void _onSubmit() {
    if (_isConfirming && _confirmPin.length == 4) {
      if (_pin == _confirmPin) {
        try {
          _pinCreationController.savePin(_pin).then((_) {
            Navigator.pushReplacementNamed(context, '/home');
          });
        } catch (e) {
          _showErrorDialog('Failed to save PIN.');
        }
      } else {
        _showErrorDialog('PINs do not match. Please try again.');
        setState(() {
          _pin = "";
          _confirmPin = "";
          _isConfirming = false;
        });
      }
    } else if (!_isConfirming && _pin.length == 4) {
      setState(() {
        _isConfirming = true;
      });
    }
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

  void _onBackPressed() {
    setState(() {
      _isConfirming = false;
      _pin = "";
      _confirmPin = "";
    });
  }

  Future<void> _logoutAndNavigateToLogin() async {
    try {
      await _loginProvider.logout(context);
    } catch (e) {
      _showErrorDialog('Failed to logout.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isConfirming
                              ? 'Verify your Hello NITR PIN'
                              : 'Create your Hello NITR PIN',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
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
            if (_isConfirming)
              Positioned(
                top: 50,
                left: 16,
                child: GestureDetector(
                  onTap: _onBackPressed,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.primaryColor.withOpacity(0.1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_back,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinDisplay(ThemeData theme) {
    String displayPin = _isConfirming ? _confirmPin : _pin;
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
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 2,
                    color: displayPin.length > index
                        ? theme.primaryColor
                        : theme.primaryColor.withOpacity(0.2),
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  displayPin.length > index ? displayPin[index] : '',
                  style: TextStyle(
                    fontSize: 24,
                    color: theme.primaryColor,
                  ),
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
          _buildKeypadRow([Icons.backspace, '0', 'check'], theme),
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
                } else if (key == 'check') {
                  _onSubmit();
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
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.2),
                  ),
                ),
                child: key == 'check'
                    ? _buildCheckButton(theme)
                    : key is IconData
                        ? Icon(
                            key,
                            size: 30,
                            color: theme.primaryColor,
                          )
                        : Text(
                            key,
                            style: TextStyle(
                              fontSize: 24,
                              color: theme.primaryColor,
                            ),
                          ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCheckButton(ThemeData theme) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.primaryColor,
      ),
      child: Center(
        child: Icon(
          Icons.check,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }
}
