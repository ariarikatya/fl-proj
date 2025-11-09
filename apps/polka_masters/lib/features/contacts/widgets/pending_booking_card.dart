import 'package:flutter/material.dart';
import 'package:polka_masters/features/contacts/widgets/contact_tile.dart';
import 'package:shared/shared.dart';

class PendingBookingCard extends StatelessWidget {
  const PendingBookingCard({
    super.key,
    required this.info,
    required this.onAccept,
    required this.onReject,
    this.acceptLabel,
    this.rejectLabel,
  });

  final BookingInfo info;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final String? acceptLabel;
  final String? rejectLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ContactTile(contact: info.contact),
        Divider(color: context.ext.theme.backgroundHover, height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(child: AppText.secondary('Услуга', style: AppTextStyles.bodyMedium)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      spacing: 4,
                      children: [
                        AppText(
                          info.service.title,
                          maxLines: 2,
                          style: AppTextStyles.bodyLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppText.rich([
                          WidgetSpan(
                            child: AppIcons.clock.icon(context, size: 16),
                            alignment: PlaceholderAlignment.middle,
                          ),
                          TextSpan(
                            text: ' ${info.booking.duration.toDurationStringShort()}  |  ₽ ${info.booking.price}',
                            style: AppTextStyles.bodyMedium500.copyWith(
                              color: context.ext.theme.textSecondary,
                              height: 1,
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(child: AppText.secondary('Дата', style: AppTextStyles.bodyMedium)),
                  Expanded(
                    child: AppText(
                      info.booking.datetime.formatFull(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.ext.theme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (info.booking.clientNotes != null) ...[
                const AppText.secondary('Комментарий', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 8),
                AppText(info.booking.clientNotes!, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 24),
              ],
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: AppTextButtonDangerous.medium(text: rejectLabel ?? 'Отклонить', onTap: onReject),
                  ),
                  Expanded(
                    child: AppTextButton.medium(text: acceptLabel ?? 'Принять', onTap: onAccept),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
