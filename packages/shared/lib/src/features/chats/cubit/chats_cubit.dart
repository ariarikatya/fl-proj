import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

/// Cubit for handling chats info and web_socket updates
class ChatsCubit extends Cubit<int> {
  ChatsCubit({required this.websockets, required this.chatsRepo, required this.userId, required this.profileRepository})
    : super(0) {
    loadChats(force: true);
    websockets.addListener(_listener);
    websockets.addOnConnectedListener(_onConnectedListener);
  }

  final int userId;
  Map<int, ChatController> chats = {};
  final WebSocketService websockets;
  final ChatsRepository chatsRepo;
  final ProfileRepository profileRepository;

  bool _loading = false;

  bool get loading => _loading;

  ChatController? maybeGetChatWithMasterId(int masterId) =>
      chats.values.firstWhereOrNull((chat) => chat.preview.otherUserId == masterId);

  void _onConnectedListener() => loadChats(force: true);

  void _listener(dynamic message) {
    try {
      final json = jsonDecode(message.toString());
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
    } catch (e) {
      logger.error('Unable to parse socket message: $message', e);
    }
  }

  @override
  Future<void> close() {
    websockets.removeListener(_listener);
    websockets.removeOnConnectedListener(_onConnectedListener);
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

  Future<ChatPreview?> startChat(int masterId, String message) async {
    final result = await chatsRepo.startChat(masterId, message);
    return result.when<ChatPreview?>(
      ok: (chat) {
        chats[chat.id] = _createChat(chat);
        return chat;
      },
      err: (_, __) => null,
    );
  }

  ChatController _createChat(ChatPreview chat) =>
      ChatController(preview: chat, userId: userId, chatsRepo: chatsRepo, websockets: websockets)..load();
}
