import 'package:flutter/material.dart';
import 'package:hello_nitr/screens/login/widgets/welcome_text.dart';
import 'package:hello_nitr/screens/login/widgets/text_field.dart';
import 'package:hello_nitr/screens/login/widgets/sign_in_button.dart';
import 'package:hello_nitr/screens/login/widgets/terms_text.dart';
import 'package:hello_nitr/screens/login/widgets/footer.dart';
import 'package:hello_nitr/screens/login/widgets/exit_confirmation_dialog.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late FocusNode _usernameFocusNode;
  late FocusNode _passwordFocusNode;
  late AnimationController _animationController;
  late Animation<double> _buttonScaleAnimation;
  bool _obscureText = true;
  ValueNotifier<bool> _allFieldsFilled = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _usernameFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _usernameController.addListener(_checkFields);
    _passwordController.addListener(_checkFields);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _checkFields() {
    _allFieldsFilled.value = _usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showExitConfirmationDialog(context) ?? false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 40),
                          Image.asset(
                            'assets/images/login-main-image.png',
                            height: constraints.maxHeight * 0.15,
                            width: constraints.maxWidth * 0.5,
                          ),
                          SizedBox(height: constraints.maxHeight * 0.01),
                          WelcomeText(),
                          SizedBox(height: constraints.maxHeight * 0.025),
                          CustomTextField(
                            controller: _usernameController,
                            hintText: "Username",
                            icon: Icons.person_2_outlined,
                            obscureText: false,
                            focusNode: _usernameFocusNode,
                          ),
                          SizedBox(height: constraints.maxHeight * 0.01),
                          CustomTextField(
                            controller: _passwordController,
                            hintText: "Password",
                            icon: Icons.lock_clock_outlined,
                            obscureText: _obscureText,
                            focusNode: _passwordFocusNode,
                            onVisibilityToggle: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                          SizedBox(height: constraints.maxHeight * 0.025),
                          ValueListenableBuilder<bool>(
                            valueListenable: _allFieldsFilled,
                            builder: (context, value, child) {
                              return SignInButton(
                                animationController: _animationController,
                                buttonScaleAnimation: _buttonScaleAnimation,
                                allFieldsFilled: value,
                                usernameController: _usernameController,
                                passwordController: _passwordController,
                                usernameFocusNode: _usernameFocusNode,
                                passwordFocusNode: _passwordFocusNode,
                              );
                            },
                          ),
                          SizedBox(height: constraints.maxHeight * 0.05),
                          TermsText(),
                        ],
                      ),
                      SizedBox(height: constraints.maxHeight * 0.02),
                      Footer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
