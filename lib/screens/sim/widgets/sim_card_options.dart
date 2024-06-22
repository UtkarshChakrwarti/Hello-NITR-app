import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:simnumber/siminfo.dart';

class SimCardOptions extends StatelessWidget {
  final SimInfo simInfo;
  final String? selectedSim;
  final Function(SimCard) onSimSelected;

  SimCardOptions({required this.simInfo, required this.selectedSim, required this.onSimSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: simInfo.cards.map((sim) {
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
                  sim.phoneNumber?.substring(sim.phoneNumber!.length - 10) ?? '',
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
      }).toList(),
    );
  }
}
