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
    int validSimCount = simInfo.cards.where((sim) {
      bool isPhoneNumberValid = sim.phoneNumber != null && sim.phoneNumber!.trim().isNotEmpty && sim.phoneNumber!.length >= 10;
      bool isCarrierNameValid = sim.carrierName != null && sim.carrierName!.trim().isNotEmpty;
      return isPhoneNumberValid && isCarrierNameValid;
    }).length;

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(), // Prevents GridView from scrolling independently
      itemCount: validSimCount + (validSimCount == 1 ? 1 : 0), // Add one for the manual entry tile if only one SIM card is valid
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of columns in the grid
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 3 / 3.5, // Aspect ratio for the tiles
      ),
      itemBuilder: (context, index) {
        if (index < validSimCount) {
          SimCard sim = simInfo.cards.where((sim) {
            bool isPhoneNumberValid = sim.phoneNumber != null && sim.phoneNumber!.trim().isNotEmpty && sim.phoneNumber!.length >= 10;
            bool isCarrierNameValid = sim.carrierName != null && sim.carrierName!.trim().isNotEmpty;
            return isPhoneNumberValid && isCarrierNameValid;
          }).toList()[index];

          return GestureDetector(
            onTap: () {
              onSimSelected(sim);
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
        } else {
          // Manual entry tile
          return GestureDetector(
            onTap: onManualEntryTap,
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
                    'Enter manually',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
