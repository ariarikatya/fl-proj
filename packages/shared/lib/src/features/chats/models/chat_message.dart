import 'package:flutter/foundation.dart';
import 'package:shared/src/dev/json_equatable.dart';
import 'package:shared/src/extensions/datetime.dart';

class ChatMessage extends JsonEquatable {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.contentType,
    required this.status,
    required this.sentAt,
    required this.isOwnMessage,
    this.attachments = const [],
    this.fileUrl,
    super.json,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: (json['id'] ?? json['message_id']) as int,
    senderId: json['sender_id'] as int,
    content: json['content'] as String,
    contentType: json['type'] as String,
    status: json['status'] as String,
    sentAt: DateTime.parse(json['sent_at'] as String),
    isOwnMessage: json['is_own_message'] as bool,
    attachments: (json['attachments'] as List?)?.cast<String>() ?? [],
    fileUrl: (json['file_url'] ?? json['data']?['file_url']) as String?,
    json: json,
  );

  final int id, senderId;
  final String content, contentType, status;
  final DateTime sentAt;
  final bool isOwnMessage;
  final String? fileUrl;
  final List<String> attachments;

  @override
  List<Object?> get props => [id, senderId, content, contentType, status, sentAt, isOwnMessage, attachments];

  ChatMessage copyWith({
    ValueGetter<int>? id,
    ValueGetter<int>? senderId,
    ValueGetter<String>? content,
    ValueGetter<String>? contentType,
    ValueGetter<String>? status,
    ValueGetter<DateTime>? sentAt,
    ValueGetter<bool>? isOwnMessage,
    ValueGetter<List<String>>? attachments,
    ValueGetter<String>? fileUrl,
  }) => ChatMessage(
    id: id != null ? id() : this.id,
    senderId: senderId != null ? senderId() : this.senderId,
    content: content != null ? content() : this.content,
    contentType: contentType != null ? contentType() : this.contentType,
    status: status != null ? status() : this.status,
    sentAt: sentAt != null ? sentAt() : this.sentAt,
    isOwnMessage: isOwnMessage != null ? isOwnMessage() : this.isOwnMessage,
    attachments: attachments != null ? attachments() : this.attachments,
    fileUrl: fileUrl != null ? fileUrl() : this.fileUrl,
    json: json,
  );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'sender_id': senderId,
    'content': content,
    'type': contentType,
    'status': status,
    'sent_at': sentAt.toUtc().toJson(),
    'is_own_message': isOwnMessage,
    if (attachments.isNotEmpty) 'attachments': attachments,
    'file_url': ?fileUrl,
  };
}
