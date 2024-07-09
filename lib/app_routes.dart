import 'package:flutter/material.dart';
import 'package:hello_nitr/core/utils/custom_error/custom_error.dart';
import 'package:hello_nitr/screens/contacts/update/contacts_update_screen.dart';
import 'package:hello_nitr/screens/home/home_screen.dart';
import 'package:hello_nitr/screens/login/login_screen.dart';
import 'package:hello_nitr/screens/otp/otp_verification_screen.dart';
import 'package:hello_nitr/screens/pin/create/pin_creation_screen.dart';
import 'package:hello_nitr/screens/pin/verify/pin_unlock_screen.dart';
import 'package:hello_nitr/screens/sim/sim_selection_screen.dart';
import 'package:hello_nitr/screens/splash/splash_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  // Splash Screen
  '/': (_) => const SplashScreen(),

  //Login Screen
  '/login': (context) => const LoginScreen(),

  //Sim Selection Screen
  '/simSelection': (context) => const SimSelectionScreen(),

  //OTP Verification Screen
  '/otp': (context) => const OtpVerificationScreen(mobileNumber: ''),

  //Contacts Update Screen
  '/contactsUpdate': (context) => const ContactsUpdateScreen(),

  //Pin Creation Screen
  '/pinCreation': (context) => const PinCreationScreen(),

  //Pin Unlock Screen
  '/pinUnlock': (context) => const PinUnlockScreen(),

  //Home Screen
  '/home': (context) => const HomeScreen(),

  //Custom error page
  '/error': (context) => CustomError(
        key: null,
        errorDetails: FlutterErrorDetails(
          exception: Exception('Dummy Exception'),
          stack: StackTrace.fromString('Dummy Stack Trace'),
        ),
      ),
};
