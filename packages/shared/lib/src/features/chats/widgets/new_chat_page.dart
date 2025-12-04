import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class NewChatPage extends StatefulWidget {
  const NewChatPage({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.withClient,
    this.prependText,
  });

  final int otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final bool withClient;
  final String? prependText;

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  void _startChat(String text, {List<String> attachments = const []}) async {
    final chats = context.read<ChatsCubit>();
    await chats.startChat(widget.otherUserId, text, withClient: widget.withClient);
    if (!mounted) return;
    await chats.loadChats(force: true);
    if (!mounted) return;
    final chat = chats.maybeGetChatWithOtherUserId(widget.otherUserId);
    if (mounted && chat != null) {
      context.ext.replace(ChatScreen(chatId: chat.preview.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: CustomAppBar(
        titleWidget: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: context.ext.colors.black[500], borderRadius: BorderRadius.circular(8)),
            ),
            Flexible(child: AppText(widget.otherUserName)),
          ],
        ),
        action: Padding(
          padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
          child: ImageClipped(imageUrl: widget.otherUserAvatar, borderRadius: 40),
        ),
      ),
      child: Column(
        children: [
          Expanded(child: Center(child: AppText('Пока что нет сообщений'))),
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: ChatInputField(onSubmit: _startChat, onTyping: (_) {}, initialText: widget.prependText),
          ),
        ],
      ),
    );
  }
}
