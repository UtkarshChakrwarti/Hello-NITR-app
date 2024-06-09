import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
import 'package:hello_nitr/models/login.dart';
import 'package:simnumber/siminfo.dart';
import 'package:simnumber/sim_number.dart';
import 'package:hello_nitr/controllers/sim_selection_controller.dart';
import 'package:flutter/cupertino.dart';

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
        if (simInfo.cards.isEmpty ||
            simInfo.cards.first.phoneNumber == null ||
            simInfo.cards.first.phoneNumber!.isEmpty) {
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
          ? Center(child: CircularProgressIndicator())
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
                simInfo.cards.isEmpty ||
                        simInfo.cards.first.phoneNumber == null ||
                        simInfo.cards.first.phoneNumber!.isEmpty
                    ? _buildNoSimCardWidget()
                    : _buildSimCardOptions(),
                SizedBox(height: 20),
                Container(
                  width: 140,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _selectedSim == null
                        ? null
                        : () async {
                            try {
                              if (_selectedSim != null) {
                                LoginResponse? currentUser =
                                    await LocalStorageService.getLoginResponse();

                                if (_simSelectionController.validateSimSelection(
                                    _selectedSim!, currentUser?.mobile ?? "")) {
                                  // Navigator.push(
                                  //   context,
                                    // MaterialPageRoute(
                                    //   builder: (context) =>
                                    //       OtpVerificationScreen(
                                    //     mobileNumber: _selectedSim!,
                                    //   ),
                                    // ),
                                  // );
                                } else {
                                  _showErrorDialog(
                                      'Selected SIM card does not match with the registered number.');
                                }
                              }
                            } catch (e) {
                              _showErrorDialog('An error occurred: ${e.toString()}');
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedSim == null
                          ? Colors.grey
                          : AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: Row(
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

  Widget _buildSimCardOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: simInfo.cards.map((sim) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedSim = sim.phoneNumber;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: _selectedSim == sim.phoneNumber
                  ? AppColors.primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryColor),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(Icons.sim_card, color: AppColors.primaryColor, size: 40),
                SizedBox(height: 10),
                Text(
                  'SIM ${sim.slotIndex! + 1}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  sim.phoneNumber ?? '',
                  style: TextStyle(fontSize: 14, color: AppColors.primaryColor),
                ),
                SizedBox(height: 5),
                Text(
                  sim.carrierName ?? '',
                  style: TextStyle(fontSize: 10, color: AppColors.primaryColor),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNoSimCardWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryColor),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(Icons.sim_card_alert, color: AppColors.primaryColor, size: 50),
          SizedBox(height: 10),
          Text(
            "SIM card not found",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Row(
            children: [
              Icon(Icons.error, color: AppColors.primaryColor),
              SizedBox(width: 10),
              Text(
                'Error',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
