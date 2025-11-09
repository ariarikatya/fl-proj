import 'package:fast_contacts/fast_contacts.dart' as fast_contacts;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:polka_masters/features/contacts/controller/device_contacts_cubit.dart';
import 'package:polka_masters/features/contacts/widgets/contact_tile.dart';
import 'package:shared/shared.dart';

class DeviceContactsScreen extends StatefulWidget {
  const DeviceContactsScreen({super.key});

  @override
  State<DeviceContactsScreen> createState() => _DeviceContactsScreenState();
}

class _DeviceContactsScreenState extends State<DeviceContactsScreen> {
  late final _search = DeviceContactsCubit();
  late final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _search.bindController(_controller);
  }

  @override
  void dispose() {
    _search.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: 'Контакты'),
      child: LoadDataPage(
        future: () async {
          final res = await Permission.contacts.request();
          if (res.isGranted) {
            return Result<bool>.ok(true);
          } else {
            return Result<bool>.err('Permission denied');
          }
        },
        builder: (_) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: AppTextFormField(
                hintText: 'Имя или номер телефона',
                prefixIcon: AppIcons.search.icon(context, color: context.ext.theme.textPlaceholder),
                controller: _controller,
              ),
            ),
            Expanded(
              child: SearchBuilder<DeviceContactsCubit, fast_contacts.Contact>(
                cubit: _search,
                itemBuilder: (context, index, item) {
                  if (item.phones.isEmpty) return const SizedBox.shrink();

                  final number = item.phones.first.number.replaceAll(RegExp(r'[^0-9]'), '');
                  final contact = Contact(
                    id: -1,
                    name: item.displayName,
                    number: number,
                    email: item.emails.firstOrNull?.address,
                  );
                  return ContactTile(onTap: () => context.ext.pop(contact), contact: contact);
                },
                emptyBuilder: (_) => const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: AppText(
                      'Мы не нашли контактов в твоем телефоне',
                      style: AppTextStyles.headingSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
