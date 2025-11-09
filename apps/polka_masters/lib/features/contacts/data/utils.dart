import 'package:flutter/material.dart';
import 'package:polka_masters/features/contacts/widgets/write_contact_mbs.dart';
import 'package:shared/shared.dart';

Future<void> remindContact(BuildContext context, Contact contact) async {
  final option = await showWriteContactOptionsMbs(
    context,
    options: [
      WriteContactOption.whatsapp,
      WriteContactOption.telegram,
      if (contact.clientId != null) WriteContactOption.polka,
    ],
  );
  if (option != null && context.mounted) option.handle(context, contact);
}
