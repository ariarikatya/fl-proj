import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class ClientViewModel extends ChangeNotifier {
  ClientViewModel({required this.phoneNumber, required this.client});

  Client client;
  String phoneNumber;

  void updateClient(Client client) {
    this.client = client;
    notifyListeners();
  }
}
