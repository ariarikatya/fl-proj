import 'package:flutter/foundation.dart';
import 'package:shared/src/dev/json_equatable.dart';

class ChatPreview extends JsonEquatable {
  const ChatPreview({
    required this.id,
    required this.otherUserId,
    required this.unreadCount,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.lastMessage,
    required this.isOnline,
    required this.isTyping,
    required super.json,
  });

  factory ChatPreview.fromJson(Map<String, dynamic> json) => ChatPreview(
    id: json['id'] as int,
    otherUserId: json['other_user_id'] as int,
    unreadCount: json['unread_count'] as int,
    otherUserName: json['other_user_name'] as String,
    otherUserAvatar: json['other_user_avatar'] as String,
    lastMessage: json['last_message'] as String?,
    isOnline: json['is_online'] as bool,
    isTyping: false,
    json: json,
  );

  final int id, otherUserId, unreadCount;
  final String otherUserName, otherUserAvatar;
  final String? lastMessage;
  final bool isOnline, isTyping;

  @override
  List<Object?> get props => [
    id,
    otherUserId,
    unreadCount,
    otherUserName,
    otherUserAvatar,
    lastMessage,
    isOnline,
    isTyping,
  ];

  ChatPreview copyWith({
    ValueGetter<int>? id,
    ValueGetter<int>? otherUserId,
    ValueGetter<int>? unreadCount,
    ValueGetter<String>? otherUserName,
    ValueGetter<String>? otherUserAvatar,
    ValueGetter<String?>? lastMessage,
    ValueGetter<bool>? isOnline,
    ValueGetter<bool>? isTyping,
  }) => ChatPreview(
    id: id != null ? id() : this.id,
    otherUserId: otherUserId != null ? otherUserId() : this.otherUserId,
    unreadCount: unreadCount != null ? unreadCount() : this.unreadCount,
    otherUserName: otherUserName != null ? otherUserName() : this.otherUserName,
    otherUserAvatar: otherUserAvatar != null ? otherUserAvatar() : this.otherUserAvatar,
    lastMessage: lastMessage != null ? lastMessage() : this.lastMessage,
    isOnline: isOnline != null ? isOnline() : this.isOnline,
    isTyping: isTyping != null ? isTyping() : this.isTyping,
    json: json,
  );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'other_user_id': otherUserId,
    'unread_count': unreadCount,
    'other_user_name': otherUserName,
    'other_user_avatar': otherUserAvatar,
    'last_message': lastMessage,
    'is_online': isOnline,
    'is_typing': isTyping,
  };
}
