import 'package:flutter/material.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/features/contacts/controller/contact_search_cubit.dart';
import 'package:polka_masters/features/contacts/widgets/contact_screen.dart';
import 'package:polka_masters/features/contacts/widgets/contact_tile.dart';
import 'package:shared/shared.dart';

class BlacklistContactsScreen extends StatefulWidget {
  const BlacklistContactsScreen({super.key});

  @override
  State<BlacklistContactsScreen> createState() => _BlacklistContactsScreenState();
}

class _BlacklistContactsScreenState extends State<BlacklistContactsScreen> {
  late final _controller = TextEditingController();
  late final _search = BlacklistContactSearchCubit(Dependencies().contactsRepo);

  @override
  void initState() {
    _search.bindController(_controller);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _search.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: CustomAppBar(title: '${ContactGroup.blacklist.blob} ${ContactGroup.blacklist.label}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                const AppText('Черный список', style: AppTextStyles.headingLarge),
                AppText(
                  'Здесь удаленные или проблемные клиенты, с которыми ты ограничела контакт',
                  style: AppTextStyles.bodyMedium500.copyWith(color: context.ext.theme.iconsDefault),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: AppTextFormField(
              hintText: 'Имя или номер телефона',
              prefixIcon: AppIcons.search.icon(context, color: context.ext.theme.textPlaceholder),
              controller: _controller,
            ),
          ),
          Expanded(
            child: SearchBuilder<BlacklistContactSearchCubit, Contact>(
              cubit: _search,
              itemBuilder: (context, index, item) => ContactTile(
                contact: item,
                onTap: () => context.ext.push(ContactScreen(contactId: item.id)).then((_) {
                  _search.search();
                }),
              ),
              emptyBuilder: (_) => const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    AppText(
                      'К сожалению, такого\nклиента у тебя нет',
                      style: AppTextStyles.headingSmall,
                      textAlign: TextAlign.center,
                    ),
                    AppText.secondary(
                      'Попробуй изменить запрос\nили добавь новый контакт',
                      style: AppTextStyles.bodyMedium500,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
