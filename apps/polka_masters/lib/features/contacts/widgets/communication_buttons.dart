import 'package:flutter/material.dart';
import 'package:polka_masters/features/contacts/widgets/write_contact_mbs.dart';
import 'package:shared/shared.dart';

class CommunicationButtons extends StatelessWidget {
  const CommunicationButtons({super.key, required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        if (contact.clientId != null)
          Expanded(
            child: AppTextButtonSecondary.large(
              text: 'Чат',
              onTap: () {
                ChatsUtils().openChat(context, contact.clientId!, contact.name, contact.avatarUrl, withClient: false);
              },
            ),
          )
        else
          Expanded(
            child: AppTextButtonSecondary.large(
              text: 'Написать',
              onTap: () async {
                final option = await showWriteContactOptionsMbs(
                  context,
                  options: [WriteContactOption.whatsapp, WriteContactOption.telegram],
                );
                if (option != null && context.mounted) {
                  option.handle(context, contact);
                }
              },
            ),
          ),
        Expanded(
          child: AppTextButtonSecondary.large(
            text: 'Позвонить',
            onTap: () {
              ChatsUtils().callNumber(Future.value(Result.ok(contact.number)));
            },
          ),
        ),
      ],
    );
  }
}
