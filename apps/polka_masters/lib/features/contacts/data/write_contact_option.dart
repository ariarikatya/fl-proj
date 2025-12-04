import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

enum WriteContactOption {
  whatsapp(AppIcons.whatsapp, 'WhatsApp'),
  telegram(AppIcons.telegram, 'Telegram'),
  polka(AppIcons.chatCircle, 'чат POLKA');

  const WriteContactOption(this.icon, this.optionName);
  final AppIcons icon;
  final String optionName;

  void handle(BuildContext context, Contact contact, String text) {
    if (this == WriteContactOption.polka && contact.clientId != null) {
      ChatsUtils().openChat(
        context,
        contact.clientId!,
        contact.name,
        contact.avatarUrl,
        withClient: true,
        prependText: text,
      );
    } else {
      final link = switch (this) {
        WriteContactOption.whatsapp => Uri.https('wa.me', '/${contact.numberDigitsOnly}', {'text': text}),
        WriteContactOption.telegram => Uri.https('t.me', '/+${contact.numberDigitsOnly}', {'text': text}),
        _ => throw Exception('Unsupported link option: $this'),
      };
      launchUrl(link);
    }
  }
}
