import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'package:shared/src/features/chats/chat_input_field.dart';

class NewChatPage extends StatefulWidget {
  const NewChatPage({super.key, required this.masterId, required this.masterName, required this.masterAvatar});

  final int masterId;
  final String masterName;
  final String? masterAvatar;

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  void _startChat(String text, {List<String> attachments = const []}) async {
    await blocs.get<ChatsCubit>(context).startChat(widget.masterId, text);
    if (!mounted) return;
    await blocs.get<ChatsCubit>(context).loadChats(force: true);
    if (!mounted) return;
    final chat = blocs.get<ChatsCubit>(context).maybeGetChatWithMasterId(widget.masterId);
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
              decoration: BoxDecoration(color: AppColors.borderStrong, borderRadius: BorderRadius.circular(8)),
            ),
            Flexible(child: AppText(widget.masterName)),
          ],
        ),
        action: Padding(
          padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
          child: ImageClipped(imageUrl: widget.masterAvatar, borderRadius: 40),
        ),
      ),
      child: Column(
        children: [
          Expanded(child: Center(child: AppText('Пока что нет сообщений'))),
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: ChatInputField(onSubmit: _startChat, onTyping: (_) {}),
          ),
        ],
      ),
    );
  }
}
