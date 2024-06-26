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
import 'package:hello_nitr/screens/sim/widgets/sim_card_options.dart';
import 'package:simnumber/sim_number.dart';
import 'package:simnumber/siminfo.dart';
import 'package:logging/logging.dart';

class SimSelectionScreen extends StatefulWidget {
  @override
  _SimSelectionScreenState createState() => _SimSelectionScreenState();
}

class _SimSelectionScreenState extends State<SimSelectionScreen>
    with SingleTickerProviderStateMixin {
  final SimSelectionController _simSelectionController = SimSelectionController();
  final Logger _logger = Logger('SimSelectionScreen');
  SimInfo simInfo = SimInfo([]);
  String? _selectedSim;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isNextButtonEnabled = false;
  bool _noSimCardAvailable = false;
  bool _manualEntry = false;

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

    SimNumber.listenPhonePermission((isPermissionGranted) {
      if (isPermissionGranted) {
        _loadSimCards();
      } else {
        setState(() {
          _isLoading = false;
          _noSimCardAvailable = true;
        });
        _showErrorDialog('Permission to read SIM cards was denied.');
      }
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

  Future<void> _loadSimCards() async {
    try {
      simInfo = await _simSelectionController.getAvailableSimCards();
      _logger.info("SIM cards loaded: ${simInfo.cards}");
      setState(() {
        _isLoading = false;
        _noSimCardAvailable = simInfo.cards.isEmpty ||
            simInfo.cards.first.phoneNumber == null ||
            simInfo.cards.first.phoneNumber!.isEmpty;

        if (!_noSimCardAvailable) {
          // Automatically select the first valid SIM card
          SimCard firstValidSim = simInfo.cards.firstWhere(
              (sim) => sim.phoneNumber != null && sim.phoneNumber!.length >= 10 && sim.carrierName != null && sim.carrierName!.isNotEmpty,
              orElse: () => simInfo.cards.first);
          _selectedSim = firstValidSim.phoneNumber;
          _isNextButtonEnabled = true;
        }
      });
    } on PlatformException catch (e) {
      _logger.severe("Failed to get SIM data: ${e.message}", e);
      _showErrorDialog("Failed to get SIM data: ${e.message}");
      setState(() {
        _isLoading = false;
        _noSimCardAvailable = true;
      });
    } catch (e) {
      _logger.severe("An unexpected error occurred: ${e.toString()}", e);
      _showErrorDialog("An unexpected error occurred: ${e.toString()}");
      setState(() {
        _isLoading = false;
        _noSimCardAvailable = true;
      });
    }
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
            ? LoadingIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select the number verified with NITRis',
                    style: TextStyle(
                      fontSize: 17,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _manualEntry
                      ? NoSimCardWidget(
                          onPhoneNumberChanged: _onPhoneNumberChanged,
                        )
                      : (_noSimCardAvailable
                          ? NoSimCardWidget(
                              onPhoneNumberChanged: _onPhoneNumberChanged,
                            )
                          : SimCardOptions(
                              simInfo: simInfo,
                              selectedSim: _selectedSim,
                              onSimSelected: (sim) {
                                setState(() {
                                  _selectedSim = sim.phoneNumber;
                                  _isNextButtonEnabled = true; // Enable the next button when a SIM is selected
                                });
                              },
                              onManualEntryTap: () {
                                setState(() {
                                  _selectedSim = null;
                                  _isNextButtonEnabled = false; // Disable the next button
                                  _manualEntry = true;
                                });
                              },
                            )),
                  const SizedBox(height: 20),
                  Container(
                    width: 140,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isNextButtonEnabled ? _onNextButtonPressed : null,
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
                  if (_noSimCardAvailable || _manualEntry) const SizedBox(height: 300), // Add space only if no SIM card is available or in manual entry mode
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
        LoginResponse? currentUser = await LocalStorageService.getLoginResponse();
        _logger.info("Selected SIM: $_selectedSim, Current user: ${currentUser?.mobile}");

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
      _logger.severe("An error occurred during phone number validation: ${e.toString()}", e);
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
