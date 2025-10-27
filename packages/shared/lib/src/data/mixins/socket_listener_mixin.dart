import 'dart:convert';

import 'package:shared/src/features/chats/web_socket_service.dart';
import 'package:shared/src/logger.dart';

mixin SocketListenerMixin {
  void onSocketsMessage(dynamic json);

  void onSocketsReconnect();

  void listenSockets(WebSocketService service) {
    service.addListener(_listener);
    service.addOnConnectedListener(onSocketsReconnect);
  }

  void unsubscribeSockets(WebSocketService service) {
    service.removeListener(_listener);
    service.removeOnConnectedListener(onSocketsReconnect);
  }

  void _listener(dynamic message) {
    try {
      final json = jsonDecode(message.toString());
      onSocketsMessage(json);
    } catch (e) {
      logger.error('Unable to parse socket message: $message', e);
    }
  }
}
