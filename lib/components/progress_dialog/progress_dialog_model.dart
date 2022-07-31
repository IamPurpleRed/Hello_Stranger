import 'package:flutter/material.dart';

class ProgressDialogModel extends ChangeNotifier {
  double value;
  String detailedProgress;

  ProgressDialogModel(this.value, this.detailedProgress);

  void update(double newValue, String newDetailedProgress) {
    value = newValue;
    detailedProgress = newDetailedProgress;
    notifyListeners();
  }
}
