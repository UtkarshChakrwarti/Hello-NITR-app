import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
import 'package:hello_nitr/core/utils/custom_error/custom_error.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _checkLoginStatus() async {
    try {
      bool isLoggedIn = await LocalStorageService.checkIfUserIsLoggedIn();
      String? storedPin = await LocalStorageService.getPin();

      if (isLoggedIn && storedPin != null) {
        Navigator.pushReplacementNamed(context, '/pinUnlock');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } on PlatformException catch (e) {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (ctx) =>
                CustomError(errorDetails: FlutterErrorDetails(exception: e))),
      );
    } catch (e) {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (ctx) =>
                CustomError(errorDetails: FlutterErrorDetails(exception: e))),
      );
    }
  }
}
