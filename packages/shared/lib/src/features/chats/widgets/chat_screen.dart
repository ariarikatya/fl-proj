import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shared/shared.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.chatId});

  final int chatId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final chat = blocs.get<ChatsCubit>(context).chats[widget.chatId];

  @override
  void initState() {
    super.initState();
    chat?.onChatOpened();
  }

  @override
  void dispose() {
    chat?.onChatClosed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (chat == null) return AppPage(child: AppErrorWidget(error: 'Чат не найден'));
    return _ChatView(chat: chat!);
  }
}

class _ChatView extends StatelessWidget {
  const _ChatView({required this.chat});

  final ChatController chat;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: CustomAppBar(
        titleWidget: ListenableBuilder(
          listenable: chat,
          child: Flexible(
            child: AppText(chat.preview.otherUserName, style: AppTextStyles.bodyLarge.copyWith(height: 1)),
          ),
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: chat.preview.isOnline ? context.ext.theme.success : context.ext.theme.borderStrong,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child!,
                  ],
                ),
                if (chat.preview.isTyping) AppText('печатает...', style: AppTextStyles.bodySmall),
              ],
            );
          },
        ),
        action: Padding(
          padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
          child: ImageClipped(imageUrl: chat.preview.otherUserAvatar, borderRadius: 40),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: PaginationBuilder<ChatController, ChatMessage>(
              cubit: chat,
              reverse: true,
              invisibleItemsThreshold: 10,
              padding: EdgeInsets.symmetric(vertical: 16),
              separatorBuilder: (_, __) => SizedBox(height: 8),
              emptyBuilder: (_) => Center(child: AppText('Пока что нет сообщений')),
              itemBuilder: (context, index, item) {
                final previousMessage = index < (chat.state.items?.length ?? -1) - 1
                    ? (chat.state.items?[index + 1])
                    : null;
                return MessageBubble(previousMessageTimestamp: previousMessage?.sentAt, message: item);
              },
            ),
          ),
          ChatInputField(onSubmit: chat.sendMessage, onTyping: chat.sendTypingEvent),
        ],
      ),
    );
  }
}
