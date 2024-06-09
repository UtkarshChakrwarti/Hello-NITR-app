import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/core/constants/app_constants.dart';
import 'dart:async';
import 'package:hello_nitr/controllers/otp_verification_controller.dart';
import 'package:hello_nitr/screens/contacts/update/contacts_update_screen.dart';
import 'package:hello_nitr/screens/otp/widgets/otp_input.dart';
import 'package:hello_nitr/screens/otp/widgets/resend_button.dart';
import 'package:hello_nitr/screens/otp/widgets/verify_button.dart';
import 'package:hello_nitr/screens/sim/widgets/error_dialog.dart';


class OtpVerificationScreen extends StatefulWidget {
  final String mobileNumber;

  const OtpVerificationScreen({required this.mobileNumber, super.key});

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final OtpVerificationController _otpVerificationController = OtpVerificationController();

  bool _isResendButtonActive = false;
  late Timer _timer;
  int _remainingSeconds = AppConstants.otpTimeOutSeconds;
  String _enteredOtp = "";
  String _actualOtp = "";
  bool _isOtpComplete = false;

  @override
  void initState() {
    super.initState();
    _startOtpTimer();
    _fetchOtp();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startOtpTimer() {
    const oneSecond = Duration(seconds: 1);
    _timer = Timer.periodic(oneSecond, (timer) {
      setState(() {
        if (_remainingSeconds == 0) {
          _isResendButtonActive = true;
          timer.cancel();
        } else {
          _remainingSeconds--;
        }
      });
    });
  }

  void _fetchOtp() async {
    try {
      _actualOtp = await _otpVerificationController.fetchOtp();
    } catch (e) {
      _showErrorDialog('Failed to fetch OTP. Please try again.');
    }
  }

  void _verifyOtp() async {
    try {
      bool isSuccess = await _otpVerificationController.verifyOtp(_enteredOtp, _actualOtp);
      if (isSuccess) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ContactsUpdateScreen()),
        );
      } else {
        _showErrorDialog('Invalid OTP');
      }
    } catch (e) {
      _showErrorDialog('An error occurred while verifying the OTP. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
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
    } catch (e) {
      _showErrorDialog('An error occurred during logout. Please try again.');
    }
  }

  Future<bool> _onWillPop() async {
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
                  Text('Confirmation', style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
                ],
              ),
              content: const Text('Are you sure you want to start again?', style: TextStyle(fontSize: 16)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No', style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                    await _logoutAndNavigateToLogin();
                  },
                  child: const Text('Yes', style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Verify Your Mobile Number!',
                                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'We have sent an OTP to your mobile number ${widget.mobileNumber}',
                                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 40),
                                  OtpInput(
                                    onChanged: (String code) {
                                      setState(() {
                                        _enteredOtp = code;
                                        _isOtpComplete = code.length == 6;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 40),
                                  VerifyButton(
                                    isOtpComplete: _isOtpComplete,
                                    onPressed: _isOtpComplete ? _verifyOtp : null,
                                  ),
                                  const SizedBox(height: 30),
                                  ResendButton(
                                    isResendButtonActive: _isResendButtonActive,
                                    remainingSeconds: _remainingSeconds,
                                    onResend: () {
                                      setState(() {
                                        _isResendButtonActive = false;
                                        _remainingSeconds = AppConstants.otpTimeOutSeconds;
                                        _startOtpTimer();
                                        _fetchOtp(); // Re-fetch the OTP
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
