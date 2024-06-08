import 'package:flutter/material.dart';
import 'package:hello_nitr/screens/login/login_helper.dart';
import 'package:hello_nitr/screens/login/widgets/footer.dart';
import 'package:hello_nitr/screens/login/widgets/sign_in_button.dart';
import 'package:hello_nitr/screens/login/widgets/terms_text.dart';
import 'package:hello_nitr/screens/login/widgets/text_field.dart';
import 'package:hello_nitr/screens/login/widgets/welcome_text.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late LoginHelper _loginHelper;

  @override
  void initState() {
    super.initState();
    _loginHelper = LoginHelper();
    _loginHelper.initializeControllers(this, context);
  }

  @override
  void dispose() {
    _loginHelper.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop =
            await _loginHelper.showExitConfirmationDialog(context);
        return shouldPop ?? false;
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
                          SizedBox(height: constraints.maxHeight * 0.1),
                          Image.asset(
                            'assets/images/login-main-image.png',
                            height: constraints.maxHeight * 0.15,
                            width: constraints.maxWidth * 0.5,
                          ),
                          SizedBox(height: constraints.maxHeight * 0.01),
                          WelcomeText(),
                          const SizedBox(height: 10),
                          CustomTextField(
                              controller: _loginHelper.usernameController,
                              hintText: "Username",
                              icon: Icons.person,
                              obscureText: false,
                              focusNode: _loginHelper.usernameFocusNode),
                          SizedBox(height: constraints.maxHeight * 0.01),
                          CustomTextField(
                              controller: _loginHelper.passwordController,
                              hintText: "Password",
                              icon: Icons.lock,
                              obscureText: true,
                              focusNode: _loginHelper.passwordFocusNode,
                              toggleObscureText: () {
                                setState(() {
                                  _loginHelper.obscureText = !_loginHelper.obscureText;
                                });
                              },
                              obscureTextValue: _loginHelper.obscureText),
                          SizedBox(height: constraints.maxHeight * 0.02),
                          SignInButton(loginHelper: _loginHelper),
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
