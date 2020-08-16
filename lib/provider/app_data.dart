import 'package:flutter/material.dart';

class AppData extends ChangeNotifier {
  Widget timePicker;
  bool isPaused = false;

  togglePauseButton() {
    isPaused ? isPaused = false : isPaused = true;
    notifyListeners();
  }
}
