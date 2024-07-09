import 'package:logging/logging.dart';

class SimSelectionController {
  final Logger _logger = Logger('SimSelectionController');

  bool validateSimSelection(String selectedSim, String registeredMobile) {
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
