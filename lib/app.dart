import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/core/utils/custom_error/custom_error.dart';
import 'package:hello_nitr/core/services/notifications/notifications_service.dart';
import 'package:hello_nitr/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:hello_nitr/providers/sample_provider.dart';

class MyApp extends StatelessWidget {
  final NotificationService notificationService;

  MyApp({required this.notificationService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => SampleProvider()), // Add your provider here
      ],
      child: MaterialApp(
        builder: (BuildContext context, Widget? widget) {
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return CustomError(errorDetails: errorDetails);
          };
          return widget!;
        },
        debugShowCheckedModeBanner: false,
        title: 'Hello NITR',
        theme: _buildAppTheme(),
        initialRoute: '/error',
        routes: appRoutes,
      ),
    );
  }

  ThemeData _buildAppTheme() {
    const primaryColor = Color(0xFFC35839);

    return ThemeData(
      fontFamily: 'Roboto',
      primaryColor: primaryColor,
      highlightColor: primaryColor,
      splashColor: primaryColor,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: primaryColor,
        selectionColor: primaryColor.withOpacity(0.4),
        selectionHandleColor: primaryColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(
          color: AppColors.primaryColor,
        ),
        titleTextStyle: TextStyle(
          color: AppColors.primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontFamily: 'Roboto',
        ),
      ),
      scaffoldBackgroundColor: Colors.white,
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryColor,
      ),
    );
  }
}
