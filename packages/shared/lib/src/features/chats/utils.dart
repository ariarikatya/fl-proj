import 'package:flutter/material.dart';
import 'package:shared/src/blocs_provider.dart';
import 'package:shared/src/extensions/context.dart';
import 'package:shared/src/features/chats/widgets/chat_screen.dart';
import 'package:shared/src/features/chats/cubit/chats_cubit.dart';
import 'package:shared/src/features/chats/widgets/new_chat_page.dart';
import 'package:shared/src/result.dart';
import 'package:shared/src/utils.dart';

final class ChatsUtils {
  ChatsUtils._();

  factory ChatsUtils() => _instance;
  static final _instance = ChatsUtils._();

  Future<void> callNumber(Future<Result<String>> getNumber) async {
    final phone = await getNumber;

    phone.when(
      ok: (phone) {
        try {
          launchUrl(Uri.parse('tel:+$phone'));
        } catch (e, st) {
          handleError(e, st);
        }
      },
      err: (e, st) => handleError(e, st),
    );
  }

  Future<void> openChat(
    BuildContext context,
    int otherUserId,
    String otherUserName,
    String? otherUserAvatar, {
    required bool withClient,
  }) async {
    final chats = blocs.get<ChatsCubit>(context);
    await chats.loadChats();
    if (!context.mounted) return;

    final chat = chats.maybeGetChatWithOtherUserId(otherUserId);
    if (chat != null) {
      context.ext.push(ChatScreen(chatId: chat.preview.id));
    } else {
      context.ext.push(
        NewChatPage(
          otherUserId: otherUserId,
          otherUserName: otherUserName,
          otherUserAvatar: otherUserAvatar,
          withClient: withClient,
        ),
      );
    }
  }
}
