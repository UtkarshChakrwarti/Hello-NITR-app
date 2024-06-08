
import 'package:flutter/material.dart';
import 'package:hello_nitr/core/utils/custom_error/custom_error.dart';
import 'package:hello_nitr/screens/login/login_screen.dart';
import 'package:hello_nitr/screens/splash/splash_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  // Splash Screen
  '/': (_) => const SplashScreen(),


  //Login Screen
  '/login': (context) => LoginScreen(),



  //Custom error page
  '/error': (context) => CustomError(
        key: null,
        errorDetails: FlutterErrorDetails(
          exception: Exception('Dummy Exception'),
          stack: StackTrace.fromString('Dummy Stack Trace'),
        ),
      ),

  

};
