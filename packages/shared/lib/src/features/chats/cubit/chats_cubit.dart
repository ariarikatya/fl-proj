import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

/// Cubit for handling chats info and web_socket updates
class ChatsCubit extends Cubit<int> with SocketListenerMixin {
  ChatsCubit({required this.websockets, required this.chatsRepo, required this.userId, required this.profileRepository})
    : super(0) {
    loadChats(force: true);
    listenSockets(websockets);
  }

  @override
  void onSocketsMessage(json) {
    const chatTypes = ['online', 'offline', 'typing', 'message', 'message_read'];
    if (json case <String, Object?>{'type': String eventType, 'sender_id': int _}) {
      if (!chatTypes.contains(eventType)) return;
      final event = ChatEvent.fromJson(json);
      final chat = switch (event) {
        ChatEvent$Message(:final int chatId) => chats[chatId],
        ChatEvent$MessageRead(:final int chatId) => chats[chatId],
        ChatEvent$Typing(:final int chatId) => chats[chatId],
        ChatEvent$Online(:final int senderId) => chats.values.firstWhereOrNull(
          (chat) => chat.preview.otherUserId == senderId,
        ),
      };
      chat?.handleEvent(event);

      // Reload chats if message is received for a new chat
      if (event is ChatEvent$Message && chat == null) {
        loadChats(force: true);
      }
    }
  }

  @override
  void onSocketsReconnect() => loadChats(force: true);

  final int userId;
  Map<int, ChatController> chats = {};
  final WebSocketService websockets;
  final ChatsRepository chatsRepo;
  final ProfileRepository profileRepository;

  bool _loading = false;

  bool get loading => _loading;

  ChatController? maybeGetChatWithOtherUserId(int otherUserId) =>
      chats.values.firstWhereOrNull((chat) => chat.preview.otherUserId == otherUserId);

  @override
  Future<void> close() {
    unsubscribeSockets(websockets);
    return super.close();
  }

  Future<void> loadChats({bool force = false}) async {
    if (_loading) return;
    if (chats.isNotEmpty && !force) return;

    _loading = true;
    final result = await chatsRepo.getChats();
    result.when(
      ok: (data) {
        chats = {for (var chat in data) chat.id: chats[chat.id] ?? _createChat(chat)};
        emit(state + 1);
      },
      err: handleError,
    );
    _loading = false;
  }

  Future<ChatPreview?> startChat(int otherUserId, String message, {required bool withClient}) async {
    final result = await switch (withClient) {
      true => chatsRepo.startChatWithClient(otherUserId, message),
      false => chatsRepo.startChatWithMaster(otherUserId, message),
    };
    return result.when<ChatPreview?>(
      ok: (chat) {
        chats[chat.id] = _createChat(chat);
        return chat;
      },
      err: handleError,
    );
  }

  ChatController _createChat(ChatPreview chat) =>
      ChatController(preview: chat, userId: userId, chatsRepo: chatsRepo, websockets: websockets)..load();
}
