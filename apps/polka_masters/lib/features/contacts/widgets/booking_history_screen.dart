import 'package:flutter/material.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/features/contacts/controller/booking_history_cubit.dart';
import 'package:polka_masters/features/contacts/widgets/booking_history_card.dart';
import 'package:polka_masters/features/contacts/widgets/contact_avatar.dart';
import 'package:polka_masters/features/contacts/widgets/contact_screen.dart';
import 'package:shared/shared.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key, required this.info});

  final ContactInfo info;

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  late final _cubit = BookingHistoryCubit(widget.info.contact.id, Dependencies().bookingsRepository);

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: 'Визиты клиента'),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                color: context.ext.theme.backgroundSubtle,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                spacing: 16,
                children: [
                  ContactBlotAvatar(contact: widget.info.contact, size: 70),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        AppText(
                          widget.info.contact.name,
                          style: AppTextStyles.headingSmall.copyWith(height: 1),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppText(
                          contactLabel(widget.info.contact),
                          style: AppTextStyles.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppText.secondary(
                          '${widget.info.contact.city} | ${pluralizeAppointments(widget.info.totalAppointmentsCount)}',
                          style: AppTextStyles.bodySmall500,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText('Все визиты', style: AppTextStyles.headingLarge),
                  AppText.secondary('Здесь собраны все посещения клиента', style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
          ),
          Expanded(
            child: PaginationBuilder<BookingHistoryCubit, Booking>(
              cubit: _cubit,
              emptyBuilder: (_) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: AppText('У этого клиента пока нет визитов', textAlign: TextAlign.center),
                ),
              ),
              itemBuilder: (context, index, item) {
                final prevItem = (index > 0 && (_cubit.items?.length ?? 0) > index - 1)
                    ? _cubit.items![index - 1]
                    : null;
                // final nextItem = index < (_cubit.items?.length ?? -1) - 1 ? (_cubit.items?[index + 1]) : null;

                // Add year label if years are different
                if (prevItem == null || prevItem.date.year != item.date.year) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                        child: AppText(item.date.year.toString(), style: AppTextStyles.headingSmall),
                      ),
                      BookingHistoryCard(booking: item),
                    ],
                  );
                }
                return BookingHistoryCard(booking: item);
              },
            ),
          ),
        ],
      ),
    );
  }
}
