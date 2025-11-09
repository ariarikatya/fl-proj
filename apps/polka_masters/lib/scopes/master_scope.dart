import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class MasterScope extends ChangeNotifier {
  MasterScope({required this.master, required this.schedule, required this.phoneNumber});

  Master master;
  Schedule schedule;
  String phoneNumber;

  void updateMaster(Master $master) {
    master = $master;
    notifyListeners();
  }

  void updateSchedule(Schedule $schedule) {
    schedule = $schedule;
    notifyListeners();
  }
}
