import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:simnumber/siminfo.dart';

class SimCardOptions extends StatelessWidget {
  final SimInfo simInfo;
  final String? selectedSim;
  final Function(SimCard) onSimSelected;
  final VoidCallback onManualEntryTap;

  SimCardOptions({
    required this.simInfo,
    required this.selectedSim,
    required this.onSimSelected,
    required this.onManualEntryTap,
  });

  @override
  Widget build(BuildContext context) {
    List<SimCard> validSims = [];
    bool isSim1Detected = false;
    bool isSim2Detected = false;

    try {
      validSims = simInfo.cards.where((sim) {
        bool isPhoneNumberValid = sim.phoneNumber != null && sim.phoneNumber!.trim().isNotEmpty && sim.phoneNumber!.length >= 10;
        bool isCarrierNameValid = sim.carrierName != null && sim.carrierName!.trim().isNotEmpty;
        return isPhoneNumberValid && isCarrierNameValid;
      }).toList();

      isSim1Detected = validSims.any((sim) => sim.slotIndex == 0);
      isSim2Detected = validSims.any((sim) => sim.slotIndex == 1);
    } catch (e) {
      print('Error processing SIM info: $e');
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 2, // Always two tiles: one for each SIM slot.
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 3 / 3.5,
      ),
      itemBuilder: (context, index) {
        try {
          if (index == 0) {
            if (isSim1Detected) {
              SimCard sim = validSims.firstWhere((sim) => sim.slotIndex == 0);
              return _buildSimCardTile(sim, context);
            } else {
              return _buildManualEntryTile("SIM 1 Details Not Found!");
            }
          } else {
            if (isSim2Detected) {
              SimCard sim = validSims.firstWhere((sim) => sim.slotIndex == 1);
              return _buildSimCardTile(sim, context);
            } else {
              return _buildManualEntryTile("SIM 2 Details Not Found!");
            }
          }
        } catch (e) {
          return _buildErrorTile('Error displaying SIM card options');
        }
      },
    );
  }

  Widget _buildSimCardTile(SimCard sim, BuildContext context) {
    return GestureDetector(
      onTap: () {
        try {
          onSimSelected(sim);
        } catch (e) {
          print('Error selecting SIM card: $e');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: selectedSim == sim.phoneNumber ? AppColors.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primaryColor),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sim_card, color: AppColors.primaryColor, size: 40),
            SizedBox(height: 10),
            Text(
              'SIM ${sim.slotIndex! + 1}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              sim.phoneNumber != null && sim.phoneNumber!.length >= 10
                  ? sim.phoneNumber!.substring(sim.phoneNumber!.length - 10)
                  : '',
              style: const TextStyle(fontSize: 15, color: AppColors.primaryColor),
            ),
            const SizedBox(height: 5),
            Text(
              sim.carrierName ?? '',
              style: const TextStyle(fontSize: 12, color: AppColors.primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualEntryTile(String message) {
    return GestureDetector(
      onTap: () {
        try {
          onManualEntryTap();
        } catch (e) {
          print('Error on manual entry tap: $e');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primaryColor),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit, color: AppColors.primaryColor, size: 40),
            SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5),
            Text(
              'Enter manually',
              style: TextStyle(fontSize: 12, color: AppColors.primaryColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorTile(String errorMessage) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red, size: 40),
          SizedBox(height: 10),
          Text(
            errorMessage,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
