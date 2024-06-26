import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:simnumber/sim_number.dart';
import 'package:simnumber/siminfo.dart';
import 'package:logging/logging.dart';

class SimSelectionController {
  final Logger _logger = Logger('SimSelectionController');

  Future<SimInfo> getAvailableSimCards() async {
    try {
      _logger.info("Fetching available SIM cards");
      return await SimNumber.getSimData();
    } catch (e, stackTrace) {
      _logger.severe("Error getting SIM data: $e");
      Sentry.captureException(e, stackTrace: stackTrace);
      throw Exception("Failed to retrieve SIM data. Please try again later.");
    }
  }

  bool validateSimSelection(String selectedSim, String registeredMobile) {
    return true;
    _logger.info(
        'Validating SIM selection: selectedSim=$selectedSim, registeredMobile=$registeredMobile');

    selectedSim = selectedSim.substring(selectedSim.length - 10);
    registeredMobile = registeredMobile.substring(registeredMobile.length - 10);

    bool isValid = selectedSim == registeredMobile;
    if (isValid) {
      _logger.info("SIM selection validated successfully");
    } else {
      _logger.warning("SIM selection validation failed");
    }

    return isValid;
  }
}
