
import 'package:flutter/material.dart';
import 'package:hello_nitr/core/utils/custom_error/custom_error.dart';
import 'package:hello_nitr/screens/home/home_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  // Home Screen
  '/': (context) => HomeScreen(),

  //Custom error page
  '/error': (context) => CustomError(
        key: null,
        errorDetails: FlutterErrorDetails(
          exception: Exception('Dummy Exception'),
          stack: StackTrace.fromString('Dummy Stack Trace'),
        ),
      ),

  

};
