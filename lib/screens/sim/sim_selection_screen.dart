import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hello_nitr/controllers/sim_selection_controller.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
import 'package:hello_nitr/models/login.dart';
import 'package:hello_nitr/screens/otp/otp_verification_screen.dart';
import 'package:hello_nitr/screens/sim/widgets/error_dialog.dart';
import 'package:hello_nitr/screens/sim/widgets/loading_indicator.dart';
import 'package:hello_nitr/screens/sim/widgets/no_sim_card_widget.dart';
import 'package:logging/logging.dart';

class SimSelectionScreen extends StatefulWidget {
  const SimSelectionScreen({super.key});

  @override
  _SimSelectionScreenState createState() => _SimSelectionScreenState();
}

class _SimSelectionScreenState extends State<SimSelectionScreen>
    with SingleTickerProviderStateMixin {
  final SimSelectionController _simSelectionController =
      SimSelectionController();
  final Logger _logger = Logger('SimSelectionScreen');
  String? _selectedSim;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isNextButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _lockOrientationToPortrait();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // Load the screen with manual entry as default
    setState(() {
      _isLoading = false;
    });

    _logger.info('SimSelectionScreen initialized');
  }

  void _lockOrientationToPortrait() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void _resetOrientation() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  @override
  void dispose() {
    _resetOrientation();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: _isLoading
            ? const LoadingIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter the number verified with NITRis',
                    style: TextStyle(
                      fontSize: 17,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  NoSimCardWidget(
                    onPhoneNumberChanged: _onPhoneNumberChanged,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 140,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          _isNextButtonEnabled ? _onNextButtonPressed : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isNextButtonEnabled
                            ? AppColors.primaryColor
                            : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              'NEXT',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                      height:
                          300), // Add space by default because ios only have manual entry
                ],
              ),
      ),
    );
  }

  void _onPhoneNumberChanged(String phoneNumber) {
    setState(() {
      _selectedSim = phoneNumber;
      _isNextButtonEnabled = phoneNumber.length == 10;
    });
  }

  Future<void> _onNextButtonPressed() async {
    try {
      if (_selectedSim != null) {
        LoginResponse? currentUser =
            await LocalStorageService.getLoginResponse();
        _logger.info(
            "Selected SIM: $_selectedSim, Current user: ${currentUser?.mobile}");

        if (_simSelectionController.validateSimSelection(
            _selectedSim!, currentUser?.mobile ?? "")) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                mobileNumber: _selectedSim!,
              ),
            ),
          );
        } else {
          _showErrorDialog(
              'Entered phone number does not match with the registered number.');
        }
      }
    } catch (e) {
      _logger.severe(
          "An error occurred during phone number validation: ${e.toString()}",
          e);
      _showErrorDialog('An error occurred: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    _logger.warning("Showing error dialog: $message");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ErrorDialog(message: message);
      },
    );
  }
}
