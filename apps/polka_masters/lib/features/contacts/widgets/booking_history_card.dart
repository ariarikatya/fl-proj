import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class BookingHistoryCard extends StatelessWidget {
  const BookingHistoryCard({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return DebugWidget(
      model: booking,
      child: Container(
        height: 82,
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.ext.colors.white[300])),
        ),
        child: Row(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImageClipped(imageUrl: booking.serviceImageUrl, width: 48, height: 48, borderRadius: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  AppText(
                    booking.serviceName,
                    maxLines: 2,
                    style: AppTextStyles.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppText.rich([
                    WidgetSpan(child: FIcons.clock.icon(context, size: 16), alignment: PlaceholderAlignment.middle),
                    TextSpan(
                      text: ' ${booking.duration.toDurationStringShort()}  |  ₽ ${booking.price}',
                      style: AppTextStyles.bodyMedium500.copyWith(color: context.ext.colors.black[700], height: 1),
                    ),
                  ]),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppText('${booking.date.day}.${booking.date.month}.${booking.date.year}'),
                AppText(
                  booking.status.label,
                  style: AppTextStyles.bodyMedium.copyWith(color: booking.status.colorOf(context)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
