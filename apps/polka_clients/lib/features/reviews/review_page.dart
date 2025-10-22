import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:polka_clients/app_links.dart';
import 'package:polka_clients/dependencies.dart';
import 'package:polka_clients/features/booking/controller/bookings_cubit.dart';
import 'package:shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key, required this.booking});

  final Booking booking;

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final _tags = ValueNotifier<Set<ReviewTags>>({});
  final _images = ValueNotifier<List<XFile>>([]);
  late final _stars = ValueNotifier(0)..addListener(_validateContinue);
  late final _commentController = TextEditingController()..addListener(_validateContinue);
  final _continueNotifier = ValueNotifier<bool>(false);

  void _validateContinue() {
    _continueNotifier.value = _stars.value > 0 && _commentController.text.isNotEmpty;
  }

  @override
  void dispose() {
    _stars.dispose();
    _tags.dispose();
    _commentController.dispose();
    _images.dispose();
    super.dispose();
  }

  void _sendReview() async {
    final imageUrls = await Dependencies().profileRepository.uploadPhotos(_images.value);
    final result = await Dependencies().bookingsRepo.leaveReview(
      widget.booking.id,
      _stars.value,
      _tags.value.toList(),
      _commentController.text,
      imageUrls.unpack()?.values.toList() ?? [],
    );
    result.maybeWhen(
      ok: (data) {
        context.ext.pop(true);
        blocs.get<BookingsCubit>(context).markAsReviewed(widget.booking.id);
      },
      err: (e, st) => handleError,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: CustomAppBar(title: 'Оцени прошедшую услугу'),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _subtitle('Как все прошло?'),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: _BookingInfoCard(booking: widget.booking),
            ),
            _Stars(stars: _stars),
            Divider(color: AppColors.backgroundHover, height: 1),

            _subtitle('Что особенно понравилось?'),
            _Tags(tags: _tags),
            Divider(color: AppColors.backgroundHover, height: 1),

            _subtitle('Напиши комментарий'),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: AppTextFormField(
                hintText: 'Что было особенно приятно? Или что можно улучшить?',
                maxLines: 4,
                controller: _commentController,
                validator: Validators.isNotEmpty,
                maxLength: 1000,
              ),
            ),
            Divider(color: AppColors.backgroundHover, height: 1),

            _subtitle('Добавь фото'),
            MultiImagePickerWidget(count: 5, onImagesChanged: (images) => _images.value = images),

            Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: ValueListenableBuilder(
                valueListenable: _continueNotifier,
                builder: (context, enabled, child) {
                  return AppTextButton.large(text: 'Отправить отзыв', onTap: _sendReview, enabled: enabled);
                },
              ),
            ),

            _Disclaimer(),
          ],
        ),
      ),
    );
  }

  Widget _subtitle(String text) => Padding(
    padding: EdgeInsets.fromLTRB(24, 12, 24, 12),
    child: AppText(text, style: AppTextStyles.headingSmall.copyWith(fontWeight: FontWeight.w600)),
  );
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Нажимая кнопку, вы принимаете ',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
            WidgetSpan(
              child: GestureDetector(
                onTap: () => launchUrl(Uri.parse(AppLinks.reviewPublicationConditions)),
                child: AppText(
                  'условия публикации',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            TextSpan(
              text: ' отзыва - он появится в карточке мастера',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tags extends StatelessWidget {
  const _Tags({required ValueNotifier<Set<ReviewTags>> tags}) : _tags = tags;

  final ValueNotifier<Set<ReviewTags>> _tags;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 8, 16),
      child: ValueListenableBuilder(
        valueListenable: _tags,
        builder: (context, value, child) {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ReviewTags.values
                .map(
                  (e) => AppChip(
                    enabled: _tags.value.contains(e),
                    onTap: () => _tags.value = {..._tags.value, e},
                    onClose: () => _tags.value = {..._tags.value}..remove(e),
                    child: AppText(e.label, style: AppTextStyles.bodyMedium),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required ValueNotifier<int> stars}) : _stars = stars;

  final ValueNotifier<int> _stars;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Center(
        child: ValueListenableBuilder(
          valueListenable: _stars,
          builder: (context, value, child) {
            return Row(
              spacing: 8,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 1; i <= 5; i++)
                  GestureDetector(
                    onTap: () => _stars.value = i,
                    child: AppIcons.star.icon(
                      size: 44,
                      color: value >= i ? Colors.amberAccent : AppColors.backgroundDisabled,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BookingInfoCard extends StatelessWidget {
  const _BookingInfoCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final timeLabel =
        '${booking.date.formatShort()} • ${booking.startTime.toTimeString()}-${booking.endTime.toTimeString()}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ImageClipped(imageUrl: booking.serviceImageUrl, width: 64, height: 64, borderRadius: 12),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                booking.serviceName,
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
              ),
              SizedBox(height: 2),
              AppText(timeLabel, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500), maxLines: 1),
              AppText(
                booking.masterName,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
