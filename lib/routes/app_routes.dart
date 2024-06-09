import 'package:flutter/material.dart';
import 'package:hello_nitr/core/utils/custom_error/custom_error.dart';
import 'package:hello_nitr/screens/login/login_screen.dart';
import 'package:hello_nitr/screens/otp/otp_verification_screen.dart';
import 'package:hello_nitr/screens/sim/sim_selection_screen.dart';
import 'package:hello_nitr/screens/splash/splash_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  // Splash Screen
  '/': (_) => const SplashScreen(),

  //Login Screen
  '/login': (context) => LoginScreen(),

  //Sim Selection Screen
  '/simSelection': (context) => SimSelectionScreen(),

  '/otp': (context) => const OtpVerificationScreen(mobileNumber: ''),

  //Custom error page
  '/error': (context) => CustomError(
        key: null,
        errorDetails: FlutterErrorDetails(
          exception: Exception('Dummy Exception'),
          stack: StackTrace.fromString('Dummy Stack Trace'),
        ),
      ),
};
