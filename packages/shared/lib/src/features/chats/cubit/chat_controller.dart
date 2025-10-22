import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared/shared.dart';

class ChatController extends PaginationCubit<ChatMessage> with ChangeNotifier {
  ChatController({
    required this.preview,
    required this.userId,
    required this.chatsRepo,
    required this.websockets,
    super.limit = 20,
  }) {
    websockets.addOnConnectedListener(_resetIfOpened);
  }

  final int userId;
  final WebSocketService websockets;
  final ChatsRepository chatsRepo;
  ChatPreview preview;
  bool _opened = false;

  void sendEvent(ChatEvent event) => websockets.send(jsonEncode(event.toJson()));

  void _resetIfOpened() {
    if (_opened) reset();
  }

  @override
  Future<void> close() {
    dispose();
    websockets.removeOnConnectedListener(_resetIfOpened);
    return super.close();
  }

  @override
  Future<Result<List<ChatMessage>>> loadItems(int page, int limit) {
    return chatsRepo.getChatHistory(preview.id, limit: limit, offset: (page - 1) * limit);
  }

  void onChatOpened() {
    _opened = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _readAllMessages());
  }

  void onChatClosed() {
    _opened = false;
  }

  Future<void> _readAllMessages() async {
    chatsRepo.readAllMessages(preview.id);
    preview = preview.copyWith(unreadCount: () => 0);
    notifyListeners();
  }

  Future<void> sendTypingEvent(bool typing) async {
    final event = ChatEvent$Typing(chatId: preview.id, senderId: userId, timestamp: DateTime.now(), typing: typing);
    sendEvent(event);
  }

  Future<void> sendMessage(String text, {List<String> attachments = const []}) async {
    final now = DateTime.now();
    final event = ChatEvent$Message(
      chatId: preview.id,
      senderId: userId,
      timestamp: now,
      message: ChatMessage(
        id: 0,
        senderId: userId,
        content: text,
        contentType: 'text',
        status: 'sent',
        sentAt: now,
        isOwnMessage: true,
        attachments: attachments,
      ),
    );
    sendEvent(event);
  }

  Future<void> handleEvent(ChatEvent event) async {
    logger.debug('chat event received: ${event.runtimeType} for chat with id: ${preview.id}');
    if (event case ChatEvent$Message(message: ChatMessage message)) {
      _onMessageReceived(message);
    }
    if (event case ChatEvent$MessageRead(chatId: int chatId, senderId: int senderId)) {
      _onMessagesRead(chatId, senderId);
    }
    if (event case ChatEvent$Typing(typing: bool typing) when event.senderId == preview.otherUserId) {
      preview = preview.copyWith(isTyping: () => typing);
    }
    if (event case ChatEvent$Online(online: bool online)) {
      preview = preview.copyWith(isOnline: () => online);
    }
    notifyListeners();
  }

  Future<void> _onMessagesRead(int chatId, int senderId) async {
    final pages = state.pages
        ?.map((page) => page.map((message) => message.copyWith(status: () => 'read')).toList())
        .toList();
    emit(state.copyWith(pages: pages, keys: state.keys));
  }

  Future<void> _onMessageReceived(ChatMessage msg) async {
    final unreadCount =
        preview.unreadCount +
        (msg.isOwnMessage
            ? 0
            : _opened
            ? 0
            : 1);
    preview = preview.copyWith(lastMessage: () => msg.content, unreadCount: () => unreadCount);
    if (state.pages?.isNotEmpty ?? false) {
      final newMsg = msg.copyWith(status: msg.isOwnMessage ? null : () => 'read');
      emit(
        state.copyWith(
          pages: [
            [newMsg],
            ...?state.pages,
          ],
          keys: [0, ...?state.keys],
        ),
      );
    } else {
      reset();
    }
    if (_opened) {
      sendEvent(ChatEvent$MessageRead(chatId: preview.id, senderId: userId, timestamp: DateTime.now()));
    }
  }
}
