import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
import 'package:hello_nitr/models/login.dart';
import 'package:hello_nitr/screens/sim/widgets/error_dialog.dart';
import 'package:hello_nitr/screens/sim/widgets/loading_indicator.dart';
import 'package:hello_nitr/screens/sim/widgets/no_sim_card_widget.dart';
import 'package:hello_nitr/screens/sim/widgets/sim_card_options.dart';
import 'package:simnumber/siminfo.dart';
import 'package:simnumber/sim_number.dart';
import 'package:hello_nitr/controllers/sim_selection_controller.dart';


class SimSelectionScreen extends StatefulWidget {
  @override
  _SimSelectionScreenState createState() => _SimSelectionScreenState();
}

class _SimSelectionScreenState extends State<SimSelectionScreen> {
  SimSelectionController _simSelectionController = SimSelectionController();
  SimInfo simInfo = SimInfo([]);
  String? _selectedSim;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    SimNumber.listenPhonePermission((isPermissionGranted) {
      if (isPermissionGranted) {
        _loadSimCards();
      } else {
        setState(() {
          _isLoading = false;
          _showErrorDialog('Permission to read SIM cards was denied.');
        });
      }
    });
  }

  Future<void> _loadSimCards() async {
    try {
      simInfo = await _simSelectionController.getAvailableSimCards();
      setState(() {
        _isLoading = false;
        if (simInfo.cards.isEmpty || simInfo.cards.first.phoneNumber == null || simInfo.cards.first.phoneNumber!.isEmpty) {
          // Handle the case where no SIM card or phone number is available
        } else {
          _selectedSim = simInfo.cards.first.phoneNumber; // Auto-select the first SIM card
        }
      });
    } on PlatformException catch (e) {
      _showErrorDialog("Failed to get SIM data: ${e.message}");
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _showErrorDialog("An unexpected error occurred: ${e.toString()}");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: _isLoading
          ? LoadingIndicator()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select the number verified with NITRis',
                  style: TextStyle(
                    fontSize: 17,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                simInfo.cards.isEmpty || simInfo.cards.first.phoneNumber == null || simInfo.cards.first.phoneNumber!.isEmpty
                    ? NoSimCardWidget()
                    : SimCardOptions(
                        simInfo: simInfo,
                        selectedSim: _selectedSim,
                        onSimSelected: (sim) {
                          setState(() {
                            _selectedSim = sim.phoneNumber;
                          });
                        },
                      ),
                SizedBox(height: 20),
                Container(
                  width: 140,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _selectedSim == null ? null : _onNextButtonPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedSim == null ? Colors.grey : AppColors.primaryColor,
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
              ],
            ),
    );
  }

  Future<void> _onNextButtonPressed() async {
    try {
      if (_selectedSim != null) {
        LoginResponse? currentUser = await LocalStorageService.getLoginResponse();

        if (_simSelectionController.validateSimSelection(_selectedSim!, currentUser?.mobile ?? "")) {
          // Navigate to OTP Verification Screen
        } else {
          _showErrorDialog('Selected SIM card does not match with the registered number.');
        }
      }
    } catch (e) {
      _showErrorDialog('An error occurred: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ErrorDialog(message: message);
      },
    );
  }
}
