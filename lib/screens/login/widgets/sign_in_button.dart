import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/providers/login_provider.dart';
import 'package:hello_nitr/screens/login/login_helper.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';

class SignInButton extends StatelessWidget {
  final LoginHelper loginHelper;
  final Logger _logger = Logger('SignInButton');

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
                          // Hide the keyboard
                          FocusScope.of(context).unfocus();

                          final loginController = context.read<LoginProvider>();
                          try {
                            _logger.info('Login button pressed');
                            loginHelper.animationController.forward();
                            final response = await loginController.login(
                                loginHelper.usernameController.text,
                                loginHelper.passwordController.text,
                                context);

                            // Handle the response from the login API
                            switch (response) {
                              case 1:
                                _logger.info(
                                    'Login successful, proceeding to SIM selection');
                                loginHelper.showSimSelectionModal(context);
                                break;
                              case 2:
                                _logger.warning('Device ID update failed');
                                loginHelper.showErrorDialog(
                                    'Device ID update failed', context);
                                break;
                              case 3:
                                _logger.warning('Device ID mismatch');
                                loginHelper.showErrorDialog(
                                    'Device ID does not match. Please contact support for assistance',
                                    context);
                                break;
                              case 4:
                                _logger
                                    .warning('Failed to save login response');
                                loginHelper.showErrorDialog(
                                    'Failed to save login response', context);
                                break;
                              case 5:
                                _logger.warning('Device verification failed');
                                loginHelper.showErrorDialog(
                                    'Device verification failed', context);
                                break;
                              case 6:
                                _logger.warning('Invalid User Credentials');
                                loginHelper.showErrorDialog(
                                    'Invalid User Credentials', context);
                                break;
                              default:
                                _logger.severe('An unknown error occurred');
                                loginHelper.showErrorDialog(
                                    'An error occurred. Please try again',
                                    context);
                                break;
                            }
                          } catch (e, stacktrace) {
                            _logger.severe('Login error: $e\n$stacktrace');
                            loginHelper.showErrorDialog(
                                'An error occurred. Please try again.',
                                context);
                          } finally {
                            loginHelper.animationController.reverse();
                            _logger.info('Login process completed');
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
