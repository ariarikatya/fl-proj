import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class ClientData {
  const ClientData({
    required this.phoneNumber,
    required this.tokens,
    required this.client,
    required void Function(Client client) onClientUpdate,
  }) : _onClientUpdate = onClientUpdate;

  final Client client;
  final String phoneNumber;
  final TokensPair tokens;

  final void Function(Client client) _onClientUpdate;

  void updateClient(Client Function(Client client) fn) => _onClientUpdate(fn(client));
}

class ClientScope extends InheritedWidget {
  const ClientScope({super.key, required this.clientData, required super.child});

  final ClientData clientData;

  static ClientData of(BuildContext context, {bool listen = true}) => ClientScope.maybeOf(context, listen: listen)!;

  static ClientData? maybeOf(BuildContext context, {bool listen = true}) {
    if (listen) {
      return context.dependOnInheritedWidgetOfExactType<ClientScope>()?.clientData;
    }
    return context.getInheritedWidgetOfExactType<ClientScope>()?.clientData;
  }

  @override
  bool updateShouldNotify(ClientScope oldWidget) => clientData.client != oldWidget.clientData.client;
}
