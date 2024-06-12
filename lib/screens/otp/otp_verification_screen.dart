import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/core/constants/app_constants.dart';
import 'dart:async';
import 'package:hello_nitr/controllers/otp_verification_controller.dart';
import 'package:hello_nitr/providers/login_provider.dart';
import 'package:hello_nitr/screens/contacts/update/contacts_update_screen.dart';
import 'package:hello_nitr/screens/otp/widgets/otp_input.dart';
import 'package:hello_nitr/screens/otp/widgets/resend_button.dart';
import 'package:hello_nitr/screens/otp/widgets/verify_button.dart';
import 'package:hello_nitr/screens/sim/widgets/error_dialog.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String mobileNumber;

  const OtpVerificationScreen({required this.mobileNumber, super.key});

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final OtpVerificationController _otpVerificationController = OtpVerificationController();
  late LoginProvider loginProvider;
  final Logger _logger = Logger('OtpVerificationScreen');

  bool _isResendButtonActive = false;
  late Timer _timer;
  int _remainingSeconds = AppConstants.otpTimeOutSeconds;
  String _enteredOtp = "";
  String _actualOtp = "";
  bool _isOtpComplete = false;

  @override
  void initState() {
    super.initState();
    loginProvider = context.read<LoginProvider>();
    _logger.info('OtpVerificationScreen initialized');
    _startOtpTimer();
    _fetchOtp();
  }

  @override
  void dispose() {
    _logger.info('OtpVerificationScreen disposed');
    _timer.cancel();
    super.dispose();
  }

  void _startOtpTimer() {
    _logger.info('Starting OTP timer');
    const oneSecond = Duration(seconds: 1);
    _timer = Timer.periodic(oneSecond, (timer) {
      setState(() {
        if (_remainingSeconds == 0) {
          _isResendButtonActive = true;
          timer.cancel();
          _logger.info('OTP timer completed');
        } else {
          _remainingSeconds--;
        }
      });
    });
  }

  void _fetchOtp() async {
    try {
      _actualOtp = await _otpVerificationController.fetchOtp();
      _logger.info('OTP fetched successfully');
    } catch (e) {
      _logger.severe('Failed to fetch OTP: $e');
      _showErrorDialog('Failed to fetch OTP. Please try again.');
    }
  }

  void _verifyOtp() async {
    try {
      bool isSuccess = await _otpVerificationController.verifyOtp(_enteredOtp, _actualOtp);
      if (isSuccess) {
        _logger.info('OTP verified successfully');
        if (loginProvider.isFreshLoginAttempt == true) {
          try {
            await _otpVerificationController.updateDeviceId();
            _logger.info('Device ID updated successfully');
          } catch (e) {
            _logger.severe('Failed to update device ID: $e');
            _showErrorDialog('Failed to update device ID. Please try again.');
          }
        }
        _logger.info('No Device Update Needed : Navigating to ContactsUpdateScreen');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ContactsUpdateScreen()),
        );
      } else {
        _logger.warning('Invalid OTP entered');
        _showErrorDialog('Invalid OTP');
      }
    } catch (e) {
      _logger.severe('Error during OTP verification: $e');
      _showErrorDialog('An error occurred while verifying the OTP. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    _logger.info('Showing error dialog: $message');
    showDialog(
      context: context,
      builder: (context) {
        return ErrorDialog(message: message);
      },
    );
  }

  Future<void> _logoutAndNavigateToLogin() async {
    try {
      await _otpVerificationController.logout(context);
      _logger.info('Logged out successfully');
    } catch (e) {
      _logger.severe('Error during logout: $e');
      _showErrorDialog('An error occurred during logout. Please try again.');
    }
  }

  Future<bool> _onWillPop() async {
    _logger.info('Back button pressed, showing confirmation dialog');
    return (await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              title: const Row(
                children: [
                  Icon(Icons.info, color: AppColors.primaryColor),
                  SizedBox(width: 10),
                  Text('Confirm',
                      style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
                ],
              ),
              content: const Text(
                  'Are you sure you want to go back to the login page?',
                  style: TextStyle(fontSize: 16)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No',
                      style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
                ),
                TextButton(
                  onPressed: () async {
                    await _logoutAndNavigateToLogin();
                  },
                  child: const Text('Yes',
                      style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'OTP Verification',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Please enter the 6 digit verification code sent to',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '🇮🇳',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      widget.mobileNumber,
                      style: TextStyle(fontSize: 16, color: AppColors.primaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                OtpInput(
                  onChanged: (String code) {
                    setState(() {
                      _enteredOtp = code;
                      _isOtpComplete = code.length == 6;
                    });
                  },
                ),
                const SizedBox(height: 20),
                if (!_isResendButtonActive)
                  Text(
                    'Didn\'t receive the code?',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ResendButton(
                  isResendButtonActive: _isResendButtonActive,
                  remainingSeconds: _remainingSeconds,
                  onResend: () {
                    setState(() {
                      _isResendButtonActive = false;
                      _remainingSeconds = AppConstants.otpTimeOutSeconds;
                      _startOtpTimer();
                      _fetchOtp();
                      _logger.info('OTP re-sent');
                    });
                  },
                ),
                const SizedBox(height: 20),
                VerifyButton(
                  isOtpComplete: _isOtpComplete,
                  onPressed: _isOtpComplete ? _verifyOtp : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
