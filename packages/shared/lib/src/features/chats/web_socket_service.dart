import 'dart:async';

import 'package:shared/shared.dart';
import 'package:web_socket_channel/io.dart';

abstract class WebSocketService {
  WebSocketService({required this.getToken});

  final Future<String?> Function() getToken;

  Future<void> connect();
  Future<void> disconnect();

  void addListener(void Function(dynamic data) listener);
  void removeListener(void Function(dynamic data) listener);

  void addOnConnectedListener(void Function() listener);
  void removeOnConnectedListener(void Function() listener);

  void send(dynamic data);
}

final class WebSocketService$IOImpl extends WebSocketService {
  WebSocketService$IOImpl({required this.url, required super.getToken});

  IOWebSocketChannel? channel;
  Stream? _broadcast;
  final String url;

  final Set<void Function(dynamic data)> _listeners = {};
  final Set<void Function()> _reconnectListeners = {};

  bool _connecting = false;
  bool _reconnetingEnabled = true; // Required for disabling reconnects when disconnected manually

  void _listener(dynamic data) {
    logger.debug('[sockets] logevent: $data');
    for (var listener in _listeners) {
      listener(data);
    }
  }

  @override
  Future<void> connect() async {
    _reconnetingEnabled = true;
    if (_connecting) {
      logger.warning('[sockets] already connecting, skipping');
      return;
    }
    _connecting = true;
    channel?.sink.close();

    final token = await getToken();
    logger.info('[sockets] connecting..., token: $token');
    channel = IOWebSocketChannel.connect(
      url,
      headers: {'Authorization': 'Bearer $token'},
      pingInterval: const Duration(seconds: 10),
      connectTimeout: const Duration(seconds: 15),
    );

    try {
      await channel!.ready;
    } catch (e, st) {
      logger.error('[sockets] error connecting', e, st);
      await Future.delayed(const Duration(seconds: 10));
      _reconnect();
    }

    _connecting = false;
    logger.info('[sockets] connected, listening for messages');
    _broadcast = channel!.stream.asBroadcastStream();

    for (var listener in _reconnectListeners) {
      listener();
    }

    _broadcast!.listen(
      _listener,
      onDone: () {
        logger.warning('[sockets] onDone called: ${channel?.closeCode}, ${channel?.closeReason}');
        _reconnect();
      },
      onError: (e, st) => handleError(e, st, false),
      cancelOnError: false,
    );
  }

  void _reconnect() {
    if (!_reconnetingEnabled) return logger.warning('[sockets] reconnecting disabled');
    logger.info('[sockets] reconnecting...');
    connect();
  }

  @override
  Future<void> disconnect() async {
    _reconnetingEnabled = false;
    if (channel == null) return;
    logger.warning('[sockets] disconnecting manually...');
    await channel?.sink.close();
    logger.warning('[sockets] disconnected manually');
  }

  @override
  void send(data) {
    logger.info('[sockets] sending: $data');
    channel!.sink.add(data);
  }

  @override
  void addListener(void Function(dynamic data) listener) => _listeners.add(listener);

  @override
  void removeListener(void Function(dynamic data) listener) => _listeners.remove(listener);

  @override
  void addOnConnectedListener(void Function() listener) => _reconnectListeners.add(listener);

  @override
  void removeOnConnectedListener(void Function() listener) => _reconnectListeners.remove(listener);
}
