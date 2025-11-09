import 'package:flutter/material.dart';
import 'package:polka_masters/features/contacts/widgets/contact_avatar.dart';
import 'package:shared/shared.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({super.key, required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: context.ext.theme.backgroundHover, borderRadius: BorderRadius.circular(14)),
      child: Row(
        spacing: 8,
        children: [
          ContactAvatar(contact, size: 48, fontSize: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(contact.name, overflow: TextOverflow.ellipsis),
                AppText.secondary(
                  phoneFormatter.maskText(contact.number),
                  style: AppTextStyles.bodyMedium500,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
