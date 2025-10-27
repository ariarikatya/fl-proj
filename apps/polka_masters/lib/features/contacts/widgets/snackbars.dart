import 'package:flutter/material.dart';
import 'package:polka_masters/features/contacts/widgets/contact_avatar.dart';
import 'package:shared/shared.dart';

SnackBar contactAddedSnackbar(BuildContext context, Contact contact) => infoSnackbar(
  Row(
    spacing: 8,
    children: [
      ContactAvatar(contact.avatarUrl),
      Flexible(
        child: AppText.rich([
          TextSpan(
            text: '${contact.name} ',
            style: AppTextStyles.bodyLarge.copyWith(color: context.ext.theme.textPlaceholder),
          ),
          TextSpan(
            text: 'успешно добавлена в твои контакты',
            style: AppTextStyles.bodyLarge.copyWith(color: context.ext.theme.textPrimary),
          ),
        ], maxLines: 3),
      ),
    ],
  ),
);
