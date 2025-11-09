import 'package:flutter/material.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/features/contacts/controller/contact_groups_cubit.dart';
import 'package:polka_masters/features/contacts/controller/contact_search_cubit.dart';
import 'package:polka_masters/features/contacts/widgets/add_contact_mbs.dart';
import 'package:polka_masters/features/contacts/widgets/create_contact_screen.dart';
import 'package:polka_masters/features/contacts/widgets/device_contacts_screen.dart';
import 'package:shared/shared.dart';

class AddContactButton extends StatelessWidget {
  const AddContactButton({super.key, this.onContactCreated});

  final void Function(Contact contact)? onContactCreated;

  void _addContact(BuildContext context) async {
    final option = await showAddContactOptionMbs(context);
    if (!context.mounted) return;

    Contact? newContact;
    if (option == AddContactOption.manually) {
      newContact = await context.ext.push<Contact>(const CreateContactScreen());
    } else if (option == AddContactOption.fromContacts) {
      newContact = await context.ext.push<Contact>(const DeviceContactsScreen());
    }

    if (newContact != null && context.mounted) {
      final createdContact = await _createContact(context, newContact);
      if (createdContact != null && context.mounted) {
        blocs.get<ContactSearchCubit>(context).search();
        blocs.get<ContactGroupsCubit>(context).load();
        onContactCreated?.call(newContact);
      }
    }
  }

  Future<Contact?> _createContact(BuildContext context, Contact contact) async {
    final result = await Dependencies().contactsRepo.createContact(contact);
    if (result.isOk) showInfoSnackbar('Клиент успешно добавлен');
    return result.unpack();
  }

  @override
  Widget build(BuildContext context) {
    return AppFloatingActionButton$Add(text: 'Добавить клиента', onTap: () => _addContact(context));
  }
}
