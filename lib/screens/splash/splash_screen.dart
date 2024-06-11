import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
import 'package:logging/logging.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final Logger _logger = Logger('SplashScreen');

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: const Image(
                  image: AssetImage('assets/images/hello_nitr.png'),
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              LoadingAnimationWidget.staggeredDotsWave(
                color: AppColors.primaryColor,
                size: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkLoginStatus() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      bool isLoggedIn = await LocalStorageService.checkIfUserIsLoggedIn();
      String? storedPin = await LocalStorageService.getPin();

      _logger.info('Login status: $isLoggedIn');
      _logger.info('Stored PIN: $storedPin');

      if (!mounted) return;

      if (isLoggedIn && storedPin != null) {
        // Navigator.pushReplacementNamed(context, '/pinUnlock');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } on PlatformException catch (e) {
      _logger.severe('PlatformException occurred: $e');
    } catch (e) {
      _logger.severe('An error occurred: $e');
    }
  }
}
