import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

enum AddContactOption { fromContacts, manually }

Future<AddContactOption?> showAddContactOptionMbs(BuildContext context) {
  return showModalBottomSheet<AddContactOption>(
    context: context,
    backgroundColor: context.ext.theme.backgroundDefault,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => const _AddContactMbs(),
  );
}

class _AddContactMbs extends StatelessWidget {
  const _AddContactMbs();

  @override
  Widget build(BuildContext context) {
    return MbsBase(
      expandContent: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText('Добавь контакт', style: AppTextStyles.headingLarge),
          const SizedBox(height: 16),
          const AppText.secondary('Выбери, как ты хочешь создать контакт'),
          const SizedBox(height: 24),
          const _Option(
            option: AddContactOption.fromContacts,
            icon: AppIcons.userAlt,
            text: 'Выбрать из списка контактов',
          ),
          Divider(height: 1, color: context.ext.theme.backgroundDisabled),
          const _Option(option: AddContactOption.manually, icon: AppIcons.edit, text: 'Создать контакт вручную'),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({required this.option, required this.icon, required this.text});

  final AddContactOption option;
  final AppIcons icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.ext.pop(option),
      child: Container(
        color: Colors.transparent, // Important for tap recognition over all card (wraps it with Material)
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            icon.icon(context),
            Flexible(
              child: AppText(
                text,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
