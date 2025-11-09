import 'package:flutter/material.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/features/contacts/controller/contact_search_cubit.dart';
import 'package:polka_masters/features/contacts/data/utils.dart';
import 'package:polka_masters/features/contacts/widgets/contact_screen.dart';
import 'package:polka_masters/features/contacts/widgets/contact_tile.dart';
import 'package:shared/shared.dart';

class ContactGroupSearchScreen extends StatefulWidget {
  const ContactGroupSearchScreen({super.key, required this.group, this.remindButton = false});

  final ContactGroup group;
  final bool remindButton;

  @override
  State<ContactGroupSearchScreen> createState() => _ContactGroupSearchScreenState();
}

class _ContactGroupSearchScreenState extends State<ContactGroupSearchScreen> {
  late final _controller = TextEditingController();
  late final _search = ContactSearchCubit(Dependencies().contactsRepo, group: widget.group);

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

  ({String title, String description}) get heading => switch (widget.group) {
    ContactGroup.neW => (title: 'Новые клиенты', description: 'Здесь показаны клиенты, которым услуга оказана впервые'),
    ContactGroup.scheduledTomorrow => (
      title: 'Запись на завтра',
      description: 'Здесь показаны клиенты, которых ты ждешь завтра к себе',
    ),
    ContactGroup.regular => (
      title: 'Постоянные клиенты',
      description: 'Здесь показаны клиенты, которые посещают тебя больше 3 раз в месяц или 1 раз в месяц',
    ),
    ContactGroup.needReappointment => (
      title: 'Нужен повторный визит',
      description: 'Клиенты, которые не посещали тебя уже 3 недели, и больше, нужен контакт',
    ),
    ContactGroup.lost => (
      title: 'Потерявшиеся',
      description: 'Клиенты, которые посещали тебя 1 месяц назад или больше',
    ),
    ContactGroup.blacklist => (
      title: 'Черный список',
      description: 'Здесь удаленные или проблемные клиенты, с которыми ты ограничела контакт',
    ),
  };

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: CustomAppBar(title: '${widget.group.blob} ${widget.group.label}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                AppText(heading.title, style: AppTextStyles.headingLarge),
                AppText(
                  heading.description,
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
            child: SearchBuilder<ContactSearchCubit, Contact>(
              cubit: _search,
              itemBuilder: (context, index, item) => ContactTile(
                contact: item,
                onTap: () => context.ext.push(ContactScreen(contactId: item.id)).then((_) {
                  _search.search();
                }),
                button: widget.remindButton
                    ? AppTextButton.small(text: 'Напомнить', onTap: () => remindContact(context, item))
                    : null,
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
