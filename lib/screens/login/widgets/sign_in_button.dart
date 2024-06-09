import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/providers/login_provider.dart';
import 'package:hello_nitr/screens/login/login_helper.dart';
import 'package:provider/provider.dart';

class SignInButton extends StatelessWidget {
  final LoginHelper loginHelper;

  SignInButton({required this.loginHelper});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: loginHelper.allFieldsFilled,
      builder: (context, value, child) {
        return GestureDetector(
          onTapDown: (_) => loginHelper.animationController.forward(),
          onTapUp: (_) => loginHelper.animationController.reverse(),
          child: AnimatedBuilder(
            animation: loginHelper.animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: loginHelper.buttonScaleAnimation.value,
                child: ElevatedButton(
                  onPressed: value
                      ? () async {
                          final loginController = context.read<LoginProvider>();
                          try {
                            loginHelper.animationController.forward();
                            final isSuccess = await loginController.login(
                                loginHelper.usernameController.text,
                                loginHelper.passwordController.text);
                            if (isSuccess == 1) {
                              loginHelper.showSimSelectionModal(context);
                            } else if (isSuccess == 2) {
                              loginHelper.showErrorDialog(
                                  'Invalid Credentials', context);
                            }else if (isSuccess == 3) {
                              loginHelper.showErrorDialog(
                                  'Device ID does not match. Please contact support for assistance', context);
                            }
                          } catch (e, stacktrace) {
                            // Log the error and stack trace to a monitoring service or console
                            debugPrint('Login error: $e\n$stacktrace');
                            loginHelper.showErrorDialog(
                                'An error occurred. Please try again.', context);
                          } finally {
                            loginHelper.animationController.reverse();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        value ? AppColors.primaryColor : Colors.grey,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                    shadowColor: Colors.black54,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    child: context.watch<LoginProvider>().isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            key: ValueKey('loading'))
                        : const Text("SIGN IN",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontFamily: 'Roboto'),
                            key: ValueKey('text')),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
