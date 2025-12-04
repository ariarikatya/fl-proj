import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class MasterModel extends ChangeNotifier {
  MasterModel({required this.master, required this.phoneNumber});

  Master master;
  String phoneNumber;

  void updateMaster(Master $master) {
    master = $master;
    notifyListeners();
  }
}
