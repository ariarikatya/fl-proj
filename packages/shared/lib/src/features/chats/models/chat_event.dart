import 'package:shared/shared.dart';

sealed class ChatEvent {
  ChatEvent({required this.senderId, required this.timestamp});

  // final int chatId;
  final int senderId;
  final DateTime timestamp;

  factory ChatEvent.fromJson(Map<String, dynamic> json) {
    if (json case <String, Object?>{'type': 'online', 'sender_id': int senderId, 'sent_at': String sentAt}) {
      final timestamp = DateTime.tryParse(sentAt)?.toUtc() ?? DateTime.now();
      return ChatEvent$Online(senderId: senderId, timestamp: timestamp, online: true);
    }

    if (json case <String, Object?>{'type': 'offline', 'sender_id': int senderId, 'sent_at': String sentAt}) {
      final timestamp = DateTime.tryParse(sentAt)?.toUtc() ?? DateTime.now();
      return ChatEvent$Online(senderId: senderId, timestamp: timestamp, online: false);
    }
    if (json case <String, Object?>{
      'type': 'typing',
      'sender_id': int senderId,
      'sent_at': String sentAt,
      'chat_id': int chatId,
      'typing': bool typing,
    }) {
      final timestamp = DateTime.tryParse(sentAt)?.toUtc() ?? DateTime.now();
      return ChatEvent$Typing(senderId: senderId, timestamp: timestamp, chatId: chatId, typing: typing);
    }

    if (json case <String, Object?>{
      'type': 'message_read',
      'chat_id': int chatId,
      'sender_id': int senderId,
      'sent_at': String sentAt,
    }) {
      final timestamp = DateTime.tryParse(sentAt)?.toUtc() ?? DateTime.now();
      return ChatEvent$MessageRead(
        chatId: chatId,
        senderId: senderId,
        timestamp: timestamp,
        // messageId: json['data']['reader_id'] as int,
      );
    }

    if (json case <String, Object?>{
      'type': 'message',
      'chat_id': int chatId,
      'sender_id': int senderId,
      'sent_at': String sentAt,
    }) {
      final timestamp = DateTime.tryParse(sentAt)?.toUtc() ?? DateTime.now();
      return ChatEvent$Message(
        chatId: chatId,
        senderId: senderId,
        timestamp: timestamp,
        message: ChatMessage.fromJson(json),
      );
    }

    throw Exception('Unknown chat event type: $json');
  }

  Map<String, dynamic> toJson();
}

final class ChatEvent$Online extends ChatEvent {
  ChatEvent$Online({required super.senderId, required super.timestamp, required this.online});

  final bool online;

  @override
  Map<String, dynamic> toJson() => {
    'type': online ? 'online' : 'offline',
    'sender_id': senderId,
    'sent_at': timestamp.toUtc().toJson(),
  };
}

final class ChatEvent$Typing extends ChatEvent {
  ChatEvent$Typing({required super.senderId, required super.timestamp, required this.chatId, required this.typing});

  final int chatId;
  final bool typing;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'typing',
    'sender_id': senderId,
    'sent_at': timestamp.toUtc().toJson(),
    'chat_id': chatId,
    'typing': typing,
  };
}

final class ChatEvent$MessageRead extends ChatEvent {
  ChatEvent$MessageRead({
    required this.chatId,
    required super.senderId,
    required super.timestamp,
    // required this.messageId,
  });

  final int chatId;
  // final int messageId;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'message_read',
    'chat_id': chatId,
    'sender_id': senderId,
    'sent_at': timestamp.toUtc().toJson(),
  };
}

final class ChatEvent$Message extends ChatEvent {
  ChatEvent$Message({required this.chatId, required super.senderId, required super.timestamp, required this.message});

  final int chatId;
  final ChatMessage message;

  @override
  Map<String, dynamic> toJson() => {'type': 'message', 'chat_id': chatId, ...message.toJson()..remove('type')};
}
