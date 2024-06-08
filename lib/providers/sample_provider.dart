//write sample provider to just return a string

import 'package:flutter/material.dart';

class SampleProvider extends ChangeNotifier {
  String _sampleString = 'Hello NITR';

  String get sampleString => _sampleString;

  void updateSampleString(String newString) {
    _sampleString = newString;
    notifyListeners();
  }
}