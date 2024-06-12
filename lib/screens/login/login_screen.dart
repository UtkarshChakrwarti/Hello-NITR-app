import 'package:flutter/material.dart';
import 'package:hello_nitr/controllers/login_controller.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/core/constants/app_constants.dart';
import 'package:hello_nitr/core/utils/dialogs_and_prompts.dart';
import 'package:hello_nitr/providers/login_provider.dart';
import 'package:hello_nitr/screens/terms_and_conditions/terms_and_conditions_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
        return await _showExitConfirmationDialog(context) ?? false;
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
                          _buildWelcomeText(),
                          SizedBox(height: constraints.maxHeight * 0.03),
                          _buildTextField(
                              _usernameController,
                              "Username",
                              Icons.person_2_outlined,
                              false,
                              _usernameFocusNode),
                          SizedBox(height: constraints.maxHeight * 0.01),
                          _buildTextField(
                              _passwordController,
                              "Password",
                              Icons.lock_clock_outlined,
                              true,
                              _passwordFocusNode),
                          SizedBox(height: constraints.maxHeight * 0.02),
                          ValueListenableBuilder<bool>(
                            valueListenable: _allFieldsFilled,
                            builder: (context, value, child) {
                              return GestureDetector(
                                onTapDown: (_) =>
                                    _animationController.forward(),
                                onTapUp: (_) => _animationController.reverse(),
                                child: AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _buttonScaleAnimation.value,
                                      child: _buildSignInButton(value
                                          ? AppColors.primaryColor
                                          : AppColors.lightSecondaryColor),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          SizedBox(height: constraints.maxHeight * 0.05),
                          _buildTermsText(),
                        ],
                      ),
                      SizedBox(height: constraints.maxHeight * 0.02),
                      _buildFooter(),
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

  Row _buildWelcomeText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text("Welcome to",
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                    fontFamily: 'Roboto')),
            Text("Hello NITR",
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                    fontFamily: 'Roboto')),
            Text("v 2.0",
                style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryColor,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  TextField _buildTextField(TextEditingController controller, String hintText,
      IconData icon, bool obscureText, FocusNode focusNode) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText && hintText == "Password" ? _obscureText : false,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primaryColor),
        suffixIcon: hintText == "Password"
            ? IconButton(
                icon: Icon(
                    _obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.primaryColor),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        hintText: hintText,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.black26, width: 2.0)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0)),
      ),
    );
  }

  ElevatedButton _buildSignInButton(Color buttonColor) {
    return ElevatedButton(
      onPressed: _allFieldsFilled.value
          ? () async {
              final loginProvider = context.read<LoginProvider>();
              try {
                _animationController.forward();
                final isSuccess = await loginProvider.login(
                    _usernameController.text,
                    _passwordController.text,
                    context);
                if (!isSuccess) {
                  if (!loginProvider.isAllowedToLogin &&
                      !loginProvider.invalidUserNameOrPassword) {
                    DialogsAndPrompts.showLoginFromDifferentDeviceDialog(
                        context);
                  } else {
                    _showErrorDialog('Invalid username or password', context);
                  }
                } else {
                  //make sure unfocus text fields is called before opening the modal
                  _usernameFocusNode.unfocus();
                  _passwordFocusNode.unfocus();
                  //Open the Sim selection screen
                  LoginController().showSimSelectionModal(context);
                }
              } catch (e, stacktrace) {
                // Log the error and stack trace to a monitoring service or console
                debugPrint('Login error: $e\n$stacktrace');
                _showErrorDialog(
                    'An error occurred. Please try again.', context);
              } finally {
                _animationController.reverse();
              }
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
                    fontSize: 18, color: Colors.white, fontFamily: 'Roboto'),
                key: ValueKey('text')),
      ),
    );
  }

  Column _buildTermsText() {
    return Column(
      children: [
        const Text("By signing in, you agree to our ",
            style: TextStyle(
                fontSize: 14, color: Colors.black, fontFamily: 'Roboto'),
            textAlign: TextAlign.center),
        GestureDetector(
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => TermsAndConditionsScreen())),
          child: Text("Terms and Conditions",
              style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 14,
                  decoration: TextDecoration.underline)),
        ),
      ],
    );
  }

  Column _buildFooter() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("\u{00A9} NIT Rourkela 2024 \nDesigned and Developed by ",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14, color: Colors.black, fontFamily: 'Roboto')),
        GestureDetector(
          onTap: () => _launchURL(AppConstants.catUrl, context),
          child: Text("Centre for Automation Technology",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  decoration: TextDecoration.underline)),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> _launchURL(String url, BuildContext context) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch $url: $e',
              style: const TextStyle(color: Colors.white)),
          backgroundColor: AppColors.primaryColor,
        ),
      );
    }
  }

  Future<bool?> _showExitConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Row(
            children: [
              Icon(Icons.exit_to_app, color: AppColors.primaryColor),
              const SizedBox(width: 10),
              Text('Exit',
                  style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text('Are you sure you want to exit?',
              style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              child: Text('No',
                  style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Yes',
                  style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Row(
            children: [
              Icon(Icons.error, color: AppColors.primaryColor),
              const SizedBox(width: 10),
              Text('Error',
                  style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(message, style: const TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              child: Text('OK',
                  style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
