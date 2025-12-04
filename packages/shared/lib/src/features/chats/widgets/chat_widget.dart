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
                Stack(
                  children: [
                    ImageClipped(imageUrl: chat.preview.otherUserAvatar, borderRadius: 64, height: 64, width: 64),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: ListenableBuilder(
                        listenable: chat,
                        builder: (context, child) {
                          // if (chat.preview.isOnline) {
                          return Container(
                            height: 12,
                            width: 12,
                            decoration: BoxDecoration(
                              color: chat.preview.isOnline ? context.ext.colors.success : context.ext.colors.white[200],
                              shape: BoxShape.circle,
                            ),
                          );
                          // }
                          // return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListenableBuilder(
                    listenable: chat,
                    builder: (context, child) => Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: AppText(chat.preview.otherUserName, overflow: TextOverflow.ellipsis)),
                            Padding(padding: EdgeInsets.only(left: 8), child: FIcons.check.icon(context)),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            Expanded(
                              child: AppText(
                                (chat.preview.lastMessage ?? 'Пока что нет сообщений'),
                                style: AppTextStyles.bodyMedium.copyWith(color: context.ext.colors.black[700]),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                            if (chat.preview.unreadCount > 0)
                              CounterWidget(count: chat.preview.unreadCount, color: context.ext.colors.error),
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

class CounterWidget extends StatelessWidget {
  const CounterWidget({super.key, required this.count, required this.color});

  final int count;
  final Color color;

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
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(40)),
      alignment: Alignment.center,
      child: AppText(
        '$count',
        textAlign: TextAlign.center,
        style: AppTextStyles.bodySmall.copyWith(color: context.ext.colors.white[100], overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
