import 'package:simnumber/sim_number.dart';
import 'package:simnumber/siminfo.dart';

class SimSelectionController {

  Future<SimInfo> getAvailableSimCards() async {
    try {
      return await SimNumber.getSimData();
    } catch (e) {
      // Handle any exceptions that occur during the SIM data retrieval
      print("Error getting SIM data: $e");
      throw Exception("Failed to retrieve SIM data. Please try again later.");
    }
  }

  // Selected SIM is valid or not also match de
  bool validateSimSelection(String selectedSim, String registeredMobile) {
    

    //First check selected sim is from India or not
    if (!selectedSim.startsWith("+91") && !selectedSim.startsWith("91")) {
      print("Selected SIM is not from India");
      return false;
    }

    //Then check selected sim is same as registered mobile number
    //For simplicity, we are checking only last 10 digits
    selectedSim = selectedSim.substring(selectedSim.length - 10);
    registeredMobile = registeredMobile.substring(registeredMobile.length - 10);

    return selectedSim == registeredMobile;


  }
}
