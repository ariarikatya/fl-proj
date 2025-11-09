import 'package:flutter/material.dart';
import 'package:polka_masters/features/contacts/widgets/contact_avatar.dart';
import 'package:polka_masters/features/contacts/widgets/small_chip.dart';
import 'package:shared/shared.dart';

class ContactTile extends StatelessWidget {
  const ContactTile({super.key, required this.contact, this.onTap, this.button});

  final Contact contact;
  final VoidCallback? onTap;
  final Widget? button;

  @override
  Widget build(BuildContext context) {
    return DebugWidget(
      model: contact,
      child: GestureDetector(
        onTap: onTap,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              spacing: 8,
              children: [
                ContactAvatar(contact),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        spacing: 8,
                        children: [
                          Expanded(child: AppText(contact.name, overflow: TextOverflow.ellipsis)),
                          if (contact.group != null && !contact.isBlocked)
                            AppText(
                              '${contact.group!.blob} ${contact.group!.labelSingleVariant}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: contact.group == ContactGroup.neW
                                    ? context.ext.theme.success
                                    : context.ext.theme.iconsDefault,
                              ),
                            ),
                        ],
                      ),
                      AppText.secondary(
                        phoneFormatter.maskText(contact.number),
                        style: AppTextStyles.bodyMedium500,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (contact.lastAppointmentDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: SmallChip(text: 'Последний визит: ${contact.lastAppointmentDate!.toDateString('.')}'),
                        ),
                    ],
                  ),
                ),
                ?button,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
