import 'package:flutter/material.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/features/contacts/controller/contact_groups_cubit.dart';
import 'package:polka_masters/features/contacts/controller/contact_search_cubit.dart';
import 'package:polka_masters/features/contacts/widgets/booking_history_card.dart';
import 'package:polka_masters/features/contacts/widgets/booking_history_screen.dart';
import 'package:polka_masters/features/contacts/widgets/communication_buttons.dart';
import 'package:polka_masters/features/contacts/widgets/contact_avatar.dart';
import 'package:shared/shared.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key, required this.contactId});

  final int contactId;

  @override
  Widget build(BuildContext context) {
    return LoadDataPage(
      future: () => Dependencies().contactsRepo.getContactInfo(contactId),
      builder: (info) => _View(info: info),
    );
  }
}

class _View extends StatefulWidget {
  const _View({required this.info});

  final ContactInfo info;

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  late var contact = widget.info.contact.copyWith();

  late final _controllers = [
    TextEditingController(text: contact.name),
    TextEditingController(text: contact.city),
    TextEditingController(text: contact.birthday?.toDateString('.')),
    TextEditingController(text: phoneMask.maskText(contact.number.replaceAll('+', '').substring(1))),
    TextEditingController(text: contact.email),
    TextEditingController(text: contact.notes),
  ];
  final emailValidator = Validators.email;

  @override
  void dispose() {
    for (var ctrl in _controllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _updateContact({String? name, String? city, DateTime? birthday, String? email, String? notes}) async {
    logger.debug([?name, ?city, ?birthday, ?email, ?notes].join(', '));

    final res = await Dependencies().contactsRepo.updateContact(
      contact.id,
      name: name,
      city: city,
      birthday: birthday,
      email: email,
      notes: notes,
    );
    if (mounted) {
      res.when(
        ok: (data) => showSnackbar(infoSnackbar(const AppText('Контакт успешно обновлен'), bottom: 0)),
        err: handleError,
      );
    }
  }

  void _blockContact() async {
    final res = await Dependencies().contactsRepo.blockContact(contact.id);
    if (mounted) {
      res.when(
        ok: (data) {
          setState(() => contact = contact.copyWith(isBlocked: () => true));
          showSnackbar(infoSnackbar(const AppText('Контакт добавлен в черный список'), bottom: 0));
          blocs.get<ContactGroupsCubit>(context).load();
          blocs.get<ContactSearchCubit>(context).search();
        },
        err: handleError,
      );
    }
  }

  void _unblockContact() async {
    final res = await Dependencies().contactsRepo.unblockContact(contact.id);
    if (mounted) {
      res.when(
        ok: (data) {
          setState(() => contact = contact.copyWith(isBlocked: () => false));
          showSnackbar(infoSnackbar(const AppText('Контакт разблокирован'), bottom: 0));
          blocs.get<ContactGroupsCubit>(context).load();
          blocs.get<ContactSearchCubit>(context).search();
        },
        err: handleError,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: 'Твой клиент'),
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(child: _Header(widget.info)),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
                child: CommunicationButtons(contact: contact),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 12, 24, 12),
                child: AppText('Персональная информация', style: AppTextStyles.headingSmall),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Column(
                  spacing: 8,
                  children: [
                    AppTextFormField(
                      controller: _controllers[0],
                      labelText: 'Имя и Фамилия',
                      onFieldSubmitted: (name) => _updateContact(name: name.trim()),
                    ),
                    AppTextFormField(
                      controller: _controllers[1],
                      labelText: 'Город',
                      onFieldSubmitted: (city) => _updateContact(city: city.trim()),
                    ),
                    AppTextFormField(
                      controller: _controllers[2],
                      labelText: 'День рождения',
                      inputFormatters: [birthdayMask],
                      onFieldSubmitted: (birthday) {
                        final date = DateTime.tryParse(birthday.split('.').reversed.join('-'));
                        _updateContact(birthday: date);
                      },
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 12, 24, 12),
                child: AppText('Контакты', style: AppTextStyles.headingSmall),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Column(
                  spacing: 8,
                  children: [
                    AppTextFormField(
                      controller: _controllers[3],
                      labelText: 'Номер телефона',
                      readOnly: true,
                      enabled: false,
                      inputFormatters: [phoneMask],
                    ),
                    AppTextFormField(
                      controller: _controllers[4],
                      labelText: 'E-mail',
                      onFieldSubmitted: (email) {
                        final valid = email.isNotEmpty && emailValidator(email) == null;
                        if (valid) _updateContact(email: email);
                      },
                      validator: emailValidator,
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 12, 24, 12),
                child: AppText('Заметки', style: AppTextStyles.headingSmall),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: AppTextFormField(
                  controller: _controllers[5],
                  labelText: 'Например, аллергия на коллаген',
                  maxLines: 5,
                  maxLength: 1000,
                  onFieldSubmitted: (notes) => _updateContact(notes: notes.trim()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                child: Row(
                  children: [
                    const Expanded(child: AppText('Последние визиты', style: AppTextStyles.headingSmall)),
                    if (widget.info.lastBookings.isNotEmpty)
                      AppLinkButton(
                        text: 'Смотреть все',
                        onTap: () {
                          context.ext.push(BookingHistoryScreen(info: widget.info));
                        },
                      ),
                  ],
                ),
              ),
              if (widget.info.lastBookings.isNotEmpty) ...[
                for (var booking in widget.info.lastBookings.take(2)) BookingHistoryCard(booking: booking),
              ] else
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: AppText.secondary(
                    'У этого клиента еще нет посещений, может, ты сможешь показать ей что-то интересное',
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: contact.isBlocked
                    ? AppTextButtonSecondary.large(text: 'Разблокировать', onTap: _unblockContact)
                    : AppTextButtonDangerous.large(text: 'Добавить в черный список', onTap: _blockContact),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.info);

  final ContactInfo info;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
      child: Column(
        children: [
          ContactBlotAvatar(contact: info.contact),
          const SizedBox(height: 4),
          AppText(
            info.contact.name,
            style: AppTextStyles.headingLarge.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          AppText(
            contactLabel(info.contact),
            style: AppTextStyles.bodyLarge.copyWith(color: context.ext.theme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              AppText('📍 ${info.contact.city}'),
              AppText('✂️ ${pluralizeAppointments(info.totalAppointmentsCount)}'),
            ],
          ),
        ],
      ),
    );
  }
}

String contactLabel(Contact contact) =>
    contact.group == ContactGroup.neW ? '${contact.group!.blob} Новый клиент' : 'Клиент';

String pluralizeAppointments(int count) =>
    count.pluralize(one: 'посещение', few: 'посещения', many: 'посещений', other: 'посещений');
