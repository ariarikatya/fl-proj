import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

enum WriteContactOption {
  whatsapp(AppIcons.whatsapp, 'WhatsApp'),
  telegram(AppIcons.telegram, 'Telegram'),
  polka(AppIcons.chatCircle, 'чат POLKA');

  const WriteContactOption(this.icon, this.optionName);
  final AppIcons icon;
  final String optionName;

  void handle(BuildContext context, Contact contact) {
    if (this == WriteContactOption.polka && contact.clientId != null) {
      ChatsUtils().openChat(context, contact.clientId!, contact.name, contact.avatarUrl, withClient: true);
    } else {
      final link = switch (this) {
        WriteContactOption.whatsapp => Uri.https('wa.me', '/${contact.number}', {'text': 'Hello from Polka!'}),
        WriteContactOption.telegram => Uri.https('t.me', '/+${contact.number}', {'text': 'Hello from Polka!'}),
        _ => throw Exception('Unsupported link option: $this'),
      };
      launchUrl(link);
    }
  }
}

Future<WriteContactOption?> showWriteContactOptionsMbs(
  BuildContext context, {
  List<WriteContactOption> options = WriteContactOption.values,
}) {
  return showModalBottomSheet<WriteContactOption>(
    context: context,
    backgroundColor: context.ext.theme.backgroundDefault,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => _WriteContactMbs(options: options),
  );
}

class _WriteContactMbs extends StatelessWidget {
  const _WriteContactMbs({required this.options});

  final List<WriteContactOption> options;

  @override
  Widget build(BuildContext context) {
    return MbsBase(
      expandContent: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText('Выбери способ связи', style: AppTextStyles.headingLarge),
          const SizedBox(height: 16),
          const AppText.secondary('Выбери, как ты хочешь связаться с клиентом,  чтобы напомнить о себе'),
          const SizedBox(height: 24),
          for (final (index, option) in options.indexed) ...[
            _Option(option: option, icon: option.icon, text: 'Написать в ${option.optionName}'),
            if (index < options.length - 1) Divider(height: 1, color: context.ext.theme.backgroundDisabled),
          ],
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({required this.option, required this.icon, required this.text});

  final WriteContactOption option;
  final AppIcons icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.ext.pop(option),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            icon.icon(context),
            Flexible(
              child: AppText(
                text,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
