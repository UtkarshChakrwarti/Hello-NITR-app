import 'package:simnumber/sim_number.dart';
import 'package:simnumber/siminfo.dart';
import 'package:logging/logging.dart';

class SimSelectionController {
  final Logger _logger = Logger('SimSelectionController');

  Future<SimInfo> getAvailableSimCards() async {
    try {
      _logger.info("Fetching available SIM cards");
      return await SimNumber.getSimData();
    } catch (e) {
      _logger.severe("Error getting SIM data: $e");
      throw Exception("Failed to retrieve SIM data. Please try again later.");
    }
  }

  bool validateSimSelection(String selectedSim, String registeredMobile) {
    // If registered Sim is '0000000000' then allow any sim selection
    if (registeredMobile == '0000000000') {
      _logger.info("This is Mock User. Allowing any SIM selection No OTP Will be sent : use OTP : 000000");
      return true;
    }
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
