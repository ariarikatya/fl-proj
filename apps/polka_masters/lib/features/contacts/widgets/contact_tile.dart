import 'package:flutter/material.dart';
import 'package:polka_masters/features/contacts/widgets/contact_avatar.dart';
import 'package:shared/shared.dart';

class ContactTile extends StatelessWidget {
  const ContactTile({super.key, required this.contact, this.onTap, this.onClose});

  final Contact contact;
  final VoidCallback? onTap;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: 64,
          padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Row(
            spacing: 8,
            children: [
              ContactAvatar(contact.avatarUrl),
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
              if (onClose != null)
                GestureDetector(
                  onTap: onClose,
                  child: Padding(padding: EdgeInsets.fromLTRB(8, 8, 0, 8), child: AppIcons.close.icon(context)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
