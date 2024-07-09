import 'package:flutter/material.dart';
import 'package:hello_nitr/controllers/login_controller.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/core/utils/dialogs_and_prompts.dart';
import 'package:hello_nitr/providers/login_provider.dart';
import 'package:provider/provider.dart';

class SignInButton extends StatelessWidget {
  final AnimationController animationController;
  final Animation<double> buttonScaleAnimation;
  final bool allFieldsFilled;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final FocusNode usernameFocusNode;
  final FocusNode passwordFocusNode;

  const SignInButton({super.key, 
    required this.animationController,
    required this.buttonScaleAnimation,
    required this.allFieldsFilled,
    required this.usernameController,
    required this.passwordController,
    required this.usernameFocusNode,
    required this.passwordFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => animationController.forward(),
      onTapUp: (_) => animationController.reverse(),
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: buttonScaleAnimation.value,
            child: ElevatedButton(
              onPressed: allFieldsFilled
                  ? () async {
                      final loginProvider = context.read<LoginProvider>();
                      try {
                        animationController.forward();
                        final isSuccess = await loginProvider.login(
                            usernameController.text,
                            passwordController.text,
                            context);
                        if (!isSuccess) {
                          if (!loginProvider.isAllowedToLogin &&
                              !loginProvider.invalidUserNameOrPassword) {
                            DialogsAndPrompts
                                .showLoginFromDifferentDeviceDialog(context);
                          } else {
                            DialogsAndPrompts.showErrorDialog(
                                'Invalid username or password', context);
                          }
                        } else {
                          usernameFocusNode.unfocus();
                          passwordFocusNode.unfocus();
                          LoginController().showSimSelectionModal(context);
                        }
                      } catch (e, stacktrace) {
                        debugPrint('Login error: $e\n$stacktrace');
                        DialogsAndPrompts.showErrorDialog(
                            'An error occurred. Please try again.', context);
                      } finally {
                        animationController.reverse();
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: allFieldsFilled
                    ? AppColors.primaryColor
                    : AppColors.lightSecondaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                elevation: 5,
                shadowColor: Colors.black54,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: context.watch<LoginProvider>().isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
  }
}
