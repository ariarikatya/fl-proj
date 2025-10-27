import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({super.key, required this.chat});

  final ChatController chat;

  @override
  Widget build(BuildContext context) {
    return DebugWidget(
      model: chat.preview,
      child: GestureDetector(
        onTap: () => context.ext.push(ChatScreen(chatId: chat.preview.id)),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                ImageClipped(imageUrl: chat.preview.otherUserAvatar, borderRadius: 64, height: 64, width: 64),
                Expanded(
                  child: ListenableBuilder(
                    listenable: chat,
                    builder: (context, child) => Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: AppText(chat.preview.otherUserName, overflow: TextOverflow.ellipsis)),
                            Padding(padding: EdgeInsets.only(left: 8), child: AppIcons.check.icon(context)),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            Expanded(
                              child: AppText(
                                (chat.preview.lastMessage ?? 'Пока что нет сообщений'),
                                style: AppTextStyles.bodyMedium.copyWith(color: context.ext.theme.textSecondary),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                            if (chat.preview.unreadCount > 0) _UnreadCounter(chat.preview.unreadCount),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UnreadCounter extends StatelessWidget {
  const _UnreadCounter(this.count);

  final int count;

  @override
  Widget build(BuildContext context) {
    final width = switch (count) {
      > 99 => 28.0,
      > 9 => 22.0,
      _ => 16.0,
    };
    return Container(
      width: width,
      height: 16,
      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(40)),
      alignment: Alignment.center,
      child: AppText(
        '$count',
        textAlign: TextAlign.center,
        style: AppTextStyles.bodySmall.copyWith(
          color: context.ext.theme.backgroundDefault,
          height: 0.75,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
