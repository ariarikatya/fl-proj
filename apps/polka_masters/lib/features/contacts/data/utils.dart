import 'package:flutter/material.dart';
import 'package:polka_masters/features/contacts/data/contact_reminder.dart';
import 'package:polka_masters/features/contacts/data/write_contact_option.dart';
import 'package:polka_masters/features/contacts/widgets/write_contact_mbs.dart';
import 'package:shared/shared.dart';

Future<void> remindContact(BuildContext context, Contact contact, ContactReminder reminder) async {
  final option = await showWriteContactOptionsMbs(
    context,
    options: [
      WriteContactOption.whatsapp,
      WriteContactOption.telegram,
      if (contact.clientId != null) WriteContactOption.polka,
    ],
  );
  if (option != null && context.mounted) option.handle(context, contact, reminder.text);
}
