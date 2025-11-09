import 'package:flutter/material.dart';
import 'package:polka_masters/features/contacts/controller/contact_groups_cubit.dart';
import 'package:polka_masters/features/contacts/widgets/group_screens/blacklist_contacts_screen.dart';
import 'package:polka_masters/features/contacts/widgets/group_screens/contact_group_search_screen.dart';
import 'package:polka_masters/features/contacts/widgets/group_screens/scheduled_tomorrow_screen.dart';
import 'package:polka_masters/features/contacts/widgets/small_chip.dart';
import 'package:shared/shared.dart';

class ContactsGroupsView extends StatelessWidget {
  const ContactsGroupsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DataBuilder<ContactGroupsCubit, Map<ContactGroup, int>>(
      cubit: blocs.get<ContactGroupsCubit>(context),
      dataBuilder: (_, groups) => RefreshWidget(
        refresh: blocs.get<ContactGroupsCubit>(context).load,
        child: SingleChildScrollView(
          child: Column(
            children: [for (var MapEntry(:key, :value) in groups.entries) _GroupContainer(group: key, count: value)],
          ),
        ),
      ),
    );
  }
}

class _GroupContainer extends StatelessWidget {
  const _GroupContainer({required this.group, required this.count});

  final ContactGroup group;
  final int count;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final page = switch (group) {
          ContactGroup.blacklist => const BlacklistContactsScreen(),
          ContactGroup.scheduledTomorrow => const ScheduledTomorrowScreen(),
          ContactGroup.needReappointment ||
          ContactGroup.lost => ContactGroupSearchScreen(group: group, remindButton: true),
          _ => ContactGroupSearchScreen(group: group),
        };
        context.ext.push(page);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.ext.theme.backgroundHover)),
        ),
        child: Row(
          spacing: 8,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: context.ext.theme.backgroundHover, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: AppText(group.blob, style: AppTextStyles.headingLarge),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(group.label),
                  AppText.secondary(group.description, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  SmallChip(text: count.pluralMasculine('клиент')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
